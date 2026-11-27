# Product client transport

`techmino-transport` is an independent Rust crate. It does not build Cadence's gameplay engine or require the authority source bundle. Its dynamic/static library is named `techmino_transport`; its frozen C interface is in `include/techmino_transport.h`.

This is a first-party product-session transport, **not OAuth/OIDC**. No native client secret or resource-server validation secret is embedded. Product IDs are exactly `techmino` and `techminoGalaxy`.

## Verification status

The integration owner ran `tests/ffi_smoke.py` against both the Linux debug library and a fresh locked Linux release library built with Rust 1.96.0, using actual local TLS servers. The exercised scenarios passed:

- Verified HTTPS, exact binary response bytes, and independently correlated concurrent HTTP requests.
- HTTPS and WSS rejection of an untrusted CA and a wrong certificate hostname.
- HTTP status/redirect preservation and response-size rejection.
- Cancellation that releases the in-flight HTTPS connection.
- Complete fragmented WSS text/binary messages, outbound binary integrity, ping/pong, and socket cancellation.
- Aggregate fragmented-message size rejection and a manual WebSocket close handshake.
- A temporary loopback receiver that rejects a wrong state and delivers the correctly bound state/issuer callback.

Actual current-source Linux execution also passed with `Techmino.love` and its adjacent release library, without `TECHMINO_TRANSPORT_LIBRARY`: original system-browser consent, trusted WSS admission, two native participants and real game inputs. The rebuilt original Web client joined that match only after it was playing, received its first authoritative snapshot at frame 1336, and rendered both source boards with server/rendered frame 2508. The rebuilt Galaxy Web client completed its separate `techminoGalaxy` consent and trusted identity flow.

Local package evidence includes the actual fused Techmino AppImage's original
browser consent, callback exchange, WSS `ready`, room directory and device logout.
Its session visibly remained memory-only with locked/unavailable Secret Service.
The matching corrected Debian package was installed into an owned network-disabled
Debian bookworm/Mesa clone; its installed desktop entry rendered the original GUI.
Original offline Sprint 10L inputs produced 17 keys and 13 pieces. Original Save (O)
and the disk-loaded replay reproduced those counts at replay frame 511, including
after restarting the installed launcher. The original main-menu exit gestures
then ended that launcher with exit 0; the earlier forced window-close exit 1 is
retained separately. Dedicated Xvfb cookie access control stayed enabled, and
Mesa dependencies were installed only in the disposable image.

These results do **not** establish Debian online or physical GPU/audio behavior,
a distributed release, Windows/Apple/Android runtime behavior, Galaxy gameplay/audio,
or all-platform OS credential-store/device acceptance. No release workflow,
signing/notarization, APK installation or Apple device run is claimed.

## Native build and scoped transport probe

```sh
cargo build --locked --manifest-path transport/Cargo.toml
python3 -m venv /tmp/transport-probe-venv
/tmp/transport-probe-venv/bin/pip install -r transport/tests/requirements.txt
/tmp/transport-probe-venv/bin/python transport/tests/ffi_smoke.py \
    transport/target/debug/libtechmino_transport.so
```

Run those commands from Cadence. The probe needs OpenSSL. It creates a temporary CA and a certificate valid only for `localhost`; it adds the CA explicitly to the probe client. It never disables TLS or modifies the host trust store. It proves transport boundaries, not a mock account or game service.

`Cargo.lock` is provided beside this crate's own `[workspace]` and must be included in the pinned release revision. Package builds use `--locked`. HTTP uses reqwest/rustls, and WSS uses tokio-tungstenite/rustls; no TLS or handshake parser is implemented locally. Web/WASM uses the browser's fetch/WebSocket APIs rather than a Rust TLS library compiled to WASM.

## Lua interface

The adapters have the same interface:

```lua
local Transport=require 'Zframework.transport' -- Techmino
-- local Transport=require 'Zenitha.transport' -- Galaxy
local client,err=Transport.new()
local requestId,requestError=client:request{
    url='https://configured.example/v1/products',
    method='GET',
    headers={Accept='application/json'},
    timeout=12, -- seconds
    credentials='include', -- Web only; native never has a browser cookie jar
}
```

URLs are strictly `https://` or `wss://`. Native redirects are returned as HTTP responses rather than automatically followed. Browser redirects are rejected rather than exposing redirect-sensitive credentials. A development HTTP server does not become a TLS exception: put an actual verified HTTPS/WSS proxy in front of it.

Native test/development trust is explicitly configured, without a bypass:

```lua
local client,err=Transport.new{
    libraryPath='/absolute/path/libtechmino_transport.so',
    caPem=trustedLocalCaPem,
}
```

