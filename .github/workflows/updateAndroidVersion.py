import re
import getVersion

versionCode, versionName = getVersion.getVersion()

with open("apk/apktool.yml", "r+") as file:
    data = file.read()
    data = re.sub("versionCode:.+", f"versionCode: '{versionCode}'", data)
    data = re.sub("versionName:.+", f"versionName: {versionName}", data)
    file.seek(0)
    file.truncate()
    file.write(data)