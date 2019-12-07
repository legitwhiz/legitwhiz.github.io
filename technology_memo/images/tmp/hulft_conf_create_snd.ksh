#!/bin/ksh
###########################################################################
#
#  �V�X�e����      �F  ALM�V�X�e��
#  �T�u�V�X�e����  �F  �Z���^�[�T�[�o
#  �V�F����        �F  hulft_conf_create_snd.ksh
#  �@�\��          �F  HULFT��`�쐬
#  �@�\�T�v        �F  
#  OutPut File     �F  none
#  CALLED BY       �F  none
#  CALL TO         �F  none
#  ARGUMENT        �F  1.RD�G���A��
#  RETURNS         �F  0  ����
#                     16  �ُ�
#-------------------------------------------------------------------------
#  ��������
#  No.    ���t            �S��                     �ڍ�
#  0000   2009/07/27      (HITACHI)T.Soun          �V�K
#
###########################################################################

# #####################
# #     ��������      #
# #####################
IniDir=/up
# --�ϐ��t�@�C���Ǎ�--
. ${IniDir}/middle_common.ini

# --���ʊ֐��t�@�C���Ǎ�--
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
