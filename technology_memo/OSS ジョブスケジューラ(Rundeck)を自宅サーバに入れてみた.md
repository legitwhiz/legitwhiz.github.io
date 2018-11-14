
# OSS ジョブスケジューラ(Rundeck)を自宅サーバに入れてみた

自宅サーバで運用スクリプトを実行する場面は多くはないですが、商用ジョブスケジューラ(JP1/AJS,TWS,SystemWalker等)と比較し、OSSでも使えるジョブスケジューラとなっているのか検証してみました。

検証する環境は、Ubuntu16.04LTSとCentOS7.5

## 0.検証環境

OS:Ubuntu 16.04 LTS  
OS:CentOS 7.5  
ミドルウェア:Rundeck 3.0.7 (20181008)  
前提ミドルウェア:JRE 1.8.0  

## 1.Rundeckとは

まず、OSS ジョブスケジューラである『Rundeck』とは、どういった製品なのか調査してみました。

『Rundeck』とは、LinuxもしくはWindowsで動作する、オープンソースのJob管理ツールであり、ライセンスは「Apache Software License 2.0」で商用利用が可能なライセンスとなっています。エージェントは、エージェントレスのシステムであることも(SSHを介してジョブ実行する。エージェント)その為、FW等のネットワーク設計も容易と思われる。

Cronのようにシェルスクリプトなどを定時実行するだけでなく、結果に応じて、通知や別スクリプトを実行するなどCronだけでは実施が難しいフロー制御が可能となっています。
『Rundeck』は、Java/Groovyで作られています。また、バックエンドDBは、デフォルトの『H2 Database』も同梱していますが、『MariaDB』に変更することも可能です。

ジョブ管理ソフトウェアとして、[Web GUI],[Web API]、[コマンドライン]を介してジョブの作成、実行、管理、スケジューリングすることも可能です。

日本語化については、公式には行われておらず、propertiesファイルを_jpとしてコピーし、編集することで可能なようだ。※要調査

『Rundeck』には、コミュニティサポート版でフリーである『Rundeck Community』と、有償のプロサポート版である『Rundeck Enterprise』がある。
『Rundeck Enterprise』では、プロのサポートを受けられる他にクラスタ環境でも使用することができ(DBはReplication)、使用できるPluginもPRO仕様となります。

連携については、Slack通知プラグインSCM(Git)連携、LDAP/ActiveDirectory連携、Graylogを使ってログに特定のメッセージを出力した際にジョブを実行することも可能みたいです。


