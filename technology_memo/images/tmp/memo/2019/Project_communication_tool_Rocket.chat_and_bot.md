---
layout: default
title: プロジェクトコミュニケーションツール『Rocket.chat』＆bot
---

# プロジェクトコミュニケーションツール『Rocket.chat』＆bot

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/Rocketchat/rocket.chat_logo.png" width="320">

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/Rocketchat/hubot_logo.png" width="320">



## 0. 目的

プロジェクトのコミュニケーションを円滑にし、DevOpsの各ツールの結果をプロジェクトのメンバーに通知するためにチャットツールを導入します。


## 1. プロジェクトコミュニケーションツールとは？

チャットを使うことで、チーム内でチャットルームで発言した内容は、メンバーが参照できるため、1対1のように一方的な指示やプロジェクトに必要のない仕事を振るなどのムダがなくなります。

また、チャットルームで発言した内容により【bot】が他ツールと連携しオペレーションを自動化することも可能です。

以上からシステム運用ができるchatツール類を【ChatOps】と呼ばています。

また、ChatOpsの大きなメリットとして、共有がしやすく、記録に残しやすく、時系列に事を追いやすいという点があります。



<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/Rocketchat/rocket.chat_hubot_jenkins.png" width="640">



### 1.1. OSSプロジェクトコミュニケーションツール



#### 1.1.1. オンプレ型プロジェクトコミュニケーションツール

