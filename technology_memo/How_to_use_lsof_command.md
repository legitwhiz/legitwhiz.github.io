---
title: lsofコマンドの使い方
tags: centos7 lsof
author: hana_shin
slide: false
---
#1 環境
VMware Workstation 12 Player上のゲストマシンを使っています。

```
[root@admin ~]# cat /etc/redhat-release
CentOS Linux release 7.3.1611 (Core)

[root@admin ~]# uname -r
3.10.0-514.el7.x86_64
```

#2 インストール方法
```
[root@server ~]# yum -y install lsof
[root@server ~]# lsof -v
lsof version information:
    revision: 4.87

```

#3 ネットワーク関連
##3.1　INETドメインのソケットを使用しているプロセスの表示方法(-i)

```
[root@server ~]# lsof -i
COMMAND    PID   USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
chronyd    512 chrony    1u  IPv4  16709      0t0  UDP localhost:323
chronyd    512 chrony    2u  IPv6  16710      0t0  UDP localhost:323
chronyd    512 chrony    3u  IPv4  57134      0t0  UDP server:37067->routerida1.soprano-asm.net:ntp
httpd      776   root    4u  IPv6  17035      0t0  TCP *:http (LISTEN)
sshd       779   root    3u  IPv4  18920      0t0  TCP *:ssh (LISTEN)
sshd       779   root    4u  IPv6  18929      0t0  TCP *:ssh (LISTEN)
sshd       780   root    3u  IPv4  20514      0t0  TCP server:ssh->192.168.0.5:50081 (ESTABLISHED)
httpd      781 apache    4u  IPv6  17035      0t0  TCP *:http (LISTEN)
httpd      782 apache    4u  IPv6  17035      0t0  TCP *:http (LISTEN)
httpd      783 apache    4u  IPv6  17035      0t0  TCP *:http (LISTEN)
httpd      784 apache    4u  IPv6  17035      0t0  TCP *:http (LISTEN)
httpd      785 apache    4u  IPv6  17035      0t0  TCP *:http (LISTEN)
sshd       828   root    3u  IPv4  20580      0t0  TCP server:ssh->192.168.0.5:50082 (ESTABLISHED)
sshd      1125   root    3u  IPv4  23128      0t0  TCP server:ssh->192.168.0.5:50324 (ESTABLISHED)
sshd      1453   root    3u  IPv4  34525      0t0  TCP server:ssh->192.168.0.5:55322 (ESTABLISHED)
docker-pr 2834   root    4u  IPv6  50817      0t0  TCP *:documentum_s (LISTEN)
```


##3.2 UNIXドメインのソケットを使用しているプロセスの表示方法(-U)

```
[root@server ~]# lsof -U
COMMAND    PID    USER   FD   TYPE             DEVICE SIZE/OFF  NODE NAME
systemd      1    root   12u  unix 0xffff880034755400      0t0   964 /run/systemd/private
systemd      1    root   14u  unix 0xffff880031824400      0t0 23916 socket
systemd      1    root   16u  unix 0xffff880034c19400      0t0 10519 /run/systemd/notify
systemd      1    root   17u  unix 0xffff880034c19000      0t0 10521 /run/systemd/cgroups-agent
systemd      1    root   18u  unix 0xffff880034750400      0t0  1017 /run/lvm/lvmpolld.socket
-以下、略-
```


##3.3 TCPソケットを使用しているプロセスの表示方法(-iTCP)

