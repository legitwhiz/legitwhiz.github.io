---
layout: default
title: Linux FireWall
---

# Linux FireWall

LinuxのFireWallには、iptables,SELinux,ipchains,ipfilter,firewalldがありますが
RHEL 7系で新たに追加されたfirewalldについて調査し検証してました。


## Linuxで使用できるFireWall

### SELinuxとは？

SELinuxの最大の特徴は，従来のLinuxやUNIXでは絶対的な権限を持っていた  
root（ルート）アカウントの特権を無くしてしまったことです。  
リソースへの権限をユーザーやプロセスごとに細かく設定して，  
例外なくセキュリティ・ポリシーで制御します。  
必要最低限の権限しか与えないことで，クラッカに侵入されてもシステムへの  
影響を最小限に抑えることを目指しています。  

### iptablesとは？

iptablesとは一般的なLinuxに搭載されているパケットフィルタの事だ。  
パケットとは、スマホのパケット通信費などでよく出てくるように、  
ネットワーク上を流れるデータの事だ。  

パケットフィルタとは、このパケットを選別して、  
通すものと通さないものを分けるということを意味している。  

サーバ自身を守ることはもちろん、パケット転送などにも対応しているため、  
ネットワークアダプタを二つ搭載したマシンの上で動作させパケット転送制御を  
行うことで、ネットワーク型ファイアウォールとしても使用可能である。  

Snortなどと組み合わせるとUTM（統合脅威管理システム）としても使用できる。  
またパケットの状態を把握するステートフル機能やログ機能を備えている。  

### firewalldとは？

RHEL6までは高機能なパケットフィルタとしてiptablesを使用していたが、  
RHEL7では新しく「firewalld」というのもが実装された。  

「firewalld」は、「iptables」の後継のため、サービス単位での共存は  
出来ないようになっている。  
iptablesを使用することも出来るようになっているが、RHEL7ではfirewalldが  
デフォルトで稼動するようになっているので、そちらを使用したほうがいいだろう。

## firewalld基本

### 「Firewalld」とは

Firewalldは、CentOS 7から採用された「パケットフィルタリング」の仕組みです。  
パケットフィルタリングは、パケットの送受信において、あらかじめ指定した  
ルールに基づいて通信の許可／拒否を制御する、セキュリティ対策の基礎手段です。  

### そもそも、iptablesもfirewalldも「Netfilter」のための管理インタフェース

Linuxにおけるパケットフィルタリングは、Linuxカーネル内のNetfilterと呼ぶ  
サブシステムで行われます。  

Firewalldも、iptablesも、その役割は、  
 - Netfilterを動作させるための設定を行う  
 - Netfilterの設定内容を保持するための、「Netfilterの管理インタフェース」です。 
    ただし、これまでのiptablesは、運用において幾つかの課題を抱えていました。  

例えば、本来のiptablesは設定を保持する機能がないこと。  
システムを再起動すると設定がクリアされてしまうので、/etc/sysconfig/iptables  
というファイルにルールを書き込むことで、設定を保持できるようにしていました。  

また、コマンドオプションがかなり複雑で、TCP/IPの仕組みを深く理解していないと  
設定が難しいものでした。  

Firewalldは、そんな課題を解決するために設計されたといえます。  
Firewalldには、以下の特徴があります。  
「Firewalld」と「iptables」の簡易特徴比較  



| type|Firewalld|iptables|
| :----------- | :----------------------------------------------------------- | :----------------------------------------------------------- |
| 設定変更     | 通信を停止させることなく、変更した設定を反映できる           | 設定を反映させるために、サービスの再起動が必要（ネットワークの瞬断が発生する） |
| 設定の難易度 | TCP/IPの仕組みを深く理解していなくても比較的簡単に設定できる | TCP/IPの仕組みを深く理解していないと、設定そのものが難しい。コマンドオプションがかなり複雑 |
| 運用の柔軟性 | 一時的なルールと永続的なルールをそれぞれ管理できる。一定時間のみ有効にするといったルールの設定も可能 | 一時的なルールの設定は困難                       |



### Netfilterにおける「チェイン」とは

Firewalldでのパケットフィルタリング設定について解説する前に、Netfilterに  
おけるパケットフィルタリング処理の仕組みをおさらいしておきましょう。  
Netfilterでは、以下の3種類のパケットの流れに対してパケットフィルタリングの  
処理を行います  

#### (1) INPUT（外部から内部へ）

    受信するパケットが適切かをチェックします。  
    受信すべきパケットはローカルプロセス（Linux上のプロセス）に配送し、  
    ルールに合致しないパケットは破棄します。  


#### (2) OUTPUT（内部から外部へ）

    送信するパケットが適切かをチェックします。  
    送信すべきパケットはネットワークデバイスを経由して外部へ送信し、  
    ルールに合致しないパケットは破棄します。  

#### (3) FORWARD（外部へ転送）

    別のサーバへ転送すると指定されたパケットを受信すると、FORWARDのルールを  
    適用して処理します。  
    転送すべきパケットはネットワークデバイスを経由して別のサーバなどに転送され、  
    ルールに合致しないパケットは破棄します。  

**このパケット処理の分類を「チェイン」と呼びます。  
iptablesでは、それぞれのチェインに対して個別のフィルタリングルール  
とデフォルトルールを設定します。  
デフォルトルールでは、通信の「ACCEPT（許可）」または「DROP（廃棄）」  
を指定します。  
「ACCEPT」は、ルールが定められていない通信も「全て許可」します。  
「DROP」はその逆で、ルールを定めていない通信は「全て破棄」します。  
また、INPUT方向の戻り通信に対して、OUTPUT方向の  
「通信許可ルールを設定する必要」もあります。  
  一方のFirewalldでは、主にINPUTチェインのパケットフィルタリングルールを  
  制御します。  
また、チェインに対して直接デフォルトルールを設定するのではなく、  
「ゾーン」と呼ぶグループ単位でルールを定義します。  **

### Firewalldにおける「ゾーン」と「インタフェース」

では、Firewalldはどのようにシンプルになったのか。
「ゾーン」設定の具体例を交えながら説明していきます。
  ゾーンとは、パケットフィルタリングのルールをまとめて、  
グループ化したものです。  
  Firewalldでは、このゾーンを「インタフェース」に定義します。  
際のルールの設定は「ゾーン」に対して行います。  

### Firewalldにおけるパケットフィルタリングの方式
Firewalldでは、いくつもの以下のパケットフィルタリング方式が定義可能です。

interfaceにzoneを割り当て、
各zoneのtarget定義によりパケットの許可(ACCEPT)、破棄(DROP)、拒否(REJECT)のルールを設けることが可能。
また、zoneのルールに各対象[service]、[port]、[source]、[protocols]、
[masquerade]、[forward-ports]、[icmp-blocks]、[ipset]、[helper]、
[icmptype]単位もしくは組み合わせることでフィルタすることが可能。

