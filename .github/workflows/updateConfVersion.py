import argparse

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="用于更新conf.lua")
    parser.add_argument("-H", "--Hash", type=str, default = False, help = "Github提交Hash")
    args = parser.parse_args()
    with open("conf.lua", "r+", encoding="utf-8") as file:
        data = file.read()
        if args.Hash != False:
            data = data.replace('@DEV', f'@{args.Hash[0:4]}')
        else:
            data = data.replace('@DEV', '')
        file.seek(0)
        file.truncate()
        file.flush()
        file.write(data)