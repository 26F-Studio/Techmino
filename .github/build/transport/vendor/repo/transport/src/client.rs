use base64::{engine::general_purpose::STANDARD, Engine};
use futures_util::{SinkExt, StreamExt};
use serde::Deserialize;
use serde_json::{json, Value};
use parking_lot::Mutex;
use std::{collections::HashMap, sync::{Arc, LazyLock}, time::Duration};
use tokio::sync::{mpsc, OwnedSemaphorePermit, Semaphore};
use tokio_tungstenite::{connect_async_tls_with_config, tungstenite::{client::IntoClientRequest, protocol::{frame::coding::CloseCode, CloseFrame, WebSocketConfig}, Message}, Connector};
use tokio_util::sync::CancellationToken;

pub const HTTP_LIMIT: usize = 2 * 1024 * 1024;
pub const WS_LIMIT: usize = 256 * 1024;
const EVENT_BYTES: usize = 4 * 1024 * 1024;
const MAX_OPERATIONS: usize = 24;
const MAX_HTTP: usize = 16;
const MAX_WS: usize = 4;

static RUNTIME: LazyLock<tokio::runtime::Runtime> = LazyLock::new(|| {
    tokio::runtime::Builder::new_multi_thread().worker_threads(2).enable_all().thread_name("product-transport").build().expect("transport runtime")
});
pub fn runtime() -> &'static tokio::runtime::Runtime { &RUNTIME }

#[derive(Deserialize, Default)]
#[serde(rename_all = "camelCase", deny_unknown_fields)]
pub struct Options { pub ca_pem: Option<String> }

pub struct Event { pub bytes: Vec<u8>, _permit: OwnedSemaphorePermit }
pub struct SocketCommand { message: Message, _permit: OwnedSemaphorePermit }
#[derive(Clone)]
pub enum Operation {
    Http(CancellationToken),
    Socket { cancel: CancellationToken, tx: mpsc::Sender<SocketCommand>, budget: Arc<Semaphore> },
    Callback(CancellationToken),
}

pub struct State {
    pub cancel: CancellationToken,
    http: reqwest::Client,
    tls: Arc<rustls::ClientConfig>,
    events: mpsc::Sender<Event>,
    budget: Arc<Semaphore>,
    pub operations: Mutex<HashMap<u64, Operation>>,
    last_id: Mutex<u64>,
    pub fatal: Mutex<Option<Vec<u8>>>,
}
pub struct Client { pub state: Arc<State>, pub events: Mutex<mpsc::Receiver<Event>>, pub pending: Mutex<Option<Event>> }

pub fn new(options: Options) -> Result<Client, &'static str> {
    let mut roots = rustls::RootCertStore::empty();
    roots.extend(webpki_roots::TLS_SERVER_ROOTS.iter().cloned());
    if let Some(pem) = options.ca_pem {
        if pem.len() > 64 * 1024 { return Err("INVALID_CA"); }
        let certs: Vec<_> = rustls_pemfile::certs(&mut std::io::Cursor::new(pem.as_bytes())).collect::<Result<_, _>>().map_err(|_| "INVALID_CA")?;
        if certs.is_empty() { return Err("INVALID_CA"); }
        for cert in certs { roots.add(cert).map_err(|_| "INVALID_CA")?; }
    }
    let tls = rustls::ClientConfig::builder_with_provider(Arc::new(rustls::crypto::ring::default_provider()))
        .with_safe_default_protocol_versions().map_err(|_| "TLS_CONFIGURATION")?.with_root_certificates(roots).with_no_client_auth();
    let http = reqwest::Client::builder().https_only(true).http1_only().redirect(reqwest::redirect::Policy::none())
        .connect_timeout(Duration::from_secs(10)).pool_max_idle_per_host(2).pool_idle_timeout(Duration::from_secs(30))
        .use_preconfigured_tls(tls.clone()).build().map_err(|_| "TLS_CONFIGURATION")?;
    let (events, rx) = mpsc::channel(128);
    Ok(Client { state: Arc::new(State { cancel: CancellationToken::new(), http, tls: Arc::new(tls), events,
        budget: Arc::new(Semaphore::new(EVENT_BYTES)), operations: Mutex::new(HashMap::new()), last_id: Mutex::new(0), fatal: Mutex::new(None) }), events: Mutex::new(rx), pending: Mutex::new(None) })
}

