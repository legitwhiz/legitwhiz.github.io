#!/bin/bash
###########################################################################
#
#  システム名      ：  
#  サブシステム名  ：  
#  シェル名        ：  Directory_deploy.sh
#  機能名          ：  リストファイルのディレクトリ作成
#  機能概要        ：  リストファイルのディレクトリ作成、オーナー、パーミッションを設定
#  CALLED BY       ：  NONE
#  CALL TO         ：  NONE
#  ARGUMENT        ：  1.作成するディレクトリのリストファイル名
#                      2.none
#  RETURNS         ：  0      正常
#                      0以外  異常
#-------------------------------------------------------------------------
#  作成元          ：  新規
#  作成日　        ： 2020/04/01    作成者　：　D.SAKAMOTO
#  修正履歴　      ：
#
###########################################################################

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

RC=0

# リストファイル読み込み(ループ処理)
while read LINE
do

    Target_Dir=`echo $LINE | awk -F',' '{ print $1}'`
    Target_Owner=`echo $LINE | awk -F',' '{print $2}'`
    Target_Group=`echo $LINE | awk -F',' '{print $3}'`
    Target_Permition=`echo $LINE | awk -F',' '{print $4}'`

    #ディレクトリ作成（なければ）
    if [ ! -d $Target_Dir ]; then
        mkdir -p $Target_Dir
        if [ $? -ne 0 ]; then
            echo "The directory could not be created.($Target_Dir)"
            RC=1
        fi
    fi

    #OWNERに差異があれば
    NOW_Owner=`ls -ld $Target_Dir | awk '{print $3}'`
    if [ $Target_Owner = $NOW_Owner ]; then
        chown $Target_Owner $Target_Dir
        if [ $? -ne 0 ]; then
            echo "Could not change directory owner.($Target_Dir:$Target_Owner)"
            RC=1
        fi
    fi

    #GROUPに差異があれば
    NOW_Group=`ls -ld $Target_Dir | awk '{print $4}'`
    if [ $Target_Group = $NOW_Group ]; then
        chgrp $Target_Group $Target_Dir
        if [ $? -ne 0 ]; then
            echo "Could not change directory group.($Target_Dir:$Target_Group)"
            RC=1
        fi
    fi

    #Permitionに差異があれば

    MOD=`ls -ld $Target_Dir | awk '{print $1}'`

    #2-10桁目の計算
    NOW_Permition=`echo $MOD | awk '{for(i=2;i<=10;i+=3){ {x=0;n=substr($1,i,3)} {if(n~/r/){x+=4}} {if(n~/w/){x+=2}} {if(n~/[xst]/){x+=1}} {printf x}}}'`


    if [ $Target_Permition = $NOW_Permition ]; then
        chmod $Target_Permition $Target_Dir
        if [ $? -ne 0 ]; then
            echo "Could not change directory permition.($Target_Dir:$Target_Permition)"
            RC=1
        fi
    fi

done < $List

if [ $RC -ne 0 ]; then
    echo "$(basename) is failed."
    exit 1
fi
exit 0
