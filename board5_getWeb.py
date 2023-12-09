import sys
sys.path.append("lib.bs4")

import os
import re
import requests, bs4
from datetime import datetime
import pandas as pd
import html5lib
import csv
import json
import hashlib


# work

wfilename=os.environ['BOARD5TMP_DIR'] + '/' + os.environ['BOARD5TMP_FILE']
wf= open(wfilename, 'w') 
writer = csv.writer(wf)


rfilename=os.environ['BOARD5URLLIST']
f = open(rfilename, 'r') #URLリストを読み込む
url=f.readline()
url=url.replace('\n', '')
print(url)

while url:
    # txtファイルに記録されている1行目のURLのページを取得する
     res = requests.get(url)

     # デコード
     scanned_text = res.content[:1024].decode('ascii', errors='replace')
     match = re.search(r'charset=["\']?([\w-]+)', scanned_text)
     if match:
         res.encoding = match.group(1)
     else:
         res.encoding = 'utf-8'

     # HTMLを抽出する
     soup = bs4.BeautifulSoup(res.text, "html5lib")  # 2chではhtml5libを使用
     articles = soup.select("article")
     title=soup.select("title")[0].string.replace('\n', '')

     titleid=int(hashlib.sha256(title.encode()).hexdigest(), 16)%1000
     print(titleid)

     for  article in articles:
        art_id     =article.details.summary.span.text
        art_date_str   =article.details.select("span.date")[0].string

        art_date_str = re.sub(r'\(\w+\)', '', art_date_str)
        art_date_date = datetime.strptime(art_date_str, "%Y/%m/%d %H:%M:%S.%f")
        art_date = art_date_date.strftime("%Y-%m-%d %H:%M:%S")

        art_comment=article.section.text
        category=""
        summary=""
        
        csv_format=[titleid,title, url, art_id, art_date, art_comment,category,category,category,summary]
        writer.writerow(csv_format)

     url = f.readline()
     url=url.replace('\n', '')

wf.close()

print("end")

quit()
