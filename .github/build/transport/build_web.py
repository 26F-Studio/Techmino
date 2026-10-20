#!/usr/bin/env python3
"""Build a fresh source-backed love.js runtime; never reuse an obsolete game WASM.

Run from the client checkout with configured HTTPS origins:
python3 .github/build/transport/build_web.py --product techmino --out /tmp/play/techmino
The integration owner opens the resulting real game page to establish runtime proof.
"""
import argparse
import hashlib
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import tarfile
import urllib.request
import zipfile

LOVEJS_REVISION = "c4f04e185033a7c9fbefa9be3bec88c41a90421b"
LOVEJS_ARCHIVE_SHA256 = "b43129684aa1fb7b633064c37882d25a7809e5e3c4d0d938885bf395d24e7d13"
LOVEJS_COMPAT_WASM_SHA256 = "8e955d3ca1db20c2c3509313c0093cf81826fc391f509194f85562ac57c601fa"
LOVEJS_FILES = (
    "package.json", "package-lock.json", "index.js", "src/game.js",
    "src/compat/index.html", "src/compat/love.js", "src/compat/love.wasm",
    "src/compat/theme/bg.png", "src/compat/theme/love.css",
)
BRIDGE_REVISION = "ee8a91fa971d928dcb32f8d4d9b7e04f10e3976c"
BUILD_LISTS = {
    "techmino": ("media", "parts", "Zframework", "conf.lua", "main.lua", "version.lua", "legals.md", "license.txt"),
    "techminoGalaxy": ("assets", "datatable", "Zenitha", "ZTC", "conf.lua", "main.lua", "shell.lua", "version.lua"),
}


def fail(message):
    raise SystemExit("::error::" + message)


def prepare_lovejs(staging):
    # The npm 11.4.1 release has older runtime bytes; this revision's package
    # version is also 11.4.1, but its compiled LÖVE _version is actually 11.5.
    url = f"https://github.com/Davidobot/love.js/archive/{LOVEJS_REVISION}.tar.gz"
    with urllib.request.urlopen(url, timeout=60) as response:
        content = response.read(8 * 1024 * 1024 + 1)
    if len(content) > 8 * 1024 * 1024 or hashlib.sha256(content).hexdigest() != LOVEJS_ARCHIVE_SHA256:
        fail("Pinned love.js archive exceeds its bound or fails SHA-256 verification")
    archive_path = staging / "lovejs.tar.gz"
    archive_path.write_bytes(content)
    runtime = staging / "lovejs"
    with tarfile.open(archive_path, "r:gz") as archive:
        # Extract only the local packaging entry, its declared dependency lock,
        # and the exact compatibility runtime; never unpack samples or links.
        for relative in LOVEJS_FILES:
            try:
                member = archive.getmember(f"love.js-{LOVEJS_REVISION}/{relative}")
            except KeyError:
                fail(f"The pinned love.js archive is missing {relative}")
            if not member.isfile() or member.size > 8 * 1024 * 1024:
                fail(f"The pinned love.js source is not a bounded regular file: {relative}")
            destination = runtime / relative
            destination.parent.mkdir(parents=True, exist_ok=True)
            with archive.extractfile(member) as source, destination.open("wb") as target:
                shutil.copyfileobj(source, target)
    wasm = (runtime / "src/compat/love.wasm").read_bytes()
    if hashlib.sha256(wasm).hexdigest() != LOVEJS_COMPAT_WASM_SHA256 or b"11.5\x00love\x00_version\x00" not in wasm:
        fail("The pinned compatibility runtime is not the verified LÖVE 11.5 artifact")
    # Registry dependencies are locked upstream. Direct local execution needs
    # no remote npm package permission and cannot resolve the stale npm release.
    subprocess.run(["npm", "ci", "--omit=dev", "--ignore-scripts", "--no-audit", "--no-fund"], cwd=runtime, check=True)
    print(f"-- LÖVE 11.5 compatibility runtime: Davidobot/love.js@{LOVEJS_REVISION}, WASM SHA-256 {LOVEJS_COMPAT_WASM_SHA256}")
    return runtime / "index.js"


