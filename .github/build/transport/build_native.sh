#!/usr/bin/env bash
# Build the authoritative techmino_transport crate for one packaging target and
# place the resulting library in a loader-resolvable layout, failing closed when
# a required toolchain, NDK or exported ABI symbol is missing.
#
# Usage: source .github/build/transport/env.sh && bash build_native.sh <target>
#   target: linux | windows | android | macos | ios
set -euo pipefail

target="${1:?usage: build_native.sh <linux|windows|android|macos|ios>}"
: "${TRANSPORT_CRATE_ROOT:?source .github/build/transport/env.sh before build_native.sh}"

toolchain="${TRANSPORT_RUST_TOOLCHAIN:-stable}"
artifacts="${TRANSPORT_ARTIFACTS:-$PWD/transport-artifacts}"
manifest="$TRANSPORT_CRATE_ROOT/Cargo.toml"
lib_stem="techmino_transport"
lockfile="$TRANSPORT_CRATE_ROOT/Cargo.lock"

fail() { echo "::error::$*" >&2; exit 1; }
note() { echo "-- $*"; }

[ -f "$manifest" ] || fail "transport crate manifest not found at $manifest"
[ -f "$lockfile" ] || fail "transport crate has no committed Cargo.lock ($lockfile); dependency versions cannot be pinned - commit the lockfile in the transport crate before running release packaging"

build() { rustup run "$toolchain" cargo build --locked --release --manifest-path "$manifest" "$@"; }

check_symbols_impl() { # <library> <nm binary> <nm flags> <symbol>...
  local lib="$1"; local nm_bin="$2"; local nm_flags="$3"; shift 3
  [ -f "$lib" ] || fail "expected library $lib was not produced"
  local symbols
  symbols="$("$nm_bin" $nm_flags "$lib" 2>/dev/null || true)"
  for symbol in "$@"; do
    grep -qE "[[:space:]][TtDdBbRrWwVv] _?${symbol}\$" <<<"$symbols" \
      || fail "$lib does not define $symbol; the packaged library would not provide the frozen tn_* ABI"
  done
  note "exported ABI symbols verified in $lib: $*"
}

## Frozen C ABI (single source of truth in env.sh); word splitting is intended.
# shellcheck disable=SC2206
ABI_SYMBOLS=(${TRANSPORT_ABI_SYMBOLS:-tn_client_new tn_client_destroy tn_command tn_poll tn_callback_begin tn_secret tn_random tn_pkce tn_mobile_callback})

rustup toolchain install "$toolchain" --profile minimal --no-self-update
add_target() { rustup target add --toolchain "$toolchain" "$1"; }

case "$target" in
  linux)
    add_target x86_64-unknown-linux-gnu
    build --target x86_64-unknown-linux-gnu
    out="$artifacts/linux-x64"
    mkdir -p "$out"
    cp "$TRANSPORT_CRATE_ROOT/target/x86_64-unknown-linux-gnu/release/lib${lib_stem}.so" "$out/"
    check_symbols_impl "$out/lib${lib_stem}.so" nm "-D --defined-only" "${ABI_SYMBOLS[@]}"
    ;;
  windows)
    add_target i686-pc-windows-msvc
    add_target x86_64-pc-windows-msvc
    build --target i686-pc-windows-msvc
    build --target x86_64-pc-windows-msvc
    mkdir -p "$artifacts/windows-x86" "$artifacts/windows-x64"
    cp "$TRANSPORT_CRATE_ROOT/target/i686-pc-windows-msvc/release/${lib_stem}.dll" "$artifacts/windows-x86/"
    cp "$TRANSPORT_CRATE_ROOT/target/x86_64-pc-windows-msvc/release/${lib_stem}.dll" "$artifacts/windows-x64/"
    python3 - "$artifacts/windows-x86/${lib_stem}.dll" 0x14c "$artifacts/windows-x64/${lib_stem}.dll" 0x8664 <<'PY'
import struct
import sys

