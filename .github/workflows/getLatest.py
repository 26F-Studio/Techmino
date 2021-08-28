import requests
import time
import json
import argparse

def getColdClear(args):
    while True:
        get = requests.get(f'https://api.github.com/repos/{args.Repo}/releases')
        if get.status_code != 200:
            time.sleep(2)
        else:
            break
    getJson = json.loads(get.text)
    if args.Pre:
        print (getJson[0]['tag_name'])
    else:
        for i in getJson:
            if i['prerelease'] == args.Pre:
                print (i['tag_name'])
                break

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='用于获取Github仓库的最新Release版本名')
    parser.add_argument('-P', '--Pre', action='store_true', help = '是否获取pre')
    parser.add_argument('-R', '--Repo', default = '26F-Studio/cold_clear_ai_love2d_wrapper', help = '获取的仓库, 默认为cold_clear_ai_love2d_wrapper, 输入格式为User/Repo')
    args = parser.parse_args()
    getColdClear(args)
