#!/usr/bin/env bash
# Prepare the mobile bridge patch that love-actions applies to its own pinned
# upstream checkout.
#
# The bridge sources live in the transport crate (platform/install_android.py,
# platform/install_ios.py). They are copied into a pinned upstream tree here,
# the result is converted into a git patch, and the patch is validated so a
# package can never be produced without the callback installer, the required
# intent/URL-scheme registration and the tn_* export wiring.
#
# Usage: source .github/build/transport/env.sh && bash prepare_mobile_patch.sh <android|ios>
set -euo pipefail

platform="${1:?usage: prepare_mobile_patch.sh <android|ios>}"
: "${TRANSPORT_CRATE_ROOT:?source .github/build/transport/env.sh before prepare_mobile_patch.sh}"
: "${TRANSPORT_PRODUCT:?TRANSPORT_PRODUCT must be techmino or techminoGalaxy}"
: "${TRANSPORT_PRODUCT_SCHEME:?TRANSPORT_PRODUCT_SCHEME must hold the product callback scheme}"

work="${TRANSPORT_WORK_DIR:-$PWD/transport-work}"
out_dir="${TRANSPORT_GENERATED_DIR:-$PWD/transport-generated}"
mkdir -p "$work" "$out_dir"

fail() { echo "::error::$*" >&2; exit 1; }

clone_pinned() { # <url> <sha> <dir>
  local url="$1" sha="$2" dir="$3"
  rm -rf "$dir"
  git init -q "$dir"
  git -C "$dir" remote add origin "$url"
  git -C "$dir" fetch -q --depth 1 origin "$sha" \
    || fail "cannot fetch $sha from $url; the pinned bridge ref must exist upstream"
  git -C "$dir" checkout -q --detach FETCH_HEAD
  local head
  head="$(git -C "$dir" rev-parse HEAD)"
  [ "$head" = "$sha" ] || fail "checked out $head from $url, expected pinned $sha"
}

emit_patch() { # <tree> <patch path> <expected path fragment>...
  local tree="$1" patch="$2"; shift 2
  git -C "$tree" add -A
  local ignored
  ignored="$(git -C "$tree" status --porcelain --ignored=matching | grep '^!!' || true)"
  if [ -n "$ignored" ]; then
    fail "bridge installer produced files excluded by upstream .gitignore, which would be dropped from the shipped patch: $(echo "$ignored" | tr '\n' ' ')"
  fi
  local changed
  changed="$(git -C "$tree" diff --cached --name-only)"
  [ -n "$changed" ] || fail "bridge installer produced no changes in $tree"
  if grep -q '^love/src/jni/love/' <<<"$changed"; then
    fail "bridge installer modified the pinned love submodule; only parent-repo files may be patched"
  fi
  for fragment in "$@"; do
    grep -q "$fragment" <<<"$changed" || fail "bridge installer did not touch $fragment in $tree (changed: $changed)"
  done
  git -C "$tree" diff --cached --binary > "$patch"
  [ -s "$patch" ] || fail "generated bridge patch $patch is empty"
  grep -qF "$TRANSPORT_PRODUCT_SCHEME" "$patch" \
    || fail "generated patch does not register the $TRANSPORT_PRODUCT_SCHEME callback; refusing to ship an unreachable mobile callback"
  echo "-- bridge patch: $patch"
  echo "$changed" | sed 's/^/   patched: /'
}

case "$platform" in
  android)
    : "${TRANSPORT_LOVE_ANDROID_REF:?TRANSPORT_LOVE_ANDROID_REF must pin the love-android commit}"
    installer="$TRANSPORT_CRATE_ROOT/platform/install_android.py"
    [ -f "$installer" ] || fail "missing Android bridge installer $installer"
    tree="$work/love-android"
    clone_pinned https://github.com/love2d/love-android "$TRANSPORT_LOVE_ANDROID_REF" "$tree"
    python3 "$installer" --root "$tree" --product "$TRANSPORT_PRODUCT"
    patch="$out_dir/android.patch"
    emit_patch "$tree" "$patch" "AndroidManifest.xml" "GameActivity.java" "\.java$"
    grep -q 'SecureSession' "$patch" \
      || fail "generated Android patch does not install the SecureSession bridge class; the Keystore/callback installer would be missing from the APK"
    ;;
  ios)
    : "${TRANSPORT_LOVE_IOS_REF:?TRANSPORT_LOVE_IOS_REF must pin the love2d/love commit}"
    installer="$TRANSPORT_CRATE_ROOT/platform/install_ios.py"
    [ -f "$installer" ] || fail "missing iOS bridge installer $installer"
    tree="$work/love"
    clone_pinned https://github.com/love2d/love "$TRANSPORT_LOVE_IOS_REF" "$tree"
    if [ -n "${TRANSPORT_IOS_BASE_PATCH:-}" ]; then
      base_patch="$TRANSPORT_IOS_BASE_PATCH"
      [ -f "$base_patch" ] || fail "configured iOS base patch $base_patch does not exist"
      git -C "$tree" apply --check "$base_patch" \
        || fail "iOS base patch $base_patch does not apply to $TRANSPORT_LOVE_IOS_REF"
      git -C "$tree" apply "$base_patch"
      echo "-- applied iOS base patch $base_patch (keeps the Cold Clear offline AI injection)"
    fi
    python3 "$installer" --root "$tree" --product "$TRANSPORT_PRODUCT"
    patch="$out_dir/ios.patch"
    emit_patch "$tree" "$patch" "love-ios.plist"
    grep -qiE 'force_load|export_dynamic|exported_symbols?|-u _?tn_' "$patch" \
      || fail "generated iOS patch does not keep the tn_* symbols alive in the app link; ffi.C would not see the transport"
    mentioned="$(grep -oE 'tn_[a-z_]+' "$patch" | sort -u | tr '\n' ' ')"
    abi_symbols="${TRANSPORT_ABI_SYMBOLS:-tn_client_new tn_client_destroy tn_command tn_poll tn_callback_begin tn_secret tn_random tn_pkce tn_mobile_callback}"
    for symbol in $mentioned; do
      case " $abi_symbols " in
        *" $symbol "*) ;;
        *) fail "iOS patch references $symbol which is not part of the frozen tn_* ABI" ;;
      esac
    done
    if grep -qE '"-[uU]"|-Wl,-u|--undefined' "$patch"; then
      [ -n "$mentioned" ] || fail "iOS patch uses -u linker roots but names no tn_* symbol"
      for symbol in $abi_symbols; do
        case " $mentioned " in
          *" $symbol "*) ;;
          *) fail "iOS patch retains -u tn_* roots but omits $symbol; the shipped binary would not export the frozen ABI" ;;
        esac
      done
      echo "-- iOS patch retains the full frozen ABI via -u roots: $abi_symbols"
    fi
    ;;
  *)
    fail "unknown bridge platform '$platform'"
    ;;
esac
