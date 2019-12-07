#!/bin/sh
################################################################################
#
# �V�F����     : make_unix_server_access_log.sh
# �@�\         : UNIX�T�[�o�A�N�Z�X���O�쐬
# �N�����@     : /home/SHELL/SSC/make_access_login_log.sh
# �N�����[�U   : root
# �߂�l       : 0 : ����I��
#                8 : �ُ�I��
#
################################################################################

# ���ϐ�
export LANG=C
LIST_DIR=/tmp/log/access
SL_KEYWORD1='still logged in'
SL_KEYWORD2='begins'
HOST_NAME=`hostname`

# �����̓��t�擾
TODAY_W=`date +%a`
TODAY_M=`date +%b`
TODAY_D=`date +%e`
TODAY="${TODAY_W} ${TODAY_M} ${TODAY_D}"

# �O���̓��t�擾
export TZ=JST+15
YESTERDAY_W=`date +%a`
YESTERDAY_M=`date +%b`
YESTERDAY_D=`date +%e`
YESTERDAY="${YESTERDAY_W} ${YESTERDAY_M} ${YESTERDAY_D}"

TARGET_DT=`date +%Y%m%d`
DISPLAY_DT=`date +%Y/%m/%d`
# �^�C���]�[������{�ɖ߂�
export TZ=JST-9

# tmp�t�@�C����
ACCESS_LOG=${LIST_DIR}/access_login_${HOST_NAME}_${TARGET_DT}.log
TMP_ACCESS_LOG_1=${LIST_DIR}/access_login_${TARGET_DT}_1.tmp
TMP_ACCESS_LOG_2=${LIST_DIR}/access_login_${TARGET_DT}_2.tmp
TMP_ACCESS_LOG_3=${LIST_DIR}/access_login_${TARGET_DT}_3.tmp
TMP_ACCESS_LOG_4=${LIST_DIR}/access_login_${TARGET_DT}_4.tmp

NOACCESS_LOG=${LIST_DIR}/access_nologin_${HOST_NAME}_${TARGET_DT}.log
TMP_NOACCESS_LOG_1=${LIST_DIR}/access_nologin_${TARGET_DT}_1.tmp
TMP_NOACCESS_LOG_2=${LIST_DIR}/access_nologin_${TARGET_DT}_2.tmp

#===============================================================================
# �G���[�`�F�b�N
# $1 : Check Code
# $2 : Error Message
# $3 : Exit Code
#===============================================================================
function CheckError
{
        CHECKCODE=${1:-0}
        MESSAGE=${2:-""}
        EXITCODE=${3:-8}
        if [ $CHECKCODE -ne 0 ]; then
                if [ "$MESSAGE" != "" ]; then
                        echo `date "+%Y/%m/%d %H:%M:%S"` $MESSAGE 1>&2
                fi
                exit $EXITCODE
        fi
}

# �f�B���N�g�����Ȃ�������쐬
if [ ! -d ${LIST_DIR} ]
then
        mkdir -p ${LIST_DIR}
	chmod 755 ${LIST_DIR}
fi

# ���[�U�̃A�N�Z�X���t�@�C��(���O�C��)�̍쐬
# �O�X���ȑO���烍�O�A�E�g���Ă��Ȃ����[�U���O�C�����̏�����
last | grep "${SL_KEYWORD1}" | grep -v "${TODAY}" | grep -v "${YESTERDAY}" > ${TMP_ACCESS_LOG_1}
sort -k 6,6 ${TMP_ACCESS_LOG_1} | grep -v "${SL_KEYWORD2}" > ${TMP_ACCESS_LOG_2}

# �O���̃��[�U���O�C�����̃t�@�C��������
last | grep "${YESTERDAY}" | grep -v "${SL_KEYWORD1}" > ${TMP_ACCESS_LOG_3}
sort -k 6,6 ${TMP_ACCESS_LOG_3} | grep -v "${SL_KEYWORD2}" > ${TMP_ACCESS_LOG_4}

# �t�@�C���̍쐬
echo "################################################################" > ${ACCESS_LOG}
echo "# file name   : unix_server_access_log(login,logout)" >> ${ACCESS_LOG}
echo "# host name   : ${HOST_NAME}" >> ${ACCESS_LOG}
echo "# date        : ${DISPLAY_DT}" >> ${ACCESS_LOG}
echo "################################################################\n" >> ${ACCESS_LOG}
echo "###             still logged in user infomation              ###\n" >> ${ACCESS_LOG}
cat ${TMP_ACCESS_LOG_2} >> ${ACCESS_LOG}
echo "\n###                         end                              ###\n" >> ${ACCESS_LOG}
echo "###             logged in user infomation                    ###\n" >> ${ACCESS_LOG}
cat ${TMP_ACCESS_LOG_4} >> ${ACCESS_LOG}
echo "\n###                         end                              ###" >> ${ACCESS_LOG}

# UNIX�T�[�o�A�N�Z�X���O(���O�C�����s)�̍쐬
# �O���̃��[�U���O�C�����(���O�C�����s)�̃t�@�C��������
lastb | grep "${YESTERDAY}" > ${TMP_NOACCESS_LOG_1}
sort -k 1,1 ${TMP_NOACCESS_LOG_1} | grep -v "${SL_KEYWORD2}" > ${TMP_NOACCESS_LOG_2}

# �t�@�C���̍쐬
echo "###############################################################" > ${NOACCESS_LOG}
echo "# file name   : unix_server_access_log(login failed)" >> ${NOACCESS_LOG}
echo "# host name   : ${HOST_NAME}" >> ${NOACCESS_LOG}
echo "# date        : ${DISPLAY_DT}" >> ${NOACCESS_LOG}
echo "###############################################################\n" >> ${NOACCESS_LOG}
echo "###             logged in failed user infomation            ###\n" >> ${NOACCESS_LOG}
cat ${TMP_NOACCESS_LOG_2} >> ${NOACCESS_LOG}
echo "\n###                         end                              ###" >> ${NOACCESS_LOG}

# �����̕ύX
chmod 444 ${ACCESS_LOG}
chmod 444 ${NOACCESS_LOG}

# tmp�t�@�C���̍폜
rm -f ${LIST_DIR}/*.tmp

# �s�ǃ��O�C���f�[�^�x�[�X�A���O�C���f�[�^�x�[�X�����e�i���X
if [ ${TODAY_D} = "1" ]
then
	if [ -f /var/adm/btmp ]
	then
		echo "\c" > /var/adm/btmp
	fi
	if [ -f /var/adm/btmps ]
	then
		echo "\c" > /var/adm/btmps
	fi
	if [ -f /var/adm/wtmp ]
	then
		echo "\c" > /var/adm/wtmp
	fi
	if [ -f /var/adm/wtmps ]
	then
		echo "\c" > /var/adm/wtmps
	fi
	if [ -f /var/adm/wtmpx ]
	then
		echo "\c" > /var/adm/wtmpx
	fi
fi

################################################################################
