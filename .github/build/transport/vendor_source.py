#!/usr/bin/env python3
"""Copy an exact transport source tree from the sibling Cadence checkout into
.github/build/transport/vendor so CI packages a pinned revision without a
cross-repository clone.

Usage (release flow, run from the game repository root):
  python3 .github/build/transport/vendor_source.py \
      --repo-root /path/to/Cadence \
      --crate-subdir transport

The command records a SHA-256 manifest and provenance. resolve_source.py
re-verifies every file at build time, so a stale or hand-edited vendor tree
fails the workflow instead of shipping.
"""

import argparse
import hashlib
import json
import shutil
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

IGNORE = shutil.ignore_patterns(".git", "target", "node_modules", "*.pyc", "__pycache__")


def fail(message: str) -> "None":
    print(f"error: {message}", file=sys.stderr)
    sys.exit(1)


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def git_output(repo: Path, *args: str) -> "str | None":
    if not (repo / ".git").exists():
        return None
    try:
        return subprocess.run(
            ["git", "-C", str(repo), *args], check=True, capture_output=True, text=True
        ).stdout.strip()
    except subprocess.CalledProcessError:
        return None


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--repo-root", required=True, type=Path, help="Cadence repository root to vendor from")
    parser.add_argument("--crate-subdir", default="transport", help="transport crate path inside the repository")
    parser.add_argument(
        "--out",
        type=Path,
        default=Path(".github/build/transport/vendor"),
        help="vendor output directory (default: .github/build/transport/vendor)",
    )
    parser.add_argument("--force", action="store_true", help="replace an existing vendor directory")
    args = parser.parse_args()

    repo_root = args.repo_root.resolve()
    crate_subdir = args.crate_subdir.strip("/")
    if not (repo_root / crate_subdir / "Cargo.toml").is_file():
        fail(f"{repo_root / crate_subdir}/Cargo.toml does not exist")
    if not (repo_root / crate_subdir / "Cargo.lock").is_file():
        fail(f"{repo_root / crate_subdir}/Cargo.lock does not exist; the crate must commit its lockfile")
    if args.out.exists():
        if not args.force:
            fail(f"{args.out} already exists; pass --force to replace it")
        shutil.rmtree(args.out)

    repo_out = args.out / "repo"
    # The transport crate owns its workspace and has no sibling path dependencies.
    # Do not publish unrelated backend sources or operator files with the client.
    shutil.copytree(repo_root / crate_subdir, repo_out / crate_subdir, ignore=IGNORE, symlinks=True)

    hashes = {}
    for path in sorted(repo_out.rglob("*")):
        if path.is_file():
            hashes[path.relative_to(repo_out).as_posix()] = sha256_file(path)
    if not hashes:
        fail(f"vendored source tree {repo_out} is empty")
    (args.out / "MANIFEST.sha256").write_text(
        "".join(f"{digest}  {rel}\n" for rel, digest in sorted(hashes.items())), encoding="utf-8"
    )

    provenance = {
        "mode": "vendor",
        "origin": str(repo_root),
        "crate-subdir": crate_subdir,
        "git-revision": git_output(repo_root, "rev-parse", "HEAD"),
        "git-remote": git_output(repo_root, "remote", "get-url", "origin"),
        "cargo-lock-sha256": sha256_file(repo_root / crate_subdir / "Cargo.lock"),
        "vendored-at": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "file-count": len(hashes),
    }
    (args.out / "SOURCE.json").write_text(
        json.dumps(provenance, indent=2, sort_keys=True) + "\n", encoding="utf-8"
    )
    print(json.dumps(provenance, indent=2, sort_keys=True))


if __name__ == "__main__":
    main()
