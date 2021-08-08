import os
import getVersion

versionCode, versionName = getVersion.getVersion()

os.system(f'echo Version={versionName} >> $env:GITHUB_ENV')