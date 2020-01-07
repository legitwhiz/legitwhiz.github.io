# NetApp Beginner

## NetApp の aggregate snapshot について

aggregate snapshot の特徴は以下のとおりです。
" aggregate の snapshot は、デフォルトで aggregate の全容量の 5% が予約されています。
" aggregate の snapshot 領域は、主に以下の状況で使用されます。 %flexvolume を削除した際、flexvolume 上のデータが、aggregate snapshot に参照されていた場合。
%volume snapshot やデータ削除により、解放されるデータが aggregate snapshot に参照されていた場合。

" aggregate snapshot 領域が 100% になった場合、autodelete により、削除されます。

aggregate snapshot は、SyncMirror を行わない場合は特に必要ありません。
 以下、aggregate snapshot を削除し、スケジュール取得を停止する手順になります。

aggregate の空き状態を確認します。

```
# df -Ag
Aggregate                total       used      avail capacity
aggr0                   4245GB      941GB     3304GB      22%
aggr0/.snapshot          223GB        4GB      218GB       2%
```

aggregate schedule snapshot の設定を確認します。

```
# snap sched -A
Aggregate aggr0: 0 1 4@9,14,19
```

aggregate snapshot 領域の割合を確認します。

```
# snap reserve -A
Aggregate aggr0: current snapshot reserve is 5% or 234326544 k-bytes.
```

aggregate snapshot を確認します。

```
# snap list -A -n
Aggregate aggr0
working...

date          name
------------  --------
Oct 04 14:00  hourly.0
Oct 04 09:00  hourly.1
Oct 04 00:01  nightly.0
Oct 03 19:00  hourly.2
Oct 03 14:00  hourly.3
```

aggregate schedule snapshot を停止します。

```
# snap sched -A aggr0 0 0 0
```

aggregate snapshot を全て削除します。

```
# snap delete -A -a aggr0
Are you sure you want to delete all snapshots for aggregate aggr0? y
Deleted aggr0 snapshot hourly.3.
Deleted aggr0 snapshot hourly.2.
Deleted aggr0 snapshot nightly.0.
Deleted aggr0 snapshot hourly.1.
Deleted aggr0 snapshot hourly.0.
```

aggregate snapshot 領域割合を 0% に変更します。

```
# snap reserve -A aggr0 0
```

aggregate schedule snapshot の設定を確認します。

```
# snap sched -A
Aggregate aggr0: 0 0 0
```

aggregate snapshot を確認します。

```
# snap list -A -n
Aggregate aggr0
working...

No snapshots exist.
```

aggregate snapshot 領域の割合を確認します。

```
# snap reserve -A
Aggregate aggr0: current snapshot reserve is 0% or 0 k-bytes.

aggregate の空き状態を確認します。

```
df -Ag
Aggregate                total       used      avail capacity
aggr0                   4469GB      941GB     3527GB      21%
aggr0/.snapshot            0GB        0GB        0GB     ---%
```

## Ontap シミュレーターで Flash Pool を試す 

Flash Pool とは

HDD と SSD が混在したアグリゲートを構成し、使用頻度の高いデータを SSD のキャッシュへ集めることで、HDD へのアクセスを低減する機能になります。データを移動させるわけではなく、アクセス頻度の高いデータを ONTAP が自動で判別し、キャッシュされる事から、運用稼動は発生しません。
 下記は、ユーザ数の増加に伴うスループットの傾向です。（出典：Tech OnTap）

f:id:FriendsNow:20150311205706p:plain
HDD のみで構成した場合、100ユーザの時点で HDD がボトルネックになり、スループットが頭打ちになっています。これに対して、Flash Pool を使用した場合は、ユーザの増加に伴い、スループットが向上しています。


### Flash Pool の設定方法

ONTAP シミュレータで SSD Disk を擬似的に作成し、Flash Pool をを設定する際の手順になります。


SSD Disk の作成

- Unlock the Diag user(7-Mode)

# priv set diag
*> useradmin diaguser unlock
*> useradmin diaguser password
```

- Unlock the Diag user(Clustered Mode)

```
# set diag
*> security login unlock -username diag -vserver cluster1
*> security login password -username diag -vserver cluster1
```

- Enter system shell(7-Mode)

```
*> systemshell
login: diag
Password:
%
```

- Enter system shell(Clustered Mode)

```
*> systemshell -node cluster1-01
login: diag
Password:
%
```

- Create SSD Disks(7-Mode/Clustered Mode)

```
% setenv PATH /sim/bin:$PATH
% cd /sim/dev
% sudo vsim_makedisks -t 35 -a 2 -n 14
% exit
```

- Vefify the Disks(7-Mode)

```
*> disk show -n
*> sysconfig -r
```

- Vefify the Disks(Clustered Mode)

```
*> disk show -container-type unassigned
*> system node run -node cluster1-01 sysconfig -r
```

```
Assign the Disks(7-Mode)
> disk assign  v6.16
```

Assign the Disks(Clustered Mode)

```
> disk assign -disk v6.16 -owner cluster1-01
```

### Flash Pool の有効化

- Enable the Flash Pool(7-Mode)

```
> aggr options aggr1 hybrid_enabled on
> aggr add aggr1 -T SSD 14
```

- Enable the Flash Pool(Clustered Mode)

```
> storage aggregate modify -aggregate aggr1 -hybrid-enabled true
> aggregate add-disks -aggregate aggr1 -disktype SSD -diskcount 14
```

- Use the Flash Pool(7-Mode)

```
> vol create myvol aggr1 1g
```

- Use the Flash Pool(Clustered Mode)

```
> volume create -vserver svm-01 -aggregate aggr1 -volume myvol -size 1g
```

### busy,LUNs 状態の Snapshot について 

SnapManager for Exchange (SME) 等のベリファイ処理失敗時に、残存する Snapshot になります。
 以下の手順で削除する事が可能です。

- snap list コマンドで busy 状態の Snapshot を確認します。

```
> snap list testvol
Volume testvol
working...

  %/used       %/total  date          name
----------  ----------  ------------  --------
<...snip...>
 56% (12%)   26% ( 3%)  Dec 18 05:01  exchsnap__exchange_02-23-2009_05.00.40 (busy,LUNs)
```

- Snapmirror の送信元/送信先で Clone LUN が存在する事を確認します。

```
> lun show
<...snip...>
/vol/testvol/{3fd1acat-346c-216d-b6e4-bdf90a52801f}.rws
```

- Snapmirror 送信先で snapmirror break を実行します。

```
> snapmirror break testvol
```

- Snapmirror 送信先で lun offline/lun destroy を実行します。

```
> lun offline /vol/testvol/{3fd1acat-346c-216d-b6e4-bdf90a52801f}.rws
> lun destroy /vol/testvol/{3fd1acat-346c-216d-b6e4-bdf90a52801f}.rws
```

SnapDrive にて、Clone LUN をマウントしている場合は、Disconnect Disk を実行します。

- Snapmirror 送信元で不要な Snapshot を削除します。

```
> snap delete testvol exchsnap__exchange_02-23-2009_05.00.40
```

- Snapmirror resync を実行します。

```
> snapmirror resync -S [Sorce]:testvol testvol
```

## HA コントローラ構成における NVRAM について 


NetApp のコントローラを HA で構成した場合、各コントローラ上の NVRAM の半分がパートナーデータのミラー用として、リザーブされます。（使用できる NVRAM が 非 HA 構成と比較し 1/2 になります。）
Takeover 発生時、残ったコントローラは、このミラー用の NVRAM を使用して、ダウンコントローラの Read/Write を処理します。つまり、Takeover が発生した際には、NVRAM は縮退せず、CPU /Memory のみ縮退するという事になります。


### NVRAM During Normal Mode


踏み台サーバー（192.168.1.100）を経由して、複数の NetApp の aggregate と volume の使用量を収集するマクロです。任意の Host（192.168.1.101-105）に、巡回アクセスして "df -Ag" と "df -h"を実行します。

TeraTerm マクロ例 

```
connect '192.168.1.100 /ssh /auth=password /user=root /passwd=default'
wait '$'

;================ logopen ================
getdir DIR
getdate DATE
gettime TIME
strcopy TIME 1 2 HH
strcopy TIME 4 2 MM
strcopy TIME 7 2 SS
LOG = DIR
strconcat LOG ''
strconcat LOG DATE
strconcat LOG '_'
strconcat LOG HH
strconcat LOG MM
strconcat LOG SS
strconcat LOG '_'
strconcat LOG 'netapp.log'
logopen LOG 0 1

;================ login ================
sendln
wait '$'
for i 1 1           ※192.168.1.101 でのみ実行したい場合
;for i 1 5          ※192.168.1.101-105 で実行したい場合
  if i =  1 then
    HOST = '192.168.1.101'
  elseif i =  2 then
    HOST = '192.168.1.102'
  elseif i =  3 then
    HOST = '192.168.1.103'
  elseif i =  4 then
    HOST = '192.168.1.104'
  elseif i =  5 then
    HOST = '192.168.1.105'
  endif
  PR = HOST
  strconcat PR '> '
  sendln 'ssh -l root ' HOST
  wait 'password:'
  sendln 'default'
  wait PR
;================ command ================
  sendln 'df -Ag'
  wait PR
  sendln 'df -h' 
  wait PR
;================ logout =================
  sendln 'logout telnet'
  wait '$'
next

;================ logclose ================
logclose
sendln 'exit'
```

## NetApp の Config バックアップ・リストアについて 

システム障害によるデータ損失に備え、volume 内のデータは SnapMirror 等でバックアップを取りますが、コントローラー及び、volume の一部の設定情報については、config コマンドでバックアップ・リストアが可能です。
 （参考）PROFESSIONAL SERVICE TECH NOTE #034

なお、下記の情報については対象外となりますのでご注意ください。
 vol options
ignore_inconsistent, guarantee, svo_enable, svo_checksum, svo_allow_rman, svo_reject_errors
fractional_reserve, try_first, snapshot_clone_dependency, dlog_hole_reserve, nbu_archival_snap

etc 配下の下記ファイル
asup_content.conf, asuptriggers.conf, asuptriggers.sample, filersid.cfg, krb5関連ファイル
qual_devices, rlm_config_to_filer, services, rmtab, snmppersist.conf


### バックアップ手順

- config dump -v "任意のファイル名"で、設定ファイルを保存します。

```
> config dump -v config01.cfg
```

- 設定ファイルは、/etc/cofnigs 配下へ保存されます。

```
> priv set advanced
> ls /etc/configs
.
..
config_saved
config01.cfg
config02.cfg
```

- 必要に応じてサーバで vol0 をマウントし、生成されたファイルを取得します。

```
# mount -t nfs 192.168.1.51:/vol/vol0 /mnt
# cp -p /mnt/etc/configs/config*.cfg /tmp
```

- 設定ファイルを複数保存した場合、config diff コマンドで差分を確認できます。

```
> config diff config01.cfg config02.cfg
## changed
< file.contents.exports=\
/vol/vol0       -sec=sys,rw,anon=0,nosuid
/vol/vol1       -sec=sys,rw,nosuid
/vol/vol2       -sec=sys,rw,nosuid
/vol/vol0/home  -sec=sys,rw,nosuid
\
---
> file.contents.exports=\
/vol/vol0/home  -sec=sys,rw,nosuid
\
```

### リストア手順

- config dump -v "保存ファイル名"で、設定をリストアします。

```
> config dump -v config01.cfg
```

## Netapp NFS データストアマウント (VMware) 

NetApp で作成した Volume に VMware ESXi5.0 で NFS データストアを作成する手順を紹介させて頂きます。

### NetApp NFS ボリューム作成手順

- iSCSI と異なり NFS はデフォルトで有効となっています。

```
ontap> nfs status
NFS server is running.
```

Volume 作成後、Export が自動で行われマウント可能となりますが、R/W は許可されていないため、root ユーザーからの操作を受け付けるように設定する必要があります。設定は wrfile コマンドで直接行う事も可能ですが、本例では CentOS で /vol/vol0*1をマウントし、vi エディタで編集します。

```
ontap> exportfs
/vol/pocvol     -sec=sys,rw,nosuid
```

CentOS でマウントするために vol/vol0 を export します。Volume pocvol1~pocvol3 は作成後、自動で export されるので、これを含めた形で設定します。仮に /vol/vol0 のみ設定した場合、他の export 設定は上書き削除されるため、注意が必要です。そのため、この方法を用いる場合は、Volume 作成前にまず、vol0 を export する方が良いかもしれません。

- flexvolume の exports の状態を確認します。

```
ontap> rdfile /vol/vol0/etc/exports
/vol/pocvol1    -sec=sys,rw=nosuid
/vol/pocvol2    -sec=sys,rw=nosuid
/vol/pocvol3    -sec=sys,rw,nosuid
/vol/vol0       -sec=sys,ro
```

※wrfile を実行するとファイルの内容が全て削除されるため、必ず rdfile を事前に実行します。

- wrfile で exports の設定を変更します。

```
ontap> wrfile /vol/vol0/etc/exports
/vol/pocvol1    -sec=sys,rw=nosuid
/vol/pocvol2    -sec=sys,rw=nosuid
/vol/pocvol3    -sec=sys,rw,nosuid
/vol/vol0       -sec=sys,rw,nosuid,anon=0
```

exportfs -p を使用すると、任意のボリュームのみ exports を設定する事が可能です。

```
ontap> exportfs -p sec=sys,rw,nosuid,anon=0 /vol/vol0
```

- exports の設定を反映します。

```
ontap> exportfs -a
```

- CentOS にログインし、マウントポイントを作成します。例では「pocontap」とします。

```
# cd /mnt/
# mkdir pocontap
```

- Netapp（192.168.72.20）の /vol/vol0 領域をマウントします。

```
# mount -t nfs 192.168.72.20:/vol/vol0 /mnt/pocontap

# df -h
Filesystem            Size  Used Avail Use% Mounted on
/dev/mapper/VolGroup00-LogVol00
                       16G  2.3G   13G  16% /
/dev/sda1              99M   13M   81M  14% /boot
tmpfs                 501M     0  501M   0% /dev/shm
192.168.72.20:/vol/vol0
                      809M  210M  600M  26% /mnt/pocontap
```

vi エディタで exports ファイルを編集します。例では、pocvol1,2 を NFS データストアとして使用するため、これらに anon=0 オプション及び、R/W を許可するホストの IP アドレスを設定します。

```
# vi /mnt/pocontap/etc/exports
/vol/pocvol1    -sec=sys,rw=1.1.1.17:1.1.1.16,nosuid,anon=0
/vol/pocvol2    -sec=sys,rw=1.1.1.17:1.1.1.16,nosuid,anon=0
/vol/pocvol3    -sec=sys,rw,nosuid
/vol/vol0       -sec=sys,rw,nosuid,anon=0
```

- Netapp にログインし、export ファイルを更新します。

```
ontap> exportfs -r
ontap> exportfs
/vol/pocvol1    -sec=sys,rw=1.1.1.17:1.1.1.16,anon=0,nosuid
/vol/pocvol2    -sec=sys,rw=1.1.1.17:1.1.1.16,anon=0,nosuid
/vol/pocvol3    -sec=sys,rw,nosuid
/vol/vol0       -sec=sys,rw,anon=0,nosuid
```

- CentOS でマウントを解除し、編集を終了します。

```
# umount -l nfs 192.168.72.20:/vol/vol0
```

### vSphere での NFS データストア追加手順

構成タブのハードウェアペインから、ストレージを選択し、「ストレージの追加」をクリックします。
f:id:FriendsNow:20131209210021p:plain

ストレージタイプで、「ネットワークファイルシステム」を選択します。
f:id:FriendsNow:20131209210123p:plain

サーバーに、NFS サーバーののアドレスを設定し、フォルダに作成した領域の場所を指定します。
f:id:FriendsNow:20131209210130p:plain

内容を確認し「終了」をクリックします。
f:id:FriendsNow:20131209210142p:plain

下記のようにデータストアが追加され、共有ストレージとして使用可能となります。
f:id:FriendsNow:20131209210202p:plain


*1:設定ファイルの Path は、/vol/vol0/etc/exports となります。


## setup

```
FAS2040> setup
The setup command will rewrite the /etc/rc, /etc/exports,       
/etc/hosts, /etc/hosts.equiv, /etc/dgateways, /etc/nsswitch.conf,       
and /etc/resolv.conf files, saving the original contents of       
these files in .bak files (e.g. /etc/exports.bak).       
Are you sure you want to continue? [yes] yes       
 NetApp Release 7.3.2: Thu Oct 15 04:17:39 PDT 2009      
 System ID: 0135107715 (FAS2040)      
 System Serial Number: 850000026045 (FAS2040)      
 System Rev: A6      
 System Storage Configuration: Mixed-Path      
 System ACP Connectivity: No Connectivity      
 slot 0: System Board      
                Processors:         2       
                Memory Size:        4096 MB       
 slot 0: Private BGE 10/100 Ethernet Controller      
  e0P MAC Address:    00:a0:98:26:dd:b8 (auto-unknown-cfg_down)     
 slot 0: Dual 10/100/1000 Ethernet Controller G20      
  e0a MAC Address:    00:a0:98:26:dd:bd (auto-1000t-fd-up)     
  e0b MAC Address:    00:a0:98:26:dd:bc (auto-unknown-cfg_down)     
  e0c MAC Address:    00:a0:98:26:dd:bb (auto-unknown-cfg_down)     
  e0d MAC Address:    00:a0:98:26:dd:ba (auto-unknown-cfg_down)     
<...snip...>    
Please enter the new hostname [FAS2040]:        
Do you want to enable IPv6? [n]: n       
Do you want to configure virtual network interfaces? [n]: n       
Vif は、Network Interface を1つの論理インターフェースに集約します。  

Please enter the IP address for Network Interface e0a [192.168.253.45]:       
Please enter the netmask for Network Interface e0a [255.255.255.0]:       
Please enter media type for e0a {100tx-fd, tp-fd, 100tx, tp, auto (10/100/1000)} [auto]: auto       
Please enter flow control for e0a {none, receive, send, full} [full]:        
Do you want e0a to support jumbo frames? [n]: y         
Please enter the IP address for Network Interface e0b :        
Please enter the IP address for Network Interface e0c : 10.1.1.1     
Please enter the netmask for Network Interface e0c [255.0.0.0]: 255.255.255.0       
Please enter media type for e0c {100tx-fd, tp-fd, 100tx, tp, auto (10/100/1000)} [auto]:        
Please enter flow control for e0c {none, receive, send, full} [full]:        
Do you want e0c to support jumbo frames? [n]:        
Please enter the IP address for Network Interface e0d : 10.1.2.1       
Please enter the netmask for Network Interface e0d [255.0.0.0]: 255.255.255.0       
Please enter media type for e0d {100tx-fd, tp-fd, 100tx, tp, auto (10/100/1000)} [auto]:        
Please enter flow control for e0d {none, receive, send, full} [full]:        
Do you want e0d to support jumbo frames? [n]:        
Would you like to continue setup through the web interface? [n]: n       
yes を実行すると、http://filer_ip_address/api から初期 setup を web で実行する事が可能となります。例）e0 の IP が 10.10.10.10 の場合、 http://10.10.10.10/api

Please enter the name or IP address of the IPv4 default gateway [10.10.10.1]: 
The administration host is given root access to the filer's      

 /etc files for system administration.  To allow /etc root access      
 to all NFS clients enter RETURN below.      
Please enter the name or IP address of the administration host: 
administration host を指定すると、filer の root system （/vol/vol0 by default) は、これにアクセスできます。尚、アクセスには NFS を使用します。

Please enter timezone [Japan]: 
Where is the filer located? : FAS2040@UN       

What language will be used for multi-protocol files (Type ? for list)?:ja

Setting language on volume vol0 

The new language mappings will be available after reboot 
Thu Jan 20 15:12:18 JST [vol.language.changed:info]: Language on volume vol0 changed to ja 
Language set on volume vol0 

Do you want to run DNS resolver? [n]: n 
Do you want to run NIS client? [n]: n 

 The Baseboard Management Controller (BMC) provides remote management capabilities
 including console redirection, logging and power control.
 It also extends autosupport by sending down filer event alerts.

Would you like to configure the BMC [y]: n 
 The Shelf Alternate Control Path Management process provides the ability
 to recover from certain SAS shelf module failures and provides a level of
 availability that is higher than systems not using the Alternate Control
 Path Management process.
BMC を有効にするとリモートで、コンソール制御、logging、Power 制御が可能となります。
BMC が正常に機能しているかどうかを確認するには、storage system promp: で以下を実行します。
storage system promp:  "bmc test autosupport"
* BMC: Baseboard Management Controller

Do you want to configure the Shelf Alternate Control Path Management interface for SAS shelves [n]:  
The initial aggregate currently contains 3 disks;  you may add more
disks to it later using the "aggr add" command.
Now type 'reboot' for changes to take effect. 
FAS2040> reboot
```