```
[root@server ~]# lsof -iTCP
COMMAND    PID   USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
httpd      776   root    4u  IPv6  17035      0t0  TCP *:http (LISTEN)
sshd       779   root    3u  IPv4  18920      0t0  TCP *:ssh (LISTEN)
sshd       779   root    4u  IPv6  18929      0t0  TCP *:ssh (LISTEN)
sshd       780   root    3u  IPv4  20514      0t0  TCP server:ssh->192.168.0.5:50081 (ESTABLISHED)
httpd      781 apache    4u  IPv6  17035      0t0  TCP *:http (LISTEN)
httpd      782 apache    4u  IPv6  17035      0t0  TCP *:http (LISTEN)
httpd      783 apache    4u  IPv6  17035      0t0  TCP *:http (LISTEN)
httpd      784 apache    4u  IPv6  17035      0t0  TCP *:http (LISTEN)
httpd      785 apache    4u  IPv6  17035      0t0  TCP *:http (LISTEN)
sshd       828   root    3u  IPv4  20580      0t0  TCP server:ssh->192.168.0.5:50082 (ESTABLISHED)
sshd      1125   root    3u  IPv4  23128      0t0  TCP server:ssh->192.168.0.5:50324 (ESTABLISHED)
sshd      1453   root    3u  IPv4  34525      0t0  TCP server:ssh->192.168.0.5:55322 (ESTABLISHED)
docker-pr 2834   root    4u  IPv6  50817      0t0  TCP *:documentum_s (LISTEN)
```


##3.4 UDPソケットを使用しているプロセスの表示方法(-iUDP)

```
[root@server ~]# lsof -iUDP
COMMAND PID   USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
chronyd 512 chrony    1u  IPv4  16709      0t0  UDP localhost:323
chronyd 512 chrony    2u  IPv6  16710      0t0  UDP localhost:323
chronyd 512 chrony    3u  IPv4  57134      0t0  UDP server:37067->routerida1.soprano-asm.net:ntp
```

##3.5 特定のポート番号を使用しているプロセスを絞り込む方法

```
TCPポート番号80を使用しているプロセスを表示する。
[root@server ~]# lsof -iTCP:80
COMMAND PID   USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
httpd   776   root    4u  IPv6  17035      0t0  TCP *:http (LISTEN)
httpd   781 apache    4u  IPv6  17035      0t0  TCP *:http (LISTEN)
httpd   782 apache    4u  IPv6  17035      0t0  TCP *:http (LISTEN)
httpd   783 apache    4u  IPv6  17035      0t0  TCP *:http (LISTEN)
httpd   784 apache    4u  IPv6  17035      0t0  TCP *:http (LISTEN)
httpd   785 apache    4u  IPv6  17035      0t0  TCP *:http (LISTEN)

"TCP"というキーワードを省略することも可能です。
[root@server ~]# lsof -i:80
COMMAND PID   USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
httpd   776   root    4u  IPv6  17035      0t0  TCP *:http (LISTEN)
httpd   781 apache    4u  IPv6  17035      0t0  TCP *:http (LISTEN)
httpd   782 apache    4u  IPv6  17035      0t0  TCP *:http (LISTEN)
httpd   783 apache    4u  IPv6  17035      0t0  TCP *:http (LISTEN)
httpd   784 apache    4u  IPv6  17035      0t0  TCP *:http (LISTEN)
httpd   785 apache    4u  IPv6  17035      0t0  TCP *:http (LISTEN)
```

##3.6 ポート番号の範囲を指定する方法

```
[root@server ~]# lsof -iTCP:1-1024
COMMAND PID   USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
httpd   768   root    4u  IPv6  20488      0t0  TCP *:http (LISTEN)
sshd    770   root    3u  IPv4  18548      0t0  TCP *:ssh (LISTEN)
sshd    770   root    4u  IPv6  18550      0t0  TCP *:ssh (LISTEN)
httpd   771 apache    4u  IPv6  20488      0t0  TCP *:http (LISTEN)
httpd   772 apache    4u  IPv6  20488      0t0  TCP *:http (LISTEN)
httpd   773 apache    4u  IPv6  20488      0t0  TCP *:http (LISTEN)
httpd   774 apache    4u  IPv6  20488      0t0  TCP *:http (LISTEN)
httpd   775 apache    4u  IPv6  20488      0t0  TCP *:http (LISTEN)
sshd    825   root    3u  IPv4  21607      0t0  TCP server:ssh->192.168.0.5:49583 (ESTABLISHED)
sshd    851   root    3u  IPv4  22628      0t0  TCP server:ssh->192.168.0.5:49584 (ESTABLISHED)

"TCP"というキーワードを省略することも可能です。
[root@server ~]# lsof -i:1-1024
COMMAND  PID   USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
systemd    1   root   49u  IPv6  16095      0t0  TCP *:sunrpc (LISTEN)
systemd    1   root   50u  IPv4  16096      0t0  TCP *:sunrpc (LISTEN)
chronyd  705 chrony    1u  IPv4  16224      0t0  UDP localhost:323
chronyd  705 chrony    2u  IPv6  16225      0t0  UDP localhost:323
sshd    1092   root    3u  IPv4  21620      0t0  TCP *:ssh (LISTEN)
sshd    1092   root    4u  IPv6  21629      0t0  TCP *:ssh (LISTEN)
sshd    1133   root    3u  IPv4  23145      0t0  TCP server:ssh->192.168.0.6:50237 (ESTABLISHED)
sshd    1162   root    3u  IPv4  23199      0t0  TCP server:ssh->192.168.0.6:50240 (ESTABLISHED)
sshd    1225   root    3u  IPv4  26212      0t0  TCP server:ssh->192.168.0.6:50292 (ESTABLISHED)
```


