#/bin/bash

if [ $# != 1 ]; then
    echo "There are not enough arguments."
    exit 1
else
    List=$1
fi

if [ ! -f $List ]; then
    echo "List file did not exist.($List)"
    exit 1
fi

# リストファイル読み込み(ループ処理)
while read LINE
do

    Target_File=`echo $LINE | awk '{ print $1}'`
    Target_Dir=`echo $Target_File | awk -F'/' '{$NF="";print $0}'`
    Source_File=`echo $LINE | awk '{ print $2}'`

    # シンボリックリンク削除（あれば）
    if [ -L $Target_File ]; then
        /bin/rm $Target_File
        if [ $? -ne 0 ]; then
            echo "Failed to delete symbolic link. ($Target_File)"
            exit 1
    fi

    #ディレクトリ作成（なければ）
    if [ ! -d $Target_Dir ]; then
        mkdir -p $Target_Dir
        if [ $? -ne 0 ]; then
            echo "Directory creation failed. ($Target_Dir)"
            exit 1
        fi
    fi

    # PDFファイルコピー
    cp $Source_File $Target_File
    if [ $? -ne 0 ]; then
        echo "Failed to copy PDF file. ($Source_File)"
        exit 1
    fi
    #コピー元ファイル削除
    /bin/rm $Source_File
    if [ $? -ne 0 ]; then
        echo "The source file could not be deleted. ($Source_File)"
        exit 1
    fi
done < $List

exit 0
