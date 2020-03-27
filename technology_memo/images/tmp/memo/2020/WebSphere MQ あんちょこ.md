# WebSphere MQ あんちょこ

## ・全キュー・マネージャーの状態確認

```
# dspmq
```

##・オブジェクト権限の表示

```
# dspmqaut -m $QMNAME -g $GROUP -t $OBJECT-TYPE -n $OBJECT-NAME

# dmpmqaut -m $QMNAME -g $GROUP -t $OBJECT-TYPE
```

## ・エラーログ

```
/var/mqm/errors
```

## ・プロンプト起動

```
# runmqsc $QMNAME
```

##・runmqscプロンプトの終了
```
# end
```

## ・キュー・マネージャーの作成

```
CRTMQM $QMNAME
```

##・キュー・マネージャーの状態確認

```
DISPLAY QMSTATUS
```

## ・キュー・マネージャー情報の確認

```
DISPLAY QMGR
```

## ・キュー・マネージャーの起動

```
# strmqm $QMNAME
```

## ・キュー・マネージャーの停止

```
# endmqm $QMNAME
```

## ・リスナーの状態確認

```
DISPLAY LSSTATUS(*) ALL
```

## ・リスナー情報の確認

```
DISPLAY LISTENER(*) ALL
```

## ・リスナーの起動

```
START LISTENER
```

## ・リスナーの停止

```
STOP LISTENER
```

##・チャネルの状態確認

```
DISPLAY CHSTATUS(*) ALL
```

## ・チャネル情報の確認

```
DISPLAY CHANNEL(*) ALL
```

## ・チャネルの接続

```
START CHANNEL(${CHA_NAME})
```

## ・チャネルの切断

```
STOP CHANNEL(${CHA_NAME})
```

## ・認証情報の確認

```
DISPLAY AUTHINFO(*) ALL
```

## ・クラスター・チャネル情報の確認

```
DISPLAY CLUSQMGR(*) ALL
```

## ・MQプロセスの属性確認

```
DISPLAY PROCESS(*) ALL
```

## ・ネームリスト情報の確認

```
DISPLAY NAMELIST(*) ALL
```

## ・キューの状態確認

```
DISPLAY QSTATUS(*) ALL
```

## ・全キュー情報の確認

```
DISPLAY QUEUE(*) ALL
```

## ・別名キュー情報の確認

```
DISPLAY QALIAS(*) ALL
```

## ・クラスター・キュー情報の確認

```
DISPLAY QCLUSTER(*) ALL
```

## ・ローカル・キュー情報の確認

```
DISPLAY QLOCAL(*) ALL
```

## ・モデル・キュー情報の確認

```
DISPLAY QMODEL(*) ALL
```

## ・リモート・キュー情報の確認

```
DISPLAY QREMOTE(*) ALL
```

## ・キュー内メッセージ数の確認

```
DISPLAY QL($QNAME) CURDEPTH
```

## ・キュー内、全メッセージの削除

```
CLEAR QL($QNAME)
```

## ・接続情報の確認

```
DISPLAY CONN(*) ALL
```

## ・サービスの状態確認

```
DISPLAY SVSTATUS(*) ALL
```

## ・サービス情報の確認

```
DISPLAY SERVICE(*) ALL
```

## ・トピックの状態確認

```
DISPLAY TPSTATUS(*) ALL
```

## ・トピック情報の確認

```
DISPLAY TOPIC(*) ALL
```

## ・サブスクリプションの状態確認

```
DISPLAY SBSTATUS(*) ALL
```

## ・サブスクリプション情報の確認

```
DISPLAY SUB(*) ALL
```

## ・ローカルキューの作成

```
DEFINE QLOCAL($QNAME) DESCR('$QNAME for $QMNAME')
```

## ・キューの構成変更
MAXDEPTHを2000に変更、その結果を確認する(設定したDESCRパラメータも合わせて確認している)。

```
ALTER QLOCAL($QNAME) maxdepth(2000)
```

## ・別名キューの作成