##3.7 特定のIPアドレスで絞り込む方法

```
[root@server ~]# lsof -i@192.168.0.100 -n
COMMAND  PID USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
sshd     780 root    3u  IPv4  20514      0t0  TCP 192.168.0.100:ssh->192.168.0.5:50081 (ESTABLISHED)
sshd     828 root    3u  IPv4  20580      0t0  TCP 192.168.0.100:ssh->192.168.0.5:50082 (ESTABLISHED)
sshd    1125 root    3u  IPv4  23128      0t0  TCP 192.168.0.100:ssh->192.168.0.5:50324 (ESTABLISHED)
sshd    1453 root    3u  IPv4  34525      0t0  TCP 192.168.0.100:ssh->192.168.0.5:55322 (ESTABLISHED)
```

##3.8 TCPの状態でソケットを絞り込む方法(-s)

TCPのソケットの状態として指定できるのは、以下のものがある。
CLOSED,  IDLE,  BOUND,  LISTEN,  ESTABLISHED,  SYN_SENT,  SYN_RCDV,  ESTABLISHED,  CLOSE_WAIT,  FIN_WAIT1,  CLOSING, LAST_ACK, FIN_WAIT_2, and TIME_WAIT


```
ESTABLISHED状態のソケットを表示する。
[root@server ~]# lsof -i -sTCP:ESTABLISHED
COMMAND PID USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
sshd    825 root    3u  IPv4  21607      0t0  TCP server:ssh->192.168.0.5:49583 (ESTABLISHED)
sshd    851 root    3u  IPv4  22628      0t0  TCP server:ssh->192.168.0.5:49584 (ESTABLISHED)

LISTEN状態のソケットを表示する。
[root@server ~]# lsof -iTCP -sTCP:LISTEN
COMMAND PID   USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
httpd   768   root    4u  IPv6  20488      0t0  TCP *:http (LISTEN)
sshd    770   root    3u  IPv4  18548      0t0  TCP *:ssh (LISTEN)
sshd    770   root    4u  IPv6  18550      0t0  TCP *:ssh (LISTEN)
httpd   771 apache    4u  IPv6  20488      0t0  TCP *:http (LISTEN)
httpd   772 apache    4u  IPv6  20488      0t0  TCP *:http (LISTEN)
httpd   773 apache    4u  IPv6  20488      0t0  TCP *:http (LISTEN)
httpd   774 apache    4u  IPv6  20488      0t0  TCP *:http (LISTEN)
httpd   775 apache    4u  IPv6  20488      0t0  TCP *:http (LISTEN)
```

##3.9 複数の条件で絞り込む方法(-a)