A normal `Transport.new()` also accepts `TECHMINO_TRANSPORT_LIBRARY` and `TECHMINO_TRANSPORT_CA_FILE`. The CA file is read with a 64 KiB bound and adds trusted roots; default public roots and hostname verification remain enabled.

### Operations

- `client:request{url,method?,headers?,body?,timeout?,credentials?,id?}` returns a numeric request ID or `nil,{code,message}`. `body` is raw bytes, not an implicitly encoded table.
- `client:connect{url,headers?,timeout?,id?}` returns a socket ID. For browser connections obtain the approved single-use connection ticket via Cadence HTTPS and use its returned `websocketUrl`. Browser WebSocket headers are unsupported and rejected, never silently ignored.
- `client:send(id,bytes,'text'|'binary')`, `client:close(id,code?,reason?)`, and `client:cancel(id)` return `bool,error?`.
- `client:ping(id,payload?)` sends a native protocol ping. Browsers manage protocol ping/pong themselves; their API returns `false,{code='BROWSER_MANAGED_PING',...}` for a manual protocol-ping request. No JSON gameplay ping is invented.
- `client:poll()` returns one event or `nil`. One business owner drains each client; scene changes must not create competing poll owners.
- `client:destroy()` cancels operations, closes receivers/sockets, and releases the native handle. It is idempotent at the Lua layer.

IDs increase across HTTP, sockets, and callback receivers and are never reused. Admission is bounded to 16 HTTP requests, 4 sockets, 2 callbacks, and 24 total operations per native/browser client. HTTP request/response bodies are at most 2 MiB. Complete WSS messages are at most 256 KiB; native tungstenite aggregates fragments within that bound. Native outgoing socket queues are at most 128 messages/256 KiB; incoming delivery is at most 128 events/4 MiB. Queue exhaustion fails explicitly and closes the transport rather than silently discarding required events.

The browser owns pre-delivery WebSocket buffering and cannot emit reserved protocol close code 1009 through its public `close()` API. Oversized delivered browser messages close with application code 4009; native oversize handling uses 1009. Browser outgoing limits use `bufferedAmount` plus bounded queued-message admission.

Events:

```text
{kind='http', id, status, headers, body}              -- body: raw bytes
{kind='ws_open', id}
{kind='ws_message', id, data, binary}                -- data: complete raw bytes
{kind='ws_pong', id, data}                           -- native protocol pong
{kind='ws_close', id, code, reason}
{kind='error', id, code, message}                    -- public safe error, no raw secrets
{kind='callback', id, code? xor error?, state, issuer}
```

### System-browser authorization

```lua
local bytes,err=Transport.randomBytes(64)             -- secure raw random bytes
local challenge,err=Transport.pkce(verifier)          -- unpadded base64url S256
local receiver,err=client:callbackBegin(
    productId, state, tesseraOrigin, 180, webRedirectUri)
local opened,err=client:openAuthorization(
    authorizationUrl, receiver.id, websiteOrigin)
-- Cancel both the receiver and the proof-bound Tessera request on UI cancellation:
client:callbackCancel(receiver.id)
```

The product-session business owner creates and cancels the Tessera authorization request and exchanges the returned single-use code. A receiver alone does not authenticate a user. A separate configured website origin is permitted; callback `issuer` still has to match the Tessera origin.

Desktop callbacks bind only `127.0.0.1` on an ephemeral port with exact `/callback`, require the exact Host header/state/issuer/redirect URI, have bounded headers/read time, and close on completion/cancellation/expiry. Mobile callbacks are exactly:

- Techmino: `org.studio26f.techmino:/callback`
- Galaxy: `org.studio26f.techmino-galaxy:/callback`

Android hooks cold launch and `onNewIntent` outside LÖVE's embed guards. iOS uses the real SDL UIKit delegate class-choice hook and preserves non-authorization SDL URL handling. Both call Rust's bound callback validation; merely receiving a registered scheme is not sufficient.

Web `callbackBegin` must run directly from a user gesture. It synchronously pre-opens a popup, reports popup blocking, and later navigates that same window after the HTTPS authorization response. The registered redirect is the real game page, not an invented callback endpoint. The bootstrap script relays the callback with `postMessage`; the receiver validates same origin, exact popup source, redirect URI, state and issuer. Cancellation/expiry closes the popup. PKCE state/verifier stay in the original page's memory.

## Protected session storage

Only the native product refresh credential belongs in this store. Access credentials and PKCE secrets are not persisted.

