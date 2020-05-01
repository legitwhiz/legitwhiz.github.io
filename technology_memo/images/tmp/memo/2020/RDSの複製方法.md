# RDSの複製方法

[公式ドキュメント](https://docs.aws.amazon.com/ja_jp/AmazonRDS/latest/UserGuide/USER_RestoreFromSnapshot.html)によると，できるっぽい．

> Amazon RDS により、DB インスタンスのストレージボリュームのスナップショットが作成され、個々のデータベースだけではなく、その DB インスタンス全体がバックアップされます。この DB スナップショットからの復元で、DB インスタンスを作成できます。DB インスタンスを復元するとき、復元の元となる DB スナップショットの名前を指定し、復元オペレーションから作成される新しい DB インスタンスの名前を指定します。DB スナップショットから既存の DB インスタンスに復元することはできません。復元すると新しい DB インスタンスが作成されます。

## 手順

以下のサイトを参考に

[[AWS] RDS スナップショットからDBをリストア(コピー)](https://agohack.com/rds-db-restoring/)

> ※ スナップショットの復元によって、 VPC 、サブネットグループ、パブリックアクセシビリティ、アベイラビリティーゾーン、VPC セキュリティグループは、変更することが可能。
> （ 1 度 DB を作成するとアベイラビリティーゾーンとかは変えられないので、復元とかで変更する。）

> 「DB パラメータグループ」は、コピー元の情報が引き継がれていないので、必要に応じてコピー元と同じパラメータグループを選択。

## 考慮事項

### パラメータグループ

DBの設定値．

> 復元された DB インスタンスを適切なパラメータグループと関連付けることができるように、作成する DB スナップショットのパラメータグループを保持することをお勧めします。DB インスタンスを復元するときにパラメータグループを指定できます。

### セキュリティグループ

> DB インスタンスを復元すると、デフォルトのセキュリティグループは、復元済みインスタンスに関連付けられます。
>
> 復元が完了し、新しい DB インスタンスが利用できるようになったらすぐに、復元の元となるスナップショットによって使用されているカスタムセキュリティグループを関連付けることができます。RDS コンソール、AWS CLI `modify-db-instance` コマンドまたは `ModifyDBInstance` Amazon RDS API 操作を介して DB インスタンス を修正することで、これらの変更を適用します。詳細については、「[Amazon RDS DB インスタンスを変更する](https://docs.aws.amazon.com/ja_jp/AmazonRDS/latest/UserGuide/Overview.DBInstance.Modifying.html)」を参照してください。

### オプショングループ

→AWS RDSのPostgreSQLにはオプショングループ機能が対応していないので，今回は無視していい？

公式ドキュメント：[オプショングループを使用する](https://docs.aws.amazon.com/ja_jp/AmazonRDS/latest/UserGuide/USER_WorkingWithOptionGroups.html)

> DB インスタンスに割り当てると、オプショングループは DB インスタンスが存在するサポート対象プラットフォーム、つまり VPC または EC2-Classic (VPC 以外) にもリンクされます。DB インスタンスが VPC 内にある場合、その DB インスタンスに関連付けられているオプショングループはその VPC にリンクされます。つまり、別の VPC または別のプラットフォームに DB インスタンスを復元しようとしても、そのインスタンスに割り当てられているオプショングループは使用できません。**別の VPC 内にまたは別のプラットフォーム上に DB インスタンスを復元する場合は、デフォルトのオプショングループをインスタンスに割り当てるか、その VPC またはプラットフォームにリンクされているオプショングループをインスタンスに割り当てるか、新しいオプショングループを作成してインスタンスに割り当てる必要があります。**

※太字は引用者による

## 参考資料

* [公式ドキュメント](https://docs.aws.amazon.com/ja_jp/AmazonRDS/latest/UserGuide/USER_RestoreFromSnapshot.html)
* [【AWS】RDSのインスタンスの複製](https://scrapbox.io/tamago324-05149866/%E3%80%90AWS%E3%80%91RDS%E3%81%AE%E3%82%A4%E3%83%B3%E3%82%B9%E3%82%BF%E3%83%B3%E3%82%B9%E3%81%AE%E8%A4%87%E8%A3%BD)
* [[AWS] RDS スナップショットからDBをリストア(コピー)](https://agohack.com/rds-db-restoring/)



#### 余談

MySQLならdumpでデータベース構造をコピーできるっぽい？

https://rfs.jp/server/aws/rds-mysqldump-copy.html

→PostgreSQLならばpg_dumpでデータベース構造をコピーできるかも？