```console:プロセス名とIPv4ソケットのAND条件で絞り込む方法
[root@server ~]# lsof -c sshd -a -i4
COMMAND  PID USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
sshd    1092 root    3u  IPv4  21620      0t0  TCP *:ssh (LISTEN)
sshd    1133 root    3u  IPv4  23145      0t0  TCP server:ssh->192.168.0.6:50237 (ESTABLISHED)
sshd    1162 root    3u  IPv4  23199      0t0  TCP server:ssh->192.168.0.6:50240 (ESTABLISHED)
sshd    1225 root    3u  IPv4  26212      0t0  TCP server:ssh->192.168.0.6:50292 (ESTABLISHED)
```

```console:プロセス名とIPv6ソケットのAND条件で絞り込む方法
[root@server ~]# lsof -c sshd -a -i6
COMMAND  PID USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
sshd    1092 root    4u  IPv6  21629      0t0  TCP *:ssh (LISTEN)
```

```console:プロセス名とUNIXドメインソケットのAND条件で絞り込む方法
[root@server ~]# lsof -c sshd -a -U
COMMAND  PID USER   FD   TYPE             DEVICE SIZE/OFF  NODE NAME
sshd    1133 root    4u  unix 0xffff880031af7400      0t0 19429 socket
sshd    1162 root    4u  unix 0xffff880036ca3800      0t0 21823 socket
sshd    1225 root    4u  unix 0xffff88003294f000      0t0 26231 socket
```


##3.10 複数のFDを指定する方法(-d)
lsofで表示するFDについて、範囲を指定する方法と、複数のFDを指定する方法を説明します。

chronydが使用しているFD=1からFD=5を表示してみます。

```console:実行結果
[root@server ~]# lsof -c chronyd -a -d 1-5
COMMAND PID   USER   FD   TYPE             DEVICE SIZE/OFF  NODE NAME
chronyd 574 chrony    1u  IPv4              17429      0t0   UDP localhost:323
chronyd 574 chrony    2u  IPv6              17430      0t0   UDP localhost:323
chronyd 574 chrony    3r   CHR                1,9      0t0  1033 /dev/urandom
chronyd 574 chrony    5u  unix 0xffff8801355b6800      0t0 17435 /var/run/chrony/chronyd.sock
```

chronydが使用しているFD=1,2,3を表示してみます。

```console:実行結果
[root@server ~]# lsof -c chronyd -a -d 1,2,3
COMMAND PID   USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
chronyd 574 chrony    1u  IPv4  17429      0t0  UDP localhost:323
chronyd 574 chrony    2u  IPv6  17430      0t0  UDP localhost:323
chronyd 574 chrony    3r   CHR    1,9      0t0 1033 /dev/urandom
```




##3.11 ポート番号をサービス名ではなく数値で表示する方法(-P)

```
sshdが使用しているTCPポート番号を数値で表示する。
sshというサービス名ではなく22番のポート番号が表示(★)されていることがわかる。
[root@server ~]# lsof -c sshd -a -i -P
COMMAND PID USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
sshd    770 root    3u  IPv4  18548      0t0  TCP *:★22 (LISTEN)
sshd    770 root    4u  IPv6  18550      0t0  TCP *:★22 (LISTEN)
sshd    825 root    3u  IPv4  21607      0t0  TCP server:22->192.168.0.5:49583 (ESTABLISHED)
sshd    851 root    3u  IPv4  22628      0t0  TCP server:22->192.168.0.5:49584 (ESTABLISHED)
```

##3.12 ホスト名ではなくIPアドレスで表示する方法(-n)

