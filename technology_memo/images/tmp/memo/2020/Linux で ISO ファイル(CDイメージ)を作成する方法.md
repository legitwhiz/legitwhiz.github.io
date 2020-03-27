# Linux で ISO ファイル(CDイメージ)を作成する方法

## ファイルやフォルダからisoファイルを作成する場合

```
# mkisofs -r -J -V <ラベル> -o <isoファイル名> <ディレクトリ名>
```

(例)# mkisofs -r -J -V "MyCD" -o cd_image.iso /home/hoge/・CD/DVDドライブからISOファイルを作成する場合


## CD/DVDドライブからISOファイルを作成する場合

```
# dd if=/dev/cdrom of=<isoファイル名>
```

(例)# dd if=/dev/cdrom of=cd_image.isoまたは

または

```
# mkisofs -r -J -o -V <ラベル> -o <isoファイル名> <マウント場所>
```

(例)# mkisofs -r -J -V "MyCD" -o cd_image.iso /media/cdrom