より詳細なパケットフィルタを定義したい場合は、、[rich-rule]もしくは、
iptablesのような、OUTPUT定義も可能な[direct-rule]フィルタ定義
も設定可能となっている。

あらかじめ設定されている「ゾーン」は表1の通りです。  
#### 表1　ゾーン名  

| ゾーン名 | 概要                                                         |
| :------- | :----------------------------------------------------------- |
| public   | サーバとして最低限必要な受信許可ルール。全てのインタフェースはデフォルトでpublicゾーンに所属している |
| work     | 業務用クライアントPCとしての利用を想定したルール。社内LAN内で使う場合を想定している。クライアントPCに求められる必要最低限のルールが定義されている |
| home     | 家庭用クライアントPCとしての利用を想定したルール。家庭内LANに接続して使う場合を想定している |
| internal | Linuxを用いてファイアウォールを構築するのに使うルール。内部ネットワークのインタフェースに設定する |
| external | 同じく、Linuxを用いてファイアウォールを構築するのに使うルール。こちらは、外部ネットワークのインタフェースに対して設定する |
| dmz      | 同じく、Linuxを用いてファイアウォールを構築するのに使うルール。こちらは、DMZのインタフェースに対して設定する |
| block    | 受信パケットを全て拒否するルール。送信パケットの戻り通信は許可される |
| drop     | 受信パケットを全て破棄するルール。送信パケットの戻り通信は許可される |
| trusted  | 全ての通信を許可するルール                                   |

### 動的ファイアウォールと静的ファイアウォール 
iptablesによるファイアウォール(system-config-firewall/lokkit)は、
静的ファイアウォールモデルでした。

firewalldは、ネットワークコネクション、インターフェースの信頼度を
定義するネットワーク、またはファイアウォールのゾーンに対応し、
動的に管理が可能となっています。
また、firewalldは、その名前が示す通りデーモンとして動作します。

※firewalldは、system-config-firewallに依存していませんが、
同時に利用するべきではありません。

### firewalld設定ファイル格納パス
firewalldは、基本的にコマンドもしくはGUIから設定変更可能ですが、
実行結果を以下パスから確認することが可能です。

