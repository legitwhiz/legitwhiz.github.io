---
title: docker コマンド チートシート
layout: default
---

Docker バージョン: 1.4.1

docker 触るたびに毎回調べてばかりで覚えられないので、頭を整理するために自分用にチートシート作る事にした。

## docker pull

### イメージを引っ張ってくる

```bash
$ docker pull ubuntu
```

```bash
$ docker pull centos
```

### タグを使ってイメージのバージョンを指定する

```
$ docker pull ubuntu:12.04
```

## docker build

### キャッシュを無効にする

ビルド時にキャッシュを無効にしたい場合は --no-cache を true にする。デフォルトでは false

```bash
$ docker build --no-cache=true
```

## docker run

### ホスト名を付けて起動する

-h で指定する

```bash
$ docker run -h spam -i -t ubuntu /bin/bash
```

spam というホスト名を付けてみた

### コンテナ名を付けて起動する

--name でコンテナに名前を付けられる

```bash
$ docker run --name spam -i -t ubuntu /bin/bash
```

spam という名前を付けてみた

### 起動して開きっぱなし

-i を付けると起動時に STDOUT を開きっぱなしにしてくれる

```bash
$ docker run -i -t ubuntu /bin/bash
```

### イメージのタグを指定して実行する

```bash
$ docker run ubuntu:13.10 /bin/echo hello world
```

### 起動して終了するとコンテナ破棄する

docker run をするとき --rm を付ける。これを付けると docker を終了させると同時に docker コンテナを削除してくれる。

```bash
$ docker run --rm -t -i ubuntu /bin/bash
```

### コンテナ起動時に CPU 相対的使用率を指定する

CPU 使用率を決めたい場合。

```bash
$ docker run -c 200 -i -t ubuntu /bin/bash
```

### コンテナ起動時にメモリを指定する

```bash
$ docker run -m 512m -i -t ubuntu /bin/bash
```

-m を使う事でメモリ容量を指定できる。単位は b,k,m,g です。上記例では 512メガバイトを割り当てている。

### コンテナバックグラウンド起動

-d を使う事でバックグラウンドで起動できる。

```bash
$ docker run -i -t -d ubuntu /bin/bash
```

### ホストディレクトリをコンテナにマウントする

-v コマンドと : を使います。絶対パスが必要なので要注意です

```bash
$ docker run -v /home/spam/test:/root/test
$ docker run -v `pwd`/test:/root/test
```

### データボリュームでコンテナ間でデータを共有する

-v を使うとデータボリュームをコンテナに作成できる。

```bash
$ docker run --name tmp -v /tmp -i -t ubuntu /bin/bash
```

```bash
$ docker run --volumes-from tmp -i -t ubuntu /bin/bash
```

これで両方のコンテナで /tmp が共有される。

- [docker - Data Volume と Data Volume Container - Qiita](http://qiita.com/sokutou-metsu/items/b83b275198fc9594f5a4)

### データボリュームの読み込みをリードオンリーにする

--volumes-from で指定コンテナに ro を付けることでリードオンリーとなる。

```bash
$ docker run --volumes-from tmp:ro -i -t ubuntu /bin/bash
```

- [docker - Data Volume と Data Volume Container - Qiita](http://qiita.com/sokutou-metsu/items/b83b275198fc9594f5a4)

## docker start

### コンテナを起動してログイン

-a を付けると attach します。

```bash
$ docker start -a <ContanerID>
```

## docker attach

### 起動中のコンテナにログイン

```
$ docker attach <ContainerID>
```

## docker ps

### 直近で起動したコンテナの ID を取得する

```bash
$ docker ps -l -q
```

このコマンドを dl とかに設定しておくと良いそうです。自分はやってません ... 。

- [15 Docker Tips in 5 Minutes - SSSSLIDE](http://sssslide.com/speakerdeck.com/bmorearty/15-docker-tips-in-5-minutes)
- [実例で学ぶDockerコマンド - Qiita](http://qiita.com/deeeet/items/ed2246497cd6fcfe4104#2-2)

### コンテナ一覧

-a を付けないと起動しているコンテナだけになる

```bash
$ docker ps -a
```

### 古いコンテナを一気に削除する

```bash
$ docker ps -a | grep 'weeks ago' | awk '{print $1}' | xargs docker rm
```

### docker rm

#### 停止中のコンテナを一気に削除する

```bash
$ docker rm `docker ps -aq`
```

#### コンテナをすべて強制的に削除する

```bash
$ docker rm -f `docker ps -aq`
```

### docker images

#### イメージの一覧を表示する

```
$ docker images
```

### docker rmi

#### イメージの削除

```
$ docker rmi <ImageID>
```

## 参考

- [docker - Data Volume と Data Volume Container - Qiita](http://qiita.com/sokutou-metsu/items/b83b275198fc9594f5a4)
- [Docker メモ - Qiita](http://qiita.com/voluntas/items/bb7c46fdfc709d97f9a5)
	- 焼き直し
- [私の Docker TIPS - Qiita](http://qiita.com/mopemope/items/181cb6c6c6f7cf9bbaa9)
- [実例で学ぶDockerコマンド - Qiita](http://qiita.com/deeeet/items/ed2246497cd6fcfe4104)
- [Command line - Docker Documentation](https://docs.docker.com/reference/commandline/cli/)
- [Dockerfile - Docker Documentation](https://docs.docker.com/reference/builder/)
- [Dockerfileを書く時の注意とかコツとかハックとか](http://kimh.github.io/blog/jp/docker/gothas-in-writing-dockerfile-jp/)
- [Dockerチートシート - Qiita](http://qiita.com/bungoume/items/b8911fd243d9c084bd63)
