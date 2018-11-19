# OSS ジョブスケジューラ(Rundeck)を自宅サーバに入れてみた Part3

rundeckを運用するための機能に【Rundeck cli】と【Rundeck API】があります。
【Rundeck API】は、aclを設定し『API Token』を取得する必要があり、【Rundeck cli】は別途インストールする必要があります。

【Rundeck cli】と【Rundeck API】はどちらも機能面はほぼ同じと考えていいでしょうが使い分けは、運用でより見やすく容易にするための作り込みや他システムとAPI連携をするなら【Rundeck API】で、大量の設定追加をする場合は【Rundeck cli】とするとよいかと考えます。

## 0.検証環境

OS:Ubuntu 16.04 LTS
OS:CentOS 7.5
ミドルウェア:Rundeck 3.0.8 (20181029)
前提ミドルウェア:JRE 1.8.0_181
Rundeck cli 1.1.0

## 1.【Rundeck API】

### 1.1. Rundeck API設定

【Rundeck API】で使用する『API Token』は、作成してからデフォルト30日が有効期限となります。
30日毎に『API Token』の再作成するのは面倒なので、有効期限を無期限に設定します。
※『API Token』を更新するAPIもあるが、aclで何故か弾かれてしまうので無期限にしています。

```
# vi /etc/rundeck/rundeck-config.properties
rundeck.api.tokens.duration.max = 0
```

- ログイン後のGUI画面の右上の[Profile]ボタンから[User API Tokens]作成画面へ
- 「Expiration in」を0で設定すると有効期限が無期限になります。[Show Token]ボタンを押すと現在の『API Token』が表示されます。
- Rolesは、管理者用ユーザのため全ての権限を与えるため何も設定しておりません。参考にした他HPでは「*」で全ての権限を割り当てるとしていましたが「api version27」では逆に何も権限が割り当てられませんでした。(私はここでハマリましたw)

<div align="center">
<img src="https://drive.google.com/uc?export=view&id=10NrUnMVb6gBkL9EkzlOoZZMamijHJ4ic" width=450>
</div>

### 1.2.ジョブの一覧取得

■ジョブの一覧
・リクエスト

```
# export RD_PROJECT=<Project Name>
# export RD_URL=https://<ドメイン名>/rundeck/api/<api version>
# export RD_TOKEN=<1.1.で取得したトークン>
# curl --verbose -H 'Accept:application/json ' -H "X-Rundeck-Auth-Token: ${RD_TOKEN}" ${RD_URL}/project/${RD_PROJECT}/jobs | jq '.'

```

※「|jq '.'」は、出力したjsonを成型するために入れています。「jq」をインストールしていなければ代用として「| python -mjson.tool」でも同様な結果を取得することができます。

・レスポンス

```
[
  {
    "href": "https://<ドメイン名>/rundeck/api/<api version>/job/ebe1539b-85d2-47c8-afe0-0d7ac1665338",
    "id": "ebe1539b-85d2-47c8-afe0-0d7ac1665338",
    "scheduleEnabled": true,
    "scheduled": true,
    "enabled": true,
    "permalink": "https://<ドメイン名>/rundeck/project/<Project Name>/job/show/ebe1539b-85d2-47c8-afe0-0d7ac1665338",
    "group": null,
    "description": "",
    "project": "<Project Name>",
    "name": "Cript_Update"
  }
]
```

### 1.3.ジョブの実行

・リクエスト

```
# export RD_PROJECT=<Project Name>
# export RD_URL=https://<ドメイン名>/rundeck/api/<api version>
# export RD_TOKEN=<1.1.で取得したトークン>
# export JobID=<job UUID> ※UUIDは、[edit job]の最下部で確認できます。
# curl -X POST -H 'Accept:application/json ' -H "X-Rundeck-Auth-Token: ${RD_TOKEN}" ${RD_URL}/job/${JobID}/executions | jq '.'
# 
```

・レスポンス

