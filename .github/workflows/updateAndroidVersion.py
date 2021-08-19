import re, argparse

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="用于CI更新Android版本号")
    parser.add_argument("-C", "--Code", type=str, help = "versionCode")
    parser.add_argument("-N", "--Name", type=str, help = "versionName")
    args = parser.parse_args()

    with open("./love-android/app/build.gradle", "r+") as file:
        data = file.read()
        data = re.sub(r"\{\{versionCode\}\}", args.Code, data)
        data = re.sub(r"\{\{versionName\}\}", args.Name, data)
        file.seek(0)
        file.truncate()
        file.write(data)
