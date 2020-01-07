# UNIX系クイックコマンドリファレンス

書いておいてすみませんが、私が作ったかなり古い資料(2012)でかつ調査しきれず抜けている箇所も散見されますが、ご容赦ください。


## 文字コード

| デフォルト文字コード | AIX       | HP-UX      | Solaris     | Linux(Debian系)Ubuntu8.04LTS | Linux(Red Hat系) | FreeBSD     |
| -------------------- | --------- | ---------- | ----------- | ---------------------------- | ---------------- | ----------- |
| デフォルト文字コード | Shift_JIS | Shift_JIS  | EUC-JP      | EUC-JP??? Ubuntu8.04は、UTF8 | UTF8(RHEL4以降)  | EUC-JP      |
| 言語                 | Ja-JP     | ja_JP.SJIS | ja_JP.eucJP | ja_JP.UTF-8                  | ja_JP.UTF-8      | ja_JP.eucJP |

　　

## パッケージ管理

| パッケージ                   | AIX                | HP-UX                    | Solaris        | Linux(Debian系)                                              | Linux(Red Hat系) | FreeBSD       |
| ---------------------------- | ------------------ | ------------------------ | -------------- | ------------------------------------------------------------ | ---------------- | ------------- |
| パッケージのインストール     | installp   -a      | swinstall                | pkgadd         | dpkg   -i [パッケージ]      apt-get install [パッケージ]     | rpm   -i         | pkg_add       |
| パッケージの削除             | installp   -u      | swremove                 | pkgrm          | パッケージを削除する(設定ファイルは残す)      dpkg -r [パッケージ]      パッケージを完全に削除する(設定ファイルも削除)      dpkg --purge [パッケージ] | rpm   -e         | pkg_delete    |
| パッケージの一覧             | lslpp   -L all     | swlist                   | pkginfo        | dpkg   -l                                                    | rpm   -qa        | pkg_info   -a |
| パッケージのファイル表示     | lslpp   -f fileset | swlist   -l file         | pkgchk   -l    | dpkg   -L [パッケージ]                                       | rpm   -ql        | pkg_info   -L |
| ファイルからのパッケージ検索 | lslpp   -w path    | swlist   -l file \| grep | pkgchk   -l -p | dpkg   -S [ファイル名]                                       | rpm   -qf        | pkg_info   -W |
| パッケージ情報のディレクトリ | /usr/lpp           | /var/adm/sw              | /var/sadm      |                                                              | /var/lib/rpm     | /var/db/pkg   |



## デバイス管理

| デバイス                                 | AIX                   | HP-UX                   | Solaris                                                      | Linux(Debian系) | Linux(Red Hat系)    | FreeBSD           |
| ---------------------------------------- | --------------------- | ----------------------- | ------------------------------------------------------------ | --------------- | ------------------- | ----------------- |
| Install devices for attached peripherals | cfgmgr   -v           | insf   -e               | drvconfig         devlinks       disks       tapes       ports |                 | /dev/MAKEDEV        | /dev/MAKEDEV      |
| デバイス削除                             | rmdev   -l            | rmsf                    | rem_drv                                                      |                 |                     |                   |
| デバイスドライバー                       | lscfg                 | lsdev      kcmodule -v  | prtconf   -D                                                 |                 | lsmod               |                   |
| CPU                                      | lsdev   -Cc processor | ioscan   -fnC processor | psrinfo   -v                                                 |                 | cat   /proc/cpuinfo | sysctl   hw.model |
| List Terminal                            | lsdev   -Cc tty       | ioscan   -fnC tty       | pmadm   -l                                                   |                 |                     |                   |
| ダイアグ(機器情報)                       | diag                  | stm                     | /usr/platform/`uname   -m`/sbin/prtdiag      ok test-all      /opt/SUNWvts/bin/sunvts | lspci           | lspci      pnpdump  | pciconf -l        |
| デバイス診断情報                         | lscfg                 | ioscan                  |                                                              |                 |                     |                   |
| ファームウェア                           | lscfg－ｖｌ           | machinfo                |                                                              |                 |                     |                   |
| CPUクロック速度                          | prtconf   -s          | machinfo                |                                                              |                 |                     |                   |
| 物理メモリサイズ                         | prtconf   -m          | machinfo                |                                                              |                 |                     |                   |
| CPUタイプ                                | prtconf   -c          | machinfo                |                                                              |                 |                     |                   |



