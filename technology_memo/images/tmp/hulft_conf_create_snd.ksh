#!/bin/ksh
###########################################################################
#
#  システム名      ：  ALMシステム
#  サブシステム名  ：  センターサーバ
#  シェル名        ：  hulft_conf_create_snd.ksh
#  機能名          ：  HULFT定義作成
#  機能概要        ：  
#  OutPut File     ：  none
#  CALLED BY       ：  none
#  CALL TO         ：  none
#  ARGUMENT        ：  1.RDエリア名
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

TMPconf=/middle_work/tmp/sakamoto/add_snd.tmp
OutPutFile=/middle_work/tmp/sakamoto/add_snd.cfg

while read LINE
do
ID=`echo $LINE | awk '{ print $1 }'`
FileName=`echo $LINE | awk '{ print $2 }'`
JOBID=`echo $LINE | awk '{ print $3 }'`
if [ $JOBID -eq "-" ]; then
JOBID=
fi
EJOBID=`echo $LINE | awk '{ print $4 }'`
GRPID=`echo $LINE | awk '{ print $5 }'`
TRANSTYPE=`echo $LINE | awk '{ print $6 }'`
Comment=`echo $LINE | awk '{ print $7 }'`

echo "#"					>> $OutPutFile
echo "# ID=$ID"				>> $OutPutFile
echo "#"					>> $OutPutFile
echo 						>> $OutPutFile
echo "SNDFILE=$ID"			>> $OutPutFile
echo "FILENAME=${FileName}"	>> $OutPutFile
echo "DBID="				>> $OutPutFile
echo "TRANSTYPE=$TRANSTYPE"	>> $OutPutFile
echo "TRANSPRTY=50"			>> $OutPutFile
echo "INTERVAL=1"			>> $OutPutFile
echo "BLOCKLEN=8190"		>> $OutPutFile
echo "BLOCKCNT=8"			>> $OutPutFile
echo "COMP=2"				>> $OutPutFile
echo "JOBID=$JOBID"			>> $OutPutFile
echo "COMMENT=$Comment"		>> $OutPutFile
echo "GRPID=$GRPID"			>> $OutPutFile
echo "FMTID="				>> $OutPutFile
echo "EJOBID=$EJOBID"		>> $OutPutFile
echo "KJCHNGE=N"			>> $OutPutFile
echo "CLEAR=K"				>> $OutPutFile
echo "PASSWORD=XXXXXXXXXXXXXXXXXXXX"			>> $OutPutFile
echo "EXCHENGE=N"			>> $OutPutFile
echo "CODESET=1"			>> $OutPutFile
echo "COMPSIZE=50"			>> $OutPutFile
echo "SHIFTTRANSACT=Y"		>> $OutPutFile
echo "PREJOBID="			>> $OutPutFile
echo "END"					>> $OutPutFile
echo 						>> $OutPutFile

done < $TMPconf

ls -l $OutPutFile

exit 0
