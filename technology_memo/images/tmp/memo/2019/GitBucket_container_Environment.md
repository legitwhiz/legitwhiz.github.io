---
layout: default
title: GitBucketをdockerで構築
---

# GitBucketをdockerで構築

## 1. GitBucket

### 1.1. 目的
未だにソース管理されていない現場が、まだまだあるのでバージョン管理システムを構築し、運用ルールを設ける指標を考えてみました。

私自身、バージョン管理システムでの運用を実施したことがないので勉強を兼ねてますので、色々と不備はあると思いますが何事も経験してみないことには、不具合を理解することができないと思うのでご指摘あればお願いします。

また私は、バージョン管理システムをDevOpsの最初の一歩と考えています。
バージョン管理システム自体は、本来は、集中型と分散型のメリット・デメリットを考慮した上で検討すべきなのでしょうが、安易に最近の流行りであるGitを導入してみました。

Dockerコンテナ環境の構築は前回の[Dockerでコンテナ環境簡単構築](https://qiita.com/legitwhiz/items/d3a588f30ad5ec42c500)を参照。




### 1.2. GitBucketとは？

[GitBucket](https://github.com/takezoe/gitbucket)とは、Gitのリポジトリ環境を自前で構築するサーバであり、OSSのGitHubクローンです。

[GitHub](https://github.com/)等で世間にソースコードを公開はしたくないが、Gitでリポジトリを管理するのに適したミドルウェアです。

GitBucketは「GitHubクローン」をうたっており、UIはかなり寄せてあります。

リポジトリブラウザはもちろんのことフォーク機能、イシュートラッカー、Wikiなど、GitHubの主要機能のほとんどが実装されていますでのGitHubを使ったことがある人からすれば、違和感なく使うことができるでしょう。



## 2. GitBucket構築

### 2.1. 環境
CentOS : 7.5.1804
Docker : 18.09.0, build 4d60db4
Docker-compose : 1.23.2, build 1110ad01
※Dockerには、[Docker CE]とエンタープライズ版の[Docker EE]がありますが、今回は無償の[Docer CE]を使用します。
GitBucket 4.29.0



### 2.2. docker imageのダウンロード

gitbucketのdocker imageをダウンロードするには、以下のコマンドを実行するだけで完了となります。
```
# docker pull gitbucket/gitbucket
Using default tag: latest
latest: Pulling from gitbucket/gitbucket
5040bd298390: Pull complete
fce5728aad85: Pull complete
c42794440453: Pull complete
0c0da797ba48: Pull complete
7c9b17433752: Pull complete
114e02586e63: Pull complete
e4c663802e9a: Pull complete
4f8252fa05f0: Pull complete
9da190d7177d: Pull complete
Digest: sha256:2a418a857fdf624f05fd4958c9eae25fbb26ccbe7dbad02497d3f8adfedf2d18
Status: Downloaded newer image for gitbucket/gitbucket:latest
```

ダウンロードしたdocker imageを確認するには
```
# docker images
REPOSITORY            TAG                 IMAGE ID            CREATED             SIZE
gitbucket/gitbucket   latest              8a9b1c7d4155        10 days ago         362MB
```

### 2.3. docker imageの起動・停止

以下のようにして簡単に起動できます。
```
# docker run -d -p 8080:8080 gitbucket/gitbucket
```

gitbucketにSSH接続も行う場合は-p 29418:29418を指定します。
```
# docker run -d -p 8080:8080 -p 29418:29418 gitbucket/gitbucket
```

データディレクトリの場所を指定するには-vで指定できます。
```
# docker run -d -p 8080:8080 -v `pwd`/gitbucket:/gitbucket gitbucket/gitbucket
```

プロセスを確認するには
```
# docker ps -a
CONTAINER ID        IMAGE                 COMMAND                  CREATED             STATUS              PORTS                               NAMES
5e4857ec99d5        gitbucket/gitbucket   "sh -c 'java -jar /o…"   17 minutes ago      Up 17 minutes       0.0.0.0:8080->8080/tcp, 29418/tcp   dazzling_matsumoto
```

停止するには
```
# docker stop <CONTAINER ID>
```

停止した場合は、STATUSが[Exited]となります。
```
# docker ps -a
CONTAINER ID        IMAGE                 COMMAND                  CREATED             STATUS                        PORTS               NAMES
5e4857ec99d5        gitbucket/gitbucket   "sh -c 'java -jar /o…"   21 minutes ago      Exited (137) 28 seconds ago                       dazzling_matsumoto
```



### 2.4. ブラウザアクセス

クライアントからブラウザで以下にアクセスし
http://<Server IP Address>:8080/

以下のユーザでログインすること。
user:root
password:root



### 2.5. DockerでGitBucketのコンテナを永続化+Port変更
docker上のコンテナで作成したリポジトリ情報は，コンテナを破棄した時に同時に消滅してしまいます。そのため、dockerのデータボリューム機能及びdocker compose機能を用いて永続化をしました。

まずは、Dockerfileでデータボリューム及びbuildする対象を設定。＋Portをdefault8080から8888に変更
```
# vi Dockerfile
FROM java:8-jre

MAINTAINER Naoki Takezoe <takezoe [at] gmail.com>

ADD https://github.com/gitbucket/gitbucket/releases/download/4.30.0/gitbucket.war /opt/gitbucket.war

RUN ln -s /gitbucket /root/.gitbucket

VOLUME ./gitbucket/gitbucket-data:/gitbucket

# Port for web page
EXPOSE 8888
# Port for SSH access to git repository (Optional)
EXPOSE 29418

ENV MAX_FILE_SIZE=3145728

CMD ["sh", "-c", "java -jar /opt/gitbucket.war --max_file_size=$MAX_FILE_SIZE"]
```



そして、docker composeの設定＋Portをdefault8080から8888に変更

```
# vi docker-compose.yml
version: '2'
services:
  gitbucket:
    image: gitbucket:4.30.0
    ports:
      - 8888:8080
      - 29418:29418
    volumes:
      - ./gitbucket/gitbucket-data:/gitbucket
    restart: always
```



docker composeから起動(docker-compose.ymlが存在するディレクトリで実行すること)

```
# docker-compose up -d
```

docker composeからの停止は

```
# docker-compose down 
```

docker composeからのプロセス確認は

```
# docker-compose ps
```



