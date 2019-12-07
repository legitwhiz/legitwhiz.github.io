#!/bin/ksh
###########################################################################
#
#  �V�X�e����      �F  ALM�V�X�e��
#  �T�u�V�X�e����  �F  �Z���^�[�T�[�o
#  �V�F����        �F  hulft_conf_create_rcv.ksh
#  �@�\��          �F  HULFT��`�쐬
#  �@�\�T�v        �F  
#  OutPut File     �F  none
#  CALLED BY       �F  none
#  CALL TO         �F  none
#  ARGUMENT        �F  1.none
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
