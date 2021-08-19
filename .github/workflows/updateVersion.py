import argparse

def updateConf():   #更新存档位置
    with open('conf.lua', 'r+', encoding='utf-8') as file:
        data = file.read()
        data = data.replace("t.identity='Techmino'--Saving folder", "t.identity='Techmino_Snapshot'--Saving folder")
        file.seek(0)
        file.truncate()
        file.flush()
        file.write(data)

def updateVersion(args):    #更新版本号
    with open('version.lua', 'r+', encoding='utf-8') as file:
        data = file.read()
        if args.Hash != False:
            data = data.replace('@DEV', f'@{args.Hash[0:4]}')
            updateConf()
        else:
            data = data.replace('@DEV', '')
        file.seek(0)
        file.truncate()
        file.flush()
        file.write(data)

def updateMacOS(args):  #更新macOS打包信息
    import datetime
    with open('./build/macOS/info.plist.template', 'r', encoding='utf-8') as template:
        template = ((template.read()).replace('@versionName', args.Name)).replace('@ThisYear', str(datetime.datetime.today().year))
        with open('./Techmino.app/Contents/info.plist', 'w+', encoding='utf-8') as file:
            file.write(template)

def updateWindows(args):    #更新Windows打包信息
    Version = (args.Name).replace('V', '')
    FileVersion = (f"{Version.replace('.', ',')},0")
    with open('./build/Windows/Techmino.rc.templace', 'r', encoding='utf8') as templace:
        template = ((templace.read()).replace('@FileVersion', FileVersion)).replace('@Version', Version)
        with open('Techmino.rc', 'w+', encoding='utf8') as file:
            file.write(template)

def updateAndroid(args):    #更新Android打包信息
    import re
    with open('./apk/apktool.yml', 'r+', encoding='utf-8') as file:
        data = file.read()
        data = re.sub("versionCode:.+", f"versionCode: '{args.Code}'", data)
        data = re.sub("versionName:.+", f"versionName: '{args.Name}'", data)
        file.seek(0)
        file.truncate()
        file.write(data)

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='用于CI更新程序各类信息')
    parser.add_argument('-T', '--Type', type=str, help = '更新的种类')
    parser.add_argument('-H', '--Hash', type=str, default = False, help = 'Github提交Hash')
    parser.add_argument('-C', '--Code', type=str, default = False, help = 'versionCode')
    parser.add_argument('-N', '--Name', type=str, default = False, help = 'versionName')
    args = parser.parse_args()
    if args.Type == 'Conf':
        updateConf()
    elif args.Type == 'Version':
        updateVersion(args)
    elif args.Type == 'Windows':
        updateWindows(args)
    elif args.Type == 'macOS':
        updateMacOS(args)
    elif args.Type == 'Android':
        updateAndroid(args)