```
-nオプションを指定して、lsofコマンドを実行する。ホスト名ではなくIPアドレス(★)で表示されていることがわかる。
[root@server ~]# lsof -c sshd -a -i -n
COMMAND  PID USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
sshd    1092 root    3u  IPv4  21620      0t0  TCP *:ssh (LISTEN)
sshd    1092 root    4u  IPv6  21629      0t0  TCP *:ssh (LISTEN)
sshd    1133 root    3u  IPv4  23145      0t0  TCP ★192.168.0.100:ssh->192.168.0.6:50237 (ESTABLISHED)
sshd    1162 root    3u  IPv4  23199      0t0  TCP ★192.168.0.100:ssh->192.168.0.6:50240 (ESTABLISHED)
sshd    1225 root    3u  IPv4  26212      0t0  TCP ★192.168.0.100:ssh->192.168.0.6:50292 (ESTABLISHED)

-nを指定しないと、ホスト名(●)で表示されてしまう。
[root@server ~]# lsof -c sshd -a -i
COMMAND  PID USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
sshd    1092 root    3u  IPv4  21620      0t0  TCP *:ssh (LISTEN)
sshd    1092 root    4u  IPv6  21629      0t0  TCP *:ssh (LISTEN)
sshd    1133 root    3u  IPv4  23145      0t0  TCP ●server:ssh->192.168.0.6:50237 (ESTABLISHED)
sshd    1162 root    3u  IPv4  23199      0t0  TCP ●server:ssh->192.168.0.6:50240 (ESTABLISHED)
sshd    1225 root    3u  IPv4  26212      0t0  TCP ●server:ssh->192.168.0.6:50292 (ESTABLISHED)
```


#4 ファイルを使用しているプロセスを表示する方法

```
rsyslogを起動する。
[root@server ~]# systemctl start rsyslog

/var/log/messagesファイルを使用しているプロセスを表示する。rsyslogdが使用していることがわかる。
[root@server ~]# lsof /var/log/messages
COMMAND   PID USER   FD   TYPE DEVICE SIZE/OFF     NODE NAME
rsyslogd 1232 root    3w   REG    8,3  1250226 35441017 /var/log/messages

rsyslogを停止する。
[root@server ~]# systemctl stop rsyslog

/var/log/messagesファイルを使用しているプロセスを表示する。rsyslogdは使用していないことがわかる。
[root@server ~]# lsof /var/log/messages
[root@server ~]#
```

#5 ユーザで絞り込む方法(-u)
##5.1 特定のユーザが使用しているファイルを表示する方法

```
apacheユーザが使用しているファイルを表示する。
[root@server ~]# lsof -u apache
COMMAND PID   USER   FD      TYPE             DEVICE SIZE/OFF     NODE NAME
httpd   771 apache  cwd       DIR                8,3     4096       64 /
httpd   771 apache  rtd       DIR                8,3     4096       64 /
httpd   771 apache  txt       REG                8,3   519432   503359 /usr/sbin/httpd
httpd   771 apache  mem       REG                8,3    61752    98860 /usr/lib64/libnss_files-2.17.so
httpd   771 apache  mem       REG                8,3    27704   503409 /usr/lib64/httpd/modules/mod_cgi.so
-以下、略-
```

##5.2 特定のユーザ以外のユーザが使用しているファイルを表示する方法

```
rootユーザ以外のユーザが使用しているファイルを表示する。
[root@server ~]# lsof -u ^root
COMMAND   PID TID    USER   FD      TYPE             DEVICE SIZE/OFF     NODE NAME
polkitd   701     polkitd  cwd       DIR                8,3     4096       64 /
polkitd   701     polkitd  rtd       DIR                8,3     4096       64 /
polkitd   701     polkitd  txt       REG                8,3   116320   514122 /usr/lib/polkit-1/polkitd
-以下、略-
```


#6 ファイルをオープンしているプロセスを表示する
##6.1 ディレクトリを再帰的にたどる方法(+D)