[Rocket.chat公式HP](https://rocket.chat/)

Rocket.Chatはオープンソースのウェブチャットプラットフォームです。MITライセンスで公開されています。



#### 1.1.2. クラウド型プロジェクトコミュニケーションツール(無料のみを記載※)

[Slack公式HP](https://slack.com/)

人気のオンラインのチャットツールでPC・スマホと各デバイスから利用しやすいのが特徴です。よく利用されるとサービスとのインテグレーションが充実しており、APIを使って独自にインテグレーションを行うことも可能です。

シンプルで使いやすくて汎用的というストレスが少ないチャットツールです。

[ChatWork公式HP](http://www.chatwork.com/ja/)

個人ベースで利用する分には無料で問題なく利用できます。日本国内で小さなプロジェクトの利用が目立ちます。拡張性は高いとは言えません。

[HipChat公式HP]([https://www.hipchat.com/](https://www.hipchat.com/))

Slackとよく比較されるのがHipChatです。チャットとしての基本機能については大きく違いは感じず、インテグレーションで対応しているものの細かい差や、UIの違いで使い勝手が異なるといった程度です。APIの利用も可能です。



#### 1.1.3. オンプレ型botツール

[HUBOT公式サイト](https://hubot.github.com/)

よく使われているbotツールがHUBOTです。Node.jsとCoffeeScriptで開発されています。チャットの監視やイベント通知を受け取ってアクションを起こします。

HUBOTは利用者が多いこともあり、サードパーティーによるチャットツールやメッセンジャーツールとのアダプターが充実しています。



[Ruboty公式サイト](https://github.com/r7kamura/ruboty)

RubotyはRuby製のbotツールです。Herokuの無料プランで動作させることができるのが魅力でしたが、現在24時間無料プランがなくなったためHerokuの有料プランを使うか他アプリケーションサーバーで動作させる必要があります。

サードパーティーによるチャットツールやメッセンジャーツールとのアダプターは、slack,twitter,hipchat,idobata,chatworkに対応しています。



### 1.2. プロジェクトコミュニケーションツール選定

チャットツールは、自社内にオンプレミスで構築でき、利用料金が発生しない**【Rocket.chat】**を選定し、botには、チャットツールとのアダプターが存在する**【HUBOT】**を選定することにします。



### 1.3. Rocket.chatとは？

Rocket.Chatとは、[OSS](https://www.designet.co.jp/faq/term/index.php?id=44Kq44O844OX44Oz44K944O844K544K944OV44OI44Km44Kn44Ki)のウェブチャットソフトウェアです。昨今では、本社と支社間、在宅勤務者、顧客先や移動中の社員等、遠隔地にいる人とコミュニケーションを取る機会が増えています。会議室やプロジェクトルーム内で気軽に話をするように遠隔地とも話ができれば、作業効率の向上を期待できます。Rocket.Chatは、オンプレミス環境にシンプルなチャットシステムを構築できるソフトウェアです。

## 2. Rocket.chatインストール

### 2.0. 環境

CentOS : 7.5.1804
Docker : 18.09.0, build 4d60db4
Docker-compose : 1.23.2, build 1110ad01
※Dockerには、[Docker CE]とエンタープライズ版の[Docker EE]がありますが、今回は無償の[Docer CE]を使用します。
Rocket.chat：0.74.3
Node.js:8.11.4
mongo 3.2
HUBOT ：2.17.2

### 2.1. docker-compose用YAML作成

```
# vi docker-compose.yml
```

以下を追記。

```
  rocketchat:
    image: rocketchat/rocket.chat:latest
    volumes:
      - ./uploads:/app/uploads
      - /etc/localtime:/etc/localtime:ro
    environment:
      - PORT=3000
      - ROOT_URL=http://localhost:3000
      - MONGO_URL=mongodb://mongo:27017/rocketchat
      - TZ=Asia/Tokyo
    links:
      - mongo:mongo
    ports:
      - "3000:3000"

  mongo:
    image: mongo:3.2
    volumes:
      - ./data/db:/data/db
      - /etc/localtime:/etc/localtime:ro
    environment:
      - TZ=Asia/Tokyo
    command: mongod --smallfiles --oplogSize 128

  # hubot, the popular chatbot (add the bot user first and change the password before starting this image)
  hubot:
    image: rocketchat/hubot-rocketchat:latest
    environment:
      - ROCKETCHAT_URL=rocketchat:3000
      - ROCKETCHAT_ROOM=GENERAL
      - ROCKETCHAT_USER=[botユーザ名]
      - ROCKETCHAT_PASSWORD=[botユーザのパスワード]
      - BOT_NAME=bot
      - HUBOT_JENKINS_URL=[連携するjenkinsのURL]
      - HUBOT_JENKINS_AUTH=[jenkinsのアカウント:パスワード]
      - EXTERNAL_SCRIPTS=hubot-help,hubot-seen,hubot-links,hubot-diagnostics,hubot-reddit,hubot-bofh,hubot-bookmark,hubot-shipit,hubot-maps,hubot-cron,hubot-jenkins-notifier
      - TZ=Asia/Tokyo
    links:
      - rocketchat:rocketchat
    labels:
      - "traefik.enable=false"
    volumes:
      - ./scripts:/home/hubot/scripts
      - /etc/localtime:/etc/localtime:ro
    ports:
      - "3001:8080"
```

### 2.2. Rocket.chat起動

```
# docker-compose up -d
```

注意事項：Hubotは、初回起動時のみRocket.chatにbotユーザを作成していないため、docker コンテナが異常終了(Exit 1)します。

## 3.Rocket.chat初期設定



### 3.1. Rocket.chat初期設定

ブラウザで[http://IPアドレス:3000/] にアクセスし、[名前]に"root"、[ユーザ名]に"root"、[組織の電子メール]に"適当なメールアドレス"、[パスワード]に"管理者のパスワード"を入力し[次へ]ボタンをクリック。

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/Rocketchat/Rocket.chat001.png" width="640">

[組織の種類]に"適当な種類"、[組織名]に"適当な組織名"、[産業]に"適当な産業"、[規模]に"適当なメンバー数"、[国・地域]に"日本"、[ウェブサイト]に"適当なURL"を入力し、[次へ]ボタンをクリック。

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/Rocketchat/Rocket.chat002.png" width="640">

[サイト名]に"適当なサイト名"、[言語]に"日本語"、[サーバの種類]に"プライベートチーム"を選択し、[次へ]ボタンをクリック。

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/Rocketchat/Rocket.chat003.png" width="640">

[次を自分で実施し、スタンドアローン利用する]を選択し、[次へ]ボタンをクリック。

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/Rocketchat/Rocket.chat004.png" width="640">

[ワークスペースを開く]ボタンをクリック。

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/Rocketchat/Rocket.chat005.png" width="420">

ワークスペース画面で[:]ボタンをクリックし[管理]ボタンをクリック。

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/Rocketchat/Rocket.chat006.png" width="640">

管理画面の左側で[ユーザー]を選択し、右側の[+]ボタンをクリック。

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/Rocketchat/Rocket.chat007.png" width="640">

[名前]に"bot"、[ユーザ名]に[docker-compose.yml]に設定した[ROCKETCHAT_USER]のパラメータ、[メール]に"適当なメールアドレス"、[パスワード]に[docker-compose.yml]に設定した[ROCKETCHAT_PASSWORD]のパラメータ、[ロールを選択]で[BOT_NAME]のパラメータを選択し[ロールを追加する]ボタンをクリックし、[ようこそメールを送信]のチェックを外し、[保存]ボタンをクリック。

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/Rocketchat/Rocket.chat008.png" width="320">

botユーザが追加されたことを確認。

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/Rocketchat/Rocket.chat009.png" width="640">

botユーザ追加後、hubotを起動しRocket.chatのユーザ画面でbotユーザの左側のマークが緑色に変わったらbotの認識はOKとなります。



### 3.4. ユーザ作成

ユーザ作成は、botユーザ作成と同様に作成すること。

### 3.5 Jenkins連携用スクリプトの配置



docker-compose.ymlの記載したhubotのscript格納ディレクトリ(以下の場合は[./scripts])に

```yaml
volumes:
  - ./scripts:/home/hubot/scripts
```


以下のファイルをダウンロードし、

https://github.com/github/hubot-scripts/blob/master/src/scripts/jenkins.coffee

script格納ディレクトリにファイル[hubot-scripts.json]に以下を設定する。

```json
[
    "jenkins.coffee"
]
```



3.6. Jenkins側にリモートジョブ実行許可設定

Jenkins側でもユーザ・パスワードだけでなくリモートジョブを実行許可する設定が必要となります。

Jenkinsにログインし[Jenkinsの管理]をクリック。

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/Rocketchat/hubot_jenkins_config001.png" width="240">

[グローバルセキュリティの設定]をクリック

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/Rocketchat/hubot_jenkins_config002.png" width="480">

[CSRF対策]のチェックを外し、[保存]ボタンをクリック。

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/Rocketchat/hubot_jenkins_config003.png" width="240">



### 3.6. Jenkinsジョブを実行

まずは、Rocket.chatにメッセージでbotが応答してくれるか動作確認を実施してみたいと思います。Rocket.chatからbotに対して、呼びかける時は`@bot`と入力すればチャットでの発言がbotに対してのメッセージとなります。

また、単純にbotの応答確認したい時は、`ping`を投げると設定が間違っていなければ`PONG`と応答してくれます。

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/Rocketchat/hubot_ping001.png" width="320">

Rocket.chatにメッセージを載せ、Hubot経由でJenkinsジョブを実行してみます。
botにjenkinsのビルドを実行させるには`@bot jenkins build <ジョブ名>`となります。
なお、jenkinsのジョブリストを出力させたい場合は、`@bot jenkins list`でジョブリストを応答してくれます。

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/Rocketchat/hubot_jenkins_jobstart001.png" width="480">



### 3.7. その他連携スクリプトの設定

[hubot-scripts.json]に使用するscriptをカンマ(,)区切りで設定し、scriptフォルダに`*.coffee`を設定し、docker-compose.ymlに連携するためのURLや認証情報を環境変数に設定する。

```hubot-scripts.json
[
    "jenkins.coffee","gitbucket-notification.coffee"
]
```



## 最後に

最初は、チャットツールの必要性を疑問視していたが、jenkinsのジョブ実行も含め、チーム内で作業も連携することができるのは、連携ミスも避けることも可能だと感じました。

