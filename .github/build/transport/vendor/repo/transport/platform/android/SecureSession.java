package org.studio26.transport;

import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.security.keystore.KeyGenParameterSpec;
import android.security.keystore.KeyProperties;
import android.util.Base64;

import androidx.annotation.Keep;

import java.io.IOException;
import java.nio.ByteBuffer;
import java.nio.charset.CharacterCodingException;
import java.nio.charset.CodingErrorAction;
import java.nio.charset.StandardCharsets;
import java.security.GeneralSecurityException;
import java.security.Key;
import java.security.KeyStore;
import java.util.Arrays;

import javax.crypto.Cipher;
import javax.crypto.KeyGenerator;
import javax.crypto.SecretKey;
import javax.crypto.spec.GCMParameterSpec;

/** Application-scoped Android Keystore storage; no plaintext is written to disk. */
@Keep
public final class SecureSession {
    private static final String PREFERENCES = "studio26_transport_secrets";
    private static final String KEY_ALIAS = "studio26.transport.session.v1";
    private static final String PRODUCT_METADATA = "org.studio26.transport.product";
    private static final int MAX_SESSION_BYTES = 8192;
    private static final int MAX_CALLBACK_LENGTH = 8192;
    private static final int NONCE_BYTES = 12;
    private static final int TAG_BITS = 128;
    private static final byte VERSION = 1;
    private static final int MAX_ENVELOPE_BYTES = 1 + NONCE_BYTES + MAX_SESSION_BYTES + TAG_BITS / 8;
    private static final int MAX_ENCODED_LENGTH = ((MAX_ENVELOPE_BYTES + 2) / 3) * 4;

    private static Context applicationContext;
    private static SharedPreferences preferences;
    private static SecretKey secretKey;

    static {
        System.loadLibrary("techmino_transport");
    }

    private SecureSession() {}

    private static native void nativeInitialize(Context context);
    private static native void nativeCallback(String url);