```
/var/log配下のファイルだけでなく、/var/log/journal,/var/log/audit,/var/log/tuned,/var/log/httpd配下の
ファイルをオープンしているプロセスについても表示されていることがわかる。
[root@server ~]# lsof +D /var/log/
COMMAND   PID   USER   FD   TYPE DEVICE SIZE/OFF     NODE NAME
systemd-j 383   root  mem    REG    8,3 33554432  1654143 /var/log/journal/60cacdd09caf4ec881306360130479b7/system.journal
systemd-j 383   root   18u   REG    8,3 33554432  1654143 /var/log/journal/60cacdd09caf4ec881306360130479b7/system.journal
auditd    485   root    4w   REG    8,3  3678981       75 /var/log/audit/audit.log
vmtoolsd  511   root    3w   REG    8,3   216562 33628643 /var/log/vmware-vmsvc.log
tuned     767   root    3w   REG    8,3    13258  2637674 /var/log/tuned/tuned.log
httpd     768   root    2w   REG    8,3    15095 19361768 /var/log/httpd/error_log
httpd     768   root    7w   REG    8,3    76452 19361763 /var/log/httpd/access_log
httpd     771 apache    2w   REG    8,3    15095 19361768 /var/log/httpd/error_log
httpd     771 apache    7w   REG    8,3    76452 19361763 /var/log/httpd/access_log
httpd     772 apache    2w   REG    8,3    15095 19361768 /var/log/httpd/error_log
httpd     772 apache    7w   REG    8,3    76452 19361763 /var/log/httpd/access_log
httpd     773 apache    2w   REG    8,3    15095 19361768 /var/log/httpd/error_log
httpd     773 apache    7w   REG    8,3    76452 19361763 /var/log/httpd/access_log
httpd     774 apache    2w   REG    8,3    15095 19361768 /var/log/httpd/error_log
httpd     774 apache    7w   REG    8,3    76452 19361763 /var/log/httpd/access_log
httpd     775 apache    2w   REG    8,3    15095 19361768 /var/log/httpd/error_log
httpd     775 apache    7w   REG    8,3    76452 19361763 /var/log/httpd/access_log
```

##6.2 ディレクトリを再帰的にたどらない方法(+d)

```
/var/log配下のファイルをオープンしているプロセスだけが表示されていることがわかる。
[root@server ~]# lsof +d /var/log/
COMMAND   PID USER   FD   TYPE DEVICE SIZE/OFF     NODE NAME
vmtoolsd  700 root    3w   REG    8,3   400186 33628643 /var/log/vmware-vmsvc.log
firewalld 737 root    3w   REG    8,3     5555 33628644 /var/log/firewalld
```


#7 リピートモードの使い方
chronydプロセス(-c)が使用するINETドメイン(-i)のソケットを2秒間隔(-r2)で監視してみます。
-mはマーカです。%Tは時刻を表示します。
以下の例では、3つの条件をAND条件で指定しています。

```
[root@server ~]# lsof -c chronyd -a -i -a -r2m====%T====
COMMAND PID   USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
chronyd 705 chrony    1u  IPv4  16224      0t0  UDP localhost:323
chronyd 705 chrony    2u  IPv6  16225      0t0  UDP localhost:323
====21:36:11====
COMMAND PID   USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
chronyd 705 chrony    1u  IPv4  16224      0t0  UDP localhost:323
chronyd 705 chrony    2u  IPv6  16225      0t0  UDP localhost:323
====21:36:13====
COMMAND PID   USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
chronyd 705 chrony    1u  IPv4  16224      0t0  UDP localhost:323
chronyd 705 chrony    2u  IPv6  16225      0t0  UDP localhost:323
====21:36:15====
```

#8 ソケットの各種状態を表示する方法

```
[root@server ~]# lsof -i4 -Tqs
COMMAND  PID   USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
systemd    1   root   50u  IPv4  16096      0t0  TCP *:sunrpc (LISTEN QR=0 QS=0)
chronyd  705 chrony    1u  IPv4  16224      0t0  UDP localhost:323 (QR=0 QS=0)
chronyd  705 chrony    3u  IPv4  41773      0t0  UDP server:52657->v157-7-235-92.z1d6.static.cnode.jp:ntp (QR=0 QS=0)
sshd    1092   root    3u  IPv4  21620      0t0  TCP *:ssh (LISTEN QR=0 QS=0)
sshd    1133   root    3u  IPv4  23145      0t0  TCP server:ssh->192.168.0.6:50237 (ESTABLISHED QR=0 QS=96)
sshd    1162   root    3u  IPv4  23199      0t0  TCP server:ssh->192.168.0.6:50240 (ESTABLISHED QR=0 QS=0)
sshd    1225   root    3u  IPv4  26212      0t0  TCP server:ssh->192.168.0.6:50292 (ESTABLISHED QR=0 QS=0)
```

