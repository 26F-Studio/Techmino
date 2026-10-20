#!/usr/bin/env python3
"""Resolve the authoritative techmino_transport crate for packaging.

Exactly two reproducible source modes are supported; anything else fails closed
before any package can be produced:

  vendor  .github/build/transport/vendor/{repo/, MANIFEST.sha256, SOURCE.json}
          Exact source copied from the sibling Cadence checkout during a release
          flow; every file is hash-verified at build time.
  repo    TRANSPORT_SOURCE_REPO + TRANSPORT_SOURCE_REF
          Explicit source repository and full 40-character commit SHA checked out
          by the workflow. Moving refs (branches, tags, "latest") are rejected.

Output layout (uploaded as the "transport_source" artifact):
  <out>/SOURCE.json    resolved provenance + hashes
  <out>/repo/...       source tree containing the crate
"""

import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
import tomllib
from pathlib import Path

REQUIRED_LIB_NAME = "techmino_transport"
REQUIRED_CRATE_TYPES = ("cdylib", "staticlib")
SHA_RE = re.compile(r"^[0-9a-f]{40}$")
VENDOR_MANIFEST_NAME = "MANIFEST.sha256"


def fail(message: str) -> "None":
    print(f"::error::{message}", file=sys.stderr)
    sys.exit(1)


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def hash_tree(root: Path) -> "dict[str, str]":
    hashes: "dict[str, str]" = {}
    for path in sorted(root.rglob("*")):
        if not path.is_file():
            continue
        rel = path.relative_to(root).as_posix()
        if rel.startswith(".git/") or rel == ".git":
            continue
        if "/target/" in f"/{rel}" or rel.startswith("target/"):
            continue
        hashes[rel] = sha256_file(path)
    return hashes


def read_manifest(path: Path) -> "dict[str, str]":
    entries: "dict[str, str]" = {}
    for line in path.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line:
            continue
        digest, _, rel = line.partition("  ")
        if not rel:
            fail(f"malformed vendor manifest line: {line!r}")
        entries[rel] = digest
    return entries


def verify_vendor_tree(root: Path, manifest_path: Path) -> int:
    actual = hash_tree(root)
    expected = read_manifest(manifest_path)
    missing = sorted(set(expected) - set(actual))
    extra = sorted(set(actual) - set(expected))
    changed = sorted(rel for rel in set(expected) & set(actual) if expected[rel] != actual[rel])
    if missing or extra or changed:
        fail(
            "vendored transport source does not match "
            f"{manifest_path}: missing={missing[:5]} unexpected={extra[:5]} changed={changed[:5]}"
        )
    return len(actual)


def dump_toml(path: Path) -> dict:
    with path.open("rb") as handle:
        return tomllib.load(handle)


def find_workspace_root(crate_root: Path) -> "Path | None":
    current = crate_root
    for _ in range(8):
        current = current.parent
        manifest = current / "Cargo.toml"
        if manifest.is_file():
            try:
                data = dump_toml(manifest)
            except Exception:  # noqa: BLE001 - unparsable parent manifests are not our concern
                continue
            if "workspace" in data or "package" in data:
                return current
    return None


def collect_path_deps(table: dict, location: str, found: "list[tuple[str, str]]") -> None:
    for key, value in table.items():
        if isinstance(value, dict):
            if "path" in value:
                found.append((f"{location}.{key}", str(value["path"])))
            collect_path_deps(value, f"{location}.{key}", found)


def find_lockfile(crate_root: Path, source_root: Path, manifest_data: dict) -> Path:
    """Locate the lockfile that pins the packaged dependency graph.

    A crate that is its own workspace root must carry Cargo.lock next to its
    manifest; a member crate is pinned by the enclosing workspace lockfile.
    """
    direct = crate_root / "Cargo.lock"
    if direct.is_file():
        return direct
    if "workspace" in manifest_data:
        fail(
            f"missing {direct}; this crate declares its own [workspace], so it must commit "
            "Cargo.lock to pin dependency versions for packaging"
        )
    candidates = sorted(source_root.rglob("Cargo.lock"))
    if len(candidates) == 1:
        return candidates[0]
    if not candidates:
        fail(
            f"no Cargo.lock found at {crate_root} or under {source_root}; "
            "dependency versions cannot be pinned - commit the workspace lockfile"
        )
    fail(
        "multiple workspace lockfiles found ("
        + ", ".join(str(c) for c in candidates[:5])
        + "); the transport crate must resolve through exactly one pinned lockfile"
    )


