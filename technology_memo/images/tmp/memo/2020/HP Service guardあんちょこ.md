# HP Service guardあんちょこ(HP-UX11iv3)

### クラスタの起動

・両系起動する

```
# cmruncl -v
```

・片系起動する

```
# cmrunnode -v
```

### クラスタの状態の確認

```
# cmviewcl
```

### パッケージをクラスターに組み込む

```
# cmapplyconf
```

### パッケージ構成ファイルの整合性を検証

```
# cmcheckconf
```

### テンプレート作成

```
# cmmakepkg
```

### パッケージの起動

```
# cmrunpkg -v package1 -n node1
```

### 自動でのフェールオーバ/フェールバック有効化設定

```
# cmmodpkg -v -e パッケージ名
```

### パッケージの停止

```
# cmhaltpkg -v パッケージ名 -n ノード名
```

### クラスタの停止

・両系停止する

```
# cmhaltcl -v
```
※全パッケージを停止しないとクラスタは停止できない

・片系停止する

```
# cmhaltnode -v
```

### ログ

#### クラスタ関連

`/var/log/messages`

#### パッケージ関連

`/usr/local/cmcluster/log/`

設定次第であるが基本はこのあたり。