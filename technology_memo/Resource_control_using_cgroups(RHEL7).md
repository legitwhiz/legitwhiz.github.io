---
layout: default
title: cgroupsを利用したリソースコントロール(RHEL7)
---

# cgroupsを利用したリソースコントロール(RHEL7)

## cgroupsとは

cgroups(Control Groups)とは、「プロセスをグループ化して、
リソースの利用をコントロール」するカーネル機能で、
Linux 2.6.24からマージされています。

具体的には、グループ単位でリソースの割り当て、
優先度、管理、モニタリングなどが設定できます。

cgroupsそのものはプロセスを「コントロールグループ」
と呼ばれる単位にまとめるだけで、リソースコントロールを
行うにはコントロールグループに「サブシステム」
と呼ばれる抽象化されたリソース群をつなげる必要があります。


主なサブシステムには、次のようなものがあります。

・cpu       CPUへのアクセス
・cpuacct   CPUについての自動レポートを生成
・cpuset    マルチコアCPUのコア単位およびメモリノードを割り当て
・memory    メモリに対する制限設定とメモリリソースについての自動レポートの生成
・blkio     ブロックデバイスの入出力アクセス
・devices   デバイスへのアクセス
・net_cls   ネットワークパケットへのタグ付け
・net_prio  ネットワークトラフィックの優先度を動的に設定
・freezer   タスクを一時停止または再開

「コントロールグループ」自体は、あくまで名前だけなので
１つの「コントロールグループ」で複数のリソースをコントロールすることも可能です。


## cgroupsのインストール

### cgroupsのインストール
```
# yum install libcgroup libcgroup-tools
```

### cgroupsの起動設定
```
# /usr/bin/systemctl enable cgconfig
# /usr/bin/systemctl enable cgred
```

## コマンドによる設定方法

### まずはグループ作成
対象をCPUとメモリとした[CPU75_Mem_Group]というコントロールグループを作成する。

```
# sudo cgcreate -g cpu,memory:/CPU75_Mem_Group
```

### 制限値を設定
作成したコントロールグループにリソースの制限値を設定する。
CPUを使用率75%に制限する場合は、1000000マイクロ秒(1秒)あたり
75000マイクロ秒(0.75秒)間だけ、単一のCPUを使用するよう
に指定したいので以下のようになる。と思いがちですが
「単一のCPU」というのがネックで複数コアを搭載している場合は


制限したい使用率75%×コア数(4コアの場合)
[cpu.cfs_quota_us]を計算すると
[cpu.cfs_quota_us]= 0.75 x 4core x 100000(sをµsに変換) = 300000 となる。

以下のように設定したい。

```
# cgset -r cpu.cfs_quota_us=300000 CPU75_Mem_Group
# cgset -r cpu.cfs_period_us=1000000 CPU75_Mem_Group
```

メモリの割り当て制限する場合は、
memory.limit_in_bytes(ユーザーメモリの上限)とmemory.memsw.limit_in_bytes(ユーザーメモリ+スワップの上限)の値を設定する必要がある。

例えばユーザーメモリ(物理メモリ)を100MB、スワップを500MBに制限するとした場合は

```
# cgset -r memory.limit_in_bytes=100M CPU75_Mem_Group
# cgset -r memory.memsw.limit_in_bytes=500M CPU75_Mem_Group
```


### その他のcgroupsに関連するコマンド

コマンド            機能
・cgcreate          コントロールグループの作成
・cgdelete          コントロールグループの削除
・cgset             サブシステムのパラメーター設定
・cgget             コントロールグループのパラメーター表示
・cgclassify        コントロールグループのタスク移動
・cgexec            コントロールグループ内のプロセス開始
・cgsnapshot        既存サブシステムから設定ファイルを生成
・cgconfigparser    設定ファイルを解析して階層をマウント
・cgclear           コントロールグループのアンロード
・lscgroup          コントロールグループの確認
・lssubsys          サブシステムのマウントポイント表示

## 設定ファイルによる設定方法

### 設定ファイルによる設定

cgconfigサービスが参照している[/etc/cgconfig.conf]を編集し設定する方法です。
コマンドと同じ条件で制限する場合は、以下のようにファイルに編集する必要がある。

