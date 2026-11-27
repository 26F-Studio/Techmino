#!/usr/bin/env python3
"""Install the transport bridge into love-android 11.5a before generating its love-patch."""

import argparse
from pathlib import Path
import re
import subprocess
import xml.etree.ElementTree as ET


UPSTREAM_COMMIT = "55feb38fa144f4734c26742389f279fb07d955c0"
PRODUCT_SCHEMES = {
    "techmino": "org.studio26f.techmino",
    "techminoGalaxy": "org.studio26f.techmino-galaxy",
}
ANDROID = "{http://schemas.android.com/apk/res/android}"
SOURCE = Path(__file__).resolve().parent / "android"


def replace_once(text, old, new, label):
    if text.count(new) == 1:
        if text.replace(new, old, 1).count(old) != 1:
            raise ValueError(f"Ambiguous already-installed {label}")
        return text
    if text.count(old) != 1:
        raise ValueError(f"Expected exactly one upstream {label}")
    return text.replace(old, new, 1)


def read_text(path):
    text = path.read_bytes().decode("utf-8")
    if "\r" in text:
        raise ValueError(f"Expected LF source: {path}")
    return text


def minimum_sdk(text, label):
    matches = list(re.finditer(r"(?m)^(\s*)minSdk ([0-9]+)$", text))
    if len(matches) != 1:
        raise ValueError(f"Expected exactly one minSdk in {label}")
    match = matches[0]
    if int(match.group(2)) >= 23:
        return text
    return text[:match.start()] + match.group(1) + "minSdk 23" + text[match.end():]


def keep_class(text):
    rule = "-keep class org.studio26.transport.SecureSession { *; }"
    if text.count(rule) > 1:
        raise ValueError("Duplicate secure-session JNI retention rule")
    if rule in text:
        return text
    if "org.studio26.transport" in text:
        raise ValueError("Conflicting secure-session JNI retention rules")
    return text.rstrip("\n") + "\n\n# Retain the JNI class and Rust-invoked Java methods.\n" + rule + "\n"