def verify_manifest(manifest: Path, source_root: Path, crate_root: Path) -> dict:
    if not manifest.is_file():
        fail(f"missing crate manifest: {manifest}")
    data = dump_toml(manifest)
    lib = data.get("lib")
    if not isinstance(lib, dict):
        fail(f"{manifest} must declare a [lib] section")
    name = lib.get("name")
    if name != REQUIRED_LIB_NAME:
        fail(f"{manifest} must declare [lib] name = \"{REQUIRED_LIB_NAME}\" (found {name!r})")
    crate_types = lib.get("crate-type") or []
    missing = [t for t in REQUIRED_CRATE_TYPES if t not in crate_types]
    if missing:
        fail(f"{manifest} [lib] crate-type must include {list(REQUIRED_CRATE_TYPES)} (missing {missing})")
    lockfile = find_lockfile(crate_root, source_root, data)
    missing_installers = [
        str(rel)
        for rel in ("platform/install_android.py", "platform/install_ios.py")
        if not (crate_root / rel).is_file()
    ]
    if missing_installers:
        fail(
            "transport crate is missing the mobile bridge installers "
            f"{missing_installers}; both packaged products need them to register the "
            "callback installer and keep the native symbols in the shipped app"
        )

    path_deps: "list[tuple[str, str]]" = []
    collect_path_deps({k: v for k, v in data.items() if k != "workspace"}, str(manifest), path_deps)
    if "workspace" in data:
        # The crate is its own workspace root; enclosing manifests do not participate.
        workspace_root = crate_root
    else:
        workspace_root = find_workspace_root(crate_root)
        if workspace_root is not None:
            workspace_manifest = workspace_root / "Cargo.toml"
            try:
                workspace_data = dump_toml(workspace_manifest)
            except Exception as exc:  # noqa: BLE001
                fail(f"cannot parse workspace manifest {workspace_manifest}: {exc}")
            collect_path_deps(workspace_data.get("workspace", {}), str(workspace_manifest), path_deps)

    source_root = source_root.resolve()
    for where, raw in path_deps:
        base = crate_root if where.startswith(str(manifest)) else source_root
        target = (base / raw).resolve()
        if source_root not in target.parents and target != source_root:
            fail(
                f"dependency {where} points outside the packaged transport source ({raw}); "
                "package the dependency inside the source tree or pin it from a registry"
            )
    return {
        "lib": name,
        "crate-types": crate_types,
        "path-dependency-count": len(path_deps),
        "workspace-root": None if workspace_root is None else workspace_root.name,
        "lockfile": str(lockfile.relative_to(source_root)) if lockfile.is_relative_to(source_root) else str(lockfile),
    }


def copy_tree(src: Path, dst: Path) -> None:
    if dst.exists():
        shutil.rmtree(dst)
    dst.parent.mkdir(parents=True, exist_ok=True)
    shutil.copytree(
        src,
        dst,
        ignore=shutil.ignore_patterns(".git", "target", "node_modules", "*.pyc", "__pycache__"),
        symlinks=True,
    )


def main() -> None:
    workspace = Path(os.environ.get("GITHUB_WORKSPACE") or os.getcwd())
    here = workspace / ".github/build/transport"
    vendor_dir = Path(os.environ.get("TRANSPORT_VENDOR_DIR", here / "vendor"))
    checkout_dir = Path(os.environ.get("TRANSPORT_CHECKOUT_DIR", workspace / "transport-checkout"))
    out = Path(os.environ.get("TRANSPORT_SRC_OUT", workspace / "transport-src"))
    crate_subdir = os.environ.get("TRANSPORT_CRATE_SUBDIR", "transport").strip("/")
    requested_mode = os.environ.get("TRANSPORT_SOURCE_MODE", "").strip()

    vendored_crate = vendor_dir / "repo" / crate_subdir
    has_vendor = (vendor_dir / VENDOR_MANIFEST_NAME).is_file() and vendored_crate.is_dir()

    mode = requested_mode or ("vendor" if has_vendor else "repo")
    if mode not in ("vendor", "repo"):
        fail(f"unknown TRANSPORT_SOURCE_MODE {mode!r}")

    if mode == "vendor" and not has_vendor:
        fail(
            f"vendored transport source is incomplete: expected {vendor_dir}/{VENDOR_MANIFEST_NAME} "
            f"and {vendored_crate}"
        )
    if mode == "repo" and has_vendor:
        fail(
            "both a vendored transport source and an explicit source repository are configured; "
            "keep exactly one to avoid packaging an ambiguous revision"
        )

    out.mkdir(parents=True, exist_ok=True)
    repo_out = out / "repo"

    source_repo = os.environ.get("TRANSPORT_SOURCE_REPO", "").strip()
    source_ref = os.environ.get("TRANSPORT_SOURCE_REF", "").strip()

    if mode == "vendor":
        files = verify_vendor_tree(vendor_dir / "repo", vendor_dir / VENDOR_MANIFEST_NAME)
        copy_tree(vendor_dir / "repo", repo_out)
        provenance = json.loads((vendor_dir / "SOURCE.json").read_text(encoding="utf-8"))
        mode_report = {"mode": "vendor", "verified-files": files, **provenance}
    else:
        if not source_repo or not source_ref:
            fail(
                "transport source is not configured: set the repository variables TRANSPORT_SOURCE_REPO "
                "and TRANSPORT_SOURCE_REF, or commit a vendored source under .github/build/transport/vendor"
            )
        if not SHA_RE.match(source_ref):
            fail(
                f"TRANSPORT_SOURCE_REF must be a full 40-character commit SHA (got {source_ref!r}); "
                "branches, tags and moving refs are not reproducible"
            )
        if not (checkout_dir / ".git").exists():
            fail(f"transport source checkout is missing at {checkout_dir}")
        head = subprocess.run(
            ["git", "-C", str(checkout_dir), "rev-parse", "HEAD"],
            check=True,
            capture_output=True,
            text=True,
        ).stdout.strip()
        if head != source_ref:
            fail(f"checked out transport source is {head}, expected {source_ref}")
        copy_tree(checkout_dir, repo_out)
        mode_report = {"mode": "repo", "repo": source_repo, "ref": source_ref}

    crate_root = repo_out / crate_subdir
    if not crate_root.is_dir():
        fail(f"crate directory {crate_subdir!r} does not exist in the resolved transport source")
    metrics = verify_manifest(crate_root / "Cargo.toml", repo_out, crate_root)

    report = {
        **mode_report,
        "crate-subdir": crate_subdir,
        "cargo-lock-sha256": sha256_file(repo_out / metrics["lockfile"]),
        "crate": metrics,
        "resolved-at": subprocess.run(
            ["date", "-u", "+%Y-%m-%dT%H:%M:%SZ"], check=True, capture_output=True, text=True
        ).stdout.strip(),
    }
    (out / "SOURCE.json").write_text(json.dumps(report, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    print(json.dumps(report, indent=2, sort_keys=True))


if __name__ == "__main__":
    main()
