#!/usr/bin/env bash
# Assemble the static/dynamic library directory that love-actions copies into an
# iOS or macOS package: the built techmino_transport artifact plus the pinned
# offline AI (Cold Clear) artifacts for products that ship it.
#
# Usage: source .github/build/transport/env.sh && bash stage_bridge_libs.sh <ios|macos>
# Env:
#   TRANSPORT_COLD_CLEAR_URL     optional pinned Cold Clear archive (empty -> none)
#   TRANSPORT_COLD_CLEAR_EXPECT  space separated member paths that must exist in the archive
#   TRANSPORT_COLD_CLEAR_LIBS    space separated extracted paths to stage
set -euo pipefail

platform="${1:?usage: stage_bridge_libs.sh <ios|macos>}"
: "${TRANSPORT_ARTIFACTS:?source .github/build/transport/env.sh before stage_bridge_libs.sh}"

stage="${TRANSPORT_BRIDGE_STAGE:-$PWD/transport-libs}"
rm -rf "$stage"
mkdir -p "$stage"

fail() { echo "::error::$*" >&2; exit 1; }

case "$platform" in
  ios) source_dir="$TRANSPORT_ARTIFACTS/ios" ;;
  macos) source_dir="$TRANSPORT_ARTIFACTS/macos" ;;
  *) fail "unknown bridge platform '$platform'" ;;
esac
[ -d "$source_dir" ] || fail "native transport artifacts for $platform are missing at $source_dir (build_native.sh must run first)"
cp "$source_dir"/* "$stage/"

if [ -n "${TRANSPORT_COLD_CLEAR_URL:-}" ]; then
  archive="$PWD/transport-cold-clear.zip"
  extract="$PWD/transport-cold-clear"
  rm -rf "$extract"
  mkdir -p "$extract"
  curl -L --retry 5 "$TRANSPORT_COLD_CLEAR_URL" -o "$archive"
  if command -v unzip >/dev/null 2>&1; then
    unzip -q -o "$archive" -d "$extract"
  elif command -v 7z >/dev/null 2>&1; then
    7z x "$archive" "-o$extract" >/dev/null
  else
    fail "cannot extract $archive: neither unzip nor 7z is available"
  fi
  for member in ${TRANSPORT_COLD_CLEAR_EXPECT:?TRANSPORT_COLD_CLEAR_EXPECT must list the expected Cold Clear members}; do
    [ -f "$extract/$member" ] || fail "Cold Clear archive $TRANSPORT_COLD_CLEAR_URL does not contain $member"
  done
  for member in ${TRANSPORT_COLD_CLEAR_LIBS:?TRANSPORT_COLD_CLEAR_LIBS must list the Cold Clear libraries to stage}; do
    [ -f "$extract/$member" ] || fail "Cold Clear archive $TRANSPORT_COLD_CLEAR_URL does not contain $member"
    cp "$extract/$member" "$stage/"
  done
  rm -f "$archive"
  rm -rf "$extract"
else
  echo "-- no Cold Clear archive configured for $platform; staging transport artifacts only"
fi

case "$platform" in
  ios)
    [ -f "$stage/libtechmino_transport.a" ] || fail "staged iOS transport static library missing"
    ;;
  macos)
    [ -f "$stage/libtechmino_transport.dylib" ] || fail "staged macOS transport dylib missing"
    ;;
esac

echo "-- staged bridge libraries in $stage:"
ls -1 "$stage" | sed 's/^/   /'