for index in range(1, len(sys.argv), 2):
    path, expected = sys.argv[index], int(sys.argv[index + 1], 16)
    with open(path, "rb") as handle:
        data = handle.read(0x40)
    if data[:2] != b"MZ":
        sys.exit(f"::error::{path} is not a PE image")
    pe_offset = struct.unpack_from("<I", data, 0x3C)[0]
    with open(path, "rb") as handle:
        handle.seek(pe_offset)
        machine = struct.unpack("<H", handle.read(6)[4:6])[0]
    if machine != expected:
        sys.exit(f"::error::{path} has PE machine 0x{machine:x}, expected 0x{expected:x}")
    print(f"-- {path} PE machine 0x{machine:x} verified")
PY
    ;;
  android)
    : "${ANDROID_NDK_HOME:?ANDROID_NDK_HOME must point at the pinned NDK (25.2.9519653) before building the Android transport}"
    [ -d "$ANDROID_NDK_HOME/toolchains/llvm/prebuilt" ] || fail "ANDROID_NDK_HOME=$ANDROID_NDK_HOME does not look like an installed NDK"
    add_target armv7-linux-androideabi
    add_target aarch64-linux-android
    cargo_ndk_version="${TRANSPORT_CARGO_NDK_VERSION:-4.1.2}"
    if ! command -v cargo-ndk >/dev/null 2>&1; then
      note "installing cargo-ndk $cargo_ndk_version (pinned)"
      cargo install cargo-ndk --locked --version "$cargo_ndk_version" >/dev/null
    fi
    out="$artifacts/android"
    mkdir -p "$out"
    # cargo-ndk needs its own --manifest-path (it resolves the crate from the
    # current directory otherwise) and API level 23 to match the app's minSdk.
    rustup run "$toolchain" cargo ndk --manifest-path "$manifest" --platform 23 \
      -t armeabi-v7a -t arm64-v8a -o "$out" build --locked --release
    llvm_nm="$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin/llvm-nm"
    [ -x "$llvm_nm" ] || llvm_nm="$(find "$ANDROID_NDK_HOME/toolchains/llvm/prebuilt" -name llvm-nm -type f | head -n 1)"
    [ -x "${llvm_nm:-}" ] || fail "llvm-nm not found in $ANDROID_NDK_HOME"
    check_symbols_impl "$out/arm64-v8a/lib${lib_stem}.so" "$llvm_nm" "-D --defined-only" "${ABI_SYMBOLS[@]}"
    check_symbols_impl "$out/armeabi-v7a/lib${lib_stem}.so" "$llvm_nm" "-D --defined-only" "${ABI_SYMBOLS[@]}"
    ;;
  macos)
    add_target aarch64-apple-darwin
    add_target x86_64-apple-darwin
    build --target aarch64-apple-darwin
    build --target x86_64-apple-darwin
    out="$artifacts/macos"
    mkdir -p "$out"
    lipo -create \
      "$TRANSPORT_CRATE_ROOT/target/aarch64-apple-darwin/release/lib${lib_stem}.dylib" \
      "$TRANSPORT_CRATE_ROOT/target/x86_64-apple-darwin/release/lib${lib_stem}.dylib" \
      -output "$out/lib${lib_stem}.dylib"
    lipo -info "$out/lib${lib_stem}.dylib" | grep -q "arm64" || fail "universal dylib is missing arm64"
    lipo -info "$out/lib${lib_stem}.dylib" | grep -q "x86_64" || fail "universal dylib is missing x86_64"
    check_symbols_impl "$out/lib${lib_stem}.dylib" nm "-g" "${ABI_SYMBOLS[@]}"
    ;;
  ios)
    add_target aarch64-apple-ios
    build --target aarch64-apple-ios
    out="$artifacts/ios"
    mkdir -p "$out"
    cp "$TRANSPORT_CRATE_ROOT/target/aarch64-apple-ios/release/lib${lib_stem}.a" "$out/"
    check_symbols_impl "$out/lib${lib_stem}.a" nm "-g" "${ABI_SYMBOLS[@]}"
    ;;
  *)
    fail "unknown transport target '$target'"
    ;;
esac

note "$target transport artifacts written to $artifacts"