#9 特定のFDを使っているプロセスを表示する方法

```console:FD=11を使っているプロセスの表示結果
[root@server ~]# lsof -d 11
COMMAND    PID    USER   FD      TYPE             DEVICE SIZE/OFF       NODE NAME
systemd      1    root   11r      REG                0,3        0 4026532019 /proc/swaps
systemd-j  379    root   11u  a_inode                0,9        0       7017 [signalfd]
systemd-u  404    root   11u  a_inode                0,9        0       7017 [eventpoll]
systemd-l  566    root   11u  netlink                         0t0      17425 KOBJECT_UEVENT
dbus-daem  570    dbus   11u     unix 0xffff8801355b3000      0t0      16743 /var/run/dbus/system_bus_socket
NetworkMa  625    root   11r  a_inode                0,9        0       7017 inotify
tuned      990    root   11u  a_inode                0,9        0       7017 [eventpoll]
master    1080    root   11uW     REG                8,3       33  101292464 /var/lib/postfix/master.lock
qmgr      1091 postfix   11r     FIFO                0,8      0t0      20678 pipe
ovsdb-ser 1184    root   11r     FIFO                0,8      0t0      20346 pipe
ovs-vswit 1196    root   11u      CHR                1,3      0t0       1028 /dev/null
```

```console:FD=11を使っているプロセスの表示結果
[root@server ~]# lsof -d 11,13
COMMAND    PID    USER   FD      TYPE             DEVICE SIZE/OFF       NODE NAME
systemd      1    root   11r      REG                0,3        0 4026532019 /proc/swaps
systemd-j  379    root   11u  a_inode                0,9        0       7017 [signalfd]
systemd-j  379    root   13u  a_inode                0,9        0       7017 [timerfd]
systemd-u  404    root   11u  a_inode                0,9        0       7017 [eventpoll]
systemd-l  566    root   11u  netlink                         0t0      17425 KOBJECT_UEVENT
systemd-l  566    root   13u  a_inode                0,9        0       7017 [timerfd]
dbus-daem  570    dbus   11u     unix 0xffff8801355b3000      0t0      16743 /var/run/dbus/system_bus_socket
dbus-daem  570    dbus   13u     unix 0xffff8801355b4800      0t0      17529 /var/run/dbus/system_bus_socket
NetworkMa  625    root   11r  a_inode                0,9        0       7017 inotify
NetworkMa  625    root   13r  a_inode                0,9        0       7017 inotify
tuned      990    root   11u  a_inode                0,9        0       7017 [eventpoll]
tuned      990    root   13r      CHR                1,9      0t0       1033 /dev/urandom
master    1080    root   11uW     REG                8,3       33  101292464 /var/lib/postfix/master.lock
master    1080    root   13u     IPv4              20541      0t0        TCP localhost:smtp (LISTEN)
qmgr      1091 postfix   11r     FIFO                0,8      0t0      20678 pipe
sshd      1109    root   13u      CHR                5,2      0t0       1121 /dev/ptmx
sshd      1134    root   13u      CHR                5,2      0t0       1121 /dev/ptmx
ovsdb-ser 1184    root   11r     FIFO                0,8      0t0      20346 pipe
ovsdb-ser 1184    root   13uW     REG                8,3        0     663926 /etc/openvswitch/.conf.db.~lock~
ovs-vswit 1196    root   11u      CHR                1,3      0t0       1028 /dev/null
ovs-vswit 1196    root   13w     FIFO                0,8      0t0      24152 pipe
```


#X 参考情報
[lsof の使い方](http://kiririmode.hatenablog.jp/entry/20081013/p1)
[知っておくべきUnixユーティリティー : lsof](https://yakst.com/ja/posts/4217)
[An lsof Primer](https://danielmiessler.com/study/lsof/#gs.aw0lYbM)
[Linux lsof command](https://www.computerhope.com/unix/lsof.htm)
[Linux:The Ultimate lsof (list open files)](http://www.geekpills.com/operating-system/linux/the-ultimate-lsof-list-open-files)
