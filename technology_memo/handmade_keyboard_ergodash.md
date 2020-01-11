#『自作キーボード Ergodashビルドログ』

今までキーボードは、HHKBを使用していましたが打ちやすさは満足いくものの肩をすくめて打つスタイルなので肩凝りがひどい…！Σ(×_×;)!
そして、マウスへの手の移動が苦痛でしかない。

そこでいいものはないかとネットを迷走していました。
キーボードにトラックボールを搭載したものも発見しましたが、肩凝り解消にはならないのでボツ。

一旦、マウスを忘れて、肩凝りを減少させるためには
どうしたらいいか調べたところ、肩をすくめて作業を続けることが肩凝りの原因だと分かった。
そして、それを解消する『エルゴノミクス』という
キー配列がハの字のもと『左右分離式』という左右ユニットに分割しているものがあるということが分かった！

『左右分離式』でも色々あり、【自作キーボード】なるものが世間では流行り初めてようで、自分でハードも組み立てられ、ファームウェアも自分で設計できるなんて、【大人の玩具】には最高じゃね？
色々と自作キーボードでも種類がありましたが、親指を活用できる【Ergodash】に決めました。

## パーツ購入
自作キーボード(Ergodash)パーツを『遊舍工房』で購入。

・ErgoDash 親指あり
・Kailh BOX スイッチ 赤軸  x70
・MDA Big Bang 2.0    
・TRRSケーブル  
・USBケーブル    
・Mill-Max ソケット x140 
・M2ねじ (短) 2本
・M2スペーサー  2本

『akiba LED ピカリ館』
・LED WS2812B × 30  

以外、工具類は『千石電商』で購入

・白光 ダイヤル式温度制御はんだこて FX600 
・goot こて先クリーナー ST-70               
・goot 高密度集積基板用はんだ SD-60    
・goot はんだ吸取り線 CP-20Y
・白光 こて先 2C型 T18-C1

その他に手持ちの工具で

逆作用ピンセット
プラスドライバー(精密)
ラジオペンチ
ニッパー
テスター

『100均』で以下を購入
作業マット
マスキングテープ

## ハード構築

[公式ビルドログ](https://github.com/omkbd/ErgoDash/blob/master/Doc/build.md)を見ながらまずは、ダイオード・TRRSソケット・リセットスイッチを半田付け。
<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/tmp/kb/DSC_0646.JPG" width="840">

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/tmp/kb/DSC_0649.JPG" width="840">

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/tmp/kb/DSC_0674.JPG" width="840">

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/tmp/kb/IMG_20191121_125724_867.jpg" width="840">

※後で分かったが、リセットスイッチの場所が左右対象に付けてしまっていた。
(本来は左右非対称)
キースイッチを直接半田付けし、promicroにコンスルーを付け搭載。
それで組み合わせると左手は、数ヶ所半田が未完全でしたがなんとか使えるように。

だが、右手はpromicroのLEDさえも付かない…
リセットスイッチとpromicroの搭載位置が間違っていたので、PCBに搭載した全てを取り外し、再度半田をやり直しました。

この時、リセットスイッチ・ダイオード・TRRSソケットを買い直し、Mill-Max ソケットを買い足し、コテ先を『T18-C1』に換え再度、挑戦。
コテ先を『T18-C1』に換えたことで作業効率は断然よくなりなした。

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/tmp/kb/DSC_0675.JPG" width="840">

まずは左手ユニットを半田付けし、全てのキースイッチを確認。
右手ユニットも半田付けし、USBケーブルを直接接続。
右手PromicroのLEDは点灯するようになったし、全てのキースイッチが反応してくれたー。

『はぁー長かった』と思ったのはつかの間…
TRRSケーブルで接続するとPromicroのLEDは点灯するもののキースイッチは、無反応…
ジャンパの説明が微妙に分かりずらかったので色々と試したが変わらず。

そこで、制作元にtwitterで見てもらうことに
ダイオードは問題ないが、ジャンパ間違っていると指摘されました。
ジャンパは色々試した時のままでしたので、それを直しましたがやはりダメ。
制作元に、TRRSケーブルを接続状態でテスターで導通確認を指示いただき、確認したところ本来導通できるところができていませんでした。
左右を比べながらTRRSケーブルは接続しないでTRRSソケットのスルーホールからpromicroを搭載するスルーホール間を導通していくと、右手が悪いと思ってましたが、左手のPCBがどうも問題のようでした。空中配線も試しなんとか動くが接触があまりよくない…

そこで、最後本体を再購入し、一からやり直し
流石に半田付けも慣れてきたので、あっという間に完成。
何事もなく、右手も動作しました。

後、UnderGlowのLEDを一つ一つ確認しながら実装しました。
右手は難なく取り付けできましたが、左手は途中で失敗しLEDを破損したようで吸取り線で取り外したがスルーホールのプリントまで剥がれたため、LEDテープでの実装に切り替えましたwww

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/tmp/kb/IMG_20191215_200935_503.jpg" width="840">

## QMKファームウェア

ファームウェアのコンパイル環境として【[Msys2](https://www.msys2.org/)】をセットアップし
ファームウェアを書き込むのに【[QMK Toolbox](https://github.com/qmk/qmk_toolbox/releases)】を導入し
【[QMK Configurator](https://config.qmk.fm/)にてキーマップを作成しました。

【QMK Configurator】だけで、ファームウェアはコンパイルできるのですが、UnderGlowやMouseなどを実装するにはソースファイルを編集する必要があったので、キーマップを作成し【Msys2】でコンパイルしています。
コンパイルしたファームウェアを書き込むのに【QMK Toolbox】

【参考】
[プログラマーではない人向けのQMK Firmware入門](https://qiita.com/cactusman/items/ac41993d1682c6d8a12e)


## 自作TRRS、USBケーブル

『遊舍工房』にて販売している、TRRSケーブル、USBケーブルに自作キットを購入し、作成してみました。
<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/tmp/kb/DSC_0713.JPG" width="840">
