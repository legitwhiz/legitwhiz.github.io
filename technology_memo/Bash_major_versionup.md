---
layout: default
title: Bashメジャーバージョンアップで何が変わった？
---

# Bashメジャーバージョンアップで何が変わった？

Bashが2019年1月7日にメジャーバージョンアップ(5.0)されました。

bash4.0 RC1が2009年1月12日なので10年ぶりのメジャーバージョンアップ。

と言うか10年以上も現役なんて凄いですねw



[Bash 5.0 released](https://lwn.net/Articles/776223/)を見るとbugfixと新機能の追加です。

主な変更点は、

・nameref変数に関するbugfix

・最も注目すべき新機能は、いくつかの新しいシェル変数です。BASH_ARGV0、EPOCHSECONDS、およびEPOCHREALTIME。

・historyは、履歴を範囲指定して削除することができるようになりました。



bash-4.4とbash-5.0の間に互換性のない変更がいくつかあります。

となっていますが、nameref変数の解決方法に限った内容だそうです。



## 新機能

[Bash 5.0 released](https://lwn.net/Articles/776223/)から最新版をダウンロードし、解凍しNEWSを読んでみました。



### 新しく追加された変数



・BASH_ARGV0

$0と同様みたいですが、同じ機能なら、あまり追加機能としてどうなのかと・・・w



・EPOCHSECONDS

UNIX時間の秒数

dateコマンドにUNIX時間を出力するオプションがあるので・・・。



・EPOCHREALTIME。

UNIX時間のマイクロ秒数

マイクロ秒まで使うことってスクリプトだと少ないかと・・・。



### history範囲指定削除

コマンド履歴を範囲指定で削除できるようです。

そもそも、削除する必要って・・・。



### その他

・ビルトインコマンドであるwaitが`-f`オプションを付けることで、ちゃんと待てるようになった。

・umaskが今まで3桁だったのが4桁まで対応できるようになった。

・Readline系も変わったみたい。キーバインドで`next-screen-line`と`previous-screen-line`が追加され、Insertキーで上書き出来るようになった。



[Bashソース](https://ftp.gnu.org/gnu/bash/)を

