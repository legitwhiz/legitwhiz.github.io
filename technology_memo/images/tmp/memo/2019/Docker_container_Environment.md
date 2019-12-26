---
layout: default
title: Dockerでコンテナ環境簡単構築
---

# Dockerでコンテナ環境簡単構築

## 1. Dockerとは？

### 1.1. Dockerとは？
DockerでGitbucketやjenkinsを簡単に導入しDevOps環境を構築するため、今まで手つかずであったDockerを導入してみました。

まず、Dockerとは、インフラ関係やDevOps界隈で注目されている技術の一つで、コンテナ型の仮想環境を作成、配布、実行するためのプラットフォームです。
コンテナ型の仮想環境は、

仮想マシンでは、ホストマシン上でハイパーバイザを利用しゲストOSを動かし、その上でミドルウェアなどを動かしますますが、Dockerのコンテナはホストマシンのカーネルを利用し、プロセスやユーザなどを隔離することで、あたかも別のマシンが動いているかのように動かすことができます。

ハイパーバイザ、ゲストOSは必要ないため、軽量で高速に起動、停止などが可能となっています。

最初は、DockerのLinuxコンテナを使った軽量なアプリケーション実行環境でしたが
「Docker for Windows」「Docker for Mac」などもリリースされており
気軽にコンテナ環境を構築することが出来るようになっているようです。

### 1.2. Dockerイメージとは？

Dockerではアプリケーションと実行環境をまとめてパッケージ化したものをDockerイメージと言い、それをリポジトリで公開・配布しているものを利用することで簡単に環境を構築可能としている。また、自分の使いやすい実行環境を自分で構築し、イメージ化することも可能となる。


Dockerイメージは、イメージファイルの互換性が高く、どこのDockerホスト上でも動作できることが強みだそうです。

Dockerイメージには、アプリケーションと実行環境をまとめてパッケージ化するのが一般的ですが、中にはOSや言語環境、フレームワーク等の環境もあるので、まずなにかやってみたいと思った時にDockerイメージがあればそこから始めるのも一つの手段としていいだろう。

