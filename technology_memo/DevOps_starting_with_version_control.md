---
layout: default
title: バージョン管理から始めるDevOps(今までの総まとめ)
---

# バージョン管理から始めるDevOps(今までの総まとめ)

以下は、今ままで私が執筆した、DevOps関連記事の目次として記載しております。

まずは、 **【DevOps】** (開発・運用・品質管理が三位一体となったソフトウェア開発体制)とはなんぞや？と言葉じたいを知らない人は、以下のリンクを参照して下さい。

[「DevOps」を全く知らない人のために「DevOps」の魅力を伝えるための「DevOps」入門](https://qiita.com/bremen/items/44c3de10413f45f9f41e)

なお、DevOps（デブオプス）には、１１の構成要素があります。構成要素については以下を参照して下さい。

[DevOpsを実現する11の要素](https://tracpath.com/works/devops/11_topics_for_devops/)

運用で「自動化して運用の工数削減！！エンジニアの空いた稼働を他にあてて利益をアップ！！」
という戦略で偉い人から自動化しろ！！と言われたことはありませんか？

利益アップしろ言われてないにしろ、日々の運用作業に殆どの時間を費やすのではなく、より **【効率的(工数削減)】** に作業し、 **【信頼性アップ】** していくことを目標としているのが **【DevOps】** です。

また、自動化することで運用メンバーの負荷を下げ、更に業務改善を進めることで運用メンバーの **【スキル向上】** も目標としています。

セキュリティ面でクラウドには一抹の不安を覚える現場もあるので、オンプレで実現可能なようにツールは選定しております。(クラウドサービスで実現可能な範囲については、おいおい執筆したいと思います。)

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/DevOps/DevOps.png" width="840">

 **【DevOps】** (開発・運用・品質管理が三位一体となったソフトウェア開発体制)の手始めとして、まずは、 **バージョン管理システム** を **【Git】** を使用し、 **【GitBucket】** でリポジトリ環境を構築しました。

次に **CI環境(継続的インテグレーション)** を **【Jenkins】** で構築しております。

運用ルールをどう定めるかによって、運用ツールも変わりますが、cronの変わりに **ジョブスケジューラー** の **【Rundeck】** を構築しましたので運用でどう使用するかは検討して下さい。

また、インフラ環境(OS、ミドルウェア)の環境構築を自動化するための **構成管理ツール** の **【Ansible】** も導入しております。

 **【GitBucket】** と **【Jenkins】** については、コンテナ型の仮想環境の **【Docker】** のコンテナ上に構築しております。
プロジェクトのタスク管理としてガントチャートやインシデント管理も使用できる **【OpenProject】** を導入しています。

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/DevOps/docker.png" width="240">

Dockerの構築方法及び起動・停止は、以下を参照して下さい。

[【Dockerでコンテナ環境簡単構築】](technology_memo/Docker_container_Environment.html)
[Docker入門](https://knowledge.sakura.ad.jp/13265/)

## 1. バージョン管理システム GitBucket

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/DevOps/GitBucket_logo.png" width="320">

### 1.1. 構築方法及び起動・停止

構築方法及び起動・停止は、以下を参照して下さい。
[【GitBucketをdockerで構築】](technology_memo/GitBucket_container_Environment.html)

### 1.2. Git運用ルール

また、Gitの運用ルールを簡単に作成しましたので、参考にして下さい。
(運用ルールは、実運用してみて使いやすいように改修する必要があると思っています。)

[【サイト管理のためのGit運用フローを作ってみました。】](technology_memo/Gitbucket_Resource_management.html)

## 2. CI( 継続的インテグレーション)環境  Jenkins

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/DevOps/jenkins_logo.png" width="460">

### 2.1. 構築方法及び起動・停止

構築方法及び起動・停止は、以下を参照して下さい。

[【Jenkinsをdocker上に構築】](technology_memo/Jenkins_container_Environment.html)

### 2.2. Jenkins運用ルール

現状、GitBucketにプッシュされたソースをジョブ実行により、サーバ上の
ソースを配置(ビルド)するようにしております。(ここまでは実装済み)

1. GitBucketでのバージョン管理する際に各サーバ毎にフォルダを分け、Jenkinsによってサーバ上にソースを配置(ビルド)する。

2. 各サーバに必要なソースを配布(デプロイ)を実行するJenkinsジョブを作成する。

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/DevOps/Jenkins_rule.png" width="640">

※Jenkinsの最終形態として【１．】と【２．】の間に『ant,Mavenもしくはスクリプトで【テスト環境に配布】』し『JenkinsジョブでServerspec等のテストツールを実行し【単体試験】を実行する』を実装する必要があります。

最終的な【Jenkins】のイメージフロー図

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/DevOps/Jenkins_flow.png" width="640">

## 3.ジョブスケジューラ環境 Rundeck

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/DevOps/rundeck.png" width="420">

### ３.1.  構築方法及び起動・停止

構築方法及び起動・停止は、以下を参照して下さい。

[【OSS ジョブスケジューラ(Rundeck)を自宅サーバに入れてみた】](technology_memo/OSS_job_scheduler_Rundeck_Part1.html)

[【OSS ジョブスケジューラ(Rundeck)を自宅サーバに入れてみた_Part2】](technology_memo/OSS_job_scheduler_Rundeck_Part2.html)

[【OSS ジョブスケジューラ(Rundeck)を自宅サーバに入れてみた_Part3】](technology_memo/OSS_job_scheduler_Rundeck_Part3.html)

## 4.構成管理ツール Ansible

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/DevOps/Ansible.png" width="240">

### 4.1.  構築

構築方法は、以下を参照して下さい。

[【Ansibleで始める構成管理ツール_Part1】](technology_memo/Ansible_Part1.html)

[【Ansibleで始める構成管理ツール_Part2】](technology_memo/Ansible_Part2.html)

### 4.2.  実行方法

```console
# ansible-playbook -i /etc/ansible/inventories/production/hosts /etc/ansible/site.yml
```

## 5.プロジェクト管理ツール OpenProject

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/DevOps/Logo-OpenProject.png" width="320">

### 5.1 構築

構築方法は、以下を参照して下さい。

[【OpenProjectで始めるプロジェクト管理】](technology_memo/Project_management_starting_with_OpenProject.html)

## 6.自動テストツール Serverspec

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/DevOps/Serverspec_logo.png" width="320">

### 6.1. 構築

[【インフラのテスト自動化を実現するツール「Serverspec」】](technology_memo/Tool_Serverspec_to_realize_infrastructure_test_automation.html)

### 6.2. 実行方法

```
# SPEC_ENV=production bundle exec rake spec:all
```

## 7. チャットツール Rocket.chat

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/DevOps/rocket.chat_logo.png" width="320">

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/DevOps/hubot_logo.png" width="320">

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/DevOps/rocket.chat_hubot_jenkins.png" width="640">

### 7.1 構築

[【プロジェクトコミュニケーションツール『Rocket.chat』＆bot】](technology_memo/Project_communication_tool_Rocket.chat_and_bot.html)

# 最後に

DevOps関連ツールは、アジャイル開発スタイルで徐々に運用を改良・発展させるべきだと考えます。
そのためには、チームメンバーや組織の文化や考え方、個人の意識までも変えていかないといけません。
そうでないとDevOpsは成り立たず、定着していかず、陳腐化してしまいます。
なので、トップダウンで指示するのではなくチームメンバー全員で仕事を効率的に品質を上げて楽をするつもりで進めていきましょう。

また、将来的にはDevOpsからMLOps(DevOpsを機械学習にて自動運用する)に発展する必要がありことを念頭に置いてDevOpsを発展させることも意識しなければなりません。
