# Raspberry Pi4をAmazonプライムビデオ専用機に

自分用のファイルサーバで使用していた「Raspberry Pi4」ですが
結局あまり使用することもないので、テレビに繋いで「Amazonプライムビデオ」を見れるように
作り変えることにしました。

「Raspberry Pi4」をメディアプレイヤーとして構築しなければならないのですが、ググると「OSMC」にて構築するのを見かけますが、「Raspberry Pi4」には対応していないようで「LibreELEC」を導入しても可能なようですが、最新のブラウザのアドオンが対応していないことが判明(2020/11/01現在)。

では、何を導入するか調査していると「Raspberry Pi4」にAndroidOSである「LineageOS17.1(Android10)」にて「Amazonプライムビデオ」も「Youtube」も視聴できるようです。

## 1.Raspberry PiにLineageOSを導入

### 1.1 LineageOSとは

「LineageOS」とは、Androidをベースとした、スマートフォンやタブレット用のオープンソースなオペレーティングシステムであり、「Raspberry Pi4」にも対応している。

### 1.2. LineageOS準備

私の所持する「Raspberry Pi4」にはNoobsというOSのインストーラーを含んだ、Bootloaderを導入しているためMicroSDカードをPCに接続しフォーマットした後に[KonstaKANG.com](https://konstakang.com/devices/rpi4/LineageOS17.1/)から「lineage-17.1-YYYYMMDD-UNOFFICIAL-KonstaKANG-rpi4.zip」をダウンロードし、解凍するとimgファイルができます。

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/amazon_prime_video/amazon_prime_video001.png" width="640">

このimgファイルをMicroSDカードに焼くには、[balenaEtcher](https://www.balena.io/etcher/)を使います。

[Select images]を押し、先程解凍したimgファイルを指定し、[Select drive]にて「LineageOS」をインストールするMicroSDカードを指定し、[Flash!]を押す。

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/amazon_prime_video/amazon_prime_video002.png" width="640">

### 1.3. LineageOSインストール

Raspberry pi4にモニター、キーボード、マウスを接続し、MicroSDカードとUSBメモリを「Raspberry Pi4」に接続し起動します。

Raspberry pi4を起動すると初期セットアップが始まりますので、言語では「日本語」を選択し、Wifiの設定、Timezone、日付と時刻を設定します。

その後、LineageOSが起動します。

## 2.カスタムOSインストール

LineageOSだけでは、GooglePlayからアプリが導入できません。
というかGooglePlayを導入済みのカスタムOSをインストールし直すのが本項目の目的となります。

### 2.1 カスタムOSダウンロード

これまでの手順では、Androidは起動するもののGooglePlayが導入されていないためアプリが導入できません。
なので、カスタムOSにすべく[「Goolge関連アプリを導入するためのパッチ(open_gapps-arm-10.0-pico-YYYYMMDD.zip)」](https://opengapps.org/?arch=arm&api=10.0&variant=tvstock)をダウンロード(Platform:ARM、Android:10.0、Variant:picoを選択)。

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/amazon_prime_video/amazon_prime_video003.png" width="640">

カスタムROM導入するにあたりリカバリーモードに移行しますが、[「リカバリモードから通常モードに戻すためのパッチ(lineage-17.1-rpi-recovery2boot.zip)」](https://androidfilehost.com/?w=search&s=lineage-17.1&type=files&sort_by=downloads&sort_dir=DESC&page=1)をダウンロード。

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/amazon_prime_video/amazon_prime_video004.png" width="640">

OSを導入するMicroSDカードとは別にUSBメモリを用意し「Goolge関連アプリを導入するためのパッチ」と「リカバリモードから通常モードに戻すためのパッチ」をzipのままコピーします。

### 2.2 カスタムOSインストール準備

カスタムOSをインストールするためには、LineageOSを「開発者モード」「RootAccess許可」「Terminal有効化」にする必要があります。また、パッチを導入したUSBメモリをRaspberryPiに差しておいてください。

#### (1) 開発者モードを有効化

設定画面(初期画面から右にスライドし、右下の歯車を押す)→「タブレット情報※1」に移動し、「ビルド番号」欄を5回以上クリックしてください。開発者モード有効化されるとその旨のメッセージが出力されます。

※1タブレット情報は、システムより下の画面最下部に表示されます。また画面によりドラッグしないと見えないので注意してください。

#### (2) RootAccess有効化

「設定画面」→「開発者向けオプション」→「RootAccess」を有効化します。

#### (3) Terminal有効化

「設定画面」→「開発者向けオプション」→「ローカルターミナル」を有効化します。

#### (4) ターミナル起動

ホーム画面にてホームボタンを上にドラッグすると現在インストールされているアプリの一覧が出てきますので、「ターミナル」を押し起動します。

#### (5)リカバリモード

Terminal内で以下のコマンドを打って次回起動時にリカバリモードにするためのコマンドを実行しOSを再起動します。

```
$ su ※suしてもパスワードは聞かれません。
# rpi4-recovery.sh
# reboot
```

### 2.3 カスタムOSインストール

LineageOSは、リカバリモードで起動され「Install」を選択し、「SelectStorage」から対象の「open_gapps-arm-10.0-pico-YYYYMMDD.zip」を選択し「Install Image」を選択します。

Install Zip画面にて[Swipe to confirm Flash]をスワイプします。

インストールが完了すると「Back」と「Reboot System」とどちらかを選択するように求められますが、ここでは「Back」を選択してください。

同様に「Install」を選択し、「SelectStorage」から対象の「lineage-17.1-rpi-recovery2boot.zip」を選択し「Install Image」を選択します。

Install Zip画面にて[Swipe to confirm Flash]をスワイプします。

インストールが完了すると「Back」と「Reboot System」とどちらかを選択するように求められますが、ここでは「Reboot System」を選択してください。

## 3.Amazonプライムビデオの設定


### 3.1 Googleアカウント設定

設定画面(初期画面から右にスライドし、右下の歯車を押す)→「アカウント」→「アカウントを追加」を押しGoogleアカウントを設定します。


### 3.2 GooglePlayからChromeをインストール

ホーム画面にてホームボタンを上にドラッグすると現在インストールされているアプリの一覧が出てきますので、「Playストア」を押しChromeをインストールします。


### 3.3 GooglePlayからAmazonプライムをインストール

同様にホーム画面にてホームボタンを上にドラッグすると現在インストールされているアプリの一覧が出てきますので、「Playストア」を押しAmazonプライムをインストールします。

### 3.4 Amazonプライムアカウント設定

設定画面(初期画面から右にスライドし、右下の歯車を押す)→「アカウント」→「アカウントを追加」を押しGoプライム・ビデオアカウントを設定します。

## 4. おわりに

これでAmazonプライムを見ることができます。
課題としては、日本語変換ができないことと、RaspberryPiはRTCが実装されてないため(後付け可能なよう)、毎回起動時に日時を合わせる必要があります。

また、使ってみて毎回日時を合わせるのは面倒ではありますが、動画は不満なく見ることができるので、PCのCPUを無駄に使うぐらいならRaspberryPiで見るのもありかと思います。