firewalld設定ファイル[/etc/firewalld/firewalld.conf]
zoneファイルフォルダ[/etc/firewalld/zones/］
サービスファイルフォルダ[/etc/firewalld/services/]
ICMPタイプファイルフォルダ[/etc/firewalld/icmptypes]


## firewalldサービス設定

自動起動の設定

```
# systemctl enable firewalld.service
```

自動起動設定の状態確認

```
# systemctl is-enabled firewalld.service 
enabled
```

自動起動の解除

```
# systemctl disable firewalld.service
Removed symlink /etc/systemd/system/dbus-org.fedoraproject.FirewallD1.service.
Removed symlink /etc/systemd/system/basic.target.wants/firewalld.service.
# systemctl is-enabled firewalld.service
disabled
```


### firewalld設定以外のコマンド

#### firewalldサービス状態確認(--state)

```
# firewall-cmd --state
running
```

#### firewalld設定再読み込み(--reload)

```
# firewall-cmd --reload
success
```


#### firewalldバージョン(--version,-V)

```
# firewall-cmd --version
0.4.4.4
```

#### firewalldヘルプ(-h,--help)

```
# firewall-cmd --help
```

#### firewalldメッセージ出力なしにする(-q,--quiet)

```
# firewall-cmd --quiet
```


#### firewalld状態情報を破棄してリロード(--complete-reload)

```
# firewall-cmd --complete-reload
```

#### アクティブなランタイム構成を保存し、永続的な構成を上書き(--runtime-to-permanent)

```
# firewall-cmd --runtime-to-permanent
```

#### ログ拒否設定を出力(--get-log-denied)

```
# firewall-cmd --get-log-denied
off
```

#### ログ拒否設定を設定(--set-log-denied=value)
可能な値は、 all 、 unicast 、 broadcast 、 multicastおよびoff
デフォルトの設定はoffで、ログを無効。

iptables -nvLで確認するとlog-level 4(warning)となっており、
syslogのfacility.level=kern.warningとなり、
/var/log/messagesに記録されます。

```
# firewall-cmd --set-log-denied=all
success
```

#### 自動ヘルパーの確認(--get-automatic-helpers)

```
# firewall-cmd --get-automatic-helpers
system
```

#### 自動ヘルパーの設定(--set-automatic-helpers=value)
可能な値は、 yes 、 noおよびsystem。
デフォルト値はsystem。

```
# firewall-cmd --set-automatic-helpers=system
success
```

#### 永続的なオプション(--permanent)
変更を記録し、永続的に設定をする。
サポートされているすべてのオプションにオプションで追加できる。

```
# firewall-cmd --set-default-zone=<zone name> --permanent
```

#### 一時的な設定(--timeout)
timevalは、秒（秒）または数字の後に文字s（秒）、 m （分）、 h （時間）のいずれか、たとえば20mまたは1hいずれかです。

```
# firewall-cmd --zone=<zone name> --add-service=<service> --timeout=20s
```


#### GUI設定(firewall-config)

グラフィカルユーザーインターフェースを使った firewalld の設定

```
# firewall-config
```


<!--=================================================================-->

## FWの設定

### firewalldゾーン設定

「ゾーンと呼ばれるファイルにFWのフィルタ設定を定義しておき
それをNICに割り当てます。」

でもこのゾーン、実はデフォルトで9個も用意されているんです。
「block、dmz、drop、external、home、internal、public、trusted、work」の9つです。以上は、ファイアウォールの設定のテンプレートだと思ってください
正直なところ大多数の方は、デフォルトに設定されているpublicゾーンに
許可するサービスやポートを定義していくだけで十分だと思います。

ただし、インタフェースは、1つのゾーンにだけ割り当てることが可能です。
1つのゾーンに複数のインタフェースを設定することは可能です。

#### 現在割り当てられているアクティブゾーンの確認(--get-active-zones)

NICに割り当てられているゾーンを調べる

```
# firewall-cmd --get-active-zones
public
  interfaces: ens160
```

#### デフォルトで割り当てられるゾーンの確認(--get-default-zone)

ens160にはpublicというゾーンが割り当たっている状態。

システムのデフォルトゾーンの確認 

```
# firewall-cmd --get-default-zone
public
```

#### デフォルトで割り当てられるゾーンの設定(--set-default-zone)

システムのデフォルトゾーンの設定

```
# firewall-cmd --set-default-zone=<zone name>
public
```

#### ゾーンの確認(--get-zones)

システムのデフォルトゾーンの設定

```
# firewall-cmd --get-zones
```

#### すべてのゾーン表示(--list-all-zones)

「--list-all-zones」オプションを指定することで、
すべてのゾーンの現在のFW設定を確認できます。

すべてのゾーンのFW設定を確認 

```
# firewall-cmd --list-all-zones
```

#### ゾーンに関する情報を表示(--info-zone)

```
# firewall-cmd --info-zone=<zone name>
```

#### ゾーン新しく作成(--new-zone)

```
# firewall-cmd --new-zone=<zone name>
```

#### ゾーンを削除(--delete-zone)

```
# firewall-cmd --delete-zone=<zone name>
```

#### ゾーンのデフォルト設定をロード(--load-zone-defaults)

```
# firewall-cmd --load-zone-defaults=<zone name>
```

#### ゾーン構成ファイルのパスを表示(--path-zone)

```
# firewall-cmd --path-zone=<zone name>
```

#### ゾーンの説明文を表示(--get-description)

```
# firewall-cmd --zone=<zone name> --get-description
```

#### ゾーンに短い説明文を設定する(--set-short)

```
# firewall-cmd --zone=<zone name> --set-short=<description>
```

#### ゾーンに短い説明文を表示する(--get-short)

```
# firewall-cmd --zone=<zone name> --get-short
```


### FWの設定状態の確認

#### デフォルトゾーンのFW設定確認(--list-all)

「--list-all」オプションを指定することでデフォルトゾーンの現在のFW設定を確認できます。
※デフォルトゾーンとアクティブゾーンが異なる場合は、
アクティブゾーンの設定を見るように促す注意書きが出力されます。

デフォルトゾーンのFW設定確認 

```
# firewall-cmd --list-all
public
  target: default
  icmp-block-inversion: no
  interfaces: 
  sources: 
  services: dhcpv6-client mdns samba-client ssh
  ports: 
  protocols: 
  masquerade: no
  forward-ports: 
  sourceports: 
  icmp-blocks: 
  rich rules: 
```

(publicゾーン)指定したゾーン設定を確認する

```
# firewall-cmd --list-all --zone=<zone name>
<zone name>
  target: default
  icmp-block-inversion: no
  interfaces: 
  sources: 
  services: dhcpv6-client mdns samba-client ssh
  ports: 
  protocols: 
  masquerade: no
  forward-ports: 
  sourceports: 
  icmp-blocks: 
  rich rules: 
```




#### 恒久的なFW設定の確認(--list-all --permanent)

「--permanent」オプションを指定することで、恒久的な設定をそれぞれ確認できます。
※一時的に追加した設定は表示されません。再起動後も反映される設定となります。

デフォルトゾーンのFW設定確認（恒久的な設定のみ） 

```
# firewall-cmd --list-all --permanent
```

指定したゾーンのFW設定確認（恒久的な設定のみ） 

```
# firewall-cmd --list-all --zone=home --permanent
```

すべてのゾーンのFW設定確認（恒久的な設定のみ） 

```
# firewall-cmd --list-all-zones --permanent
```


### services

ゾーンにサービスを追加することで、そのサービス用のFW設定が反映されます。
サービスのFW設定は、XMLファイルで定義されており、以下の場所に格納されています。
/usr/lib/firewalld/services/

#### 登録可能なサービスの確認(--get-services)

「--get-servicess」オプションを指定することで登録可能なサービス名一覧を確認できます。

登録可能なサービスの確認

```
# firewall-cmd --get-services
RH-Satellite-6 amanda-client amanda-k5-client bacula bacula-client bitcoin bitcoin-rpc bitcoin-testnet bitcoin-testnet-rpc ceph ceph-mon cfengine condor-collector ctdb dhcp dhcpv6 dhcpv6-client dns docker-registry dropbox-lansync elasticsearch freeipa-ldap freeipa-ldaps freeipa-replication freeipa-trust ftp ganglia-client ganglia-master high-availability http https imap imaps ipp ipp-client ipsec iscsi-target kadmin kerberos kibana klogin kpasswd kshell ldap ldaps libvirt libvirt-tls managesieve mdns mosh mountd ms-wbt mssql mysql nfs nfs3 nrpe ntp openvpn ovirt-imageio ovirt-storageconsole ovirt-vmconsole pmcd pmproxy pmwebapi pmwebapis pop3 pop3s postgresql privoxy proxy-dhcp ptp pulseaudio puppetmaster quassel radius rpc-bind rsh rsyncd samba samba-client sane sip sips smtp smtp-submission smtps snmp snmptrap spideroak-lansync squid ssh synergy syslog syslog-tls telnet tftp tftp-client tinc tor-socks transmission-client vdsm vnc-server wbem-https xmpp-bosh xmpp-client xmpp-local xmpp-server
```

#### 現在追加されているサービスの確認(--list-services)

「--list-services」オプションを指定することで現在追加されているサービスを確認できます。
※「--zone」オプションを省略した場合、デフォルトゾーンの設定が表示されます。
　ただし、アクティブゾーンとデフォルトゾーンが異なる場合は、注意書きが出力されます。

現在追加されているサービスの確認

```
# firewall-cmd --list-services --zone=<zone name>
dhcpv6-client ssh https
```
現在追加されているサービスの確認（恒久的な設定のみ表示）

```
# firewall-cmd --list-services --zone=<zone name> --permanent
dhcpv6-client ssh
```

#### ゾーンにサービスの追加(--add-service)
「--add-service」オプションを指定することでサービスを追加できます。
※「--zone」オプションを省略した場合、デフォルトゾーンに登録されます。

サービスの追加（publicゾーンに対して、httpsを追加する例）

```
# firewall-cmd --add-service=https --zone=<zone name> 
```

恒久的な設定とする場合は、「--permanent」オプションを指定します。
ただし、設定を反映したい場合は設定の再読み込みが必要です。

サービスの追加

```
# firewall-cmd --add-service=https --zone=<zone name> --permanent
```

#### ゾーンのサービスの削除(--remove-service)

「--remove-service」オプションを指定することでサービスを削除できます。
※「--zone」オプションを省略した場合、デフォルトゾーンから削除されます。

サービスの削除

```
# firewall-cmd --remove-service=https --zone=<zone name>
```

恒久的な設定とする場合は、「--permanent」オプションを指定します。
ただし、設定を反映したい場合は設定の再読み込みが必要です。

サービスの削除

```
# firewall-cmd --remove-service=https --zone=<zone name> --permanent
```

#### サービスの新規作成(--new-service)

サービスは独自に作成することも可能です。
詳しくは、firewall-cmdのマニュアル（man firewalld-cmd）をご覧ください。
「--permanent」オプションは必須です。

hogeサービスの作成

```
# firewall-cmd --permanent --new-service hoge

# cat /etc/firewalld/services/hoge.xml
<?xml version="1.0" encoding="utf-8"?>
<service>
</service>
```

※/etc/firewalld/services/hoge.xml が作成されます。

#### xmlファイルからサービスの新規作成(--new-service-from-file)

既存のxmlファイルから作成する場合

```
# firewall-cmd --permanent --new-service-from-file=<filename> --name=<別名をつける場合>
```

#### サービスの説明文を追加(--set-description)

サービスの説明文追加

```
# firewall-cmd --permanent --service=hoge --set-description=<説明文>
# firewall-cmd --permanent --service=hoge --set-short=<短い説明文>
```

#### サービスの削除(--delete-service)

サービスの削除

```
# firewall-cmd --permanent --delete-service=<service name>
```

#### サービスが追加されたか照会(--query-service)

追加サービスの確認

```
# firewall-cmd --permanent --zone=<zone name> --query-service=<service name>
```

#### module

##### 新しいモジュールを追加(--add-module)

```
firewall-cmd --service=<service name> --add-module=<module name>
```

##### 常設サービスからモジュールを削除(--remove-module)

```
firewall-cmd --service=<service name> --remove-module=<module name>
```

##### 常設サービスにモジュールが追加されたか照会(--query-module)

```
firewall-cmd --service=<service name> --query-module=<module name>
```

##### サービスに追加されたモジュールのリスト(--get-modules)

```
firewall-cmd --service=<service name> --get-modules
```

<!--=================================================================-->

### ports

#### 現在追加されているポート番号の確認(--list-ports)

「--list-ports」オプションを指定することで現在追加されているポート番号を確認できます。
※「--zone」オプションを省略した場合、デフォルトゾーンの設定が表示されます。
　ただし、アクティブゾーンとデフォルトゾーンが異なる場合は、注意書きが出力されます。

現在追加されているポート番号の確認

```
# firewall-cmd --list-ports --zone=<zone name>
```

現在追加されているポート番号の確認（恒久的な設定のみ表示）

```
# firewall-cmd --list-ports --zone=<zone name>
```

#### ポート番号の追加(--add-port)

「--add-port」オプションを指定することでサービスを追加できます。
※「--zone」オプションを省略した場合、デフォルトゾーンに追加されます。

ポート番号の追加（デフォルトゾーンに対して、TCP8080、UDP60000の例）

```
# firewall-cmd --add-port=8080/tcp --zone=<zone name>
# firewall-cmd --add-port=60000/udp --zone=<zone name>
```

恒久的な設定とする場合は、「--permanent」オプションを指定します。
ただし、設定を反映したい場合は設定の再読み込みが必要です。

ポート番号の追加

```
# firewall-cmd --add-port=8080/tcp --zone=<zone name> --permanent
# firewall-cmd --add-port=60000/udp --zone=<zone name> --permanent
```

#### ポート番号の削除(--remove-port)

「--remove-service」オプションを指定することでサービスを削除できます。
※「--zone」オプションを省略した場合、デフォルトゾーンから削除されます。

ポート番号の削除

```
# firewall-cmd --remove-port=8080/tcp --zone=<zone name>
# firewall-cmd --remove-port=60000/udp --zone=<zone name>
```

恒久的な設定とする場合は、「--permanent」オプションを指定します。
ただし、設定を反映したい場合は設定の再読み込みが必要です。

ポート番号の削除

```
# firewall-cmd --remove-port=8080/tcp --zone=<zone name> --permanent
# firewall-cmd --remove-port=60000/udp --zone=<zone name> --permanent
```

#### 追加ポートの照会(--query-port)

ポート番号の削除（恒久的な設定とする場合）

```
# firewall-cmd --query-port=8080/tcp --zone=<zone name>
```


<!--=================================================================-->

### sources

#### 現在追加されているIPアドレスの確認(--list-sources)

「--list-sources」オプションを指定することで現在追加されているIPアドレスを確認できます。
※「--zone」オプションを省略した場合、デフォルトゾーンに追加されます。

現在追加されているIPアドレスの確認

```
# firewall-cmd --list-sources --zone=<zone name>
```

現在追加されているIPアドレスの確認

```
# firewall-cmd --list-sources --zone=<zone name> --permanent
```

#### IPアドレスの追加(--add-source)

「--add-source」オプションを指定することでIPアドレスを追加できます。
※「--zone」オプションを省略した場合、デフォルトゾーンに追加されます。

##### アクセス許可

許可アドレスの追加

```
# firewall-cmd --add-source=192.168.0.0/24 --zone=<zone name>
```

恒久的な設定とする場合は、「--permanent」オプションを指定します。
ただし、設定を反映したい場合は設定の再読み込みが必要です。

ポート番号の追加（恒久的な設定とする場合）

```
# firewall-cmd --add-source=192.168.0.0/24 --zone=<zone name> --permanent
```

##### アクセス拒否
「drop」ゾーンに対してIPアドレスを登録することで拒否IPアドレスとなります。

拒否アドレスの追加

```
# firewall-cmd --add-source=192.168.11.0/24 --zone=drop 
```

恒久的な設定とする場合は、「--permanent」オプションを指定します。
ただし、設定を反映したい場合は設定の再読み込みが必要です。

ポート番号の追加（恒久的な設定とする場合）

```
# firewall-cmd --add-source=192.168.11.0/24 --zone=drop --permanent
```

#### アクセス元IPアドレスのゾーンの変更(--change-source)

すでに登録済みのIPアドレスは、「--change-source」オプションを指定することで、ゾーンの変更が行えます。

アクセス元IPアドレスに割り当てられているゾーンの変更（dropに変更の例）

```
# firewall-cmd --change-source=192.168.11.0/24 --zone=drop
```

アクセス元IPアドレスに割り当てられているゾーンの確認

```
# firewall-cmd --get-zone-of-source=192.168.11.0/24
drop
```

恒久的な設定とする場合は、「--permanent」オプションを指定します。
ただし、設定を反映したい場合は設定の再読み込みが必要です。

ゾーンの変更

```
# firewall-cmd --change-source=192.168.11.0/24 --zone=drop --permanent
```

#### IPアドレスの削除(--remove-source)
「--remove-source」オプションを指定することでサービスを削除できます。
※「--zone」オプションを省略した場合、デフォルトゾーンに追加されます。

IPアドレスの削除

```
# firewall-cmd --remove-source=192.168.11.0/24 --zone=drop
```

恒久的な設定とする場合は、「--permanent」オプションを指定します。
ただし、設定を反映したい場合は設定の再読み込みが必要です。

IPアドレスの削除

```
# firewall-cmd --remove-source=192.168.11.0/24 --zone=drop --permanent
```

#### IPアドレスの照会(--query-source)

IPアドレスの確認

```
# firewall-cmd --query-source=192.168.11.0/24 --zone=drop --permanent
```

<!--=================================================================-->

### target
    target: { default , ACCEPT , DROP , REJECT }
    default ⇒ Zoneによって以下3つのいずれかになる。publicの場合はREJECTの動作になる。
    ACCEPT ⇒ 全てを許可するようになる。
    DROP ⇒ 拒否ルールに引っ掛かった通信はルール通り拒否し、何も返さない。
    REJECT ⇒ 拒否ルールに引っ掛かった通信はルール通り拒否し、ICMP の Type 3(Destination Unreachable) の Code 10 ( Host administratively prohibited) を返す。
    DROPとREJECTの違いは、上記のようにICMPのエラーコードを返すか返さないかです。

#### ターゲットの追加(--set-target)

sshを許可し、ゾーン:telnetを拒否するゾーン設定

```
# firewall-cmd --permanent --zone=ssh --set-target=ACCEPT
# firewall-cmd --permanent --zone=telnet --set-target=DROP
```

#### ターゲットの削除
ターゲットの削除は、ゾーンの削除で対応。

#### ターゲットの確認(--get-target)

```
# firewall-cmd --get-target
```

### icmp-block-inversion

    icmp-block-inversion: { yes , no }
    yes ⇒ icmp-blocks に記載されたICMP Typeを受け入れ、記載されていないICMP Type を拒否するようになる。つまり、逆の動作になる。
    no ⇒ icmp-blocks に記載された ICMP Type を拒否する。通常の動作。
    これは一時的にデバッグを行うときのために使うものです。


#### ICMPブロックの逆設定の有効化(--add-icmp-block-inversion)

```
# firewall-cmd --add-icmp-block-inversion
```

#### ICMPブロックの逆設定の無効化(--remove-icmp-block-inversion)

```
# firewall-cmd --remove-icmp-block-inversion
```

#### ICMPブロックの逆設定の照会(--query-icmp-block-inversion)

```
# firewall-cmd --query-icmp-block-inversion
```

<!--=================================================================-->

### interfaces

interfaces: { 該当インタフェース }

#### 対象nicにゾーンを適用(--add-interface)

```
# firewall-cmd --add-interface=<interface name> –-zone=<zone name>
```

#### nicに適用するゾーンを変更(--change-interface)

```
# firewall-cmd --zone=home --change-interface=<interface name>
The interface is under control of NetworkManager, setting zone to 'home'.
success
```

#### ゾーンが適用されるNICポートを表示(--list-interfaces)

eth0がpublicゾーン、eth1がhomeゾーンに所属することがわかる。

```
# firewall-cmd --list-interfaces --zone=<zone name>
```

#### 適用ゾーンを除去(--remove-interface)

```
# firewall-cmd --remove-interface=<interface name>
```

#### nicに対象ゾーンが適用されたかの照会(--query-interface)

```
# firewall-cmd --query-interface=interface=<interface name>
```

<!--=================================================================-->

### sources

    通信元のIPサブネットによる通信制限する。
    sources: { IP or NW address }
    送信元IPもしくはNWアドレス単位で全てを許可したい場合はここで指定します。
    sources: 192.168.100.0/24 等と記載されます。

#### 送信元制御設定のゾーン設定確認(--list-sources )

```
# firewall-cmd --list-sources –zone=<zone name>
```

#### 定義済み送信元制御設定の確認(--get-zone-of-source)

```
# firewall-cmd --get-zone-of-source=<subnet>
```

#### 対象ゾーンに送信元設定が適用されたかを照会(--query-source)

```
# firewall-cmd --query-source=<subnet>
```

#### ゾーンに送信元制御設定を追加(--add-source)

```
# firewall-cmd --add-source=<subnet> –zone=<zone name>
```

#### ゾーンの送信元制御設定を変更(--change-source)

```
# firewall-cmd --change-source=<subnet> –zone=<zone name>
```

#### 送信元通信制御設定を削除(--remove-source)

```
# firewall-cmd --remove-source=<subnet>
```

<!--=================================================================-->

### protocols

protocols: { プロトコル }
プロトコル単位で（送信元IP等に依らず）許可したい場合はここで指定します。TCPやUDP, ICMP, OSPF等が入れられます。
protocols: tcp udp icmp ospf 等と記載されます。

protocol value=protocol_name_or_ID

#### zone用に追加されたプロトコルを表示(--list-protocols)

zone用に追加されたプロトコルをスペース区切りリストとして表示。
zoneを省略すると、デフォルトのゾーンが使用されます。

```
# firewall-cmd --list-protocols --zone=<zone name>
```

#### zone用にプロトコルを追加(--add-protocol)

```
# firewall-cmd --add-protocol=<protocol> --zone=<zone name>
```

#### zone用にプロトコルを削除(--remove-protocol)

```
# firewall-cmd --remove-protocol=<protocol> --zone=<zone name>
```

#### zone用のプロトコルを照会(--query-protocol )

```
# firewall-cmd --query-protocol=<protocol> --zone=<zone name>
```

#### protocolsは、リッチルールと組み合わせて使用する。(protocol)

```
# firewall-cmd --permanent --zone=<zone name> --add-rich-rule="rule family=ipv4 source address=<ip address>  port port=<port number> protocol=<protocol> accept"
```


<!--=================================================================-->

### masquerade

masquerade: { yes , no }
NAPTを掛けるかどうかを決めます。カーネルでルーティングを有効にした場合や、firewalld のポートフォワードの機能を使う際に使うことができます。

#### IPマスカレードを有効化(-add-masquerade -zone)

```
# firewall-cmd --add-masquerade --zone=<zone name>
```

#### IPマスカレードを無効化(--remove-masquerade)

```
# firewall-cmd --remove-masquerade --zone=<zone name>
```

#### IPマスカレードの現在の設定を照会(--query-masquerade)

```
# firewall-cmd --query-masquerade
```

<!--=================================================================-->

### forward-ports

forward-ports: { port=待受ポート:proto=プロトコル:toport=変換後ポート:toaddr=変換後IPアドレス }
待ち受けポートおよびプロトコルの通信を受信した場合に、ポートおよび送信元IPアドレスを変換してルーティングを行います。
forward-ports: port=8080:proto=tcp:toport=80:toaddr=192.168.1.1 等と記載されます。

#### public ゾーンでのポートフォワードの設定を確認(--list-forward-ports)

```
# firewall-cmd --zone=<zone name> --list-forward-ports
```


#### ポートフォワードする設定を追加(--add-forward-port)

TCP:99 宛のパケットを TCP:8888 宛にポートフォワードする設定を追加

```
# firewall-cmd --zone=<zone name> --add-forward-port=port=22:proto=tcp:toport=8888
```

#### ポートフォワードする設定が適用されているかを照会(--query-forward-port)

TCP:99 宛のパケットを TCP:8888 宛にポートフォワードする設定を確認

```
# firewall-cmd --zone=<zone name> --query-forward-port=port=22:proto=tcp:toport=8888
```

#### ポートフォワードする設定を削除(--remove-forward-port)

TCP:99 宛のパケットを TCP:8888 宛にポートフォワードする設定を削除

```
# firewall-cmd --zone=<zone name> --remove-forward-port=port=22:proto=tcp:toport=8888
```


<!--=================================================================-->

### icmp-blocks

icmp-blocks: { ICMP Type }
送られてきたときに拒否するICMPのタイプを指定します。ICMPタイプは firewall-cmd --get-icmptypes で確認できますが定義情報を見たいときは /usr/lib/firewalld/icmptypes の .xml ファイルを確認します。以下は redirect の例です。


ICMPタイプ定義ファイル

```
# pwd
/usr/lib/firewalld/icmptypes
# cat redirect.xml
<?xml version="1.0" encoding="utf-8"?>
<icmptype>
<short>Redirect</short>
<description>This error message informs a host to send packets on another route.</description>
</icmptype>
```

#### 定義済みの ICMP（インターネット制御通知プロトコル）を確認(--get-icmptypes)

```
# firewall-cmd --get-icmptypes
destination-unreachable echo-reply echo-request parameter-problem
redirect router-advertisement router-solicitation source-quench time-exceeded
```

#### 禁止されているICMPタイプを表示(--list-icmp-blocks)

```
# firewall-cmd --list-icmp-blocks –zone=<zone name>
```

#### ICMPタイプが禁止されているかを照会(--query-icmp-block)

```
# firewall-cmd --query-icmp-block=<ICMPタイプ名> --zone=<zone name>
```

#### 拒否するICMPタイプの追加(--add-icmp-block)

```
# firewall-cmd --add-icmp-block=<ICMPタイプ名> --zone=<zone name>
```

#### 拒否するICMPタイプの除外(--remove-icmp-block)

```
# firewall-cmd --remove-icmp-block=<ICMPタイプ名> --zone=<zone name>
```


<!--=================================================================-->

### rich-rule

    rich-rules: {rich rule}
    細かいルールを指定します。例えば送信元IPが192.168.200.0/24 からの TCP 135 番ポートを許可する場合は以下のように指定します。


#### rich-ruleの書式

rule family=<ipv4|ipv6> 必須  
[ source address=<ソースアドレス>[/mask] [invert=”true”] ]  
*invert=”true” 指定したソースアドレス以外の意味  
[ destination address=<ソースアドレス>[/mask] [invert=”true”] ]  
[ service name=<サービス名> ]  
[ port port=<ポート番号> protocol=<プロトコル> ]  
[ forward-port port=<ポート番号> protocol=<プロトコル> to-port=<ポート番号> to-addr=<アドレス> ]  
[ icmp-block name=<icmpタイプ> ]  
[ masquerade ]  
[ log [ prefix=<プレフィックス ] [level=<ログレベル> ] [ limit value=<レート>/<デュレイション> ] ]  
[ audit ]  
[ accept|reject|drop]  

#### rich-ruleの追加(--add-rich-rule)

```
firewall-cmd --add-rich-rule='rule family="ipv4" source address="192.168.200.0/24" port port="135" protocol="tcp" accept'
```

#### rich-ruleの削除(--remove-rich-rule)

```
firewall-cmd --remove-rich-rule='rule family="ipv4" source address="192.168.200.0/24" port port="135" protocol="tcp" accept'
```

#### rich-ruleの確認(--list-rich-rules)

```
firewall-cmd --list-rich-rules --zone=<zone name>
```

#### rich-ruleを照会(--query-rich-rule)

```
firewall-cmd --query-rich-rule='rule family="ipv4" source address="192.168.200.0/24" port port="135" protocol="tcp" accept'
```


<!--=================================================================-->

### ダイレクトルール

ダイレクトルールは、Netfilterに直接アクセスするためのものです。
ダイレクトルールを使えば、iptablesで設定できていたことは、
ほぼ全て設定できるようです。


#### ユーザ定義チェイン

##### ユーザ定義チェインの追加(--direct --add-chain)

ユーザ定義チェインを追加する。

```
# firewall-cmd --direct --add-chain ipv4 filter OUTPUT_direct_xxxxx
success
```

##### ユーザ定義チェインの表示(--direct --get-all-chains)

全てのユーザ定義チェインを確認する。

```
# firewall-cmd --direct --get-all-chains
ipv4 filter OUTPUT_direct_xxxxx
```

別の確認方法として、特定のテーブル(filer)のユーザ定義チェインを確認する。

```
# firewall-cmd --direct --get-chains ipv4 filter
```

##### ユーザ定義チェインの削除(--direct --remove-chain)

ユーザ定義チェインを削除する。

```
# firewall-cmd --direct --remove-chain ipv4 filter OUTPUT_direct_xxxxx
success
# firewall-cmd --direct --remove-chain ipv4 filter OUTPUT_direct_yyyyy
success
```

ユーザ定義チェインを確認する。2つとも削除できたことがわかる。

```
# firewall-cmd --direct --get-all-chains
```

#### ダイレクトルール

##### ダイレクトルールの追加(--add-rule)

ダイレクトルールを設定する。設定内容は、宛先ポート番号11111は廃棄する。

```
# firewall-cmd --direct --add-rule ipv4 filter OUTPUT 1 -p tcp --dport 11111 -j DROP
success
```

##### ダイレクトルールの表示(--get-all-rules, --get-rules)

定義されている全てのダイレクトルールを表示する。

```
# firewall-cmd --direct --get-all-rules
ipv4 filter OUTPUT 1 -o eth0 -d 224.0.0.18 -p vrrp -j ACCEPT
ipv4 filter INPUT 1 -i eth0 -d 224.0.0.18 -p vrrp -j ACCEPT
```

INPUTチェインのダイレクトルールだけを表示する。

```
# firewall-cmd --direct --get-rules ipv4 filter INPUT
```

#### ダイレクトルールの削除(--remove-rule)

ダイレクトルールを削除する。

```
# firewall-cmd --direct --remove-rule ipv4 filter OUTPUT 1 -p tcp --dport 11111 -j DROP
success
```

ダイレクトルールを表示する。

```
# firewall-cmd --direct --get-all-rules
```

#### ダイレクトルールでポート番号の範囲を指定する方法(multiport)

指定したポート番号の範囲についてフィルタを設定する方法を示します。
以下の例は、宛先TCPポート番号10000から10005までのパケットの受信許可をする設定です。

##### 宛先TCPポート番号が10000～10005のパケットの受信を許可する。

```
# firewall-cmd --direct --add-rule ipv4 filter INPUT 1 -i eth0 -p tcp -m multiport --dports 10000:10005 -j ACCEPT
success
```


##### 宛先TCPポート番号が10000-10005のパケットの受信許可のルールを削除する。()

```
# firewall-cmd --direct --remove-rule ipv4 filter INPUT 1 -i eth0 -p tcp -m multiport --dports 10000:10005 -j ACCEPT
success
```

#### パススルー

パススルーオプションの引数`<args>`は、対応するiptablesやip6tables、ebtablesの引数と同様です。

パススルーをIPレベルを定義

```
# firewall-cmd --direct --passthrough {ipv4|ipv6|eb} <arg>...
```

既存のパススルーを出力

```
# firewall-cmd --direct --get-all-passthroughs
```

パススルーのIPレベルを出力

```
# firewall-cmd --direct --get-passthroughs {ipv4|ipv6|eb} <arg>...
```

パススルーを追加設定

```
# firewall-cmd --direct --add-passthrough {ipv4|ipv6|eb} <arg>...
```

パススルーを削除

```
# firewall-cmd --direct --remove-passthrough {ipv4|ipv6|eb} <arg>...
```

既存のパススルーを照会

```
# firewall-cmd --direct --query-passthrough {ipv4|ipv6|eb} <arg>...
```

パススルーの設定例

```
# firewall-cmd --permanent --direct --passthrough ipv4 -I FORWARD -m physdev --physdev-is-bridged -j ACCEPT
# firewall-cmd --direct --passthrough ipv4 -I FORWARD -m physdev --physdev-is-bridged -j ACCEPT
```

パススルーの削除例

```
# firewall-cmd --permanent --direct --remove-passthrough ipv4 -m physdev --physdev-is-bridged -j ACCEPT
# firewall-cmd --direct --remove-passthrough ipv4 -I FORWARD -m physdev --physdev-is-bridged -j ACCEPT
```

<!--=================================================================-->

### ipset

ipsetユーティリティは、LinuxカーネルでIPセットを管理するために使用します。IPセットはIPアドレス、ポート番号、IPとMACアドレスのペア、またはIPアドレスとポート番号のペアを格納するために行われるフレームワークです。

オプションでtimeout、hashsize、maxelemようなファミリとオプションを追加する。
詳細は、 ipset （8）のマニュアルページを参照

#### ipsetを新たに作成(--new-ipset)

```
# firewall-cmd --permanent --new-ipset=<ipset name> --type=hash:net
```

#### ipsetを新たにファイルから作成(--new-ipset-from-file)

```
# firewall-cmd --permanent --new-ipset=<ipset name> --type=hash:net
```

#### ipsetを削除(--delete-ipset)

```
# firewall-cmd --permanent --delete-ipset=<ipset name>
```

#### ipsetのデフォルト設定をロード(--load-ipset-defaults)

```
# firewall-cmd --permanent --load-ipset-defaults=<ipset name>
```

#### ipsetに関する情報を表示(--info-ipset)

```
# firewall-cmd --permanent --info-ipset=<ipset name>
```

#### 定義されたipsetsをスペース区切りリストとして出力(--get-ipsets)

```
# firewall-cmd --permanent --get-ipsets
```

#### ipsetに新しい説明を設定(--set-description)

```
# firewall-cmd --permanent --ipset=<ipset name> --set-description=<description>
```

#### ゾーンの説明を出力(--get-description)

```
# firewall-cmd --permanent --get-description
```

<!--=================================================================-->

### helper

#### ヘルパーhelperに関する情報を表示(--info-helper)

```
# firewall-cmd --info-helper=<helper name>
```

新しいヘルパーにモジュールを追加

```
# firewall-cmd --new-helper=<helper name> --module=nf_conntrack_module [ --family=ipv4 | ipv6 ]
```

#### ヘルパーファイルから新しいヘルパーを追加(--new-helper-from-file)

```
# firewall-cmd --new-helper-from-file=filename [ --name=<helper name> ]
```

#### 既存のヘルパーを削除(--delete-helper)

```
# firewall-cmd --delete-helper=<helper name>
```

#### ヘルパーのデフォルト設定をロード(--load-helper-defaults)

```
# firewall-cmd --load-helper-defaults=<helper name>
```

#### ヘルパー構成ファイルのパス出力(--path-helper)

```
# firewall-cmd --path-helper=<helper name>
```

#### 定義されたヘルパーをスペースで区切ったリストとして出力(--get-helpers)

```
# firewall-cmd --get-helpers
```


#### ヘルパーの詳細設定(--helper)

新しい説明をヘルパーに設定

```
# firewall-cmd --helper=<helper name> --set-description=<description>
```

ヘルパーの説明の出力

```
# firewall-cmd --helper=<helper name> --get-description
```

短い説明をヘルパーに設定

```
# firewall-cmd --helper=<helper name> --set-short=<description>
```

ヘルパーの簡単な説明を出力

```
# firewall-cmd --helper=<helper name> --get-short
```

既存ヘルパーに新しいポートを追加

```
# firewall-cmd --helper=<helper name> --add-port=portid [ - portid ] / protocol 
```

既存ヘルパーからポートを削除

```
# firewall-cmd --helper=<helper name> --remove-port=portid [ - portid ] / protocol 
```

既存ヘルパーからポートを照会

```
# firewall-cmd --helper=<helper name> --query-port=portid [ - portid ] / protocol 
```

ヘルパーからポートの確認

```
# firewall-cmd --helper=<helper name> --get-ports 
```

ヘルパーにモジュールを設定

```
# firewall-cmd --helper=<helper name> --set-moduledescription 
```

ヘルパーのモジュールを出力

```
# firewall-cmd --helper=<helper name> --get-module
```

ヘルパーにfamilyを設定

```
# firewall-cmd --helper==helper --set-familydescription
```

ヘルパーのfamilyを出力

```
# firewall-cmd --helper=helper --get-family 
```

<!--=================================================================-->

### icmptype

#### 新しくicmptypeを追加(--new-icmptype)

```
# firewall-cmd --new-icmptype=<icmptype>
```

#### 新しくicmptypeをファイルから追加(--new-icmptype-from-file)

```
# firewall-cmd --new-icmptype-from-file=<filename> [--name=<icmptype>]
```

#### icmptypeを削除(--delete-icmptype)

```
# firewall-cmd --delete-icmptype=<icmptype>
```

#### デフォルトのicmptypeをロード(--load-icmptype-defaults)

```
# firewall-cmd --load-icmptype-defaults=<icmptype>
```

#### icmptypeの情報を出力(--info-icmptype)

```
# firewall-cmd --info-icmptype=<icmptype>
```

#### icmptypeのファイルパスを出力(--path-icmptype)

```
# firewall-cmd --path-icmptype=<icmptype>
```

#### icmptype詳細設定(--icmptype)

icmptypeの説明を設定

```
# firewall-cmd --icmptype=<icmptype> --set-description=<description>
```

icmptypeの説明を出力

```
# firewall-cmd --icmptype=<icmptype> --get-description
```

icmptypeの短い説明を追加

```
# firewall-cmd --icmptype=<icmptype> --set-short=<description>
```

icmptypeの短い説明を出力

```
# firewall-cmd --icmptype=<icmptype> --get-short
```

icmptypeの説明を追記

```
# firewall-cmd --icmptype=<icmptype> --add-destination=<ipv>
```

icmptypeの説明を削除

```
# firewall-cmd --icmptype=<icmptype> --remove-destination=<ipv>
```

icmptypeの説明を照会

```
# firewall-cmd --icmptype=<icmptype> --query-destination=<ipv>
```

icmptypeの説明をリスト出力

```
# firewall-cmd --icmptype=<icmptype> --get-destinations
```

<!--=================================================================-->

### ファイアウォールのロックダウン

ローカルのアプリケーションやサービスは、root で実行していれば (たとえば libvirt) ファイアウォール設定を変更することができます。この機能を使うと、管理者はファイアウォール設定をロックして、どのアプリケーションもファイアウォール変更を要求できなくするか、ロックダウンのホワイトリストに追加されたアプリケーションのみがファイアウォール変更を要求できるようにすることが可能になります。ロックダウン設定はデフォルトで無効になっています。これを有効にすると、ローカルのアプリケーションやサービスによるファイアウォールの望ましくない変更を確実に防止することができます。 

ロックダウンを有効化するとroot以外のユーザが操作すると以下のようになります。

```
$ firewall-cmd --add-service=imaps
Error: ACCESS_DENIED: lockdown is enabled
```


#### ロックダウン有効化

```
# firewall-cmd --lockdown-on
```

#### ロックダウン無効化

```
# firewall-cmd --lockdown-off
```

#### ロックダウン設定を照会

```
# firewall-cmd --query-lockdown
```

#### ロックダウンのホワイトリスト詳細設定
ロックダウンホワイトリストのエントリは、次の順序でチェックされます。 
1. context 
2. uid 
3. user 
4. command

ホワイトリストにあるすべてのコマンドラインを一覧表示

```
# firewall-cmd --list-lockdown-whitelist-commands
```

commandホワイトリストに追加

```
# firewall-cmd --add-lockdown-whitelist-command=<command>
```

commandホワイトリストに追加例

```
# firewall-cmd --add-lockdown-whitelist-command='/usr/bin/python -Es /usr/bin/command'
```

commandホワイトリストから削除

```
# firewall-cmd --remove-lockdown-whitelist-command=<command>
```

commandホワイトリストから削除例

```
# firewall-cmd --remove-lockdown-whitelist-command='/usr/bin/python -Es /usr/bin/command'
```

commandがホワイトリストにあるかどうかを照会

```
# firewall-cmd --query-lockdown-whitelist-command=<command>
```

commandがホワイトリストにあるかどうかを照会例

```
# firewall-cmd --query-lockdown-whitelist-command='/usr/bin/python -Es /usr/bin/command'
```

ホワイトリストにあるすべてのコンテキストを一覧表示

```
# firewall-cmd --list-lockdown-whitelist-contexts
```

コンテキストをホワイトリストに追加

```
# firewall-cmd --add-lockdown-whitelist-context=<context>
```

コンテキストをホワイトリストから削除

```
# firewall-cmd --remove-lockdown-whitelist-context=<context>
```

コンテキストがホワイトリストにあるかどうかを照会

```
# firewall-cmd --query-lockdown-whitelist-context=<context>
```

ホワイトリストにあるすべてのユーザーIDを一覧表示

```
# firewall-cmd --list-lockdown-whitelist-uids
```

uidホワイトリストにユーザーID を追加
```
# firewall-cmd --add-lockdown-whitelist-uid=<uid>
```

idホワイトリストからユーザーID を削除

```
# firewall-cmd --remove-lockdown-whitelist-uid=<uid>
```

ユーザーID uidがホワイトリストにあるかどうかを照会

```
# firewall-cmd --query-lockdown-whitelist-uid=<uid>
```

ホワイトリストにあるすべてのユーザー名を一覧表示

```
# firewall-cmd --list-lockdown-whitelist-users
```

userホワイトリストにユーザー名を追加

```
# firewall-cmd --add-lockdown-whitelist-user=<user>
```

userホワイトリストからユーザー名を削除

```
# firewall-cmd --remove-lockdown-whitelist-user=<user>
```

ユーザー名userがホワイトリストにあるかどうかを照会

```
# firewall-cmd --query-lockdown-whitelist-user=<user>
```


<!--=================================================================-->

## システム保守時役立つコマンド

### すべてのネットワーク通信が遮断する

```
# firewall-cmd --panic-on
```

### パニックモードを止める

```
# firewall-cmd --panic-off
```


## firewalld の初期化方法

--permanentを付けて設定した内容は、以下の設定ファイルに書き込まれます。
/etc/firewalld/zones/public.xml

設定ファイルに書き込むだけなので、再起動/再読込時には反映されますが、既存稼働中プロセスには反映しません。初期化したいときは上記xmlファイルを削除もしくは mv で退避すればOKです。元ネタは /usr/lib/firewalld/zones にあるから大丈夫。

```
# pwd
/usr/lib/firewalld/zones
# cat public.xml
<?xml version="1.0" encoding="utf-8"?>
<zone>
<short>Public</short>
<description>For use in public areas. You do not trust the other computers on networks to not harm your computer. Only selected incoming connections are accepted.</description>
<service name="ssh"/>
<service name="dhcpv6-client"/>
</zone>
```

/etc/firewalld/zones/public.xml のファイルを削除して --reload すると上記元ネタから読み込んできます。次回--permanent設定をすると、/etc/firewalld/zones に pulic.xml が新たに生成されます。

## よくある事象

複数NICがあるサーバで、I/F毎に別々のzoneを設定する場合に
永続的な変更をしたのにも関わらず、サーバを再起動すると
設定が元に戻ってしまう。

設定を以下のようにして、I/F毎に別々のzoneを設定する。

```
# firewall-cmd --get-active-zone
public
interfaces: eth0 eth1
# firewall-cmd --get-default-zone
public

# firewall-cmd --change-interface=eth1 --zone=external --permanent
success
# firewall-cmd --get-active-zone
external
interfaces: eth1
public
interfaces: eth0
```

だが、OS再起動すると設定が元に戻っている場合がある。

```
# firewall-cmd --get-active-zone
public
interfaces: eth0 eth1
```

ゾーンの設定はNetworkManagerからも設定できます。

```
# nmcli conn show eth1 | grep zone
connection.zone: --
# nmcli conn mod eth1 connection.zone external
# nmcli conn show eth1 | grep zone
connection.zone: external
# firewall-cmd --get-active-zone
external
interfaces: eth1
public
interfaces: eth0
```

この設定は、再起動後も維持されます。

開放するサービス/ポート等のルール → firewall-cmd
ゾーンの設定 → NetworkManager
で分けべきなのでしょうか!?

ちなみに、[/etc/sysconfig/network-scripts/ifcfg-*]に直接、
ZONE=externalを追記してzoneを変更できるとの記載もありましたが
そもそも、NetworkManagerでは[/etc/sysconfig/network-scripts/ifcfg-*]
に直接追記することは推奨されていないため、本来がNGなんでしょう。


## 参考

以下、サイトを参考にさせていただきました。
https://fedoraproject.org/wiki/FirewallD/jp
https://firewalld.org/documentation/man-pages/firewall-cmd.html
https://access.redhat.com/documentation/ja-jp/red_hat_enterprise_linux/7/html/security_guide/sec-Using_Firewalls
https://www.nedia.ne.jp/blog/tech/2015/10/13/6031
