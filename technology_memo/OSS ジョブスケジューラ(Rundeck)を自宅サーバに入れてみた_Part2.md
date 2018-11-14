
# OSS ジョブスケジューラ(Rundeck)を自宅サーバに入れてみた Part2

サーバに『Rundeck』を導入したとこまで、前回(Part1)検証してみましたが、Part2は実際にプロジェクト、ジョブを作成し、実行するまでは検証してみました。

前回のPart1は、[OSS ジョブスケジューラ(Rundeck)を自宅サーバに入れてみた](https://qiita.com/legitwhiz/items/d3402d3c8bcb0bbed8eb)を参照。

## 0.検証環境

OS:Ubuntu 16.04 LTS
OS:CentOS 7.5
ミドルウェア:Rundeck 3.0.7 (20181008)
前提ミドルウェア:JRE 1.8.0

## 1.ジョブ実行環境構築

### 1.1.管理者パスワードの変更

ユーザのパスワード変更は、[/etc/rundeck/realm.properties]を修正すればいいのですがconfigファイルに平文で書かれてます。
これでは、セキュリティ的によろしくないので、md5で暗号化しパスワード変更してみたいと思います。

#### 1.1.1.暗号化パスワード生成

まずは、パスワードを変更するユーザ(admin)の暗号化パスワードの生成を実行し。

```
# java -jar /var/lib/rundeck/bootstrap/rundeck-3.0.7-20181 008.war --encryptpwd Jetty
Required values are marked with: * 
Username (Optional, but necessary for Crypt encoding):
admin
*Value To Encrypt (The text you want to encrypt):
<変更するパスワードを入力>

==ENCRYPTED OUTPUT==
obfuscate: OBF:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
md5: MD5:yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy
crypt: CRYPT:zzzzzzzzzzzzz
$ 
```

#### 1.1.2.暗号化パスワード設定

生成された暗号化パスワードを設定ファイル[/etc/rundeck/rundeck-config.properties]に反映する。
※記述は、<ユーザ名>: <暗号化方式>:<暗号化パスワード>となるが注意点として[<ユーザ名>:]と[<暗号化方式>]の間に***スペース***があります。

```
# sudo vi /etc/rundeck/realm.properties

admin:admin,user,admin,architect,deploy,build
↓↓↓
admin: MD5:yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy,user,admin,architect,deploy,build
```

#### 1.1.3.Rundeckサービス再起動

設定した暗号化パスワードを反映させるためにRundeckサービスを再起動

```
# systemctl restart rundeckd
```

ちなみにユーザを追加する時も[/etc/rundeck/rundeck-config.properties]は新規追加ですが。上記手順でOKです。※一応、暗号化パスワード生成のみはGUIで可能ですが、結局設定は直接ファイル編集なのでGUI操作は省略してます。

### 1.2.プロジェクト作成

プロジェクト作成は、RundeckにWebアクセス[https://ドメイン名/rundeck]※1し、[New Project]ボタンを押す。

<div align="center">
<img src="https://drive.google.com/uc?export=view&id=1vbk5E_7Ffcq18UHXxXV1hfwxkrD0gFm4" width=120>
</div>

※1:前回Part1にて、Apacheとの連携を設定しているため、連携させない場合は、[http://ドメイン名:4440/]もしくは[https://ドメイン名:4443/]でアクセスして、[New Project]ボタンを押すこと。

[New Project]ボタンを押すと、[Create a new Project]画面が出力されるので[Project Name]を入力する。

<div align="center">
<img src="https://drive.google.com/uc?export=view&id=1zJ83dOMALMyfg_EItE56fpoYEwbN-N_R" width=320>
</div>
ジョブ実行環境[Default Node Executor]とファイルコピー環境[Default Node File Copier]を以下から環境に合わせて、それぞれ選択する必要がありますが、私の環境だとSSHだけで十分だと思うので[SSH],[SCP]を選択しました。後は最下部の[create]ボタンを押すだけ。



ジョブ実行環境[Default Node Executor]

- SSH
- Local
- Stub
- Script Execution
- Ansible Ad-Hoc Node Executor
- openssh / executor
- WinRM Node Executor Python



ファイルコピー環境[Default Node File Copier]

- SCP
- Script Execution
- Ansible File Copier
- Stub
- WinRM Python File Copier
- openssh / file-copier



SSH,SCP鍵認証の詳細設定は以下としました。

| 設定項目           | 設定値                       |
| ------------------ | ---------------------------- |
| SSH Key File path  | /var/lib/rundeck/.ssh/id_rsa |
| SSH Authentication | privateKey                   |
| Force PTY          | off                          |
| Connection Timeout | 30                           |
| Command Timeout    | 0                            |



### 1.3.ノード追加

Rundeckのジョブからリモート実行するには、ファイル[/var/rundeck/projects/test/etc/resources.xml]に直接ノードを追加する必要があります。
※ユーザも含めノード追加もなぜGUIでないのか不思議ですが...。

Rundeck2系では、デフォルトでプロジェクト毎の[project.properties]にresourcesの設定ファイルの定義がされていましたが、Rundeck3系では自分で設定する必要がありました。(Rundeck3系の情報が少なく私はノード追加で躓きましたｗ)
※[project.properties]を修正した際は、rundeckdを再起動が必要となります。



```
# vi /var/rundeck/projects/<Project Name>/etc/project.properties

<!-- 最終行に以下を追加 -->
resources.source.1.type=file
resources.source.1.config.file=/var/rundeck/projects/${project.name}/etc/resources.xml
resources.source.1.config.format=resourcexml
resources.source.1.config.includeServerNode=true
resources.source.1.config.generateFileAutomatically=true
```



その上で、[resources.xml]にノードを追加します。
※Rundeck2系では、[resources.xml]が最初から用意されており、localhostの記載があるがRundeck3系ではファイル自体が存在しないので自分で作成する必要がある。ただし、localhostの設定は必要はない。



```
# vi /var/rundeck/projects/<Project Name>/etc/resources.xml

<?xml version="1.0" encoding="UTF-8"?>
<project>
  <node name="WebServer" type="Node" 
     description="Web Server" 
     hostname="192.168.1.2"
     username="www" tags="web"
     osFamily="unix"
     osName="Red Hat Enterprise Linux Server release 7.3"
     ssh-authentication="privateKey"/>
  <node name="DBServer" type="Node" 
     description="DB Server" 
     hostname="192.168.1.3"
     username="db" tags="db"
     osName="Red Hat Enterprise Linux Server release 7.3"
     ssh-authentication="privateKey"/>
</project>
```



RundeckにWebアクセス[https://ドメイン名/rundeck]し、[Project Name]ボタンを押し、左ペインの[NODES]を押すと追加したノードが表示されます。

<div align="center">
<img src="https://drive.google.com/uc?export=view&id=1METfD59JI72lFdLTaQqIdsvO1RZ_KK1v" width=320>
</div>



### 1.4.SSH鍵設定

リモート実行するサーバにRundeck ManagerのSSH鍵をリモートジョブ実行するノードに登録しておきます。
まずは、Rundeck Manager側で公開鍵を確認。

```
# ls -al /var/lib/rundeck/.ssh
# cat /var/lib/rundeck/.ssh/id_rsa.pub   #公開鍵
```

リモート実行するサーバでジョブを実行するユーザでログインし、Rundeck Managerの公開鍵を設定する。

```
# mkdir ~/.ssh
# vi ~/.ssh/authorized_keys
# chmod 600 ~/.ssh/authorized_keys
# chmod 700 ~/.ssh
```

一応、Rundeck ManagerからSSH鍵でパスワード無しでコマンド実行できるか確認。

```
# ssh -i /var/lib/rundeck/.ssh/id_rsa -o 'StrictHostKeyChecking no' www@192.168.1.2 'hostname'

# ssh -i /var/lib/rundeck/.ssh/id_rsa -o 'StrictHostKeyChecking no' db@192.168.1.3 'hostname'

```

## 2.ジョブ作成

### 2.1.ジョブ構成要素

***■ジョブグループ***

Rundeckには、ジョブグループという概念がありますが、あくまでも使う側の見せ方の問題なのでディレクトリに相当すると考え、運用によりグループ分けをするとよいだろう。

商用のジョブスケジューラ(JP1/AJS,TWS,Systemwalker,千手,WebSAM JobCenter)のようにジョブネットという概念がRundeckにはありません。

ただし、ジョブに構成できる、コマンド、シェルもしくはジョブをstep単位で設定することが可能です。要するに、ジョブの中にジョブをネストするように扱うことができる。
そのためジョブ自体に複数stepを設けることでジョブネットのように扱うことができます。

...と言うことは、
単位ジョブであろうがジョブネットとして動作するジョブであろが同じジョブとしてGUI上は表示されるので見た目での判断が出来ないんです...。

なので、単位ジョブなのかジョブネットなのか分かるようにグループで分類分けするかジョブ名で命名規則を付けて運用するのがいいだろう。



***■step***

ジョブ毎に複数stepを設けることが可能。
stepをシリアル実行とパラレル実行が選択でき、step毎にerror分岐も可能です。
ただし、複数ジョブの合流地点での待ち合わせは、出来ないようです。



***■ノード***

ジョブを実行するノード。一つのジョブに対して複数ノードを設定可能。



***■If a step fails(各ステップの継続設定)***

各step毎に異常終了した場合の後続処理の扱いを設定します。
[Stop at the failed step.]を選択した場合は、stepが異常終了した場合、後続stepは中止されます。
[Run remaining steps before failing.]を選択した場合は、異常終了したstepは無視し、後続stepを実行します。



***■Strategy(ステップの実行規則)***

各ジョブに定義できるstepの実行規則を以下の3点から選択する。

- Node First    : 各stepをシリアル実行する。複数ノードがジョブに定義された場合、ノード1で各stepをシリアル実行し、stepが全て完了したら次のノードで各stepをシリアル実行する。

- Parallel         :  各stepをパラレル実行する。複数ノードがジョブに定義された場合、ノード1で各stepをパラレル実行し、stepが全て完了したら次のノードで各stepをパラレル実行する。

- Sequential   : 各stepをシリアル実行する。複数ノードがジョブに定義された場合、全ノードで各stepをシリアル実行し、次のstepを実行する。


各イメージは、以下のようになる。
なお、ノードの選択はABC順になるようです。なので実行するノードの順序を正確に制御するには、ジョブを分ける必要があります。

<div align="center">
<img src="https://docs.google.com/drawings/d/e/2PACX-1vTkJdSe_6yW1aZfuaE8TJnOcmPl9H0QTz6vb8TY10Hb6p-uu0N9dK0XY0AWvFMAL1wxTVYiGq6FGlVq/pub?w=640&amp;h=419">
</div>
### 2.2.ジョブ作成

まずは、単一ジョブを単一ノードで実行する際のジョブを作成してみます。
Rundeckにアクセスし[JOBS]をクリックし[Job Actions]をクリックし[New Job]をクリックします。

<div align="center">
<img src="https://drive.google.com/uc?export=view&id=1sESNAZMpvTc2PtFzyCYs5H42-ibRB2Fv" width=320>
</div>

[Create New Job]画面で以下を設定します。
Job Name:

<div align="center">
<img src="https://drive.google.com/uc?export=view&id=1ruhCub8G_PSgcgsOzuXZl_Tt39YGxTv7" width=450>
</div>

If a step fails:Stop at the failed step.
Strategy:NodeFirst

<div align="center">
<img src="https://drive.google.com/uc?export=view&id=1-sqw5bBuidiTG5DJBHEjrOnH4CYfmKNv" width=450>
</div>

Add a step:[Command]もしくは[Script]、[Script file or URL]

<div align="center">
<img src="https://drive.google.com/uc?export=view&id=1y9COtuh80MvdOjXdyZnlYIPDI7iNL4lo" width=450>
</div>

Commandの場合は、

<div align="center">
<img src="https://drive.google.com/uc?export=view&id=1Jo9BDiGXNHoLpB5f0_7PBSPnqyAgkUct" width=450>
</div>

Nodes:リモートではれば[Dispatch to Nodes]もしくはローカルであれば[Execute locally]
Matched Nodes:対象ノード

<div align="center">
<img src="https://drive.google.com/uc?export=view&id=1W5pNp6iaLsI_PwSntupuCiHya6KfmhVL" width=450>
</div>

Schedule to run repeatedly?:yes

<div align="center">
<img src="https://drive.google.com/uc?export=view&id=1A2uNRdARH85SZzVHRFB63ZK_IXuqiQjc" width=450>
</div>

<div align="center">
<img src="https://drive.google.com/uc?export=view&id=16gu_KIkF8RLfBOYLlz8HwSgA2vIJBmKV" width=450>
</div>

Timeout: 設定が間違っていたり、対象ノードが落ちていると永遠に待ち続けてしまうのでタイムアウトを適当に設定しておきます。

<div align="center">
<img src="https://drive.google.com/uc?export=view&id=1w4V6onvmi2xoeyjTsyPuEQrZZ-Rqspw3" width=450>
</div>

最後にCreateボタンをクリック

<div align="center">
<img src="https://drive.google.com/uc?export=view&id=1KZYmYdQ_8W6dGnIMMBowgrAkwGTYK48I" width=320>
</div>

### 2.3.ジョブネット作成

先にも記載した通りRundeckには、ジョブネットという概念は存在しません。
ジョブに複数stepを設けることが可能なため、ジョブネットのように扱うことができます。ただし、一つのジョブにシーケンシャル処理とパラレル処理を混在することができないのでシーケンシャル処理とパラレル処理は別々のジョブに定義する必要があります。

### 2.3.1.直列ジョブネット

WorkflowのStrategyをNode Firstと設定すれば直列ジョブ作成できます。また、エラー分岐も試してみたいと思います。
以下のイメージでジョブを作成したいと思います。

<div align="center">
<img src="https://docs.google.com/drawings/d/e/2PACX-1vQzgwBCtqkdbxwk1CGBJ-VAwrKEeiUVTmyy-B18Z0rpKB7NeUC018D_tQ-RFsCgvMcAl2YC3ITc8J_R/pub?w=640&amp;h=156">
</div>

<div align="center">
<img src="https://drive.google.com/uc?export=view&id=1rd8icNZmomc_kadNzfkm-YqaABSQodFu" width=450>
</div>

エラー分岐ジョブは、分岐したいstepの右側の[Add Error Handler]をクリックすると設定できます。

<div align="center">
<img src="https://drive.google.com/uc?export=view&id=1QuF28XnhMfrXKG1n18RsDM9geX-PzI-b" width=320>
</div>

ジョブ実行すると以下のような結果となりました。
結果も含め商用ジョブスケジューラみたいにGUIでジョブの設定も実行状況も図示化して欲しいところですね。

<div align="center">
<img src="https://drive.google.com/uc?export=view&id=1MipRib5QC9IMXCw4t7AlC3COYzsyWTdO" width=450>
</div>

### 2.3.2.並列ジョブネット

WorkflowのStrategyをParallelと設定すれば並列ジョブが作成できます。

※個々のジョブは、省略してます。

<div align="center">
<img src="https://docs.google.com/drawings/d/e/2PACX-1vQfsKByuU4iy7WCUW2jbWvs64_E2PI_y876djWNKM6OR8pcGgLbEyd8V4CftloFAddDPd4nzhcCfUZN/pub?w=640&amp;h=224">
</div>

Job-Net2の設定は以下のようになります。

<div align="center">
<img src="https://drive.google.com/uc?export=view&id=1pXZABzGQQFonp3bHU2k1jpFz-rUNkt9V" width=450>
</div>

Chiled-Job-Net1の設定は以下のようになります

<div align="center">
<img src="https://drive.google.com/uc?export=view&id=1694PwOb5B888hzmSAwHADbsDiiFW3ElZ" width=450>
</div>

なお、スケジュールは最上位のジョブにのみ設定すれば定期的にジョブが実行できます。


とりあえず、シリアル、パラレル実行を混在したジョブまでは作成、実行することができました。
ただし、後でジョブの設定もしくは実行結果を見た時に、実行順序があっているかはGUIではないのでわかりずらいのが私としては今一つな感じですね。
まあ、cronよりかは信頼できるとは思いますが...w

ジョブでファイル監視やジョブネットの中で曜日によって実行有無を設定とか、時間の待ち合わせ等ができるか今後の課題です。
Rundeck2系はそれなりに情報があるのですが、Rundeck3系に関してはマニュアルも適当で記載内容が2系だったりで、今回は記載してませんが結構躓きましたw







