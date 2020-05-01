# AWS RDSメモ

[TOC]

## 概要

### RDSとは

> Amazon Relational Database Service (Amazon RDS) は、AWS クラウドでリレーショナルデータベースを簡単にセットアップ、運用、スケーリングできるウェブサービスです。業界標準のリレーショナルデータベース向けに、費用対効果に優れた拡張機能を備え、一般的なデータベース管理タスクを管理します。

## 特徴

### 基本的な役割・機能

#### DBエンジン

* MySQL
* ORACLE
* SQL Server
* PostgreSQL
* Amazon Aurora
* MariaDB

#### パラメータグループ

> 　DB エンジンの設定を管理するには、DB インスタンスをパラメータグループに関連付けます。Amazon RDS は、新しく作成された DB インスタンスに適用されるデフォルト設定でパラメータグループを定義します。カスタマイズした設定を使用して独自のパラメータグループを定義できます。次に、独自のパラメータグループを使用するように DB インスタンスを変更できます。

一度作成したパラメータグループを変更することはできないため，変更する際は新しくパラメータグループを作成して，RDSにアタッチする必要がある．

#### リードレプリカ

> Amazon RDS は、MariaDB、MySQL、Oracle、PostgreSQL、Microsoft SQL Server の DB エンジンに組み込まれたレプリケーション機能を使用して、リードレプリカと呼ばれる特殊なタイプの DB インスタンスをソース DB インスタンスから作成します。ソース DB インスタンスに加えられた更新は、リードレプリカに非同期的にコピーされます。読み込みクエリをアプリケーションからリードレプリカにルーティングすることにより、ソース DB インスタンスへの負荷を減らすことができます。リードレプリカを使うと、単一 DB インスタンスのキャパシティ制約にとらわれることなく伸縮自在にスケールアウトし、読み込み負荷の高いデータベースワークロードに対応できます。

