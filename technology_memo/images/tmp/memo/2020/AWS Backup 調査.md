# 【AWS Backup】
アーキテクトと、コストを把握する。
対象：OSバックアップ、DBバックアップとリストア

ドキュメント：
https://docs.aws.amazon.com/ja_jp/aws-backup/latest/devguide/whatisbackup.html

## はっきりさせたい

- EC2 バックアップ 設定管理方法
- 世代管理　いつでも7日前の状態まで復旧できるか
- バックアップ復元

- RDS バックアップ 設定管理方法
- バックアップはS3に保存されるのか。S3コンソールで操作できるのか。バケット指定できるのか　→　否。保存先はS3だがユーザからは見えないのでS3コンソールによる操作やバケット指定は不可

- バックアップ対象の、どこまで管理できるのか、線引きする
- 料金



## バックアップ対象の整理

【AWSBackup 対象外】

ファイルバックアップ → AWS Backup 管理対象外。シェルでS3にアップロード。ログファイルはCloudWatch Logs？

| **バックアップ対象データ** | **Web** | **AP** | **DB** |
| -------------------------- | ------- | ------ | ------ |
| OCR読取イメージファイル    | ―       | 〇     | ―      |
| 帳票データ                 | ―       | 〇     | ―      |
| 各種ログファイル           | 〇      | 〇     | ―      |

【AWS Backup 対象】

システムバックアップ → AWS Backup 管理対象(EC2のみ？RDSは自身の自動バックアップ機能を使う？)

| **バックアップ対象データ** | **Web** | **AP** | **DB** |
| -------------------------- | ------- | ------ | ------ |
| システムイメージ(全体)     | 〇      | 〇     | 〇     |
| システムイメージ(差分)     | ―       | ―      | 〇     |

【メモ：世代管理一覧】

| **バックアップデータ**            | **周期** | **世代数** |
| --------------------------------- | -------- | ---------- |
| **業務DBデータ フルバックアップ** | **週次** | **1世代**  |
| **業務DBデータ 差分バックアップ** | **日次** | **6世代**  |
| OCR読取イメージファイル           | 日次     | 約30世代   |
| 帳票データ                        | 日次     | 30世代？   |
| 各種ログファイル                  | 日次     | 5年        |
| **システムバックアップ**          | **随時** | **1世代**  |



## AWS Backup 使い方の整理

#### なにができるの

##### 	AWS Backup と他の AWS サービスとの連携

> ​	AWS Backup は AWS サービスに既に存在するバックアップ機能を使用し、それら	を一元管理する機能を実装します。たとえば、バックアッププランを作成すると、	そのバックアッププランに従って自動的にバックアップを作成するときに、AWS 	Backup は EBS スナップショット機能を使用します。
>
> ​	https://docs.aws.amazon.com/ja_jp/aws-backup/latest/devguide/how-it-works.html

​	バックアップ処理自体は、RDSやEC2が元から備えているバックアップ機能を用いるようだ。AWS Backup は、各サービスに備わるバックアップ機能の、全体的なマネジメントといっていいのかな



	##### 	保存先について

​	EBSスナップショットは、保存先はS3ではあるが、ただしユーザからみえない別基盤のS3に保存される。なのでS3コンソールから確認・操作することはできない。バケット指定もできない。

AWS Backupのコンソールから、編集・復元等の操作を行う。

あるいは各サービスのコンソールからも多分バックアップを見れると思う。（それらしき記述をしていた）

https://www.climb.co.jp/blog_vmware/aws-7412

​	RDSバックアップも同様？



##### 	AWS Backupを使うメリットは





#### バックアッププラン

AWS BackupでEC2・RDSのバックアップを取得してみた↓

https://engineers.weddingpark.co.jp/?p=2709



https://dev.classmethod.jp/articles/aws-backup/

バックアッププラン作成時に、「バックアップルール」＝スケジュールを設定する。



↓Backup rules 設定内容↓

https://qiita.com/nasuvitz/items/e5fe886b5282c49608b5

> - Frequency
>   - Daily
>   - Weekly
>   - Monthly
>   - Custom cron expression
> - Backup window
>   - Use backup window default - recommend
>   - Customize backup window
> - Lifecycle　
>   - Transition to cold storage
>     - Never
>     - Days after creation
>     - Weeks after creation
>     - Months after creation
>     - Years after creation
>   - Expire　**→　世代管理**
>     - Days after creation
>     - Weeks after creation
>     - Months after creation
>     - Years after creation
> - Backup vault
>   - Default
>   - Create new Backup vault





#### オンデマンドバックアップ

任意のタイミングで取得するバックアップ。（＝手動？）



#### タグによる管理

各リソースにタグをつけて、バックアッププラン作成時に、タグでバックアップ対象リソースを指定する。





#### バックアップボールト

https://docs.aws.amazon.com/ja_jp/aws-backup/latest/devguide/vaults.html

AWS Backupで取得したバックアップを整理できる。

KMS 暗号化







#### 世代管理について

https://dev.classmethod.jp/articles/how-aws-backup-and-amazon-dlm-manages-backup-lifecycle/

ライフサイクル管理が可能。

バックアッププラン作成時に、expireというパラメータを設定する。

