#!/usr/bin/env python3
"""Keep AppImage libraries out of the external system browser process."""

import argparse
from pathlib import Path


LAUNCHER_ENV = '''export LOVE_HOST_PATH="$PATH"
export LOVE_HOST_LD_LIBRARY_PATH="${LD_LIBRARY_PATH-}"
export PATH="$APPDIR/bin:$PATH"
'''

OPENER = '''#!/bin/sh
# Restore the environment captured before AppRun added its bundled libraries.
export PATH="${LOVE_HOST_PATH:?AppRun did not capture the system PATH}"
if [ -n "${LOVE_HOST_LD_LIBRARY_PATH-}" ]; then
    export LD_LIBRARY_PATH="$LOVE_HOST_LD_LIBRARY_PATH"
else
    unset LD_LIBRARY_PATH
fi
unset LOVE_HOST_PATH LOVE_HOST_LD_LIBRARY_PATH
exec xdg-open "$@"
'''


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("appdir", type=Path)
    args = parser.parse_args()
    launcher = args.appdir / "AppRun"
    opener = args.appdir / "bin" / "xdg-open"
    source = launcher.read_text(encoding="utf-8")
    marker = 'export LD_LIBRARY_PATH="$APPDIR/lib/:$LD_LIBRARY_PATH"'
    if source.count(marker) != 1 or "LOVE_HOST_PATH" in source:
        parser.error("expected a fresh LÖVE 11.5 AppRun library environment")
    if opener.exists():
        parser.error("refusing to replace an existing packaged xdg-open")
    opener.write_text(OPENER, encoding="utf-8")
    opener.chmod(0o755)
    launcher.write_text(source.replace(marker, LAUNCHER_ENV + marker), encoding="utf-8")
    print("Prepared AppImage system-browser environment; rebuild AppImage and Debian artifacts.")


if __name__ == "__main__":
    main()
