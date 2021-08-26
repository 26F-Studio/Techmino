import requests
import time
import json
import argparse

def getColdClear(pre):
    while True:
        get = requests.get('https://api.github.com/repos/26F-Studio/cold_clear_ai_love2d_wrapper/releases')
        if get.status_code != 200:
            time.sleep(2)
        else:
            break
    getJson = json.loads(get.text)
    if pre:
        print (getJson[0]['tag_name'])
    else:
        for i in getJson:
            if i['prerelease'] == pre:
                print (i['tag_name'])
                break

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='用于获取CC的Release版本名')
    parser.add_argument('-P', '--Pre', action='store_true', help = '是否获取pre')
    args = parser.parse_args()
    getColdClear(args.Pre)