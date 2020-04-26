# Raspbian初期設定(RaspberryPi4)



Raspbian:10.3

kernel:4.19.97-v7l+ #1294



## 1. RasbianOS初期設定

NOOBSでOSインストール時にwifi設定を実施していると、OSにもその設定がされた状態でインストールされていました。

### 1.1.RasbianOSを最新の状態にする。

```
$ rpi-update
$ reboot
```



### 1.2. 次に、SSHの有効化

```
$ mkdir /boot/ssh
$ shutdown -r now
```



### 1.3. SSHでログイン

SSHにてユーザ `pi` 初期パスワード `raspberry`で接続



### 1.4. rootのパスワードを設定する

初期状態のラズベリーパイは、「root」にパスワードが設定されていません。

```
$ sudo passwd root
```



### 1.5. ログイン用ユーザーを追加

```
$ useradd  --group sudo -m -u <uid> <newuser>
```



### 1.6. ログイン用ユーザーのパスワード変更

```
$ passwd <newuser>
```


### 1.7. piユーザの削除

```
userdel -r pi
```



### 1.8. IPアドレス固定化

```
$ vi /etc/dhcpcd.conf

interface eth0
static ip_address=192.168.1.10/24
static routers=192.168.1.1

interface wlan0
static ip_address=192.168.1.30/24
static routers=192.168.1.1
```



### 1.9. SSH設定

セキュリティ向上のため、ポートを変更しrootでの直接ログインを拒否し、暗号化キーを有効化し、パスワード認証を無効化し、セッション有効時間を延長しています。※変更箇所のみ記載しております。

```
$ vi /etc/ssh/sshd_config

Port <PortNo>
PermitRootLogin no
PubkeyAuthentication yes
AuthorizedKeysFile      .ssh/authorized_keys .ssh/authorized_keys2
PasswordAuthentication no
ClientAliveInterval 1800
ClientAliveCountMax 3
```



### 1.10 暗号化キーの作成

```
$ ssh-keygen
Generating public/private rsa key pair.
Enter file in which to save the key (/home/<username>/.ssh/id_rsa):
Created directory '/home/<username>/.ssh'.
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /home/<username>/.ssh/id_rsa.
Your public key has been saved in /home/<username>/.ssh/id_rsa.pub.
The key fingerprint is:
SHA256:*************************************************** <username>@raspberrypi
The key's randomart image is:
+---[RSA 2048]----+
|OOOOOO           |
+----[SHA256]-----+
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys

```



### 1.11. IPアドレス固定化(無線LAN)

まずは、無線LANアクセスポイントを設定(アクセスポイントが複数ある場合)

```
$ vi /etc/wpa_supplicant/wpa_supplicant.conf
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1

network={
        ssid="<SSID1>"
        psk="<passphrase>"
}

network={
        ssid="<SSID2>"
        psk="<passphrase>"
}
```

次に無線LAN I/FにIPアドレスを定義しますが、アクセスポイント毎に割り当てIPアドレスを定義することができます。

```
$ vi /etc/dhcpcd.conf
interface wlan0
ssid <SSID1>
static ip_address=192.168.1.30/24
static routers=192.168.1.1
static domain_name_servers=192.168.1.1

ssid <SSID2>
static ip_address=192.168.11.30/24
static routers=192.168.11.1
static domain_name_servers=192.168.11.1
```



### 1.12. パッケージとOSの更新

```
$ apt update
$ apt upgrade
※upgrade実行時、保留が出たら以下を実施すること
$ apt -s dist-upgrade
$ apt upgrade
```



### 1.13. ファームウェアの更新

```
$ rpi-update  
$ reboot
```



### 1.14. 自動upgrede

aptコマンドで手動でupgradeするのは面倒なので、自動更新するパッケージを導入。

```
$ apt install -y unattended-upgrades
$ vi /etc/apt/apt.conf.d/50unattended-upgrades
Unattended-Upgrade::Origins-Pattern {
        "o=${distro_id},n=${distro_codename}";
        
```