参考: [Amazon RDS での PostgreSQL リードレプリカの使用](https://docs.aws.amazon.com/ja_jp/AmazonRDS/latest/UserGuide/USER_PostgreSQL.Replication.ReadReplicas.html)

#### バックアップ

##### 保存期間

自動バックアップ：0 ～ 35 日間

手動バックアップ：100個まで保存可能

##### 自動バックアップ

* 最初のバクアップはフル．
* 以降は差分バックアップ．

1日1回自動実行される．

##### S3への保存

可能，ただしセットアップにKMSが必要．
　→その場合はS3のライフサイクルで設定可能？

また，IAMロールをポリシーにアタッチしないと，RDSとS3間で通信ができない．

##### スナップショット取得のCLIコマンド

`mydbinstance`というDBインスタンスの`mydbsnapshot`というスナップショットを取得

```shell
aws rds create-db-snapshot \
    --db-instance-identifier mydbinstance \
    --db-snapshot-identifier mydbsnapshot 
```

### モニタリング

#### モニタリングメトリクスタイプ

* CPUまたはRAMの消費量
* ディスクスペースの消費量
* Network Traffic
* データベース接続数
* IOPSメトリクス

#### 自動モニタリングツール

* Amazon RDS イベント

  Amazon RDS では、Amazon RDS のイベントが発生したときに、Amazon Simple Notification Service (Amazon SNS) を使用して通知を送ります。

  イベントカテゴリとイベントメッセージの詳細については[公式ドキュメント](https://docs.aws.amazon.com/ja_jp/AmazonRDS/latest/UserGuide/USER_Events.html#USER_Events.Messages)を参照．

* データベースのログファイル

  RDS PostgreSQL ではクエリおよびエラーログが生成される．接続，切断，及びチェックポイントもエラーログに記録される．PostgreSQLが出力するログの詳細については[PostgreSQLの公式ドキュメント](https://www.postgresql.org/docs/9.6/runtime-config-logging.html)を参照．

  Amazon RDS コンソールまたは Amazon RDS API オペレーションを使用して、データベースのログファイルの表示、ダウンロード、監視を行います。

  ログ保持期間のデフォルト値は4320分（3日間）で最大値は10080分（7日間）．

  PostgreSQLのログをCloudWatch Logsへ発行する方法は[公式ドキュメント](https://docs.aws.amazon.com/ja_jp/AmazonRDS/latest/UserGuide/USER_LogAccess.Concepts.PostgreSQL.html#USER_LogAccess.PostgreSQL.PublishtoCloudWatchLogs)を参照．

* Amazon RDS 拡張モニタリング

  Amazon RDS には，DB インスタンスが実行されているオペレーティングシステム (OS) のリアルタイムのメトリクスが用意されています．コンソールで DB インスタンスのメトリクスを表示したり，選択したモニタリングシステムで Amazon CloudWatch Logs からの拡張モニタリング JSON 出力を使用したりできます．

  拡張モニタリングのメトリクスが便利なのは，DB インスタンス上のさまざまなプロセスやスレッドがどのように CPU を使用しているかを表示するときです．

* Amazon CloudWatch メトリクス

  Amazon RDS は、アクティブな各データベースのメトリクスを 1 分ごとに CloudWatch に自動送信します．CloudWatch で Amazon RDS メトリクスによってさらに課金されることはありません．

  * Amazon CloudWatch Alarms

    特定の期間にわたって単一の Amazon RDS メトリクスを監視し，指定したしきい値に関連するメトリクス値に基づいて 1 つ以上のアクションを実行できます．

  * Amazon CloudWatch Logs

    ほとんどの DB エンジンによって，CloudWatch Logs のデータベースログファイルの監視，保存およびアクセスが可能になります．

#### 手動モニタリングツール

Amazon RDS コンソールから、リソースについて以下の項目をモニタリングできます。

- DB インスタンスへの接続の数
- DB インスタンスへの読み書きオペレーションの量
- DB インスタンスが現在利用しているストレージの量
- DB インスタンスのために利用されるメモリおよび CPU の量
- DB インスタンスとの間で送受信されるネットワークトラフィックの量

CloudWatch ホームページには、次の内容が表示されます。

- 現在のアラームとステータス
- アラームとリソースのグラフ
- サービス状態ステータス

さらに、CloudWatch を使用して次のことが行えます。

- 重視するサービスをモニタリングするための[カスタマイズしたダッシュボード](https://docs.aws.amazon.com/AmazonCloudWatch/latest/DeveloperGuide/CloudWatch_Dashboards.html)を作成する
- メトリクスデータをグラフ化して、問題のトラブルシューティングを行い、傾向を確認する
- AWS リソースのすべてのメトリクスを検索して、参照する
- 問題があることを通知するアラームを作成/編集する

### セキュリティ

#### 暗号化

保管時の Amazon RDS DB インスタンスとスナップショットを暗号化するには、Amazon RDS DB インスタンスの暗号化オプションを有効にします。保管時に暗号化されるデータには、DB インスタンス、自動バックアップ、リードレプリカ、スナップショットの基本的なストレージが含まれます。

Amazon RDS の暗号化された DB インスタンスでは、業界標準の AES-256 暗号化アルゴリズムを使用して、Amazon RDS DB インスタンスをホストしているデータをサーバーで暗号化します。

Amazon RDS リソースを暗号化および復号するために使用するキーを管理するには、[AWS Key Management Service (AWS KMS) ](https://docs.aws.amazon.com/kms/latest/developerguide/)を使用します。

#### IAM

##### Amazon RDS アイデンティティベースのポリシー

IAM アイデンティティベースのポリシーでは、許可または拒否されたアクションとリソースを指定でき、さらにアクションが許可または拒否された条件を指定できます。Amazon RDS は、特定のアクション、リソース、および条件キーをサポートします。

RDSで定義されるアクションは[公式ドキュメント](https://docs.aws.amazon.com/ja_jp/IAM/latest/UserGuide/list_amazonrds.html#amazonrds-actions-as-permissions)を参照．

##### Amazon RDS リソースベースのポリシー

Amazon RDS では、リソースベースのポリシーはサポートされていません。

#### セキュリティグループ

> セキュリティグループにより DB インスタンスに対する送受信トラフィックへのアクセスを制御します。Amazon RDS では、VPC セキュリティグループ、DB セキュリティグループ、EC2-Classic セキュリティグループという 3 種類のセキュリティグループを使用します。

##### VPCセキュリティグループ

> VPC セキュリティグループの各ルールにより、その VPC セキュリティグループに関連付けられている VPC 内の DB インスタンスへのアクセスを特定のソースに許可できます。ソースとしては、アドレスの範囲 (203.0.113.0/24 など) または別の VPC セキュリティグループを指定できます。VPC セキュリティグループをソースとして指定すると、ソース VPC セキュリティグループを使用するすべてのインスタンス (通常はアプリケーションサーバー) からの受信トラフィックを許可することになります。

DBセキュリティグループ，EC2-Classicセキュリティグループについては，今回の案件と直接かかわりがないため，割愛する．

## 注意点

## 料金

料金については[公式ドキュメント](https://docs.aws.amazon.com/ja_jp/AmazonRDS/latest/UserGuide/USER_OnDemandDBInstances.html)を参照．

　参考：[Amazon RDS for PostgreSQLの料金](https://aws.amazon.com/jp/rds/postgresql/pricing/)

## 要調査

## リンク集

* [AWS RDS公式ガイド](https://docs.aws.amazon.com/rds/index.html)
* [サービス別資料 RDS](https://d1.awsstatic.com/webinars/jp/pdf/services/20180425_AWS-BlackBelt_RDS.pdf)
* [Amazon RDSのバックアップでAWS CLIを利用した話](https://toranoana-lab.hatenablog.com/entry/2018/09/04/193157)
* [最も効果的なリスク回避策！rdsのバックアップ方](https://tech-dive.xyz/2019/05/25/%E6%9C%80%E3%82%82%E5%8A%B9%E6%9E%9C%E7%9A%84%E3%81%AA%E3%83%AA%E3%82%B9%E3%82%AF%E5%9B%9E%E9%81%BF%E7%AD%96%EF%BC%81rds%E3%81%AE%E3%83%90%E3%83%83%E3%82%AF%E3%82%A2%E3%83%83%E3%83%97%E6%96%B9/)
* [RDSのメンテナンス基礎知識（パッチ適用）](https://tech-dive.xyz/2019/02/15/post-2144/)
* [S3で一定期間が経過したファイルをライフサイクルで削除したい](https://www.kabegiwablog.com/entry/2017/11/24/090000)
* [[小ネタ] RDS パラメーターグループの動作](https://qiita.com/bee3/items/fde100a1d82b24032ac4)

