---
title: bashコーディング規約
tags: Bash shell コーディング規約
author: mashumashu
slide: false
---
# bashコーディング規約

## モチベーション

* 一定の品質を保ちたい
* 書くたびに書き方が変わるのは好ましくない


## シェバング（shebang）は`#!/bin/sh`ではなく`#!/bin/bash`にする

* シバン、シェバンとも言われる
* `#!/bin/sh`は実行環境によって様々なシェルにシンボリックリンクになっているので、bashなら`#!/bin/bash`と明示しよう

```bash
#!/bin/bash
```

## インデントは半角スペース2つ

* 1行が横に長くなり折り返されないように

## 処理内容および使い方をスクリプト内に記載する（`usage()`）

* 何をしてくれるスクリプトか、どのように使うのか`usage()`関数を用意しよう
    *  ヘッダコメントでもいいけど

```bash
function usage() {
cat <<_EOT_
Usage:
  $0 [-a] [-b] [-f filename] arg1 ...

Description:
  hogehogehoge

Options:
  -a    aaaaaaaaaa
  -b    bbbbbbbbbb
  -f    ffffffffff

_EOT_
exit 1
}
```

## オプション解析を行う（`getopts`）

```bash
#!/bin/bash

function usage() {
cat <<_EOT_
Usage:
  $0 [-a] [-b] [-f filename] arg1 ...

Description:
  hogehogehoge

Options:
  -a    aaaaaaaaaa
  -b    bbbbbbbbbb
  -f    ffffffffff

_EOT_
exit 1
}

if [ "$OPTIND" = 1 ]; then
  while getopts abf:h OPT
  do
    case $OPT in
      a)
        FLAG_A="on"
        echo "FLAG_A is $FLAG_A"            # for debug
        ;;
      b)
        FLAG_B="on"
        echo "FLAG_B is $FLAG_B"            # for debug
        ;;
      f)
        ARG_F=$OPTARG
        echo "ARG_F is $ARG_F"              # for debug
        ;;
      h)
        echo "h option. display help"       # for debug
        usage
        ;;
      \?)
        echo "Try to enter the h option." 1>&2
        ;;
    esac
  done
else
  echo "No installed getopts-command." 1>&2
  exit 1
fi

echo "before shift"                       # for debug
shift $((OPTIND - 1))
echo "display other arguments [$*]"       # for debug
echo "after shift"                        # for debug
```

## 変数の命名規則

### 定数は`readonly`宣言する

### 定数は大文字、定数以外は小文字

```bash
readonly CONSTANT_PARAM="hoge"
score=100
```

### 複数単語の場合は「名詞」と「名詞」を`_`で結合

```bash
readonly MAX_NUMBER=100
```

### ローカル変数の先頭に`_`を付ける

```bash
function cal_score_ave() {
  local _score_sum=0
  # ...
}
```

### ファイルおよびディレクトリの命名規則

* 末尾に`/`をつけない
* readonly宣言して定数にする

|対象                       |命名規則     |備考            |
|:--------------------------|:------------|:---------------|
|ファイル名（絶対パス）     |HOGE_FILE    |                |
|ディレクトリ名（絶対パス） |HOGE_DIR     |                |
|ファイル名（パスなし）     |HOGE_FILENAME|                |
|ディレクトリ名（パスなし） |HOGE_DIRNAME |                |

```bash
# ファイル名（絶対パス）
readonly HOGE_FILE="/var/tmp/hoge.txt"
# ディレクトリ名（絶対パス）
readonly HOGE_DIR="/var/tmp/hoge"
# ファイル名（パスなし）
readonly HOGE_FILENAME="hoge.txt"
# ディレクトリ名（パスなし）
readonly HOGE_DIRNAME="hoge"
```

## 変数の宣言箇所

### 値を変更する可能性のある場合は冒頭に

* あとで値を変更する場合にわかりやすい

### 値を変更せず内部的に利用する場合は利用する箇所の直前に

* 変数と処理の関連性がわかりやすい

## 関数の命名規則

### `function`宣言する

### 小文字で「動詞」と「名詞」を`_`で結合

* `usage()`は例外

```bash
function cal_score_ave() {
  # ...
  return 0
}
```

## 関数は必ず`return`する

```bash
function cal_score_ave() {
  # ...
  return 0
}
```

## リターンコード：正常終了は0、異常終了は0以外

## パイプの前後に半角スペース1つ

```bash
CMD1 | CMD2
```

## リダイレクトの前は半角スペース1つ、後はスペースなし

```bash
CMD1 >hoge.txt
CMD1 >>hoge.txt
CMD2 <fuga.txt
CMD2 <<fuga.txt
```

## リダイレクトはグルーピングする

```bash
{
  echo "hoge"
  echo "fuga"
  echo "piyo"
} >>logfile.log
```

## 制御構文

### `if`、`then`は同一行に、セミコロンの後ろは半角スペース1つ

```bash
if [ $? -ne 0 ]; then
  # ...
  exit 1
fi
```

### `for`、`while`の`do`と`done`を揃える

```bash
for _score in ${SCORE_ARRAY[@]}
do
  _score_sum=$((_score_sum + _score))
done
```

```bash
while IFS=$`\n` read _line
do
  echo $_line
done <hoge.txt
```

### if文を省略しない

```bash
[ $hoge = $foo ] && echo "true" || echo "false"
```

# 参考情報

1. [シェルスクリプト Tips](http://shellscript.sunone.me/tips.html "シェルスクリプト Tips")
2. [bash によるオプション解析](http://qiita.com/b4b4r07/items/dcd6be0bb9c9185475bb "bash によるオプション解析")
3. [逆引きシェルスクリプト/getoptsを利用して引数を取得する(bashビルドイン)](http://linux.just4fun.biz/%E9%80%86%E5%BC%95%E3%81%8D%E3%82%B7%E3%82%A7%E3%83%AB%E3%82%B9%E3%82%AF%E3%83%AA%E3%83%97%E3%83%88/getopts%E3%82%92%E5%88%A9%E7%94%A8%E3%81%97%E3%81%A6%E5%BC%95%E6%95%B0%E3%82%92%E5%8F%96%E5%BE%97%E3%81%99%E3%82%8B%28bash%E3%83%93%E3%83%AB%E3%83%89%E3%82%A4%E3%83%B3%29.html "逆引きシェルスクリプト/getoptsを利用して引数を取得する(bashビルドイン)")
