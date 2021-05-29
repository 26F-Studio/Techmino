import re
with open("conf.lua", "r") as file:
    data = file.read()
versionCode = re.search("build=(\\d+)", data).group(1)
versionName = re.search('short="([^"]+)', data).group(1)
with open("apk/apktool.yml", "r+") as file:
    data = file.read()
    data = re.sub("versionCode:.+", f"versionCode: '{versionCode}'", data)
    data = re.sub("versionName:.+", f"versionName: {versionName}", data)
    file.seek(0)
    file.truncate()
    file.write(data)