## ONTAP 8.1 シミュレーター初期セットアップ 


ONTAP は、NetApp 社のストレージシステムで使用されている OS です。ONTAP 8.1 シミュレーターでは、この OS の運用・管理を体験できます。シミュレーター及びライセンスは、NOW からダウンロード可能です。以下、VMware Workstaion 8.0.1 上にインストールする際の例になります。


### 仮想マシンセットアップ

デフォルトでは、NIC を 4 つ（e0a, e0b, e0c, e0d）認識しています。必要に応じて NIC の追加、 削除を行います。例では、NIC を2つ（e0a:管理用、e0b:ストレージ接続用）とします。
f:id:FriendsNow:20130123145331p:plain
f:id:FriendsNow:20130123145338p:plain

### 初期 Boot

VMware Workstaion からシミュレーター仮想マシンを起動します。起動後、"Press Ctrl +C" for Boot Menu." メッセージが表示されますので、CTRL + C を実行します。Boot Menu 表示後、"4" Clean configuration and initialize all disks.を選択し、config のをクリア及び zeroing（要 Reboot）を行います。
f:id:FriendsNow:20130123145348p:plain
f:id:FriendsNow:20130123145355p:plain
f:id:FriendsNow:20130123145400p:plain

### 初期 Setup

ホスト名、ネットワーク等の設定を行います。初期設定の再設定は、setup コマンドで可能です。
 尚、設定を反映させるためには再起動が必要です。

```
netapp> setup
The setup command will rewrite the /etc/rc, /etc/exports,
/etc/hosts, /etc/hosts.equiv, /etc/dgateways, /etc/nsswitch.conf,
and /etc/resolv.conf files, saving the original contents of
these files in .bak files (e.g. /etc/exports.bak).
Are you sure you want to continue? [yes]
        NetApp Release 8.1.1X34 7-Mode: Thu May 31 21:30:59 PDT 2012
        System ID: 4061490311 (netapp)
        System Serial Number: 4061490-31-1 (netapp)
        System Storage Configuration: Multi-Path
        System ACP Connectivity: NA
        slot 0: System Board
                Processors:         2
                Memory Size:        4096 MB
                Memory Attributes:  None
        slot 0: 10/100/1000 Ethernet Controller V
                e0a MAC Address:    00:0c:29:1a:e7:91 (auto-1000t-fd-up)
                e0b MAC Address:    00:0c:29:1a:e7:9b (auto-1000t-fd-up)
Please enter the new hostname [netapp]:
Do you want to enable IPv6? [n]:
Do you want to configure interface groups? [n]:
Please enter the IP address for Network Interface e0a [192.168.1.51]:
Please enter the netmask for Network Interface e0a [255.255.255.0]:
Please enter media type for e0a {100tx-fd, tp-fd, 100tx, tp, auto (10/100/1000)} [auto]:
Please enter flow control for e0a {none, receive, send, full} [full]:
Do you want e0a to support jumbo frames? [y]:
Please enter the IP address for Network Interface e0b [1.1.1.51]:
Please enter the netmask for Network Interface e0b [255.255.255.0]:
Please enter media type for e0b {100tx-fd, tp-fd, 100tx, tp, auto (10/100/1000)} [auto]:
Please enter flow control for e0b {none, receive, send, full} [full]:
Do you want e0b to support jumbo frames? [y]:
Would you like to continue setup through the web interface? [n]:
Please enter the name or IP address of the IPv4 default gateway [192.168.1.2]:
        The administration host is given root access to the filer's
        /etc files for system administration.  To allow /etc root access
        to all NFS clients enter RETURN below.
Please enter the name or IP address of the administration host:
Please enter timezone [Japan]:
Where is the filer located? []:
Enter the root directory for HTTP files [/vol/vol0/home/http]:
Do you want to run DNS resolver? [n]:
Do you want to run NIS client? [n]:
This system will send event messages and weekly reports to NetApp Technical Support. To disable this feature, enter "options autosupport.support.enable off" within 24 hours. Enabling AutoSupport can significantly speed problem determination and resolution should a problem occur on your system. For further information on AutoSupport, please see: http://now.netapp.com/autosupport/
        Press the return key to continue.


        The Shelf Alternate Control Path Management process provides the ability
        to recover from certain SAS shelf module failures and provides a level of
        availability that is higher than systems not using the Alternate Control
        Path Management process.
Do you want to configure the Shelf Alternate Control Path Management interface for SAS shelves [n]:
        The initial aggregate currently contains 3 disks;  you may add more
        disks to it later using the "aggr add" command.

Now type 'reboot' for changes to take effect.
netapp> reboot
```

### オプション設定

Telnet 及び、HTTP 接続はデフォルトで無効となっているので、必要に応じて有効にします。

```
ontap> options telnet.enable on
ontap> options telnet
telnet.access                legacy
telnet.distinct.enable       on
telnet.enable                on
ontap> options httpd.admin.enable on
ontap> options httpd.admin
httpd.admin.access           legacy
httpd.admin.enable           on
```