def install(root, product):
    head = subprocess.run(
        ["git", "-C", str(root), "rev-parse", "HEAD"],
        check=True, capture_output=True, text=True,
    ).stdout.strip()
    if head != UPSTREAM_COMMIT:
        raise ValueError(f"Expected love-android {UPSTREAM_COMMIT}, found {head}")
    scheme = PRODUCT_SCHEMES[product]
    changes = {}
    activity_path = root / "love/src/main/java/org/love2d/android/GameActivity.java"
    activity = read_text(activity_path)
    activity = replace_once(
        activity,
        "import org.libsdl.app.SDLActivity;\n",
        "import org.libsdl.app.SDLActivity;\nimport org.studio26.transport.SecureSession;\n",
        "SDL activity import",
    )
    activity = replace_once(
        activity,
        "        needToCopyGameInArchive = embed;\n\n        if (!embed) {\n",
        "        needToCopyGameInArchive = embed;\n\n"
        "        SecureSession.initialize(this);\n"
        "        boolean transportCallback = SecureSession.onIntent(getIntent());\n"
        "        if (!embed && !transportCallback) {\n",
        "cold-launch intent hook",
    )
    activity = replace_once(
        activity,
        "    protected void onNewIntent(Intent intent) {\n"
        "        Log.d(\"GameActivity\", \"onNewIntent() with \" + intent);\n",
        "    protected void onNewIntent(Intent intent) {\n"
        "        if (SecureSession.onIntent(intent)) {\n"
        "            return;\n"
        "        }\n"
        "        Log.d(\"GameActivity\", \"onNewIntent()\");\n",
        "warm-launch intent hook",
    )
    changes[activity_path] = activity

    for module in ("app", "love"):
        gradle_path = root / module / "build.gradle"
        changes[gradle_path] = minimum_sdk(read_text(gradle_path), str(gradle_path))
        rules_path = root / module / "proguard-rules.pro"
        changes[rules_path] = keep_class(read_text(rules_path))

    manifest_path = root / "app/src/main/AndroidManifest.xml"
    manifest = read_text(manifest_path)
    tree = ET.fromstring(manifest)
    applications = tree.findall("application")
    if len(applications) != 1:
        raise ValueError("Expected exactly one Android application")
    application = applications[0]
    activities = [item for item in application.findall("activity")
                  if item.get(ANDROID + "name") == "org.love2d.android.GameActivity"]
    if len(activities) != 1:
        raise ValueError("Expected the upstream GameActivity")
    registrations = [item for item in application.findall("meta-data")
                     if item.get(ANDROID + "name") == "org.studio26.transport.product"]
    if registrations and (len(registrations) != 1 or registrations[0].get(ANDROID + "value") != product):
        raise ValueError("Conflicting transport product registration")
    for key, expected in (("fullBackupContent", "@xml/transport_backup_rules"),
                          ("dataExtractionRules", "@xml/transport_data_extraction_rules")):
        existing = application.get(ANDROID + key)
        if existing is not None and existing != expected:
            raise ValueError(f"Conflicting Android {key} policy")
    callback_filters = (
        '      <intent-filter>\n'
        '        <action android:name="android.intent.action.VIEW" />\n'
        '        <category android:name="android.intent.category.DEFAULT" />\n'
        '        <category android:name="android.intent.category.BROWSABLE" />\n'
        '        <data android:scheme="' + scheme + '" />\n'
        '      </intent-filter>\n'
    )
    callback_registration_count = 0
    for item in activities[0].findall("intent-filter/data"):
        registered_scheme = item.get(ANDROID + "scheme")
        if registered_scheme in PRODUCT_SCHEMES.values() and (
                registered_scheme != scheme or item.get(ANDROID + "host") is not None):
            raise ValueError("Conflicting mobile callback intent filter")
        if registered_scheme in PRODUCT_SCHEMES.values():
            callback_registration_count += 1
    if callback_registration_count and (
            callback_registration_count != 1 or manifest.count(callback_filters) != 1):
        raise ValueError("Ambiguous existing mobile callback registration")
    manifest = replace_once(
        manifest,
        '      android:allowBackup="true"\n',
        '      android:allowBackup="true"\n'
        '      android:fullBackupContent="@xml/transport_backup_rules"\n'
        '      android:dataExtractionRules="@xml/transport_data_extraction_rules"\n',
        "application backup policy",
    )
    manifest = replace_once(
        manifest,
        "    <activity\n",
        '    <meta-data android:name="org.studio26.transport.product" android:value="' + product + '" />\n'
        "    <activity\n",
        "transport product metadata",
    )
    # Android ignores path matching without an authority. Register only the scheme;
    # SecureSession.onIntent and Rust enforce the complete single-slash callback URL.
    manifest = replace_once(
        manifest,
        "    </activity>\n",
        callback_filters +
        "    </activity>\n",
        "registered callback intent filter",
    )
    ET.fromstring(manifest)
    changes[manifest_path] = manifest

    copies = {
        root / "love/src/main/java/org/studio26/transport/SecureSession.java": SOURCE / "SecureSession.java",
        root / "app/src/main/res/xml/transport_backup_rules.xml": SOURCE / "transport_backup_rules.xml",
        root / "app/src/main/res/xml/transport_data_extraction_rules.xml": SOURCE / "transport_data_extraction_rules.xml",
    }
    for destination, source in copies.items():
        content = read_text(source)
        if destination.exists() and read_text(destination) != content:
            raise ValueError(f"Refusing to overwrite a different bridge file: {destination}")
        changes[destination] = content

    # Validate all anchors and destinations before changing the pinned upstream tree.
    for path, content in changes.items():
        if path.is_symlink() or not path.resolve().is_relative_to(root):
            raise ValueError(f"Refusing a destination outside the upstream tree: {path}")
    for path, content in changes.items():
        if path.exists() and read_text(path) == content:
            continue
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content, encoding="utf-8", newline="\n")
    print(f"Installed Android transport bridge for {product}: {scheme}:/callback (minSdk >= 23)")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", required=True, type=Path, help="Pinned love-android checkout, not a submodule")
    parser.add_argument("--product", required=True, choices=PRODUCT_SCHEMES)
    args = parser.parse_args()
    try:
        install(args.root.resolve(strict=True), args.product)
    except (OSError, ValueError, subprocess.CalledProcessError, ET.ParseError) as error:
        parser.exit(1, f"Android bridge preparation failed: {error}\n")


if __name__ == "__main__":
    main()
