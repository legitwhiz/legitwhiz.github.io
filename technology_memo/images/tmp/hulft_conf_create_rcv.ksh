#!/bin/ksh
###########################################################################
#
#  システム名      ：  ALMシステム
#  サブシステム名  ：  センターサーバ
#  シェル名        ：  hulft_conf_create_rcv.ksh
#  機能名          ：  HULFT定義作成
#  機能概要        ：  
#  OutPut File     ：  none
#  CALLED BY       ：  none
#  CALL TO         ：  none
#  ARGUMENT        ：  1.none
#  RETURNS         ：  0  正常
#                     16  異常
#-------------------------------------------------------------------------
#  改訂履歴
#  No.    日付            担当                     詳細
#  0000   2009/07/27      (HITACHI)T.Soun          新規
#
###########################################################################

# #####################
# #     初期処理      #
# #####################
IniDir=/up
# --変数ファイル読込--
. ${IniDir}/middle_common.ini

# --共通関数ファイル読込--
. $CommonFile

TMPconf=/middle_work/tmp/sakamoto/add_rcv.tmp
OutPutFile=/middle_work/tmp/sakamoto/add_rcv.cfg

while read LINE
do
ID=`echo $LINE | awk '{ print $1 }'`
FileName=`echo $LINE | awk '{ print $2 }'`
JOBID=`echo $LINE | awk '{ print $3 }'`
EJOBID=`echo $LINE | awk '{ print $4 }'`
OWNER=`echo $LINE | awk '{ print $5 }'`
GROUP=`echo $LINE | awk '{ print $6 }'`
PERM=`echo $LINE | awk '{ print $7 }'`
Comment=`echo $LINE | awk '{ print $8 }'`

echo "#"					>> $OutPutFile
echo "# ID=$ID"				>> $OutPutFile
echo "#"					>> $OutPutFile
echo 						>> $OutPutFile
echo "RCVFILE=$ID"			>> $OutPutFile
echo "FILENAME=${FileName}"	>> $OutPutFile
echo "OWNER=$OWNER"			>> $OutPutFile
echo "GROUP=$GROUP"			>> $OutPutFile
echo "PERM=$PERM"			>> $OutPutFile
echo "TRANSMODE=R"			>> $OutPutFile
echo "ABNORMAL=D"			>> $OutPutFile
echo "RCVTYPE=S"			>> $OutPutFile
echo "JOBID=$JOBID"			>> $OutPutFile
echo "COMMENT=${Comment}"	>> $OutPutFile
echo "GRPID="				>> $OutPutFile
echo "EJOBID=$EJOBID"		>> $OutPutFile
echo "GENCTL=N"				>> $OutPutFile
echo "PASSWORD=XXXXXXXXXXXXXXXXXXXX"	>> $OutPutFile
echo "EXCHENGE=N"			>> $OutPutFile
echo "CODESET=1"			>> $OutPutFile
echo "JOBWAIT=T"			>> $OutPutFile
echo "END "					>> $OutPutFile
echo 						>> $OutPutFile

done < $TMPconf

ls -l $OutPutFile

exit 0
