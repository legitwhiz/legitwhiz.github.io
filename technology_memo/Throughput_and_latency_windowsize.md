
![title](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/1000007322.jpg)

# スループットとWindow size見積もり

Linux 初心者 インフラ ネットワーク 見積もり

## 0. 目的
 
スループットとlatencyとWindow sizeの関係について理解し、設計フェーズにてスループット、Window sizeを見積もりできるようになりたい人に観て欲しい。

## 1. スループットとlatencyとWindow sizeの関係について

### 1.1. 最大スループット

ローカルネットワークとの通信のみであれば、そこまで気にする必要はないが、WAN越えの通信となるとlatencyによる影響は、微量であってもスループットへの影響は大きいことを意識してください。

それは、以下の式から証明出来きます。
※本来RTTは往復での遅延時間、latencyは片道での遅延時間を指すが、ITでは往復でないと通信が確立出来ないから、RTTはlatencyとITでは、ほぼ同義です｡

```
最大スループット(bps)=(Window size*8)/(RTT(ms)/1000)
```

なお、式の8をかけているのはbyteをbitに直し、1000で割ってをいるのはミリ秒を秒に直すために入れてます｡

window size 256KBの場合、RTT2ms以下であれば1Gbps以上となる為、I/Fが1Gbpsなら問題ないですが、RTTが5msとなったら最大スループットが400Mbpsとなってしまいます。RTTが20msともなると100Mbpsしかスループットが出ない。

以下に一例としてWindow sizeとlatencyからThroughputを求めた記載します。

|WindowSize|latency|Throughput|
|-----------:|-------:|-----------:|
|256KB|10ms|200Mbps|
|256KB|5ms|400Mbps|
|256KB|2ms|1000Mbps|
|512KB|10ms|400Mbps|
|512KB|5ms|800Mbps|
|512KB|2ms|2000Mbps|
|1024KB|10ms|800Mbps|
|1024KB|5ms|1600Mbps|
|1024KB|2ms|4000Mbps|

スループットが出ないならどうするか？

### 1.2. 必要なスループットからWindow sizeを算出するには

RTT20msでI/F速度(1Gbps)と同じスループットがWANでも必要な場合、WindowSizeを算出するには以下の式になり

```
Window size=(最大スループット*(RTT(ms)/1000))/8
```

なので、必要なI/F速度(1Gbps)とした場合は、WindowSizeは「262KB」となります。

```
(1Gbps*1024*1024*1024*0.002)/8
```

というように、環境のlatency(RTT(ms))と必要とする最大スループットからWindow sizeが求めることができましたね。

では、そのWindow sizeをどうやって設定したらいい？

### 1.3. Window sizeの設定

一時的に設定する場合は、/proc配下に設定すればいいですが、一時的に設定はあまりないでしょうから割愛します。

なのでカーネルパラメーターの設定していきます。

まず、送信(wmem)なのか受信(rmem)なのかで設定項目が分かれますので、必要なのはどちらか見きわめてください。

```
・ net.ipv4.tcp_rmem: TCPソケットの 最小, デフォルト, 最大受信サイズ

・ net.ipv4.tcp_wmem: TCPソケットの 最小, デフォルト, 最大送信サイズ
```

必要なスループットを維持できるだけの送受信のWindow sizeを最大サイズとします。

最大は、求めたWindow sizeとします。
最小は、変更せずdefault(4KB)のままでいいです。
デフォルトは、目安として送信(wmem)の場合は、最大値の1/256倍。受信(rmem)の場合は、最大値の1/48倍。

### 1.4. 送受信バッファサイズの設定

次に送受信に使用するバッファサイズもWindow sizeに合わせて設定変更する必要があります。

注意なのが、バッファサイズは大きくすれば、それだけメモリを使うことを認識しておいてください。

```
・net.core.rmem_default: デフォルト受信ソケット・バッファ・サイズ

・net.core.rmem_max: 最大受信ソケット・バッファ・サイズ

・net.core.wmem_default: デフォルト送信ソケット・バッファ・サイズ

・net.core.wmem_max: 最大送信ソケット・バッファ・サイズを指定
```

デフォルトは、[「1.3. Window sizeの設定」](#1.3.-window-sizeの設定)で求めた値を設定してください。
最大も同様に、[「1.3. Window sizeの設定」](#1.3.-window-sizeの設定)で求めた値を設定してください。

### 1.5. クライアント側での送受信バッファサイズの調整

SCPやFTP,NFSなどのクライアント側で送受信バッファサイズをできるものも多いので、大容量ファイルを送受信する運用がある場合は、特に意識してください。

## 2. 最後に

MTUやMSSを理解すべきなのでしょうが、今回はスループットやWindow sizeは見積もりできるようになったかと思います。

latencyの注意点は、簡単出来るからといってpingの応答時間をlatencyと勘違いしないようにしてください。
pingは、送信したパケットサイズと同じサイズで応答するので、pingで64KBのパケットを送った場合、RTTの値は64KBの往復値つまり128KBの時間となります｡
latencyの詳細は、iperf(iperf3)などのツールを使って調べるようにしてください。

ちなみにRHEL9のカーネルパラメーターのデフォルト値は以下となりますが、latencyが50msともなるとデフォルトではI/F速度のスループットが保てなくなります。

```RHEL9デフォルトWindow size
net.ipv4.tcp_rmem = 4096  131072  6291456
net.ipv4.tcp_wmem = 4096  16384   4194304
```

latencyが50msの場合、各I/F速度に合わせた送信Window sizeは以下となります。

|I/F|Min|default|Max|
|------:|------:|---------:|---------:|
|default|4K|16K|4M|
|1G|4K|32K|8M|
|10G|4K|256K|64M|
|40G|4K|1M|256M|
