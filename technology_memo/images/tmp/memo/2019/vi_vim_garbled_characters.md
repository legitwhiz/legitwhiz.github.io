---
layout: default
title: viもしくはvimでファイルを開いたら文字化け・・・。でも、慌てずファイルエンコードを変えれば読めるよ!
---

# viもしくはvimでファイルを開いたら文字化け・・・。でも、慌てずファイルエンコードを変えれば読めるよ!


う～ん。viの使い方ぐらいSEなら覚えようよ・・・。
viで文字化けしてたからって、scpでgetしてエディタで開くとか時間の無駄だから・・・。

## まずは、viの文字コードを確認

```console:viでファイル開いた状態で
:set enc?
```

すると画面最下部に[encoding=<文字コード>]って表示されるから、これがviのデフォルトの[fileencodings]もしくは[encoding]だよ。
都度viで設定が面倒なら、ユーザ毎に[~/.vimrc]にて設定出来るから。

ちなみに

```console:確実にファイルの文字コードを調べたいなら(他にも調べる方法はあるから自分で調べてね)
nkf --guess <file name>
Shift_JIS (LF)
```

## [~/.vimrc]の設定するなら
[~/.vimrc]の設定内容は、こんな感じで

```
# default encoding
set encoding=utf-8

# Character code when opening. 
# If more than one is specified, it tries to open with matched ones from the beginning.
set fileencodings=iso-2022-jp,euc-jp,sjis,utf-8

# Automatic recognition of line feed code.
set fileformats=unix,dos,mac
```

## vi上で文字コードを変更

```console:vi上で表示の文字コードを変更するなら
:e ++enc=<文字コード>
```

これで読めるようにはなったでしょ？

## vi上で文字コードを変更して保存するなら

もし、ファイルが意図しない文字コードであれば、文字コードを変更して保存することもデキるからね。

```console:ファイルの文字コード変更
:set fenc=<文字コード>
```

```console:もちろん、その後保存してね
:wq
```