```
{
  "id": 2338,
  "href": "https://<ドメイン名>/rundeck/api/<api version>/execution/2338",
  "permalink": "https://<ドメイン名>/rundeck/project/<Project Name>/execution/show/2338",
  "status": "running",
  "project": <Project Name>,
  "executionType": "user",
  "user": "admin",
  "date-started": {
    "unixtime": 1542161193907,
    "date": "2018-11-14T02:06:33Z"
  },
  "job": {
    "id": "<job UUID>",
    "averageDuration": 37218,
    "name": "<Job Name>",
    "group": "",
    "project": <Project Name>,
    "description": "",
    "href": "https://<ドメイン名>/rundeck/api/<api version>/job/<job UUID>",
    "permalink": "https://<ドメイン名>/rundeck/project/<Project Name>/job/show/<job UUID>"
  },
  "description": "sudo -S whoami [... 3 steps]",
  "argstring": null
}
```

### 1.4.ジョブの実行結果確認

・リクエスト

```
# export RD_PROJECT=<Project Name>
# export RD_URL=https://<ドメイン名>/rundeck/api/<api version>
# export RD_TOKEN=<1.1.で取得したトークン>
# export JobID=<job UUID> ※UUIDは、[edit job]の最下部で確認できます。
# curl -X GET -H 'Accept:application/json ' -H "X-Rundeck-Auth-Token: ${RD_TOKEN}" ${RD_URL}/job/${JobID}/executions  | jq '.'
# 
```

・レスポンス (実行した時にidと同じidを確認すること)

```
{
  "paging": {
    "count": 107,
    "total": 107,
    "offset": 0,
    "max": 20
  },
  "executions": [
    {
      "id": 2338,
      "href": "https://<ドメイン名>/rundeck/api/<api version>/execution/2338",
      "permalink": "https://<ドメイン名>/rundeck/project/<Project Name>/execution/show/2338",
      "status": "succeeded",
      "project": "<Project Name>",
      "executionType": "user",
      "user": "admin",
      "date-started": {
        "unixtime": 1542161193907,
        "date": "2018-11-14T02:06:33Z"
      },
      "date-ended": {
        "unixtime": 1542161195510,
        "date": "2018-11-14T02:06:35Z"
      },
      "job": {
        "id": "<job UUID>",
        "averageDuration": 32977,
        "name": "<Job Name>",
        "group": "",
        "project": "<Project Name>",
        "description": "",
        "href": "https://<ドメイン名>/rundeck/api/<api version>/job/<job UUID>",
        "permalink": "https://<ドメイン名>/rundeck/project/<Project Name>/job/show/<job UUID>"
      },
      "description": "sudo -S whoami [... 3 steps]",
      "argstring": null,
      "successfulNodes": [
        "<ドメイン名>"
      ]
    }
  ]
}
```

[status]が[succeeded]となっていればジョブが正常終了したことのようだ。

また、[executionType]が[user]となっているため、ユーザによる手動実行だということが分かります。※スケジュール実行した際は、[scheduled]となります。

## 2.【Rundeck cli】

もともと、Rundeckには、Command Line Toolがパッケージに同梱されていましたが、Ver2.7以降からは、【Rundeck cli】と別パッケージに変更されました。

運用するうえでGUIは、見やすいのでいいでしょうが、特に設定等はGUIでチマチマ設定するのは規模が大きくなれば成る程、苦痛ですw

そこで便利なコマンドラインで使用できる【Rundeck cli】を導入してみました。