```lua
local token,status=Transport.secureStoreGet(productId)
local saved,status=Transport.secureStoreSet(productId,refreshToken)
local deleted,status=Transport.secureStoreDelete(productId)
-- status: {mode='secure'|'memory_only'|'unavailable', code?, message?}
```

- Linux uses an **already unlocked** Secret Service collection over encrypted D-Bus sessions. It does not trigger an unlock prompt or write a plaintext substitute. Missing/locked Secret Service yields a visible `memory_only` status; the session business owner retains its credential in memory and shows that mode to the user.
- Windows uses Credential Manager. macOS/iOS use Keychain through the platform-native keyring backend. Store errors return `unavailable`; no file fallback exists.
- Android Java stores only AES-256/GCM ciphertext in private SharedPreferences, using a non-exportable Android Keystore key, provider-generated nonce and package/product-bound AAD. Backup/device-transfer policies exclude the secret preference. JNI caches the actual Java class reference and attaches native threads rather than guessing class-loader exports. Key, authentication-tag, storage-commit and provider failures are not reported as an empty successful session.
- Web stores no bearer credential. It uses an independent stable HttpOnly product-session cookie and keeps access credentials in memory; `secureStoreSet` does not persist a token. Native refresh rotation/single-flight behavior belongs to the session business owner, not transport.

Both clients include browser cookies only on Tessera HTTP requests. Cadence HTTP requests explicitly use `credentials='omit'` with their bearer access credential; the WebSocket uses its issued single-use ticket instead of a browser-supplied Authorization header. Forwarding Tessera's cookie mode to Cadence incorrectly makes cross-origin bearer requests require credentialed CORS and prevents the ticket request from reaching the WebSocket path.

## Package source and public settings

Both client repositories' workflows consume either:

1. `TRANSPORT_SOURCE_REPO` plus `TRANSPORT_SOURCE_REF`, where the ref is a full 40-hex commit SHA containing this crate, its lockfile and mobile bridge sources; or
2. A hash-verified source bundle under `.github/build/transport/vendor/`, prepared from the actual Cadence checkout:

```sh
python3 .github/build/transport/vendor_source.py \
    --repo-root /absolute/path/Cadence --crate-subdir transport
```

Use the command from the corresponding client repository and include the generated exact source bundle in that release revision. The workflow rejects moving refs, missing dependencies/bridges, tampered bundle hashes, and simultaneous repo/vendor modes. A private source repo may require `TRANSPORT_SOURCE_TOKEN`. No external Cadence repository URL is guessed. `TRANSPORT_RUST_TOOLCHAIN` can select the repository's approved Rust toolchain.

`build-core` generates credential-free `online-config.json`, included in the `.love` whitelist, from:

- Required `PUBLIC_ORIGIN` and `CADENCE_PUBLIC_ORIGIN` repository variables: exact HTTPS origins.
- Optional `TESSERA_PUBLIC_ORIGIN`: defaults to `PUBLIC_ORIGIN`, where deployed same-origin proxy routes serve Tessera.
- Optional `GAME_WEB_REDIRECT_URI`: otherwise `PUBLIC_ORIGIN + /play/techmino/` or `/play/techmino-galaxy/`.

The exact Web URL must also be registered in Tessera and correspond to the actual deployed game page. These settings are public, not secrets. Missing origins fail packaging rather than silently embedding legacy hosts. Local clients can use their business-layer configuration override; this generator is for deployable packages.

### Linux system-browser environment

Upstream LÖVE AppRun adds its bundled libraries to `LD_LIBRARY_PATH`. The actual
AppImage acceptance reproduced an external opener failure:
`node: undefined symbol: BrotliDecoderAttachDictionary`.
Both Linux workflows run `prepare_linux_launcher.py` against the generated
AppDir, then rebuild the AppImage and its embedded Debian copy before upload.
AppRun captures the original host `PATH` and `LD_LIBRARY_PATH`; the packaged
`bin/xdg-open` restores them only in its child before executing the existing
system opener. LÖVE, transport, AI and audio continue using the packaged
libraries. Do not change process-global library paths during gameplay or count
an older Debian artifact as containing a newly rebuilt AppImage.


### Fresh local Web runtime

From each actual client checkout, configure the same public-origin environment variables and generate a new output directory:

```sh
python3 .github/build/transport/build_web.py \
    --product techmino --out /tmp/fresh-play-runtime/play/techmino
# From the Galaxy checkout:
python3 .github/build/transport/build_web.py \
    --product techminoGalaxy --out /tmp/fresh-play-runtime/play/techmino-galaxy
```

