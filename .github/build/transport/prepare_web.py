#!/usr/bin/env python3
"""Package the browser transport into a love.js output tree.

The framework browser transport (Zframework/transport_web.js or
Zenitha/transport_web.js) is copied to the web product root and loaded before
every other startup script so it can observe the authorization callback on the
registered game root and hand it back to the game. The file is also part of the
core package through the framework whitelist; this step makes it a first-class
page script.

Missing framework sources abort the build instead of shipping a web package
whose browser transport silently never loads.
"""

import os
import shutil
import sys
from pathlib import Path

SCRIPT_NAME = "transport_web.js"


def fail(message: str) -> "None":
    print(f"::error::{message}", file=sys.stderr)
    sys.exit(1)


def main() -> None:
    workspace = Path(os.environ.get("GITHUB_WORKSPACE") or os.getcwd())
    source = Path(os.environ.get("TRANSPORT_WEB_SOURCE", "Zframework/transport_web.js"))
    out = Path(os.environ.get("TRANSPORT_WEB_OUT", "build"))

    if not source.is_file():
        fail(
            f"browser transport source {source} is missing; the framework wrapper must exist "
            "before a web package is shipped (expected transport_web.js in the packaged framework directory)"
        )

    index = out / "index.html"
    if not index.is_file():
        fail(f"web output {index} is missing; love.js must produce index.html before the transport is injected")

    script_name = os.environ.get("TRANSPORT_WEB_SCRIPT", SCRIPT_NAME)
    shutil.copyfile(source, out / script_name)

    html = index.read_text(encoding="utf-8")
    if script_name in html:
        fail(f"{index} already loads {script_name}; refusing to inject it twice")
    script_tag = f'<script src="{script_name}"></script>'
    anchor = html.find("<script")
    if anchor == -1:
        head_end = html.find("</head>")
        if head_end == -1:
            fail(f"{index} has no <script> or </head> anchor to inject the browser transport before game startup")
        anchor = head_end
    html = html[:anchor] + script_tag + "\n" + html[anchor:]

    index.write_text(html, encoding="utf-8")
    first_script = html.find("<script")
    if html[first_script:first_script + len(script_tag)] != script_tag:
        fail(f"{script_name} must be the first script in {index} so the callback is observed before game startup")

    core_package = os.environ.get("TRANSPORT_WEB_CORE_PACKAGE", "").strip()
    if core_package:
        import zipfile

        if not Path(core_package).is_file():
            fail(f"core package {core_package} is missing; the browser transport must ship inside the game package too")
        try:
            packaged_path = source.resolve().relative_to(workspace.resolve()).as_posix()
        except ValueError:
            packaged_path = source.as_posix()
        with zipfile.ZipFile(core_package) as handle:
            names = [name.replace("\\", "/") for name in handle.namelist()]
        if not any(name.endswith(packaged_path) or name.endswith("./" + packaged_path) for name in names):
            fail(
                f"{core_package} does not contain the framework browser transport {packaged_path}; "
                "the packaged framework must include the transport wrapper"
            )
        print(f"-- {core_package} carries the framework browser transport {packaged_path}")

    print(f"-- {script_name} copied to {out / script_name} and loaded first in {index}")


if __name__ == "__main__":
    main()
