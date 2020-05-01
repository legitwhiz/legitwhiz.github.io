

# デバイス同士でファイルを同期、共有できる「Syncthing」

自分用にファイル共有できるようにRaspberryPi4とNextCloudを構築したが、サーバを構築しなくともファイル共有も同期もできるソフトウェアがあることを発見し試してみました。
ストレージサービスだと、どうしてもセキュリティ面が不安ですし、漏洩ニュースなどを見ると不安ですよね。
なので、この「Syncthing」を使用したことで操作感的にもセキュリティ的な面でも問題ないか検証してみました。

## 1. Syncthingとは

> Syncthingは継続的なファイル同期プログラムです。 2つ以上のコンピューター間でファイルをリアルタイムで同期し、覗き見から安全に保護します。あなたのデータはあなた自身のデータであり、あなたはそれが保存されている場所、それが第三者と共有されているかどうか、そしてそれがインターネット上でどのように送信されるかを選択する価値があります。

[Syncthing公式HP](https://syncthing.net/)

## 2. クライアントアプリ

### 2.1. Windows用のクライアントアプリ(SyncTrayzor)導入

Windows用のクライアントアプリとして、SyncTrayzorが公開されています。

https://github.com/canton7/SyncTrayzor/releases にアクセスし、「[SyncTrayzorSetup-x86.exe](https://github.com/canton7/SyncTrayzor/releases/download/v1.1.24/SyncTrayzorSetup-x86.exe)」をダウンロードしてください。ちなみに私が検証してみたタイミングでは、Version1.1.24.0でした。

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/Syncthing/SyncTrayzor_Win10_001.png" width="640">

[I accept the agreement]を選択し[Next]をクリックする。

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/Syncthing/SyncTrayzor_Win10_002.png" width="640">

インストールするディレクトリを入力(デフォルトで以下が入力されている)し、[Next]をクリックする。

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/Syncthing/SyncTrayzor_Win10_003.png" width="640">

メニューフォルダを入力(デフォルトで以下が入力されている)し、[Next]をクリックする。

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/Syncthing/SyncTrayzor_Win10_004.png" width="640">

以下画面で[Create a desktop shortcut]のチェックボックスにチェックを付け、[Next]をクリックする。

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/Syncthing/SyncTrayzor_Win10_005.png" width="640">

インストールの設定が正しいことを確認し、[Install]をクリックする。

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/Syncthing/SyncTrayzor_Win10_006.png" width="640">

以下画面で[Finish]をクリックする。

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/Syncthing/SyncTrayzor_Win10_007.png" width="640">

SyncTrayzorが起動すると以下のように[Windowsセキュリティの重要な警告]が出力されますので、ネットワーク環境に合わせたセキュリティ設定を設定し[アクセスを許可する]をクリックする。

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/Syncthing/SyncTrayzor_Win10_008.png" width="640">

SyncTrayzorの初回起動時には、レポート許可を確認する画面が出力されますので応えます。

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/Syncthing/SyncTrayzor_Win10_009.png" width="640">

SyncTrayzorの左側がこのクライアントの共有ディレクトリに関する情報、右側にクライアントの情報が

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/Syncthing/SyncTrayzor_Win10_010.png" width="640">

Default Folderをクリックすると詳細が表示されます。

フォルダーのパスは、[C:\User\<ユーザ>\Sync]となるようです。

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/Syncthing/SyncTrayzor_Win10_011.png" width="640">

### 2.2. Android用クライアントアプリ(Syncthing)導入

GooglePlay から[Syncthing](https://play.google.com/store/apps/details?id=com.nutomic.syncthingandroid&hl=ja)をインストールします。

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/Syncthing/SyncTrayzor_Android_001.png" width="440">

Syncthingを初回起動すると、以下のように初期設が画面が出力されるので[続行]を選択する。

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/Syncthing/SyncTrayzor_Android_002.png" width="440">

次にストレージ許可を求めてきますので、[アクセス許可を付与する]を選択した後に[続行]を選択する。

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/Syncthing/SyncTrayzor_Android_003.png" width="440">

次に位置情報アクセス許可を求める画面に遷移しますので、状況に合わせ[アクセス許可を付与する]を選択し、[完了]を選択する。

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/Syncthing/SyncTrayzor_Android_004.png" width="440">

初回起動のみバッテリー最適化画面が出力されるため、環境・都合に合わせ選択する。

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/Syncthing/SyncTrayzor_Android_005.png" width="440">

次にバックグラウンド実行許可を確認するメッセージが出力されますので、環境に合わせて選択します。

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/Syncthing/SyncTrayzor_Android_006.png" width="440">

起動後に画面左側のメニューボタンを押すと以下メニュー画面が出力されるので、[デバイスIDを表示]を選択する。

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/Syncthing/SyncTrayzor_Android_007.png" width="440">

出力されたデバイスIDを控えます。

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/Syncthing/SyncTrayzor_Android_008.png" width="440">

Windows10クライアントにてAndroidクライアントを[接続先デバイスを追加]ボタンを押し登録します。

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/Syncthing/SyncTrayzor_access_001.png" width="640">

デバイスIDに先程、控えたIDを入力し自分で分かりやすい[デバイス名]を入力し[保存]を選択します。

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/Syncthing/SyncTrayzor_access_002.png" width="640">

登録すると以下のように接続先デバイスが表示されます。

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/Syncthing/SyncTrayzor_access_003.png" width="640">

するとAndroid側接続を許可するか拒否の画面が出力されますので、[許可]を選択します。

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/Syncthing/SyncTrayzor_Android_010.png" width="440">

### 2.3. Linux用クライアントアプリ(SyncTrayzor)導入

RaspbianにSyncTrayzor(2020/04/30時点ではVer1.4.2)します。

```
# curl -s https://syncthing.net/release-key.txt | sudo apt-key add -
# echo "deb https://apt.syncthing.net/ syncthing stable" | tee /etc/apt/sources.list.d/syncthing.list
# apt update
# apt -y install syncthing
```

自動起動設定

```
# systemctl enable syncthing@${USER}.service
# systemctl start syncthing@${USER}.service
```



現状、私のRaspberryPi4に導入しているRaspbianはGUIをインストールしていないので設定ファイルにて、設定していきます。

```
$ vi ~/.config/syncthing/config.xml
<修正前>
<gui enabled="true" tls="false" debugging="false">
    <address>127.0.0.1:8384</address>
    <apikey>XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX</apikey>
    <theme>default</theme>
</gui>
<修正後>
<gui enabled="true" tls="false" debugging="false">
    <!-- ここを0.0.0.0に修正 -->
    <address>0.0.0.0:8384</address>
    <apikey>XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX</apikey>
    <theme>default</theme>
</gui>

```

接続設定にWindows10を追加しました。

id="XXXXXX"部分は、Windows10でIDを表示させてコピーしてください。

```
<device id="XXXXXX" name="MyPC" compression="metadata" introducer="false" skipIntroductionRemovals="false" introducedBy="">
     <address>dynamic</address>
     <paused>false</paused>
     <autoAcceptFolders>false</autoAcceptFolders>
     <maxSendKbps>0</maxSendKbps>
     <maxRecvKbps>0</maxRecvKbps>
     <maxRequestKiB>0</maxRequestKiB>
</device>
```

また、同期するためのフォルダに接続先を許可する設定を追加します。

```
    <folder id="default" label="Default Folder" path="/home/${USER}/Sync" type="sendreceive" rescanIntervalS="300" fsWatcherEnabled="true" fsWatcherDelayS="10" ignorePerms="false" autoNormalize="true">
        <filesystemType>basic</filesystemType>
        <device id="<自ホストのID>" introducedBy=""></device>
        <device id="接続先のID" introducedBy=""></device>
        <minDiskFree unit="%">1</minDiskFree>
    </folder>
```

設定を変更した際は、 `syncthing@${USER}.service` を再起動すること。



## 3. 使用感

なお、ルーターのポート開放する必要もなく容量も無制限なので、本当に気軽にファイル共有ができますね。
友達とのファイル共有でも活用できそうですが、自分用のバックアップに使ってもよさそうですね。
Linux版のSyncTrayzorもあるのでRaspberryPiに導入してUSBディスクでも接続しておけば、簡単クラウドストレージができあがりですね。

前回、書いた[NextCloudをWindows10でネットワークマウント(WebDAV)](https://qiita.com/legitwhiz/items/9ec7d672874ca8ce35bb)に比べてサーバ構築やドメイン取ったり、証明書取ったりもせずできる点を考えれば、SyncTrayzorのほうが簡単ですね。

また、中継サーバーを通さず直接端末間でファイルを同期することから、情報漏洩する心配も少ないので安心して使えますね。