[Rundeck cli](https://github.com/rundeck/rundeck-cli)

### 2.1.Rundeck cliインストール

■Ubuntu 16.04 LTS

```
# echo "deb https://dl.bintray.com/rundeck/rundeck-deb /" | sudo tee -a /etc/apt/sources.list
# curl "https://bintray.com/user/downloadSubjectPublicKey?username=bintray" > /tmp/bintray.gpg.key
# apt-key add - < /tmp/bintray.gpg.key
# apt -y install apt-transport-https
# apt -y update
# apt -y install rundeck-cli
# apt -y install jq
```

■CentOS 7.5

```
# wget https://bintray.com/rundeck/rundeck-rpm/rpm -O bintray.repo
# mv bintray.repo /etc/yum.repos.d/
# yum install rundeck-cli
# yum install jq
```

### 2.2.環境変数設定

```
$ vi ~/.bash_profile
export RD_URL=https://<ドメイン名>/rundeck
export RD_PROJECT=<Project Name>
export RD_TOKEN=<1.1.で取得したトークン>
export RD_DATE_FORMAT="yyyy-MM-dd' 'HH:mm:ss"
export RD_HTTP_TIMEOUT=30
export RD_CONNECT_RETRY=false
export RD_FORMAT=json
```

### 2.3.ジョブの一覧取得

■ジョブ一覧
・リクエスト

```
# rd jobs list
```

・レスポンス

```
<job UUID> <Job Name>
```

### 2.4.ジョブの実行

■ジョブ実行
・リクエスト

```
# rd run -j rundeck_executions_cleanup -p <Project Name>
```
・レスポンス

```
# Found matching job: <job UUID>
<Job Name>
# Execution started: [2363] <job UUID>
/rundeck_executions_cleanup <https://<ドメイン名>/rundeck/project/<Project Name>/execution/show/2363>
```

### 2.5.ジョブの実行結果確認

■ジョブ実行結果確認
・リクエスト

```
rd executions query -v
```
・レスポンス	

```
# Page [1/1] results 1 - 4 (of 4 by 20)
failedNodes:
  description: sudo -S whoami [... 3 steps]
  project: <Project Name>
  successfulNodes:
    <hostname>

  argstring:
  serverUUID:
  dateStarted: 2018-11-14T15:10:00+0900
  dateEnded: 2018-11-14T15:10:27+0900
  id: 2364
  href: https://<ドメイン名>rundeck/api<api version>execution/2364
  permalink: https://<ドメイン名>rundeck/project/<Project Name>/execution/show/2364
  job:
    id: <job UUID>
    name: IP_Set_ie
    group:
    project: <Project Name>
    href: https://<ドメイン名>rundeck/api<api version>job/<job UUID>
    permalink: https://<ドメイン名>rundeck/project/<Project Name>/job/show/<job UUID>
    description:
    averageDuration: 38086

  user: admin
  status: succeeded

failedNodes:
  description: export RD_PROJECT=<Project Name> (6 more lines)
  project: <Project Name>
  successfulNodes:
    regulus0134.dip.jp

  argstring:
  serverUUID:
  dateStarted: 2018-11-14T15:09:59+0900
  dateEnded: 2018-11-14T15:10:03+0900
  id: 2363
  href: https://<ドメイン名>rundeck/api<api version>execution/2363
  permalink: https://<ドメイン名>rundeck/project/<Project Name>/execution/show/2363
  job:
    id: eb463d18-2e6b-46b8-9a04-b09fa5de2940
    name: rundeck_executions_cleanup
    group:
    project: <Project Name>
    href: https://<ドメイン名>rundeck/api<api version>job/eb463d18-2e6b-46b8-9a04-b09fa5de2940
    permalink: https://<ドメイン名>rundeck/project/<Project Name>/job/show/eb463d18-2e6b-46b8-9a04-b09fa5de2940
    description:
    averageDuration: 2752

  user: admin
  status: succeeded
```

### 2.6.ジョブ定義のバックアップ

■ジョブ定義のバックアップ

```
# rd jobs list -f /tmp/jobs.xml -p <Project Name>
```

### 2.7.ジョブ定義のリストア

■ジョブ定義のリストア

```
# rd jobs load -f /tmp/jobs.xml -p <Project Name>
```

## 3.Rundeck 運用

### 3.1..Rundeckでユーザ毎のアクセス権限設定

運用担当者により役割が違うので以下のように役割を想定し、ユーザを追加・権限を設定しました。

- Rundeck管理者 →全てのProjectの権限及びミドルウェアの管理者として使用(admin)
- Project管理者 →対象Projectの実行、開発(ProjectAadmin) 開発者がAPIを使用して運用するため実行ユーザ
- Project開発者 →対象Projectの実行、開発(ProjectAdev)
- Project運用者 →対象Projectの参照のみ(ProjectAope)

#### 3.1.1.ユーザ追加

まずは、[/etc/rundeck/realm.properties]を編集することでユーザをします。
※今のところGUIでユーザを直接追加することはできません。

```
# sudo vi /etc/rundeck/realm.properties

admin: MD5:<encryption password>,user,admin,architect,deploy,build,api_token_group
ProjectAadmin: MD5:<encryption password>,user,admin,architect,deploy,build,api_token_group
ProjectAdev: MD5:<encryption password>,user,admin,architect,deploy,build
ProjectAope: MD5:<encryption password>,user
```

※暗号化パスワードの生成は、Part2を参照。

ちなみに設定ファイルを修正することでユーザ追加することは出来ますが、一度でもGUIでログインしていないと、Rundeck管理者ユーザでもGUIからユーザの参照が出来ません。

#### 3.1.2.ACL設定

ACLは、主に[System ACL]、[Project ACL]に分かれます。
[System ACL]は、Rundeckシステムの権限を設定する箇所で[context:application:'rundeck']と記載された箇所となり、
[Project ACL]は、プロジェクト毎の権限を設定する箇所と[context:project: '<Project name>']と記載された箇所となります。
追加したユーザは対象プロジェクトにのみ権限を持たせないように設定する。

・Project管理者(ProjectAadmin)の権限設定

【Project管理者】は、対象Projectの実行、開発と開発者がAPIを使用して運用するため実行ユーザとしているため、プロジェクトには全ての権限を与えるが、Rundeckシステムに関しては、制限をかけることとしています。

```
# vi /etc/rundeck/ProjectAadmin.aclpolicy

description: Project settings for ProjectAadmin user
context:
  project: '<Project name>' # 対象Projectに対する権限の設定
for:
  resource:
    - allow: '*'
  adhoc:
    - allow: '*'
  job:
    - allow: '*'
  node:
    - allow: '*'
by:
    username: ProjectAadmin

---

description: Rundeck settings for ProjectAadmin user
context:
  application: 'rundeck'
for:
  resource:
    - equals:
        kind: project
        deny: [create]  # プロジェクトの作成は禁止
    - equals:
        kind: system
        deny: [readenable_executions,disable_executions,admin]    # システム情報の閲覧禁止
    - equals:
        kind: user
        deny: [admin]   # ユーザ情報の編集禁止
    - equals:
        kind: system_acl
        deny: [read,create,update,delete,admin] # system ACL全て禁止
    - equals:
        kind: apitoken
        allow: [generate_user_token] #API Token作成許可

  project:
    - match:
        name: '<Project name>'  # 対象Projectのみ設定の閲覧可能
        allow: [read]
by:
  username: ProjectAadmin
```

・Project開発者(ProjectAdev)の権限設定 
【Project開発者】は、対象Projectの実行、開発ユーザとしているため、プロジェクトには全ての権限を与えるが、Rundeckシステムに関しては、【Project管理者】同様に制限をかけることとしています。

```
# vi /etc/rundeck/ProjectAdev.aclpolicy

description: Project settings for ProjectAdev user
context:
  project: '<Project name>' # 対象Projectに対する権限の設定
for:
  resource:
    - allow: '*'
  adhoc:
    - allow: '*'
  job:
    - allow: '*'
  node:
    - allow: '*'
by:
    username: ProjectAdev

---

description: Rundeck settings for ProjectAdev user
context:
  application: 'rundeck'
for:
  resource:
    - equals:
        kind: project
        deny: [create]  # プロジェクトの作成は禁止
    - equals:
        kind: system
        deny: [read,enable_executions,disable_executions,admin]    # システム情報の閲覧禁止
    - equals:
        kind: user
        deny: [admin]   # ユーザ情報の編集禁止
    - equals:
        kind: system_acl
        deny: [read,create,update,delete,admin] # system ACL全て禁止
  project:
    - match:
        name: '<Project name>'  # 対象Projectのみ設定の閲覧可能
        allow: [read]
by:
  username: ProjectAdev
```

・Project運用者(ProjectAope)の権限設定 
【Project運用者】は、対象Projectの参照のみとし、プロジェクトは全てread、もしくはrefresh権限のみを与え、Rundeckシステムに関しては、readのみとしています。

```
# vi /etc/rundeck/ProjectAope.aclpolicy

description: Project settings for ProjectAope user
context:
  project: '<Project Name>' # 対象Projectに対する権限の設定
for:
  resource:
    - equals:
        kind: 'node'
      allow: [read,refresh]
    - equals:
        kind: 'job'
      allow: [read]
    - equals:
        kind: 'event'
      allow: [read]
  job:
    - match:
        name: '.*'
      allow: [read]
  node:
    - match:
        nodename: '.*'
      allow: [read,refresh]
by:
    username: ProjectAope

---

description: Rundeck settings for ProjectAope user
context:
  application: 'rundeck'
for:
  project:
    - match:
        name: '.*'
      allow: [read]
  system:
    - match:
        name: '.*'
      allow: [read]
by:
  username: ProjectAope
```



### 3.2.Rundeck ログ削除

Rundeckのジョブ実行ログは、ログファイル、DBの両方に出力されます。
ただし、DBはログファイルのメタデータとして格納されているだけなようです。

その上、メンテナンスされないようなのでRundeckジョブにログ削除のジョブを作成しました。※本当に削除しても後でログを追えないのはNGですが、リソースを食い潰してしまうの問題なので、とりあえず定期的に1週間以前だけを削除することとしました。

ログファイルは、ジョブ実行単位でファイルが作成されるので、ファイルの更新日を見て古いファイル(7日より古いファイル)は削除するようにしました。

```
find /var/lib/rundeck/logs/rundeck/<Project Name>/job/ -mtime +7 -type f | xargs -I{} rm {}
```

DBは、APIもしくはcliを介して削除します。(GUIでは鬱陶しいので)
GUIでは、20行毎にページが切られておりページ毎にしかログ削除ができません。
cliに関しても同様なため、1週間前のfilterした上で、ページ数を取得し、20件づつ削除しております。

```console:rundeck_executions_cleanup.sh
#!/bin/bash

# export required vars
export RD_URL=https://<ドメイン名>/rundeck
export RD_TOKEN=<token>
export RD_HTTP_TIMEOUT=300

# make sure rd & jq commands are in the PATH
which -- rd jq >/dev/null

del_executions() {
local_project=$1
loop_count=`rd executions query --older ${RD_OPTION_OLDER_THAN:-7d} -p ${local_project} | awk '{ print $3 }' | awk -F"/" '{ print $2 }' | sed -e 's/\]//g'`

while [ $loop_count -gt 0 ]
do
    rd executions deletebulk -y -m ${RD_OPTION_BATCH:-20} --older ${RD_OPTION_OLDER_THAN:-7d} -p $local_project
    if [ $? -eq 0 ] ;then
        echo "$project deletebulk is successfull."
    else
        echo "$project deletebulk is failed."
        exit 1
    fi
    find /var/lib/rundeck/logs/rundeck/${local_project}/job/ -mtime +7 -type f | xargs -I{} rm {}
    loop_count=$((loop_count-1))
    sleep 1s
done
}

# delete executions for each project
for p in $(RD_FORMAT=json rd projects list | jq -r .[]); do
    del_executions $p
done

exit 0
```

### 3.3.Rundeckシステムバックアップ

#### 3.3.1.バックアップ対象

Rundeckで使用しているバックアップ対象とした、各ディレクトリを記載しました。

なお、**△**としたディレクトリは各環境、運用に合わせて取得することとします。

| 内容                                | ディレクトリ                                         | バックアップ対象 |
| ----------------------------------- | ---------------------------------------------------- | ---------------- |
| rundeck全体の情報を持つデータベース | /var/lib/rundeck/data/                               | 〇               |
| プロジェクトの情報                  | /var/rundeck/projects/                               | 〇               |
| rundeckの設定全般                   | /etc/rundeck/                                        | 〇               |
| SSH鍵                               | /var/lib/rundeck/.ssh                                | 〇               |
| ジョブ実行ログ                      | /var/lib/rundeck/logs                                | △                |
| Rundeckログ                         | /var/log/rundeck/                                    | △                |
| ジョブ定義                          | ジョブ定義バックアップシェルにて格納したディレクトリ | 〇               |

#### 3.3.2.バックアップシェル

```console:rundeck_backup.sh
#!/bin/bash
Rundeck_DB=/var/lib/rundeck/data/
Rundeck_ProjectInfo=/var/rundeck/projects/
Rundeck_config=/etc/rundeck/
Rundeck_key=/var/lib/rundeck/.ssh
Rundeck_job_excutelog=/var/lib/rundeck/logs
Rundeck_log=/var/log/rundeck/

RD_URL=https://<ドメイン名>/rundeck
RD_TOKEN=<1.1.で取得したトークン>

RD_HTTP_TIMEOUT=300

RundeckJob_Backup_TMP=/tmp/backup
RundeckJob_Backup_Name=jobconf_`date "+%Y%m%d"`.xml
Projects=`RD_FORMAT=json rd projects list | jq -r .[]`
ShellLog_PATH=/tmp
ShellLog=${ShellLog_PATH}/$(basename ${0%.*})_`date "+%Y%m%d"`.log
BackupDir=/tmp
BackupTarFile=${BackupDir}/$(basename ${0%.*})_`date "+%Y%m%d"`.tar.gz

# make sure rd & jq commands are in the PATH
which -- rd jq >/dev/null

# RundeckJob_Backup_TMP Directory create
if [ ! -d ${RundeckJob_Backup_TMP} ] ;then
    mkdir -m 777 ${RundeckJob_Backup_TMP}
    if [ $? -ne 0 ] ;then
        echo "`date "+%Y/%m/%d %H:%M:%S"` Backup TMP Directory creation failed." >> ${ShellLog}
        exit 1
    fi
fi

# Rundeck Job Backup
for ProjectName in ${Projects[@]}
do
    rd jobs list -f "${RundeckJob_Backup_TMP}/${ProjectName}_${RundeckJob_Backup_Name}" -p ${ProjectName}
    if [ $? -ne 0 ] ;then
        echo "`date "+%Y/%m/%d %H:%M:%S"`  Backup Job config failed." >> ${ShellLog}
        exit 1
    fi
done

# create Backup

tar zcf ${BackupTarFile} ${Rundeck_DB} ${Rundeck_ProjectInfo} ${Rundeck_config} ${Rundeck_key} ${Rundeck_job_excutelog} ${Rundeck_log} ${RundeckJob_Backup_TMP}
if [ $? -ne 0 ] ;then
    echo "`date "+%Y/%m/%d %H:%M:%S"`  Failed to create backup file." >> ${ShellLog}
    exit 1
fi

rm -r ${RundeckJob_Backup_TMP}
if [ $? -ne 0 ] ;then
    echo "`date "+%Y/%m/%d %H:%M:%S"` Backup TMP Directory delete failed." >> ${ShellLog}
    exit 1
fi

echo "`date "+%Y/%m/%d %H:%M:%S"`  Rundeck Backup succeeded." >> ${ShellLog}
exit 0
```

一旦、Rundeckについては、調査・検証はこれで完了とします。
また、何か気付いた点や機能で検証してみたいと思うことがあれば検証してみます。