## ネットワーク

| ネットワーク               | AIX                     | HP-UX                    | Solaris                                                      | Linux(Debian系)                             | Linux(Red Hat系)                                         | FreeBSD               |
| -------------------------- | ----------------------- | ------------------------ | ------------------------------------------------------------ | ------------------------------------------- | -------------------------------------------------------- | --------------------- |
| ネットワーク設定           | lsattr   -E -l inet0    | /etc/rc.config.d/netconf | /etc/hostname      /etc/nodename      /etc/netmasks      /etc/inet/*      /etc/defaultrouter | /etc/network/interfaces                     | /etc/sysconfig/network-script/*      /usr/sbin/netconfig | /etc/rc.conf          |
| hostsファイル              | /etc/hosts              | /etc/hosts               | /etc/inet/hosts      /etc/hosts                              | /etc/hosts                                  | /etc/hosts                                               | /etc/hosts            |
| ネームサービスの設定       | /etc/netsvc.conf        | /etc/nsswitch.conf       | /etc/nsswitch.conf      /etc/resolv.conf                     | /etc/nsswitch.conf      /etc/resolv.conf    | /etc/nsswitch.conf      /etc/resolv.conf                 | /etc/host.conf        |
| ネットワークデバイスの設定 | ifconfig   -a           | lanscan   -v             | ifconfig   -a                                                | ifconfig   -a      iwconfig -a(無線LAN)     | ifconfig   -a                                            | ifconfig   -a         |
| port開放                   | /etc/services           | /etc/services            | /etc/services                                                | /etc/services                               | /etc/services                                            | /etc/services         |
| NFS　exportsファイル       | /etc/exports            | /etc/exports             | /etc/dfs/dfstab                                              |                                             | /etc/exports                                             | /etc/exports          |
| Secondary IP Address       | ifconfig   en0 alias IP | ifconfig   lan0:1 IP     | ifconfig   hme0:1 IP up                                      | modprobe   ip_alias      ifconfig eth0:1 IP | modprobe   ip_alias      ifconfig eth0:1 IP              | ifconfig xl0 alias IP |
| リモートシェル             | remsh      rsh          | remsh                    | rsh                                                          | rsh                                         | rsh                                                      | rsh                   |

## ディスク

| ディスク                   | AIX                                       | HP-UX                       | Solaris                                                    | Linux(Debian系)                | Linux(Red Hat系)               | FreeBSD        |
| -------------------------- | ----------------------------------------- | --------------------------- | ---------------------------------------------------------- | ------------------------------ | ------------------------------ | -------------- |
| ファイルシステムテーブル   | /etc/filesystems                          | /etc/fstab                  | /etc/vfstab                                                | /etc/fstab                     | /etc/fstab                     | /etc/fstab     |
| ディスク利用状況           | df   -k                                   | bdf                         | df   -k                                                    | df   -k                        | df   -k                        | df   -k        |
| ディスク情報               | bootinfo   -s hdisk#                      | diskinfo   /dev/rdsk/c#d#t# | format   -d c#d#t#      format>current      format>inquiry | cat   /proc/ide/ide0/had/model | cat   /proc/ide/ide0/had/model | fdisk   -v ad0 |
| デバイスリスト             | lsdev   -C                                | /sbin/ioscan                | sysdef                                                     | cat /proc/devices              | cat /proc/devices              | -              |
| ディスクラベル             | lspv   -l hdisk#                          | pvdisplay   -v              | prtvtoc                                                    | fdisk   -l                     | fdisk   -l                     | disklabel      |
| ジャーナルファイルシステム | jfs      jfs2                             | vxfs                        | vxfs                                                       | ext3                           | ext3      reiserfs             | -              |
| fs表示                     | lsfs                                      |                             |                                                            |                                |                                |                |
| fs作成                     | /usr/sbin/crfs   -v jfs2 -d lv_name       | newfs                       |                                                            | mkfs                           | mke2fs                         |                |
| fsリスト                   | /usr/sbin/lsfs                            |                             |                                                            |                                |                                |                |
| fs変更                     | chfs                                      |                             |                                                            |                                | resize2fs                      |                |
| lvol表示                   | lslv                                      |                             |                                                            |                                | lvdisplay -C                   |                |
| lvol作成                   | mklv                                      |                             |                                                            |                                | lvcreate                       |                |
| lvolリスト                 | /usr/sbin/lsvg   -o\|/usr/sbin/lsvg -i -l |                             |                                                            |                                | lvscan      lvs                |                |
| lvol変更                   | /usr/sbin/extendlv                        |                             |                                                            |                                | lvchange      lvextend         |                |
| VG表示                     | lsvg   -l rootvg                          | vgdisplay   -v vg00         | vxprint   -l -g rootdg                                     | vgdisplay   -v      ※lvm2要    | vgdisplay   -v      vgs        | -              |
| VG作成                     | mkvg                                      | vgcreate                    | vxdg   init                                                | vgcreate      ※lvm2要          | vgcreate                       |                |
| VGリスト                   | lsvg                                      | vgscan                      |                                                            |                                | vgscan                         | vgscan         |
| VG変更                     | chlv                                      | lvchange                    | vxedit   set                                               | lvchange      ※lvm2要          | lvchange                       |                |
| PV作成                     | mkdev   -c disk -l hdisk#                 | pvcreate                    | vxdiskadd                                                  | pvcreate      ※lvm2要          | pvcreate                       | -              |
| PVリスト                   | lspv                                      | pvdisplay                   | vxprint   -dl                                              | pvdisplay      ※lvm2要         | pvdisplay      pvs             | vinum   ld     |
| PV変更                     | chpv                                      | pvchange                    |                                                            | pvchange      ※lvm2要          | pvchange                       | -              |
| スワップサイズの状態       | lsps   -a                                 | swapinfo   -a               | swap   -l                                                  | free                           | free                           | swapinfo       |
| スワップの有効化           | swapon   -a                               | swapon   -a                 | swap   -a                                                  |                                | swapon   -a                    | swapon   -a    |
| スワップのデバイス         | /dev/hd6                                  | /dev/vg00/lvol2             | /dev/vx/dsk/swapvol                                        |                                | /dev/sda2                      | /dev/ad0s1b    |



## 外部メディア

| 外部メディア                 | AIX       | HP-UX           | Solaris           | Linux(Debian系) | Linux(Red Hat系)         | FreeBSD    |
| ---------------------------- | --------- | --------------- | ----------------- | --------------- | ------------------------ | ---------- |
| リワインド・テープ・デバイス | /dev/rmt0 | /dev/rmt/0mn    | /dev/rmt/0        |                 | /dev/rst0                | /dev/rwt0d |
| フロッピードライブ           | /dev/rfd0 | -               | /dev/diskette     | /dev/fd         | /dev/fd0                 | /dev/fd0   |
| CD-ROMデバイス               | /dev/cd0  | /dev/dsk/c#d#t0 | /dev/dsk/c#d#t0p0 | /dev/cdrom      | /dev/cdrom(/dev/hdcなど) | /dev/acd0  |
| CD-ROMファイルシステム       | cdrfs     | cdfs            | hsfs              |                 | iso9660                  | cd9660     |



## 性能

| 性能               | AIX              | HP-UX                                   | Solaris                  | Linux(Debian系)                       | Linux(Red Hat系)   | FreeBSD             |
| ------------------ | ---------------- | --------------------------------------- | ------------------------ | ------------------------------------- | ------------------ | ------------------- |
| プロセスモニタ     | top      monitor | top      glance                         | prstat      top          | nice -10 top -d 2      top ※sysstat要 | top                | top                 |
| システム監視ツール | sar              | sar                                     | sar                      | sar      ※sysstat要                   | sar      {sysstat} | sa                  |
| 物理メモリの表示   | bootinfo   -r    | grep   Phys /var/adm/syslog/syslog.log* | prtconf   \| grep memory | free                                  | free               | sysctl   hw.physmem |
| 仮想メモリの状態   | vmstat           | vmstat                                  | vmstat                   | vmstat      ※sysstat要                | vmstat             | vmstat              |
| I/Oの状態          | iostat           | iostat                                  | iostat                   | iostat      ※sysstat要                | iostat             | iostat              |



## ディスク構成

| ディスク構成 | AIX            | HP-UX             | Solaris      | Linux(Debian系) | Linux(Red Hat系)  | FreeBSD    |
| ------------ | -------------- | ----------------- | ------------ | --------------- | ----------------- | ---------- |
|              | Partition      | logical   extents | sub   disk   |                 | logical   extents | sub   disk |
|              | Volume         | logical   volume  | Volume       |                 | logical   volume  | Volume     |
|              |                |                   | Plex         |                 |                   | Plex       |
|              | Volume   group | volume group      | disk   group |                 | volume   group    |            |



## カーネル,OS

| カーネル,OS              | AIX                                      | HP-UX                                               | Solaris                                   | Linux(Debian系)                                       | Linux(Red Hat系)                          | FreeBSD                                                  |
| ------------------------ | ---------------------------------------- | --------------------------------------------------- | ----------------------------------------- | ----------------------------------------------------- | ----------------------------------------- | -------------------------------------------------------- |
| カーネルファイル         | /usr/lib/boot/unix_up                    | /stand/vmunix                                       | /kernel/genunix                           | /boot/vmlinuz                                         | /boot/vmlinuz                             | /boot/kernel                                             |
| カーネルパラメータ       | lsattr   -E -l sys0                      | sysdef      kmtune⇒kctune      kmsystem             | sysdef   -i                               | sysctl   -a      ulimit -a                            | sysctl   -a                               | sysctl -a                                                |
| モジュールの表示         | genkex                                   | kmadmin   -s                                        | modinfo                                   | lsmod                                                 | lsmod                                     | kldstat                                                  |
| モジュールのアンロード   | -                                        | kmadmin   -U                                        | modunload                                 | modprobe                                              | rmmod                                     | kldunload                                                |
| モジュールのロード       |                                          | kmadmin   -L                                        | modload                                   | update-modules                                        | insmod                                    | kldload                                                  |
| モジュール設定ファイル   |                                          |                                                     |                                           | /etc/modules                                          |                                           |                                                          |
| システムコールのトレース | syscalls                                 | tusc                                                | truss                                     | strace                                                | strace                                    | truss      ktrace                                        |
| マシンタイプ             | uname   -m      bootinfo -m      prtconf | model      uname -m                                 | uname   -imp                              | uname   -m                                            | uname   -m                                | uname   -m                                               |
| ＯＳバージョン           | oslevel      uname -r                    | uname   -r                                          | uname   -r                                | uname   -r      cat /etc/lsb-release                  | uname   -r      cat /etc/redhat-release   | uname   -r                                               |
| 使用中のカーネル         | prtconf -k                               |                                                     |                                           |                                                       |                                           |                                                          |
| コアダンプファイル       | /var/adm/ras                             | /var/adm/crash                                      | /var/crash/`uname   -n`                   | /                                                     | -                                         | -                                                        |
| タイムゾーン             | /etc/environment      /etc/profile       | /etc/TIMEZONE                                       | /etc/TIMEZONE      /etc/default/init      | ln   -s /usr/share/zoneinfo/Asia/Tokyo /etc/localtime | /etc/sysconfig/clock                      | /etc/localtime                                           |
| ＮＴＰ設定               | /etc/ntp.conf      startsrc -s xntpd     | /etc/rc.config.d/netdaemons      /sbin/init.d/xntpd | /etc/inet/ntp.conf      /etc/init.d/xntpd | /etc/ntp.conf      ※ntp要                             | /etc/ntp.conf      /etc/rc.d/init.d/xntpd | /etc/rc.conf   {xntpd_enable="YES"}      /etc/rc.network |
| スタートアップスクリプト | /etc/rc                                  | /sbin/rc                                            | /etc/init.d                               |                                                       | /etc/rc.d/rc                              | /etc/rc                                                  |



## ランレベル

| ランレベル                   | AIX                                                          | HP-UX                                                        | Solaris                                                      | Linux(Debian系)        | Linux(Red Hat系)                             | FreeBSD                                                      |
| ---------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ | ---------------------- | -------------------------------------------- | ------------------------------------------------------------ |
| 現在のランレベル             | who   -r                                                     | who   -r                                                     | who   -r                                                     |                        | runlevel                                     | -                                                            |
| デフォルト・ランレベル       | init2                                                        |                                                              |                                                              | init2                  | init5                                        |                                                              |
| init 0                       | 将来オペレーティング・システムが使用するために予約。         | システム停止。/sbin/rc0.d   内にあるあらゆる停止（K）および起動（S）スクリプトが実行される。 | パワー・ダウン状態。この状態の時にだけ電源を切ることができる。 | 停止                   | システム停止                                 |                                                              |
| init 1                       | 将来オペレーティング・システムが使用するために予約。         | シングルユーザモードで、ファイルシステムがマウントされた状態。 | システム管理状態（シングル・ユーザー）。   / と /usr ファイル・システムだけがマウントされている。他のユーザーは、ログイン出来ない。 | シングルユーザーモード | シングルユーザーモード                       |                                                              |
| init 2                       | マルチユーザモード                                           | NFSなしのマルチユーザモード。                                | 通常の状態で、複数のユーザーがファイルシステムにアクセス出来る。NFSサーバー（syslog、RFSも）が動いていない。 | マルチユーザーモード   | ローカルマルチユーザモード（NFSなどはなし）  |                                                              |
| init 3                       | ユーザが定義。                                               | HP   CDEマルチユーザモード。NFSが使用可能。                  | マルチ・ユーザー状態（リソースがエキスポートされている）。通常の動作状態。 | init2に同じ            | フルマルチユーザモード（テキストコンソール） |                                                              |
| init 4                       | ユーザが定義。                                               | HP   VUEマルチユーザモード。HP-UX10.10以前の環境。           | 別のマルチ・ユーザー状態。現在使われていない                 | init2に同じ            | 未使用                                       |                                                              |
| init 5                       | ユーザが定義。                                               | 未定義。                                                     | ソフトウェア・リブート状態。デフォールトのブート・デバイス以外のデバイスを指定する。   インターラクティブなリブート状態。 reboot -a と同じ。 | init2に同じ            | フルマルチユーザモード（グラフィカル環境）   |                                                              |
| init 6                       | ユーザが定義。                                               | 未定義。                                                     | リブート。システムを行ったんレベル0に落し、マルチ・ユーザーで立ち上げる。 | 再起動                 | システム再起動                               |                                                              |
| init s                       | コマンドを保守モードに入るよう指示する。システムが別の実行レベルから保守モードに入ると、システム・コンソールだけが端末として使用される。 | シングルユーザモード。/sbin/rc0.d   内にあるあらゆる停止（K）および起動（S）スクリプトが実行される。 ※ワンポイント /sbin/rcn.d 内のファイルは、通常 /sbin/init.d   以下のファイルにシンボリックリンクしている。 | シングル・ユーザー状態。全てのファイルシステムがマウントされている。 |                        | シングルユーザーモード                       |                                                              |
| init S                       | コマンドを保守モードに入るよう指示する。システムが別の実行レベルから保守モードに入ると、システム・コンソールだけが端末として使用される。 | S（大文字のS)だと、システムコンソールの機能は、このコマンドを実行したログイン中の端末に切り替わり   root で自動ログインした仮想システムコンソールとなる。 | シングル・ユーザー状態。全てのファイルシステムがマウントされている。 |                        |                                              |                                                              |
| シングルユーザモードへの切替 | shutdown   -Fm                                               | ISL>   hpux -is boot /stand/vmunix      HPUX> boot -is vmunix      ？shutdown -r | shudown -y -g0 -iS                                           |                        |                                              | 電源を入れ、Boot:という画面が出たらすぐに、-sと入力します。         Boot: -s |



## ランレベルと rcスクリプト

| ランレベルと   rcスクリプト        | AIX                                                          | HP-UX        | Solaris                   | Linux(Debian系)                                              | Linux(Red Hat系)  | FreeBSD |
| ---------------------------------- | ------------------------------------------------------------ | ------------ | ------------------------- | ------------------------------------------------------------ | ----------------- | ------- |
| システムの動作状態規定             | /etc/inittab                                                 | /etc/inittab | /etc/inittab              |                                                              |                   |         |
| スクリプト格納フォルダ             | /etc/init.d/                                                 | /sbin/init.d | /sbin/init.d              | /etc/init.d/                                                 | /etc/rc.d/init.d/ |         |
| ランレベルS                        |                                                              | /sbin/rcS    | /sbin/rcS,   /etc/rcS.d/* | /etc/rcS.d/                                                  |                   |         |
| ランレベル0                        | /etc/rc.d/rc0.d                                              | /sbin/rc0    | /sbin/rc0,   /etc/rc0.d/* | /etc/rc0.d/                                                  | /etc/rc.d/rc0.d/  |         |
| ランレベル1                        | /etc/rc.d/rc1.d                                              | /sbin/rc1    | /sbin/rc1,   /etc/rc1.d/* | /etc/rc1.d/                                                  | /etc/rc.d/rc1.d/  |         |
| ランレベル2                        | /etc/rc.d/rc2.d                                              | /sbin/rc2    | /sbin/rc2,   /etc/rc2.d/* | /etc/rc2.d/                                                  | /etc/rc.d/rc2.d/  |         |
| ランレベル3                        | /etc/rc.d/rc3.d                                              | /sbin/rc3    | /sbin/rc3,   /etc/rc3.d/* | /etc/rc3.d/                                                  | /etc/rc.d/rc3.d/  |         |
| その他                             | /etc/rc.tcpip      inittabからTCP/IP   daemonsに関連するデーモンを起動する。 |              |                           | /etc/init.d/以下にシェルスクリプトを配置      update-rc.d <スクリプト名> default をrootで実行      /etc/rc*.d/以下にシンボリックリンクが自動生成される |                   |         |
| デーモン起動スクリプト登録コマンド |                                                              |              |                           |                                                              | chkconfig         |         |



## 一般操作

| 一般操作                  | AIX                                                          | HP-UX                                                        | Solaris                                                      | Linux(Debian系)                                              | Linux(Red Hat系)                                             | FreeBSD                             |
| ------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ | ----------------------------------- |
| パスワードファイル        | /etc/passwd      /etc/security/passwd                        | /etc/passwd      /tcb/files/auth/r/root                      | /etc/passwd         /etc/shadow                              | /etc/passwd      /etc/shadow                                 | /etc/passwd      /etc/shadow                                 | /etc/passwd      /etc/master.passwd |
| rootパスワードリカバリ    | boot   from CD/Tape      Installation/Maintenance      Start Limited Shell      getrootfs hdisk0      vi /etc/security/passwd | >boot      Interact with IPL ? Y      ISL>hpux -iS      passwd root | boot   cdrom -s      mkdir /tmp/a      mount /dev/c0t0d0s0 /tmp/a      vi /tmp/a/etc/shadow |                                                              | {lilo}      control-x      linux S      passwd root            {grub}      c      kernel vmlinuz-2.4.9-13 single   ro   root=/dev/hda8      initrd /initrd-2.4.9-13.img      boot      passwd root | ok   boot -s      passwd root       |
| ユーザの作成              | mkuser                                                       | useradd                                                      | useradd                                                      | adduser                                                      | useradd                                                      | adduser                             |
| ユーザの削除              | rmuser                                                       | userdel                                                      | userdel                                                      | deluser                                                      | userdel                                                      | rmuser                              |
| ユーザリスト              | lsuser   -f ALL                                              | logins                                                       | logins                                                       | -                                                            | -                                                            | -                                   |
| グループの作成            | mkgroup                                                      |                                                              |                                                              | groupadd                                                     |                                                              |                                     |
| グループの削除            | rmgroup                                                      |                                                              |                                                              | groupdel                                                     |                                                              |                                     |
| グループファイル          | /etc/group      /etc/security/group                          | /etc/group      /etc/logingroup                              | /etc/group                                                   | /etc/group                                                   | /etc/group                                                   | /etc/group                          |
| ホスト独自ＩＤ            | hostid                                                       | uname   -i                                                   | hostid                                                       | hostid                                                       | hostid                                                       | -                                   |
| 設定ツール                | smit                                                         | sam                                                          | admintool                                                    | debian   : dpkg-reconfigure -a      ubuntu : dpkg-reconfigure -a | linuxconf      fedora : setup      vine : setup              |                                     |
| X Window System設定ツール |                                                              |                                                              |                                                              | fedoa   : Xconfigurator      debian : dpkg-reconfigure xserver-xorg      ubuntu : dpkg-reconfigure xserver-xorg      turbo : turboxcfg |                                                              |                                     |
| リモートログインの許可    | /etc/security/user      {rlogin=true}                        | /etc/securetty      {console}                                | /etc/default/login      {CONSOLE=/dev/console}               | /etc/securetty      {ttyp1}                                  | /etc/securetty      {ttyp1}                                  | /etc/ttys         {secure}          |



## シスログ

| シスログ                           | AIX                                                          | HP-UX                      | Solaris                    | Linux(Debian系)                        | Linux(Red Hat系)                                    | FreeBSD           |
| ---------------------------------- | ------------------------------------------------------------ | -------------------------- | -------------------------- | -------------------------------------- | --------------------------------------------------- | ----------------- |
| シスログ                           | /var/adm/ras/syslog.out      ※syslog.confの設定をしないと出力なし      errptにてOSのログ参照。 | /var/adm/syslog/syslog.log | /var/adm/messeges          | /var/log/messages      /var/log/syslog | /var/log/messages                                   | /var/log/messages |
| システム・ログ・デーモン・プロセス | /usr/sbin/syslogd   -N                                       | /etc/syslogd               |                            | /sbin/syslogd                          | /sbin/syslogd                                       |                   |
| シスログ設定ファイル               | /etc/syslog.conf                                             | /etc/syslog.conf           |                            | /etc/syslog.conf                       | /etc/sysconfig/syslog                               |                   |
| syslogdの起動                      | startsrc   -s syslogd                                        |                            | /etc/init.d/syslog   start | /etc/init.d/sysklogd start             | /etc/rc.d/syslogd   start      service syslog start |                   |
| syslogdの停止                      | stopsrc   -s syslogd                                         |                            | /etc/init.d/syslog   stop  | /etc/init.d/sysklogd stop              | /etc/rc.d/syslogd   stop      service syslog stop   |                   |
| syslogdの稼働確認                  | lssrc   -g ras                                               |                            |                            | ps -ef \| grep syslogd                 |                                                     |                   |
| syslogdの再起動                    | refresh   -s syslogd                                         | kill   -HUP syslogd PID    |                            | /etc/init.d/sysklogd restart           | /etc/rc.d/init/syslog   restart                     |                   |



## OS起動・停止

| OS起動・停止 | AIX                                 | HP-UX                                                 | Solaris                | Linux(Debian系)                       | Linux(Red Hat系)                      | FreeBSD |
| ------------ | ----------------------------------- | ----------------------------------------------------- | ---------------------- | ------------------------------------- | ------------------------------------- | ------- |
| OS起動       | boot                                |                                                       |                        |                                       |                                       |         |
| OS停止       | shutdown   -h now      shutdown -F  | /usr/sbin/shutdown   -h now      /usr/sbin/reboot -h  | shutdown   -i0 -g0 -y0 | /sbin/shutdown   -h      /sbin/halt   | /sbin/shutdown   -h      /sbin/halt   |         |
| OS再起動     | shutdown   -r now      shutdown -Fr | /usr/sbin/shutdown   -r now      /usr/sbin/reboot now | shutdown   -i6 -g0 -y0 | /sbin/shutdown   -r      /sbin/reboot | /sbin/shutdown   -r      /sbin/reboot |         |



## ファイルシステム

| ファイルシステム     | AIX                     | HP-UX                          | Solaris                              | Linux(Debian系)                | Linux(Red Hat系)               | FreeBSD                 |
| -------------------- | ----------------------- | ------------------------------ | ------------------------------------ | ------------------------------ | ------------------------------ | ----------------------- |
| Rootファイルシステム | /           {/dev/hd4}  | /          {/dev/vg00/lvol1}   | /  {/dev/vx/dsk/rootvol}             | /                  {/dev/hda1} | /                  {/dev/sda1} | /         {/dev/ad0s1a} |
| Homeディレクトリ     | /home    {/dev/hd1}     | /home      {/dev/vg00/lvol4}   | /export/home      {/dev/vx/dsk/home} | /home                          | /home                          |                         |
| tmpディレクトリ      | /tmp      {/dev/hd3}    | /tmp       {/dev/vg00/lvol6}   | /tmp        {/dev/vx/dsk/swapvol}    | /tmp                           | /tmp                           |                         |
| usrディレクトリ      | /usr       {/dev/hd2}   | /usr         {/dev/vg00/lvol7} | /usr                                 | /usr                           | /usr                           | /usr    {/dev/ad0s1f}   |
| varディレクトリ      | /var      {/dev/hd9var} | /var       {/dev/vg00/lvol8}   | /var                                 | /var                           | /var                           | /var    {/dev/ad0s1e}   |



## セキュリティ

| セキュリティ     | AIX                                 | HP-UX | Solaris         | Linux(Debian系) | Linux(Red Hat系) | FreeBSD |
| ---------------- | ----------------------------------- | ----- | --------------- | --------------- | ---------------- | ------- |
| ログイン成功履歴 | last                                | last  | last            |                 | last             |         |
| ログイン失敗履歴 | last   -f /etc/security/failedlogin | lastb | [※](#Sheet3!A1) |                 |                  |         |



## パワードメイン

| パワードメイン             | AIX                          | HP-UX                        | Solaris                                 | Linux(Debian系) | Linux(Red Hat系) | FreeBSD |
| -------------------------- | ---------------------------- | ---------------------------- | --------------------------------------- | --------------- | ---------------- | ------- |
| パーティション技術         | マイクロ・パーティショニング | Virtual   Server Environment | Solaris   Container                     |                 |                  |         |
| ハードウェアパーティション | PPAR                         | nPars(nPartitions)           | DSD(Dynamic   System Domains)           |                 |                  |         |
| パーティションの最小単位   | システムボード               | セル・ボード                 | システム・ボード                        |                 |                  |         |
| 動作中の構成変更           |                              | ○                            | ○                                       |                 |                  |         |
| パーティション間の隔離性   |                              | ○                            | △      (拡張ボード共有時は隔離されない) |                 |                  |         |
| バックプレーンの隔離性     |                              | ○                            | ×                                       |                 |                  |         |
| ソフトウェアパーティション | LPAR                         | vPars                        | LDOM                                    |                 |                  |         |
| システムマネージャ         |                              |                              | SMS                                     |                 |                  |         |
| システムコントローラ       | HMC                          | MP                           | SC                                      |                 |                  |         |
| 動的システムドメイン       |                              |                              | Dynamic   Reconfiguration(DR)           |                 |                  |         |



## ソフトウェアRAID

| ソフトウェアRAID   | AIX                                                         | HP-UX                           | Solaris                                   | Linux(Debian系) | Linux(Red Hat系)                                            | FreeBSD |
| ------------------ | ----------------------------------------------------------- | ------------------------------- | ----------------------------------------- | --------------- | ----------------------------------------------------------- | ------- |
| ミラーディスク作成 | mirrorvg   -s rootvg hdisk1      (hdisk0にhdisk1を追加する) | lvextend   -m 1 /dev/vg01/lvol1 | metainit   volume-name -m  submirror-name |                 | mdadm   -C /dev/md0 -ayes -l raid1 -n 2 /dev/hdb1 /dev/hdb2 |         |
| ミラーの同期       | sysncvg   -v rootvg                                         |                                 |                                           |                 |                                                             |         |