def fetch_bridge(name, destination):
    url = f"https://raw.githubusercontent.com/MrcSnm/Love.js-Api-Player/{BRIDGE_REVISION}/{name}"
    with urllib.request.urlopen(url, timeout=30) as response:
        content = response.read(1024 * 1024 + 1)
    if len(content) > 1024 * 1024:
        fail("Pinned browser bridge source exceeds its bound")
    destination.write_bytes(content)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--product", choices=tuple(BUILD_LISTS), required=True)
    parser.add_argument("--out", type=Path, required=True)
    parser.add_argument("--memory", type=int, default=128000000)
    args = parser.parse_args()
    root = Path.cwd().resolve()
    output = args.out.resolve()
    tooling = Path(__file__).resolve().parent
    framework = "Zframework" if args.product == "techmino" else "Zenitha"
    if not shutil.which("npm") or not shutil.which("node"):
        fail("Node.js and npm are required for the pinned local love.js compiler")
    if output.exists():
        fail(f"Refusing to overwrite an existing Web output directory: {output}")
    if not 16777216 <= args.memory <= 2147483648:
        fail("The Web memory allocation must be explicit and within the love.js heap bound")
    for relative in BUILD_LISTS[args.product]:
        if not (root / relative).exists():
            fail(f"Missing real game source or asset: {relative}")
    if not (root / framework / "transport.lua").is_file() or not (root / framework / "transport_web.js").is_file():
        fail("The maintained Lua/browser transport is missing from the game source")
    with tempfile.TemporaryDirectory(prefix="product-web-source-") as staging:
        staging = Path(staging)
        subprocess.run(["python3", str(tooling / "prepare_config.py"), args.product], cwd=staging, check=True)
        package = staging / "core.love"
        with zipfile.ZipFile(package, "w", compression=zipfile.ZIP_STORED) as archive:
            for relative in BUILD_LISTS[args.product]:
                source = root / relative
                if source.is_dir():
                    for path in sorted(source.rglob("*")):
                        if path.is_file() and ".git" not in path.relative_to(root).parts:
                            archive.write(path, path.relative_to(root).as_posix())
                else:
                    archive.write(source, relative)
            if args.product == "techminoGalaxy":
                banks = root / "soundbank"
                if banks.is_dir():
                    for path in sorted(banks.rglob("*")):
                        if path.is_file():
                            archive.write(path, path.relative_to(root).as_posix())
                else:
                    # The existing Galaxy Web source explicitly skips FMOD. Do not invent banks.
                    print("-- Galaxy Web keeps its existing source-defined FMOD-disabled behavior; no soundbank was fabricated")
            archive.write(staging / "online-config.json", "online-config.json")
        if package.stat().st_size >= args.memory:
            fail("The real source package exceeds the configured Web heap; select an explicit larger --memory value")
        compiler = prepare_lovejs(staging)
        subprocess.run(["node", str(compiler), str(package), str(output), "-t", "Techmino" if args.product == "techmino" else "Techmino Galaxy", "-m", str(args.memory), "-c"], cwd=compiler.parent, check=True)
        for name in ("index.html", "love.wasm", "love.js", "game.js", "game.data"):
            if not (output / name).is_file():
                fail(f"The actual love.js compiler did not produce {name}")
        if hashlib.sha256((output / "love.wasm").read_bytes()).hexdigest() != LOVEJS_COMPAT_WASM_SHA256:
            fail("The Web compiler did not emit the pinned LÖVE 11.5 compatibility runtime")
        for name in ("consolewrapper.js", "webdb.js", "globalizeFS.js"):
            destination = output / ("globalizeFS.cjs" if name == "globalizeFS.js" else name)
            fetch_bridge(name, destination)
        subprocess.run(["node", "globalizeFS.cjs"], cwd=output, check=True)
        (output / "globalizeFS.cjs").unlink()
        index = output / "index.html"
        html = index.read_text(encoding="utf-8")
        if "</head>" not in html:
            fail("The pinned love.js output has no browser-bridge script insertion anchor")
        html = html.replace("</head>", '<script src="consolewrapper.js"></script>\n<script src="webdb.js"></script>\n</head>', 1)
        html = html.replace("32, 37, 38, 39, 40", "37, 38, 39, 40")
        index.write_text(html, encoding="utf-8")
        env = os.environ | {
            "TRANSPORT_WEB_SOURCE": str(root / framework / "transport_web.js"),
            "TRANSPORT_WEB_OUT": str(output),
            "TRANSPORT_WEB_CORE_PACKAGE": str(package),
            "GITHUB_WORKSPACE": str(root),
        }
        subprocess.run(["python3", str(tooling / "prepare_web.py")], cwd=root, env=env, check=True)
        shutil.copyfile(staging / "online-config.json", output / "online-config.json")
    print(f"-- Fresh source-backed Web runtime: {output / 'index.html'}")
    print("-- Serve this directory at its registered /play/ product URL; compilation does not establish browser acceptance")


if __name__ == "__main__":
    main()
