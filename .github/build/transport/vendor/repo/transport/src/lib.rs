mod client;
pub mod callback;
mod store;
#[cfg(target_os = "android")]
mod store_android;

use base64::{engine::general_purpose::URL_SAFE_NO_PAD, Engine};
use client::{Client, Command, Options};
use sha2::{Digest, Sha256};
use std::{ptr, slice};

const MAX_COMMAND: usize = 3 * 1024 * 1024;
const INVALID_BUFFER: i32 = i32::MIN;
unsafe fn input<'a>(bytes: *const u8, len: usize, maximum: usize) -> Option<&'a [u8]> {
    if len > maximum || bytes.is_null() { None } else { Some(slice::from_raw_parts(bytes, len)) }
}
unsafe fn output(bytes: &[u8], out: *mut u8, capacity: usize) -> i32 {
    if bytes.len() > i32::MAX as usize { return INVALID_BUFFER; }
    if capacity < bytes.len() { return -(bytes.len() as i32); }
    if out.is_null() { return INVALID_BUFFER; }
    ptr::copy_nonoverlapping(bytes.as_ptr(), out, bytes.len());
    bytes.len() as i32
}

#[no_mangle]
pub unsafe extern "C" fn tn_client_new(json: *const u8, len: usize) -> *mut Client {
    let Some(bytes) = input(json, len, 128 * 1024) else { return ptr::null_mut(); };
    let Ok(options) = serde_json::from_slice::<Options>(bytes) else { return ptr::null_mut(); };
    match client::new(options) { Ok(client) => Box::into_raw(Box::new(client)), Err(_) => ptr::null_mut() }
}

#[no_mangle]
pub unsafe extern "C" fn tn_client_destroy(client: *mut Client) {
    if !client.is_null() {
        let client = Box::from_raw(client);
        client.state.cancel.cancel();
        client.state.operations.lock().clear();
    }
}

#[no_mangle]
pub unsafe extern "C" fn tn_command(client: *mut Client, json: *const u8, len: usize) -> i32 {
    let Some(client) = client.as_ref() else { return -2; };
    let Some(bytes) = input(json, len, MAX_COMMAND) else { return -1; };
    let Ok(command) = serde_json::from_slice::<Command>(bytes) else { return -1; };
    client::command(client.state.clone(), command).map(|_| 0).unwrap_or_else(|code| code)
}

#[no_mangle]
pub unsafe extern "C" fn tn_poll(client: *mut Client, out: *mut u8, capacity: usize) -> i32 {
    let Some(client) = client.as_ref() else { return INVALID_BUFFER; };
    let mut pending = client.pending.lock();
    if pending.is_none() { *pending = client.events.lock().try_recv().ok(); }
    if let Some(event) = pending.as_ref() {
        let result = output(&event.bytes, out, capacity);
        if result >= 0 { pending.take(); }
        return result;
    }
    let mut fatal = client.state.fatal.lock();
    if let Some(bytes) = fatal.as_ref() {
        let result = output(bytes, out, capacity);
        if result >= 0 { fatal.take(); }
        return result;
    }
    0
}

#[no_mangle]
pub unsafe extern "C" fn tn_callback_begin(client: *mut Client, json: *const u8, len: usize, out: *mut u8, capacity: usize) -> i32 {
    if capacity < 16384 { return -16384; }
    if out.is_null() { return INVALID_BUFFER; }
    let Some(client) = client.as_ref() else { return INVALID_BUFFER; };
    let Some(bytes) = input(json, len, 8192) else { return INVALID_BUFFER; };
    let result = match serde_json::from_slice::<callback::Begin>(bytes) {
        Ok(request) => match callback::begin(client.state.clone(), request) {
            Ok(value) => value,
            Err(code) => serde_json::json!({"error":{"code":code,"message":"Authorization callback could not be started."}}),
        },
        Err(_) => serde_json::json!({"error":{"code":"INVALID_CALLBACK","message":"Authorization callback parameters are invalid."}}),
    };
    let Ok(bytes) = serde_json::to_vec(&result) else { return INVALID_BUFFER; };
    output(&bytes, out, capacity)
}

#[no_mangle]
pub unsafe extern "C" fn tn_secret(json: *const u8, len: usize, out: *mut u8, capacity: usize) -> i32 {
    if capacity < 16384 { return -16384; }
    if out.is_null() { return INVALID_BUFFER; }
    let Some(bytes) = input(json, len, 16 * 1024) else { return INVALID_BUFFER; };
    let result = match serde_json::from_slice::<store::Request>(bytes) {
        Ok(request) => store::execute(request),
        Err(_) => serde_json::json!({"ok":false,"mode":"unavailable","code":"INVALID_STORE_REQUEST","message":"Credential storage request is invalid."}),
    };
    let Ok(bytes) = serde_json::to_vec(&result) else { return INVALID_BUFFER; };
    output(&bytes, out, capacity)
}

#[no_mangle]
pub unsafe extern "C" fn tn_random(out: *mut u8, count: usize) -> i32 {
    if out.is_null() || count == 0 || count > 4096 { return -1; }
    match getrandom::getrandom(slice::from_raw_parts_mut(out, count)) { Ok(()) => 0, Err(_) => -2 }
}

#[no_mangle]
pub unsafe extern "C" fn tn_pkce(verifier: *const u8, len: usize, out: *mut u8, capacity: usize) -> i32 {
    let Some(verifier) = input(verifier, len, 128) else { return INVALID_BUFFER; };
    if len < 43 || !verifier.iter().all(|b| b.is_ascii_alphanumeric() || b"-._~".contains(b)) { return INVALID_BUFFER; }
    let challenge = URL_SAFE_NO_PAD.encode(Sha256::digest(verifier));
    output(challenge.as_bytes(), out, capacity)
}

#[no_mangle]
pub unsafe extern "C" fn tn_mobile_callback(url: *const u8, len: usize) {
    if let Some(bytes) = input(url, len, 8192) {
        if let Ok(url) = std::str::from_utf8(bytes) { callback::mobile_callback(url); }
    }
}
