---
layout: default
title: findコマンドで-execオプションを使用する時の最後の「{} ;」ってなんだっけ？
---

# findコマンドで-execオプションを使用する時の最後の「{} ;」ってなんだっけ？

私は、-execじゃなく殆どxargsを使ってますが、シェル改修で-execを久々に見ました。
過去、-execオプションも使ってましたが最後の「{} ;」ってなんだっけ？
と素朴に思いました。
まあ、manを見ろって話なんですが。

## findのman

```console:man抜粋
-exec command ;
>すべてコマンドに対する引き数と見なされる。文字列 `{}` は、
>それがコマンドの引き数中に現れるすべての場所で、現在処理中のファイル名に
>置き換えられる。
```

パイプ("|") 処理における展開("-") を find 内でいうと "{}" 
になるってことなんですかね。

```console:man抜粋
manを更に読み進めると「-exec {} +」ってのもあったんですね。

>選択したファイルに対して指定したコマンドを実行するが、
>コマンドラインを形成するとき、選択した各ファイル名をコマンドラインの末尾に
>追加して行くという方法を取る
```

「-exec {} ;」と「-exec {} +」の違いは、ググったら
>「-exec {} +」はファイルをまとめて実行する（グループ実行）
>全ファイルのパスに置き換えられる。
>「-exec {} ;」はファイルを１つずつ実行する（単体実行）
>ファイルパスにならない

ただし、-exec {} ; より xargs が推奨みたいですね。
理由は、find の -exec では 1つのファイルに対して 1回コマンドを実行するが、
xargs ならカーネルが許す限り長いコマンドを作って実行するため、
-exec より xargs の方が fork&exec の回数が少なくなって効率的なはずだそうです。

実際ファイル数が数万個ともなると実行時間に差異が出てくるので分かると思います。

## find比較

### execとxargsとの比較

```
time find /var -type f -exec ls -l {} ; > /dev/null
real    0m23.684s
user    0m6.679s
sys     0m15.602s

time find /var -type f | xargs ls -l > /dev/null
real    0m0.441s
user    0m0.345s
sys     0m0.160s
```
### キャッシュによる影響確認

明らかにxargsの方が早いですね。
ちなみにキャッシュの関係性もあるかもしれないので
キャッシュをクリア。

```
[root@server ~]# sync && sysctl -w vm.drop_caches=3
[root@server ~]# free
             total       used       free     shared    buffers     cached
Mem:       1034564    1003368      31196          0     123764     761776
-/+ buffers/cache:     117828     916736
Swap:      2031608     107724    1923884
# sync
# echo 3 > /proc/sys/vm/drop_caches
# free
             total       used       free     shared    buffers     cached
Mem:       1034564     240196     794368          0        664     150404
-/+ buffers/cache:      89128     945436
Swap:      2031608     107724    1923884
```

キャッシュをクリアして何度か実施しましたが
ほぼ、変わらず。

```
[root@server ~]# time find /var -type f | xargs ls -l  > /dev/null

real    0m0.526s
user    0m0.344s
sys     0m0.182s
[root@server ~]# time find /var -type f | xargs ls -l  > /dev/null

real    0m0.443s
user    0m0.326s
sys     0m0.180s
```

### findに[-ls]オプションでは？

ちなみにLinuxではfindに[-ls]というオプションがあるので
同様に計測してみましたが、xargsとほぼ同じ性能でした。

```
[root@server ~]# time find /var -type f -ls > /dev/null

real    0m0.914s
user    0m0.237s
sys     0m0.280s
```

更にキャッシュクリアしても、あまり差はないですね。

```
[root@server ~]# time find /var -type f -ls > /dev/null

real    0m0.154s
user    0m0.100s
sys     0m0.054s
```

まあ、スクリプトでそんなにcpやmvすることはあっても
大量にlsすることはないんでしょうけど。

