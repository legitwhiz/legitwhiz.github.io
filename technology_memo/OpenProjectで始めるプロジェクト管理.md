---
layout: default
title: OpenProjectで始めるプロジェクト管理
---

# OpenProjectで始めるプロジェクト管理

## 1. プロジェクト管理ツール選定

### 1.1. Excelでプロジェクト管理は、NGなの？

エクセルでプロジェクトのスケジュールは、簡単そうに感じている人が多いと思いますが、計画通り進めばプロジェクトに支障をもたらすことはないと思います。

ですが、計画自体の変更やタスクの追加などと、その度にエクセルを修正しメンバーに修正した旨を展開しなければなりません。特に各タスクの関連線などは、修正が面倒になります。

また、共有しているとはいえ、一つのエクセルファイルを複数メンバーで修正しますので、実績の記録が面倒となり、修正が追い付かない状況をよく見かけます。

エクセルでプロジェクト管理するには、【計画の修正】、【実績の記録】において、『不向きと言わざるを得ない』のである。

エクセルマクロで、その辺を解消したものをプロジェクトで作成している現場もありますが、Officeのバージョンアップで使い物にならなくなったとの悲鳴もよく聞きます。

そもそも、エクセルは表計算ソフトなので、プロジェクト管理には限界があると考える。

### 1.2. プロジェクト管理に必要なもの

【プロジェクト管理の管理項目】

ですが、まずPMBOKにおける、プロジェクト管理の管理項目が何なのかを理解した上で選定する必要があるので、以下にPMBOK管理10項目を記載します。

【PMBOK管理10項目】

- 統合管理(プロジェクト管理計画、実行、監視、管理、締結)
- スコープ管理(原価管理)
- スケジュール管理(進捗管理)
- コスト管理
- 品質管理
- 組織管理(要員管理)
- コミュニケーション管理
- リスク管理
- 調達管理
- ステークホルダー管理

私は、PMを何度か経験(小規模)ありますが、正直ここまで管理したことありません。(;'∀')
実際は、スコープ管理、スケジュール管理、品質管理、リスク管理ぐらいですかね~

### 1.3. プロジェクト管理ツールを導入する目的

現状で問題の兆候がないにしろ、プロジェクトをより円滑に進行させ、より利益を出すプロジェクトに進化させるため、以下の項目を導入する目的としています。

- 要員の状況を正確に把握するため。
- プロジェクト管理業務（集計、報告、共有etc）を効率化するため。
- 課題やタスクの抜け漏れを防ぐため。
- スケジュールを一元管理するため。
- プロジェクトの見える化を実現するため。
- 会社のプロジェクト管理業務を標準化するため。
- プロジェクト管理レベルを上げるため。
- 失敗プロジェクトを減らすため。

ただし、プロジェクト管理ツールには、そもそも製品によって目的が違います。スケジュール管理を得意にしている製品、コスト管理に得意にしている製品、統合的に網羅している製品とあります。

この中から、現プロジェクトの目的に合った製品を選定する必要があります。

### 1.4. OSSプロジェクト管理ツール

#### 1.4.1. オンプレ型プロジェクト管理ツール