> AWS Backupは各スナップショットをどれだけの期間残すか(expire)指定します。





#### 復元・リストアについて

復元時は、新しくインスタンスを生成して、そのインスタンス内に、バックアップ時のサーバーのデータを復元する。









## EC2システムバックアップ(EBSボリュームスナップショット)



https://qiita.com/nasuvitz/items/e5fe886b5282c49608b5



snapshot取得・復元ロジックを整理し、課金も正しく理解する

https://qiita.com/kaojiri/items/1c4a95c271fb1584476a







## RDS DBスナップショット



> また、AWS Backup を使用して、Amazon RDS DB インスタンスのバックアップを管理することもできます。AWS Backup によって管理されているバックアップは、**手動のスナップショット制限の手動スナップショット**とみなされます。

https://docs.aws.amazon.com/ja_jp/AmazonRDS/latest/UserGuide/USER_WorkingWithAutomatedBackups.html





S3（バケット指定可）にエクスポート(Apache Parquet形式)するやり方

> 手動スナップショット、自動システムスナップショット、AWS Backup サービスで作成されたスナップショットなど、すべてのタイプの DB スナップショットをエクスポートできます。

https://docs.aws.amazon.com/ja_jp/AmazonRDS/latest/UserGuide/USER_ExportSnapshot.html



RDS　よくある質問↓

「Q: 自動化バックアップと DB スナップショットの違いは何ですか?」

https://aws.amazon.com/jp/rds/faqs/









↓RDS自身による自動バックアップ

https://docs.aws.amazon.com/ja_jp/AmazonRDS/latest/UserGuide/USER_WorkingWithAutomatedBackups.html





## AWS CLI によるバックアップ





## コスト
https://aws.amazon.com/jp/backup/pricing/
AWS Backup では、その月に使用したバックアップストレージ量および復元したバックアップデータの量に対してのみ料金をお支払いいただきます。最低料金および初期費用は発生しません。

+-------------------------------+
|製品料金における用語|
+--------------------+----------------------------------------------------------------------------------------------------+
| GB-時間: 1 時間あたりの平均バックアップストレージ使用量 (ギガバイト) の測定単位   |
| GB-月: 1 か月あたりの平均バックアップストレージ使用量 (ギガバイト) の測定単位       |
+--------------------------------------------------------------------------------------------------------------------------+

Amazon EBSボリュームスナップショット     0.05 USD/月 (GBあたり)
Amazon RDS データベーススナップショット  0.095 USD/月 (GB あたり)

※AWS Backup独自の料金体系が(EFSを除いて)あるわけではなく、EBS、RDSの各サービスが提供している料金体系に従う。
・EBSスナップショットの料金↓（料金の例あり）
https://aws.amazon.com/jp/ebs/pricing/

・
汎用 SSD (gp2) ボリュームのボリュームストレージの料金はプロビジョニングした容量 (GB/月) で決まり、お客様がそのストレージを解放するまで毎月料金が発生します。gp2 ボリュームのプロビジョニング済みストレージは、1 秒ごとに課金されます (最小課金時間は 60 秒)。I/O はボリュームの料金に含まれているため、プロビジョニングした各ストレージの GB に対してのみ課金されます。

◎ EBS
～～～～～～～～～～～～～
1USD = 108JPYとすると

<1000GB のEBSボリュームスナップショット>
0.05USD x 1000GB → 50USD
50USD x 108JPY = 5400JPY

<1000GB のRDS データベーススナップショット>
0.095 x 1000GB → 95USD
95 USD x 108JPY = 10260JPY
～～～～～～～～～～～～～

↑　これは算出間違ってる。「月の平均使用量（GB）」にたいして、いくらか、をかけなければならない。

実使用容量分をさらに圧縮した結果のサイズ



◎ RDS
https://aws.amazon.com/jp/rds/postgresql/pricing/?pg=pr&loc=3


db.m5.xlarge



■　S3エクスポート

|              S3エクスポート               |          |
| :---------------------------------------: | -------- |
| スナップショットサイズ 1 GB あたりの料金: | 0.012USD |

> たとえば、100 GB のスナップショットをお持ちで、このスナップショットから 10 GB のテーブルをフィルタリングで選択して、Amazon S3 にエクスポートするとします。このデータをエクスポートするには、100 GB * スナップショットサイズ 1 GB あたり 0.012USD の料金が発生します。それ以降、同じスナップショットからデータをエクスポートしても料金が毎回加算されることはありません。

0.012 * 1000 = 12

12*108 = 1296 yen



・復元の料金
https://aws.amazon.com/jp/backup/pricing/
Amazon EBS ボリュームスナップショット 無料
Amazon RDS データベーススナップショット 無料





## その他・メモ

### 暗号化

AWS でのすべてのバックアップは AWS KMS 管理キー (SSE-KMS) を使用して暗号化されます。

https://docs.aws.amazon.com/ja_jp/AmazonS3/latest/dev/object-lifecycle-mgmt.html



### ウォームストレージとコールドストレージ

「EBS ボリュームスナップショット」と、「RDSデータベーススナップショット」は、コールドストレージ（長期保存用の安いストレージ？）に対応しておらず、ウォームストレージのみのようなので、考慮しない。

（「EFS システムバックアップ」しかコールドストレージに移せない。）



