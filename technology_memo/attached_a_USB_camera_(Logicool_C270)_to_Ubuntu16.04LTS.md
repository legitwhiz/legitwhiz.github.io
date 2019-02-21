---
layout: default
title: Ubuntu16.04LTSにUSBカメラ(Logicool C270)を付けて静止画を撮ってみた。
---

# Ubuntu16.04LTSにUSBカメラ(Logicool C270)を付けて静止画を撮ってみた。

## 環境
Ubuntu16.04LTS
ESXi 5.5

## まずはVMware ESXi 5.5にUSBパススルーを使用しUSBカメラを仮想マシンに割り当てます。

vSphereClientから対象仮想マシンを選択し、「設定の編集」を選ぶ。
「ハードウェア」の「追加」を選び、「USBコントローラ」の追加を選んで「次へ」、「次へ」、「終了」を選び、「USBコントローラ」の追加を実施する。

次に「USBデバイス」の追加するため、「ハードウェア」の「追加」を選び、「USBデバイス」の追加を選び「次へ」、LogiCoolのWebカメラを選択して「次へ」、「終了」を選び、「USBデバイス」の追加を実施する。

## Ubuntu16.04LTS側での作業

### Ubuntu 16.04LTSにログインしUSBの認識確認

```
$ sudo lsusb
Bus 002 Device 001: ID 1d6b:0003 Linux Foundation 3.0 root hub
Bus 001 Device 005: ID 046d:0825 Logitech, Inc. Webcam C270
Bus 001 Device 003: ID 0e0f:0002 VMware, Inc. Virtual USB Hub
Bus 001 Device 004: ID 0e0f:0003 VMware, Inc. Virtual Mouse
Bus 001 Device 002: ID 0e0f:0002 VMware, Inc. Virtual USB Hub
Bus 001 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
```

### コマンドラインで使えるfswebcamのインストール

```
$ sudo apt-get install fswebcam
```

### カメラの向きを微調整するために、とりあえず撮影。

定期的に画像を撮り、撮った画像をowncloudから見れるようにするため、owncloudディレクトリに格納し更新コマンドを実行するようにシェルスクリプトを作成しcronに登録してみました。

```
$ fswebcam -D 5 -r 1280x720 -S 100 --no-title --no-banner --no-shadow ./test.jpg
```

撮影した写真を確認する方式としてowncloudを利用しデータの更新は、

```
sudo -u <apache user> php /var/www/owncloud/occ files:scan <owncloud user>
```

ちなみにUSBカメラで静止画を撮るのは特に目的はありません。(ただ単にやってみたかっただけですwww。)




```
