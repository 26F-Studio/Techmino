#!/usr/bin/env python3
"""Verify account-relative layout in the actual client with isolated saves."""
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

from cloud_restore import package_client


BOOTSTRAP = r"""
TASK.new(function()
    while not LOADED do coroutine.yield() end
    local ok,message=pcall(require'online_layout_regression')
    if ok then print('ONLINE_LAYOUT_PASS')
    else print('ONLINE_LAYOUT_FAIL '..tostring(message)) end
    love.event.quit(ok and 0 or 1)
end)
"""


def main():
    root = Path(__file__).resolve().parents[2]
    love = os.environ.get('LOVE_EXECUTABLE') or shutil.which('love')
    if not love:
        raise RuntimeError('The actual LÖVE runtime is required')
    launch = [love]
    if not os.environ.get('DISPLAY'):
        xvfb = shutil.which('xvfb-run')
        if not xvfb:
            raise RuntimeError('An active DISPLAY or xvfb-run is required')
        launch = [xvfb, '-a', love]
    with tempfile.TemporaryDirectory(prefix='techmino-online-layout-') as temporary:
        fixture = Path(temporary)
        package = fixture / 'client.love'
        package_client(root, package, bootstrap=BOOTSTRAP,
                       regression=Path(__file__).with_suffix('.lua'))
        environment = os.environ.copy()
        environment.update({
            'XDG_DATA_HOME': str(fixture / 'data'),
            'XDG_CONFIG_HOME': str(fixture / 'config'),
            'XDG_CACHE_HOME': str(fixture / 'cache'),
            'DBUS_SESSION_BUS_ADDRESS': 'unix:path=' + str(fixture / 'no-session-bus'),
        })
        result = subprocess.run(launch + [str(package)], cwd=root, env=environment,
                                stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                                text=True, timeout=90)
        if result.returncode or 'ONLINE_LAYOUT_PASS' not in result.stdout:
            sys.stderr.write(result.stdout[-12000:])
            raise RuntimeError(f'Online layout regression failed (exit {result.returncode})')
        for line in result.stdout.splitlines():
            if line.startswith('ONLINE_LAYOUT_'):
                print(line)


if __name__ == '__main__':
    try:
        main()
    except (OSError, RuntimeError, subprocess.TimeoutExpired) as error:
        print('FAIL: ' + str(error), file=sys.stderr)
        sys.exit(1)