```
DEFINE QALIAS($ALIAS_QNAME) TARGET($LOCAL_QNAME)
```

## ・別名キューへのputを禁止

```
ALTET QALIAS($ALIAS_QNAME) PUT(disabled)
```

 ## ・ローカル・キューの削除 – DELETEコマンド

```
DELETE QLOCAL($QNAME)
```

## ・キュー内のメッセージクリア

```
CLEAR QLOCAL($QNAME)
```

## ・キューにメッセージが存在していても強制的にキュー削除

```
DELETE QLOCAL($QNAME) PURGE
```

## ・チャネルへping

```
PING CHANNEL($CHNAME)
```

なお、いちいちrunmqscプロンプトに変えるのが面倒な時は以下のようにパイプで渡すことも可能です。
と言うか運用スクリプトに組み込むならこっちじゃないと面倒ですね。

```
# echo “DISPLAY QMSTATUS” | runmqsc $QMNAME
```

【MQ】設定を調べたい
一部不完全ですが、以下のようなスクリプトで MQ の設定情報が表示できます。

```
echo "---------------------------------------------------------"
echo "DISPLAY AUTHINFO(*) ALL" | runmqsc _QMGR_ 
echo "---------------------------------------------------------" 
echo "DISPLAY CHANNEL(*)" | runmqsc _QMGR_ 
echo "---------------------------------------------------------" 
echo "DISPLAY CHANNEL(*) ALL" | runmqsc _QMGR_ 
echo "---------------------------------------------------------" 
echo "DISPLAY CHSTATUS(*) ALL" | runmqsc _QMGR_ 
echo "---------------------------------------------------------" 
#echo "DISPLAY CLUS_QMGR_" | runmqsc QMGR 
echo "---------------------------------------------------------" 
echo "DISPLAY PROCESS(*) ALL" | runmqsc _QMGR_ 
echo "---------------------------------------------------------" 
echo "DISPLAY NAMELIST(*) ALL" | runmqsc _QMGR_ 
echo "---------------------------------------------------------" 
echo "DISPLAY QALIAS(*) ALL" | runmqsc _QMGR_ 
echo "---------------------------------------------------------" 
#echo "DISPLAY QCLUSTER" | runmqsc _QMGR_ 
echo "---------------------------------------------------------" 
echo "DISPLAY QLOCAL(*) ALL" | runmqsc _QMGR_ 
echo "---------------------------------------------------------" 
echo "DISPLAY _QMGR_ ALL" | runmqsc QMGR 
echo "---------------------------------------------------------" 
echo "DISPLAY QMODEL(*) ALL" | runmqsc _QMGR_ 
echo "---------------------------------------------------------" 
echo "DISPLAY QREMOTE(*) ALL" | runmqsc _QMGR_ 
echo "---------------------------------------------------------" 
echo "DISPLAY QUEUE(*)" | runmqsc _QMGR_ 
echo "---------------------------------------------------------" 
echo "DISPLAY QUEUE(*) ALL" | runmqsc _QMGR_ 
echo "---------------------------------------------------------" 
echo "DISPLAY QSTATUS(*) ALL" | runmqsc _QMGR_ 
echo "---------------------------------------------------------" 
echo "DISPLAY CONN(*) ALL" | runmqsc _QMGR_ 
echo "---------------------------------------------------------" 
echo "DISPLAY SERVICE(*) ALL" | runmqsc _QMGR_ 
echo "---------------------------------------------------------" 
echo "DISPLAY LISTENER(*) ALL" | runmqsc _QMGR_ 
echo "---------------------------------------------------------" 
#echo "DISPLAY SVSTATUS" | runmqsc _QMGR_ 
echo "---------------------------------------------------------" 
echo "DISPLAY LSSTATUS(*) ALL" | runmqsc _QMGR_ 
echo "---------------------------------------------------------" 
echo "DISPLAY QMSTATUS ALL" | runmqsc _QMGR_ 
echo "---------------------------------------------------------" 
```