※Unattended-Upgradeの次の行に `"o=${distro_id},n=${distro_codename}";` を追記する。



### 1.15. sudoers(piユーザ用)の削除

piユーザを削除しているので、問題はないと思うが念のためsudoers定義を削除

```
$ rm /etc/sudoers.d/010_pi-nopasswd
```



### 1.16. Timezone設定

```
$ raspi-config

```

`4 Localisation Options` を選択し、
`I2 Change Timezone` を選択。
`アジア` を選択。
`東京` を選択。
`了解` を選択。

### 1.17. NTP設定

```
$ timedatectl status
               Local time: 土 2020-03-21 14:35:07 JST
           Universal time: 土 2020-03-21 05:35:07 UTC
                 RTC time: n/a
                Time zone: Asia/Tokyo (JST, +0900)
System clock synchronized: yes
              NTP service: active
          RTC in local TZ: no
```

`NTP service`が `active`となっていれば、NTPサービスは起動状態なので自動起動設定はあえてやる必要はありません。



```
$ vi /etc/systemd/timesyncd.conf
[Time]
NTP=ntp.jst.mfeed.ad.jp
FallbackNTP=ntp.nict.jp time.google.com
```



### 1.18. Wifi接続元国設定

```
$ raspi-config
```

`4 Localisation Options` を選択し、
`I4 Change Wi-fi Country` を選択。
`JP Japan` を選択。
`了解` を選択。







### 1.19. NTFSインストール

```
$ apt -y install ntfs-3g
```

※Raspbian Lite10.3では既に入ってました。



### 1.20. USBディスクの追加

USBディスクを接続し、USB HDDのUUIDを調べます。

```
$ blkid
/dev/mmcblk0p1: LABEL_FATBOOT="RECOVERY" LABEL="RECOVERY" UUID="BED1-E8B9" TYPE="vfat" PARTUUID="00031adc-01"
/dev/mmcblk0p5: LABEL="SETTINGS" UUID="f3286ddd-6b11-4a1e-b780-32c39134818d" TYPE="ext4" PARTUUID="00031adc-05"
/dev/mmcblk0p6: LABEL_FATBOOT="boot" LABEL="boot" UUID="3CB5-EC8B" TYPE="vfat" PARTUUID="00031adc-06"
/dev/mmcblk0p7: LABEL="root" UUID="f319c423-f87b-4a99-8309-11173614c408" TYPE="ext4" PARTUUID="00031adc-07"
/dev/mmcblk0: PTUUID="00031adc" PTTYPE="dos"
/dev/sda1: LABEL="My Passport" UUID="C00EE4C60EE4B716" TYPE="ntfs" PTTYPE="atari" PARTLABEL="My Passport" PARTUUID="4638ed1e-9915-42f4-96b5-1491ff482e58"
```



自動マウントするため `fstab` に追記

```
$ mkdir /data
$ vi /etc/fstab
UUID="C00EE4C60EE4B716"    /data    ntfs-3g      async,auto,dev,exec,gid=33,rw,uid=33,umask=007    0    0
```


### 1.21. GPUメモリ割当最小化

ディスプレイを使用することはあまりなく、基本的にSSHでアクセスして設定を行いうためGPUメモリへの割当値を最小にします。(デフォルト64MBを最小の16MBに変更)

```
$ vi /boot/config.txt
gpu_mem=16
```

設定変更後に再起動すること。

### 1.22.Bluetooth無効化

使用しないラズパイの内蔵Bluetooth無効化します。

```
$ vi /boot/config.txt
dtoverlay=disable-bt
#dtoverlay=disable-wifi #無線LAN無効化も可能
```

これも設定変更後に再起動すること。

### 1.23. Ethernet LEDの無効化

```
$ vi /boot/config.txt
dtparam=eth_led0=14
dtparam=eth_led1=14
```