The script packages the real current Lua/assets and credential-free configuration. Both clients' Web jobs use the same builder against their current source checkout rather than reusing a prebuilt Web runtime. Node.js and npm are required; no remote npm package permission is needed. The builder downloads the [Davidobot/love.js archive at `c4f04e185033a7c9fbefa9be3bec88c41a90421b`](https://github.com/Davidobot/love.js/archive/c4f04e185033a7c9fbefa9be3bec88c41a90421b.tar.gz), verifies archive SHA-256 `b43129684aa1fb7b633064c37882d25a7809e5e3c4d0d938885bf395d24e7d13`, extracts only the local packager and compatibility runtime, and runs `npm ci --omit=dev --ignore-scripts --no-audit --no-fund` followed by `node index.js <fresh-core.love> <new-output> -t <product-title> -m 128000000 -c` in that temporary source directory.

The revision's package version remains `11.4.1`, so the CLI's `--version` is not LÖVE runtime evidence. Its `src/compat/love.wasm` contains compiled binary version `11.5`, Lua `love._version` value `11.5`, and codename `Mysterious Mysteries`; its SHA-256 is `8e955d3ca1db20c2c3509313c0093cf81826fc391f509194f85562ac57c601fa`. The builder verifies that exact WASM before and after packaging. The separately published npm `love.js@11.4.1` release contains the older LÖVE 11.4 runtime and is not used.

The resulting fresh package contains `love.wasm`, `game.data`, `game.js`, `love.js` and `index.html`. It retains the browser bridge at exact revision `ee8a91fa971d928dcb32f8d4d9b7e04f10e3976c`, executes its FS-globalizing helper as `globalizeFS.cjs`, and injects the framework transport as the first page script. It refuses to overwrite an existing output directory. Serve the parent output at the exact registered HTTPS game URLs and open the actual page; a completed build and compiled version bytes alone are not browser evidence.

If Galaxy's local source has no soundbanks, the builder states that it retains Galaxy's pre-existing Web path that explicitly skips FMOD; it does not fabricate audio assets or alter that behavior. Native package jobs still include/download their real audio dependencies.

### Target contents and external prerequisites

| Target | Required package contents | External prerequisites / remaining evidence |
| --- | --- | --- |
| Linux x64 | `libtechmino_transport.so` in packaged `lib/`, child-scoped `bin/xdg-open`; existing AI/audio assets preserved | Adjacent `.love` online, fused AppImage offline/statistics/replay and rebuilt AppImage consent/WSS/rooms passed locally. Genuine independently staged issued refresh token used an unlocked private Secret Service; actual process restart rotated it and reused the same server grant. Corrected Debian offline GUI/input/disk replay/restart/normal exit passed in a network-disabled clone. Debian online/physical GPU/audio and Galaxy native execution remain unverified |
| Windows x86/x64 | Separate i686/x86_64 DLL next to the matching executable; PE architecture checked | MSVC target toolchains; installer app ID; actual 32/64-bit LÖVE and Credential Manager checks pending |
| Android armv7/arm64 | APK `lib/<abi>/libtechmino_transport.so`, actual Java/JNI bridge, scheme, backup rules, minSdk23 | Java17, SDK34/NDK25.2.9519653, pinned cargo-ndk4.1.2; `ANDROID_KEYSTORE_*` signing inputs; API23+ Keystore/device runs pending |
| macOS | Universal dylib in `Contents/Frameworks`; existing dependencies preserved | Xcode/macOS runner; Developer ID/Apple account signing/notarization inputs; actual Keychain/dylib run pending |
| iOS arm64 | Static Rust archive, all nine C symbols rooted/exported for `ffi.C`, real callback source and URLTypes | Xcode/iOS SDK; pinned LÖVE/Apple dependencies and existing Techmino CCloader archive; provisioning/signing/App Store Connect inputs; actual device run pending |
| Web/WASM | Browser transport source in `.love` and injected before startup scripts at the built game root | Fresh Techmino consent/WSS/late-live authority rendering and Galaxy consent/trusted identity passed locally; Galaxy gameplay/audio is not claimed; public deployment still needs exact HTTPS origins and registered callbacks |

The independent loopback-only two-CPU staging now uses account host `localhost`
and game host `127.0.0.1`; different ports on one host did not isolate cookies.
Fresh original Techmino Web ticket issuance and WSS Upgrade passed with no
Cookie on the actual browser handshake. Original Galaxy has its own issued
product grant and trusted identity 200; actual Cadence fetch uses
`credentials: omit`. The exact compiler-produced Linux archive also completed
original consent/`ready`/room-directory and same-grant secure-refresh restart on
the new game host without library/origin overrides. These results do not turn
the two failed full-load workloads into capacity acceptance.