*ONTAP 8.01 では、上記を有効化すると HTTP アクセス(http://ipaddress/na_admin)で、FilerView を呼び出す事が可能となりますが、8.1 では、"Error 500 Servlets not enabled" エラーが出力されました。調べてみると、FilerView は、8.1 以降はサポートしておらず、System Manager でのみ対応しているとの情報もあり、引き続き調査予定です。
http://communities.netapp.com/thread/17542
 Filerview is no longer available is 8.1. For a GUI use system manager 2.0r1 and operations manager / NetApp management console in the on command products.System manager replaces Filerview for 8.1. 


### ライセンスの有効化

使用する機能に対応したライセンス（CIFS, iSCSI 等）を有効化する必要があります。
アクティベートは、"license add "ライセンス" コマンドにより、行います。 
ライセンスの詳細については Data ONTAP Simulator Installation Simple Steps and FAQ をご参照ください。
https://communities.netapp.com/blogs/fitforpurpose/2009/09/06/data-ontap-simulator-installation-simple-steps-and-frequently-asked-questions


## NetApp Ontap(ver8.1)の基本操作について 

### Aggregate の操作

- disk 3本（dparity/parity/data）で構成される 64bit の［aggr1］を作成します。

```
> aggr create aggr1 -B 64 3
```

- aggregate1 に disk を2本（data）追加します。

```
> aggr add aggr1 2
Addition of 2 disks to the aggregate has completed.
```

- aggregate の基本情報を確認します。*1

```
> aggr status
           Aggr State           Status            Options
          aggr0 online          raid_dp, aggr     root
                                64-bit
```

- aggregate を構成する device 等を確認します。

```
> sysconfig -r
aggregate aggr1 (online, raid_dp) (block checksums)
  Plex /aggr1/plex0 (online, normal, active, pool0)
    RAID group /aggr1/plex0/rg0 (normal, block checksums)

      RAID Disk Device  HA  SHELF BAY CHAN Pool Type  RPM  Used (MB/blks)
      --------- ------  ------------- ---- ---- ---- ----- --------------
      dparity   v4.19   v4    ?   ?   FC:B   0  FCAL 15000 1020/2089984
      parity    v4.20   v4    ?   ?   FC:B   0  FCAL 15000 1020/2089984
      data      v4.21   v4    ?   ?   FC:B   0  FCAL 15000 1020/2089984

aggregate aggr0 (online, raid_dp) (block checksums)
  Plex /aggr0/plex0 (online, normal, active, pool0)
    RAID group /aggr0/plex0/rg0 (normal, block checksums)

      RAID Disk Device  HA  SHELF BAY CHAN Pool Type  RPM  Used (MB/blks)
      --------- ------  ------------- ---- ---- ---- ----- --------------
      dparity   v4.16   v4    ?   ?   FC:B   0  FCAL 15000 1020/2089984
      parity    v4.17   v4    ?   ?   FC:B   0  FCAL 15000 1020/2089984
      data      v4.18   v4    ?   ?   FC:B   0  FCAL 15000 1020/2089984
<...snip...>
```

- aggregate のサイズを確認します。

```
> df -Ah aggr1
aggregate                total       used      avail capacity
aggr1                   2700MB      207MB     2492MB       8%
aggr1/.snapshot            0TB        0TB        0TB     ---%
```

- FlexVolume の操作

- aggr1 に volume［pocvol］をサイズ100m で作成します。

```
> vol create pocvol aggr1 100m
```

- volume を Thin provisioning(guarantee=none)で作成します。

```
> vol create pocvol1 -s none aggr1 1000m
```

- volume［pocvol］のサイズを 100m から 200m に変更します。

```
> vol size pocvol 200m
vol size: Flexible volume 'pocvol' size set to 200m.
```

- volume［pocvol］の名前を［labvol］へ変更します。

```
> vol rename pocvol labvol
```

- volume［pocvol］を削除します。まず対象の volume を offline へ移行します。

```
> vol offline pocvol
volume 'pocvol' is now offline.
```

- offline 状態へ移行後、destroy コマンドを発行します。

```
> vol destroy pocvol
Are you sure you want to destroy volume 'pocvol'? y
volume 'pocvol' destroyed.
```

- volume の基本情報を確認します。*2

```
> vol status
         volume State           Status            Options
           vol0 online          raid_dp, flex     root
                                64-bit
```

- volume のサイズを確認します。

```
> df -h
Filesystem               total       used      avail capacity  Mounted on
/vol/vol0/               808MB      141MB      667MB      17%  /vol/vol0/
/vol/vol0/.snapshot       42MB       54MB        0MB     127%  /vol/vol0/.snapshot
/vol/pocvol/              95MB      116KB       94MB       0%  /vol/pocvol/
/vol/pocvol/.snapshot   5120KB        0TB     5120KB       0%  /vol/pocvol/.snapshot||<
```



### snapshot の操作

- volume［pocvol］の snapshot を作成します。

```
> snap create pocvol snap1
```

- 取得した snapshot から volume の状態をリストアします。

```
fas2020> snap restore -t vol /vol/pocvol

WARNING! This will revert the volume to a previous snapshot.
All modifications to the volume after the snapshot will be
irrevocably lost.

volume pocvol will be made restricted briefly before coming back online.

Are you sure you want to do this? y

The following snapshot is available for volume pocvol:

date            name
------------    ---------
May 17 10:32    snap1

Revert volume pocvol to snapshot snap1?
Please answer yes or no.

Revert volume pocvol to snapshot snap1? yes

You have selected volume pocvol, snapshot snap1

Proceed with revert? yes
volume pocvol: revert successful.
```

- snapshot を自動取得する間隔を確認します。*3

```
> snap sched pocvol
volume pocvol: 0 2 6@8,12,16,20
```

- スケジュールをリセットするには、以下を実行します。

```
> snap sched pocvol 0 0 0
```

- ファイル単位で削除するには以下を実行します。

```
> snap delete pocvol nightly.1
```

- ボリューム内の全ての snapshot を一括削除するには以下を実行します。

```
> snap delete -a -f pocvol
```

- snapshot のリストを確認します。

```
> snap list pocvol
volume pocvol
working...

  %/used       %/total  date          name
----------  ----------  ------------  --------
  1% ( 1%)    0% ( 0%)  May 17 10:32  snap1
```

- snapshot のスケジュールを確認します。

```
> snap sched pocvol
volume pocvol: 0 2 6@8,12,16,20
```

### lun の操作

- pocvol3 に lun［poclun3］をサイズ2G で作成します。

```
> lun create -s 2g -t vmware /vol/pocvol3/poclun3
```

- lun［poclun］の名前を［lablun］へ変更します。

```
> lun move /vol/pocvol/poclun /vol/pocvol/lablun
```

- lun［poclun3］を削除します。まず対象の lun を offline へ移行します。

```
> lun offline /vol/pocvol3/poclun3
```

- offline 状態へ移行後、destroy コマンドを発行します。

```
> lun destroy /vol/pocvol3/poclun3
```

- lun の基本情報を確認します。

```
> lun show /vol/pocvol3/poclun3
        /vol/pocvol3/poclun3           2g (2147483648)    (r/w, online)
```

### igroup の操作

- esxi5 という名前の igroup を作成し、iqn を登録します。タイプは vmware とします。

```
> igroup create -i -t vmware esxi5 iqn.1998-01.com.vmware:esxi06-70d75e37
```

- 既存 igroup［esxi5］へ iqn を追加する場合は、下記のようになります。

```
> igroup add esxi5 iqn.1998-01.com.vmware:localhost-7f8428ec
```

- igroup［poc］の名前を［lab］へ変更します。

```
> igroup rename poc lab
```

- 既存 igroup［esxi5］から iqn を削除する場合は、下記のようになります。

```
> igroup remove esxi5 iqn.1998-01.com.vmware:localhost-7f8428ec
```

- igroup が lun に関連付けられている場合は、下記のようなエラーが出力されます。
```
igroup remove: iqn.1998-01.com.vmware:localhost-7f8428ec: lun maps for this initiator group exist
```

- 強制的に削除する場合は、"-f" キーワードを使用します。

```
> igroup remove -f esxi5 iqn.1998-01.com.vmware:localhost-7f8428ec
```

- lun［pocvol3］と igroup［esxi5］を mapping します。 

```
> lun map /vol/pocvol3/poclun3 esxi5 0
```

- igroup の基本情報を確認します。

```
> igroup show esxi5
    esxi5 (iSCSI) (ostype: vmware):
        iqn.1998-01.com.vmware:esxi06-70d75e37 (not logged in)
        iqn.1998-01.com.vmware:localhost-7f8428ec (not logged in)
```

- lun との関連情報を確認します。

```
> lun show -m
lun path                            Mapped to          lun ID  Protocol
-----------------------------------------------------------------------
/vol/pocvol3/poclun3                esxi5                   0     iSCSI
```

### disk の操作

- disk 故障が発生した場合、下記のように［Failed］となります。

```
> sysconfig -r
<...snip...>
RAID Disk Device  HA  SHELF BAY CHAN Pool Type  RPM  Used (MB/blks)
--------- ------  ------------- ---- ---- ---- ----- --------------
Spare disks for block or zoned checksum traditional volumes or aggregates
spare     0a.27   0a    1   11  FC:A   0  ATA   7200 847555/1735794176
spare     0a.29   0a    1   13  FC:A   0  ATA   7200 847555/1735794176
spare     0b.23   0b    1   7   FC:A   0  ATA   7200 847555/1735794176

Broken disks

RAID Disk Device  HA  SHELF BAY CHAN Pool Type  RPM  Used (MB/blks)
--------- ------  ------------- ---- ---- ---- ----- --------------
failed    0a.26   0a    1   10  FC:A   0  ATA   7200 847555/1735794176
```

- 故障 disk（0a.26）を交換後、必要に応じて、以下を実行します。*4

```
> priv set diag
Warning: These diagnostic commands are for use by Network Appliance
         personnel only.
> disk unfail -s 0a.26
```

- 交換した disk は［not zeroed］状態のため、Zeroing を実行します。

```
> disk zero spares
```

- 出荷状態では data,parity,dparity の3本で構成されています。 disk の割り当てはシステムの設定により異なります。残りの disk は、全て spare として認識されます。

```
> sysconfig -r
aggregate aggr0 (online, raid_dp) (block checksums)
  Plex /aggr0/plex0 (online, normal, active, pool0)
    RAID group /aggr0/plex0/rg0 (normal, block checksums)

      RAID Disk Device  HA  SHELF BAY CHAN Pool Type  RPM  Used (MB/blks)
      --------- ------  ------------- ---- ---- ---- ----- --------------
      dparity   v4.16   v4    ?   ?   FC:B   0  FCAL 15000 1020/2089984
      parity    v4.17   v4    ?   ?   FC:B   0  FCAL 15000 1020/2089984
      data      v4.18   v4    ?   ?   FC:B   0  FCAL 15000 1020/2089984

RAID Disk       Device  HA  SHELF BAY CHAN Pool Type  RPM  Used (MB/blks)
---------       ------  ------------- ---- ---- ---- ----- --------------
Spare disks for block checksum
spare           v4.19   v4    ?   ?   FC:B   0  FCAL 15000 1020/2089984
spare           v4.20   v4    ?   ?   FC:B   0  FCAL 15000 1020/2089984
spare           v4.21   v4    ?   ?   FC:B   0  FCAL 15000 1020/2089984
spare           v4.22   v4    ?   ?   FC:B   0  FCAL 15000 1020/2089984
spare           v4.24   v4    ?   ?   FC:B   0  FCAL 15000 1020/2089984
spare           v4.25   v4    ?   ?   FC:B   0  FCAL 15000 1020/2089984
spare           v4.26   v4    ?   ?   FC:B   0  FCAL 15000 1020/2089984
spare           v4.27   v4    ?   ?   FC:B   0  FCAL 15000 1020/2089984
spare           v4.28   v4    ?   ?   FC:B   0  FCAL 15000 1020/2089984
spare           v4.29   v4    ?   ?   FC:B   0  FCAL 15000 1020/2089984
spare           v4.32   v4    ?   ?   FC:B   0  FCAL 15000 1020/2089984
```

### その他

- iSCSI サービスは、デフォルトで無効となっているため、有効にします。

```
> iscsi start
iSCSI service started
```

- iSCSI サービスの起動状況を確認します。

```
> iscsi status
iSCSI service is running
```
*1:aggregate は RAID-DP で構成され、64bit で動作している事がわかります。
*2:aggregate1 に volume［vol0］が存在している事がわかります。
*3:デフォルト：[Weekly] [Nightly] [Hourely]@time,time2･･
*4:https://communities.netapp.com/thread/10933


## NetApp の重複排除（De-duplication） 

### 重複排除機能とは

ストレージ内に、同じ内容のデータが複数保存されている場合、これを排除して、ストレージ利用の効率化を図る技術です。NetApp の重複排除機能は、次のような点で優れていると訴えています。
- NetApp 製またはサードパーティ製のプライマリ、セカンダリ、アーカイブストレージ上で動作する。
- アプリケーション、プロトコルに依存しない。
- オーバーヘッドが最小限。
- バイト単位で検証を実行。
- ボリュームおよび LUN 内にある新しいデータと以前に格納されたデータに適用できる。
- ピーク時以外の時間帯に実行可能。（DR だけでなく、プライマリでも実行可能。）
- NetApp の他の Storage Efficiency テクノロジと統合できる。
- 重複排除による削減効果を、SnapMirrorR や Flash Cache の使用時にも継承できる。
- 無償で提供。

### 重複データの特定

Data ONTAPは、ブロックごとに、フィンガープリント*1を計算し、同じフィンガープリントを持つ2つのブロックは、共有の候補とします。NetApp の重複排除機能を有効にすると、ボリューム内で使用されているすべてのブロックのフィンガープリント・データベースが作成*2され、この初期セットアップが完了すると、データの重複排除が可能となります。

重複排除を開始するきっかけは、以下のとおりです。
- 重複排除の「start」コマンドを手動で実行。
- 定期的な重複排除プロセスの開始。
- ボリュームに新しいデータが 20% 書き込まれた場合。
- SnapVaultR転送が完了後。

重複排除プロセスが開始されると、フィンガープリント・データベースが検証され、同一ブロックが存在する場合は、一方のブロックを廃棄し、もう一方のブロックを参照するようにします。

- NetApp 重複排除の要件 %ハードウェア ・%NearStoreR R200, FAS2000シリーズ, FAS3000シリーズ, FAS3100シリーズ, FAS3200シリーズ, FAS6000シリーズ, FAS6200シリーズ等。詳細についてはこちらをご参照ください。
- Data ONTAP のバージョン要件 ・%Data ONTAP 7.2.5.1以上*3
- 必要なライセンス ・%De-dup
・%NearStore ライセンス*4
- サポートされるボリュームの種類 ・%FlexVolRのみ、トラディショナル・ボリュームはサポートされません。
- 最大ボリュームサイズ ・%Data ONTAP 8.0.1の場合、最大16TB です。他バージョン等、詳細についてはこちら。
- サポート対象のプロトコル ・%すべて。

### 設定方法

出力結果は、実際に検証環境で得た数値になります。pocvol1, pocvol2 の各ボリュームのそれぞれに、VM（CentOS-6.0）x2 配置*5し、pocvol1 でのみ重複排除を実行した結果、約59% 削減できました。

- 指定したフレキシブル・ボリュームで重複排除機能を有効にします。

```
ontap> sis on /vol/pocvol1
SIS for "/vol/pocvol1" is enabled.
Already existing data could be processed by running "sis start -s /vol/pocvol1".
```

- 指定したフレキシブル・ボリュームで重複排除プロセスを開始し既存のデータを処理します。*6

```
ontap> sis start -s /vol/pocvol1
The file system will be scanned to process existing data in /vol/pocvol1.
This operation may initialize related existing metafiles.
Are you sure you want to proceed (y/n)? y
The SIS operation for "/vol/pocvol1" is started.
```

- 指定したフレキシブル・ボリュームで重複排除プロセスを開始します。

```
ontap> sis start /vol/pocvol1
The SIS operation for "/vol/pocvol1" is started.
```

- 重複排除について現在のステータスを返します。-lオプションを使用すると、詳細が表示されます。

```
ontap> sis status -l /vol/pocvol1

Path:                            /vol/pocvol1
State:                           Disabled
Compression:                     Disabled
Inline Compression:              Disabled
Status:                          Idle
Progress:                        Idle for 00:04:34
Type:                            Regular
Schedule:                        sun-sat@0
Minimum Blocks Shared:           1
Blocks Skipped Sharing:          0
Last Operation State:            Success
Last Successful Operation Begin: Sun Mar 11 09:27:49 JST 2012
Last Successful Operation End:   Sun Mar 11 09:27:50 JST 2012
Last Operation Begin:            Sun Mar 11 09:27:49 JST 2012
Last Operation End:              Sun Mar 11 09:27:50 JST 2012
Last Operation Size:             0 KB
Last Operation Error:            -
Change Log Usage:                0%
Logical Data:                    2661 MB/15 TB (0%)
Queued Job:                      -
Stale Fingerprints:              8%
```

- 重複排除機能によるスペース節約の値が返されます。

```
ontap> df -s
Filesystem                used      saved       %saved
/vol/vol0/              262456          0           0%
/vol/pocvol2/          2318708          0           0%
/vol/pocvol1/          1109452    1615872          59%
/vol/pocvol3/          2106068          0           0%
```

- 実際のディスクの使用量を確認します。

```
ontap> df -h pocvol1
Filesystem               total       used      avail capacity  Mounted on
/vol/pocvol1/           9728MB     1083MB     8644MB      11%  /vol/pocvol1/
/vol/pocvol1/.snapshot   512MB        0TB      512MB       0%  /vol/pocvol1/.snapshot

ontap> df -h pocvol2
Filesystem               total       used      avail capacity  Mounted on
/vol/pocvol2/           9728MB     2264MB     7463MB      23%  /vol/pocvol2/
/vol/pocvol2/.snapshot   512MB        0TB      512MB       0%  /vol/pocvol2/.snapshot
```

- 自動重複排除スケジュールが作成されます。デフォルトは、各曜日の午前0時です。

```
ontap> sis config
                                              Inline
Path                 Schedule     Compression Compression
-------------------- ------------ ----------- -----------
/vol/pocvol2         sun-sat@0    Disabled    Disabled
/vol/pocvol1         sun-sat@0    Disabled    Disabled
```

- 指定したフレキシブル・ボリュームで、アクティブな重複排除プロセスを中断します。

```
ontap> sis stop /vol/pocvol2
The operation on "/vol/pocvol2" is being stopped.
```

（参考）
http://www.netapp.com/jp/communities/tech-ontap/tot-dedupe-0807-ja.html
http://www.netapp.com/jp/communities/tech-ontap/tot-back-to-basics-deduplication-1104-ja.html
http://media.netapp.com/documents/tr-3505-ja.pdf

*1:ブロックデータのハッシュ
*2:このプロセスは「収集」と呼ばれるようです。
*3:8.0.X の場合は 7-Mode のみ
*4:バージョン8.0より前の Data ONTAP の場合に必要
*5:VM はクローンで作成しています。
*6:このオプションを使用するのは一般に、初期設定時と、重複排除されていないデータを含んだ既存のフレキシブル･ボリュームで重複排除を実行する場合です。

## ONTAP "priv set advanced" について 

"priv set advanced" を使用して、Ontap で extra command を実行する事が可能です。ただし、操作や取り扱いを誤ると、致命的な問題を引き起こす可能性があるため、サポートの指導の元、使用する事を推奨されています。

- advanced mode への移行

```
> priv set advanced
Warning: These advanced commands are potentially dangerous; use them only when directed to do so by Network Appliance personnel.
*> 
* は、advanced mode である事を示します。
```

- advanced mode では、ls コマンドを使用して、volume が抱える lun の情報を参照する事が可能です。

```
*> ls /vol/vol1
.
..
lun1
```

- non-advanced mode への復帰

```
*> priv set
> 
```

参考：http://wiki.xdroop.com/space/netapp/priv+set+advanced


## NetApp AutoSupport mail の設定 

### AutoSupport Mail とは？

NetApp FAS のための自動診断ツールで、システム構成とその状態を定期的にユーザー自身と NetApp へ送信します。また、重大なシステム障害が発生した場合には自動的に警告メッセージが送信されるため、運用管理者が迅速に対応できるだけでなく、潜在的な障害に対して、未然に対応することが可能です。
 出典：NISSHO ELECTRONICS


- 送信先 email アドレスの定義について
  - autosupport.partner.to  全ての情報（info 等も含みます）を送信します。
  - autosupport.to 上記よりも、レベルは低くなるパラメータ*1
  - autosupport.noteto 必要最低限の情報のみ送信するパラメータ*2

### AutoSupport Mail の設定（例）

- AutoSupport Mail の有効化

```
> options autosupport.enable on
```

- mailhost の指定

```
> options autosupport.mailhost 10.10.10.10
```

- 送信先 email アドレスの指定

```
> options autosupport.partner.to manager1@example.com,manager2@example.org
```

- AutoSupport Mail の設定確認

```
> options autosupport
autosupport.cifs.verbose     off
autosupport.content          complete
autosupport.doit             DONT
autosupport.enable           on
autosupport.from             ontap@example.com
autosupport.local.nht_data.enable off
autosupport.local.performance_data.enable off
autosupport.mailhost         10.10.10.10                               
autosupport.minimal.subject.id hostname
autosupport.nht_data.enable  on
autosupport.noteto
autosupport.partner.to       manager1@example.com,manager2@example.org 
autosupport.performance_data.enable on
autosupport.retry.count      15         (value might be overwritten in takeover)
autosupport.retry.interval   4m         (value might be overwritten in takeover)
autosupport.support.enable   on
autosupport.support.proxy
autosupport.support.to       autosupport@netapp.com
autosupport.support.transport smtp
autosupport.support.url      support.netapp.com/asupprod/post/1.0/postAsup
autosupport.throttle         on
autosupport.to
```

- AutoSupport Mail の手動送信

```
options autosupport.doit <email subject>
<example>
options autosupport.doit 20121023_chckautosupport
```

※尚、email subject に"test"という文字列は使用しない方が良いという情報があります。

*1:クリティカルな問題があっても送信されない可能性があります。
*2:ディスクが壊れた場合でも送信されないため、運用上、現実的ではありません。


### NetApp Aggregate の節約に対応した volume の作成 

- flexvolume を作成します。

```
> vol create nfsvol -s none aggr0 2t
> vol options nfsvol
nosnap=off, nosnapdir=off, minra=off, no_atime_update=off, nvfail=off,
ignore_inconsistent=off, snapmirrored=off, create_ucode=on,
convert_ucode=on, maxdirsize=9175, schedsnapname=ordinal,
fs_size_fixed=off, compression=off, guarantee=none, svo_enable=off,
svo_checksum=off, svo_allow_rman=off, svo_reject_errors=off,
no_i2p=off, fractional_reserve=100, extent=off, try_first=volume_grow,
read_realloc=off, snapshot_clone_dependency=off
> vol status nfsvol
         Volume State           Status            Options
         nfsvol online          raid_dp, flex     create_ucode=on,
                                                  convert_ucode=on, guarantee=none,
                Containing aggregate: 'aggr0'
```

- flexvolume の snapshot を全て削除します。

```
> snap delete -a -f nfsvol
> snap list nfsvol
Volume nfsvol
working...

No snapshots exist.

flexvolume schedule snapshot を停止します。
> snap sched nfsvol 0 0 0

> snap sched nfsvol
Volume nfsvol: 0 0 0
```

- flexvolume snapshot 領域割合を 0% に変更します

```
> snap reserve nfsvol 0

> snap reserve nfsvol
Volume nfsvol: current snapshot reserve is 0% or 0 k-bytes.

> df -h nfsvol
Filesystem               total       used      avail capacity  Mounted on
/vol/nfsvol/            2048GB       72MB     2047GB       0%  /vol/nfsvol/
/vol/nfsvol/.snapshot      0GB        0GB        0GB     ---%  /vol/nfsvol/.snapshot
```

- flexvolume の autosize を無効化します。

```
> vol autosize nfsvol
Volume autosize is currently OFF for volume 'nfsvol'.
```

- flexvolume で重複排除を有効化します。

```
> sis on /vol/nfsvol
Volume or maxfiles exceeded max allowed for SIS: /vol/nfsvol
```

※error "Volume or maxfiles exceeded max allowed for SIS: /vol/nfsvol" となりました。
バージョンによっては、1TB までの制限があるようです。

- flexvolume サイズを 2TB から 1TB へ変更します。

```
> vol size nfsvol -1t
vol size: Flexible volume 'nfsvol' size set to 1t.

> vol size nfsvol
vol size: Flexible volume 'nfsvol' has size 1t.

> df -h nfsvol
Filesystem               total       used      avail capacity  Mounted on
/vol/nfsvol/            1024GB       72MB     1023GB       0%  /vol/nfsvol/
/vol/nfsvol/.snapshot      0GB        0GB        0GB     ---%  /vol/nfsvol/.snapshot
```

- あらためて flexvolume で重複排除を有効化します。

```
> sis on /vol/nfsvol
SIS for "/vol/nfsvol" is enabled.
Already existing data could be processed by running "sis start -s /vol/nfsvol".

> sis start -s /vol/nfsvol
The file system will be scanned to process existing data in /vol/nfsvol.
This operation may initialize related existing metafiles.
Are you sure you want to proceed (y/n)? y
The SIS operation for "/vol/nfsvol" is started.

> sis status -l /vol/nfsvol
Path:                    /vol/nfsvol
State:                   Enabled
Status:                  Idle
Progress:                Idle for 00:00:13
Type:                    Regular
Schedule:                sun-sat@0
Minimum Blocks Shared:   1
Blocks Skipped Sharing:  0
Last Operation Begin:    Thu Nov  1 16:15:08 JST 2012
Last Operation End:      Thu Nov  1 16:15:13 JST 2012
Last Operation Size:     0 KB
Last Operation Error:    -
Changelog Usage:         0%
Checkpoint Time:         No Checkpoint
Checkpoint Op Type:      -
Checkpoint stage:        -
Checkpoint Sub-stage:    -
Checkpoint Progress:     -

> df -s nfsvol
Filesystem                used      saved       %saved
/vol/nfsvol/             74604          0           0%
```

- flexvolume の exports の状態を確認します。

```
> rdfile /vol/vol0/etc/exports
/vol/nfsvol     -sec=sys,rw,nosuid 
```

※wrfile を実行するとファイルの内容が全て削除されるため、必ず rdfile を事前に実行します。

- wrfile で exports の設定を変更します。

```
> wrfile /vol/vol0/etc/exports
/vol/nfsvol     -sec=sys,rw,anon=0,nosuid
read: error reading standard input: Interrupted system call
```

- exports の設定を反映します。

```
> exportfs -a
```

(参考）
http://www.netapp.com/jp/communities/tech-ontap/tot-back-to-basics-deduplication-1104-ja.html


## NetApp SnapMirror の設定 

### NetApp SnapMirror とは

遠隔地へ高速にデータを転送し、筐体間レプリケーションを実現するテクノロジです。初回転送時は、全データをコピーし、次回以降は Snapshot によって取得された変更データブロックのみを転送します。
 出典：NetApp Inc,

### SnapMirror 送信元設定

- コピー元ボリューム"vol_test"を aggr1 に 100g で作成します。オプションを適当に設定します。

```
src> vol create vol_test -s none aggr1 100g
src> vol options vol_test nosnap on
src> vol options vol_test create_ucode on
src> vol options vol_test convert_ucode on
src> snap reserve vol_test 0
src> snap sched vol_test 0 0 0
```

### SnapMirror 送信先設定

- コピー先ボリュームを作成します。基本的にコピー元の構成と合わせます。

```
dst> vol create vol_test_mirror -s none aggr1 100g
dst> vol options vol_test_mirror nosnap on
dst> vol options vol_test_mirror create_ucode on
dst> vol options vol_test_mirror convert_ucode on
dst> snap reserve vol_test_mirror 0
dst> snap sched vol_test_mirror 0 0 0
```

- コピー先ボリュームを"restricted mode"に指定します。

```
dst> vol restrict vol_test_mirror
Volume 'vol_test' is now restricted.
```

- vol status コマンドで確認すると"restricted"となっている事が確認できます。 

```
dst> vol status vol_test_mirror
         Volume State           Status            Options
  vol_test restricted      raid_dp, flex     
		Containing aggregate: 'aggr1'
```

- SnapMirror Initialize を実行します。

```
dst> snapmirror initialize -S src:vol_test dst:vol_test_mirror
Transfer started.
Monitor progress with 'snapmirror status' or the snapmirror log.
```

- snapmirror status で状態を確認します。

```
dst> snapmirror status
Snapmirror is on.

Source                   Destination               State          Lag        Status
src:vol_test             dst:vol_test_mirror         Snapmirrored   00:00:28   Idle
```

- 詳細を確認する場合は、snapmirror status -l を実行します。

```
dst> snapmirror status -l
Snapmirror is on.

Source:                 src:vol_test
Destination:            dst:vol_test_mirror
Status:                 Idle
Progress:               -
State:                  Uninitialized
Lag:                    -
Mirror Timestamp:       -
Base Snapshot:          -
Current Transfer Type:  Initialize
Current Transfer Error: cannot connect to source filer
Contents:               -
Last Transfer Type:     -
Last Transfer Size:     -
Last Transfer Duration: -
Last Transfer From:     -
```

### SnapMirror スケジュール設定

SnampMirror のスケジュールは、snapmirror.conf 上に定義します。
※wrfile を実行すると、全ての設定が消えますのでご注意ください。

- 月曜 - 金曜の 9:30, 13:30, 19:30 に SnapMirror を実行する例になります。 

```
> wrfile /etc/snapmirror.conf
src:vol_test dst:vol_test_mirror - 30 9,13,19 * 1,2,3,4,5
```

- 毎月10日と20日の7時に SnapMirror を実行する場合は下記のようになります。

```
> wrfile /etc/snapmirror.conf
src:vol_test dst:vol_test_mirror - 0 7 10,20 *
```

### SnapMirror の手動実行

- 手動で更新する場合は、snapmirror update コマンドを使用します。

```
dst> snapmirror update -S src:vol_test dst:vol_test_mirror
```

### SnapMirror Initialize 時のエラー

- SnapMirror Initialize 実行時、下記エラーが出力される場合があります。

```
dst> snapmirror initialize -S src:vol_test dst:vol_test_mirror
Transfer aborted: cannot connect to source filer.
dst> [dst:replication.dst.err:error]: SnapMirror: destination transfer from src:vol_test to vol_test_mirror : cannot connect to source filer.
```

- Source 側で snapmirror.access を定義する事で収束する可能性があります。

```
src> options snapmirror.access all
src> options snapmirror.access
snapmirror.access            all
```

- 通信を許可する Filer を定義する場合は、下記のように定義します。*1

```
src> options snapmirror.access host=dst
src> options snapmirror.access
snapmirror.access            host=dst
```

### SnapMirror の関係解除

- 送信先 Filer で実行
- snapmirror break を実行します。

```
dst> snapmirror break vol_test_mirror
```

- Base Snapshot*2 の存在を確認します。

```
dst> snap list vol_test_mirror
```

- Base Snapshot を削除します。

```
dst> snap delete vol_test_mirror <Base Snapshot Name>
```

- Snapmirror が削除された事を確認します。

```
dst> snapmirror status
```

- 送信元 Filer で実行
- Base Snapshot の存在を確認します。

```
src> snap list vol_test
```

- snapmirror release を実行します。

```
src> snapmirror release vol_test dst:vol_test_mirror
```

- Base Snapshot が削除された事を確認します。

```
src> snap list vol_test
```

- Snapmirror が削除された事を確認します。

```
src> snapmirror status
```

*1:複数定義する場合は、カンマで区切ります。
*2:snapmirror status -l で Base Snapshot が確認可能です。

## NetApp Data ONTAP アップデート手順 

FAS3210A クラスタモデルでのソフトウェアアップデート例になります。

### Data ONTAP のダウンロード

下記 URL からソフトウェアをダウンロードします。
http://support.netapp.com/NOW/cgi-bin/software/


### Web Server の準備

本例では、mongoose を使用して、端末を Web Server とします。
http://code.google.com/p/mongoose/
 mongoose では、c: がデフォルトの Web Root folder になります。

### Filer への Data ONTAP ダウンロード

- "software get"コマンドを使用して、Data ONTAP をダウンロードします。

```
head1> software get http://192.168.1.100/736P5_setup_q.exe 736P5_setup_q.exe
```

- 正常にダウンロードした事を確認します。

```
head1> software list
736P5_setup_q.exe

head1> priv set advanced
head1*> ls /etc/software
.   
..   
736P5_setup_q.exe   

head1> priv set
```

### Filer の Data ONTAP アップデート

- バージョン情報を確認します。

```
head1> sysconfig
	NetApp Release 7.3.5.1P5: Wed Jun 15 15:37:59 PDT 2011
	System ID: ******* (head1); partner ID: ******* (head2)
<...snip...>
```

- クラスタ状態を確認します。

```
head1> cf status
Cluster enabled, head2 is up.
Negotiated failover enabled (network_interface).
Interconnect status: up.
```

- raid.back オプションを無効にしておきます。

```
head1> options raid.back
raid.background_disk_fw_update.enable on   (value might be overwritten in takeover)

head1> option raid.background_disk_fw_update.enable off
You are changing option raid.background_disk_fw_update.enable which applies to both members of the cluster in takeover mode.
This value must be the same in both cluster members prior to any takeover or giveback, or that next takeover/giveback may not work correctly.

head1> options raid.back
raid.background_disk_fw_update.enable off  (value might be overwritten in takeover)
```

- "software update"コマンドを使用して、Data ONTAP をアップデートします。

```
head1> software update 736P5_setup_q.exe -r
software: You can cancel this operation by hitting Ctrl-C in the next 6 seconds.
software: Depending on system load, it may take many minutes
software: to complete this operation. Until it finishes, you will
software: not be able to use the console.
software: installing software, this could take a few minutes...
software: Data ONTAP(R) Package Manager Verifier 1
software: Validating metadata entries in /etc/boot/NPM_METADATA.txt
software: Checking sha1 checksum of file checksum file: /etc/boot/NPM_FCSUM-x86-64.sha1.asc
software: Checking sha1 file checksums in /etc/boot/NPM_FCSUM-x86-64.sha1.asc
software: installation of 736P5_setup_q.exe completed.
software: Reminder: upgrade both the nodes in the Cluster
software: Reminder: You may need to upgrade Volume SnapMirror source filers
software: associated with this filer. Volume SnapMirror can not mirror if the
software: version of ONTAP on the source filer is newer than that on the
software: destination filer.
download: Downloading boot device
download: If upgrading from a version of Data ONTAP prior to 7.3, please ensure
download: there is at least 3% of available space on each aggregate before
download: upgrading.  Additional information can be found in the release notes.
download: Downloading boot device (Service Area)
.................
Please type "reboot" for the changes to take effect.
```

- バージョンが更新されている事を確認します。

```
head1> version -b
1:/x86_64/kernel/primary.krn: OS 7.3.6P5
1:/backup/x86_64/kernel/primary.krn: OS 7.3.5.1P5
1:/x86_64/diag/diag.krn:  5.5.2
1:/x86_64/firmware/excelsio/firmware.img: Firmware 1.9.0
1:/x86_64/firmware/DrWho/firmware.img: Firmware 2.5.0
1:/x86_64/firmware/SB_XV/firmware.img: Firmware 4.4.0
1:/x86_64/firmware/SB_XVI/firmware.img: Firmware 5.1.1
1:/boot/loader: Loader 1.8
1:/x86_64/freebsd/image1/kernel: OS 8.0.3P1
1:/common/firmware/zdi/zdi_fw.zpk: Flash Cache Firmware 2.2 (Build 0x201012201350)
1:/common/firmware/zdi/zdi_fw.zpk: PAM II Firmware 1.10 (Build 0x201012200653)
1:/common/firmware/zdi/zdi_fw.zpk: X1936A FPGA Configuration PROM 1.0 (Build 0x200706131558)
```

- "cf takeover"コマンドを使用して、takeover します。
※takeover: head2 で head1 を引き継ぎます。実行はクラスタペアで行います。

```
head2> cf takeover
cf: takeover initiated by operator
```

- head2 が head1 を正常に引き継いでいる（takeover している）事を確認します。

```
head2(takeover)> cf status
head2 has taken over head1.
head1 is ready for giveback.
Takeover due to negotiated failover, reason: operator initiated cf takeover
```

- "cf giveback"コマンドを使用して、giveback します。
※giveback: head2 から head1 へ返還します。実行はクラスタペアで行います。

```
head2(takeover)> cf giveback
head2> cf status
Cluster enabled, head1 is up.
Negotiated failover enabled (network_interface).
Interconnect status: up.
```

- Data ONTAP が更新している事を確認して完了です。

```
head1> sysconfig
	NetApp Release 7.3.5.1P5: Wed Jun 15 15:37:59 PDT 2011
	System ID: ******* (head1); partner ID: ******* (head2)
<...snip...>
```

## NetApp トラブルシューティング用のログ取得例 

NetApp のトラブルシューティングに必要な主なログとして、以下の3つがあります。
* SP ログ
* savecore ログ
* ssram ログ

SP ログについては、SP ポート経由で取得し、savecore 及び、ssram については、CIFS 経由で取得する必要があります。CIFS のセットアップ方法ついては、後述します。
なお、クラスタヘッド構成の場合、takeover 中でも head を切替えて、ログを取得する事が可能です。

- head の切替は、partner コマンドを使用します。

```
head2(takeover)> partner
Login to partner shell: head1
Thu Dec 25 12:25:00 JST [head2 (takeover): cf.partner.login:notice]: Login to partner shell: head1

head1/head2>
```

- 再度 partner コマンドを実行する事で、元に戻ります。

```
head1/head2> partner
Logoff from partner shell: head1
head2(takeover)> 
Thu Dec 25 12:25:00 JST [head2 (takeover): cf.partner.logoff:notice]: Logoff from partner shell: head1
```

### SP ログの取得手順

- SSH でアクセスします。ユーザー ID は naroot、パスワードは、root パスワードになります。

```
head1> events all
head1> system log
head1> sp status -d
```

### SP ポートについて

The Service Processor(SP)ポートは、32xx 及び 62xx に実装されるリモート管理デバイスで、遠隔でトラブルシューティングを実行する事が可能です。SP ポートの主な機能は以下のとおりです。
* 遠隔からのシステムの診断、シャットダウン、再起動等をサポートします。
* 管理ホストから SSH を使用して、SP へアクセスし、SP CLI を使用できます。

### savecore ログの取得手順

- core が出力されていれば、core.xxxxxxxxx.2012-12-25.XX_XX_XX.nz というファイルが存在します。

```
head1> savecore -l
```
/etc/crash 配下に出力されます。


- ssram ログの取得手順

/vol/vol0/etc/log/ssram ディレクトリ配下全てが対象です。
前述の通り、savecore 及び、ssram については、CIFS でアクセスし、取得する必要があります。
なお、CIFS プロトコルに関してはライセンスが無くても cifs setup と vol0 へのアクセスが可能です。


### CIFS セットアップ手順

- wafl.nt_admin_priv_map_to_root オプションを on にします。

```
head1> options wafl.nt_admin_priv_map_to_root on
```

- cifs setup コマンドを実行します。 

```
head1> cifs setup
This process will enable CIFS access to the filer from a Windows(R) system.
Use "?" for help at any prompt and Ctrl-C to exit without committing changes.

        Your filer does not have WINS configured and is visible only to
        clients on the same subnet.
Do you want to make the system visible via WINS? [n]:
        A filer can be configured for multiprotocol access, or as an NTFS-only
        filer. Since multiple protocols are currently licensed on this filer,
        we recommend that you configure this filer as a multiprotocol filer

(1) Multiprotocol filer
(2) NTFS-only filer

Selection (1-2)? [1]: ★1を選択
CIFS requires local /etc/passwd and /etc/group files and default files
        will be created.  The default passwd file contains entries for 'root',
        'pcuser', and 'nobody'.
Enter the password for the root user []: ★ root の既存パスワードを入力
Retype the password: ★root の既存パスワードを入力
        The default name for this CIFS server is 'XXXX'.
Would you like to change this name? [n]: ★そのまま enter
        Data ONTAP CIFS services support four styles of user authentication.
        Choose the one from the list below that best suits your situation.

(1) Active Directory domain authentication (Active Directory domains only)
(2) Windows NT 4 domain authentication (Windows NT or Active Directory domains)
(3) Windows Workgroup authentication using the filer's local user accounts
(4) /etc/passwd and/or NIS/LDAP authentication

Selection (1-4)? [1]: 3 ★3を選択
What is the name of the Workgroup? [WORKGROUP]: ★そのまま enter
        CIFS - Starting SMB protocol...
        It is recommended that you create the local administrator account
        (V3140Aadministrator) for this filer.
Do you want to create the XXXXAadministrator account? [y]: ★そのまま enter

Enter the new password for XXXXXadministrator: ★administrator のパスワードを入力
Retype the password: ★administrator のパスワードを入力

Welcome to the WORKGROUP Windows(R) workgroup

CIFS local server is running.
```

- CIFS セッションを確認します。 

```
head1> cifs sessions
CIFS partially enabled
Server Registers as 'XXXX' in workgroup 'WORKGROUP'
Root volume language is not set. Use vol lang.
Using Local Users authentication
====================================================
PC IP(PC Name) (user)           #shares   #files
```

- 作成した local administrator ユーザーを確認します。

```
head1> useradmin user list administrator
Name: administrator
Info: Built-in account for administering the filer
Rid: 500
Groups: Administrators
Full Name:
Allowed Capabilities: login-*,cli-*,api-*,security-* Password min/max age in days: 0/4294967295
Status: enabled
```

### Linux Client による CIFS アクセス

- 作成した NetApp local administrator で vol0(共有名 C$) に CIFS 接続します。

```
# mount -t cifs -o user=administrator //192.168.1.100/C$ /mnt
Password:
```

- core ファイルを確認し、必要に応じて取得します。

```
# cd /mnt/etc/crash
```

- ssram ディレクトリを確認し、必要に応じて全てのファイルを取得します。

```
# cd /mnt/etc/log/ssram
```

### CIFS の無効化手順

- Linux Client 側で下記ファイルを削除します。必ず mount した NetApp /vol/vol0/etc 配下で実施します。

```
# pwd
/mnt/etc
```

- "passwd" "group" "cifs*" "usermap.cfg" ファイルを削除します。

```
# rm passwd group cifs* usermap.cfg
```

- アンマウントします。

```
# cd /
# umount -l /mnt
```

- Netapp 側で CIFS を無効化します。CIFS をシャットダウンします。

```
head1> cifs terminate
CIFS local server is shutting down...

CIFS local server has shut down...
```

- wafl.nt_admin_priv_map_to_root オプションを off にします。

```
head1> options wafl.nt_admin_priv_map_to_root off
```

- CIFS を再起動できない事を確認します。

```
head1> cifs restart
CIFS not configured.  Use "cifs setup" to configure
```

## Windows PowerShell で NetApp を制御 

NetApp を Windows PowerShell により制御する事が可能です。
 詳細は NetApp PowerShell Survival Guide をご参照ください。

検証環境
* Windows Server 2008R2 Datacenter 
* Ontap Data ONTAP 8.1.0 Simulator
* VMware Workstation 9.0.1 build-894247 

### PowerShell Library のダウンロード

Now にアクセスし［DataONTAP.ZIP］をダウンロードします。ファイルを展開後、以下に配置します。
C:WindowsSystem32WindowsPowerShellv1.0ModulesDataONTAP

実行ポリシーの変更

PowerShell スクリプトの実行ポリシーを変更します。
> Set-ExecutionPolicy RemoteSigned

実行ポリシーの変更
実行ポリシーは、信頼されていないスクリプトからの保護に役立ちます。実行ポリ
のヘルプ トピックで説明されているセキュリティ上の危険にさらされる可能性があ
[Y] はい(Y)  [N] いいえ(N)  [S] 中断(S)  [?] ヘルプ (既定値は "Y"): y


Data ONTAP モジュールのインストール

モジュールファイルをインストールします。
> Import-Module DataOnTap

Data ONTAP モジュールが正常にロードされた事を確認します。
> get-module

ModuleType Name                      ExportedCommands
---------- ----                      ----------------
Manifest   DataOnTap                 {Invoke-NaSnapmirrorThrottle, Resume-NcJob, Get-NaSystemInfo, Add-NaLice...


NetApp の制御

NetApp コントローラーに接続します。
> Connect-NaController 192.168.1.51 -cred root

Name                 Address           Ontapi   Version
----                 -------           ------   -------
192.168.1.51         192.168.1.51      1.17     NetApp Release 8.1.1X34 7-Mode: Thu May 31 21:30:59 PDT 2012

アグリゲートの状態を確認します。
> Get-NaAggr

Name            State       TotalSize  Used  Available Disks RaidType RaidSize MirrorStatus     FilesUsed FilesTotal
----            -----       ---------  ----  --------- ----- -------- -------- ------------     --------- ----------
aggr0           online       900.0 MB   99%     6.2 MB   3   raid_dp     16    unmirrored              96        30k
aggr1           online         2.6 GB    0%     2.6 GB   5   raid_dp     16    unmirrored              96        31k

ボリュームの状態を確認します。
> Get-NaVol

Name                      State       TotalSize  Used  Available Dedupe  FilesUsed FilesTotal Aggregate
----                      -----       ---------  ----  --------- ------  --------- ---------- ---------
vol0                      online       808.9 MB   17%   669.9 MB  True          5k        26k aggr0
vol1                      online       100.0 MB    0%    99.8 MB  True          96         3k aggr1
vol2                      online       100.0 MB    0%    99.8 MB  True          96         3k aggr1

各ボリュームの重複排除効果を確認します。
> get-navolsis | Format-table -autosize

CompressSaved DedupSaved LastOperationBegin           LastOperationEnd             LastOperationError LastOperationSize PercentageSaved PercentCompressSaved PercentDedupSaved PercentTotalSaved
------------- ---------- ------------------           ----------------             ------------------ ----------------- --------------- -------------------- ----------------- -----------------
            0    6926336 Thu Jan 24 14:17:29 JST 2013 Thu Jan 24 14:21:58 JST 2013                            147582976               4                    0                 4                 4
            0          0 Thu Jan 24 15:23:56 JST 2013 Thu Jan 24 15:24:43 JST 2013                                    0               0                    0                 0                 0
            0          0 Thu Jan 24 15:24:00 JST 2013 Thu Jan 24 15:24:56 JST 2013                                    0               0                    0                 0                 0


スクリプトによる自動化

各ボリュームの重複排除効果を出力するスクリプト例になります。








1 $netapp = "192.168.1.51" 
2 $user = "root" 
3 $pass = "password" 
4 

5 #------------------------------------------------------------------------- 
6 # function Sis-Status 
7 #------------------------------------------------------------------------- 
8 function Sis-Status() 
9 { 
10    $outfile = "C:logssis_status.log" 
11    $logdata = "Get-NaSis" 
12    $logdata | out-file $outfile -append 
13    Get-Date -Format g >> $outfile 
14    Get-NaVol | select @{Name="Volume"    ; Exp={$_.name}},  
15                       @{Name="Total(MB)" ; Exp={[math]::Truncate(($_ | Get-NaVol).TotalSize/1MB)}}, 
16                       @{Name="Used(%)"   ; Exp={($_ | Get-NaVol).Used}}, 
17                       @{Name="Avail(MB)" ; Exp={[math]::Truncate(($_ | Get-NaVol).Available/1MB)}}, 
18                       @{Name="Saved(MB)" ; Exp={[math]::Round(($_ | Get-NaVolSis).SizeSaved/1MB,2)}}, 
19                       @{Name="Saved(%)"  ; Exp={($_ | Get-NaVolSis).PercentTotalSaved}} | Format-Table -autosize >> $outfile 
20    write-output ""`n >> $outfile 
21 } 
22 

23 #------------------------------------------------------------------------- 
24 # Do-Initialize 
25 #------------------------------------------------------------------------- 
26 $password = ConvertTo-SecureString $pass -asplaintext -force 
27 $cred = New-Object System.Management.Automation.PsCredential $user,$password 
28 

29 Import-Module DataOnTap 
30 Connect-NaController $netapp -cred $cred  
31 

32 #------------------------------------------------------------------------- 
33 # Main Application Logic 
34 #------------------------------------------------------------------------- 
35 Sis-Status 

view raw gistfile1.ps1 hosted with d' by GitHub 


タスクスケジューラに登録する事で、定期的に自動で実行可能です。
プログラム/スクリプトと引数を下記のとおり指定します。
C:WindowsSystem32WindowsPowerShellv1.0powershell.exe


-file "C:scriptsget_sis_status.ps1"

タスクスケジューラの具体的な登録手順については、こちらをご参照頂ければ幸いです。


###############################################################################

NetApp ディスクの手動 fail について 

NetApp 


NetApp では disk を明示的に fail する事が可能です。システム上は問題ないと判断されている disk において、何らかの不具合が懸念される場合等に有効です。本例では、仮想ディスク［v5.18］を fail してみます。 


ディスクの手動 fail

仮想ディスク［v5.18］が aggr0 で使用している事を確認します。 
node1> sysconfig -r
Aggregate aggr0 (online, raid_dp) (block checksums)
  Plex /aggr0/plex0 (online, normal, active)
    RAID group /aggr0/plex0/rg0 (normal, block checksums)

      RAID Disk Device  HA  SHELF BAY CHAN Pool Type  RPM  Used (MB/blks)    Phys (MB/blks)
      --------- ------  ------------- ---- ---- ---- ----- --------------    --------------
      dparity   v5.16   v5    ?   ?   FC:B   -  FCAL 15000 1020/2089984      1027/2104448
      parity    v5.17   v5    ?   ?   FC:B   -  FCAL 15000 1020/2089984      1027/2104448
      data      v5.18   v5    ?   ?   FC:B   -  FCAL 15000 1020/2089984      1027/2104448

Spare disks

RAID Disk       Device  HA  SHELF BAY CHAN Pool Type  RPM  Used (MB/blks)    Phys (MB/blks)
---------       ------  ------------- ---- ---- ---- ----- --------------    --------------
Spare disks for block checksum
spare           v5.19   v5    ?   ?   FC:B   -  FCAL 15000 1020/2089984      1027/2104448
spare           v5.20   v5    ?   ?   FC:B   -  FCAL 15000 1020/2089984      1027/2104448
spare           v5.21   v5    ?   ?   FC:B   -  FCAL 15000 1020/2089984      1027/2104448
spare           v5.22   v5    ?   ?   FC:B   -  FCAL 15000 1020/2089984      1027/2104448
spare           v5.24   v5    ?   ?   FC:B   -  FCAL 15000 1020/2089984      1027/2104448
spare           v5.25   v5    ?   ?   FC:B   -  FCAL 15000 1020/2089984      1027/2104448
spare           v5.26   v5    ?   ?   FC:B   -  FCAL 15000 1020/2089984      1027/2104448
spare           v5.27   v5    ?   ?   FC:B   -  FCAL 15000 1020/2089984      1027/2104448
spare           v5.28   v5    ?   ?   FC:B   -  FCAL 15000 1020/2089984      1027/2104448
spare           v5.29   v5    ?   ?   FC:B   -  FCAL 15000 1020/2089984      1027/2104448
spare           v5.32   v5    ?   ?   FC:B   -  FCAL 15000 1020/2089984      1027/2104448

"disk fail" コマンドにより［v5.18］を手動 fail します。
node1> disk fail v5.18
*** You are about to prefail the following file system disk, ***
*** which will eventually result in it being failed ***
  Disk /aggr0/plex0/rg0/v5.18

      RAID Disk Device  HA  SHELF BAY CHAN Pool Type  RPM  Used (MB/blks)    Phys (MB/blks)
      --------- ------  ------------- ---- ---- ---- ----- --------------    --------------
      data      v5.18   v5    ?   ?   FC:B   -  FCAL 15000 1020/2089984      1027/2104448
***
Really prefail disk v5.18? y
disk fail: The following disk was prefailed: v5.18
Disk v5.18 has been prefailed.  Its contents will be copied to a
replacement disk, and the prefailed disk will be failed out.

コマンドを実行すると［v5.18］のデータが、spare disk［v5.19］にコピーされます。
node1> sysconfig -r
Aggregate aggr0 (online, raid_dp) (block checksums)
  Plex /aggr0/plex0 (online, normal, active)
    RAID group /aggr0/plex0/rg0 (normal, block checksums)

      RAID Disk Device  HA  SHELF BAY CHAN Pool Type  RPM  Used (MB/blks)    Phys (MB/blks)
      --------- ------  ------------- ---- ---- ---- ----- --------------    --------------
      dparity   v5.16   v5    ?   ?   FC:B   -  FCAL 15000 1020/2089984      1027/2104448
      parity    v5.17   v5    ?   ?   FC:B   -  FCAL 15000 1020/2089984      1027/2104448
      data      v5.18   v5    ?   ?   FC:B   -  FCAL 15000 1020/2089984      1027/2104448 (prefail, copy in progress)
      -> copy   v5.19   v5    ?   ?   FC:B   -  FCAL 15000 1020/2089984      1027/2104448 (copy 1% completed)

Spare disks

RAID Disk       Device  HA  SHELF BAY CHAN Pool Type  RPM  Used (MB/blks)    Phys (MB/blks)
---------       ------  ------------- ---- ---- ---- ----- --------------    --------------
Spare disks for block checksum
spare           v5.20   v5    ?   ?   FC:B   -  FCAL 15000 1020/2089984      1027/2104448
spare           v5.21   v5    ?   ?   FC:B   -  FCAL 15000 1020/2089984      1027/2104448
spare           v5.22   v5    ?   ?   FC:B   -  FCAL 15000 1020/2089984      1027/2104448
spare           v5.24   v5    ?   ?   FC:B   -  FCAL 15000 1020/2089984      1027/2104448
spare           v5.25   v5    ?   ?   FC:B   -  FCAL 15000 1020/2089984      1027/2104448
spare           v5.26   v5    ?   ?   FC:B   -  FCAL 15000 1020/2089984      1027/2104448
spare           v5.27   v5    ?   ?   FC:B   -  FCAL 15000 1020/2089984      1027/2104448
spare           v5.28   v5    ?   ?   FC:B   -  FCAL 15000 1020/2089984      1027/2104448
spare           v5.29   v5    ?   ?   FC:B   -  FCAL 15000 1020/2089984      1027/2104448
spare           v5.32   v5    ?   ?   FC:B   -  FCAL 15000 1020/2089984      1027/2104448

コピーが完了すると［v5.19］が aggr0 に参加［v5.18］は Broken disk として認識されます。
node1> sysconfig -r
Aggregate aggr0 (online, raid_dp) (block checksums)
  Plex /aggr0/plex0 (online, normal, active)
    RAID group /aggr0/plex0/rg0 (normal, block checksums)

      RAID Disk Device  HA  SHELF BAY CHAN Pool Type  RPM  Used (MB/blks)    Phys (MB/blks)
      --------- ------  ------------- ---- ---- ---- ----- --------------    --------------
      dparity   v5.16   v5    ?   ?   FC:B   -  FCAL 15000 1020/2089984      1027/2104448
      parity    v5.17   v5    ?   ?   FC:B   -  FCAL 15000 1020/2089984      1027/2104448
      data      v5.19   v5    ?   ?   FC:B   -  FCAL 15000 1020/2089984      1027/2104448

Spare disks

RAID Disk       Device  HA  SHELF BAY CHAN Pool Type  RPM  Used (MB/blks)    Phys (MB/blks)
---------       ------  ------------- ---- ---- ---- ----- --------------    --------------
Spare disks for block checksum
spare           v5.20   v5    ?   ?   FC:B   -  FCAL 15000 1020/2089984      1027/2104448
spare           v5.21   v5    ?   ?   FC:B   -  FCAL 15000 1020/2089984      1027/2104448
spare           v5.22   v5    ?   ?   FC:B   -  FCAL 15000 1020/2089984      1027/2104448
spare           v5.24   v5    ?   ?   FC:B   -  FCAL 15000 1020/2089984      1027/2104448
spare           v5.25   v5    ?   ?   FC:B   -  FCAL 15000 1020/2089984      1027/2104448
spare           v5.26   v5    ?   ?   FC:B   -  FCAL 15000 1020/2089984      1027/2104448
spare           v5.27   v5    ?   ?   FC:B   -  FCAL 15000 1020/2089984      1027/2104448
spare           v5.28   v5    ?   ?   FC:B   -  FCAL 15000 1020/2089984      1027/2104448
spare           v5.29   v5    ?   ?   FC:B   -  FCAL 15000 1020/2089984      1027/2104448
spare           v5.32   v5    ?   ?   FC:B   -  FCAL 15000 1020/2089984      1027/2104448

Broken disks

RAID Disk       Device  HA  SHELF BAY CHAN Pool Type  RPM  Used (MB/blks)    Phys (MB/blks)
---------       ------  ------------- ---- ---- ---- ----- --------------    --------------
admin failed    v5.18   v5    ?   ?   FC:B   -  FCAL 15000 1020/2089984      1027/2104448


ディスクの unfaill

advance mode へ移行します。
node1> priv set advanced
Warning: These advanced commands are potentially dangerous; use them only when directed to do so by NetApp personnel.

unfail は "disk unfail" コマンドにより行います。
node2*> disk unfail v5.18
disk unfail: unfailing disk v5.18...

non-advanced mode へ復帰します。
node2*> priv set

［v5.18］が spare ディスクとして認識されます。
node1> sysconfig -r
Aggregate aggr0 (online, raid_dp) (block checksums)
  Plex /aggr0/plex0 (online, normal, active)
    RAID group /aggr0/plex0/rg0 (normal, block checksums)

      RAID Disk Device  HA  SHELF BAY CHAN Pool Type  RPM  Used (MB/blks)    Phys (MB/blks)
      --------- ------  ------------- ---- ---- ---- ----- --------------    --------------
      dparity   v5.16   v5    ?   ?   FC:B   -  FCAL 15000 1020/2089984      1027/2104448
      parity    v5.17   v5    ?   ?   FC:B   -  FCAL 15000 1020/2089984      1027/2104448
      data      v5.19   v5    ?   ?   FC:B   -  FCAL 15000 1020/2089984      1027/2104448

Spare disks

RAID Disk       Device  HA  SHELF BAY CHAN Pool Type  RPM  Used (MB/blks)    Phys (MB/blks)
---------       ------  ------------- ---- ---- ---- ----- --------------    --------------
Spare disks for block checksum
spare           v5.18   v5    ?   ?   FC:B   -  FCAL 15000 1020/2089984      1027/2104448 (not zeroed)
spare           v5.20   v5    ?   ?   FC:B   -  FCAL 15000 1020/2089984      1027/2104448
spare           v5.21   v5    ?   ?   FC:B   -  FCAL 15000 1020/2089984      1027/2104448
spare           v5.22   v5    ?   ?   FC:B   -  FCAL 15000 1020/2089984      1027/2104448
spare           v5.24   v5    ?   ?   FC:B   -  FCAL 15000 1020/2089984      1027/2104448
spare           v5.25   v5    ?   ?   FC:B   -  FCAL 15000 1020/2089984      1027/2104448
spare           v5.26   v5    ?   ?   FC:B   -  FCAL 15000 1020/2089984      1027/2104448
spare           v5.27   v5    ?   ?   FC:B   -  FCAL 15000 1020/2089984      1027/2104448
spare           v5.28   v5    ?   ?   FC:B   -  FCAL 15000 1020/2089984      1027/2104448
spare           v5.29   v5    ?   ?   FC:B   -  FCAL 15000 1020/2089984      1027/2104448
spare           v5.32   v5    ?   ?   FC:B   -  FCAL 15000 1020/2089984      1027/2104448

必要に応じてディスクの zeroing を実行します。
node1> disk zero spares


node1> sysconfig -r
Aggregate aggr0 (online, raid_dp) (block checksums)
  Plex /aggr0/plex0 (online, normal, active)
    RAID group /aggr0/plex0/rg0 (normal, block checksums)

      RAID Disk Device  HA  SHELF BAY CHAN Pool Type  RPM  Used (MB/blks)    Phys (MB/blks)
      --------- ------  ------------- ---- ---- ---- ----- --------------    --------------
      dparity   v5.16   v5    ?   ?   FC:B   -  FCAL 15000 1020/2089984      1027/2104448
      parity    v5.17   v5    ?   ?   FC:B   -  FCAL 15000 1020/2089984      1027/2104448
      data      v5.19   v5    ?   ?   FC:B   -  FCAL 15000 1020/2089984      1027/2104448

Spare disks

RAID Disk       Device  HA  SHELF BAY CHAN Pool Type  RPM  Used (MB/blks)    Phys (MB/blks)
---------       ------  ------------- ---- ---- ---- ----- --------------    --------------
Spare disks for block checksum
spare           v5.18   v5    ?   ?   FC:B   -  FCAL 15000 1020/2089984      1027/2104448 (zeroing, 3% done)
spare           v5.20   v5    ?   ?   FC:B   -  FCAL 15000 1020/2089984      1027/2104448
spare           v5.21   v5    ?   ?   FC:B   -  FCAL 15000 1020/2089984      1027/2104448
spare           v5.22   v5    ?   ?   FC:B   -  FCAL 15000 1020/2089984      1027/2104448
spare           v5.24   v5    ?   ?   FC:B   -  FCAL 15000 1020/2089984      1027/2104448
spare           v5.25   v5    ?   ?   FC:B   -  FCAL 15000 1020/2089984      1027/2104448
spare           v5.26   v5    ?   ?   FC:B   -  FCAL 15000 1020/2089984      1027/2104448
spare           v5.27   v5    ?   ?   FC:B   -  FCAL 15000 1020/2089984      1027/2104448
spare           v5.28   v5    ?   ?   FC:B   -  FCAL 15000 1020/2089984      1027/2104448
spare           v5.29   v5    ?   ?   FC:B   -  FCAL 15000 1020/2089984      1027/2104448
spare           v5.32   v5    ?   ?   FC:B   -  FCAL 15000 1020/2089984      1027/2104448


###############################################################################

Ontap シミュレーターで SnapDrive for Windows を試す 

NetApp 



SnapDrive とは

仮想ディスクの追加、削除、マッピング等を、Netapp からではなく、Windows サーバーから対話形式のウィザードで行う事が可能です。そのため、NetApp の操作方法を知らなくても、ストレージ管理を容易に実施する事が可能となります。


SnapDrive インストール

Windows Server 2008R2 へ、SnapDrive6.4.2_x64 をインストールする際のポイントになります。


Windows Server 2008R2

インストーラー［SnapDrive6.4.2_x64.exe］を使用してインストールします。
license type は［Per Storage System］を指定します。

f:id:FriendsNow:20130414071015p:plain

サーバーのローカルアカウントを［Domain NameUser Name］の形式で指定します。
f:id:FriendsNow:20130414071025p:plain

Transport Protocol を HTTP に指定します。NetApp の root パスワードを指定します。
f:id:FriendsNow:20130414071031p:plain



Ontap シミュレーター

Ontap シミュレーターで License を登録し、HTTP アクセスを有効にします。

snapmanagerexchange のライセンスを有効にします。
> license add XXXXXXX

同時に snapdrive_windows が有効になります。
> license
<...snip...>
   snapdrive_windows ENABLED
   snapmanagerexchange site XXXXXXX
<...snip...>

HTTP アクセスを有効にします。
ontap> options httpd.admin.enable on
ontap> options httpd.admin


SnapDrive による仮想ディスクの作成

SnapDrive を使用して、仮想ディスクを作成してみます。


SnapDrive

左ペインから Disks を選択後、右の操作ペインから［Create Disk］をクリックします。
f:id:FriendsNow:20130414071141p:plain

［Next］をクリックします。
f:id:FriendsNow:20130414071152p:plain

Storage System（Ontap シミュレーター）を指定し［Add］をクリックします。
f:id:FriendsNow:20130414071158p:plain

Lun Name を設定し［Next］をクリックします。※既存の Lun Name は設定できません。
f:id:FriendsNow:20130414071207p:plain

Lun Type を選択し［Next］をクリックします。
f:id:FriendsNow:20130414071214p:plain

各種パラメータを指定し［Next］をクリックします。
f:id:FriendsNow:20130414071228p:plain

iSCSI イニシエーターを選択し［Next］をクリックします。
f:id:FriendsNow:20130414071237p:plain

iGroup の登録方法を選択し［Next］をクリックします。
f:id:FriendsNow:20130414071245p:plain

内容を確認後［Finish］をクリックします。
f:id:FriendsNow:20130414071253p:plain

LUN が NetApp 上に作成されます。
f:id:FriendsNow:20130414071536p:plain

Windows Server 上にローカルディスク(E:)が追加されます。
f:id:FriendsNow:20130414071543p:plain



Ontap シミュレーター

lun3 が作成されている事を確認します。
> lun show /vol/vol2/lun3
        /vol/vol2/lun3              70.6m (74027520)      (r/w, online, mapped)

igroup が作成されている事を確認します。
> igroup show
    viaRPC.iqn.1991-05.com.microsoft:vcenter4 (iSCSI) (ostype: windows):
        iqn.1991-05.com.microsoft:vcenter4 (logged in on: e0a)

igroup が lun3 に紐づいている事を確認します。
> lun show -m
LUN path                            Mapped to          LUN ID  Protocol
-----------------------------------------------------------------------
/vol/vol2/lun3                      viaRPC.iqn.1991-05.com.microsoft:vcenter4        0     iSCSI

Space reservation を無効化します。
> lun set reservation /vol/vol2/lun3 disable

Space reservation の状態を確認します。
> lun set reservation /vol/vol2/lun3
Space Reservation for LUN /vol/vol2/lun3 (inode 11424): disabled


SnapDrive のトラブルシューティング

以下、SnapDrive 使用時のトラブル事例と対処方法になります。


LUN を作成できない場合の対処方法

LUN を作成する際、下記エラーが出力される場合があります。
Transport Protocol is not set to connect the storage system "strorage system".

f:id:FriendsNow:20130414071612p:plain

Transport Protocol Settings の Default を定義すると解決する可能性があります。
f:id:FriendsNow:20130414071601p:plain



LUN に接続できない場合の対処方法

SnapDrive で一度 Disconnect した Lun を Re-Connect する際、下記エラーが出力される場合があります。
The LUN has SCSI reservation but has not been mapped. 
You can clear the SCSI reservation by using command 'lun persistent_resv clear' at storage system. 

対処方法として、メッセージにあるように Persistent をクリアします。
> priv set advanced
*> lun persistent_resv clear /vol/vol2/lun3
*> lun persistent_resv show /vol/vol2/lun3
 No reservations found for this lun

解決しない場合は、対象の lun を抱えている vol の offline/online で解決する可能性があります。
※注意が必要です。実施前にベンダ等への確認をお勧めします。
> vol offline vol2
Volume 'vol2' is now offline.


> vol online vol2
Volume 'vol2' is now online.

（参考）
https://communities.netapp.com/message/96768


###############################################################################

NetApp SNMP Traphost 設定方法 

NetApp 


例えば、重複排除処理が失敗した場合、AutoSupport では失敗を通知する事はできませんが、SNMP の TRAP で通知する事は可能です。以下、SNMP の設定手順になります。

SNMP を有効にします。
> options snmp.enable on

SNMP コミュニティを設定します。
> snmp community add ro "コミュニティ名"

SNMP Traphost を設定します。Traphost を削除する場合は、"add" を"delete"に指定します。
> snmp traphost add "SNMP Traphost"

Authentication Trap コマンドの使用を有効にします。
> snmp authtrap 1

SNMP Daemon を有効にします。※実行したタイミングで Cold Start が Trap されます。
> snmp init 1

設定内容を確認します。
> snmp
contact:

location:

authtrap:
        1
init:
        1
traphosts:
        192.168.1.100 (192.168.1.100) <192.168.1.100>
community:
        ro public

Autosupport を送信したタイミングで Trap するため Trap を試験する時に便利です。
> options autosupport.doit TRAP-TEST


###############################################################################

ONTAP 8.2 シミュレーター（Cluster-Mode）初期セットアップ 

NetApp 


ONTAP 8.2 シミュレーターがリリースされていたので試してみました。
 今回は、汎用性の高い仕様に変更され、注目が高まっている Cluster-Mode を使用します。
7-Mode の初期セットアップ方法については、こちらをご参照頂けますと幸いです。


7-Mode と Cluster-Mode の違い
" 7-Mode %スケールアップ型のアーキテクチャ
%コントローラーとディスクを搭載したシェルフが分離した構造が前提。
%パフォーマンスを強化する場合は、より高速なコントローラーに「スケールアップ」する。*1

" Cluster-Mode %スケールアウト型のアーキテクチャ
%コントローラーを「スケールアウト」し、パフォーマンスを強化する事が可能。
%新旧のモデル（旧モデルは、2世代前までを推奨）をクラスターに同居させることが可能。



First Node のセットアップ(例)

初期 boot の手順は、7-Mode と同様になります。

クラスタを作成します。
Welcome to the cluster setup wizard.
You can enter the following commands at any time:
"help" or "?" - if you want to have a question clarified,
"back" - if you want to change previously answered questions, and
"exit" or "quit" - if you want to quit the cluster setup wizard.
Any changes you made before quitting will be saved.
You can return to cluster setup at any time by typing "cluster setup".
To accept a default or omit a question, do not enter a value.
Do you want to create a new cluster or join an existing cluster?
{create}: create

デフォルトの値を使用するため、Enter を実行します。
System Defaults:
Private cluster network ports [e0a].
Cluster port MTU values will be set to 1500.
Cluster interface IP addresses will be automatically generated.
Do you want to use these defaults? {yes, no} [yes]: <Enter>

クラスタ名［cluster1］を設定します。
It can take several minutes to create cluster interfaces...
Step 1 of 5: Create a Cluster
You can type "back", "exit", or "help" at any question.
Enter the cluster name: cluster1

license key を入力し実行します。*2
Enter the cluster base license key: 

クラスタ管理ポート及び、アドレスを設定します。
Enter the cluster management interface port [e0c]: e0c
Enter the cluster management interface IP address: 192.168.1.50
Enter the cluster management interface netmask: 255.255.255.0
Enter the cluster management interface default gateway: 192.168.1.2
A cluster management interface on port e0c with IP address 192.168.1.50 has been created.
You can use this address to connect to and manager the cluster.
Enter the DNS domain names: <Enter>

SFO（Storage Failover）情報であるロケーション［lab］を設定します。
Where is the controller located []: lab

ノード管理ポート及び、アドレスを設定します。
Enter the node management interface port [e0c]: <Enter>
Enter the node management interface IP address: 192.168.1.53
Enter the node management interface netmask: 255.255.255.0
Enter the node management interface default gateway: <Enter>
A node management interface on port e0c with IP address 192.168.1.53
has been created.

以上でセットアップは完了です。
You can access your cluster to complete these tasks by:
1) Using the NetApp System Manager to manage cluster cluster1 at 192.168.1.50.
NetApp System Manager must be at version 2.0 or above.
You can download System Manager from http://support.netapp.com
2) Logging in to the cluster by using SSH (secure shell) from your work station:
ssh admin@192.168.1.50

"cluster show"コマンドで、クラスタ情報を確認します。
cluster1::> cluster show
Node                  Health  Eligibility
--------------------- ------- ------------
cluster1-01           true    true

下記コマンドで、使用可能なディスクをノードに追加します。
cluster1::> storage disk assign -all true -node cluster1-01


Second Node セットアップ(例)

Serial Number 及び、System ID を変更します。*3

［シリアルポート］の［Named Pipe］を \.pipevsim-cm-N2-cons へ変更します。
f:id:FriendsNow:20130707235031p:plain

［シリアルポート2］の［Named Pipe］を \.pipevsim-cm-N2-gdb へ変更します。
f:id:FriendsNow:20130707235039p:plain

ONTAP を起動後即時に Space key を押下し、VLOADER> プロンプトを確認します。

Serial Number 及び System ID を変更します。
VLOADER> setenv SYS_SERIAL_NUM 4034389-06-2
VLOADER> setenv bootarg.nvram.sysid 4034389062

Serial Number 及び System ID を確認します。
VLOADER> printenv SYS_SERIAL_NUM
VLOADER> printenv bootarg.nvram.sysid

新しい Serial Number 及び System ID で起動します。
VLOADER> boot

初期 boot の手順は、7-Mode と同様になります。

First Node セットアップ時に作成したクラスタ［Cluster1］へ　join します。
Welcome to the cluster setup wizard.
You can enter the following commands at any time:
"help" or "?" - if you want to have a question clarified,
"back" - if you want to change previously answered questions, and
"exit" or "quit" - if you want to quit the cluster setup wizard.
Any changes you made before quitting will be saved.
You can return to cluster setup at any time by typing "cluster setup".
To accept a default or omit a question, do not enter a value.
Do you want to create a new cluster or join an existing cluster?
{join}: join

デフォルトの値を使用するため、Enter を実行します。
System Defaults:
Private cluster network ports [e0a].
Cluster port MTU values will be set to 1500.
Cluster interface IP addresses will be automatically generated.
Do you want to use these defaults? {yes, no} [yes]: <Enter>

join するクラスタを選択し Enter を実行します。
It can take several minutes to create cluster interfaces...
Step 1 of 3: Join an Existing Cluster
You can type "back", "exit", or "help" at any question.
Enter the name of the cluster you would like to join [cluster1]:
<Enter>

ノード管理ポート及び、アドレスを設定します。
Step 3 of 3: Set Up the Node
You can type "back", "exit", or "help" at any question.
Enter the node management interface port [e0c]: <Enter>
Enter the node management interface IP address: 192.168.1.54
Enter the node management interface netmask [255.255.255.0]: <Enter>
Enter the node management interface default gateway: <Enter>

以上でセットアップは完了です。
A node management interface on port e0c with IP address 192.168.1.54 has been created.
Cluster setup is now complete.
To begin storing and serving data on this cluster, you must complete the following additional tasks if they have not already been completed:
1) Join additional nodes to the cluster by running "cluster setup" on those nodes.
2) If in a HA configuration, verify that storage failover is enabled by running the "storage failover show" command.
3) Create a Vserver by running the "vserver setup" command.
You can access your cluster to complete these tasks by:
1) Using the NetApp System Manager to manage cluster cluster1 at 192.168.1.54.
NetApp System Manager must be at version 2.0 or above.
You can download System Manager from http://support.netapp.com
2) Logging in to the cluster by using SSH (secure shell) from your work station:
ssh admin@192.168.1.50

"cluster show"コマンドで、クラスタ情報を確認します。
cluster1::> cluster show
Node                  Health  Eligibility
--------------------- ------- ------------
cluster1-01           true    true
cluster1-02           true    true
2 entries were displayed.

下記コマンドで、使用可能なディスクをノードに追加します。
cluster1::> storage disk assign -all true -node cluster1-01


*1:容量を増やす場合は、シェルフを追加し対応する。

*2:シミュレーターをダウンロードする URL にあります。

*3:Serial Number と System ID はクラスタ内の各ノードでユニークである必要があります。



###############################################################################

NetApp sysstat コマンドについて 

NetApp 



sysstat とは
" DataONTAP 標準の性能関連情報表示コマンド %CPU 使用率、プロトコル毎の統計情報、Network Throughput、Disk Read/Write、CP 等を表示する。
%FAS の利用状況の概要を確認する事が可能。 

>sysstat -x <interval(sec)>
" マルチプロセッサ CPU の使用率の統計を下記コマンドで出力可能 %1つ以上の CPU がビジ―状態である時間の割合及び、平均値と各プロセッサの個別の状況を表示する。

>sysstat -m <interval(sec)>


sysstat -x 1 の出力例
" Disk Util %アクセス率の最も高いディスクの利用率（%）
%70%-80% 超えが連続する場合は Disk ボトルネックの兆候

" CPU %Interval 内で1つ以上の CPU が busy であった割合（マルチプロセッサの場合は、最も busy な CPU 値）
%常時90%以上の場合は、CPU ボトルネックの可能性大

" cache hit %要求したデータブロックがキャッシュ内に存在した割合（90%以上であれば問題なし）
%アプリケーション特性に依存

> sysstat -x 1
 CPU    NFS   CIFS   HTTP   Total     Net   kB/s    Disk   kB/s    Tape   kB/s  Cache  Cache    CP  CP  Disk   OTHER    FCP  iSCSI     FCP   kB/s   iSCSI   kB/s
                                       in    out    read  write    read  write    age    hit  time  ty  util                            in    out      in    out
  1%      0      0      0       5       0      1       0      0       0      0   >60    100%    0%  -     0%       5      0      0       0      0       0      0
  1%      0      0      0       0       0      0       0      0       0      0   >60    100%    0%  -     0%       0      0      0       0      0       0      0
 33%      0      0      0       0       0      0     505    569       0      0   >60    100%   66%  T    88%       0      0      0       0      0       0      0


CP(Consistency Point)とは
" NVRAM に書き込み待機されているデータを Disk へ書き込む（フラッシュ）処理
" CP ty とは %CP 要求のトリガー、10秒間隔で定期的に実行し、Interval に処理が完了したか等を表示。
%CP 処理が滞るとユーザーサービスに影響がでてくる可能性がある。
%連続した CP は NVRAM 容量の不足ではなく、書き込み先 Disk がボトルネックである可能性がある。



CP ty 処理出力表示説明
" 「-」：取得間隔内に CP の開始がなかった場合
" 「Number」: 取得間隔内に複数の CP が開始された場合の数を表示*1
" 「B」: 連続 CP - 1つ目の CP が完了する前にもう一方の NVRAM からの CP が発生*2
" 「b」: 保留された連続 CP - 更新されたバッファが少なかったため、連続 CP を延期*3
" 「F」: NVlog がフル状態になることによって発生した CP*4
" 「H」: 書き込みの集中により、メモリにキャッシュされたデータ量が閾値を上回り発生した CP
" 「L」: メモリの内の使用可能な領域が閾値を下回り発生した CP
" 「S」: Snapshot 作成によって発生した CP 
" 「T」: タイマーによって発生した CP（デフォルトでは、10秒で1回発生）
" 「U」: フラッシュによって発生した CP
" 「Z」: 内部同期により発生した CP
" 「V」: 仮想バッファ低下により発生した CP
" 「M」: メモリバッファがなくなるのを防ぐために発生した CP
" 「D」: Datavecs 低下により発生した CP
" 「:」: 前回の計測期間より継続された CP*5
" 「#」: 前回の計測期間より CP が継続し、次の CP のための NVLog がフルの状態（次回の CP は必ず B）*6

出力されたタイプを示す文字の後には、サンプリング期間終了時の CP のフェーズを示す文字が表示される。
サンプリング期間中に CP が完了している場合は、この 2番目の文字は空白となる。
" 「0」: 初期化中
" 「n」: 通常ファイルの処理中
" 「s」: 特殊ファイルの処理中（bitmap ファイル等）
" 「q」: クォータ・ファイルの処理中
" 「f」: 変更データのディスクへのフラッシュを実施中
" 「v」: 変更されたスーパーブロックのディスクへのフラッシュを実施中


*1:CP が頻発しているため負荷状況を確認

*2:1つ目の CP が完了し、NVRAM の内容がクリアされるまで、書き込み処理が保留された状態（遅延の可能性あり）

*3:連続 CP 発生寸前の状態

*4:連続して発生すると処理に対して NVRAM 容量が不足していると判断できる。

*5:連続して発生する場合、ディスクへの書き込みがボトルネック

*6:継続 CP が完了し、NVRAM の内容がクリアされるまで、書き込み処理が保留された状態（遅延の可能性あり）


###############################################################################

NetApp Route 設定について 

NetApp 


NetApp へ Route を設定/削除する際の手順になります。

Static Route 追加
> route add net 192.168.1.0/24 10.1.1.254 1

Static Route 削除
> route delete 192.168.1.0

Default Route 設定
> route add default 172.16.1.254 1

Default Route 削除
> route delete default

ルーティングテーブル確認
> route -s
Routing tables

Internet:
Destination      Gateway            Flags     Refs     Use  Interface
default          172.16.1.254       UGS         3       31  e0a
10.1.1/24        link#1             UC          0        0  e0a
systemname       0:50:56:95:45:f    UHL         2       83  lo
10.1.1.254       link#1             UHL         1        0  e0a
localhost        localhost          UH          0        0  lo
192.168.1        10.1.1.254         UGS         0        0  e0a

再起動した際に設定が維持されるように、起動スクリプトへの登録も必要です。
> rdfile /etc/rc
#Auto-generated by setup Tue May 21 08:16:54 GMT 2013
hostname head01
ifconfig e0a `hostname`-e0a mediatype auto flowcontrol full netmask 255.255.255.0 mtusize 1500
route add default 172.16.1.254 1
route add net 192.168.1.0/24 10.1.1.254 1
routed on
options dns.enable off
options nis.enable off
savecore


###############################################################################

NetApp Perfstat ツールについて 

NetApp 



Perfstat とは
" Perfstat は、FAS の詳細なパフォーマンスデータを取得する事が可能なスクリプトです。
" NOW からダウンロードし、クライアントホスト上で実行します。
" Data ONTAP 7G/7-Mode 用の Perfstat7 と、Cluster-Mode 用の Perfstat Converged の 2種類があります。
" 要件として、Perfstat を実施するクライアントと FAS 間で、RSH/SSH 接続が可能である必要があります。


Perfstat 利用準備

FAS で RSH を有効化します。
> options rsh.enable
rsh.enable                   on

RSH 接続要求クライアントを定義します。
> options rsh.access
rsh.access                   all

クライアントで、rsh コマンドを実行し結果が正常に取得可能か確認します。
# rsh 192.168.1.100 -l root:password df -gs


Perfstat オプションスイッチについて
" 「-f」：取得対象の FAS の IP アドレスまたは、ホスト名を指定します。
" 「-p」：パフォーマンスデータのみ取得します。（構成情報は取得しません。）
" 「-F」：ローカルホストの情報を取得しないようにします。
" 「-t」：取得間隔（分）を指定します。
" 「-i」：繰り返し回数を指定します。
" 「-l」：ログイン ID 及びパスワードを指定しています。


Perfstat の実行例

クライアントホストが Linux の場合の実行例は下記のとおりです。
# ./perfstat7_20130425.sh -f 192.168.1.100 -l root:password -p -F -t 5 -i 12 > perfstat.log    

RSH 接続が FAS 側の許容量を超えている場合、下記のエラーが出力されます。
Perfstat: Filer only mode
Perfstat: Perfstat v7.39 (4-2013)
Perfstat: Verify filer rsh access
Perfstat: Filer 192.168.1.100 fails rsh test
Perfstat: Verify connectivity using: ' rsh 192.168.1.100 -n -l root:password "version"' from host

この場合、RSH のセッションを終了させる必要があります。まず、セッション情報を確認します。
> rshstat -a

Advanced モードへ移行します。
> priv set advanced
Warning: These advanced commands are potentially dangerous; use them only when directed to do so by NetApp personnel.

任意の RSH プロセスを終了します。
*> rshkill 0
rshkill: rsh session 0 was closed successfully.


###############################################################################

Clustered ONTAP の基本操作について 

NetApp 



ライセンスの有効化

必要に応じてライセンスを追加します。*1
cluster1::> license add -license-code "License Code"


Aggregate の操作

Raid サイズ、Disk 数を指定して Aggregate を作成します。
cluster1::> storage aggregate create -aggregate aggr1 -raidtype raid_dp -diskcount 5 -nodes cluster1-01 -maxraidsize 22

aggr1 が作成されている事を確認します。
cluster1::> storage aggregate show
Aggregate     Size Available Used% State   #Vols  Nodes            RAID Status
--------- -------- --------- ----- ------- ------ ---------------- ------------
aggr0       5.27GB    4.44GB   16% online       1 cluster1-01      raid_dp,
                                                                   normal
aggr0_cluster1_02_0
             900MB   43.54MB   95% online       1 cluster1-02      raid_dp,
                                                                   normal
aggr1       2.64GB    2.64GB    0% online       0 cluster1-01      raid_dp,
                                                                   normal
3 entries were displayed.

disk が aggr1 にアサインされている事を確認します。
cluster1::> disk show -aggregate aggr1
                     Usable           Container
Disk                   Size Shelf Bay Type        Position   Aggregate Owner
---------------- ---------- ----- --- ----------- ---------- --------- --------
cluster1-01:v4.21    1020MB     -   - aggregate   dparity    aggr1     cluster1-01
cluster1-01:v4.22    1020MB     -   - aggregate   data       aggr1     cluster1-01
cluster1-01:v4.24    1020MB     -   - aggregate   data       aggr1     cluster1-01
cluster1-01:v5.19    1020MB     -   - aggregate   parity     aggr1     cluster1-01
cluster1-01:v5.20    1020MB     -   - aggregate   data       aggr1     cluster1-01
5 entries were displayed.

aggr1 に disk を1本追加します。
cluster1::> storage aggregate add-disks -aggregate aggr1 -disklist cluster1-01:v4.25

disk が追加され、aggr1 の容量が増加している事を確認する。
cluster1::> storage aggregate show
Aggregate     Size Available Used% State   #Vols  Nodes            RAID Status
--------- -------- --------- ----- ------- ------ ---------------- ------------
aggr0       5.27GB    4.44GB   16% online       1 cluster1-01      raid_dp,
                                                                   normal
aggr0_cluster1_02_0
             900MB   43.54MB   95% online       1 cluster1-02      raid_dp,
                                                                   normal
aggr1       3.52GB    3.51GB    0% online       0 cluster1-01      raid_dp,
                                                                   normal
3 entries were displayed.

disk(cluster1-01:v4.25)が aggr1 にアサインされている事を確認します。
cluster1::> disk show -aggregate aggr1
                     Usable           Container
Disk                   Size Shelf Bay Type        Position   Aggregate Owner
---------------- ---------- ----- --- ----------- ---------- --------- --------
cluster1-01:v4.21    1020MB     -   - aggregate   dparity    aggr1     cluster1-01
cluster1-01:v4.22    1020MB     -   - aggregate   data       aggr1     cluster1-01
cluster1-01:v4.24    1020MB     -   - aggregate   data       aggr1     cluster1-01
cluster1-01:v4.25    1020MB     -   - aggregate   data       aggr1     cluster1-01
cluster1-01:v5.19    1020MB     -   - aggregate   parity     aggr1     cluster1-01
cluster1-01:v5.20    1020MB     -   - aggregate   data       aggr1     cluster1-01
6 entries were displayed.


インターフェースグループの作成

インターフェースグループを作成します。
cluster1::> network port ifgrp create -node cluster1-01 -ifgrp a0a -distr-func ip -mode multimode
cluster1::> network port ifgrp create -node cluster1-02 -ifgrp a0a -distr-func ip -mode multimode

インターフェースグループが作成された事を確認します。
cluster1::> network port ifgrp show
         Port       Distribution                   Active
Node     IfGrp      Function     MAC Address       Ports   Ports
-------- ---------- ------------ ----------------- ------- -------------------
cluster1-01
         a0a        ip           02:0c:29:c4:aa:e4 none    -
cluster1-02
         a0a        ip           02:0c:29:c0:8c:8a none    -

インターフェースグループにポートを追加します。
cluster1::> network port ifgrp add-port -node cluster1-01 -ifgrp a0a -port e0d
cluster1::> network port ifgrp add-port -node cluster1-02 -ifgrp a0a -port e0d

インターフェースグループにポートが追加された事を確認します。
cluster1::> network port ifgrp show
         Port       Distribution                   Active
Node     IfGrp      Function     MAC Address       Ports   Ports
-------- ---------- ------------ ----------------- ------- -------------------
cluster1-01
         a0a        ip           02:0c:29:c4:aa:e4 full    e0d
cluster1-02
         a0a        ip           02:0c:29:c0:8c:8a full    e0d
2 entries were displayed.


VLAN 作成

VLAN を作成します。
cluster1::> network port vlan create -node cluster1-01 -vlan-name a0a-10
cluster1::> network port vlan create -node cluster1-02 -vlan-name a0a-10

VLAN が作成された事を確認します。
cluster1::> network port vlan show
                 Network Network
Node   VLAN Name Port    VLAN ID  MAC Address
------ --------- ------- -------- -----------------
cluster1-01
       a0a-10    a0a     10       02:0c:29:c4:aa:e4
cluster1-02
       a0a-10    a0a     10       02:0c:29:c0:8c:8a
2 entries were displayed.


フェイルオーバーグループ作成

フェイルオーバーグループを作成します。
cluster1::> network interface failover-groups create -failover-group failovergroup -node cluster1-01 -port a0a-10
cluster1::> network interface failover-groups create -failover-group failovergroup -node cluster1-02 -port a0a-10

フェイルオーバーグループが作成された事を確認します。
cluster1::> network interface failover-groups show
Failover
Group               Node              Port
------------------- ----------------- ----------
clusterwide
                    cluster1-01       a0a
                    cluster1-01       e0c
                    cluster1-02       a0a
                    cluster1-02       e0c
failovergroup
                    cluster1-01       a0a-10
                    cluster1-02       a0a-10
6 entries were displayed.


SVM(Server Virtual Machine)作成

vserver setup コマンドで SVM を作成します。
cluster1::> vserver setup
Welcome to the Vserver Setup Wizard, which will lead you through
the steps to create a virtual storage server that serves data to clients.

You can enter the following commands at any time:
"help" or "?" if you want to have a question clarified,
"back" if you want to change your answers to previous questions, and
"exit" if you want to quit the Vserver Setup Wizard. Any changes
you made before typing "exit" will be applied.

You can restart the Vserver Setup Wizard by typing "vserver setup". To accept a default
or omit a question, do not enter a value.

Vserver Setup wizard creates and configures only data Vservers.
If you want to create a Vserver with Infinite Volume use the vserver create command.

Step 1. Create a Vserver.
You can type "back", "exit", or "help" at any question.

Enter the Vserver name: svm-01
Choose the Vserver data protocols to be configured {nfs, cifs, fcp, iscsi, ndmp}: nfs, cifs, fcp, iscsi, ndmp
Choose the Vserver client services to be configured {ldap, nis, dns}: dns
Enter the Vserver's root volume aggregate [aggr1]: aggr1
Enter the Vserver language setting, or "help" to see all languages [C]:
Enter the Vserver root volume's security style {mixed, ntfs, unix} [unix]:
Vserver creation might take some time to finish....

Vserver svm-01 with language set to C created.  The permitted protocols are nfs,cifs,fcp,iscsi,ndmp.

Step 2: Create a data volume
You can type "back", "exit", or "help" at any question.

Do you want to create a data volume? {yes, no} [yes]: no

Step 3: Create a logical interface.
You can type "back", "exit", or "help" at any question.

Do you want to create a logical interface? {yes, no} [yes]: no

Step 4: Configure DNS (Domain Name Service).
You can type "back", "exit", or "help" at any question.

Do you want to configure DNS? {yes, no} [yes]: no
Error: Failed to create NFS. Reason: You do not have a valid license for "NFS". Reason: Package "NFS" is not licensed in the cluster.

Step 5: Configure NFS.
You can type "back", "exit", or "help" at any question.

Step 6: Configure CIFS.
You can type "back", "exit", or "help" at any question.

Do you want to configure CIFS? {yes, no} [yes]: no

Step 7: Configure iSCSI.
You can type "back", "exit", or "help" at any question.

Do you want to configure iSCSI? {yes, no} [yes]: no

Step 8: Configure FCP.
You can type "back", "exit", or "help" at any question.

Do you want to configure FCP? {yes, no} [yes]: no

Vserver svm-01 has been configured successfully.

SVM が作成されている事を確認します。
cluster1::> vserver show
                    Admin     Root                  Name    Name
Vserver     Type    State     Volume     Aggregate  Service Mapping
----------- ------- --------- ---------- ---------- ------- -------
cluster1    admin   -         -          -          -       -
cluster1-01 node    -         -          -          -       -
cluster1-02 node    -         -          -          -       -
svm-01      data    running   rootvol    aggr1      file    file
4 entries were displayed.


LIF(Logical Interface) 作成
" role について %クラスタネットワークで使用する LIF は、cluster を定義します。
%データ通信で使用する LIF は、data を定義します。通常、SVM 上に作成する LIF です。
%ノード管理で使用する LIF は、node-mgmt を定義します。
%Intercluster SnapMirror で使用する LIF は、intercluster を定義します。
%クラスタ管理に使用する LIF は、cluster-mgmt を定義します。


iSCSI 用の LIF を作成します。
cluster1::> network interface create -vserver svm-01 -lif lif-iscsi01 -role data -data-protocol iscsi -home-node cluster1-01 -home-port a0a-10 -address 172.16.10.11 -netmask 255.255.255.0
cluster1::> network interface create -vserver svm-01 -lif lif-iscsi02 -role data -data-protocol iscsi -home-node cluster1-02 -home-port a0a-10 -address 172.16.10.12 -netmask 255.255.255.0

iSCSI 用の LIF が作成されている事を確認します。
cluster1::> network interface show lif-iscsi01,lif-iscsi02
            Logical    Status     Network            Current       Current Is
Vserver     Interface  Admin/Oper Address/Mask       Node          Port    Home
----------- ---------- ---------- ------------------ ------------- ------- ----
svm-01
            lif-iscsi01  up/up    172.16.10.11/24    cluster1-01   a0a-10  true
            lif-iscsi02  up/up    172.16.10.12/24    cluster1-02   a0a-10  true
2 entries were displayed.

NFS 用の LIF を作成します。NFS の LIF はマイグレートが可能です。
cluster1::> network interface create -vserver svm-01 -lif lif-nfs01 -role data -data-protocol nfs -home-node cluster1-01 -home-port a0a-10 -address 172.16.20.11 -netmask 255.255.255.0 -failover-group failovergroup
cluster1::> network interface create -vserver svm-01 -lif lif-nfs02 -role data -data-protocol nfs -home-node cluster1-02 -home-port a0a-10 -address 172.16.20.12 -netmask 255.255.255.0 -failover-group failovergroup

NFS 用の LIF が作成されている事を確認します。
cluster1::> network interface show lif-nfs01,lif-nfs02
            Logical    Status     Network            Current       Current Is
Vserver     Interface  Admin/Oper Address/Mask       Node          Port    Home
----------- ---------- ---------- ------------------ ------------- ------- ----
svm-01
            lif-nfs01    up/up    172.16.20.11/24    cluster1-01   a0a-10  true
            lif-nfs02    up/up    172.16.20.12/24    cluster1-02   a0a-10  true
2 entries were displayed.

LIF の詳細情報を確認する際は、-instance オプションを使用します。
cluster1::> network interface show -lif lif-iscsi01 -instance

                    Vserver Name: svm-01
          Logical Interface Name: lif-iscsi01
                            Role: data
                   Data Protocol: iscsi
                       Home Node: cluster1-01
                       Home Port: a0a-10
                    Current Node: cluster1-01
                    Current Port: a0a-10
              Operational Status: up
                 Extended Status: -
                         Is Home: true
                 Network Address: 172.16.10.11
                         Netmask: 255.255.255.0
             Bits in the Netmask: 24
                 IPv4 Link Local: -
              Routing Group Name: d172.16.99.0/24
           Administrative Status: up
                 Failover Policy: disabled
                 Firewall Policy: data
                     Auto Revert: false
   Fully Qualified DNS Zone Name: none
         DNS Query Listen Enable: false
             Failover Group Name:
                        FCP WWPN: -
                  Address family: ipv4
                         Comment: -

LIF の設定を変更する際は、modefy コマンドを使用します。
cluster1::> network interface modify -vserver svm-01 -lif lif-iscsi01 -address 172.16.100.11

CIFS 用の LIF を作成します。
cluster1::> network interface create -vserver svm-01 -lif lif-cifs01 -role data -data-protocol cifs -home-node cluster1-01 -home-port a0a-10 -address 172.16.30.11 -netmask 255.255.255.0
cluster1::> network interface create -vserver svm-01 -lif lif-cifs02 -role data -data-protocol cifs -home-node cluster1-02 -home-port a0a-10 -address 172.16.30.12 -netmask 255.255.255.0

CIFS 用の LIF が作成されている事を確認します。
cluster1::> network interface show lif-cifs01,lif-cifs02
            Logical    Status     Network            Current       Current Is
Vserver     Interface  Admin/Oper Address/Mask       Node          Port    Home
----------- ---------- ---------- ------------------ ------------- ------- ----
svm-01
            lif-cifs01   up/up    172.16.30.11/24    cluster1-01   a0a-10  true
            lif-cifs02   up/up    172.16.30.12/24    cluster1-02   a0a-10  true
2 entries were displayed.

LIF をマイグレート*2します。
※iSCSI の LIF では、マイグレートをサポートしていません。
cluster1::> network interface migrate -vserver svm-01 -lif lif-nfs01 -dest-node cluster1-02 -dest-port a0a-10

lif-nfs01 の Home Node が cluster1-01 から cluster1-02 へ移行した事を確認します。
cluster1::> network interface show lif-nfs01,lif-nfs02
            Logical    Status     Network            Current       Current Is
Vserver     Interface  Admin/Oper Address/Mask       Node          Port    Home
----------- ---------- ---------- ------------------ ------------- ------- ----
svm-01
            lif-nfs01    up/up    172.16.20.11/24    cluster1-02   a0a-10  false
            lif-nfs02    up/up    172.16.20.12/24    cluster1-02   a0a-10  true
2 entries were displayed.

LIF をリバート*3します。
cluster1::> network interface revert -vserver svm-01 -lif lif-nfs01

lif-nfs01 の Home Node が cluster1-02 から cluster1-01 へ戻った事を確認します。
cluster1::> network interface show lif-nfs01,lif-nfs02
            Logical    Status     Network            Current       Current Is
Vserver     Interface  Admin/Oper Address/Mask       Node          Port    Home
----------- ---------- ---------- ------------------ ------------- ------- ----
svm-01
            lif-nfs01    up/up    172.16.20.11/24    cluster1-01   a0a-10  true
            lif-nfs02    up/up    172.16.20.12/24    cluster1-02   a0a-10  true
2 entries were displayed.

SVM 上の全ての LIF を Home Port に戻す際は、lif_name を指定せず * を入力します。
cluster1::> network interface revert -vserver svm-01 *


LIF に適用している VLAN の変更

VLAN-id 20 を定義します。
cluster1::> network port vlan create -node cluster1-01 -vlan-name a0a-20
cluster1::> network port vlan create -node cluster1-02 -vlan-name a0a-20

VLAN が作成された事を確認します。
cluster1::> network port vlan show
                 Network Network
Node   VLAN Name Port    VLAN ID  MAC Address
------ --------- ------- -------- -----------------
cluster1-01
       a0a-10    a0a     10       02:0c:29:c4:aa:e4
       a0a-20    a0a     20       02:0c:29:c4:aa:e4
cluster1-02
       a0a-10    a0a     10       02:0c:29:c0:8c:8a
       a0a-20    a0a     20       02:0c:29:c0:8c:8a
4 entries were displayed.

LIF(lif-nfs)の home-port を VLAN 20 に指定します。
cluster1::> network interface modify -vserver svm-01 -lif lif-nfs01 -home-node cluster1-01 -home-port a0a-20
cluster1::> network interface modify -vserver svm-01 -lif lif-nfs02 -home-node cluster1-02 -home-port a0a-20

現状は、home-port が VLAN 10 となっている事を確認します。
cluster1::> network interface show -lif lif-nfs01,lif-nfs02
            Logical    Status     Network            Current       Current Is
Vserver     Interface  Admin/Oper Address/Mask       Node          Port    Home
----------- ---------- ---------- ------------------ ------------- ------- ----
svm-01
            lif-nfs01    up/up    172.16.20.11/24    cluster1-01   a0a-10  false
            lif-nfs02    up/up    172.16.20.12/24    cluster1-02   a0a-10  false
2 entries were displayed.

home-port を VLAN20 へ移行します。
cluster1::> network interface migrate -vserver svm-01 -lif lif-nfs01 -dest-node cluster1-01 -dest-port a0a-20
cluster1::> network interface migrate -vserver svm-01 -lif lif-nfs02 -dest-node cluster1-02 -dest-port a0a-20

home-port が VLAN20 へ移行した事を確認します。
cluster1::> network interface show lif-nfs01,lif-nfs02
            Logical    Status     Network            Current       Current Is
Vserver     Interface  Admin/Oper Address/Mask       Node          Port    Home
----------- ---------- ---------- ------------------ ------------- ------- ----
svm-01
            lif-nfs01    up/up    172.16.20.11/24    cluster1-01   a0a-20  true
            lif-nfs02    up/up    172.16.20.12/24    cluster1-02   a0a-20  true
2 entries were displayed.


ルーティング設定*4

SVM-01 にデフォルトルートを設定します。
cluster1::> network routing-groups route create -vserver svm-01 -routing-group d172.16.10.0/24 -destination 0.0.0.0/0 -gateway 172.16.10.254

SVM-01 のルーティングテーブルを確認します。
cluster1::> network routing-groups route show
          Routing
Vserver   Group     Destination     Gateway         Metric
--------- --------- --------------- --------------- ------
cluster1
          c192.168.1.0/24
                    0.0.0.0/0       192.168.1.2     20
cluster1-01
          n192.168.1.0/24
                    0.0.0.0/0       192.168.1.2     10
cluster1-02
          n192.168.1.0/24
                    0.0.0.0/0       192.168.1.2     10
svm-01
          d172.16.10.0/24
                    0.0.0.0/0       172.16.10.254   20
4 entries were displayed.

ルーティングテーブルから、ルートを削除する場合は、route delete コマンドを使用します。
cluster1::> network routing-groups route delete -vserver svm-01 -routing-group d172.16.99.0/24 -destination 0.0.0.0/0


Volume の操作

volume を作成します。*5
cluster1::> volume create -vserver svm-01 -volume vol_nfs01 -aggregate aggr1 -size 2g -security-style unix -space-guarantee none -junction-path /vol_nfs01

volume が作成された事を確認します。
cluster1::> volume show
Vserver   Volume       Aggregate    State      Type       Size  Available Used%
--------- ------------ ------------ ---------- ---- ---------- ---------- -----
cluster1-01
          vol0         aggr0        online     RW      851.5MB    486.3MB   42%
cluster1-02
          vol0         aggr0_cluster1_02_0
                                    online     RW      851.5MB    519.5MB   38%
svm-01    rootvol      aggr1        online     RW          2GB     1.90GB    5%
svm-01    vol_nfs01    aggr1        online     RW          2GB     1.50GB   24%
4 entries were displayed.

volume サイズを変更する場合は、volume size コマンドを使用します。
cluster1::> volume size -vserver svm-01 -volume vol_nfs01 -new-size 3g

volume サイズが変更された事を確認します。
cluster1::> volume show vol_nfs01
Vserver   Volume       Aggregate    State      Type       Size  Available Used%
--------- ------------ ------------ ---------- ---- ---------- ---------- -----
svm-01    vol_nfs01    aggr1        online     RW          3GB     1.50GB   49%

volume 作成時に junction-path を指定しなかった場合は、個別にマウントします。
cluster1::> volume mount -vserver svm-01 -volume vol_nfs01 -junction-path /vol_nfs01


LUN の操作

iSCSI ターゲットを作成します。
cluster1::cluster> vserver iscsi create -vserver svm-01

iSCSI ターゲットが作成された事を確認します。
cluster1::cluster> vserver iscsi show
           Target                           Target                       Status
Vserver    Name                             Alias                        Admin
---------- -------------------------------- ---------------------------- ------
svm-01     iqn.1992-08.com.netapp:sn.a74d0e3b00ef11e4918d123478563412:vs.3
                                            svm-01                       up

igroup を作成します。
clluster1::cluster> lun igroup create -vserver svm-01 -igroup igroup01 -protocol iscsi -ostype vmware

igroup が作成された事を確認します。
cluster1::cluster> lun igroup show
Vserver   Igroup       Protocol OS Type  Initiators
--------- ------------ -------- -------- ------------------------------------
svm-01    igroup01     iscsi    vmware   -

igroup にサーバの initiator を追加します。
cluster1::cluster> lun igroup add -vserver svm-01 -igroup igroup01 -initiator iqn.1998-01.com.vmware:localhost-0a162bb4

igroup に initiator が追加された事を確認します。
cluster1::cluster> igroup show
Vserver   Igroup       Protocol OS Type  Initiators
--------- ------------ -------- -------- ------------------------------------
svm-01    igroup01     iscsi    vmware   iqn.1998-01.com.vmware:localhost-0a162bb4

LUN を作成します。
cluster1::cluster> lun create -vserver svm-01 -path /vol/vol_iscsi01/lun_iscsi01 -size 2g -ostype vmware -space-reserve disabled

LUN が作成された事を確認します。
cluster1::cluster> lun show
Vserver   Path                            State   Mapped   Type        Size
--------- ------------------------------- ------- -------- -------- --------
svm-01    /vol/vol_iscsi01/lun_iscsi01    online  unmapped vmware        2GB


 LUN に igroup をマッピングします。
cluster1::cluster> lun map -vserver svm-01 -path /vol/vol_iscsi01/lun_iscsi01 -igroup igroup01

LUN に igroup がマッピングされた事を確認します。
cluster1::cluster> lun mapped show
Vserver    Path                                      Igroup   LUN ID  Protocol
---------- ----------------------------------------  -------  ------  --------
svm-01     /vol/vol_iscsi01/lun_iscsi01              igroup01      0  iscsi

lun サイズを変更する場合は、lun resize コマンドを使用します。
cluster1::> lun resize -vserver svm-01 -path /vol/vol_iscsi01/lun_iscsi01 -size  2.5g

lun サイズが変更された事を確認します。
cluster1::> lun show
Vserver   Path                            State   Mapped   Type        Size
--------- ------------------------------- ------- -------- -------- --------
svm-01    /vol/vol_iscsi01/lun_iscsi01    online  mapped   vmware     2.50GB


NFS 設定

NFS を有効化します。
cluster1::> nfs on -vserver svm-01

NFS が有効になっている事を確認します。
cluster1::> nfs status -vserver svm-01
The NFS server is running.

export-policy を作成します。
cluster1::> vserver export-policy create -vserver svm-01 -policyname export01

export-policy が作成された事を確認します。
cluster1::> vserver export-policy show
Vserver          Policy Name
---------------  -------------------
svm-01           default
svm-01           export01
2 entries were displayed.

export-policy に rule を設定します。
cluster1::> vserver export-policy rule create -vserver svm-01 -policyname export01 -clientmatch 0.0.0.0/0 -anon 0 -rorule any -rwrule any

export-policy に rule が設定された事を確認します。
cluster1::> vserver export-policy rule show
             Policy          Rule    Access   Client                RO
Vserver      Name            Index   Protocol Match                 Rule
------------ --------------- ------  -------- --------------------- ---------
svm-01       export01        1       any      0.0.0.0/0             any

export する volume に export-policy を適用します。
cluster1::> volume modify -vserver svm-01 -volume vol_nfs01 -policy export01

volume に export-policy が適用された事を確認します。
cluster1::> volume show -fields policy
vserver     volume policy
----------- ------ ------
cluster1-01 vol0   -
cluster1-02 vol0   -
svm-01      rootvol
                   default
svm-01      vol_iscsi01
                   default
svm-01      vol_nfs01
                   export01
5 entries were displayed.


CIFS 設定

DNS サーバを設定します。
cluster1::> vserver services dns create -vserver svm-01 -domains example.com -name-servers 192.168.1.99

DNS サーバが設定された事を確認します。
cluster1::> vserver services dns show
                                                              Name
Vserver         State     Domains                             Servers
--------------- --------- ----------------------------------- ----------------
svm-01          enabled   example.com                         192.168.1.99

CIFS サーバを作成し、ドメインに参加します。
cluster1::> cifs create -cifs-server svm-01_cifs -domain example.com -vserver svm-01

In order to create an Active Directory machine account for the CIFS server, you must supply the name and password of a
Windows account with sufficient privileges to add computers to the "CN=Computers" container within the "example.com"
domain.

Enter the user name: Administrator

Enter the password:

CIFS が作成された事を確認します。
cluster1::> vserver cifs show
            Server          Status    Domain/Workgroup Authentication
Vserver     Name            Admin     Name             Style
----------- --------------- --------- ---------------- --------------
svm-01      SVM-01_CIFS     up        EXAMPLE          domain

volume を CIFS 共有します。
※volume の -security-style は ntfs である事が必須です。
cluster1::> vserver cifs share create -vserver svm-01 -share-name vol_cifs01 -path /vol_cifs01

volume が CIFS 共有された事を確認します。
cluster1::> vserver cifs share show
Vserver        Share         Path              Properties Comment  ACL
-------------- ------------- ----------------- ---------- -------- -----------
svm-01         admin$        /                 browsable  -        -
svm-01         ipc$          /                 browsable  -        -
svm-01         vol_cifs01    /vol_cifs01       oplocks    -        Everyone / Full Control
                                               browsable
                                               changenotify
3 entries were displayed.

CIFS サーバのローカルユーザを作成します。
cluster1::> vserver cifs users-and-groups local-user create -user-name testuser -vserver svm-01

Enter the password:
Confirm the password:

ローカルユーザが作成された事を確認します。
cluster1::> vserver cifs users-and-groups local-user show
Vserver      User Name                   Full Name            Description
------------ --------------------------- -------------------- -------------
svm-01       SVM-01_CIFSAdministrator                        Built-in administrator account
svm-01       SVM-01_CIFStestuser        -                    -
2 entries were displayed.

CIFS ACL を設定します。
cluster1::> vserver cifs share access-control create -vserver svm-01 -share vol_cifs01 -user-or-group testuser -permission read

CIFS ACL が設定された事を確認します。
cluster1::> vserver cifs share access-control show
               Share       User/Group                  Access
Vserver        Name        Name                        Permission
-------------- ----------- --------------------------- -----------
svm-01         vol_cifs01  Everyone                    Full_Control
svm-01         vol_cifs01  testuser                    Read
2 entries were displayed.

CIFS ACL が対象のユーザに適用された事を確認します。
cluster1::> vserver cifs share show
Vserver        Share         Path              Properties Comment  ACL
-------------- ------------- ----------------- ---------- -------- -----------
svm-01         admin$        /                 browsable  -        -
svm-01         ipc$          /                 browsable  -        -
svm-01         vol_cifs01    /vol_cifs01       oplocks    -        Everyone / Full Control
                                               browsable           testuser / Read
                                               changenotify
3 entries were displayed.


Snapshot の操作

Snapshot を手動で取得します。
cluster1::> volume snapshot create -vserver svm-01 -volume vol_nfs01 -snapshot ss01

Snapshot が取得された事を確認します。
cluster1::> volume snapshot show -vserver svm-01 -volume vol_nfs01
                                                                   ---Blocks---
Vserver  Volume  Snapshot                        State        Size Total% Used%
-------- ------- ------------------------------- -------- -------- ------ -----
svm-01   vol_nfs01
                 ss01                            valid        80KB     0%   31%

Snapshot を削除します。
cluster1::> volume snapshot delete -vserver svm-01 -volume vol_nfs01 -snapshot *

Warning: Deleting a Snapshot copy permanently removes any data that is stored only in that Snapshot copy. Are
         you sure you want to delete Snapshot copy "ss01" for volume "vol_nfs01" in Vserver "svm-01" ?
          {y|n}: y
1 entry was acted on.

Snapshot を取得するジョブスケジュールを作成します。
cluster1::> job schedule cron create -name job01 -hour 1 -minute 0

Snapshot のジョブが作成された事を確認します。
cluster1::> job schedule show -name job01

Schedule Name: job01
Schedule Type: cron
  Description: @1:00

Snapshot ポリシー*6を作成します。
cluster1::> volume snapshot policy create -policy sspolicy01 -enabled true -vserver svm-01 -schedule1 job01 -count1 2 -prefix1 job01

Snapshot ポリシーが作成された事を確認します。
cluster1::> volume snapshot policy show -policy sspolicy01
Vserver: svm-01
                         Number of Is
Policy Name              Schedules Enabled Comment
------------------------ --------- ------- ----------------------------------
sspolicy01                       1 true    -
    Schedule               Count     Prefix                 SnapMirror Label
    ---------------------- -----     ---------------------- -------------------
    job01                      2     job01                  -

Snapshot ポリシーを volume に適用します。
cluster1::> volume modify -vserver svm-01 -volume vol_nfs01 -snapshot-policy sspolicy01

Snapshot ポリシーが volume に適用された事を確認します。
cluster1::> volume show -fields snapshot-policy -volume vol_nfs01
vserver volume    snapshot-policy
------- --------- ---------------
svm-01  vol_nfs01 sspolicy01


*1:シミュレーターのライセンスはNowからダウンロード可能です。

*2:LIF を Home Node の Home Port から、異なる Node・Port に移行します。

*3:LIF を Home Node の Home Port へ戻します。

*4:ルーティングは、SVM 単位で設定します。

*5:CIFS で共有する volume については、-security-style を ntfs にします。

*6:スケジュールの紐づけ及び、保持世代数を定義します。


###############################################################################

Load Sharing SnapMirror について 

NetApp 


クアライアントからの Read(読み取り)要求を分散して、スループットを向上させる機能になります。
 具体的には、Root を含む任意の Volume のコピー(読み取り専用)を、マスターとは別の Aggregate に作成し、クライアントからの Read 要求を分散します。*1書き込みについては、マスターにのみ行われ、分散されません。


注意点

マスターからコピーに対し、リアルタイムミラーリングが行われないため、マスターで更新されたデータを、読み取れるようにするには、LS ミラーをアップデートする必要があります。これに関連して、Root volume をコピーした際、Root 配下に新たな Volume を作成しても、(LS ミラーをアップデートするまで、コピー先の、Junction Path が更新されないため)当該 Volume にアクセスできない事に注意してください。

SnapMirror 送信先の Volume を作成します。
cluster1::> volume create -vserver svm-01 -volume rootvol_ls -aggregate aggr2 -type DP

送信先の Volume が作成された事を確認します。
cluster1::> volume show -volume rootvol_ls
Vserver   Volume       Aggregate    State      Type       Size  Available Used%
--------- ------------ ------------ ---------- ---- ---------- ---------- -----
svm-01    rootvol_ls   aggr2        online     DP         20MB    19.89MB    0%

LS SnapMirror を作成します。
cluster1::> snapmirror create -source-path svm-01:rootvol -destination-path svm-01:rootvol_ls -type LS

LS SnapMirror が作成された事を確認します。
cluster1::> snapmirror show
                                                                       Progress
Source            Destination  Mirror  Relationship  Total             Last
Path        Type  Path         State   Status        Progress  Healthy Updated
----------- ---- ------------ ------- -------------- --------- ------- --------
cluster1://svm-01/rootvol
            LS   cluster1://svm-01/rootvol_ls
                              Uninitialized
                                      Idle           -         -       -

LS SnapMirror の Initialize を行います。
cluster1::> snapmirror initialize-ls-set -source-path svm-01:rootvol

Initialize が完了した事を確認します。
cluster1::> snapmirror show
                                                                       Progress
Source            Destination  Mirror  Relationship  Total             Last
Path        Type  Path         State   Status        Progress  Healthy Updated
----------- ---- ------------ ------- -------------- --------- ------- --------
cluster1://svm-01/rootvol
            LS   cluster1://svm-01/rootvol_ls
                              Snapmirrored
                                      Idle           -         true    -

Volume サイズが、マスターと同様となっている事を確認します。
cluster1::> volume show -volume rootvol,rootvol_ls
Vserver   Volume       Aggregate    State      Type       Size  Available Used%
--------- ------------ ------------ ---------- ---- ---------- ---------- -----
svm-01    rootvol      aggr1        online     RW          2GB     1.90GB    5%
svm-01    rootvol_ls   aggr2        online     LS          2GB     1.90GB    5%
2 entries were displayed.

新規の Volume を作成すると、下記のとおり、留意事項が通知されます。
cluster1::> volume create -vserver svm-01 -volume vol_nfs02 -aggregate aggr1 -size 1g -security-style unix -space-guarantee none -junction-path /vol_nfs02
[Job 82] Job succeeded: Successful

Notice: Volume vol_nfs02 now has a mount point from volume rootvol.  The load sharing (LS) mirrors of volume
        rootvol have no replication schedule.  Volume vol_nfs02 will not be visible in the global namespace until
        the LS mirrors of volume rootvol have been updated.
        現状、LS SnapMirror スケジュールが設定されていないため、アップデートされるまで、クライントからアクセスできません。

LS SnapMirror をアップデートします。
cluster1::> snapmirror update-ls-set -source-path svm-01:rootvol

LS SnapMirror がアップデートされた事を確認します。
cluster1::> snapmirror show
                                                                       Progress
Source            Destination  Mirror  Relationship  Total             Last
Path        Type  Path         State   Status        Progress  Healthy Updated
----------- ---- ------------ ------- -------------- --------- ------- --------
cluster1://svm-01/rootvol
            LS   cluster1://svm-01/rootvol_ls
                              Snapmirrored
                                      Idle           -         true    -

LS SnapMirror のスケジュールを作成します。
cluster1::> job schedule cron create -name sched01 -hour 1 -minute 0

LS SnapMirror にスケジュールを適用します。
cluster1::> snapmirror modify -destination-path svm-01:rootvol_ls -schedule sched01

LS SnapMirror にスケジュールが設定されている事を確認します。
cluster1::> snapmirror show -fields schedule
source-path               destination-path             schedule
------------------------- ---------------------------- --------
cluster1://svm-01/rootvol cluster1://svm-01/rootvol_ls sched01


*1:クライアントからの Read 要求は、全てコピーされた Volume に向けられます。



###############################################################################

Protection SnapMirror について 

NetApp 


従来のデータ保護を目的とした、クラスタ内/クラスタ間のミラーリング機能になります。
" クラスタ内 SnapMirror %Cluster Network を使用して、ローカルクラスタ上で、SnapMirror を行う。
%ターゲットボリュームは、Source と同じ SVM でも、異なる SVM でも良い。

" クラスタ間 SnapMirror %異なるクラスタに存在するボリューム間で、SnapMirror を行う。
%クラスタ間の Intercluster LIF を使用する。



Source 側の設定

Cluster 間通信用の VLAN を定義します。
cluster1::> network port vlan create -node cluster1-01 -vlan-name a0a-99
cluster1::> network port vlan create -node cluster1-02 -vlan-name a0a-99

Cluster 間通信用の VLAN が定義された事を確認します。
cluster1::> network port vlan show
                 Network Network
Node   VLAN Name Port    VLAN ID  MAC Address
------ --------- ------- -------- -----------------
cluster1-01
       a0a-10    a0a     10       02:0c:29:c4:aa:e4
       a0a-20    a0a     20       02:0c:29:c4:aa:e4
       a0a-30    a0a     30       02:0c:29:c4:aa:e4
       a0a-99    a0a     99       02:0c:29:c4:aa:e4
cluster1-02
       a0a-10    a0a     10       02:0c:29:c0:8c:8a
       a0a-20    a0a     20       02:0c:29:c0:8c:8a
       a0a-30    a0a     30       02:0c:29:c0:8c:8a
       a0a-99    a0a     99       02:0c:29:c0:8c:8a
8 entries were displayed.

Cluster 間通信用の FailoverGroup を定義します。
cluster1::> network interface failover-groups create -failover-group failovergroup -node cluster1-01 -port a0a-99
cluster1::> network interface failover-groups create -failover-group failovergroup -node cluster1-02 -port a0a-99

Cluster 間通信用の FailoverGroup を定義された事を確認します。
cluster1::> network interface failover-groups show
Failover
Group               Node              Port
------------------- ----------------- ----------
clusterwide
                    cluster1-01       a0a
                    cluster1-01       e0c
                    cluster1-02       a0a
                    cluster1-02       e0c
failovergroup
                    cluster1-01       a0a-10
                    cluster1-01       a0a-99
                    cluster1-02       a0a-10
                    cluster1-02       a0a-99
8 entries were displayed.

Cluster 間通信用の LIF を作成します。
cluster1::> network interface create -vserver cluster1-01 -lif lif-cluster01 -role intercluster -home-node cluster1-01 -home-port a0a-99 -address 172.16.99.11 -netmask 255.255.255.0
cluster1::> network interface create -vserver cluster1-02 -lif lif-cluster02 -role intercluster -home-node cluster1-02 -home-port a0a-99 -address 172.16.99.12 -netmask 255.255.255.0

Cluster 間通信用の LIF が作成されている事を確認します。
cluster1::> network interface show lif-cluster01,lif-cluster02
            Logical    Status     Network            Current       Current Is
Vserver     Interface  Admin/Oper Address/Mask       Node          Port    Home
----------- ---------- ---------- ------------------ ------------- ------- ----
cluster1-01
            lif-cluster01
                         up/up    172.16.99.11/24    cluster1-01   a0a-99  true
cluster1-02
            lif-cluster02
                         up/up    172.16.99.12/24    cluster1-02   a0a-99  true
2 entries were displayed.


Destination 側の設定

インターフェースグループを作成します。
cluster2::>  network port ifgrp create -node cluster2-01 -ifgrp a0a -distr-func ip -mode multimode
cluster2::>  network port ifgrp create -node cluster2-02 -ifgrp a0a -distr-func ip -mode multimode

インターフェースグループが作成された事を確認します。
cluster2::> network port ifgrp show
         Port       Distribution                   Active
Node     IfGrp      Function     MAC Address       Ports   Ports
-------- ---------- ------------ ----------------- ------- -------------------
cluster2-01
         a0a        ip           02:0c:29:af:99:db none    -
cluster2-02
         a0a        ip           02:0c:29:96:f8:e7 none    -
2 entries were displayed.

インターフェースグループにポートを追加します。
cluster2::> network port ifgrp add-port -node cluster2-01 -ifgrp a0a -port e0d
cluster2::> network port ifgrp add-port -node cluster2-02 -ifgrp a0a -port e0d

インターフェースグループにポートが追加された事を確認します。
cluster2::> network port ifgrp show
         Port       Distribution                   Active
Node     IfGrp      Function     MAC Address       Ports   Ports
-------- ---------- ------------ ----------------- ------- -------------------
cluster2-01
         a0a        ip           02:0c:29:af:99:db full    e0d
cluster2-02
         a0a        ip           02:0c:29:96:f8:e7 full    e0d
2 entries were displayed.

Cluster 間通信用の VLAN を定義します。
cluster2::> network port vlan create -node cluster2-01 -vlan-name a0a-99
cluster2::> network port vlan create -node cluster2-02 -vlan-name a0a-99

Cluster 間通信用の VLAN が定義された事を確認します。
cluster2::> network port vlan show
                 Network Network
Node   VLAN Name Port    VLAN ID  MAC Address
------ --------- ------- -------- -----------------
cluster2-01
       a0a-99    a0a     99       02:0c:29:af:99:db
cluster2-02
       a0a-99    a0a     99       02:0c:29:96:f8:e7
2 entries were displayed.

Cluster 間通信用の FailoverGroup を定義します。
cluster2::> network interface failover-groups create -failover-group failovergroup -node cluster2-01 -port a0a-99
cluster2::> network interface failover-groups create -failover-group failovergroup -node cluster2-02 -port a0a-99

Cluster 間通信用の FailoverGroup を定義された事を確認します。
cluster2::> network interface failover-groups show
Failover
Group               Node              Port
------------------- ----------------- ----------
clusterwide
                    cluster2-02       a0a
                    cluster2-02       e0c
                    cluster2-01       a0a
                    cluster2-01       e0c
failovergroup
                    cluster2-02       a0a-99
                    cluster2-01       a0a-99
6 entries were displayed.

vserver setup コマンドで SVM を作成します。
cluster2::> vserver setup
Welcome to the Vserver Setup Wizard, which will lead you through
the steps to create a virtual storage server that serves data to clients.

You can enter the following commands at any time:
"help" or "?" if you want to have a question clarified,
"back" if you want to change your answers to previous questions, and
"exit" if you want to quit the Vserver Setup Wizard. Any changes
you made before typing "exit" will be applied.

You can restart the Vserver Setup Wizard by typing "vserver setup". To accept a default
or omit a question, do not enter a value.

Vserver Setup wizard creates and configures only data Vservers.
If you want to create a Vserver with Infinite Volume use the vserver create command.

Step 1. Create a Vserver.
You can type "back", "exit", or "help" at any question.

Enter the Vserver name: bsvm-01
Choose the Vserver data protocols to be configured {nfs, cifs, fcp, iscsi, ndmp}:  nfs, cifs, fcp, iscsi, ndmp
Choose the Vserver client services to be configured {ldap, nis, dns}: dns
Enter the Vserver's root volume aggregate [aggr1]: aggr1
Enter the Vserver language setting, or "help" to see all languages [C.UTF-8]: C
Enter the Vserver root volume's security style {mixed, ntfs, unix} [unix]: unix
Vserver creation might take some time to finish....

Vserver bsvm-01 with language set to C created.  The permitted protocols are nfs,cifs,fcp,iscsi,ndmp.

Step 2: Create a data volume
You can type "back", "exit", or "help" at any question.

Do you want to create a data volume? {yes, no} [yes]: no

Step 3: Create a logical interface.
You can type "back", "exit", or "help" at any question.

Do you want to create a logical interface? {yes, no} [yes]: no

Step 4: Configure DNS (Domain Name Service).
You can type "back", "exit", or "help" at any question.

Do you want to configure DNS? {yes, no} [yes]: no
Error: Failed to create NFS. Reason: You do not have a valid license for "NFS". Reason: Package "NFS" is not licensed in the cluster.

Step 5: Configure NFS.
You can type "back", "exit", or "help" at any question.

Step 6: Configure CIFS.
You can type "back", "exit", or "help" at any question.

Do you want to configure CIFS? {yes, no} [yes]: no

Step 7: Configure iSCSI.
You can type "back", "exit", or "help" at any question.

Do you want to configure iSCSI? {yes, no} [yes]: no

Step 8: Configure FCP.
You can type "back", "exit", or "help" at any question.

Do you want to configure FCP? {yes, no} [yes]: no

Vserver bsvm-01 has been configured successfully.

Cluster 間通信用の LIF を作成します。
cluster2::> network interface create -vserver cluster2-01 -lif lif-cluster01 -role intercluster -home-node cluster2-01 -home-port a0a-99 -address 172.16.99.21 -netmask 255.255.255.0
cluster2::> network interface create -vserver cluster2-02 -lif lif-cluster02 -role intercluster -home-node cluster2-02 -home-port a0a-99 -address 172.16.99.22 -netmask 255.255.255.0

Cluster 間通信用の LIF が作成されている事を確認します。
cluster2::> network interface show lif-cluster01,lif-cluster02
            Logical    Status     Network            Current       Current Is
Vserver     Interface  Admin/Oper Address/Mask       Node          Port    Home
----------- ---------- ---------- ------------------ ------------- ------- ----
cluster2-01
            lif-cluster01
                         up/up    172.16.99.21/24    cluster2-01   a0a-99  true
cluster2-02
            lif-cluster02
                         up/up    172.16.99.22/24    cluster2-02   a0a-99  true
2 entries were displayed.

Cluster Peer を作成します。
cluster2::> cluster peer create -peer-addrs 172.16.99.11,172.16.99.12 -username admin
Remote Password:

Cluster Peer が作成されている事を確認します。
cluster2::> cluster peer show -instance

            Peer Cluster Name: cluster1
Remote Intercluster Addresses: 172.16.99.11, 172.16.99.12
                 Availability: Available
          Remote Cluster Name: cluster1
          Active IP Addresses: 172.16.99.11, 172.16.99.12
        Cluster Serial Number: 1-80-000008

Vserver Peer を作成します。
cluster2::> vserver peer create -vserver bsvm-01 -peer-vserver svm-01 -applications snapmirror -peer-cluster cluster1

Vserver Peer が作成されている事を確認します。※この時点では、まだ承認されていません。
cluster2::> vserver peer show
            Peer        Peer
Vserver     Vserver     State
----------- ----------- ------------
bsvm-01     svm-01      initiated

Source 側で、destination 側の Vserver Peer を承認します。
cluster1::> vserver peer accept -vserver svm-01 -peer-vserver bsvm-01

Vserver Peer が承認されている事を確認します
cluster2::> vserver peer show
            Peer        Peer
Vserver     Vserver     State
----------- ----------- ------------
bsvm-01     svm-01      peered

SnapMirror 送信先の Volume を作成します。
cluster2::> volume create -vserver bsvm-01 -volume rootvol_is -aggregate aggr1 -type DP

送信先の Volume が作成された事を確認します。
cluster2::> volume show -volume rootvol_is
Vserver   Volume       Aggregate    State      Type       Size  Available Used%
--------- ------------ ------------ ---------- ---- ---------- ---------- -----
bsvm-01   rootvol_is   aggr1        online     DP         20MB    19.89MB    0%

InterCluster SnapMirror を作成します。
cluster2::> snapmirror create -source-path cluster1://svm-01/rootvol bsvm-01:rootvol_is -type DP

InterCluster SnapMirror が作成された事を確認します。
cluster2::> snapmirror show
                                                                       Progress
Source            Destination  Mirror  Relationship  Total             Last
Path        Type  Path         State   Status        Progress  Healthy Updated
----------- ---- ------------ ------- -------------- --------- ------- --------
svm-01:rootvol
            DP   bsvm-01:rootvol_is
                              Uninitialized
                                      Idle           -         true    -

InterCluste SnapMirror の Initialize を行います。
cluster2::> snapmirror initialize -source-path cluster1://svm-01/rootvol bsvm-01:rootvol_is

Initialize が完了した事を確認します。
cluster1::> snapmirror show
                                                                       Progress
Source            Destination  Mirror  Relationship  Total             Last
Path        Type  Path         State   Status        Progress  Healthy Updated
----------- ---- ------------ ------- -------------- --------- ------- --------
svm-01:rootvol
            DP   bsvm-01:rootvol_is
                              Snapmirrored
                                      Idle           -         true    -




###############################################################################

sdw_cl_vol について 

NetApp 


SnapManager for Exchange (SME) 等のベリファイ時に、ミラー先で生成されるボリュームです。
ベリファイ成功時は自動で削除されますが、失敗時は残留する場合があります。
これが残留していると、対象の Snapshot が busy 状態となり、次回のベリファイも失敗する可能性があります。

ボリューム名は、sdw_cl_[volname]_0 で生成されます。
> df -h
Filesystem               total       used      avail capacity  Mounted on
/vol/sdw_cl_testvol_0/      100GB       50GB      50GB      50%  /vol/sdw_cl_testvol_0/
/vol/sdw_cl_testvol_0/.snapshot        0KB    1000KB        0KB     ---%  /vol/sdw_cl_testvol_0/.snapshot

対象ボリュームの Snapshot 状況を確認すると、busy 状態の Snapshot が存在します。
> snap list testvol
Volume testvol
working...

  %/used       %/total  date          name
----------  ----------  ------------  --------
  0% ( 0%)    0% ( 0%)  Jan 16 06:12  netapp(0151729559)_testvol.1747
  0% ( 0%)    0% ( 0%)  Jan 16 06:12  @snapmir@{93F9293E-17BB-4AF5-91D6-FBEFBDCFCCFE}
  0% ( 0%)    0% ( 0%)  Jan 16 06:01  exchsnap__exchange_01-01-2015_06.00.46 (busy,snapmirror,vclone)

以下のコマンドで、sdw_cl_vol を削除します。
> vol offline sdw_cl_testvol_0
> vol destroy sdw_cl_testvol_0

対象ボリュームの Snapshot 状況を確認すると、busy 状態の Snapshot が削除されています。
> snap list testvol
Volume testvol
working...

  %/used       %/total  date          name
----------  ----------  ------------  --------
  0% ( 0%)    0% ( 0%)  Jan 16 06:12  netapp(0151729559)_testvol.1747
  0% ( 0%)    0% ( 0%)  Jan 16 06:12  @snapmir@{93F9293E-17BB-4AF5-91D6-FBEFBDCFCCFE}

​	

###############################################################################


###############################################################################


###############################################################################



###############################################################################


###############################################################################


###############################################################################


###############################################################################


###############################################################################



###############################################################################


###############################################################################


###############################################################################


###############################################################################


###############################################################################



###############################################################################


###############################################################################


###############################################################################


###############################################################################


###############################################################################



###############################################################################


###############################################################################


###############################################################################


###############################################################################


###############################################################################



###############################################################################


###############################################################################


###############################################################################


###############################################################################


###############################################################################



###############################################################################


###############################################################################


###############################################################################


###############################################################################


###############################################################################