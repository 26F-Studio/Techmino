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
        else:
            data = data.replace('@DEV', '')
        file.seek(0)
        file.truncate()
        file.flush()
        file.write(data)

def updateMacOS(args):  #更新macOS打包信息
    import datetime
    thisYear = str(datetime.datetime.today().year)
    with open('./.github/build/macOS/info.plist.template', 'r', encoding='utf-8') as file:
        data = file.read()
        data = data\
            .replace('@versionName', args.Name)\
            .replace('@thisYear', thisYear)
    with open('./Techmino.app/Contents/info.plist', 'w+', encoding='utf-8') as file:
        file.write(data)

def updateIOS(args):  #更新macOS打包信息
    with open('./ios.app/info.plist', 'r', encoding='utf-8') as file:
        data = file.read()
        data = data.replace('0.16.1', args.Name)

    with open('./ios.app/info.plist', 'w+', encoding='utf-8') as file:
        file.write(data)

def updateWindows(args):    #更新Windows打包信息
    Version = (args.Name).replace('V', '')
    FileVersion = (f"{Version.replace('.', ',')},0")
    with open('./.github/build/Windows/Techmino.rc.template', 'r', encoding='utf8') as file:
        data = file.read()
        data = data\
            .replace('@FileVersion', FileVersion)\
            .replace('@Version', Version)
    with open('Techmino.rc', 'w+', encoding='utf8') as file:
        file.write(data)

def updateAndroid(args, edition):    #更新Android打包信息
    if edition == 'Release':
        appName = 'Techmino'
        packageName = 'org.love2d.MrZ.Techmino'
        edition = 'release'
    elif edition == 'Snapshot':
        appName = 'Techmino_Snapshot'
        packageName = 'org.love2d.MrZ.Techmino.Snapshot'
        edition = 'snapshot'
    with open('./love-android/app/src/main/AndroidManifest.xml', "r+", encoding='utf-8') as file:
        data = file.read()
        data = data\
            .replace('@appName', appName)\
            .replace('@edition', edition)
        file.seek(0)
        file.truncate()
        file.write(data)
    with open("./love-android/app/build.gradle", "r+", encoding='utf-8') as file:
        data = file.read()
        data = data\
            .replace('@packageName', packageName)\
            .replace('@versionCode', args.Code)\
            .replace('@versionName', args.Name)\
            .replace('@storePassword', args.Store)\
            .replace('@keyAlias', args.Alias)\
            .replace('@keyPassword', args.Key)
        file.seek(0)
        file.truncate()
        file.write(data)

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='用于CI更新程序各类信息')
    parser.add_argument('-T', '--Type', type=str, help = '更新的种类')
    parser.add_argument('-H', '--Hash', type=str, default = False, help = 'Github提交Hash')
    parser.add_argument('-C', '--Code', type=str, default = False, help = 'versionCode')
    parser.add_argument('-N', '--Name', type=str, default = False, help = 'versionName')
    parser.add_argument('-S', '--Store', type=str, default = False, help = 'storePassword')
    parser.add_argument('-A', '--Alias', type=str, default = False, help = 'keyAlias')
    parser.add_argument('-K', '--Key', type=str, default = False, help = 'keyPassword')
    args = parser.parse_args()
    if args.Type == 'Conf':
        updateConf()
    elif args.Type == 'Version':
        updateVersion(args)
    elif args.Type == 'Windows':
        updateWindows(args)
    elif args.Type == 'macOS':
        updateMacOS(args)
    elif args.Type == 'iOS':
        updateIOS(args)
    elif args.Type == 'AndroidRelease':
        updateAndroid(args, 'Release')
    elif args.Type == 'AndroidSnapshot':
        updateAndroid(args, 'Snapshot')
