# M5Stickcで温度計を作ってみた

## 1.M5Stickcとは

### 1.1. M5Stickcとは？

M5StickCとはESP-32が入ったケース付き超小型マイコンモジュールです。
[Grove](http://wiki.seeedstudio.com/Grove_System/)対応コネクタやHATモジュール（上部の8ピンコネクタに挿さるオプション）が使え、HAT用８端子の信号ラベルを見ると、5V電源のIN/OUTもあるみたいなので、ブレッドボードに繋ぐこともでき、アイデア次第で色々なことでできそうです。
ネットワーク機能（WiFi/Bluetooth）搭載な上に、ボタン、バッテリー、液晶ディスプレイ、６軸センサ、LED、赤外線LED搭載と機能満載なうえ、なんと2,000円弱と破格のお値段です。

### 1.2. M5StickCスペック

- Size：48mm x 24mm x 14mm
- 重量：15.1g
- バッテリー内蔵 (80mAh)
- ESP32-Pico (4MB Flash+520KB SRAM)
- 2.4GHz WiFi/BT
- 赤外線LED
- カラーTFT(80x160pixcel)
- さらにButton\*3,6軸(ジャイロ・加速度)、内蔵

### 1.3 パッケージ

購入したパッケージには、本体、ベルト、マウント、USB(Type-C)が付属してました。

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/M5Stickc/m5stick.png" width="440">

## 2. Arduino IDE開発環境の準備

Arduino IDE開発環境の準備は、以下が必要となります。
2.1. ArduinoIDEをインストール
2.2. ArduinoIDE のボードマネージャで「ESP32」をインストール
2.3. ArduinoIDE でライブラリ「M5StickC」をインストール

###　2.1. Arduino IDEをインストール

ブラウザを開いて、[Arduino公式サイト](https://www.arduino.cc/) にアクセスする。
[SOFTWARE]メニューの[DOWNLOADS ]をする。

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/M5Stickc/arduinoide_install001.png" width="640">

[Windows Installer, for Windows XP and up]をクリックし、

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/M5Stickc/arduinoide_install002.png" width="640">

次の画面で[JUST DOWNLOAD]をクリックするとダウンロードが始まります。

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/M5Stickc/arduinoide_install003.png" width="640">

ダウンロードした、[arduino-<version>-windows.exe]を実行するとインストールウィザードが起動され、[次へ]を何度か押し進める。

途中にUSBドライバなどのインストールをインストールするかの確認のダイアログが出力されますが、許可をしてインストールを進める。


### 2.2. ArduinoIDEのボードマネージャで「ESP32」をインストール

スタートメニューから[Arduino]をクリックし起動する。
Arduinoのメニューから[ファイル]->[環境設定]をクリック。

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/M5Stickc/arduinoide_setting001.png" width="440">

[環境設定]画面で[追加のボードマネージャURL]に”https://dl.espressif.com/dl/package_esp32_index.json”を入力し、[OK]をクリック。 

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/M5Stickc/arduinoide_setting002.png" width="640">

メニューから[ツール]->[ボード]->[ボードマネージャ]を選択し、

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/M5Stickc/arduinoide_setting002.png" width="640">

メニューから[ツール]->[ボード]->[ボードマネージャ]を選択し、検索窓に"esp32"を入力し、出力された"esp32 by Espressif Systems"の[インストール]をクリック。

インストールが完了したら[閉じる]をクリック。

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/M5Stickc/arduinoide_setting003.png" width="640">


### 2.3. ArduinoIDE でライブラリ「M5StickC」をインストール

メニューから[スケッチ]->[ライブラリをインクルード]->[ライブラリを管理]をクリックし、検索窓に"m5stickc"を入力し、出力された"M5StickC"の[インストール]をクリック。

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/M5Stickc/arduinoide_setting004.png" width="640">


### 2.4. ArduinoIDE でライブラリ「BMP280」をインストール

メニューから[スケッチ]->[ライブラリをインクルード]->[ライブラリを管理]をクリックし、検索窓に"bmp280"を入力し、出力された"Adafruit BMP280 Library"の[インストール]をクリック。

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/M5Stickc/arduinoide_setting005.png" width="640">


## 3.プログラム

### 3.1 温度計プログラム

今回は、M5StickC ENV Hatを購入していたので、それを試しています。
※M5StickC ENV Hatは、M5Stickcに接続できる環境センサモジュールで、温度、湿度、気圧、磁界センサを搭載しています。

メニューから[ファイル]->[スケッチ例]->[M5Stickc]->[HAT]->[ENV]をクリックするとArduinoIDEの別ウィンドウが出力され、サンプルのプログラムが出力されます。

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/M5Stickc/skech_test001.png" width="640">

検証ボタンをクリックし、プログラムに問題がないか検証します。
問題がなければ"コンパイルが完了しました"を出力されます。

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/M5Stickc/skech_test002.png" width="640">

"マイコンボードに書き込む"ボタンをクリックし、"ボードへの書き込みが完了しました。"

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/M5Stickc/skech_test003.png" width="640">

## 4.最後に

今回は、M5Stickcにて温度計を試してみました。
本当はもっと色々試したかったのですが、それよりもっと勉強したいことがあるので
検証・実験・レポートはこれで終わりです。
いつか、時間を作って色々M5Stickcで色々試してみたいと思います。
プログラムをいじって、温度計がある一定以上を検知した場合はLINEに通知するとか。
温度計で得た温度や湿度・気圧などをクラウド上にプットしてグラフ表示できるようにしたりと
色々と妄想が膨らみます。


