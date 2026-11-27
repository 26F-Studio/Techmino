#!/usr/bin/env bash
# Fail-closed package verification: prove that the shipped artifact really
# carries the native transport library (and the bridge/callback registration)
# in a loader-resolvable location instead of trusting the packaging step.
#
# Usage: verify_package.sh <kind> <path>
#   android-libs   staging jniLibs dir (pre-APK)
#   android-apk    built APK
#   windows-libs   staging DLL dir (pre-zip, per arch)
#   windows-zip    built x86/x64 zip
#   linux-appimage built AppImage
#   macos-zip      built macOS zip
#   ios-ipa        built iOS ipa
# TRANSPORT_VERIFY_EXTRA lists extra members/paths that must survive packaging.
set -euo pipefail

kind="${1:?usage: verify_package.sh <kind> <path>}"
path="${2:?usage: verify_package.sh <kind> <path>}"
extra="${TRANSPORT_VERIFY_EXTRA:-}"

fail() { echo "::error::$*" >&2; exit 1; }

zip_members() { # <archive> <member>...
  local archive="$1"; shift
  python3 - "$archive" "$@" <<'PY'
import sys
import zipfile

archive, wanted = sys.argv[1], sys.argv[2:]
with zipfile.ZipFile(archive) as handle:
    names = handle.namelist()
for want in wanted:
    hits = [n for n in names if n == want or n.endswith("/" + want)]
    if not hits:
        sys.exit(f"::error::{archive} does not contain {want}")
    print(f"-- {archive} contains {hits[0]}")
PY
}

case "$kind" in
  android-libs)
    for abi in arm64-v8a armeabi-v7a; do
      [ -f "$path/$abi/libtechmino_transport.so" ] \
        || fail "Android transport library for $abi missing from $path ($abi/libtechmino_transport.so)"
      echo "-- $path/$abi/libtechmino_transport.so present"
    done
    ;;
  android-apk)
    [ -f "$path" ] || fail "APK $path does not exist"
    zip_members "$path" lib/arm64-v8a/libtechmino_transport.so lib/armeabi-v7a/libtechmino_transport.so ${extra}
    python3 - "$path" "${TRANSPORT_PRODUCT_SCHEME:?TRANSPORT_PRODUCT_SCHEME must be set}" <<'PY'
import sys
import zipfile

apk, scheme = sys.argv[1], sys.argv[2]
with zipfile.ZipFile(apk) as handle:
    manifest = handle.read("AndroidManifest.xml")
if not any(needle in manifest for needle in (scheme.encode("utf-8"), scheme.encode("utf-16-le"))):
    sys.exit(f"::error::{apk} AndroidManifest.xml does not register the callback scheme {scheme}")
print(f"-- {apk} registers callback scheme {scheme}")
PY
    ;;
  windows-libs)
    [ -f "$path/techmino_transport.dll" ] || fail "Windows transport DLL missing from $path"
    echo "-- $path/techmino_transport.dll present"
    ;;
  windows-zip)
    [ -f "$path" ] || fail "Windows package $path does not exist"
    zip_members "$path" techmino_transport.dll ${extra}
    ;;
  linux-appimage)
    [ -f "$path" ] || fail "AppImage $path does not exist"
    abs="$(cd "$(dirname "$path")" && pwd)/$(basename "$path")"
    tmp="$(mktemp -d)"
    trap 'rm -rf "$tmp"' EXIT
    chmod +x "$abs"
    ( cd "$tmp" && "$abs" --appimage-extract >/dev/null ) || fail "cannot extract $abs for verification"
    [ -f "$tmp/squashfs-root/lib/libtechmino_transport.so" ] \
      || fail "$abs does not ship lib/libtechmino_transport.so"
    echo "-- $abs ships lib/libtechmino_transport.so"
    for member in $extra; do
      [ -e "$tmp/squashfs-root/$member" ] || fail "$abs lost the packaged asset $member"
      echo "-- $abs keeps $member"
    done
    ;;
  macos-zip)
    [ -f "$path" ] || fail "macOS package $path does not exist"
    zip_members "$path" Contents/Frameworks/libtechmino_transport.dylib ${extra}
    ;;
  ios-ipa)
    [ -f "$path" ] || fail "iOS package $path does not exist"
    tmp="$(mktemp -d)"
    trap 'rm -rf "$tmp"' EXIT
    unzip -q -o "$path" "Payload/*" -d "$tmp" || fail "cannot extract $path"
    app_dir="$(find "$tmp/Payload" -mindepth 1 -maxdepth 1 -name "*.app" | head -n 1)"
    [ -n "$app_dir" ] || fail "$path has no Payload/*.app"
    binary="$(find "$app_dir" -mindepth 1 -maxdepth 1 -type f -size +1M | head -n 1)"
    [ -n "$binary" ] || fail "$app_dir has no app executable to inspect"
    symbols="$(nm -g "$binary" 2>/dev/null || true)"
    for symbol in ${TRANSPORT_ABI_SYMBOLS:-tn_client_new tn_client_destroy tn_command tn_poll tn_callback_begin tn_secret tn_random tn_pkce tn_mobile_callback}; do
      grep -qE "[[:space:]]_?${symbol}\$" <<<"$symbols" \
        || fail "$binary does not export $symbol; the statically linked transport ABI is incomplete"
    done
    echo "-- $binary exports the full frozen tn_* transport ABI"
    plutil -extract CFBundleURLTypes xml1 -o - "$app_dir/Info.plist" > "$tmp/urltypes.xml" \
      || fail "$app_dir/Info.plist has no CFBundleURLTypes"
    grep -qF "${TRANSPORT_PRODUCT_SCHEME:?TRANSPORT_PRODUCT_SCHEME must be set}" "$tmp/urltypes.xml" \
      || fail "$app_dir does not register the callback scheme"
    echo "-- $app_dir registers callback scheme $TRANSPORT_PRODUCT_SCHEME"
    ;;
  *)
    fail "unknown verification kind '$kind'"
    ;;
esac
