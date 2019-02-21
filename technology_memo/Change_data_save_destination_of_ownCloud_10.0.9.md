---
layout: default
title: ownCloud10.0.9のデータ保存先変更
---

# ownCloud10.0.9のデータ保存先変更

## 概要

Ubuntu16.04 LTSでowncloud10.0.9にて
今までデフォルトである、[/var/www/owncloud/data/]配下に
データを格納してましたが、写真をアップロードしようとしたところ、
空き容量不足でアップロードできないとメッセージが...。

空き容量を確認すると[/]が既に85%に...(・。・;

急遽、格納先の変更を検討せねば。
ちょろっとググって保存先を変更しましたというだけの記事ですけど。

## ownCloudの保存先変更

ownCloudの設定ファイルを修正

```
vi /var/www/owncloud/config/config.php
```
修正箇所は以下となる。

'datadirectory' => '/var/www/owncloud/data',
↓
'datadirectory' => '/share/owncloud/data',

'installed' => true,
↓
'installed' => false,


## ownCloudの保存先ディレクトリの作成

```
mkdir -m 755 /share/owncloud/data
sudo chown www-data:www-data /share/owncloud/data
```

## 端末からブラウザでアクセスし初期セットアップを実施

初期セットアップ方法については、省略
※初期セットアップなしでも保存先変更なんてできそうだが
データ再読込コマンドを実行しても古いフォルダを参照してしまうため。

## データ移行

[/var/www/owncloud/data]配下のデータを[/share/owncloud/data]に移動。

```
sudo cp -R /var/www/owncloud/data /share/owncloud/data
sudo rm -rf /var/www/owncloud/data
sudo chown -R apache:apache /share/owncloud/data
sudo chmod -R 755 /share/owncloud/data
```

## ownCloudに再読込を手動実行

```
sudo -u www-data php /var/www/owncloud/occ files:scan <owncloud user name>

Scanning files for 1 users
Starting scan for user 1 out of 1 (<owncloud user name>)

+---------+-------+--------------+
| Folders | Files | Elapsed time |
+---------+-------+--------------+
| 91      | 5885  | 00:00:21     |
+---------+-------+--------------+
```
う～ん、ファイルスキャン早いのはいいけど
owncloud上のタイムスタンプも更新されちゃうんだね...。って当たり前かw
 
