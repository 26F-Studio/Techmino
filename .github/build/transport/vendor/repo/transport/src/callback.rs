use crate::client::{runtime, Operation, State};
use parking_lot::Mutex;
use serde::Deserialize;
use serde_json::{json, Value};
use std::{collections::HashMap, sync::{Arc, LazyLock, Weak}, time::Duration};
use tokio::io::{AsyncReadExt, AsyncWriteExt};
use tokio::sync::oneshot;
use tokio_util::sync::CancellationToken;

#[derive(Deserialize)]
#[serde(rename_all = "camelCase", deny_unknown_fields)]
pub struct Begin { pub id: u64, pub product: String, pub state: String, pub issuer: String, #[serde(default = "expiry")] pub timeout_seconds: u64 }
fn expiry() -> u64 { 180 }
struct Pending { id: u64, redirect: String, state: String, issuer: String, sender: Mutex<Option<oneshot::Sender<Value>>> }
static MOBILE: LazyLock<Mutex<Vec<Weak<Pending>>>> = LazyLock::new(|| Mutex::new(Vec::new()));

fn issuer_valid(value: &str) -> bool {
    if value.len() > 4096 { return false; }
    let Ok(url) = reqwest::Url::parse(value) else { return false; };
    let loopback = matches!(url.host_str(), Some("localhost" | "127.0.0.1" | "[::1]" | "::1"));
    (url.scheme() == "https" || (url.scheme() == "http" && loopback)) && url.host_str().is_some()
        && url.username().is_empty() && url.password().is_none() && url.fragment().is_none() && url.query().is_none()
}

pub fn begin(owner: Arc<State>, request: Begin) -> Result<Value, &'static str> {
    if !matches!(request.product.as_str(), "techmino" | "techminoGalaxy") || request.state.len() < 32 || request.state.len() > 128
        || !request.state.bytes().all(|b| b.is_ascii_alphanumeric() || b"-._~".contains(&b)) || !issuer_valid(&request.issuer)
        || !(1..=180).contains(&request.timeout_seconds) { return Err("INVALID_CALLBACK"); }
    let cancel = owner.cancel.child_token();
    #[cfg(any(target_os = "android", target_os = "ios"))]
    let redirect = if request.product == "techmino" { "org.studio26f.techmino:/callback" } else { "org.studio26f.techmino-galaxy:/callback" }.to_string();
    #[cfg(not(any(target_os = "android", target_os = "ios")))]
    let listener = std::net::TcpListener::bind((std::net::Ipv4Addr::LOCALHOST, 0)).map_err(|_| "CALLBACK_BIND_FAILED")?;
    #[cfg(not(any(target_os = "android", target_os = "ios")))]
    let redirect = format!("http://127.0.0.1:{}/callback", listener.local_addr().map_err(|_| "CALLBACK_BIND_FAILED")?.port());
    #[cfg(not(any(target_os = "android", target_os = "ios")))]
    listener.set_nonblocking(true).map_err(|_| "CALLBACK_BIND_FAILED")?;
    owner.register(request.id, Operation::Callback(cancel.clone())).map_err(|_| "CALLBACK_RESOURCE_LIMIT")?;
    let (tx, rx) = oneshot::channel();
    let pending = Arc::new(Pending { id: request.id, redirect: redirect.clone(), state: request.state, issuer: request.issuer, sender: Mutex::new(Some(tx)) });
    #[cfg(any(target_os = "android", target_os = "ios"))]
    {
        let mut callbacks = MOBILE.lock();
        callbacks.retain(|entry| entry.strong_count() != 0);
        callbacks.push(Arc::downgrade(&pending));
    }
    runtime().spawn(async move {
        #[cfg(not(any(target_os = "android", target_os = "ios")))]
        let work = loopback(listener, pending.clone(), cancel.clone());
        #[cfg(any(target_os = "android", target_os = "ios"))]
        let work = async { rx.await.map_err(|_| "CALLBACK_CANCELLED") };
        #[cfg(not(any(target_os = "android", target_os = "ios")))]
        drop(rx);
        tokio::select! {
            _ = cancel.cancelled() => { owner.error(pending.id, "CALLBACK_CANCELLED", "Authorization callback was cancelled.").await; }
            result = tokio::time::timeout(Duration::from_secs(request.timeout_seconds), work) => {
                match result {
                    Ok(Ok(event)) => { owner.emit(event).await; }
                    Ok(Err(code)) => { owner.error(pending.id, code, "Authorization callback could not be received.").await; }
                    Err(_) => { owner.error(pending.id, "CALLBACK_EXPIRED", "Authorization callback expired.").await; }
                }
            }
        }
        owner.finish(pending.id);
    });
    Ok(json!({"id":request.id,"redirectUri":redirect}))
}

