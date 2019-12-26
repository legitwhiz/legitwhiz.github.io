---
layout: default
title: Windows Server 2016標準コマンドでできる簡単パケットキャプチャ
---
# Windows Server 2016標準コマンドでできる簡単パケットキャプチャ

今までは、WireShark等のパケットキャプチャーソフトウェアを
導入しないとキャプチャー出来ないと思っていましたが
Windows Server 2008 R2(Windows 7) 以降(私が知らなかっただけかｗ)であれば、
OS標準機能の[netsh]コマンドでパケットキャプチャーを取ることができます。
※ただし、要管理権限
(Linuxのtcpdump,AIXのiptrace,SolarisのSNOOP,HP-UXのnettlに相当)
他OSのパケットキャプチャー方法は、[パケットキャプチャ あんちょこ](https://qiita.com/legitwhiz/items/368ef7ab71d3b86b2e6a)を参照。

簡単にソフトウェアとか追加できないような環境が多いので
OS標準であると大変助かります。(多少手間はあっても)

ただし、[netsh trace]コマンドにてパケットキャプチャを開始、停止する際に NIC のリンクダウンが発生する場合があるので、それを理解した上で使用して下さい。
ちなみに、この動作は仕様です。詳細は以下を参照。
[netsh trace コマンドにてパケット キャプチャを開始、停止する際に NIC のリンクダウンが発生する場合がある](https://support.microsoft.com/ja-jp/help/2914927)

サーバで[netsh trace]コマンドにてパケットキャプチャを開始しても
殆ど負荷はかかりませんでした。
(パフォーマンスモニタでは、CPU、メモリ共に変化を目視出来ませんでした)
ただし、停止時にデータ収集にCPUを若干変化がありましたが瞬間的なので業務影響が出るほどではないと考えてます。
アンチウィルスソフトウェアを導入しているサーバなので、データ保管の際に負荷がかかったものと思われる。

## パケットキャプチャーの採取方法

詳細なオプションは、後述するとして、まずはパケットキャプチャーの採取方法は以下コマンドで採取します。

```
C:\Users\Administrator>netsh trace start capture=yes

トレース構成:
-------------------------------------------------------------------
ステータス:           実行中
トレース ファイル:    C:\Users\Administrator\AppData\Local\Temp\NetTraces\NetTrace.etl
追加:                 オフ
循環:                 オン
最大サイズ:           250 MB
レポート:             オフ


C:\Users\Administrator>netsh trace stop
トレースを関連付けています... 完了
トレースの結合中... 完了
データ収集を生成しています ... 完了
トレース ファイルと追加のトラブルシューティング情報は、"C:\Users\Administrator\AppData\Local\Temp\NetTraces\NetTrace.cab" としてコンパイルされました。
ファイルの場所 = C:\Users\Administrator\AppData\Local\Temp\NetTraces\NetTrace.etl
トレース セッションは正常に停止しました。

C:\Users\Administrator>
```

## netsh traceコマンド基本

・キャプチャ開始
netsh trace start capture=yes traceFile=<ファイル名>

・キャプチャ停止
netsh trace stop

・キャプチャの取得状態の確認
netsh trace show status

## netsh traceコマンド オプション

【代表的なキャプチャフィルター】

```console:インターフェースを指定する場合
CaptureInterface=<インターフェース名または GUID>
    例えば、CaptureInterface="ローカル エリア接続"
```

```console:イーサネットタイプを指定する場合
Ethernet.Type=<イーサネットの種類>
    例えば、Ethernet.Type=IPv4
```

```console:プロトコルを指定する場合
Protocol=<プロトコル>
    例えば、Protocol=TCP
```

```console:IPアドレスを指定する場合
IPv4.Address=<IPv4アドレス>
    例えば、IPv4.Address=192.0.2.1
```

```console:送信元IPアドレスを指定する場合
IPv4.SourceAddress=<送信元IPv4アドレス>
    例えば、IPv4.SourceAddress=192.0.2.1
```

```console:送信先IPアドレスを指定する場合
IPv4.DestinationAddress=<送信先IPv4アドレス>
    例えば、IPv4.DestinationAddress=192.0.2.1
```

```console:再起動後もとり続けたい場合
persistent=yes
```
```console:出力ファイルを指定したい場合
traceFile=%LOCALAPPDATA%\Temp\NetTraces\NetTrace.etl
```

```console:出力ファイルサイズを指定したい場合
maxSize=500
```

合わせるとキャプチャを開始しインターフェース、イーサネットタイプ、
プロトコル、ファイルサイズ、ファイル名を指定すると以下のようになります。

```
netsh trace start capture=yes CaptureInterface="Team1" Ethernet.Type=IPv4 Protocol=UDP maxSize=500 traceFile=C:\Tmp\NetTrace.etl
```

ちなみにコマンドオプションの既定値は以下となります。
capture=no
capturetype=physical
report=no
persistent=no
maxSize=250
fileMode=circular
overwrite=yes
correlation=yes
perfMerge=yes
traceFile=%LOCALAPPDATA%\Temp\NetTraces\NetTrace.etl
providerFilter=no


## 採取したパケットキャプチャーを見るには

採取したパケットキャプチャーを見るためには、
[Microsoft Message Analyzer]をダウンロードし端末に導入し、
[Microsoft Message Analyzer](https://www.microsoft.com/en-us/download/details.aspx?id=44226)

「file」-「open」-「from file explorer」を選択し、生成された*.etlを開く

なお、wiresharkで見れるように変換するには、
[Microsoft Message Analyzer]の
「file」-「save as」を選択し
「export」を選択するとcapファイルが選べるので「保存」
これでwiresharkで見れるようになります。


## 参考
Message Analyzerは、通信しているプロセス名がデフォルトだと分からないため、通信しているプロセス名を知りたいのであれば以下を参照。
[Message Analyzer でのネットワークキャプチャーに、通信しているプロセス名情報を追加する方法](http://troushoo.blog.fc2.com/blog-entry-251.html)

また、USB機器との通信も見ることが可能。
[Microsoft Message AnalyzerでUSB解析](http://faster-than-the-sol.blogspot.com/2015/04/microsoft-message-analyzerusb.html)

Message Analyzerでどのサーバにどんなプロトコルを投げているか、
他にはHTTPステータスを何を返しているか視覚的に把握できる
[Gantt Viewer]というプラグインがありますので興味がある人は
以下を参考にしてみるといいでしょう。
[Message Analyzer の Gantt Viewer](http://troushoo.blog.fc2.com/blog-entry-323.html)

# 後述

Windows Serverでも、簡単にパケットキャプチャ出来るようになったのは
非常にありがたいですね。
Message Analyzerの見方は、WireSharkとはかなり違うので慣れるまで
時間がかかるでしょうが、そこは面倒でも変換したりせず慣れるしかないでしょうね。

あと、サーバ技術者で結構いるのが、パケットキャプチャする方法は知っている
のにも関わらずTTLの意味を理解していない人が多すぎる・・・。
折角、パケットキャプチャしても、どこでパケットロスしているかなんて
pingのTTLの値の差異で大体分かるし・・・。

なお、TTLについては、先人が詳しく分かり易く書いているので
参考にするといいでしょう。
[リセットパケットを投げたのは誰だ？](https://netwiz.jp/?p=435)
