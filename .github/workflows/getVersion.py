import re
def getVersion():
    with open("conf.lua", "r", encoding="utf-8") as file:
        data = file.read()
    versionCode = re.search("build=(\\d+)", data).group()
    versionName = re.search('(?<=string=").*(?=@)', data).group()
    return versionCode, versionName

if __name__ == "__main__":
    versionCode, versionName = getVersion()
    print (versionName)