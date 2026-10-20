#!/usr/bin/env python3
"""Install callbacks and static FFI exports after existing patches on the pinned LÖVE iOS tree."""

import argparse
from pathlib import Path
import plistlib
import re
import subprocess


UPSTREAM_COMMIT = "c35356c841976eb6f370347b81eec845d5520338"
PRODUCT_SCHEMES = {
    "techmino": "org.studio26f.techmino",
    "techminoGalaxy": "org.studio26f.techmino-galaxy",
}
SOURCE = Path(__file__).resolve().parent / "ios/transport_ios.mm"
CONFIGURATIONS = (
    ("FA0B7F261A95AAF4000E1D17", "Debug"),
    ("FA0B7F271A95AAF4000E1D17", "Release"),
    ("FA0B7F281A95AAF4000E1D17", "Distribution"),
)
SYMBOLS = (
    "tn_client_new", "tn_client_destroy", "tn_command", "tn_poll",
    "tn_secret", "tn_random", "tn_pkce", "tn_callback_begin", "tn_mobile_callback",
)


def read_text(path):
    text = path.read_bytes().decode("utf-8")
    if "\r" in text:
        raise ValueError(f"Expected LF source: {path}")
    return text


def replace_once(text, old, new, label):
    if text.count(new) == 1:
        if text.replace(new, old, 1).count(old) != 1:
            raise ValueError(f"Ambiguous already-installed {label}")
        return text
    if text.count(old) != 1:
        raise ValueError(f"Expected exactly one upstream {label}")
    return text.replace(old, new, 1)


def linker_settings(project):
    flags = [
        "$(inherited)", "-ObjC", "-force_load", "$(PROJECT_DIR)/libtechmino_transport.a", "-Wl,-export_dynamic",
        *[f"-Wl,-u,_{symbol}" for symbol in SYMBOLS],
        "-framework", "Security", "-framework", "CoreFoundation",
    ]
    additions = "\t\t\t\tOTHER_LDFLAGS = (\n" + "".join(
        f'\t\t\t\t\t"{flag}",\n' for flag in flags
    ) + '\t\t\t\t);\n\t\t\t\tSTRIP_STYLE = "non-global";\n'
    # These are the actual love-ios Debug/Release/Distribution target configurations,
    # not global project settings or the unrelated macOS target.
    for identifier, name in CONFIGURATIONS:
        pattern = re.compile(
            r"(?m)^\t\t" + identifier + r" /\* " + name + r" \*/ = \{\n.*?^\t\t\};\n",
            re.DOTALL,
        )
        matches = list(pattern.finditer(project))
        if len(matches) != 1:
            raise ValueError(f"Expected the pinned love-ios {name} configuration")
        match = matches[0]
        block = match.group(0)
        anchor = '\t\t\t\tINFOPLIST_FILE = "$(SRCROOT)/ios/love-ios.plist";\n'
        if block.count(additions) == 1:
            if block.count("OTHER_LDFLAGS =") != 1 or block.count("STRIP_STYLE =") != 1:
                raise ValueError(f"Ambiguous transport linker settings in {name}")
        else:
            if "OTHER_LDFLAGS =" in block or "STRIP_STYLE =" in block:
                raise ValueError(f"Conflicting transport linker settings in {name}")
            block = replace_once(block, anchor, anchor + additions, f"{name} Info.plist setting")
        if block.count(anchor) != 1:
            raise ValueError(f"Changed love-ios Info.plist in {name}")
        project = project[:match.start()] + block + project[match.end():]
    return project


def install(root, product):
    head = subprocess.run(
        ["git", "-C", str(root), "rev-parse", "HEAD"],
        check=True, capture_output=True, text=True,
    ).stdout.strip()
    if head != UPSTREAM_COMMIT:
        raise ValueError(f"Expected love2d/love {UPSTREAM_COMMIT}, found {head}")
    scheme = PRODUCT_SCHEMES[product]
    changes = {}

    # ios.mm is already built into liblove-ios. Including here preserves love.cpp,
    # CCloader initialization, vibration and all other pre-applied upstream patches.
    ios_path = root / "src/common/ios.mm"
    ios = read_text(ios_path)
    if ios.count("#ifdef LOVE_IOS") != 1:
        raise ValueError("Expected the upstream LOVE_IOS source guard")
    changes[ios_path] = replace_once(
        ios,
        "#include <SDL_syswm.h>\n",
        '#include <SDL_syswm.h>\n\n#include "transport_ios.mm"\n',
        "iOS SDL includes",
    )
    bridge_path = root / "src/common/transport_ios.mm"
    bridge = read_text(SOURCE)
    if bridge_path.exists() and read_text(bridge_path) != bridge:
        raise ValueError("Refusing to overwrite a different iOS bridge")
    changes[bridge_path] = bridge

    plist_path = root / "platform/xcode/ios/love-ios.plist"
    info = plistlib.loads(plist_path.read_bytes())
    if not isinstance(info, dict) or "UIApplicationSceneManifest" in info:
        raise ValueError("Expected the pinned SDL UIApplication (not UIScene) Info.plist")
    registration = info.get("Studio26TransportProduct")
    if registration is not None and registration != product:
        raise ValueError("Conflicting iOS transport product registration")
    info["Studio26TransportProduct"] = product
    url_types = info.get("CFBundleURLTypes", [])
    if not isinstance(url_types, list):
        raise ValueError("Invalid iOS CFBundleURLTypes")
    expected = {
        "CFBundleTypeRole": "Editor",
        "CFBundleURLName": scheme + ".session",
        "CFBundleURLSchemes": [scheme],
    }
    registered = []
    for url_type in url_types:
        if not isinstance(url_type, dict):
            raise ValueError("Invalid iOS URL type")
        schemes = url_type.get("CFBundleURLSchemes", [])
        if not isinstance(schemes, list):
            raise ValueError("Invalid iOS URL schemes")
        if any(value in PRODUCT_SCHEMES.values() for value in schemes):
            registered.append(url_type)
    if registered:
        if registered != [expected]:
            raise ValueError("Conflicting iOS mobile callback URL type")
    else:
        url_types.append(expected)
    info["CFBundleURLTypes"] = url_types
    changes[plist_path] = plistlib.dumps(info, sort_keys=False).decode("utf-8")

    project_path = root / "platform/xcode/love.xcodeproj/project.pbxproj"
    changes[project_path] = linker_settings(read_text(project_path))

    # Validate every destination before writing; no dependency download or .git changes.
    for path in changes:
        if path.is_symlink() or not path.resolve().is_relative_to(root):
            raise ValueError(f"Refusing a destination outside the upstream tree: {path}")
    for path, content in changes.items():
        if path.exists() and read_text(path) == content:
            continue
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content, encoding="utf-8", newline="\n")
    print(f"Installed iOS transport bridge for {product}: {scheme}:/callback; exporting all {len(SYMBOLS)} tn symbols")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", required=True, type=Path, help="Pinned love2d/love checkout after existing patches")
    parser.add_argument("--product", required=True, choices=PRODUCT_SCHEMES)
    args = parser.parse_args()
    try:
        install(args.root.resolve(strict=True), args.product)
    except (OSError, ValueError, subprocess.CalledProcessError, plistlib.InvalidFileException) as error:
        parser.exit(1, f"iOS bridge preparation failed: {error}\n")


if __name__ == "__main__":
    main()
