# Red Hat Enterprize Linux 8.0 Betaをとりあえずインストールしてみました。

## Red Hat Enterprize Linux 8.0 Betaをとりあえずインストール
2018年11月15日にRed Hat Enterprize Linux 8.0 Betaが公開されました。
なので、とりあえずVMware Workstation 15 Playerにインストールしてみました。

注意点として、ゲストOSの選択でLinuxを選択し、バージョンを「その他のLinux4.x以降のカーネル」を選択すること。
※64ビットを選択するとディスクを認識しないので必ず、64ビットの記載なしのほうを選択して下さい。(私はこれが分からずハマリました...w)


![RHEL8Beta_001](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/RHEL8Beta/RHEL8_001.JPG)
後は、RHEL7となんら変わらずにインストールできました。(Beta版では言語で日本語は選択肢が存在しませんでした。
![RHEL8Beta_002](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/RHEL8Beta/RHEL8_002.JPG)

![RHEL8Beta_003](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/RHEL8Beta/RHEL8_003.JPG)

![RHEL8Beta_004](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/RHEL8Beta/RHEL8_004.JPG)



## Red Hat Enterprize Linux 8.0 Betaの気になったポイント

- カーネルがやっと4.18(5.0のrc版が出ているのに!?)

- AnacondaのGUIや、Kickstartコマンドにおいて、Btrfsが利用できなくなります。

- RedHat 7.xでは、ntpとchronyの両方が利用可能でしたが、8.xではchronyのみがサポート。

- yumがDNFベースのYum 4に変更。(サブコマンドが拡張されてます)

- ディスプレイサーバーがXorgからWaylandに変更されます

- iptables、firewalldがnftablesに置き換えられます。(firewalldをやっと覚えたのに・・・。)

- ストレージ暗号化のデフォルトフォーマットがLUKSv2に変更。

- OpenSSL 1.1.1およびTLS 1.3をサポート

- シンプルで一貫したユーザ管理画面「Red Hat Enterprise Linux Web Console」

- API経由での洗練されたデータ管理を実現する新ストレージ管理システム「Stratis」

- IPVLANを経由で仮想マシンに配置されたコンテナとホストを接続することで，スループットの負荷を低減し，レイテンシを最小限に

- ネットワークのパフォーマンスを高速化する新たなTCP/IPスタックとして「Bandwith and Rpund-trip propagation time（BBR）⁠」を採用

- RHELのリポジトリがBaseOSとAppStreamsの２つになりました。

以上、個人的(ITインフラ開発者として)にきになった点をざっと羅列してみました！


なお、RHEL8の変更点が以下のスライドでまとまってました。
https://speakerdeck.com/moriwaka/red-hat-enterprise-linux-8-betafalsemidokoro


Red Hat Enterprise Linux 8の一般提供は2019年中だそうです。


## 最後に

とあえず今日はここまでとします。
nftables、chrony、リポジトリについては、後々調査してレポートしてみたいと思います。
「Red Hat Enterprise Linux Web Console」もどんなものか興味ありますが、何せ情報が少ない。