[/etc/cgconfig.conf]
```
group CPU75_Mem_Group  {
    cpu {
        cpu.cfs_quota_us = 300000;
        cpu.cfs_period_us = 1000000;
    }
    memory {
        memory.limit_in_bytes = 100M
        memory.memsw.limit_in_bytes = 500M
    }
}
```

### 特定ユーザのみ制限をかける方法

cgredサービスが参照している[/etc/cgrules.conf]に下記の設定を行い、
[/etc/cgconfig.conf]で設定したコントロールグループを特定ユーザに関連づける。

[/etc/cgrules.conf]
```
hoge_user cpu CPU75_Mem_Group
```

設定を反映するには、サービスの再起動が必要となる。


### 特定プロセスを制限をかけて起動

cgroup経由でSofteterを起動
[/etc/cgconfig.conf]で設定したコントロールグループ

```
# cgexec -g cpu:CPU75_Mem_Group <プロセス起動コマンド>
```

### 特定ユーザの特定プログラムだけに制限をかける方法

[/etc/cgrules.conf]に下記の設定を行い、[/etc/cgconfig.conf]で設定した
コントロールグループを特定ユーザ、特定プログラムに関連づける。

[/etc/cgrules.conf]
```
hoge_user:<プログラム名> cpu CPU75_Mem_Group
```

### 制限をかけた特定プログラムを他コントロールグループに移す方法

ユーザ単位で制限したときのタスク(プロセス)は、CPU利用率が制限され
実行時点では、コントロールグループの管理下となる。
そのため、psコマンドを実行すると管理下にあるタスク(プロセス)の
PIDが出力される。

例えばpsコマンド実行時、[hoge_user]のPID[3333]だったとしよう
[/sys/fs/cgroup/cpu/CPU75_Mem_Group/tasks]にPIDが格納されているので
[CPU75_Mem_Group]から[CPU25_Mem_Group]へコントロールグループを
移すのは、以下のように実施する。

```
# sh -c "echo 3333 >> /sys/fs/cgroup/cpu/CPU25_Mem_Group/tasks"
```

### ディスクI/O帯域制限する方法

以下のパラメータを変更するとディスクI/O制限制限することが可能となる。

・特定のデバイスに対するアクセス速度の上限をByte/Sec単位で指定。
0を指定すると制限を解除。

指定方法は"Major:Minor 設定値"（例"8:0 1048576"）

・blkio.throttle.read_bps_device
・blkio.throttle.write_bps_device

・特定のデバイスに対するアクセス速度の上限をIO/Sec単位で指定。
0を指定すると制限を解除。

指定方法は"Major:Minor 設定値"（例"8:0 2048"）

・blkio.throttle.read_iops_device
・blkio.throttle.write_iops_device

※Minor番号の指定がありますが、実際にはディスクパーティション単位での
指定はできない場合があるようです。
パーティション/dev/sda1, /dev/sda2・・などを使用している場合は、
/dev/sdaに対して指定すること。

まずは、対象となるブロックデバイスのメジャー番号の確認
以下の場合、[/dev/sda]は[8:0]となる。

```
# lsblk -p
NAME                         MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
/dev/fd0                      2:0    1    4K  0 disk
/dev/sda                      8:0    0   40G  0 disk
├/dev/sda1                   8:1    0    1G  0 part /boot
└/dev/sda2                   8:2    0   39G  0 part
  ├/dev/mapper/centos-root 253:0    0   37G  0 lvm  /
  └/dev/mapper/centos-swap 253:1    0    2G  0 lvm  [SWAP]
/dev/sr0                     11:0    1 1024M  0 rom
```

書き込みの上限を1MB/Secに指定した場合、[/etc/cgconfig.conf]に
以下のように設定する。

[/etc/cgconfig.conf]
```
group DiskIO_Group  {
    blkio {
        blkio.throttle.read_bps_device = "8:0 1048576";
        blkio.throttle.write_bps_device = "8:0 1048576";
    }
}
```

同様にIOPSの上限を999IOPSに制限する場合は、[/etc/cgconfig.conf]に
以下のように設定する。

