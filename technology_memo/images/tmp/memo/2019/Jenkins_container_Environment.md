---
layout: default
title: Jenkinsをdocker上に構築
---

# Jenkinsをdocker上に構築

## 1. Jenkins

### 1.1. 目的
前回は、GitBucketを構築するところまで実施しましたが、次のステップとしてCI環境の整備です。

CI(継続的インテグレーション)環境として、Gitbucketと連携可能なJenkinsを構築してみます。

CI環境を導入することで、作業品質の向上と作業コストの削減を目指します。

前回のGitBucket環境の構築は[GitBucketをdockerで構築](https://qiita.com/legitwhiz/items/b1e3b39364e5effb9338)を参照。



### 1.2. CIとは
まずCIとは、Continuous Integration: 継続的インテグレーションのこと。
ソース管理されたソースを各サーバに配布し、状況に合わせコンパイルやデプロイを実施し、単体テストまでをCIによって実施することによって、品質向上と作業コストを削減するのが目的です。
CIは、バージョン管理でのコミットをきっかけにして(Webhook)、上記作業を自動的に行うことも可能です。
ただし、CIだけではコンパイルやデプロイ、単体テストまでを何も考えず実行されるわけではなく、コンパイルするためのジョブを作成しスクリプト等を実行することで自動化されます。
それにバージョン管理はGit等、ビルドはGradle等、テストはJUnit等、リリースはSERENA等、デプロイはAWS、Azure、docker、openstack等と連携するためのツールのため、CIはきっかけはバージョン管理かもしれませんが、あくまでも連携するためのジョブスケジューラだと考えてよいでしょう。



**有名どころでいうと以下のようです。**

- **[Jenkins](https://github.com/jenkinsci/jenkins)**

もっとも多く導入されているCIツールであり、オープンソースのため無料。多様なスクリプトにも対応でき、豊富なプラグインによる優れた拡張性、日本語にも対応していることから人気の理由です。また、利用者が多いため、日本語コミュニティも盛んであり、日本語の情報が集めやすいのも特徴です。
対応言語は、Java、PHP、Perl、javascript、bashなど

- **[Travis CI](https://travis-ci.org/)**

GitHub上のソースをビルドやテストを行うことが可能な、分散型のCIです。ビルド・テストを実行する環境がサービスとして提供されているため、最低限の設定のみで導入できるという特徴があります。バージョン管理のリポジトリとして人気のある、GitHubとの連携が可能なことから導入している企業も多いようです。
ただし、Webサービスのためオンプレミス環境では構築できません。
対応言語は、PHP、 Python、Ruby、Javaなど

- **[Drone](http://docs.drone.io/)**

GitリポジトリのイベントをフックしDockerコンテナ内でジョブを実行することに特化したCIツールです。
オンプレミスで構築でき、Go 言語で書かれたCI/CD 環境を提供する OSS ツールで、サポート可能なEnterprise版の販売も行っているようです。実際にジョブを実行するにはAgentが必要となる。
WebUIでの利便性よりCUIでの実行に優れている。

- **[Concourse CI](https://concourse.ci/)**

パイプラインベースのCI/CD(継続的インテグレーション/デリバリー)ツールです。
タスクの集まりをパイプラインとして記述することでビルドパイプラインを実行し可視化できます。
対応言語は、PHP、 Python、Ruby、Javaなど

### 1.3. Jenkinsとは？

![logo-title](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/logo-title.png)

[Jenkins](https://github.com/jenkinsci/jenkins)とは、継続的インテグレーション(CI)/継続的デリバリー(CD)実現のためのツール
継続的インテグレーションとは、ソフトウェア開発において、ビルドやテストを頻繁に繰り返し行なうことにより問題を早期に発見し、開発の効率化・省力化や納期の短縮を図る手法であり、「ソフトウェアのリリーススピードの向上」「開発プロセスの自動化」「開発コストの削減」といった利用目的としています。
また、今回も安易に多く使われているCIということでJenkinsを導入してみます。(他の連携するためのツールは後々考えます)




## 2. Jenkins構築

### 2.1. 環境
CentOS : 7.5.1804
Docker : 18.09.0, build 4d60db4
Docker-compose : 1.23.2, build 1110ad01
※Dockerには、[Docker CE]とエンタープライズ版の[Docker EE]がありますが、今回は無償の[Docer CE]を使用します。
GitBucket 4.29.0
Jenkins 	 2.150 (LTS版)



### 2.2. docker imageのダウンロード

gitbucketのdocker imageをダウンロードするには、以下のコマンドを実行するだけで完了となります。

```
# docker pull jenkins/jenkins:lts
lts: Pulling from jenkins/jenkins
54f7e8ac135a: Pull complete
d6341e30912f: Pull complete
087a57faf949: Pull complete
5d71636fb824: Pull complete
9da6b28682cf: Pull complete
203f1094a1e2: Pull complete
ee38d9f85cf6: Pull complete
7f692fae02b6: Pull complete
eaa976dc543c: Pull complete
7f9b3f728bf9: Pull complete
0c1e7e89199b: Pull complete
ffbef2a6e2ad: Pull complete
e9cfa7b02f0f: Pull complete
a10f81bed607: Pull complete
77045bab2c3f: Pull complete
bf46802e180c: Pull complete
edb5af7df9a3: Pull complete
15987da7af8e: Pull complete
c43e1ec6f3fb: Pull complete
15f9e06bf221: Pull complete
86b655d38189: Pull complete
Digest: sha256:09cf44600c260c50b63c866aa50b8a482b1ae6089ff213527963595f9612ec2a
Status: Downloaded newer image for jenkins/jenkins:lts
```

ダウンロードしたdocker imageを確認するには

```
# docker images
REPOSITORY        TAG        IMAGE ID         CREATED           SIZE
gitbucket         4.30.0     66717563c93f     9 days ago        363MB
jenkins/jenkins   lts        5907903170ad     3 weeks ago       701MB
java              8-jre      e44d62cf8862     23 months ago     311MB
```

### 2.3. docker imageの起動・停止

以下のようにしてとりあえず起動します。

```
# docker run -p 8080:8080 -p 50000:50000 jenkins/jenkins:lts
```

データディレクトリの場所を指定するには-vで指定できます。

永続化が必要なデータはコンテナ内の `/var/jenkins_home` に作成されるので、localhost側のカレントディレクトリのjenkins_homeにマウントします。

```
# docker run -d -v `pwd`/jenkins_home:/var/jenkins_home -p 8080:8080 -p 50000:50000 jenkins/jenkins:lts
```

プロセスを確認するには

```
# docker ps -a
CONTAINER ID        IMAGE                 COMMAND                  CREATED             STATUS                     PORTS                                              NAMES
992dbda6a55c        jenkins/jenkins:lts   "/sbin/tini -- /usr/…"   About an hour ago   Up About an hour           0.0.0.0:8080->8080/tcp, 0.0.0.0:50000->50000/tcp   lucid_mclaren
```

停止するには

```
# docker stop <CONTAINER ID>
```

停止した場合は、STATUSが[Exited]となります。

```
# docker ps -a
CONTAINER ID   IMAGE               COMMAND                CREATED             STATUS                        PORTS               NAMES
992dbda6a55c   jenkins/jenkins:lts "/sbin/tini -- /usr/…" About an hour ago   Exited (143) About a minute ago  lucid_mclaren
```



### 2.4. ブラウザアクセス

クライアントからブラウザで以下にアクセスし
http://<Server IP Address>:8080/

以下のユーザでログインすること。
Administrator passwordの入力を求められるのでパスワードを入力しEnterキーを押す。

※パスワードは、[\`pwd\`/jenkins_home/secrets/initialAdminPassword]を参照。


![jenkins_install001](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/jenkins_install001.png)

初期設定でプラグインをインストールできます。ここでは何をインストールしたらよいか分からないのでとりあえず「Install suggesed plugins」を選択しました。



![jenkins_install002](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/jenkins_install002.png)


![jenkins_install003](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/jenkins_install003.png)


[Create First Admin User]画面で[ユーザ名]、[パスワード]、[パスワードの確認]、[フルネーム]、[メールアドレス]の全てを入力し[Save a Continue]をクリック。


![jenkins_install004](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/jenkins_install004.png)


[Instance Configuration]画面でURLを入力し、[Save a Continue]をクリック。


![jenkins_install005](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/jenkins_install005.png)


[Jenkins Ready]画面で、[Start using Jenkins]をクリック。


![jenkins_install006](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/jenkins_install006.png)


インストールが終わりダッシュボードが表示されたら完了です。


![jenkins_install007](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/jenkins_install007.png)



### 2.5. DockerでJenkinsのコンテナを永続化+Port変更
docker上のコンテナで作成したリポジトリ情報は，コンテナを破棄した時に同時に消滅してしまいます。そのため、dockerのデータボリューム機能及びdocker compose機能を用いて永続化をしました。

前回、GitBcketを構築しましたのでdocker-compose.ymlにjenkinsのサービスを追加しポートを8080から8889に変更してます。



そして、docker composeの設定＋Portをdefault8080から8889に変更

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

  jenkins:
    image: jenkins:lts
    ports:
      - '8889:8080'
      - '5000:5000'
    volumes:
      - ./jenkins_home:/var/jenkins_home
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



## 後書き

色々調べていくなか事例を見ていくと…。

詳細なHWリソースは分かりませんが、JenkinsのMaster3台、SlaveがMaster毎に10台構成でジョブ数300程度でジョブの実行時間が30秒から1時間ってSlaveあたり10ジョブ？？？と私の感覚だとリソースが必要な割に処理できるジョブ数も少なく、実行時間も長過ぎなのでは？と思ってしまいます。

ですが、他事例を見るとビルドプロセスがCI導入前は3日かかったものが3時間に短縮できたそうです。

多種多様なプラグインで連携できるように作られているようですが、本当に使えるかは運用してみないと分かりませんねー。

分からないものに時間的なリソースやコストをかけられるかが、提案するうえでのキモとなりそうです。