fn validate(pending: &Pending, address: &str) -> Option<Value> {
    if address.len() > 8192 { return None; }
    let mut url = reqwest::Url::parse(address).ok()?;
    if url.fragment().is_some() { return None; }
    let mut values = HashMap::new();
    for (key, value) in url.query_pairs() {
        if !matches!(key.as_ref(), "code" | "error" | "state" | "issuer") || value.len() > 4096 || values.insert(key.into_owned(), value.into_owned()).is_some() { return None; }
    }
    url.set_query(None);
    if url.as_str() != pending.redirect || values.get("state")? != &pending.state || values.get("issuer")? != &pending.issuer { return None; }
    let code = values.get("code");
    let error = values.get("error");
    if code.is_some() == error.is_some() || code.or(error)?.is_empty() || code.or(error)?.len() > 2048 { return None; }
    let mut event = json!({"kind":"callback","id":pending.id,"state":pending.state,"issuer":pending.issuer});
    if let Some(code) = code { event["code"] = json!(code); }
    if let Some(error) = error { event["error"] = json!(error); }
    Some(event)
}

pub fn mobile_callback(address: &str) {
    let callbacks: Vec<_> = {
        let mut entries = MOBILE.lock();
        entries.retain(|entry| entry.strong_count() != 0);
        entries.iter().filter_map(Weak::upgrade).collect()
    };
    for pending in callbacks {
        if let Some(event) = validate(&pending, address) {
            if let Some(sender) = pending.sender.lock().take() { let _ = sender.send(event); }
            break;
        }
    }
}

#[cfg(not(any(target_os = "android", target_os = "ios")))]
async fn loopback(listener: std::net::TcpListener, pending: Arc<Pending>, cancel: CancellationToken) -> Result<Value, &'static str> {
    let listener = tokio::net::TcpListener::from_std(listener).map_err(|_| "CALLBACK_BIND_FAILED")?;
    loop {
        let (mut connection, address) = tokio::select! {
            _ = cancel.cancelled() => return Err("CALLBACK_CANCELLED"),
            connection = listener.accept() => connection.map_err(|_| "CALLBACK_IO_FAILED")?,
        };
        if !address.ip().is_loopback() { continue; }
        let read = async {
            let mut bytes = Vec::with_capacity(1024);
            let mut chunk = [0u8; 512];
            while !bytes.windows(4).any(|w| w == b"\r\n\r\n") {
                let count = connection.read(&mut chunk).await.ok()?;
                if count == 0 || bytes.len() + count > 8192 { return None; }
                bytes.extend_from_slice(&chunk[..count]);
            }
            let request = std::str::from_utf8(&bytes).ok()?;
            let mut lines = request.split("\r\n");
            let mut first = lines.next()?.split(' ');
            if first.next()? != "GET" { return None; }
            let target = first.next()?;
            if !target.starts_with("/callback?") || first.next()? != "HTTP/1.1" || first.next().is_some() { return None; }
            let expected = reqwest::Url::parse(&pending.redirect).ok()?;
            let authority = format!("127.0.0.1:{}", expected.port()?);
            let hosts: Vec<_> = lines.filter_map(|line| line.split_once(':')).filter(|(k,_)| k.eq_ignore_ascii_case("host")).collect();
            if hosts.len() != 1 || hosts[0].1.trim() != authority { return None; }
            validate(&pending, &format!("http://{authority}{target}"))
        };
        let event = tokio::time::timeout(Duration::from_secs(2), read).await.ok().flatten();
        let (status, body) = if event.is_some() { ("200 OK", "Authorization received. You can return to the game.") } else { ("400 Bad Request", "Invalid authorization callback.") };
        let response = format!("HTTP/1.1 {status}\r\nContent-Type: text/plain; charset=utf-8\r\nContent-Length: {}\r\nCache-Control: no-store\r\nReferrer-Policy: no-referrer\r\nContent-Security-Policy: default-src 'none'; frame-ancestors 'none'\r\nConnection: close\r\n\r\n{body}", body.len());
        let _ = tokio::time::timeout(Duration::from_secs(1), connection.write_all(response.as_bytes())).await;
        if let Some(event) = event { return Ok(event); }
    }
}