[/etc/cgconfig.conf]
```
group DiskIO_Group  {
    blkio {
        blkio.throttle.read_iops_device = "8:0 999";
        blkio.throttle.write_iops_device = "8:0 999";
    }
}
```

CPU、メモリ同様にプロセス毎、ユーザ毎にディスクも制限可能だ。


### ネットワーク帯域制限する方法

プロセスごとのネットワーク帯域制限は、[cgroups]の[net_cls]と[tc]もしくは[netfilter]を使うことで実現可能です。

net_cls サブシステムは、Linux トラフィックコントローラー (tc) が
特定の cgroup から発信されるパケットを識別できるようにし、
クラス識別子 (classid) を使用して、ネットワークパケットをタグ付けします。
トラフィックコントローラーは、異なる cgroup からのパケットに
異なる優先順位を割り当てるように設定できます。

送出するネットワークパケットに『帯域クラスラベル』を付与します。帯域クラスは、別途 tc コマンドで設定しておく必要があります。tc コマンドは、送出パケットに対するネットワーク帯域を制御する機能を提供します。

なお、tc コマンドは受信パケットに対する帯域制御はできません。

まずは、ネットワーク制限するグループを作成し

[/etc/cgconfig.conf]
```
group Network_Group1 {
    net_cls {
        net_cls.classid = 0x100001;
    }
}
group Network_Group2 {
    net_cls {
        net_cls.classid = 0x100002;
    }
}
```

tcコマンドで制限値を設定し、cgroupのclassidと紐づける
```
# <Network I/F>を除外
tc qdisc del dev <Network I/F①> root
tc qdisc del dev <Network I/F②> root

# <Network I/F>を追加
tc qdisc add dev <Network I/F①> root handle 1: htb default 1
tc qdisc add dev <Network I/F②> root handle 1: htb default 1

# <Network I/F①>を10MBに制限
tc class add dev <Network I/F①> parent 1: classid 10:1  htb rate 1000Mbit ceil 1000Mbit burst 10MB cburst 10MB

# <Network I/F①>を5MBに制限
tc class add dev <Network I/F②> parent 1: classid 10:2 htb rate  500Mbit ceil  500Mbit burst  5MB cburst  5MB

# tc filterに<Network I/F①>を追加
tc filter add dev <Network I/F①> parent 1: protocol ip prio 1 handle 1 cgroup
tc filter add dev <Network I/F②> parent 1: protocol ip prio 1 handle 1 cgroup

# プロセスに帯域制限を付与して実行
cgexec --sticky -g net_cls:Network_Group1 ./scp_test.sh
```

ネットワーク帯域制限の設定確認するには

```
tc qdisc show dev <Network I/F①>
qdisc tbf 1: root refcnt 2 rate 1000Mbit burst 10MB lat 36.9ms 
qdisc netem 10: parent 1:1 limit 1000 delay 50.0ms  10.0ms
```

ネットワーク帯域制限がかかっている状態か確認するには

```
tc -s qdisc show dev <Network I/F①>
qdisc tbf 1: root refcnt 2 rate 1000Mbit burst 10MB lat 36.9ms 
qdisc netem 10: parent 1:1 limit 1000 delay 50.0ms  10.0ms
```

また、tcコマンドでは、帯域幅だけでなく、以下オプションによりデータキュー、パケットのサイズに制限をかけることも可能です。

limit 500Kb … データキューのサイズを 500KByte に設定。
buffer 100Kb … パケットのサイズを 100KByte に設定。
rate 500Kbps … 帯域幅を 200KBps に設定。
注意点として、[tc]での[b]表記は「ビット」ではなく「バイト」であること。

tcの詳しい説明は以下を参考にするといいだろう。
http://labs.gree.jp/blog/2014/10/11266/
https://qiita.com/hana_shin/items/d9ba818b49aca87b2314

## cgroupsの用途

・KVM仮想マシンのIO帯域を制限
・Dockerのコンテナ毎にCPU,メモリ制限
・アンチウィルスソフトウェアへのCPU制限
・業務に影響を与えないためにscp等のファイル転送時に帯域制限
・AWS等のクラウド環境で課金対象を低減させるための、リソース制限等々


## 参考
https://htaira.fedorapeople.org/hbstudy19/hbstudy19-cgroups.pdf




































