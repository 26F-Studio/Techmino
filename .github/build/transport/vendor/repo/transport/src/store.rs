use serde::Deserialize;
use serde_json::{json, Value};
use zeroize::{Zeroize, Zeroizing};

#[derive(Deserialize)]
#[serde(deny_unknown_fields)]
pub struct Request { pub op: String, pub product: String, #[serde(default)] pub value: Option<String> }
const SERVICE: &str = "org.studio26f.product-session";

pub fn execute(mut request: Request) -> Value {
    if !matches!(request.product.as_str(), "techmino" | "techminoGalaxy") || !matches!(request.op.as_str(), "get" | "set" | "delete") {
        return json!({"ok":false,"mode":"unavailable","code":"INVALID_STORE_REQUEST","message":"Invalid product session storage request."});
    }
    if request.op == "set" && request.value.as_ref().is_none_or(|v| v.is_empty() || v.len() > 8192 || v.bytes().any(|b| b < 0x21 || b > 0x7e)) {
        return json!({"ok":false,"mode":"unavailable","code":"INVALID_CREDENTIAL","message":"Credential is empty or exceeds its storage bound."});
    }
    let value = request.value.take().map(Zeroizing::new);
    let result = platform(&request.op, &request.product, value.as_ref().map(|v| v.as_str()));
    match result {
        Ok(value) => json!({"ok":true,"mode":"secure","value":value}),
        Err(()) => {
            let mode = if cfg!(target_os = "linux") { "memory_only" } else { "unavailable" };
            let message = if cfg!(target_os = "linux") { "An unlocked Secret Service is unavailable. Login credentials will remain in memory only and will not survive exit." } else { "The operating system protected credential store is unavailable; no credential was persisted." };
            json!({"ok":false,"mode":mode,"code":"SECURE_STORE_UNAVAILABLE","message":message})
        }
    }
}

#[cfg(target_os = "linux")]
fn platform(op: &str, product: &str, value: Option<&str>) -> Result<Option<String>, ()> {
    use dbus_secret_service::{EncryptionType, SecretService};
    use std::collections::HashMap;
    let service = SecretService::connect(EncryptionType::Dh).map_err(|_| ())?;
    let collection = service.get_default_collection().map_err(|_| ())?;
    if collection.is_locked().map_err(|_| ())? { return Err(()); }
    let attributes = HashMap::from([("service", SERVICE), ("product", product)]);
    let items = collection.search_items(attributes.clone()).map_err(|_| ())?;
    if items.len() > 1 || items.iter().any(|item| item.is_locked().unwrap_or(true)) { return Err(()); }
    match op {
        "get" => {
            let Some(item) = items.first() else { return Ok(None); };
            let mut secret = item.get_secret().map_err(|_| ())?;
            if secret.len() > 8192 { secret.zeroize(); return Err(()); }
            match String::from_utf8(secret) {
                Ok(secret) => Ok(Some(secret)),
                Err(error) => { error.into_bytes().zeroize(); Err(()) }
            }
        }
        "set" => {
            let value = value.ok_or(())?;
            if let Some(item) = items.first() { item.set_secret(value.as_bytes(), "text/plain").map_err(|_| ())?; }
            else { collection.create_item(&format!("Studio26F {product} product session"), attributes, value.as_bytes(), true, "text/plain").map_err(|_| ())?; }
            Ok(None)
        }
        "delete" => { if let Some(item) = items.first() { item.delete().map_err(|_| ())?; } Ok(None) }
        _ => Err(()),
    }
}

#[cfg(any(target_os = "windows", target_os = "macos", target_os = "ios"))]
fn platform(op: &str, product: &str, value: Option<&str>) -> Result<Option<String>, ()> {
    let entry = keyring::Entry::new(SERVICE, product).map_err(|_| ())?;
    match op {
        "get" => match entry.get_password() {
            Ok(value) if value.len() <= 8192 => Ok(Some(value)),
            Err(keyring::Error::NoEntry) => Ok(None),
            _ => Err(()),
        },
        "set" => { entry.set_password(value.ok_or(())?).map_err(|_| ())?; Ok(None) }
        "delete" => match entry.delete_credential() { Ok(()) | Err(keyring::Error::NoEntry) => Ok(None), _ => Err(()) },
        _ => Err(()),
    }
}

#[cfg(target_os = "android")]
fn platform(op: &str, product: &str, value: Option<&str>) -> Result<Option<String>, ()> {
    match op {
        "get" => crate::store_android::get(product).map_err(|_| ()),
        "set" => { crate::store_android::set(product, value.ok_or(())?).map_err(|_| ())?; Ok(None) }
        "delete" => { crate::store_android::delete(product).map_err(|_| ())?; Ok(None) }
        _ => Err(()),
    }
}

#[cfg(not(any(target_os = "linux", target_os = "windows", target_os = "macos", target_os = "ios", target_os = "android")))]
fn platform(_: &str, _: &str, _: Option<&str>) -> Result<Option<String>, ()> { Err(()) }
