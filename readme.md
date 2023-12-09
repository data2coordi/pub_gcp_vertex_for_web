
#!/bin/bash


source ./private/env.sh

rm -f ${BOARD5TMP_DIR}/${BOARD5TMP_FILE}

python ./board5_getWeb.py

gsutil cp ${BOARD5TMP_DIR}/${BOARD5TMP_FILE} ${BOARD5GCS_BUCKET}

bq mk -t --schema schema_5chboard.json \
--external_table_definition=${BOARD5GCS_BUCKET}/${BOARD5TMP_FILE}  \
ml_dataset.board5ch_ex

for ((i=0; i<5; i++))  do  
	bq query --use_legacy_sql=false   \
	 --parameter='mlimit:INT64:10' \
	 --parameter='request:STRING:以下はアーリーリタイアに関する掲示板の投稿です。次のどれかに分類してください。「節税」「生活費」「投資」「資産運用」「過ごし方」「リタイア成功の条件」「リタイアのリスク」「その他」「スパム」。また分類理由を記載してください。また「スパム」以外については要旨を記載してください。 \n 投稿:' \
	 --parameter='category:STRING:\n 分類: \n 分類理由: \n 要旨:' \
	  <board5_analyze.sql
done 

bq query --use_legacy_sql=false <board5_merge.sql

exit
exit
exit
exit
exit

# 機能概要

掲示板系WEBサイトにはすばらしい情報があるが、スパムやテーマとは無関係の投稿も存在し利用には時間コストを要する。
本システムは以下のような機能で問題を軽減することを目的としている。

掲示板系WEBサイトの投稿がスパムか判定する。

スパムでない場合は投稿を特定のカテゴリーで分類する。

それぞれの投稿を要約し読むべきか事前に短時間で判断できるようにする。

# 最終アウトプットのイメージ



# 全体構成

![全体概要](./BigqueryML_and_Python.jpg)

テクノロジーとしてはPython、Google CloudのGCS、Bigquery、Bigquery ML を利用している。




# 処理プロセス

### 処理コード全体（bashのスクリプト)
```
#!/bin/bash

source ./private/env.sh

rm -f ${BOARD5TMP_DIR}/${BOARD5TMP_FILE}

python ./board5_getWeb.py

gsutil cp ${BOARD5TMP_DIR}/${BOARD5TMP_FILE} ${BOARD5GCS_BUCKET}

bq mk -t --schema schema_5chboard.json \
--external_table_definition=${BOARD5GCS_BUCKET}/${BOARD5TMP_FILE}  \
ml_dataset.board5ch_ex

for ((i=0; i<5; i++))  do  
	bq query --use_legacy_sql=false   \
	 --parameter='mlimit:INT64:10' \
	 --parameter='request:STRING:以下はアーリーリタイアに関する掲示板の投稿です。次のどれかに分類してください。「節税」「生活費」「投資」「資産運用」「過ごし方」「リタイア成功の条件」「リタイアのリスク」「その他」「スパム」。また分類理由を記載してください。また「スパム」以外については要旨を記載してください。 \n 投稿:' \
	 --parameter='category:STRING:\n 分類: \n 分類理由: \n 要旨:' \
	  <board5_analyze.sql
done 

bq query --use_legacy_sql=false <board5_merge.sql

exit
```
※ 下記でそれぞれのコードを説明している。



### 環境変数の設定
セキュリティ、保守性を考慮し環境変数を外から読み込む。
以降で使用されている変数にはここで読み込んだ値が反映される。
```
source ./private/env.sh
```

### 事前のワークファイルの削除




```

rm -f ${BOARD5TMP_DIR}/${BOARD5TMP_FILE}
```





### 対象のデータをWEBサイトから収集して、ローカルのワークファイルに出力

```
python ./board5_getWeb.py
```
[WEBサイトからデータを取得しCSVを生成するプログラム:board5_getWeb.py](./board5_getWeb.py)






### 上記で取得したワークファイルをGCSにロード
```
gsutil cp ${BOARD5TMP_DIR}/${BOARD5TMP_FILE} ${BOARD5GCS_BUCKET}
```





### Bigqueryの外部データ連携機能でGCSのワークファイルを直接参照する外部テーブルを作成する。

下記のスキーマ情報から外部テーブルを作成する。
```
bq mk -t --schema schema_5chboard.json \
--external_table_definition=${BOARD5GCS_BUCKET}/${BOARD5TMP_FILE}  \
ml_dataset.board5ch_ex
```

[スキーマ情報:schema_5chboard.json](./schema_5chboard.json)








### Bigquery MLで 解析実行とワークテーブルに投入

```
bq query --use_legacy_sql=false 'delete from `ml_dataset.board5_analyze_tmp` where 1=1'

for ((i=0; i<5; i++))  do  
	bq query --use_legacy_sql=false   \
	 --parameter='mlimit:INT64:10' \
	 --parameter='request:STRING:以下はアーリーリタイアに関する掲示板の投稿です。次のどれかに分類してください。「節税」「生活費」「投資」「資産運用」「過ごし方」「リタイア成功の条件」「リタイアのリスク」「その他」「スパム」。また分類理由を記載してください。また「スパム」以外については要旨を記載してください。 \n 投稿:' \
	 --parameter='category:STRING:\n 分類: \n 分類理由: \n 要旨:' \
	  <board5_analyze.sql
done 
```






### 解析結果をテーブルにマージで投入or更新

```
bq query --use_legacy_sql=false <board5_merge.sql
```

[投入or更新をするMerge用SQL:board5_merge.sql](./board5_merge.sql)

解析後にマージ文で既に存在する場合は上書き、新規の場合は投入している。


# 環境セットアップ
Centos9にPythonの実行環境、GCPにBigquery MLの実行環境を構築する。
尚、Python、Google cloud sdk の基本的なセットアップは完了していることを前提としている。


### Setup Python virtul env 
```
cd ../env
python3.9 -m venv scraping
source ./scraping/bin/activate

pip install --upgrade pip
pip install  requests
pip install  bs4
pip install  pandas 
pip install  html5lib

deactivate

```

### Python debug

デバッグのコードも記載しておく

```
python -m pdb  exsample.py 
#p(変数)
#pp(変数)
#b ブレイクする行番号
#c #コンティニュー
#pp(article[5].prettify())

```



### Setup Bigquery for vertex

Connection を作成する
```
bq mk --connection \
    --location=${LOCATION} \
     --project_id=${PROJECT_ID} \
    --connection_type=CLOUD_RESOURCE ${CONNECTION_ID}
```

利用されるサービスアカウントの表示
```
bq show --connection ${PROJECT_ID}.${LOCATION}.${CONNECTION_ID}
```

サービスアカウントへの権限設定
```
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member="serviceAccount:${SERVICE_ACCOUNT_ID}" \
    --role="roles/aiplatform.user"
```

MLモデル作成

Bigqueryコンソールで実行
```
CREATE OR REPLACE MODEL ml_dataset.lang_model_v1
  REMOTE WITH CONNECTION `us-central1.con-pro-ml-for-bq`
  OPTIONS (remote_service_type = 'CLOUD_AI_LARGE_LANGUAGE_MODEL_V1');
```