impl State {
    pub fn register(&self, id: u64, op: Operation) -> Result<(), i32> {
        if self.cancel.is_cancelled() { return Err(-2); }
        let mut operations = self.operations.lock();
        let mut last = self.last_id.lock();
        if id == 0 || id > 9_007_199_254_740_991 || id <= *last { return Err(-4); }
        if operations.len() >= MAX_OPERATIONS { return Err(-3); }
        let count = match &op {
            Operation::Http(_) => operations.values().filter(|x| matches!(x, Operation::Http(_))).count(),
            Operation::Socket { .. } => operations.values().filter(|x| matches!(x, Operation::Socket { .. })).count(),
            Operation::Callback(_) => operations.values().filter(|x| matches!(x, Operation::Callback(_))).count(),
        };
        let limit = match &op { Operation::Http(_) => MAX_HTTP, Operation::Socket { .. } => MAX_WS, Operation::Callback(_) => 2 };
        if count >= limit { return Err(-3); }
        *last = id;
        operations.insert(id, op);
        Ok(())
    }
    pub fn finish(&self, id: u64) { self.operations.lock().remove(&id); }
    pub async fn emit(&self, event: Value) -> bool {
        if self.cancel.is_cancelled() { return false; }
        let bytes = match serde_json::to_vec(&event) { Ok(bytes) => bytes, Err(_) => return false };
        if bytes.len() > EVENT_BYTES { self.fail(); return false; }
        let send = async {
            let permit = self.budget.clone().acquire_many_owned(bytes.len() as u32).await.map_err(|_| ())?;
            self.events.send(Event { bytes, _permit: permit }).await.map_err(|_| ())
        };
        tokio::select! {
            _ = self.cancel.cancelled() => false,
            result = tokio::time::timeout(Duration::from_secs(5), send) => {
                if matches!(result, Ok(Ok(()))) { true } else { self.fail(); false }
            }
        }
    }
    fn fail(&self) {
        *self.fatal.lock() = Some(br#"{"kind":"error","id":0,"code":"TRANSPORT_BACKPRESSURE","message":"Transport event queue exceeded its bounded delivery deadline; all connections were closed."}"#.to_vec());
        self.cancel.cancel();
    }
    pub async fn error(&self, id: u64, code: &str, message: &str) { self.emit(json!({"kind":"error","id":id,"code":code,"message":message})).await; }
}

#[derive(Deserialize)]
#[serde(tag = "op", rename_all = "snake_case", deny_unknown_fields)]
pub enum Command {
    Request { id: u64, url: String, #[serde(default = "get_method")] method: String, #[serde(default)] headers: HashMap<String, String>, #[serde(default, rename = "bodyBase64")] body: String, #[serde(default = "default_timeout", rename = "timeoutMs")] timeout: u64 },
    Connect { id: u64, url: String, #[serde(default)] headers: HashMap<String, String>, #[serde(default = "default_timeout", rename = "timeoutMs")] timeout: u64 },
    Send { id: u64, #[serde(rename = "dataBase64")] data: String, #[serde(default)] binary: bool },
    Ping { id: u64, #[serde(default, rename = "dataBase64")] data: String },
    Close { id: u64, #[serde(default = "normal_close")] code: u16, #[serde(default)] reason: String },
    Cancel { id: u64 },
}
fn get_method() -> String { "GET".to_string() }
fn default_timeout() -> u64 { 20_000 }
fn normal_close() -> u16 { 1000 }
fn payload(encoded: &str, limit: usize) -> Result<Vec<u8>, i32> {
    if encoded.len() > (limit + 2) / 3 * 4 { return Err(-3); }
    let bytes = STANDARD.decode(encoded).map_err(|_| -1)?;
    if bytes.len() > limit { return Err(-3); }
    Ok(bytes)
}
fn url(value: &str, scheme: &str) -> Result<reqwest::Url, i32> {
    if value.len() > 4096 { return Err(-1); }
    let parsed = reqwest::Url::parse(value).map_err(|_| -1)?;
    if parsed.scheme() != scheme || parsed.host_str().is_none() || !parsed.username().is_empty() || parsed.password().is_some() || parsed.fragment().is_some() { return Err(-1); }
    Ok(parsed)
}
fn headers(values: HashMap<String, String>) -> Result<reqwest::header::HeaderMap, i32> {
    if values.len() > 32 || values.iter().map(|(k,v)| k.len()+v.len()).sum::<usize>() > 16 * 1024 { return Err(-3); }
    let mut result = reqwest::header::HeaderMap::new();
    for (name, value) in values {
        let name = reqwest::header::HeaderName::from_bytes(name.as_bytes()).map_err(|_| -1)?;
        if matches!(name.as_str(), "cookie" | "host" | "content-length" | "connection" | "upgrade") || name.as_str().starts_with("sec-websocket-") { return Err(-1); }
        let value = reqwest::header::HeaderValue::from_str(&value).map_err(|_| -1)?;
        result.insert(name, value);
    }
    Ok(result)
}

pub fn command(state: Arc<State>, command: Command) -> Result<(), i32> {
    if state.cancel.is_cancelled() { return Err(-2); }
    match command {
        Command::Request { id, url: address, method, headers: values, body, timeout } => {
            let address = url(&address, "https")?;
            let method = reqwest::Method::from_bytes(method.as_bytes()).map_err(|_| -1)?;
            if !matches!(method.as_str(), "GET" | "POST" | "PUT" | "PATCH" | "DELETE" | "HEAD" | "OPTIONS") || !(100..=120_000).contains(&timeout) { return Err(-1); }
            let request = state.http.request(method, address).headers(headers(values)?).body(payload(&body, HTTP_LIMIT)?).timeout(Duration::from_millis(timeout)).build().map_err(|_| -1)?;
            let cancel = state.cancel.child_token();
            state.register(id, Operation::Http(cancel.clone()))?;
            runtime().spawn(async move {
                let work = async {
                    let response = state.http.execute(request).await.map_err(|e| if e.is_timeout() { "HTTP_TIMEOUT" } else { "HTTPS_FAILED" })?;
                    if response.content_length().is_some_and(|n| n > HTTP_LIMIT as u64) { return Err("HTTP_TOO_LARGE"); }
                    let status = response.status().as_u16();
                    let response_headers: HashMap<String, String> = response.headers().iter().filter_map(|(k,v)| v.to_str().ok().map(|v| (k.to_string(), v.to_string()))).collect();
                    let mut body = Vec::new();
                    let mut chunks = response.bytes_stream();
                    while let Some(chunk) = chunks.next().await {
                        let chunk = chunk.map_err(|error| if error.is_timeout() { "HTTP_TIMEOUT" } else { "HTTPS_FAILED" })?;
                        if body.len() + chunk.len() > HTTP_LIMIT { return Err("HTTP_TOO_LARGE"); }
                        body.extend_from_slice(&chunk);
                    }
                    Ok(json!({"kind":"http","id":id,"status":status,"headers":response_headers,"bodyBase64":STANDARD.encode(body)}))
                };
                tokio::select! {
                    _ = cancel.cancelled() => { state.error(id, "CANCELLED", "HTTP request was cancelled.").await; }
                    result = work => { match result { Ok(event) => { state.emit(event).await; }, Err(code) => state.error(id, code, "Verified HTTPS request failed or exceeded its bounds.").await } }
                }
                state.finish(id);
            });
        }
        Command::Connect { id, url: address, headers: values, timeout } => {
            url(&address, "wss")?;
            if !(100..=120_000).contains(&timeout) { return Err(-1); }
            let mut request = address.into_client_request().map_err(|_| -1)?;
            for (name, value) in headers(values)?.iter() { request.headers_mut().insert(name.clone(), value.clone()); }
            let (tx, rx) = mpsc::channel(128);
            let cancel = state.cancel.child_token();
            let budget = Arc::new(Semaphore::new(WS_LIMIT));
            state.register(id, Operation::Socket { cancel: cancel.clone(), tx, budget })?;
            runtime().spawn(socket(state, id, request, timeout, cancel, rx));
        }
        Command::Cancel { id } => {
            let operation = state.operations.lock().get(&id).cloned().ok_or(-5)?;
            match operation { Operation::Http(cancel) | Operation::Callback(cancel) | Operation::Socket { cancel, .. } => cancel.cancel() }
        }
        Command::Send { id, data, binary } => {
            let bytes = payload(&data, WS_LIMIT)?;
            let message = if binary { Message::Binary(bytes.into()) } else { Message::Text(String::from_utf8(bytes).map_err(|_| -1)?.into()) };
            queue_socket(&state, id, message)?;
        }
        Command::Ping { id, data } => { queue_socket(&state, id, Message::Ping(payload(&data, 125)?.into()))?; }
        Command::Close { id, code, reason } => {
            if reason.len() > 123 || !CloseCode::from(code).is_allowed() { return Err(-1); }
            queue_socket(&state, id, Message::Close(Some(CloseFrame { code: CloseCode::from(code), reason: reason.into() })))?;
        }
    }
    Ok(())
}
fn queue_socket(state: &State, id: u64, message: Message) -> Result<(), i32> {
    let operation = state.operations.lock().get(&id).cloned().ok_or(-5)?;
    let Operation::Socket { tx, budget, .. } = operation else { return Err(-5); };
    let permit = budget.try_acquire_many_owned(message.len().max(1) as u32).map_err(|_| -3)?;
    tx.try_send(SocketCommand { message, _permit: permit }).map_err(|e| match e { mpsc::error::TrySendError::Full(_) => -3, mpsc::error::TrySendError::Closed(_) => -5 })
}

async fn socket(state: Arc<State>, id: u64, request: tokio_tungstenite::tungstenite::handshake::client::Request, timeout: u64, cancel: CancellationToken, mut commands: mpsc::Receiver<SocketCommand>) {
    let config = WebSocketConfig::default().read_buffer_size(16 * 1024).write_buffer_size(0)
        .max_write_buffer_size(WS_LIMIT + 4096).max_message_size(Some(WS_LIMIT)).max_frame_size(Some(WS_LIMIT));
    let connection = tokio::select! {
        _ = cancel.cancelled() => { state.error(id, "CANCELLED", "WebSocket connection was cancelled.").await; state.finish(id); return; }
        result = tokio::time::timeout(Duration::from_millis(timeout), connect_async_tls_with_config(request, Some(config), true, Some(Connector::Rustls(state.tls.clone())))) => result,
    };
    let mut ws = match connection {
        Ok(Ok((ws, _))) => ws,
        _ => { state.error(id, "WSS_FAILED", "Verified TLS/WebSocket handshake failed or timed out.").await; state.finish(id); return; }
    };
    if !state.emit(json!({"kind":"ws_open","id":id})).await { state.finish(id); return; }
    let mut heartbeat = tokio::time::interval_at(tokio::time::Instant::now() + Duration::from_secs(20), Duration::from_secs(20));
    heartbeat.set_missed_tick_behavior(tokio::time::MissedTickBehavior::Delay);
    let mut last_pong = tokio::time::Instant::now();
    let mut close = None;
    let mut close_deadline = tokio::time::Instant::now() + Duration::from_secs(86_400);
    loop {
        let next = tokio::select! {
            _ = cancel.cancelled() => { close = Some((1000, "Cancelled".to_string())); break; }
            _ = tokio::time::sleep_until(close_deadline), if close.is_some() => { break; }
            _ = heartbeat.tick(), if close.is_none() => {
                if last_pong.elapsed() > Duration::from_secs(45) { close = Some((1001, "WebSocket ping timed out".to_string())); break; }
                if !matches!(tokio::time::timeout(Duration::from_secs(5), ws.send(Message::Ping(Vec::new().into()))).await, Ok(Ok(()))) { close = Some((1006, "WebSocket write failed".to_string())); break; }
                continue;
            }
            command = commands.recv(), if close.is_none() => {
                let Some(command) = command else { close = Some((1000, "Transport closed".to_string())); break; };
                if let Message::Close(Some(frame)) = &command.message {
                    close = Some((u16::from(frame.code), frame.reason.to_string()));
                    close_deadline = tokio::time::Instant::now() + Duration::from_secs(3);
                }
                if !matches!(tokio::time::timeout(Duration::from_secs(5), ws.send(command.message)).await, Ok(Ok(()))) { close = Some((1006, "WebSocket write failed".to_string())); break; }
                continue;
            }
            next = ws.next() => next,
        };
        match next {
            Some(Ok(Message::Text(data))) => { if !state.emit(json!({"kind":"ws_message","id":id,"dataBase64":STANDARD.encode(data.as_bytes()),"binary":false})).await { break; } }
            Some(Ok(Message::Binary(data))) => { if !state.emit(json!({"kind":"ws_message","id":id,"dataBase64":STANDARD.encode(data),"binary":true})).await { break; } }
            Some(Ok(Message::Pong(data))) => { last_pong = tokio::time::Instant::now(); if !state.emit(json!({"kind":"ws_pong","id":id,"dataBase64":STANDARD.encode(data)})).await { break; } }
            Some(Ok(Message::Ping(_))) => { if !matches!(tokio::time::timeout(Duration::from_secs(5), ws.flush()).await, Ok(Ok(()))) { close = Some((1006, "WebSocket pong failed".to_string())); break; } }
            Some(Ok(Message::Close(frame))) => {
                close = Some(frame.map(|f| (u16::from(f.code), f.reason.to_string())).unwrap_or((1000, String::new())));
                let _ = tokio::time::timeout(Duration::from_secs(1), ws.flush()).await;
                break;
            }
            Some(Ok(Message::Frame(_))) => {}
            Some(Err(error)) => {
                let code = if matches!(error, tokio_tungstenite::tungstenite::Error::Capacity(_)) { 1009 } else { 1006 };
                close = Some((code, "WebSocket read failed or message exceeded its limit".to_string())); break;
            }
            None => { if close.is_none() { close = Some((1006, "WebSocket reached EOF".to_string())); } break; }
        }
    }
    let (code, reason) = close.unwrap_or((1006, "Transport closed".to_string()));
    if code != 1006 { let _ = tokio::time::timeout(Duration::from_secs(1), ws.close(Some(CloseFrame { code: CloseCode::from(code), reason: reason.clone().into() }))).await; }
    state.emit(json!({"kind":"ws_close","id":id,"code":code,"reason":reason})).await;
    state.finish(id);
}
