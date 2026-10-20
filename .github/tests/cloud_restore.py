#!/usr/bin/env python3
"""Run the actual client twice against an isolated LÖVE save directory.

From the Techmino checkout: python3 .github/tests/cloud_restore.py
No service credentials, auth substitutes, source mutations or user saves are used.
"""
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import zipfile


BOOTSTRAP = r"""
TASK.new(function()
    while not LOADED do coroutine.yield() end
    local phase=os.getenv('TECHMINO_CLOUD_RESTORE_PHASE')
    local ok,message=pcall(function() require'cloud_restore_regression'(phase) end)
    if ok then print('CLOUD_RESTORE_PASS '..phase)
    else print('CLOUD_RESTORE_FAIL '..tostring(message)) end
    love.event.quit(ok and 0 or 1)
end)
"""

CONF = r"""
local configure=love.conf
function love.conf(t)
    configure(t)
    t.identity='Techmino_CloudRestoreRegression'
end
"""


def package_client(root, destination):
    with zipfile.ZipFile(destination, 'w', compression=zipfile.ZIP_STORED) as archive:
        for directory in ('media', 'parts', 'Zframework'):
            source = root / directory
            if not source.is_dir():
                raise RuntimeError(f'Missing real client sources or resources: {directory}')
            for path in sorted(source.rglob('*')):
                relative = path.relative_to(root)
                if path.is_file() and '.git' not in relative.parts and '__pycache__' not in relative.parts:
                    archive.write(path, relative.as_posix())
        for name in ('version.lua', 'legals.md', 'license.txt'):
            archive.write(root / name, name)
        if (root / 'online-config.json').is_file():
            archive.write(root / 'online-config.json', 'online-config.json')
        archive.writestr('main.lua', (root / 'main.lua').read_text() + BOOTSTRAP)
        archive.writestr('conf.lua', (root / 'conf.lua').read_text() + CONF)
        archive.write(Path(__file__).with_suffix('.lua'), 'cloud_restore_regression.lua')


def main():
    root = Path(__file__).resolve().parents[2]
    love = shutil.which('love')
    if love is None:
        raise RuntimeError('The actual LÖVE runtime is required')
    launch = [love]
    if not os.environ.get('DISPLAY'):
        xvfb = shutil.which('xvfb-run')
        if xvfb is None:
            raise RuntimeError('An active DISPLAY or xvfb-run is required for the actual client')
        launch = [xvfb, '-a', love]
    with tempfile.TemporaryDirectory(prefix='techmino-cloud-restore-') as temporary:
        fixture = Path(temporary)
        package = fixture / 'client.love'
        package_client(root, package)
        environment = os.environ.copy()
        environment.update({
            'XDG_DATA_HOME': str(fixture / 'data'),
            'XDG_CONFIG_HOME': str(fixture / 'config'),
            'XDG_CACHE_HOME': str(fixture / 'cache'),
            'DBUS_SESSION_BUS_ADDRESS': 'unix:path=' + str(fixture / 'no-session-bus'),
        })
        for phase in ('restore', 'reload'):
            environment['TECHMINO_CLOUD_RESTORE_PHASE'] = phase
            result = subprocess.run(launch + [str(package)], cwd=root, env=environment,
                                    stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                                    text=True, timeout=90)
            marker = 'CLOUD_RESTORE_PASS ' + phase
            if result.returncode or marker not in result.stdout:
                sys.stderr.write(result.stdout[-12000:])
                raise RuntimeError(f'The actual client {phase} phase failed (exit {result.returncode})')
            print(marker)
    print('PASS: partial cloud restore survives a fresh client reload without losing omitted local values')


if __name__ == '__main__':
    try:
        main()
    except (OSError, RuntimeError, subprocess.TimeoutExpired) as error:
        print('FAIL: ' + str(error), file=sys.stderr)
        sys.exit(1)