Galaxy native soundbanks remain unavailable: verified original downloads failed
with curl exit 6, and independent public DNS returned NXDOMAIN for the original
hostname. No replacement banks, native audio or Galaxy multiplayer were invented.

### Required device handoff

Use the actual changed release/workflow revision and exact public origins, not
an older build or fixture localhost configuration. For each product and target,
record the artifact/version, architecture, OS version, original UI result and
sanitized error if a check fails. Do not send passwords, private keys, refresh
credentials, callback queries or cookie bodies in an acceptance report.

1. Install and launch the real package with its bundled transport and existing
   AI/audio assets; no library override or application hotpatch.
2. Start sign-in from the original game UI, authenticate in the real system
   browser, approve the correct displayed product/device and return through
   the registered callback. Confirm trusted identity, not just window launch.
3. Exercise certificate/hostname rejection without bypass flags. Check
   `techmino` and `techminoGalaxy` isolation and the ordinary browser/device/
   all-device logout policies; revoked established authorization must end
   within five raw seconds.
4. With an unlocked supported OS store, close/restart and restore the genuine
   product session. Verify actual refresh/renewal of that grant. A locked or
   unavailable store must show memory-only mode; it is not a persistence PASS.
5. Techmino: use two original clients for room/readiness/input, the selected
   match track, late spectating, explicit interruption, settlement/replay and
   the next match. Galaxy: verify its account/identity/session surface, without
   inventing multiplayer modes or claiming unobserved gameplay/audio.

Windows x86 and x64 need separate actual runtime/architecture checks and
Credential Manager results. macOS needs the real signed/notarized launch,
universal library and Keychain. Android needs an installed signed APK, native
callback and Keystore on the supported API/ABI. iOS needs a provisioned device
build, actual URL callback and Keychain. Missing devices or signing inputs are
SKIP, not proof supplied by a package manifest or a configured workflow.

The operator selected manual execution of this device handoff and will return
sanitized per-platform results. These results have not yet been supplied; no
signed build, device callback or protected-store result is implied by that
decision. Keep the existing platform requirements, and mark missing actual
package/HTTPS/device prerequisites as SKIP rather than using an older fixture.

The local Galaxy native package attempt could not obtain the original
`Master.strings.bank`, `Master.bank` and `Effect.bank` from the workflow's
SharePoint URLs: all three verified curl requests failed with TLS
`unexpected eof while reading`; a distinct HTTP/1.1/TLS-1.2 attempt and the
static reader also failed, and no existing local bank files were found.
Subsequent original downloads failed with curl exit 6, and independently
verified public DNS returned NXDOMAIN for the source hostname. The operator
confirmed the original banks are unavailable; the native gate remains blocked.
No certificate bypass, substitute bank or incomplete Galaxy native artifact
was produced. Supply the genuine original banks or restore verified access to
that original asset source before claiming this native package accepted.


Mobile installers pin upstream source and fail on incompatible hooks rather than generating a callback-less package:

```sh
python3 transport/platform/install_android.py --root <love-android> --product techmino
python3 transport/platform/install_ios.py --root <patched-love> --product techmino
# For Galaxy: --product techminoGalaxy
```

LÖVE Android is pinned to `55feb38fa144f4734c26742389f279fb07d955c0`. iOS LÖVE is pinned to `c35356c841976eb6f370347b81eec845d5520338`; its Apple dependencies are `402eed62c2bd654a860bb64544393285fb640497` (SDL2.0.19). Techmino's existing iOS AI/vibration patch is applied in full before the transport installer.

Apple release jobs require the existing workflow-named inputs: `APPLE_TEAM_ID`, `MACOS_ACCOUNT_USERNAME/PASSWORD`, `MACOS_DEVELOPER_ID_APPLICATION_BASE64/PASSWORD`, optional `MACOS_DEVELOPER_ID_INSTALLER_BASE64/PASSWORD`, and `IOS_APPLE_DEVELOPMENT_BASE64/PASSWORD`, `IOS_API_KEY`, `IOS_API_KEY_ID`, `IOS_API_ISSUER_ID`, `IOS_APPLE_ID`. They run for pre-release/release tags; Android/Web packaging runs on non-PR events. These workflows do not dispatch themselves and no release/upload is implied by adding them.

## Initial change

The native crate and platform adapters replace unverified homegrown networking with maintained verified HTTPS/WSS, bounded independent request/event ownership, platform-protected session storage, and real system-browser callback hooks. Obsolete HTTP/WebSocket globals, updates and workers were removed only after all business callers had migrated; unrelated offline utilities and Galaxy's local TCP module are unchanged.
