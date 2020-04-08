# AWSリソース命名規則

AWSリソースに適当な名前を付けると対象間違いによるオペレーションミスが発生したり、
aws cliを使用したスクリプトやTeraformのコードでハードコーディングとなってしまうの
を避けるためにAWSリソースに命名規則を設ける必要があると考えます。

では、命名規則に何を付与すべきか？
対象システム、環境、種別、目的など
後でリソース名だけで、どの用途で使用するリソースなのか分かるようにすべきかと思います。

また、IPアドレスなど変わる可能性がある要素はリソース名に付けるべきではないです。


## AWSリソース命名規則要素

- 対象システムの名前略称(system_id)
  - システムで一意となる識別子(例：xxx)
  
- 対象サブシステムの名前(subsystem_id)
  - サブシステムで一意となる識別子(例：yyy)

- 環境(env)
  - 本番、検証、開発など(prod/stg/dev)

- Region(tky/ue1/uw2)3文字(略称)

|コード|名前|略称|
|:--:|:--:|:--:|
|ap-northeast-1|アジアパシフィック (東京)|tky|
|ap-northeast-3|アジアパシフィック (大阪: ローカル)|osk|
|us-east-1|米国東部（バージニア北部）|us1|
|us-west-1|米国西部 (北カリフォルニア)|uw1|
|eu-west-3|EU (パリ)|ew3|

- AZ(a/c)AZの最後の1文字(略称)

|コード|略称|
|:--:|:--:|
|ap-northeast-1c|c|
|ap-northeast-1a|a|
|eu-west-3b|b|

- ネットワークレイヤー(nlayer)
  - パブリック、プロテクト、プライベートなど(public/protected/private)

- 種別（type）
  - アプリケーションサーバー、踏み台サーバー、メールサーバーなど(app/bastion/mail)

- 目的（use）
 - ログ保管用、静的コンテンツ配信用など(log/contents)

また、採用する文字は「半角英数字とハイフンもしくはアンダーバーなどの一部記号のみ」と決めるとよいでしょう。
なぜなら、あまり特殊文字を利用するとコード、スクリプト化する際に苦労することになってしまうので。。。

## AWSリソース命名規則

上記、要素を踏まえ以下のように命名規則とすれば、オペミスも軽減できるし、コードにも組み込みやすいかと思います。

|AWSリソース|命名規則|備考||
|:--:|:--:|:--:|
|VPC|{system_id}-{subsystem_id}-{env}-vpc||
|Subnet|{system_id}-{subsystem_id}-{env}-{Region}-{AZ}-{nlayer}-subnet{XX}|XXは連番|
|RouteTable|{system_id}-{subsystem_id}-{env}-{Region}-{AZ}-{nlayer}-rtb{XX}|XXは連番|
|InternetGateway{system_id}-{subsystem_id}-{env}-igw||
|ELB|{system_id}-{subsystem_id}-{env}-{Region}-{AZ}-alb/clb|役割毎に分ける場合はその部分も考慮も必要|
|TargetGroup|{system_id}-{subsystem_id}-{env}-{Region}-{AZ}-tg|同上|
|EC2|{system_id}-{subsystem_id}-{env}-{Region}-{AZ}-{type}{XX}||
|IAMRole|{system_id}-{subsystem_id}-{env}-{type}-role||
|SecurityGroup|{system_id}-{subsystem_id}-{env}-{type}-sg||
|RDS|{system_id}-{subsystem_id}-{env}-{Region}-rds||
|S3{system_id}-{subsystem_id}-{env}-{purpose}||
