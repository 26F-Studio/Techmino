import argparse

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="用于更新conf.lua内编译版本号")
    parser.add_argument("-H", "--Hash", type=str, help = "Github提交Hash")
    args = parser.parse_args()
    with open("conf.lua", "r+", encoding="utf-8") as file:
        data = file.read()
        data = data.replace('@DEV', f'@{args.Hash[0:4]}')
        file.seek(0)
        file.truncate()
        file.flush()
        file.write(data)