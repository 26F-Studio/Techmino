#!/usr/bin/env python3
"""Write public, credential-free endpoints into the game source package."""
import json
import os
import sys
from pathlib import Path
from urllib.parse import urlsplit


def fail(message):
    raise SystemExit("::error::" + message)


def origin(name, value):
    if not value:
        fail(f"{name} is required; configure the repository's public-origin variable before packaging online clients")
    try:
        parsed = urlsplit(value)
        port = parsed.port
    except ValueError:
        fail(f"{name} is not a valid origin")
    if parsed.scheme != "https" or not parsed.hostname or parsed.username or parsed.password or parsed.path not in ("", "/") or parsed.query or parsed.fragment:
        fail(f"{name} must be an exact HTTPS origin without credentials, path, query or fragment")
    if any(character.isspace() for character in value) or (port is not None and not 1 <= port <= 65535):
        fail(f"{name} is not a valid public origin")
    return value.rstrip("/")


def main():
    if len(sys.argv) != 2 or sys.argv[1] not in ("techmino", "techminoGalaxy"):
        fail("prepare_config.py requires the fixed product ID")
    product = sys.argv[1]
    public = origin("PUBLIC_ORIGIN", os.environ.get("PUBLIC_ORIGIN", ""))
    cadence = origin("CADENCE_PUBLIC_ORIGIN", os.environ.get("CADENCE_PUBLIC_ORIGIN", ""))
    tessera = origin("TESSERA_PUBLIC_ORIGIN", os.environ.get("TESSERA_PUBLIC_ORIGIN") or public)
    redirect = os.environ.get("GAME_WEB_REDIRECT_URI") or public + ("/play/techmino/" if product == "techmino" else "/play/techmino-galaxy/")
    parsed = urlsplit(redirect)
    if parsed.scheme != "https" or not parsed.hostname or parsed.username or parsed.password or parsed.query or parsed.fragment or not parsed.path:
        fail("GAME_WEB_REDIRECT_URI must be the registered exact HTTPS game URL, without credentials, query or fragment")
    # A separately hosted Web build must register this exact URL in Tessera.
    settings = {"tesseraOrigin": tessera, "cadenceOrigin": cadence, "websiteOrigin": public, "webRedirectUri": redirect}
    Path("online-config.json").write_text(json.dumps(settings, indent=2) + "\n", encoding="utf-8")
    print(f"-- configured {product} package public endpoints; no credentials are included")


if __name__ == "__main__":
    main()
