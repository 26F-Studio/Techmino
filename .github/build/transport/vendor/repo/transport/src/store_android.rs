use jni::{
    errors::Result as JniResult,
    objects::{GlobalRef, JClass, JObject, JString, JValue},
    JNIEnv, JavaVM,
};
use std::{
    panic::{catch_unwind, AssertUnwindSafe},
    sync::OnceLock,
};

struct AndroidRuntime {
    vm: JavaVM,
    class: GlobalRef,
}

// A Java-owned initialization point preserves the application's class loader on Rust threads.
static ANDROID: OnceLock<AndroidRuntime> = OnceLock::new();
const MAX_SESSION_BYTES: usize = 8192;
const MAX_CALLBACK_BYTES: usize = 8192;

fn product_valid(product: &str) -> bool {
    matches!(product, "techmino" | "techminoGalaxy")
}

fn with_environment<T>(
    operation: &'static str,
    action: impl FnOnce(&mut JNIEnv<'_>, &GlobalRef) -> JniResult<T>,
) -> Result<T, String> {
    let runtime = ANDROID.get().ok_or_else(|| "Android secure session is not initialized".to_string())?;
    let mut env = runtime.vm.attach_current_thread()
        .map_err(|_| "Android secure session thread attachment failed".to_string())?;
    let result = env.with_local_frame(16, |env| action(env, &runtime.class));
    match result {
        Ok(value) => Ok(value),
        Err(_) => {
            // Never stringify Java/provider exceptions: their messages may contain caller input.
            env.exception_clear()
                .map_err(|_| "Android secure session exception handling failed".to_string())?;
            Err(format!("Android secure session {operation} failed"))
        }
    }
}

pub fn get(product: &str) -> Result<Option<String>, String> {
    if !product_valid(product) {
        return Err("Invalid secure session product".to_string());
    }
    let result = with_environment("read", |env, class| {
        let product = env.new_string(product)?;
        let value = env.call_static_method(
            class,
            "get",
            "(Ljava/lang/String;)Ljava/lang/String;",
            &[JValue::Object(product.as_ref())],
        )?.l()?;
        if value.is_null() {
            return Ok(None);
        }
        let string = JString::from(value);
        let value: String = env.get_string(&string)?.into();
        Ok(Some(value))
    })?;
    if result.as_ref().is_some_and(|value| value.len() > MAX_SESSION_BYTES) {
        return Err("Android secure session exceeds its limit".to_string());
    }
    Ok(result)
}

pub fn set(product: &str, value: &str) -> Result<(), String> {
    if !product_valid(product) || value.len() > MAX_SESSION_BYTES {
        return Err("Invalid secure session value".to_string());
    }
    with_environment("write", |env, class| {
        let product = env.new_string(product)?;
        let value = env.new_string(value)?;
        env.call_static_method(
            class,
            "set",
            "(Ljava/lang/String;Ljava/lang/String;)V",
            &[JValue::Object(product.as_ref()), JValue::Object(value.as_ref())],
        )?.v()
    })
}

pub fn delete(product: &str) -> Result<(), String> {
    if !product_valid(product) {
        return Err("Invalid secure session product".to_string());
    }
    with_environment("deletion", |env, class| {
        let product = env.new_string(product)?;
        env.call_static_method(
            class,
            "delete",
            "(Ljava/lang/String;)V",
            &[JValue::Object(product.as_ref())],
        )?.v()
    })
}

fn initialize(env: &mut JNIEnv<'_>, class: &JClass<'_>, context: &JObject<'_>) -> JniResult<()> {
    if context.is_null() || !env.is_instance_of(context, "android/app/Application")? {
        return Err(jni::errors::Error::NullPtr("application context"));
    }
    if let Some(runtime) = ANDROID.get() {
        if env.is_same_object(&runtime.class, class)? {
            return Ok(());
        }
        return Err(jni::errors::Error::NullPtr("secure session class changed"));
    }
    let runtime = AndroidRuntime {
        vm: env.get_java_vm()?,
        class: env.new_global_ref(class)?,
    };
    if let Err(runtime) = ANDROID.set(runtime) {
        let existing = ANDROID.get().ok_or(jni::errors::Error::NullPtr("secure session runtime"))?;
        if !env.is_same_object(&existing.class, &runtime.class)? {
            return Err(jni::errors::Error::NullPtr("secure session class changed"));
        }
    }
    Ok(())
}

fn throw_bridge_failure(env: &mut JNIEnv<'_>, message: &'static str) {
    // An existing Java exception (including allocation failure) must propagate unchanged.
    if matches!(env.exception_check(), Ok(false)) {
        let _ = env.throw_new("java/lang/IllegalStateException", message);
    }
}

#[no_mangle]
pub extern "system" fn Java_org_studio26_transport_SecureSession_nativeInitialize(
    mut env: JNIEnv<'_>,
    class: JClass<'_>,
    context: JObject<'_>,
) {
    match catch_unwind(AssertUnwindSafe(|| initialize(&mut env, &class, &context))) {
        Ok(Ok(())) => {}
        _ => throw_bridge_failure(&mut env, "Android secure session initialization failed"),
    }
}

#[no_mangle]
pub extern "system" fn Java_org_studio26_transport_SecureSession_nativeCallback(
    mut env: JNIEnv<'_>,
    class: JClass<'_>,
    url: JString<'_>,
) {
    let result = catch_unwind(AssertUnwindSafe(|| -> JniResult<()> {
        let runtime = ANDROID.get().ok_or(jni::errors::Error::NullPtr("secure session runtime"))?;
        if url.is_null() || !env.is_same_object(&runtime.class, &class)? {
            return Err(jni::errors::Error::NullPtr("secure session callback"));
        }
        let address: String = env.get_string(&url)?.into();
        let recognized = ["org.studio26f.techmino:/callback", "org.studio26f.techmino-galaxy:/callback"]
            .iter().any(|callback| address == *callback
                || address.strip_prefix(*callback).is_some_and(|suffix| suffix.starts_with('?')));
        if !recognized || address.len() > MAX_CALLBACK_BYTES || address.contains('#') {
            return Err(jni::errors::Error::NullPtr("unregistered callback"));
        }
        crate::callback::mobile_callback(&address);
        Ok(())
    }));
    match result {
        Ok(Ok(())) => {}
        _ => throw_bridge_failure(&mut env, "Android authorization callback failed"),
    }
}