- **OpenProject**
  Microsoft Projectと互換して、利用できるOSSプロジェクト管理ツール。

  Redmineにプラグイン「ガントチャート」「バックログ」等を導入して、使いやすいようにカスタムするのが面倒な方におすすめ。

  [OpenProject](https://www.openproject.org/)

- **Redmine**
  ガントチャート、カレンダー、ロードマップを始め、チームごとのWiki等、情報共有の仕組みも準備されています。
  無償、商用可、OSSのGNU Licenseで運用されます。

  [Redmine](http://www.redmine.org/projects/redmine)

- **Trac**
  Webベースのプロジェクト管理ツールです。Apache等のWebサーバー上で運用します。
  　Redmineと内容的には変わりません。RedmineはRubyベースで開発され、TracはPythonベースで開発されている点が違いですが、利用者側に影響する話ではありません。
  　無償、商用可、OSSのBSD Like Licenseで運用されます。

  [Trac](https://trac.edgewall.org/)

#### 1.4.2. クラウド型プロジェクト管理ツール(無料のみを記載※)

※無料の場合、何かしらの制限はあり

- **Trello**

  無料プランの場合、人数・タスク数制限なし、添付ファイルは10MBまで、一部機能制限有りとなっていますが、機能としては十分かと思います。また、スマホ対応もしている点でも優秀です。

  タスクカードを付箋のように貼ったり剥がしたり自由に動かしながら視覚的に操作できるプロジェクト管理ツールです。

  クラウド型で、タスク管理や資料や画像の情報の共有がスムーズに行え、複数人で作業をリアルタイムで確認できる。

  [Trello](https://trello.com/)

- **Wrike**
  タスク管理機能に特化したプロジェクト管理ツールです。
  特にスケジュール管理について、ダッシュボードで一画面にまとめられるため、感覚的にプロジェクトの進捗状況をつかむことが出来ます。日本語にも対応しています。
  5人までの少人数のチームの管理は無料で使用することが可能。

  [Wrike](https://www.wrike.com/ja/)

### 1.5. プロジェクト管理ツール選定

クラウド型でも満足できる機能は、内包していると思いますが、私個人としての検証・導入し製品の知識を得るという目的を果たせないため、オンプレ型の製品を選定する条件とします。
プロジェクト管理ツールである、RedmineはOSSでは一番シェアがあるのでしょうが、スケジュール管理としてガントチャートを使用したいので、スケジュール管理を得意とする製品【OpenProject】を選定してみました。

### 1.6. OpenProjectとは？

OpenProjectは、ウェブベースのOSSプロジェクト管理ツールです。
Ruby On Rails 5.0で開発されており、ライセンスはGPLv3です。

主な機能は、以下に羅列してみました。

色々と機能があり、運用ルールを決めるだけでも、知恵熱が出そうです・・・(;^_^A

- タイムライン管理・カレンダー
- タスクボード・バックログ管理
- ロードマップ・リリース計画
- タスク管理・ウォッチ機能
- タイムトラッキング・コスト・予算管理
- Wiki・フォーラム
- バクトラッキング・イシュートラッキング
- Git・Subversionリポジトリのサポート
- ガントチャートでプロジェクト計画全体を俯瞰できる。
- チケット(タスク)一覧で「誰が」「何を」行っているかが見える。
- フィルタ機能で特定のチケットのみを抽出できる。(進捗度XX%、優先度、完了済み、未完など)

## 2. OpenProjectインストール

OpenProjectインストールは、公式のマニュアルをもとに実施できます。

[OpenProject公式HP](https://www.openproject.org/download-and-installation/)

公式ではないですが、分かり易くインストールを説明しているサイトもありましたので、一からインストールしたい方は以下を参考に構築するとよいでしょう。

[プロジェクト管理ツールOpenProjectのインストール方法の説明と紹介](https://tracpath.com/works/development/how-to-install-openproject/)


ですが、今回は簡単に構築できるようにDockerで構築してみたいと思います。

[OpenProject公式HP Install OpenProject with Docker](https://www.openproject.org/docker/)

### 2.1. docker-compose用YAML作成

```
# vi docker-compose.yml
```

以下を追記。

```
  web:
    image: openproject/community:latest
    depends_on:
      - postgres
      - memcached
    ports:
      - "8890:80"
    volumes:
      - pg-data:/var/lib/postgresql/data
      - ./data:/var/db/openproject
    environment:
      DATABASE_URL: "postgres://opuser:oppassword@postgres:5432/openproject?pool=10&encoding=unicode&timeout=5000&reconnect=true"
      SECRET_KEY_BASE: openproject_secret_key
      CACHE_MEMCACHE_SERVER: memcached
      CACHE_NAMESPACE: openproject
    restart: always
  postgres:
    image: postgres:9.6-alpine
    volumes:
      - pg-data:/var/lib/postgresql/data
    environment:
      POSTGRES_DB: openproject
      POSTGRES_USER: opuser
      POSTGRES_PASSWORD: oppassword
    restart: always
  memcached:
    image: memcached:1.5.7-alpine
    restart: always
volumes:
  pg-data:
```

### 2.2. OpenProject起動

作成したymlが存在するディレクトリでdocker composeコマンドで起動するとymlで指定したimageをdocker hubからダウンロードし起動までしてきます。そのため、初回起動はダウンロードが発生しますので起動に時間がかかります。

```
# docker-compose up -d
```

## 3.OpenProject初期設定

### 3.1. OpenProjectログイン

ブラウザで以下にアクセス

http://<IP Address>:8890

右上の「Sign in」から`admin/admin`でログインします。

![login001](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/openproject/login001.png)

初回ログイン時にパスワード変更が要求されますので、新しいパスワードを入力し[Save]ボタンをクリックする。

![login002](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/openproject/login002.png)

パスワード変更が成功したメッセージが出力すると共にOpenProjectのトップ画面が出力されます。

### 3.2. 日本語化

[Administration]-[System settings]-[Display]タグを選択し[日本語]にチェックを入れる。

![japanese001](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/openproject/japanese001.png)

![japanese002](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/openproject/japanese002.png)

[My Account]-[Settings]-[Language]で"日本語"を選択し[Time zone]で"(GMT+9:00) Tokyo"を選択し、[Save]ボタンをクリックする。 

![japanese003](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/openproject/japanese003.png)

![japanese004](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/openproject/japanese004.png)

### 3.3. プロジェクト作成

トップ画面で[+プロジェクト]ボタンをクリック

![create_project000](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/openproject/create_project000.png)

[名称]にプロジェクト名を入力し[作成]ボタンをクリック

![create_project001](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/openproject/create_project001.png)

### 3.4. ユーザ作成

[管理]-[ユーザ]を選択し、[+ユーザ]をクリック

![user_add001](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/openproject/user_add001.png)

新規ユーザ画面で[][][電子メールアドレス]、[名前]、[苗字]を入力し[作成]ボタンをクリック

![user_add002](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/openproject/user_add002.png)

追加したユーザを選択

![user_add003](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/openproject/user_add003.png)

[言語]で"日本語"を選択し、[パスワード]を入力

![user_add004](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/openproject/user_add004.png)

[タイムゾーン]に"(GMT+9:00) Tokyo"を選択し[保存]ボタンをクリック

![user_add005](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/openproject/user_add005.png)

### 3.5. ユーザをプロジェクトに追加

プロジェクトのトップ画面で[+メンバー]ボタンをクリック

![project_useradd001](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/openproject/project_useradd001.png)

[既存のユーザまたはグループを追加する またはメールで新しいユーザを招待]で追加するユーザを選択し、[追加]ボタンをクリック

![project_useradd002](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/openproject/project_useradd002.png)

### 最後に

とりあえず初期構築までやってみましたが【docker】を使用していることもあり簡単に構築できます。
GUIについてもスケジュールを【マウス操作】で移動や期間を調整できたりと感覚的に操作でき簡単です。【ガントチャート】も作業項目を登録すれば、自動的に作成され【Excel】なんかと比べたらなんて快適なんだろうと思います。バックログに関しても【マウス操作】で操作が簡単にできるのでプロジェクト管理の時間短縮にも繋がるだろう。

とは言え、まずは【運用ルール】の確立させないと、このツールがあったとしても【プロジェクト推進】が上手くいくわけがありません。

ツールに慣れ、きちんとした【運用ルール】を策定することが肝心だと感じました。



























