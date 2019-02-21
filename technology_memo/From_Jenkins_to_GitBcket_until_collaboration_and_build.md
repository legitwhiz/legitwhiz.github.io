---
layout: default
title: JenkinsとGitBcketの連携・ビルドまで
---

# JenkinsとGitBcketの連携・ビルドまで

Jenkinsで作成したジョブを実行すればGitBcketで管理されたソースを各サーバに配布するとこまでを目的とし検証してみました。

ただし、Jenkinsの連携機能であるGitで pushやPull RequestをきっかけでWebhookにてJenkinsのジョブを自動実行は、ITインフラにおいてシステムの全体停止を招く可能性があるため、採用しないこととする。そのため、Jenkinsのジョブ実行は手動とします。

<u>(Jenkinsの特性を理解できれば後々、masterブランチにpushされた場合は、開発環境にWebhookでビルド・デプロイし、releaseブランチにpushされた場合は、本番環境にWebhookでビルド・デプロイするとこまで自動化したいと思います。)</u>

まずは、GitBcketと連携するためにJenkinsにプラグインを導入しビルドするまでの設定を行っていきます。


前回のJenkins環境の構築は、[Jenkinsをdocker上に構築](https://qiita.com/legitwhiz/items/e6ac1f5a94f09ff2bb1d)を参照。

この検証をするにあたり前提となる運用ルールは、[サイト管理のためのGit運用フローを作ってみました。](https://qiita.com/legitwhiz/items/8e188bc8f9cea64fa839)を参照。

前々回のGitBucket環境の構築は[GitBucketをdockerで構築](https://qiita.com/legitwhiz/items/b1e3b39364e5effb9338)を参照。



ちなみにバージョン管理及びCIでちょいちょい出てくる、ビルドとデプロイの違いを私は理解していなかったので以下のリンクに分かり易く説明されているので参考にさせていただきました。

[ビルドとデプロイって結局なんやねん！？！？！？？？みたいな記事](https://qiita.com/isoyam/items/3d1fc5cf7403cdf4818d)




## 1.Jenkinsの設定
### 1.1. 環境

CentOS : 7.5.1804
Docker : 18.09.0, build 4d60db4
Docker-compose : 1.23.2, build 1110ad01
※Dockerには、[Docker CE]とエンタープライズ版の[Docker EE]がありますが、今回は無償の[Docer CE]を使用します。
GitBucket 4.29.0
Jenkins 	 2.150 (LTS版)



### 1.2. Jenkinsのプラグイン管理

まずは、JenkinsとGitBcketを連携するためにJenkinsにGitBcketプラグインを導入していきたいと思います。

1. Jenkinsにログインし、[ダッシュボード]-[Jennkinsの管理]クリック

![jenkins_plugin_install001](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/jenkins_plugin_install001.png)

2. Jenkins管理画面で[プラグインの管理]をクリック

![jenkins_plugin_install002](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/jenkins_plugin_install002.png)





3. [利用可能]をクリックし、フィルターに以下を入力し、チェックを入れて「ダウンロードして再起動後インストール後」をクリック。

![jenkins_plugin_install003](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/jenkins_plugin_install003.png)

- GIT client plugin ※1
- GIT plugin ※1
- GIT server plugin ※1
- GitBucket Plugin

※1 : Jenkins初回アクセス時に「Install suggested plugin」を選択するか「Select plugins to install」を選択したうえで個別に選択しインストールしていれば必要ありません。



4. 成功と出力されればプラグインのインストールは完了です。

![jenkins_plugin_install004](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/jenkins_plugin_install004.png)

### 1.3. Projectの作成(とりあえずWebhookを使わずビルドまで)

1. 「Enter an item name」にプロジェクト名を入力し、今回はGitBucketとの連携しビルドするので「フリースタイル・プロジェクトのビルド」をクリック。

![jenkins_project_add001](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/jenkins_project_add001.png)

2. 説明にプロジェクトの説明を入力し、GitBcketのURLに「http://<GitBucket server IP>:8888/<GitBucket Username>/<GitBucket Project Name>」を入力。



![jenkins_project_add002](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/jenkins_project_add002.png)



3. ソースコード管理で「Git」を選択しリポジトリURLに「http://<GitBucket server IP>:8888/git/<GitBucket Username>/<GitBucket Project Name>.git」を入力。

![jenkins_project_add003](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/jenkins_project_add003.png)



4. リポジトリの認証情報の「追加」ボタンをクリックし、「ユーザ名」にGitBcketのユーザ名と「パスワード」にGitBcketのユーザのパスワードを入力し「追加」ボタンをクリック。

![jenkins_project_add004](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/jenkins_project_add004.png)



5. リポジトリの認証情報のプルダウンをクリックし、先ほど入力したGitBcketのユーザ名を選択する。

![jenkins_project_add005](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/jenkins_project_add005.png)



6. ビルド・トリガで「Build when a chenge is pushed to GitBucket」、「Pass-through Git Commit」を選択し、「保存」ボタンをクリックする。

![jenkins_project_add006](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/jenkins_project_add006.png)



### 1.4. Jenkinsジョブの実行

1. プロジェクト画面で「ビルドの実行」をクリック。

![jenkins_job_execute001](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/jenkins_job_execute001.png)

2. 「最新のビルド」をクリック。

![jenkins_job_execute002](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/jenkins_job_execute002.png)

3. 出力されたビルド結果を確認し、エラーが出力されていないことを確認する。

![jenkins_job_execute003](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/jenkins_job_execute003.png)



4.Jenkinsサーバにjenkins起動ユーザでSSHでログインし、jenkins起動ユーザのhomeディレクトリの「jenkins_home/workspace/<Jenkins Project Name>」ディレクトリにソースがビルドされていることを確認できました。





### 1.5. GitbucketのWebhook設定

Gitbucketにpushされた場合にwebhookでjonekinsジョブを実行できるように設定します。

ただし、最終的な目標であるmasterブランチにpushされた場合は、開発環境にWebhookでビルド・デプロイし、releaseブランチにpushされた場合は、本番環境にWebhookでビルド・デプロイするとこまで自動化するためにWebhook毎に対象ブランチを設定できると想像していましたが、設定項目を見るとそれにあたる設定項目がないので更に調査が必要です。。。



なので、以下は次回の参考にまで・・・。



1. Gitbucketにログインし「Settings」-「Service Hooks」タブをクリックし「Add webhook」をクリック。

![GitBucket_Webhook_setting001](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/GitBucket_Webhook_setting001.png)



2. Payload URLに「JenkinsのURL＋gitbucket-webhook/」を入力し「Push」にチェックを入れ、「Add webhook」ボタンをクリック。

![GitBucket_Webhook_setting002](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/GitBucket_Webhook_setting002.png)



以上

