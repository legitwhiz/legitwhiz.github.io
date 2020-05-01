ドキュメント

https://docs.aws.amazon.com/ja_jp/cli/index.html



## CLIのバージョン

バージョン1：

バージョン2：





## AWS CLI 設定

#### 環境変数

https://docs.aws.amazon.com/ja_jp/cli/latest/userguide/cli-configure-envvars.html

`AWS_ACCESS_KEY_ID`

`AWS_CA_BUNDLE`

`AWS_CONFIG_FILE`

`AWS_DEFAULT_OUTPUT`

`AWS_DEFAULT_REGION`

`AWS_PAGER`

`AWS_PROFILE`

`AWS_ROLE_SESSION_NAME`

`AWS_SECRET_ACCESS_KEY`

`AWS_SESSION_TOKEN`

`AWS_SHARED_CREDENTIALS_FILE`



このなかで最低限設定が必要なもの、および設定箇所





## 各サービスにおけるコマンド一覧

### EC2(EBS)スナップショット

https://docs.aws.amazon.com/ja_jp/cli/latest/reference/ebs/index.html

↓create-snapshot

https://docs.aws.amazon.com/cli/latest/reference/ec2/create-snapshot.html

↓create-snapshots

https://docs.aws.amazon.com/cli/latest/reference/ec2/create-snapshots.html

create-snapshotと、create-snapshot"s" がある。



```
  create-snapshots
[--description <value>]
--instance-specification <value>
[--tag-specifications <value>]
[--dry-run | --no-dry-run]
[--copy-tags-from-source <value>]
[--cli-input-json <value>]
[--generate-cli-skeleton <value>]
```



----------

### RDS

- RDS スナップショットの作成（手動）

`$ aws rds create-db-snapshot \`

`--db-instance-indentifier [DBインスタンス名] \`

`--db-snapshot-identifier [スナップショット名]`

- 【参考】自動バックアップを無効にする

`$ aws rds modify-db-instance \`

`--db-instance-identifier [DBインスタンス名] \`

`--backup-retention-period 0 \`

`--apply-immediately`

--backup-retention-period を0に設定することで、バックアップ保持期間を0(日間)に設定している。

- スナップショットの復元（＝インスタンスを新しく生成）

`$ aws rds restore-db-instance-from-db-snapshot \`
`--db-instance-identifier [新しく生成するインスタンス名] \`
`--db-snapshot-identifier mydbsnapshot`

------

### S3（ファイル単位の操作）

https://aws.amazon.com/jp/getting-started/tutorials/backup-to-s3-cli/

- バケットを作成

`$ aws s3 mb s3://バケット名`

- S3へコピー（アップロード）

`$ aws s3 cp "[ファイルパス指定]" s3://[バケット名]/`

- S3からダウンロードする(カレントディレクトリへ置く場合)

`$ aws s3 cp s3://[バケット名]/[オブジェクトキー] ./`

- バケットから削除

`$ aws s3 rm s3://[バケット名]/[オブジェクトキー]`



シェルにこういったコマンドを組み込むと思うので、参考のスクリプトを乗っけておく。