[Docker社の認定Dockerイメージ](<https://github.com/docker-library/official-images/tree/master/library> )




## 2.Docker環境の構築

何はともあれ、まず手を動かして構築したみたいと思います。

### 2.1.環境

今回、用意した環境は以下となります。

CentOS : 7.5.1804
Docker : 18.09.0, build 4d60db4
Docker-compose : 1.23.2, build 1110ad01
※Dockerには、[Docker CE]とエンタープライズ版の[Docker EE]がありますが、今回は無償の[Docer CE]を使用します。

### 2.2. Docker CEのインストール

前提パッケージの確認[](yum-config-managerの前提)

```
# yum list installed lvm2 yum-utils yum-utils device-mapper-persistent-data
```

入ってなければ前提パッケージをインストールして下さい。

```
# yum install -y yum-utils device-mapper-persistent-data lvm2
```

古いバージョンのDockerがインストールされている場合はアンインストール

```
# yum remove docker docker-common docker-selinux docker-engine
```

リポジトリを追加します

```
# yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
```

Docker CEをインストールします

```
# yum install docker-ce -y 
```

自動起動を有効化します

```
# systemctl enable docker
```

Dockerを起動します

```
# systemctl start docker
```

sudoなしでDockerを実行するため、ユーザーをDockerグループに追加します

```
# usermod -aG docker $USER
```

ただし、セキュリティが弱くなりますので注意して下さい。



### 2.3. Docker-composeのインストール

docker-composeを使うと、複数のコンテナから構成されるサービスを従来よりも簡単に管理できるようになります。※docker imageをまとめて起動とかできるようにするため

docker-composeのインストール

```
# curl -L https://github.com/docker/compose/releases/download/1.23.2/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
# chmod +x /usr/local/bin/docker-compose
```


version確認

```
# docker-compose --version
docker-compose version 1.23.2, build 1110ad01
```

簡単できるのはいいですけど、概念を知らずに構築したので中身が見えず正直怖いですね。今後、中身を見る方法やセキュリティに関してちゃんと調べる必要がありますね。



## 3.Dockerコマンド一覧 ※詳細はヘルプを参照
コマンド一覧は、あくまでも自分のために公式サイトのリンク集を作ってみました
。
https://qiita.com/nimusukeroku/items/72bc48a8569a954c7aa2

### 3.1. コンテナ操作

|コマンド|内容|
|:---|:---|
|[attach](https://docs.docker.com/engine/reference/commandline/attach/)| コンテナにアタッチ|
|[cp](https://docs.docker.com/engine/reference/commandline/cp/)| コンテナ・ホスト間でのファイルコピー|
|[create](https://docs.docker.com/engine/reference/commandline/create/)| コンテナ作成|
|[diff](https://docs.docker.com/engine/reference/commandline/diff/)| コンテナの差分確認 |
|[exec](https://docs.docker.com/engine/reference/commandline/exec/)| 既存コンテナでコマンド実行|
|[export](https://docs.docker.com/engine/reference/commandline/export/)| コンテナをtarファイルで保存|
|[history](https://docs.docker.com/engine/reference/commandline/history/)| コンテナ履歴を表示 |
|[import](https://docs.docker.com/engine/reference/commandline/import/)| tarファイルからコンテナ作成|
|[inspect](https://docs.docker.com/engine/reference/commandline/inspect/)| コンテナ・イメージ情報表示 |
|[kill](https://docs.docker.com/engine/reference/commandline/kill/)| コンテナ強制終了 |
|[logs](https://docs.docker.com/engine/reference/commandline/logs/)| コンテナログ(出力)取得 |
|[pause](https://docs.docker.com/engine/reference/commandline/pause/)| コンテナ一時停止 |
|[port](https://docs.docker.com/engine/reference/commandline/port/)| 公開ポート表示 |
|[ps](https://docs.docker.com/engine/reference/commandline/ps/)| コンテナプロセス表示 |
|[rename](https://docs.docker.com/engine/reference/commandline/rename/)| コンテナ名変更 |
|[restart](https://docs.docker.com/engine/reference/commandline/restart/)| コンテナ再起動 |
|[rm](https://docs.docker.com/engine/reference/commandline/rm/)| コンテナ削除 |
|[run](https://docs.docker.com/engine/reference/commandline/run/)| コンテナ上でコマンド実行 |
|[start](https://docs.docker.com/engine/reference/commandline/start/)| コンテナイメージ起動 |
|[stats](https://docs.docker.com/engine/reference/commandline/stats/)| コンテナリソース利用状況表示 |
|[stop](https://docs.docker.com/engine/reference/commandline/stop/)| コンテナ停止 |
|[top](https://docs.docker.com/engine/reference/commandline/top/)| コンテナリソース状況表示 |
|[unpause](https://docs.docker.com/engine/reference/commandline/unpause/)| コンテナ再開 |
|[update](https://docs.docker.com/engine/reference/commandline/update/)| コンテナ設定を動的に変更 |
|[wait](https://docs.docker.com/engine/reference/commandline/wait/)| コンテナ終了を待つ |



### 3.2. イメージ操作

|コマンド|内容|
|:---|:---|
|[build](https://docs.docker.com/engine/reference/commandline/build/)| イメージのビルド|
|[commit](https://docs.docker.com/engine/reference/commandline/commit/)| コンテナからイメージ作成|
|[images](https://docs.docker.com/engine/reference/commandline/images/)| イメージ一覧表示|
|[inspect](https://docs.docker.com/engine/reference/commandline/inspect/)| コンテナ・イメージの情報表示|
|[load](https://docs.docker.com/engine/reference/commandline/load/)| tarファイルからイメージ作成|
|[rmi](https://docs.docker.com/engine/reference/commandline/rmi/)| イメージ削除 |
|[save](https://docs.docker.com/engine/reference/commandline/save/)| イメージをtar保存|
|[tag](https://docs.docker.com/engine/reference/commandline/tag/)| イメージにタグ名を設定|

### 3.3. ネットワーク

|コマンド|内容|
|:---|:---|
|[network connect](https://docs.docker.com/engine/reference/commandline/network_connect/)| コンテナをネットワークに接続|
|[network create](https://docs.docker.com/engine/reference/commandline/network_create/)| ネットワーク作成|
|[network disconnect](https://docs.docker.com/engine/reference/commandline/network_disconnect/)| コンテナのネットワークからの切断|
|[network inspect](https://docs.docker.com/engine/reference/commandline/network_inspect/)| ネットワーク状態表示 |
|[network ls](https://docs.docker.com/engine/reference/commandline/network_ls/)| ネットワーク一覧|
|[network rm](https://docs.docker.com/engine/reference/commandline/network_rm/)| ネットワーク削除 |


### 3.4.ボリューム操作

|コマンド|内容|
|:---|:---|
|[volume create](https://docs.docker.com/engine/reference/commandline/volume_create/)| ボリューム作成 |
|[volume inspect](https://docs.docker.com/engine/reference/commandline/volume_inspect/)| ボリューム内容表示 |
|[volume ls](https://docs.docker.com/engine/reference/commandline/volume_ls/)| ボリューム一覧表示 |
|[volume rm](https://docs.docker.com/engine/reference/commandline/volume_rm/)| ボリューム削除 |

### 3.5. その他

|コマンド|内容|
|:---|:---|
|[daemon](https://docs.docker.com/engine/reference/commandline/daemon/)| サーバ起動|
|[events](https://docs.docker.com/engine/reference/commandline/events/)| イベントの監視|
|[info](https://docs.docker.com/engine/reference/commandline/info/)| Dockerの情報表示|
|[system df](https://docs.docker.com/engine/reference/commandline/system_df/)| ディスク利用状況の表示|
|[system prune](https://docs.docker.com/engine/reference/commandline/system_prune/)| 不要なファイルの削除|
|[version](https://docs.docker.com/engine/reference/commandline/version/)| バージョン表示|



### 3.6. Docker Compose

|コマンド|内容|
|:---|:---|
|[docker-compose build](https://docs.docker.com/compose/reference/build/)|全コンテナをビルド|
|[docker-compose config](https://docs.docker.com/compose/reference/config/)|コンテナの設定|
|[docker-compose create](https://docs.docker.com/compose/reference/create/)|コンテナの作成|
|[docker-compose exec](https://docs.docker.com/compose/reference/exec/)|コンテナでのコマンド実行|
|[docker-compose kill](https://docs.docker.com/compose/reference/kill/)|全コンテナ強制停止|
|[docker-compose logs](https://docs.docker.com/compose/reference/logs/)|コンテナログ|
|[docker-compose ps](https://docs.docker.com/compose/reference/ps/)|コンテナ一覧|
|[docker-compose restart](https://docs.docker.com/compose/reference/restart/)|全コンテナ再起動|
|[docker-compose rm](https://docs.docker.com/compose/reference/rm/)|全コンテナ削除|
|[docker-compose run](https://docs.docker.com/compose/reference/run/)|コマンド実行|
|[docker-compose start](https://docs.docker.com/compose/reference/start/)|全コンテナ起動|
|[docker-compose stop](https://docs.docker.com/compose/reference/stop/)|全コンテナ停止|
|[docker-compose up](https://docs.docker.com/compose/reference/up/)|コンテナ生成・起動|

