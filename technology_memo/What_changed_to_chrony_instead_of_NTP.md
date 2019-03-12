---
layout: default
title: NTPに変わるChronyって何が変わったの？
---

# NTPに変わるChronyって何が変わったの？

RHEL7でも標準でもChronyは、標準で導入されていましたが、RHEL8BetaではChronyのみがサポートされるようになりました。
RHEL8は、現状Beta版ではありますが今年中には正式版もでるでしょうから、今のうちにchronyを調査・検証してみようと思います。


## 1. Chronyとは
### 1.1. Chronyとは

Chronyは、NTPクライアントとNTPサーバーの実装のひとつです。NTPのリファレンス実装であるntpdとは異なる時刻同期アルゴリズムを採用しているため、より効率良く正確な時刻同期を提供します。

また、Chronyはネットワーク接続が頻繁に切断される、ネットワークの混雑や遅延が発生する、温度が変わるといった様々な条件下や、時刻の同期が継続的に実行されない、または仮想マシンで実行されているといったシステムであっても時刻がずれないような工夫がされているようです。

[chrony公式HP](http://chrony.tuxfamily.org/)


### 1.2. NTPとの違いは？

- NTPのバージョンが異なる
  chronydはNTPバージョン3(RFC1305)、ntpdはNTPバージョン4(RFC 5905)を使用する。
  (バージョン3はバージョン4と完全互換性があります)

- ハードウェアクロックとの同期
  chronydはハードウェアクロックとの同期が可能、ntpdは不可。

- slewモードのslewレート

  NTPサーバと同様にChronyもstepモードとslewモードがあります。(stepモードがChronyのデフォルト)

  ntpdのslewレートは500(msec/sec)の固定に対して、chronyはslewレートを変更可能となっている。(defaultは83333.333(msec/sec))

- 使用ポート

  NTPは123固定でしたが、chronyはdefault:123ではあるが変更も可能。

  


## 2. chronyを導入してみる

### 2.1. 環境

OS:CentOS 7.5
ミドルウェア:chrony-3.2-2.el7.x86_64

OS:RHEL 8.0 Beta
ミドルウェア:chrony-3.3-3.el8.x86_64

### 2.2. chrony導入

CentOS 7.5、RHEL 8.0 Betaのどちらも標準パッケージに同梱されているため、新たにインストールする必要はありません。
systemctlコマンドでサービスの起動設定するだけで使用できますが、CentOS、ではNTPと動作が被らないように

ちなみにRHEL7.3では、最小インストールで`chrony-2.1.1-3.el7.x86_64`が導入されていました。

### 2.3. Chrony設定

各設定の詳細は、[RHEL公式](https://access.redhat.com/documentation/ja-jp/red_hat_enterprise_linux/7/html/system_administrators_guide/sect-understanding_chrony_and-its_configuration)HPを参照して下さい。

chronyの設定ファイル 【/etc/chrony.conf】 はntpdの設定ファイル 【/etc/ntp.conf】 とほぼ同じフォーマットであり設定項目もかなり似ています。

以下はRHEL8Betaのdefault設定です。CentOS7.5との違いはNTPサーバの宛先指定がserverでRHEL8はpool指定となっているのと`leapsectx right/UTC`が追加されていました。

**【rtcsync】**でリアルタイムクロック(HWクロック)を 11 分ごとに更新してくれるので設定しておいたほうがいいでしょう。

```
# Use public servers from the pool.ntp.org project.
# Please consider joining the pool (http://www.pool.ntp.org/join.html).
pool 2.rhel.pool.ntp.org iburst

# Record the rate at which the system clock gains/losses time.
driftfile /var/lib/chrony/drift

# Allow the system clock to be stepped in the first three updates
# if its offset is larger than 1 second.
makestep 1.0 3

# Enable kernel synchronization of the real-time clock (RTC).
rtcsync

# Enable hardware timestamping on all interfaces that support it.
#hwtimestamp *

# Increase the minimum number of selectable sources required to adjust
# the system clock.
#minsources 2

# Allow NTP client access from local network.
#allow 192.168.0.0/16

# Serve time even if not synchronized to a time source.
#local stratum 10

# Specify file containing keys for NTP authentication.
#keyfile /etc/chrony.keys

# Get TAI-UTC offset and leap seconds from the system tz database.
leapsectx right/UTC

# Specify directory for log files.
logdir /var/log/chrony

# Select which information is logged.
#log measurements statistics tracking
```



#### 2.3.1. NTP Clientとして設定

私の経験上、NTPをstepモードで使用することはなく、slewモードに変更して使用していましたのでslewモードに変更します。

[makestep]の行をコメントアウトし、[leapsecmode]で"slew"を設定

```
# vi /etc/chrony.conf 
server Local_NTP_Server
stratumweight 0
driftfile /var/lib/chrony/drift
rtcsync
#makestep 1.0 3
leapsecmode slew

noclientlog
logchange 0.5
logdir /var/log/chrony
```

#### 2.3.2. NTPサーバとして設定

allow、denyでセキュリティを考慮しNTP Clientが接続してくるセグメントのみ許可したほうがいいでしょう。
以下の設定の場合は、全てを拒否し、`192.168.120.0/24`を許可しています。
`bindaddress`は、特定のIPをbindすることができるので
同期先サーバが1つもない場合の自身のstratumするため`local`を設定する。

```
# vi /etc/chrony.conf 
pool xxx.xxx.xxx.xxx
stratumweight 0
driftfile /var/lib/chrony/drift
rtcsync
leapsecmode slew

deny all
allow 192.168.120
bindaddress 127.0.0.1
bindcmdaddress ::1
local stratum 10

#noclientlog
logchange 0.5
logdir /var/log/chrony
```

### 2.4. chrony関連コマンド

#### 2.4.1. NTPサーバへの接続状態を示すコマンド`chronyc sources`

ntpdの`ntpq -p`コマンドの変わりに使用するコマンド。

```
$ chronyc sources
210 Number of sources = 4
MS Name/IP address         Stratum Poll Reach LastRx Last sample
===============================================================================
^- ntp3.jst.mfeed.ad.jp          2  10   377   962   +400us[ +472us] +/-  134ms
^* ntp-a2.nict.go.jp             1  10   377    61   +183us[ +259us] +/- 1518us
^- y.ns.gin.ntt.net              2   9   377   472  -1334us[-1260us] +/-  107ms
^- ec2-13-230-38-136.ap-nor>     2  10   377   32m    -16us[  +63us] +/-   24ms
```

先頭の`M`列が`^`はNTPサーバーを指します。2番目の`S`列では、`*`が現在の同期元、`+`が同期候補、`-`が候補外を示します。時刻同期が動作していることが確認できますね。

#### 2.4.2. トラッキング

[chronyc sources]は接続先を示すのに対して[chronyc tracking]は自身の状態をトラッキング(追跡)するのに使用します。そのため、自信の状態を詳細に出力します。

```
$ chronyc tracking
Reference ID    : 85F3EEF3 (ntp-a2.nict.go.jp)
Stratum         : 2
Ref time (UTC)  : Fri Mar 08 07:10:48 2019
System time     : 0.000014556 seconds fast of NTP time
Last offset     : +0.000023046 seconds
RMS offset      : 0.000064057 seconds
Frequency       : 12.805 ppm fast
Residual freq   : +0.000 ppm
Skew            : 0.017 ppm
Root delay      : 0.002851847 seconds
Root dispersion : 0.000952405 seconds
Update interval : 1043.9 seconds
Leap status     : Normal
```



#### 2.4.3. 手動による時刻合わせ

slewモードで設定していても、強制的一度に修正するstepモードでシステムクロックと同期します。

```
# chronyc -a makestep
200 OK
```


#### 2.4.4. システムクロックとハードウェアクロックを同期させる

```
# chronyc -a trimrtc
200 OK
```

<!-- 513 RTC driver not running 対処不明 後日調査 -->

#### 2.4.5. クライアントの情報

chrony.confの`noclientlog`をコメントアウトしてないとクライアント情報を確認することができませんので注意して下さい。

```
# chronyc -a clients
Hostname           Client  Peer  CmdAuth CmdNorm  CmdBad  LstN  LstC
=================  ======  =====  ======  ======  ======  ====  ====
localhost               0      0       3       3       0   49y     0
192.168.1111.128        1      0       0       0       0     4   49y
```

#### 2.4.6. ポーリング間隔

ポーリング間隔は、デフォルトで `minpoll` 値は 6、`maxpoll`が10となっている。

NTPと同様にこの値は、設定値をnとすると$2^{n}$となる。なのでdefault `minpoll` は、64秒、`maxpoll`は1024秒ととなる。

この間隔を変えるには、`/etc/chrony.conf`を変更することで変えられるがクロック精度を高めるためにはdefaultよりは小さくすべきでしょう。

```
server <NTP server address> minpoll 5 maxpoll 9
```



### 最後に

以上の検証から設定及び確認コマンドの違いについては理解でき、chronyの方が明らかに精度は上がっている。

ただし使用してみた感じ、検証の方法が悪いのだろうがNW切断や遅延でのchronyのメリットは感じられなかったｗ

後は検証する環境があればpeer設定での動作検証を後日できればな~