[『Rundeck』](https://www.rundeck.com/open-source)


## 2.Rundeck(3.0.7) インストール

### 2.1.Ubutnu16.04LTSにインストール

#### 2.1.1.javaをインストール
まずは、『Rundeck』の前提となっているjavaをインストールする。

```
$ sudo apt update
$ sudo apt upgrade
$ sudo apt install openjdk-8-jdk-headless
install openjdk-8-jdk-headless
```

#### 2.1.2.JAVA_HOME追加

```console:JAVA_HOME追加
$ sudo vi ~/.bashrc

#一番下へ以下4行を追加
JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
export JAVA_HOME
PATH=$PATH:$JAVA_HOME/bin
export PATH

$ source ~/.bashrc
```

#### 2.1.3.『Rundeck』インストール

次に『Rundeck』パッケージをインストール

```
$ wget https://dl.bintray.com/rundeck/rundeck-deb/rundeck_3.0.7.20181008-1.201810082317_all.deb
$ sudo dpkg -i rundeck_3.0.7.20181008-1.201810082317_all.deb
$ sudo dpkg -l rundeck
```

#### 2.1.4. Java VM設定

使用するJava VMを設定する。

```
$ sudo update-alternatives --config java
```

#### 2.1.5.リダイレクトURLの設定

```
$ sudo vi /etc/rundeck/rundeck-config.properties
grails.serverURL=http://ホスト名:4440 ドメイン名に変更
```

```
$ sudo vi /etc/rundeck/framework.properties
framework.server.name = ドメイン名 ← localhostからドメイン名に修正
framework.server.hostname = ドメイン名 ← localhostからドメイン名に修正
framework.server.port = 4440
framework.server.url = http://ホスト名:4440 ← localhostからドメイン名に修正
```

#### 2.1.6.『Rundeck』起動
```
$ sudo systemctl status rundeckd
$ sudo systemctl start rundeckd
```

#### 2.1.7.ブラウザから『Rundeck』にアクセスする。

```
HTTPの場合は、http://ドメイン名:4440
HTTPSの場合は、、https://ドメイン名:4443
```

初期状態のAdminユーザーでログインするにはUsernameに[admin]とPasswordに[admin]を入力します。
ログイン後のページが表示されればインストール完了です。


### 2.2.CentOS7.5にインストール

#### 2.2.1.インストール 
```
# yum install java-1.8.0
# wget https://repo.rundeck.org/latest.rpm
# rpm -Uvh ./latest.rpm
# yum install rundeck
```

#### 2.2.2.JAVA_HOME追加
```console:JAVA_HOME追加
$ sudo vi ~/.bashrc

#一番下へ以下4行を追加
JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
export JAVA_HOME
PATH=$PATH:$JAVA_HOME/bin
export PATH

$ source ~/.bashrc
```

#### 2.2.3.リダイレクトURLの設定

```
# vi /etc/rundeck/rundeck-config.properties
grails.serverURL=http://IPアドレス:4440 ← ■localhostからIPアドレス変更
```

```
# vi /etc/rundeck/framework.properties
framework.server.name = localhost
framework.server.hostname = localhost
framework.server.port = 4440
framework.server.url = http://IPアドレス:4440 ← ■localhostからIPアドレスに修正
```

#### 2.2.4.『Rundeck』起動
```
# systemctl status rundeckd
# systemctl start rundeckd
```

#### 2.2.5. firewalldのポート許可設定
```
# firewall-cmd --list-ports --zone=public
# firewall-cmd --add-port=4440/tcp --zone=public --permanent
# firewall-cmd --list-ports --zone=public
```

#### 2.2.6.ブラウザから『Rundeck』にアクセスする。

```
HTTPの場合は、http://IPアドレス:4440
```

Ubuntuと同様に初期状態のAdminユーザーでログインするにはUsernameに[admin]とPasswordに[admin]を入力し、ログイン後のページが表示されればインストール完了です。


## 3.Apacheとの連携設定

『Rundeck』にアクセスするにはポート4440もしくは4443を使用するのですが
Apacheと連携することでポート80からアクセスすることが可能です。

Ubuntu16.04LTSは、HTTPSからもアクセス出来るようにしたいためApache連携し、かつHTTPSでのアクセスを目的とする。

### 3.1. Ubuntu16.04LTSの場合

#### 3.1.1.Java起動パラメータ修正

[/etc/rundeck/profile]ファイルはJava起動パラメータが設定されていますが、そこにapacheに連携するように"-Dserver.web.content"を追加します。

```
# vi /etc/rundeck/profile

RDECK_JVM="-Drundeck.jaaslogin=$JAAS_LOGIN \
-Djava.security.auth.login.config=$JAAS_CONF \
-Dloginmodule.name=$LOGIN_MODULE \
-Drdeck.config=$RDECK_CONFIG \
-Drundeck.server.configDir=$RDECK_SERVER_CONFIG \
-Dserver.datastore.path=$RDECK_SERVER_DATA/rundeck \
-Drundeck.server.serverDir=$RDECK_INSTALL \
-Drdeck.projects=$RDECK_PROJECTS \
-Drdeck.runlogs=$RUNDECK_LOGDIR \
-Drundeck.config.location=$RDECK_CONFIG_FILE \
-Djava.io.tmpdir=$RUNDECK_TEMPDIR \
-Drundeck.server.workDir=$RUNDECK_WORKDIR \
-Dserver.http.port=$RDECK_HTTP_PORT \
-Dserver.web.context=/rundeck \               ←■この行を追加
-Drdeck.base=$RDECK_BASE"
```

#### 3.1.2.リダイレクトURLの設定修正

```
$ sudo vi /etc/rundeck/rundeck-config.properties
grails.serverURL=http://IPアドレス/rundeck ←■修正
```

```
$ sudo vi /etc/rundeck/framework.properties
framework.server.name = ドメイン名 ←■修正
framework.server.hostname = ドメイン名 ←■修正
framework.server.port = 4440
grails.serverURL=https://ドメイン名/rundeck ←■修正
framework.rundeck.url = https://ドメイン名/rundeck ←■追加
```

#### 3.1.3.Rundeckの再起動

```
systemctl restart rundeckd
```

#### 3.1.4.『Rundeck』用Apache Config作成

```
$ sudo vi /etc/apache2/sites-available/rundeck.conf

<Location "/rundeck">
        ProxyPass http://localhost:4440/rundeck
        ProxyPassReverse http://localhost:4440/rundeck
        Require all granted
</Location>

$ sudo a2ensite rundeck
```

#### 3.1.5.Apacheの再起動

```
$ sudo systemctl reload apache2
```

#### 3.1.6.ブラウザから『Rundeck』にアクセスする。

```
https://ドメイン名/rundeck
```


### 3.2. CentOS7.5の場合

CentOS7.5もUbuntu16.04LTS同様にApacheと連携するが、HTTPのみとする。

#### 3.2.1.Java起動パラメータ修正

[/etc/rundeck/profile]ファイルはJava起動パラメータが設定されていますが、そこにapacheに連携するように"-Dserver.web.content"を追加します。

```
# vi /etc/rundeck/profile

RDECK_JVM="-Drundeck.jaaslogin=$JAAS_LOGIN \
-Djava.security.auth.login.config=$JAAS_CONF \
-Dloginmodule.name=$LOGIN_MODULE \
-Drdeck.config=$RDECK_CONFIG \
-Drundeck.server.configDir=$RDECK_SERVER_CONFIG \
-Dserver.datastore.path=$RDECK_SERVER_DATA/rundeck \
-Drundeck.server.serverDir=$RDECK_INSTALL \
-Drdeck.projects=$RDECK_PROJECTS \
-Drdeck.runlogs=$RUNDECK_LOGDIR \
-Drundeck.config.location=$RDECK_CONFIG_FILE \
-Djava.io.tmpdir=$RUNDECK_TEMPDIR \
-Drundeck.server.workDir=$RUNDECK_WORKDIR \
-Dserver.http.port=$RDECK_HTTP_PORT \
-Dserver.web.context=/rundeck \               ←■この行を追加
-Drdeck.base=$RDECK_BASE"
```

#### 3.2.2.リダイレクトURLの設定修正

```
# vi /etc/rundeck/rundeck-config.properties
grails.serverURL=http://IPアドレス/rundeck ←■修正
```

```
# vi /etc/rundeck/framework.properties
framework.server.name = localhost
framework.server.hostname = localhost
framework.server.port = 4440
framework.server.url = http://IPアドレス/rundeck ←■修正
```

#### 3.2.3.Rundeckの再起動

```
# systemctl restart rundeckd
```

#### 3.2.4.『Rundeck』用Apache Config作成

```
# vi /etc/httpd/conf.d/rundeck.conf

<Location "/rundeck">
        ProxyPass http://localhost:4440/rundeck
        ProxyPassReverse http://localhost:4440/rundeck
        Require all granted
</Location>
```

#### 3.2.5.Apacheの再起動

```
# systemctl reload httpd
```

#### 3.2.6.ブラウザから『Rundeck』にアクセスする。

```
http://IPアドレス/rundeck
```


## Rundeck プロジェクト作成やジョブ作成と実行については、追々書いていこうかと思います。