    public static synchronized void initialize(Context context) {
        if (context == null || context.getApplicationContext() == null) {
            throw new IllegalStateException("Application context is unavailable");
        }
        Context application = context.getApplicationContext();
        if (applicationContext != null) {
            if (!applicationContext.getPackageName().equals(application.getPackageName())) {
                throw new IllegalStateException("Secure session application changed");
            }
            return;
        }
        registeredProduct(application);
        SharedPreferences encrypted = application.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE);
        nativeInitialize(application);
        applicationContext = application;
        preferences = encrypted;
    }

    private static String registeredProduct(Context context) {
        try {
            ApplicationInfo info = context.getPackageManager().getApplicationInfo(
                    context.getPackageName(), PackageManager.GET_META_DATA);
            String product = info.metaData == null ? null : info.metaData.getString(PRODUCT_METADATA);
            if (!"techmino".equals(product) && !"techminoGalaxy".equals(product)) {
                throw new IllegalStateException("Secure session product is not registered");
            }
            return product;
        } catch (PackageManager.NameNotFoundException e) {
            throw new IllegalStateException("Secure session application is unavailable");
        }
    }

    private static void requireProduct(String product) {
        if (applicationContext == null || preferences == null) {
            throw new IllegalStateException("Secure session is not initialized");
        }
        if (!registeredProduct(applicationContext).equals(product)) {
            throw new IllegalArgumentException("Secure session product does not match this application");
        }
    }

    private static SecretKey key() throws GeneralSecurityException, IOException {
        if (secretKey != null) {
            return secretKey;
        }
        KeyStore store = KeyStore.getInstance("AndroidKeyStore");
        store.load(null);
        if (store.containsAlias(KEY_ALIAS)) {
            Key existing = store.getKey(KEY_ALIAS, null);
            if (!(existing instanceof SecretKey) || !KeyProperties.KEY_ALGORITHM_AES.equals(existing.getAlgorithm())) {
                throw new GeneralSecurityException("Secure session key is invalid");
            }
            secretKey = (SecretKey) existing;
        } else {
            // Restored ciphertext without its non-exportable key must never become an empty session.
            if (!preferences.getAll().isEmpty()) {
                throw new GeneralSecurityException("Secure session key is missing");
            }
            KeyGenerator generator = KeyGenerator.getInstance(KeyProperties.KEY_ALGORITHM_AES, "AndroidKeyStore");
            generator.init(new KeyGenParameterSpec.Builder(KEY_ALIAS,
                    KeyProperties.PURPOSE_ENCRYPT | KeyProperties.PURPOSE_DECRYPT)
                    .setKeySize(256)
                    .setBlockModes(KeyProperties.BLOCK_MODE_GCM)
                    .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
                    .setRandomizedEncryptionRequired(true)
                    .setUserAuthenticationRequired(false)
                    .build());
            secretKey = generator.generateKey();
        }
        return secretKey;
    }

    private static byte[] associatedData(String product) {
        return ("studio26.transport.session.v1:" + applicationContext.getPackageName() + ":" + product)
                .getBytes(StandardCharsets.UTF_8);
    }

    public static synchronized String get(String product) throws GeneralSecurityException, IOException {
        requireProduct(product);
        // An empty preference must not conceal an unavailable Keystore provider.
        SecretKey encryptionKey = key();
        String encoded = preferences.getString(product, null);
        if (encoded == null) {
            return null;
        }
        if (encoded.length() > MAX_ENCODED_LENGTH) {
            throw new GeneralSecurityException("Secure session payload exceeds its limit");
        }
        byte[] envelope;
        try {
            envelope = Base64.decode(encoded, Base64.NO_WRAP);
        } catch (IllegalArgumentException e) {
            throw new GeneralSecurityException("Secure session payload is malformed");
        }
        if (envelope.length < 1 + NONCE_BYTES + TAG_BITS / 8
                || envelope.length > MAX_ENVELOPE_BYTES || envelope[0] != VERSION) {
            throw new GeneralSecurityException("Secure session payload is malformed");
        }
        byte[] nonce = Arrays.copyOfRange(envelope, 1, 1 + NONCE_BYTES);
        Cipher cipher = Cipher.getInstance("AES/GCM/NoPadding");
        cipher.init(Cipher.DECRYPT_MODE, encryptionKey, new GCMParameterSpec(TAG_BITS, nonce));
        cipher.updateAAD(associatedData(product));
        // Authentication/tag, invalidated-key and provider failures propagate to Rust, never null.
        byte[] plaintext = cipher.doFinal(envelope, 1 + NONCE_BYTES, envelope.length - 1 - NONCE_BYTES);
        try {
            if (plaintext.length > MAX_SESSION_BYTES) {
                throw new GeneralSecurityException("Secure session payload exceeds its limit");
            }
            return StandardCharsets.UTF_8.newDecoder()
                    .onMalformedInput(CodingErrorAction.REPORT)
                    .onUnmappableCharacter(CodingErrorAction.REPORT)
                    .decode(ByteBuffer.wrap(plaintext)).toString();
        } catch (CharacterCodingException e) {
            throw new GeneralSecurityException("Secure session plaintext is malformed");
        } finally {
            Arrays.fill(plaintext, (byte) 0);
        }
    }

    public static synchronized void set(String product, String value) throws GeneralSecurityException, IOException {
        requireProduct(product);
        if (value == null || value.length() > MAX_SESSION_BYTES) {
            throw new IllegalArgumentException("Secure session value exceeds its limit");
        }
        byte[] plaintext = value.getBytes(StandardCharsets.UTF_8);
        try {
            if (plaintext.length > MAX_SESSION_BYTES) {
                throw new IllegalArgumentException("Secure session value exceeds its limit");
            }
            Cipher cipher = Cipher.getInstance("AES/GCM/NoPadding");
            // Android Keystore chooses a new random nonce; caller-provided encryption nonces are forbidden.
            cipher.init(Cipher.ENCRYPT_MODE, key());
            cipher.updateAAD(associatedData(product));
            byte[] nonce = cipher.getIV();
            if (nonce == null || nonce.length != NONCE_BYTES) {
                throw new GeneralSecurityException("Secure session nonce is invalid");
            }
            byte[] ciphertext = cipher.doFinal(plaintext);
            byte[] envelope = new byte[1 + NONCE_BYTES + ciphertext.length];
            envelope[0] = VERSION;
            System.arraycopy(nonce, 0, envelope, 1, NONCE_BYTES);
            System.arraycopy(ciphertext, 0, envelope, 1 + NONCE_BYTES, ciphertext.length);
            String encoded = Base64.encodeToString(envelope, Base64.NO_WRAP);
            if (!preferences.edit().putString(product, encoded).commit()) {
                throw new IOException("Secure session write was not committed");
            }
        } finally {
            Arrays.fill(plaintext, (byte) 0);
        }
    }

    public static synchronized void delete(String product) throws IOException {
        requireProduct(product);
        // Logout can remove an undecryptable payload without needing the lost/invalidated key.
        if (!preferences.edit().remove(product).commit()) {
            throw new IOException("Secure session deletion was not committed");
        }
    }

    public static synchronized boolean onIntent(Intent intent) {
        if (applicationContext == null) {
            throw new IllegalStateException("Secure session is not initialized");
        }
        if (intent == null || !Intent.ACTION_VIEW.equals(intent.getAction())) {
            return false;
        }
        Uri uri = intent.getData();
        if (uri == null) {
            return false;
        }
        String address = uri.toString();
        String product = registeredProduct(applicationContext);
        String callback = "techmino".equals(product)
                ? "org.studio26f.techmino:/callback" : "org.studio26f.techmino-galaxy:/callback";
        if (address.length() > MAX_CALLBACK_LENGTH || address.indexOf('#') >= 0
                || !(address.equals(callback) || address.startsWith(callback + "?"))) {
            return false;
        }
        // Consume before returning to upstream intent/file handling, including embed builds.
        intent.setData(null);
        nativeCallback(address);
        return true;
    }
}
