Bash、およびその周辺コマンドに関するTips。サーバ系は[こちら](http://kodama.fubuki.info/wiki/wiki.cgi/Linux/server_tips?lang=jp)。

- [ログイン](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#0)

- - [ログイン時の設定](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#1)
  - [ログインおよび対話モード時の設定](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#2)

- [標準入出力](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#3)

- - [各入出力の番号（ファイル・ディスクリプター）](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#4)
  - [入力のリダイレクト](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#5)
  - [出力のリダイレクト](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#6)
  - [ファイル・ディスクリプターの複製](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#7)
  - [Tips: 標準出力を画面とファイルに同時出力](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#8)
  - [Tips: 標準出力を複数のファイルに同時出力](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#9)
  - [Tips: 標準出力と標準エラー出力を同一ファイルに追記](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#10)
  - [Tips: 標準出力と標準エラー出力を別ファイルに出力](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#11)
  - [Tips: 標準エラー出力へ画面表示](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#12)

- [変数](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#13)

- - [値の代入と参照](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#14)
  - [変数の開放](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#15)
  - [読み取り専用の変数](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#16)
  - [環境変数](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#17)
  - [特殊パラメータ](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#18)
  - [特殊変数](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#19)
  - [変数の展開](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#20)
  - [Tips: テンポラリファイル名](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#38)
  - [Tips: 未定義の変数を参照するとエラーを吐くようにする](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#39)
  - [Tips: 拡張子の変更](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#40)
  - [Tips: パスからファイル名のみを取り出す](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#41)
  - [Tips: パスからディレクトリ名のみを取り出す](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#42)
  - [Tips: パスから拡張子のみを取り出す](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#43)
  - [Tips: 文字列の末尾の文字を取り出す](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#44)
  - [Tips: パスが相対パスなら絶対パスへ変換](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#45)
  - [Tips: 特定の文字の出現数をカウントする](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#46)

- [配列](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#47)

- - [個々の要素への値の代入](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#48)
  - [個々の要素の値の参照](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#49)
  - [最初の要素の値の参照](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#50)
  - [一括代入](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#51)
  - [要素番号を指定した一括代入](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#52)
  - [一括参照](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#53)
  - [配列の要素数の参照](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#54)
  - [値が存在する配列要素のインデックスを参照](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#55)
  - [Tips: 配列の末尾へ要素を追加する。](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#56)
  - [Tips: 部分配列を取り出す](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#57)
  - [Tips: カンマ区切りの文字列を配列に変換する](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#58)
  - [Tips: 配列をカンマ区切りの文字列に変換する](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#59)
  - [Tips: 重複する配列の要素を削除する](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#60)
  - [Tips: 2つの配列、双方に含まれる要素を抜き出した配列を作成する。](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#61)
  - [Tips: 2つの配列、双方に含まれる要素**以外**を抜き出した配列を作成する。](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#62)

- [連想配列](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#63)

- - [個々の要素への値の代入](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#64)
  - [個々の要素の値の参照](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#65)
  - [一括代入](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#66)

- [展開](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#67)

- - [ブレース展開](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#68)
  - [チルダ展開](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#69)
  - [パラメータ展開](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#74)

- [条件分岐](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#75)

- - [if文](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#76)
  - [case文](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#77)
  - [条件式](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#78)
  - [正規表現](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#81)
  - [Tips: シンボリックリンクが存在し、リンク先が存在しない場合に処理を行う](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#83)
  - [Tips: 複雑なand/or条件](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#84)

- [繰り返し](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#85)

- - [for文（1）](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#86)
  - [for文（2）](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#87)
  - [while](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#88)
  - [ループ途中からループを脱出する](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#89)
  - [ループ途中からループ先頭に戻る](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#90)
  - [Tips: for i in ～ に渡せる連番を生成](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#91)
  - [Tips: 無限ループ](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#92)

- [日付処理（date）](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#93)

- - [Tips: 特定の年月日を整形して出力](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#94)
  - [Tips: 特定の年の年月日を整形して出力](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#95)
  - [Tips: 指定した年に含まれる日数を出力](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#96)
  - [Tips: 指定した年月に含まれる日数を出力](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#97)

- [演算（let, expr, bc 等）](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#98)

- - [bash算術式（優先度順）](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#99)
  - [let, expr, bc の使い分け](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#102)
  - [let](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#103)
  - [expr](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#104)
  - [Tips: 桁数を指定した計算](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#105)
  - [Tips: 計算結果を指数表記で表示](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#106)
  - [Tips: 小数同士の比較](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#107)
  - [Tips: 常用対数の計算](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#108)

- [ファイル](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#109)

- - [デフォルトの権限](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#110)
  - [Tips: ディレクトリ名を指定したときディレクトリ自体を表示する](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#111)

- [diff](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#112)

- - [Tips: 空白の違いを無視する](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#113)
  - [Tips: ディレクトリごと中身を比較する](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#114)

- [テキスト表示（cat/tac）](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#115)

- - [catとtac](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#116)

- [テキストフィルタ（cut/paste/awk/printf/tr）](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#117)

- - [cut: 各行から選択した部分を取り出す](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#118)
  - [paste: ファイルの横結合（行単位での結合）](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#119)
  - [Tips: 列を指定して文字列を取り出す](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#120)
  - [Tips: 指定した区切り文字で区切られた文字列から最後のフィールドを取り出す](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#121)
  - [Tips: マッチしている以外の行を取り出す](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#122)
  - [Tips: マッチしたファイルのファイル名を表示する](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#123)
  - [Tips: 桁数を指定して数値の先頭を0で埋める](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#124)
  - [Tips: 先頭の0を削除する](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#125)
  - [Tips: 右詰め](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#126)
  - [Tips: 右詰めその２](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#127)
  - [Tips: 左詰め](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#128)
  - [Tips: 連続する空白を1つにする](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#129)
  - [Tips: 小文字を大文字に変換](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#130)
  - [Tips: 特定の列の数値に対して演算を行う](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#131)
  - [Tips: awkへ変数を渡す](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#132)

- [テキストフィルタ（sed）](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#133)

- - [Tips: 先頭行を削除する](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#134)
  - [Tips: 任意の行を削除する](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#135)
  - [Tips: 最終行を削除する](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#136)
  - [Tips: 空行（空白のみの行も含む）を削除する](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#137)
  - [Tips: 1行目のみについて、マッチした場合削除](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#138)
  - [Tips: マッチ行に囲まれた複数行を取り出す](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#139)
  - [Tips: マッチ行に囲まれた複数行を削除する](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#140)
  - [Tips: 行を指定して文字列を取り出す](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#141)
  - [Tips: 行の最後尾に文字列を追加する](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#142)
  - [Tips: 空白区切りの文字列に一定間隔で改行を挿入する](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#143)
  - [Tips: マッチした行の次の次の行のみを取り出す](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#144)

- [find](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#145)

- - [-typeのオプション](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#146)
  - [Tips: 複数の条件で検索する](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#147)
  - [Tips: findで検索したディレクトリを消去](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#148)
  - [Tips: ディレクトリのみの権限を変更（再帰的）](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#149)
  - [Tips: 結果をアルファベット順に表示](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#150)

- [バイナリダンプ（od）](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#151)

- - [od](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#152)

- [その他](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#153)

- - [終了ステータス](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#154)
  - [Tips: 複数行のコメントアウト](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#155)
  - [Tips: 複数のコマンドを1行に記述](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#156)
  - [Tips: 深いディレクトリを一気に作成](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#157)
  - [Tips: 物理的な絶対パスを取得する](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#158)
  - [Tips: シンボリックリンクの実体に対するパスを取得する](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#159)
  - [Tips: テキストファイルを1行ずつ処理](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#160)

## ログイン



### ログイン時の設定

- ~/.bash_profile に記述する
  - 環境変数（exportするもの）

### ログインおよび対話モード時の設定

- ~/.bashrc (bash run command) に記述する
  - シェル変数
  - エイリアス（非対話モードでは引き継がれないので注意）
  - umask

## 標準入出力



### 各入出力の番号（ファイル・ディスクリプター）

- 0: 標準入力（<）
- 1: 標準出力（>）
- 2: 標準エラー出力

### 入力のリダイレクト

```
[番号/0]<ファイル名
```

- ファイルをオープンし、指定した番号で読み込めるようにする。
- 番号を省略すると標準入力からリダイレクトする。

### 出力のリダイレクト

```
[番号/1]>ファイル名    <-上書き
[番号/1]>>ファイル名   <-追記
```

- ファイルをオープンし、指定した番号で書き込めるようにする。
- 番号を省略すると標準出力からリダイレクトする。
- **注意：>を用いた場合、ファイルが存在するとファイルサイズは0になる。**

### ファイル・ディスクリプターの複製

```
[p]>&q
```

TODO: 分かりやすい説明

### Tips: 標準出力を画面とファイルに同時出力

```
コマンド | tee ファイル名
```

- **tee**は、標準入力を標準出力、およびファイル（複数も可）に同時出力するコマンド。

- 例

  ```
  $ ./a.out | tee log
  ```

### Tips: 標準出力を複数のファイルに同時出力

```
コマンド | tee ファイル名1 ファイル名2 ... > /dev/null
```

ファイルを上書きせず追記したい場合は以下

```
コマンド | tee -a ファイル名1 ファイル名2 ... > /dev/null
```

### Tips: 標準出力と標準エラー出力を同一ファイルに追記

```
コマンド >> log 2>&1
```

- 例1

  ```
  $ ./a.out >> log 2>&1
  ```

- 例2：表示しながら出力

  ```
  $ ./a.out 2>&1 | tee log
  ```

### Tips: 標準出力と標準エラー出力を別ファイルに出力

```
コマンド 1> 標準出力ファイル名 2> 標準エラー出力ファイル名
```

- 例

  ```
  ./a.out 1> file1 2> file2
  ```

### Tips: 標準エラー出力へ画面表示

```
echo "this is error" >&2
```

## 変数



Bashでは値を保持するものを「パラメータ」、その中で名前のついているものを「変数」と呼んでいる。

### 値の代入と参照

- 代入

  ```
  変数名=[値]
  ```

  - **注意：=の両側に空白を入れてはいけない！**
  - 値を指定しない場合は空文字列が代入される。

- 参照

  ```
  $変数名
  又は
  ${変数名}
  ```

  - 変数は特に宣言をしなくても参照することができる。
  - {}は基本的にあってもなくても構わないが、どこまでが変数か明確にしたい場合は{}をつける。

### 変数の開放

```
unset 変数名
```

### 読み取り専用の変数

```
readonly 変数名
又は
readonly 変数名=値
```

- これ以後、変数に値を代入しようとするとエラーになる

### 環境変数

```
現在のシェルから呼び出されるコマンドへ引き継がれる変数。
export 変数名
又は
export 変数名=値
```

で指定できる。

特定のコマンドのみに対して一時的に環境変数を設定したい場合は

```
変数名1=値1 変数名2=値2 ... コマンド
```

とする。たとえば、

```
PATH=/home/hoge/bin ./configure
```

のようにする。この場合、元の環境における変数には影響を与えない。

### 特殊パラメータ

| パラメータ名 | 意味                                                         |
| ------------ | ------------------------------------------------------------ |
| $0           | シェル又はシェルスクリプトの名前。                           |
| $数値        | シェルの引数（数値は1以上）。2桁以上の数値を指定する場合は{}で囲む必要がある。 |
| $*           | $1 $2 ...（全て）。                                          |
| $@           | 同上。                                                       |
| $#           | $1, $2, の個数。                                             |
| $$           | プロセスID。                                                 |
| $?           | 最後に実行したフォアグラウンドコマンドの終了ステータス。0なら正常終了。 |
| $!           | 最後に実行したバックグラウンドコマンドの終了ステータス。     |
| $-           | 現在のbashのオプションフラグ。**set**コマンドで変更可能。    |

### 特殊変数

- 自動設定

  | 変数名       | 意味                                                         |
  | ------------ | ------------------------------------------------------------ |
  | BASH_VERSION | bashのバージョン。                                           |
  | HOSTNAME     | 現在のホスト名。                                             |
  | LINENO       | シェルスクリプトの現在実行している行番号。デバッグなどで便利。 |
  | OLDPWD       | 1つ前の作業ディレクトリ。                                    |
  | PPID         | シェルの親のプロセスID。**読み込み専用。**                   |
  | PWD          | 現在の作業ディレクトリ。                                     |
  | RANDOM       | 0-32767までのランダム整数。RANDOMに値を代入すると初期化される。 |
  | SECONDS      | シェルが起動されてからの秒数。                               |

- ユーザ指定可能

  | 変数名 | 意味                                             |
  | ------ | ------------------------------------------------ |
  | IFS    | 区切り文字。デフォルトは「スペース＋タブ＋改行」 |
  | PS1    | プロンプト。デフォルトは "[\u@\h \W]\\$ "        |



### 変数の展開

#### 変数の値が設定されていないか空文字の場合、文字列に置換。

```
${変数名:-文字列}
```

- 注：コロンを忘れないように！

#### 変数の値が設定されていないか空文字の場合、文字列に置換して変数に代入。

```
${変数名:=文字列}
```

#### 変数の値が設定されていないか空文字の場合、エラーを表示して強制終了。

```
${変数名:?}                  // デフォルトのエラーメッセージ
${変数名:?エラーメッセージ}  // エラーメッセージを設定
```

#### 変数の値が設定されている場合、指定した文字列に置換（変数に代入はしない）。

```
${変数名:+文字列}
```

#### 変数の値の一部を取り出す。開始位置は0以上。長さを省略すると最後まで。

```
${変数名:開始位置:[長さ]}
```

- 変数が配列（後述）で変数名の末尾に[@]をつけると、部分配列を取り出すことができる。

#### 文字数。

```
${#変数名}
```

#### 変数の先頭がマッチした場合、最短マッチ部分を削除

```
${変数名#パターン}
```

#### 変数の先頭がマッチした場合、最長マッチ部分を削除

```
${変数名##パターン}
```

#### 変数の末尾がマッチした場合、最短マッチ部分を削除

```
${変数名%パターン}
```

#### 変数の末尾がマッチした場合、最長マッチ部分を削除

```
${変数名%%パターン}
```

#### パターンにマッチ（最長一致）した部分を文字列で置換する

```
${変数名/パターン/文字列}   ← 最初にマッチした部分のみ置換
${変数名//パターン/文字列}  ← 全てのマッチした部分を置換
```

#### パターンとして使える文字

- 一般的な正規表現は使えないので注意。

  | *     | 任意の文字列       |
  | ----- | ------------------ |
  | ?     | 任意の一文字       |
  | [...] | カッコ内のいずれか |

- 例

  ```
  $ TEMP=123abc123xyz
  $ echo ${TEMP#??}
  3abc123xyz
  $ echo ${TEMP#*}
  123abc123xyz
  $ echo ${TEMP##*}
   
  $ echo ${TEMP#1*3}
  abc123xyz
  $ echo ${TEMP##1*3}
  xyz
  ```

#### 間接展開：変数の値を変数名として展開

```
${!変数名}
```

- 例

  ```
  $ A=BBB
  $ BBB=1
  $ echo ${A}
  BBB
  $ echo ${!A}
  1
  ```

#### 大文字へ変換

```
${変数名^^}
```

#### 一文字目のみ大文字へ変換

```
${変数名^}
```

#### 小文字へ変換

```
${変数名,,}
```

#### 一文字目のみ小文字へ変換

```
${変数名,}
```

### Tips: テンポラリファイル名

```
FILE=temp.$$
```

プロセスIDは一意に決まるので、重複しないファイル名を生成することができる。

### Tips: 未定義の変数を参照するとエラーを吐くようにする

```
set -u
```

### Tips: 拡張子の変更

```
PNG=abc.png
GIF=${PNG%.png}.gif
```

### Tips: パスからファイル名のみを取り出す

```
$ FILE=/home/hoge/test.dat
$ echo ${FILE##*/}
test.dat
```

- basename

  というコマンドを使う方法もある。

  ```
  $ basename /home/hoge/test.dat
  test.dat
  ```

### Tips: パスからディレクトリ名のみを取り出す

```
FILE=/home/hoge/test.dat
DIR=${FILE%/*}
```

### Tips: パスから拡張子のみを取り出す

```
FILE=abc.png
EXT=${FILE##*.}
```

### Tips: 文字列の末尾の文字を取り出す

```
$ NUM=12345
$ echo ${NUM:${#NUM}-1:1}
5
```

### Tips: パスが相対パスなら絶対パスへ変換

```
[ "${DIR:0:1}" != "/" ] && DIR=$(pwd)/${DIR}
```

### Tips: 特定の文字の出現数をカウントする

- "i"の数をカウントする例

  ```
  $ A="This is a pen"
  $ TMP=$( echo ${A} | sed -e 's/[^i]//g' )
  $ echo ${#TMP}
  2
  ```

## 配列



### 個々の要素への値の代入

```
配列名[要素番号]=[値]
```

- 注意：=の両側に空白を入れてはいけない！

- 特に宣言をしなくても配列に代入することができます。要素番号は0以上で指定する。

- 例

  ```
  A[0]="abc"
  A[1]="ABC"
  A[2]=-100
  ```

### 個々の要素の値の参照

```
${配列名[要素番号]}
```

- 変数と同様、特に宣言をしなくても配列を参照することができる。要素番号は0以上で指定する。

- 例

  ```
  echo ${A[2]}
  echo ${A[1]}
  echo ${A[0]}
  ```

### 最初の要素の値の参照

```
${配列名}
```

これは ${配列名[0]} と同じ意味である。

### 一括代入

```
配列名=( 要素1 要素2 ... )
```

- 配列に値を一気に代入する。空白が配列の切れ目になる。

- 例1

  ```
  array=( Jan Feb Mar Apr )
  echo ${array[2]}
  ```

- 例2: 現在のディレクトリの内容を配列に格納

  ```
  LS_RESULT=( $(ls) )
  ```

  - この例は後述のforループで用いると有用。

- 例3: 配列を空にする

  ```
  array=( )
  ```

### 要素番号を指定した一括代入

一括代入で要素を指定する代わりに

```
[要素番号]=要素
```

とすると、要素番号を指定して代入することができる。たとえば、

```
A=( DJF [2]=MAM SON )
```

は "DJF" 空 "MAM" "SON" の順に格納される

### 一括参照

```
${配列名[@]}
又は
${配列名[*]}
```

- 厳密には上の二つの意味は異なる。
  - ${配列名[@]}: "${配列名[0]}" "${配列名[1]}" "${配列名[2]}"...
  - ${配列名[*]}: "${配列名[0]}<SEP>${配列名[1]}<SEP>${配列名[2]}..."
    - <SEP>は特殊変数IFSの第1文字目。

- 例1

  ```
  array=( Jan Feb Mar Apr )
  echo ${array[@]} 
  ```

- 例2: 現在のディレクトリの内容を配列に格納して表示

  ```
  LS_RESULT=( $(ls) )
  for FILE in ${LS_RESULT[@]} ; do
      echo ${FILE}
  done
  ```

### 配列の要素数の参照

```
${#配列名[@]}
```

- 例1

  ```
  A=( DJF JJA MAM SON )
  echo ${#A[@]}
  ```

- 例2: 配列の中身を表示（for ～ in ～ を使わない例）

  ```
  A=( DJF JJA MAM SON )
  for(( i=0; ${i}<=${#A[@]}-1; i=${i}+1 )) ; do
      echo ${A[$i]}
  done
  ```

### 値が存在する配列要素のインデックスを参照

```
${!配列名[@]}
```

- 例1

  ```
  A=( DJF [2]=MAM SON )  # "DJF" 空 "MAM" "SON" と格納される
  echo ${!A[@]}
  for i in ${!A[@]} ; do
    echo ${A[$i]}        # 値がある配列のみ表示
  done
  ```

### Tips: 配列の末尾へ要素を追加する。

- その1

  ```
  A=( DJF JJA MAM )
  A=( ${A[@]} SON )
  ```

- その2

  ```
  A=( DJF JJA MAM )
  A[${#A[@]}]=SON
  ```

- その3

  ```
  A=( DJF JJA MAM )
  A+=( SON )
  ```

### Tips: 部分配列を取り出す

```
B=( "${A[@]:2:3}" )
```

- この場合、B[0]=A[2], B[1]=A[3], B[2]=A[4]になる。

### Tips: カンマ区切りの文字列を配列に変換する

```
A=apple,banana,grape
B=( $( echo ${A} | sed -e "s|,| |g" ) )
```

### Tips: 配列をカンマ区切りの文字列に変換する

```
A[0]=apple
A[1]=banana
A[2]=grape
for TMP in ${A[@]} ; do
  B=${B}${B:+,}${TMP}
done
```

### Tips: 重複する配列の要素を削除する

```
AR=( AAA CCC BBB AAA CCC )
AR=( $( IFS=$'\n' ; echo "${AR[*]}" | sort | uniq ; ) )
```

- 同時にソートもされる。

### Tips: 2つの配列、双方に含まれる要素を抜き出した配列を作成する。

```
IFS=$'\n'      // 配列の区切り文字を改行に変更
配列名=( $( { echo "${配列名1[*]}" ; echo "${配列名2[*]}" } | sort | uniq -d ) )
```

### Tips: 2つの配列、双方に含まれる要素**以外**を抜き出した配列を作成する。

```
IFS=$'\n'      // 配列の区切り文字を改行に変更
配列名=( $( { echo "${配列名1[*]}" ; echo "${配列名2[*]}" } | sort | uniq -u ) )
```

## 連想配列



- Bash 4以降のみ利用可能

### 個々の要素への値の代入

```
連想配列名["key名"]=[値]
```

- 例

  ```
  A["Tree"]="Ki"
  A["Forest"]="Mori"
  ```

### 個々の要素の値の参照

```
${連想配列名["key名"]}
```

- 例

  ```
  echo ${A["Tree"]}
  echo ${A["Forest"]}
  ```

### 一括代入

```
連想配列名=( ["key-1名"]=値-1 ["key-2名"]=値-2 ... )
```

## 展開



展開の優先度は以下の通り。

- ブレース展開
- チルダ展開
- パラメータ・変数・算術式展開
- コマンド置換 (左から右へ)
- 単語分割
- パス名展開。

### ブレース展開

任意の文字列を生成する展開。{ } 内でコンマで区切って文字列を指定すると、それら全ての組み合わせで文字列を生成する。右から展開される。入れ子も可能。以下の例のように文字列の一部が共通の場合に威力を発揮する。

- 例1

  ```
  $ rm test{A,BB,CCC}
  $ rm testA testBB testCCC  // 上と同じ意味
  ```

- 例2

  ```
  $ ls /home/hoge/{bin,lib,exe}
  $ ls /home/hoge/bin /home/hoge/lib /home/hoge/exe  // 上と同じ意味
  ```

- 例3

  ```
  $ echo a{a,b,{c,cc,ccc}}
  aa ab ac acc accc
  ```

規則性のある文字列は、..を利用することも可能。

- 例4

  ```
  $ echo {1..5}
  1 2 3 4 5
  $ echo {5..1}
  5 4 3 2 1
  $ echo {001..005}
  001 002 003 004 005
  $ echo {a..z}
  a b c d e f g h i j k l m n o p q r s t u v w x y z
  $ echo {00..23}:{0..5}{0..9}
  00:00 00:01 00:02 00:03 00:04 00:05 00:06 00:07
  ...(中略)...
  23:52 23:53 23:54 23:55 23:56 23:57 23:58 23:59
  ```

### チルダ展開

チルダで始まる単語は、チルダ展開の候補となる。チルダ展開文法を含む単語には、チルダ展開以外の文字列を含んではいけない。

#### 現在ログインしているユーザのホームディレクトリ（$HOME）に置換

```
~
~/
```

#### 指定したログイン名のユーザのホームディレクトリに置換

```
~ログイン名
~ログイン名/
```

- 該当するログイン名がない場合は置換は実施されない。

#### 現在のワーキングディレクトリ（PWD）に置換

```
~+
~+/
```

#### 一つ前のワーキングディレクトリ（OLDPWD）に置換

```
~-
~-/
```

### パラメータ展開

[変数の展開](http://kodama.fubuki.info/wiki/wiki.cgi/bash/tips?lang=jp#param_expansion)を参照。

## 条件分岐



### if文

```
if 処理A ; then
  処理1
elif 処理B ; then
  処理2
else
  処理0
fi
```

- 「elif～処理2」と「else～処理0」は省略可能。

- 「elif～処理2」は何度でも繰り返し可能。

- 処理Aの終了ステータスが0の場合、処理1が実行される。

- 処理Bの終了ステータスが0の場合、処理2が実行される。

- どのif,elifでも処理が実行されない場合、処理0が実行される。

- 例

  ```
  A="ABC"
  if [ "${A}" = "abc" ] ; then
    echo "if ok"
  elif [ "${A}" = "ABC" ]
    echo "elif ok"
  else
    echo "else ok"
  fi
  ```

  - これを実行すると"elif ok"と表示される。
  - ちなみに **[** はれっきとしたコマンド。

### case文

```
case 変数 in
パターン1)
  処理1
  ;;
パターン2)
  処理2
  ;;
 *)
  デフォルト処理
  ;;
esac
```

### 条件式

[[やtestコマンドで利用可能。

#### ファイル関連

- -e ファイル名

  ファイルが存在すれば真。

- -f ファイル名

  ファイルが存在し、通常ファイルであれば真。

- -d ファイル名

  ファイルが存在し、ディレクトリであれば真。

- -L ファイル名

  ファイルが存在し、シンボリックリンクであれば真。

- -r ファイル名

  ファイルが存在し、読み込み可能であれば真。

- -w ファイル名

  ファイルが存在し、書き込み可能であれば真。

- -x ファイル名

  ファイルが存在し、実行可能であれば真。

- -s ファイル名

  ファイルが存在し、サイズが0より大きければ真。

#### 文字列

- -n 文字列

  文字列の長さが0でなければ真。

- 文字列1 == 文字列2

  文字列1と文字列2が同じなら真。代わりに=も利用可能。

- 文字列1 != 文字列2

  文字列1と文字列2が異なれば真。

以下は利用例：

```
if [[ -f test.txt ]］ ; then
  echo "Regular file exists!"
else
  echo "Regular file does not exist!"
fi
```

### 正規表現

```
[[ 文字列 =~ 正規表現 ]］
```

の形で用いる。以下、例：

- 例1

  ```
  if [[ "abcde" =~ ^ab ]］ ; then 
    マッチした場合・・・
  endif
  ```

- 例2

  ```
  if [[ "12345" =~ ^1([2-4]+) ]］ ; then 
    echo ${BASH_REMATCH[0]}  // マッチ文字列全体を表示
    echo ${BASH_REMATCH[1]}  // マッチした1番目の括弧内を表示
  endif
  ```

マッチしない場合の条件は以下：

```
[[ ! 文字列 =~ 正規表現 ]］
```

#### 特別な意味を持った文字

- ^

  行頭

- $

  行末

- .

  任意の文字

- *

  0文字以上

- {n}

  n文字

### Tips: シンボリックリンクが存在し、リンク先が存在しない場合に処理を行う

```
if [[ -L file-name -a ! -f file-name ]］ ; 
  ・・・処理・・・
fi
```

### Tips: 複雑なand/or条件

- [] の外側で && や || を使うことで複雑な表現が可能。

  ```
  if [ ${AAA} -eq 1 -o ${AAA} -eq 2 ] && [ ${BBB} -eq 1 ]; then
    ...
  fi
  ```

## 繰り返し



### for文（1）

```
for 変数名 in 値1 値2 ... ; do
  処理
done
```

- 変数に値1, 値2... が順番に展開されながら処理を繰り返す。

### for文（2）

```
for(( 算術式1; 算術式2; 算術式3 )) ; do
  処理
done
```

- 算術式1: 最初に評価される。
- 算術式2: 繰り返しの度に評価される。これが真の間繰り返す。
- 算術式3: 繰り返しの度に最後に評価される。
- 算術式で使える演算子は「演算」の項を参照。

### while

```
while 処理A ; do
  処理1
done
```

- 処理Aが終了ステータス0を返しつづける間、処理1を繰り返し実行する。

### ループ途中からループを脱出する

```
break [深さ]
```

- for, while, until, select ループから脱出します。
- 深さは脱出したいループの深さ。省略時は1、つまり一番内側のループから抜ける。

### ループ途中からループ先頭に戻る

```
continue [深さ]
```

- for, while, until, select ループの先頭に戻る。
- 深さは先頭に戻りたいループの深さ。省略時は1、つまり一番内側のループの先頭に戻る。

### Tips: for i in ～ に渡せる連番を生成

```
seq 1 30
seq -w 1 30     // 同じ桁数になるように0を埋める
echo ${01..30}  // ブレース展開を利用
```

- 例

  ```
  for i in $( seq -w 1 30 ) ; do
    echo $i
  done
  ```

  - for(( i=1; i<=30; i=$i+1 )) では0を埋めることができない。

### Tips: 無限ループ

```
while :
do
  (処理)
done
```

- コロン(:)はヌルコマンド。これは常にtrueを返す。

## 日付処理（date）



### Tips: 特定の年月日を整形して出力

```
YMD="2001-03-05"
date --date "${YMD}" +%Y%m%d
```

### Tips: 特定の年の年月日を整形して出力

```
YEAR=2004
for(( d=0 ; $d<=365; d=$d+1 )) ; do
    date --date "${YEAR}-01-01 +${d}days" +%Y%m%d
done
```

### Tips: 指定した年に含まれる日数を出力

```
YEAR=2000
date --date "${YEAR}-01-01 +1year-1days" +%j
```

### Tips: 指定した年月に含まれる日数を出力

```
YEAR=2000
MONTH=2
date --date "${YEAR}-${MONTH}-01 +1month-1days" +%d
```

## 演算（let, expr, bc 等）



### bash算術式（優先度順）

- 整数のみ利用可能。

- man bash

   

  で

   

  ARITHMETIC EVALUATION

   

  の項を参照のこと。

  | 演算子                                       | 意味                                                         |
  | -------------------------------------------- | ------------------------------------------------------------ |
  | v++, v--                                     | 後置インクリメント, 後置デクリメント（つまり参照してから1を足す or 引く） |
  | ++v, --v                                     | 前置インクリメント, 前置デクリメント（つまり1を足した or 引いた後参照） |
  | -, +                                         | 単項-演算, 単項+演算（つまり単なる符号）                     |
  | !, ~                                         | 論理否定, ビット毎の否定                                     |
  | **                                           | べき乗                                                       |
  | *, /, %                                      | 乗法, 除法, 剰余                                             |
  | +, -                                         | 加算, 減算                                                   |
  | <<, >>                                       | 左ビットシフト, 右ビットシフト                               |
  | <=, >=, <, >                                 | 比較                                                         |
  | ==, !=                                       | 比較（等価, 不等価）                                         |
  | &                                            | ビット毎のAND演算                                            |
  | ^                                            | ビット毎の排他的OR演算                                       |
  | ｜                                           | ビット毎のOR演算                                             |
  | &&                                           | 論理積                                                       |
  | ｜｜                                         | 論理和                                                       |
  | expr?expr:expr                               | 条件付き演算                                                 |
  | =, *=, /=, %=, +=, -=, <<=, >>=, &=, ^=, ｜= | 代入                                                         |

  

#### 利用例

- 算術式の評価: let 算術式　又は　((算術式))
- 算術式の評価+参照: $((算術式))

#### Tips: 変数に1を加える

```
変数名++    <-参照してから1を加える
++変数名    <-先に変数に1を加えてから参照する
```

- 例

  ```
  $ A=5
  $ echo $((A++))
  5
  $ echo $A
  6
  $ A=5
  $ echo $((++A))
  6
  $ echo $A
  6
  ```

### let, expr, bc の使い分け

- let: bash算術式の評価（整数のみ）、bashの組み込みコマンド

- expr: 整数のみ

- bc: 小数もOK、複雑な式に対応、指数形式には対応していない

  - bcでも手に余る場合はperl等を使えばよい

    ```
    perl -e "print 演算式"
    ```

### let

```
let (算術式)
((算術式))  　　  <-上と等価の別表現
```

- 算術式は上を参照

- 変数名に$はつけない！

- 例

  ```
  $ A=2
  $ let A++
  ```

### expr

```
expr (値1) (演算子) (値2)
```

- 値1, 値2は整数である必要がある。
- 演算子は「演算子一覧」を参照。
- 条件式の場合、真ならば1、偽ならば0を返す。

### Tips: 桁数を指定した計算

```
echo "scale=5; 40000/3000" | bc
```

### Tips: 計算結果を指数表記で表示

```
echo "scale=20; 1/30000" | bc | xargs printf "%.5e\n" 
```

### Tips: 小数同士の比較

```
if [ $( echo "${VALUE} >= 0" | bc ) -eq 1 ] ; then
  ...(VALUE>=0の時の処理)...
else
  ...(VALUE<0の時の処理)...
fi
```

### Tips: 常用対数の計算

```
echo "scale=5; l(12345)/l(10)" | bc -l
```

## ファイル



### デフォルトの権限

- デフォルトの権限を表示（666から値を引く）

  ```
  umask
  ```

- デフォルトの権限を設定

  ```
  umask 値
  ```

### Tips: ディレクトリ名を指定したときディレクトリ自体を表示する

```
ls -d
```

## diff



### Tips: 空白の違いを無視する

```
diff -EwB file-1 file-2
```

### Tips: ディレクトリごと中身を比較する

```
diff dir-1 fir-2
```

## テキスト表示（cat/tac）



### catとtac

catはそのまま表示、tacは逆順に表示。

```
cat ファイル名
tac ファイル名
```

## テキストフィルタ（cut/paste/awk/printf/tr）



### cut: 各行から選択した部分を取り出す

```
cut [-b byte] [-c word] [-f field [ -d sep ] ]  [file-1 file-2 ...]
```

- b: バイト単位で取り出す

- c: 文字数単位で取り出す

- f: フィールド単位で取り出す。

  - d: 区切り文字 *sep* はタブがデフォルト。

- フィールドの指定方法(フィールド番号≧1)：バイト・文字数についても同様。

  | -f 3   | 3番目のフィールド        |
  | ------ | ------------------------ |
  | -f 2-5 | 2-5番目のフィールド      |
  | -f 1,5 | 1番目と5番目のフィールド |
  | -f 5-  | 5番目以降のフィールド    |

- ファイル名を指定しない場合、又は "-" を指定した場合は標準入力から読み込む。

### paste: ファイルの横結合（行単位での結合）

```
paste [-d sep] [file-1 file-2 ...]
```

- d: 区切り文字 *sep* はタブがデフォルト。
- ファイル名を指定しない場合、又は "-" を指定した場合は標準入力から読み込む。

### Tips: 列を指定して文字列を取り出す

- 2列目と4列目を取り出す例

  ```
  cat test.txt | awk '{ print $2 $4 }'
  ```

### Tips: 指定した区切り文字で区切られた文字列から最後のフィールドを取り出す

- 拡張子を取り出す例（ファイル本体に.が入っていても大丈夫）

  ```
  echo "test0.1.txt" | awk -F . '{ print $NF }'
  ```

### Tips: マッチしている以外の行を取り出す

```
grep -v ～
```

### Tips: マッチしたファイルのファイル名を表示する

```
grep -l ～
```

### Tips: 桁数を指定して数値の先頭を0で埋める

- その1

  ```
  VALUE=12
  VALUE=$( printf "%04d" ${VALUE} )
  ```

- その2

  ```
  VALUE=12
  VALUE=$( echo ${VALUE} | awk '{ printf("%04d\n",$1) }' )
  ```

### Tips: 先頭の0を削除する

```
VALUE=0012
VALUE=$( echo ${VALUE} | awk '{ printf("%d\n",$1) }' )
```

### Tips: 右詰め

```
VALUE=12
VALUE=$( printf "%4d" ${VALUE} )
```

### Tips: 右詰めその２

```
awk '{ printf("%20s",$1) }'
```

### Tips: 左詰め

```
VALUE=12
VALUE=$( printf "%-4d" ${VALUE} )
```

### Tips: 連続する空白を1つにする

```
echo "a  b c   d" | tr -s " "
```

- cut -f で処理する場合に便利

### Tips: 小文字を大文字に変換

```
$ echo "This is a pen." | tr "a-z" "A-Z" 
```

### Tips: 特定の列の数値に対して演算を行う

```
echo "aaa 10 20 30" | awk '{ print $1, $2, $3/2, ($4+1)*3 }' 
```

### Tips: awkへ変数を渡す

オプション -v で awk 内で通用する変数を定義できる。

```
echo "aaa 10 20 30" | awk -v A=5 '{ print $1, $2, $3/A, ($4+1)*3 }' 
```

## テキストフィルタ（sed）



### Tips: 先頭行を削除する

```
sed (ファイル名) -e '1d'
```

### Tips: 任意の行を削除する

```
sed (ファイル名) -e '3,7d'
```

### Tips: 最終行を削除する

```
sed (ファイル名) -e '$d'
```

### Tips: 空行（空白のみの行も含む）を削除する

```
sed (ファイル名) -e '/^ *$/d'
```

### Tips: 1行目のみについて、マッチした場合削除

```
sed (ファイル名) -e '1{ /正規表現/d }'
```

### Tips: マッチ行に囲まれた複数行を取り出す

- 「正規表現(最初)」～「正規表現(最後)」のみを表示する

  ```
  sed (ファイル名) -e "/正規表現(最初)/,/正規表現(最後)/p" -e d
  ```

### Tips: マッチ行に囲まれた複数行を削除する

- 「正規表現(最初)」～「正規表現(最後)」を削除

  ```
  sed (ファイル名) -e "/正規表現(最初)/,/正規表現(最後)/d"
  ```

### Tips: 行を指定して文字列を取り出す

- 5行目を取り出す例

  ```
  sed (ファイル名) -e "5,5p" -e d
  ```

### Tips: 行の最後尾に文字列を追加する

```
sed (ファイル名) "s/$/文字列/"
```

### Tips: 空白区切りの文字列に一定間隔で改行を挿入する

```
STR="1 2 3 4 5 6 7 8 9 10 11 12"
N=3
STR=$( echo ${STR} | sed -e "s/\(\([^ ]\+ \+\)\{${N}\}\)/\1\n/g" )
echo "${STR}"
```

- 注意：echo時に""で囲まないと改行は空白として扱われるので注意！

### Tips: マッチした行の次の次の行のみを取り出す

- "abc"にマッチした行の次の次の行を取り出す例

  ```
  sed -n -e '/abc/{n;n;p;}'
  ```

  - そんなに自信があるわけではないが・・・

## find



### -typeのオプション

- d

  ディレクトリ

- f

  ファイル

- l

  シンボリックリンク

- 例：シンボリックリンクのみ検索する

  ```
  find . -type l
  ```

### Tips: 複数の条件で検索する

```
find . -name "name1" -o -name "name2" -o -name "name3" ...
```

### Tips: findで検索したディレクトリを消去

```
find output_* -name "200406.new.prun2010.gl05" -type d -print0 | xargs -0 rm -r 
```

- find の -print0 は空白の代わりにヌル文字を区切り文字とする。
- xargsの -0 はヌル文字を区切り文字とする。
- こうすることでディレクトリリストに空白等の特殊文字が入っていても対処できる。

### Tips: ディレクトリのみの権限を変更（再帰的）

```
find * -type d -exec chmod o+x {} \;
```

- {}の部分にfindでmatchしたディレクトリ名が置き換わる。
- ;は-execの終端符、ただしエスケープが必要。

### Tips: 結果をアルファベット順に表示

- findの結果はアルファベット順を保証していないようなので sort コマンドを利用して並べ替える。

  - 例

    ```
    find . -name abc | sort
    ```

## バイナリダンプ（od）



### od

```
od ファイル名
```

一番左端に入力ファイルでの位置、その右側にデータの値が表示される。 同じ内容が続く場合は*でまとめられるが。不要な場合はオプション -v を利用する。

## その他



### 終了ステータス

- 0: 正常終了

- 0以外: 異常終了

- command1

   

  が正常終了したら

   

  command2

   

  を実行する

  ```
  command1 && command2
  ```

- command1

   

  が異常終了したら

   

  command2

   

  を実行する

  ```
  command1 || command2
  ```

### Tips: 複数行のコメントアウト

```
: <<'#_COMMENT_OUT_'
～この間の処理は全て無効～
#_COMMENT_OUT_
```

ちなみに *:* は「何もしないコマンド」。このコマンドに標準入力でコメントにしたい部分を読み込む形で、複数行コメントを実現している。

### Tips: 複数のコマンドを1行に記述

```
{ コマンド1; コマンド2; ... }
```

最後のコマンドの後ろにも;が必要なので注意。

### Tips: 深いディレクトリを一気に作成

```
mkdir -p dir1/dir2/dir3
```

ディレクトリが既に存在する場合でもエラーにはならない。

### Tips: 物理的な絶対パスを取得する

```
pwd -P
```

シンボリックリンクを使っている場合は解決される。

### Tips: シンボリックリンクの実体に対するパスを取得する

```
readlink -f sdir
```

### Tips: テキストファイルを1行ずつ処理

```
cat ファイル名 | while read LINE ; do
  echo ${LINE}
done
```

- 最終行に改行が含まれない場合、読み込まれないことに注意。
- パイプラインの先は別プロセスなので、ループ内部で変更された変数はループ外に影響を与えないので要注意。
  - 標準出力を介するのが正解か