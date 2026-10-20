# shellcheck shell=bash
# Shared environment for the native transport packaging steps.
# Source this file from workflow steps:  source .github/build/transport/env.sh
#
# Layout produced by the transport-source job (artifact "transport_source"):
#   transport-src/SOURCE.json          provenance of the resolved crate source
#   transport-src/repo/<crate-subdir>/ the authoritative techmino_transport crate
set -euo pipefail

transport_workspace="${GITHUB_WORKSPACE:-$PWD}"

export TRANSPORT_SRC="${TRANSPORT_SRC:-transport-src}"
export TRANSPORT_SOURCE_ROOT="$transport_workspace/$TRANSPORT_SRC/repo"
export TRANSPORT_CRATE_ROOT="$TRANSPORT_SOURCE_ROOT/${TRANSPORT_CRATE_SUBDIR:-transport}"
export TRANSPORT_ARTIFACTS="${TRANSPORT_ARTIFACTS:-$transport_workspace/transport-artifacts}"
export TRANSPORT_WORK_DIR="${TRANSPORT_WORK_DIR:-$transport_workspace/transport-work}"
export TRANSPORT_GENERATED_DIR="${TRANSPORT_GENERATED_DIR:-$transport_workspace/transport-generated}"
export TRANSPORT_ARTIFACTS_ROOT="$transport_workspace/$TRANSPORT_SRC"
export TRANSPORT_RUST_TOOLCHAIN="${TRANSPORT_RUST_TOOLCHAIN:-stable}"

# Frozen C ABI from the transport header
# (OtherProjects/Cadence/transport/include/techmino_transport.h). Both the
# native artifact check and the iOS export wiring must cover exactly this set.
export TRANSPORT_ABI_SYMBOLS="${TRANSPORT_ABI_SYMBOLS:-tn_client_new tn_client_destroy tn_command tn_poll tn_callback_begin tn_secret tn_random tn_pkce tn_mobile_callback}"

if [ ! -f "$TRANSPORT_ARTIFACTS_ROOT/SOURCE.json" ]; then
  echo "::error::transport source artifact is missing ($TRANSPORT_ARTIFACTS_ROOT/SOURCE.json); the transport-source job must run first"
  exit 1
fi
if [ ! -f "$TRANSPORT_CRATE_ROOT/Cargo.toml" ]; then
  echo "::error::resolved transport crate not found at $TRANSPORT_CRATE_ROOT"
  exit 1
fi
