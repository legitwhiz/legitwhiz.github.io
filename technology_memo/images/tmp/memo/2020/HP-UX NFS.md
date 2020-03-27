# [HPUX11.X]NFSの設定方法

## ■UID・GIDの一貫性を保つ

NFSを利用する前にサーバーとクライアントのユーザーID(UID)グループID(GID)を揃える必要があります。/etc/passwd,/etc/group

## ■NFSのモジュールの確認

NFSのカーネルモジュールが、カーネル内に構成されていることを確認します。

### ○HP-UX11.00/11iv1の場合

```
# kmsystem | grep -e nfs_core -e nfs_server -e nfs_client
```

### ○HP-UX11iv2/11iv3の場合

```
# kcmodule | grep -e nfs_core -e nfs_server -e nfs_clien
```

上記コマンドでステータスが"Y"(有効)であることを確認します。
また、SAM、kcwebでも確認できます。

## ■設定ファイル(nfsconf)の編集
・nfsconfファイルの下記パラメータ値を編集します。

`/etc/rc.config.d/nfsconf`

### ○パラメータ
`NFS_SERVER=1`
1に設定しサーバーを有効にします。0は無効です。

`NUM_NFSD=16`

サーバー上でnfsdデーモンが動作し、NFSが使用できます。
UDPNFS要求のためにCPU数の4倍か、この値のどちらか大きい値に設定されます。
UDPNFSは複数の独立したプロセスで動作します。
TCPNFS要求は単一マルチスレッドnfsdデーモンで処理されます。
この値はデフォルトが16で、更にTCP要求用に1つ多く起動し、17個のプロセスが動作することになります。

`PCNFS_SERVER=0`

WindowsとNFSの構成を組み、かつNFSサーバーにあるファイルのアクセス権を、Windowsユーザーが持っている場合のみ必要です。クライアントがwindowsなら起動する必要はありません。
※UNIXのみでNFSを組む場合は0に設定します。

`START_MOUNTD=1`

ブート時にrpc.mountdデーモンを自動起動します。　　
11.xではNFSサーバーで1にする必要がある。inetdデーモンで起動するのはサポートしておりません。

## ■NFSサーバーデーモンの起動
下記コマンドでNFSサーバーデーモンを起動します。　

```
# /sbin/init.d/nfs.server start
```

また、NFSサーバーデーモンを停止させる場合です。

```
# /sbin/init.d/nfs.server stop
```

## ■ファイルのエクスポート

NFSクライアントと共有するファイルを指定するため、/etc/exportsにエクスポートするファイルとアクセス制御を設定します。

### ○/etc/exportsの設定

/etc/exports(例)

```
/home-access=hosta:hostb  #hostaとhostbのみ読み取り書き込み可
/home-rw=hosta            #hostaのみ読み取り書き込み可。その他は読み取りのみ
/home-access=hosta,ro     #hostaのみ読み取り可。その他はアクセス不可
```

### ○エクスポートのオプション

`-ro`

読み取り専用でエクスポートします。

`-rw=hostname[:hostname]`

指定したホストに対してのみ読み取り/書き込みを許可します。

`-anon=uid`

未定義ユーザーから要求がきた場合、uidに指定されている権限を与えます。

`-root=hostname[:hostname]`

ルート権限を指定ホストのルートユーザーにのみ与えます。

`-access=client[:client]`

指定したクライアントにマウントアクセスを許可します。

`-async`

非同期書き込みを設定します。
※rootは-rootオプションで指定しない限りnobadyとして扱われます。

## ■エクスポートの通知

/etc/exportsに設定しただけでは反映されません。
exportfsコマンドを実行し、設定したエクスポート情報をrpc.mountdに通知します。

```
# exportfs -a
```

/etc/exportsにリストされているファイルを、全てエクスポートします。

```
# exportfs -ua　
```

エクスポートされているファイルをアンエクスポートします。
また、オプションなしで"exportfs"コマンドを実行すると、現在エクスポートされているファイルがリストされます。

## ■NFSサーバーの構成チェック

### ○NFSデーモンの確認

NFSサーバーデーモンが起動したことを確認します。
rpcinfoコマンドで登録済みRPCプログラムをリストします。

```
# rpcinfo -p <servername>
```

出力結果にmountd、nfsがあることを確認します。
出力されない場合には、NFSサーバーを再起動します。


```
# /sbin/init.d/nfs.server stop
# /sbin/init.d/nfs.server start
```

### ○エクスポート済みファイルの確認

エクスポート済みファイルにどのクライアントがアクセスできるかを確認します。

```
# showmount -e
```

必要なファイルやクライアントが表示されない場合は、/etc/exportsを確認後、exportfsコマンドの再実行します。

### ○エクスポートオプションの確認

エクスポートオプションを確認します。

```
# exportfs
```

### ○現在マウントしているクライアントの確認

実際にどのクライアントがマウントしているかを確認します。

```
# showmount-a
```

以上でサーバーの設定の終了です。


## ■設定ファイル(nfsconf)の編集

・nfsconfファイルの下記パラメータ値を編集します。
`/etc/rc.config.d/nfsconf`

### ○パラメータ
`NFS_CLIENT=1` ・・・1に設定しクライアントを有効にします。0は無効です。
`NUM_NFSD=16`・・・ブートプロセス中に起動される/usr/sbin/biod(ブロックI/Oデーモン)の数を指定します。デフォルトは16です。

### ■NFSサーバーデーモンの起動　

下記コマンドでNFSサーバーデーモンを起動します。　

```
# /sbin/init.d/nfs.client start
```

また、NFSサーバーデーモンを停止させる場合です。

```
# /sbin/init.d/nfs.client stop
```

## ■エントリの追加マウントするNFSファイルを指定します。

mountコマンドを使用することで、手動でマウントを行えますが、/etc/fstabを設定することで、システムブート時に自動的にマウントされます。

### ○/etc/fstabを設定する

(例)/etc/fstab 

```
severname:/home /home nfs defaults 0 0
```

左から順に下記項目を設定します。

・サーバー名とサーバーがエクスポートしているファイルです。ホスト名とパス名は「:」コロン区切ります。
・マウントポイント
・ファイルシステムタイプ
・マウントオプション・バックアップ頻度(0を指定します)
・fsckの順序(0を指定します)

### ○手動でマウントする

```
# mount servername:/home /home
```

マウントコマンドに「サーバー名：ディレクトリ」とマウントポイントを指定します。

```
# mount -aF nfs
```

/etc/fstabにリストされているnfsタイプのファイルシステムをマウントします。

## ■NFSクライアントの構成を確認

### ○NFSクライアントデーモンの確認

rpcbiod、rpc.lockd、rpc.statdが起動していることを確認します。

```
# ps-ef | grep -e rpc -e biod
```

### ○サーバーで使用可能なファイルシステム
どのファイルシステムが使用可能かを確認します。

```
# showmount -e <servername>
```

### ○マウントされていることを確認

現在マウントされているファイルシステムを表示します。

```
# mount -v
```

以上でクラインアントの構成は終了です。
