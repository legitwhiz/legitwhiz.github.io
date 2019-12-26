#!/bin/bash
###########################################################################
#
#  システム名      ：  
#  サブシステム名  ：  統合認証
#  シェル名        ：  ISSO_Status_Check.bash
#  機能名          ：  統合認証の各サーバのステータスを取得する
#  機能概要        ：  引数に指定したサーバ種別毎にステータスを取得し標準出力に表示する。
#  CALLED BY       ：  NONE
#  CALL TO         ：  NONE
#  ARGUMENT        ：  1.サーバ種別(iw,cert,ldap,rep,bigip,zabbix,prism,esxi,all)
#                      2.none
#  RETURNS         ：  0      正常
#                      0以外  異常
#-------------------------------------------------------------------------
#  作成元          ：  新規
#  作成日　        ： 2018/11/21    作成者　：　D.SAKAMOTO(legit whiz)
#  修正履歴　      ：
#
###########################################################################

###
readonly BIG_VIP=""
readonly BIGIP_Base64=""
readonly BIG_IP1=
readonly BIG_IP2=
readonly BIGIP_Status_File=/tmp/bigip_status.log
readonly DFW_PWD_conf=//dfw.conf
readonly DFW_DGO_conf=//dfw_dgo.conf
readonly Cert_PWD_conf=//cert.conf
readonly Cert_DGO_conf=//cert.conf
readonly Cert_DMP_PWD_conf=//dmp.xml
readonly Cert_DMP_DGO_conf=//dmp_dgo.xml
readonly BIGIP_Health_CheckFlag=//bigipcheck.html
readonly SSH_USER=
readonly SSH_PASS=
readonly Zabbix_Server_IP=
readonly Zabbix_UserName=""
readonly Zabbix_Password=""
readonly Zabbix_Front_IP=""
readonly Zabbix_URL="http://${Zabbix_Front_IP}/zabbix/api_jsonrpc.php"
readonly Zabbix_TMP_File=/tmp/zabbix_message.log
readonly Prism_Base64=""
readonly Prism_URL=https://<>:9440
readonly Nutanix_SSH_USER=
readonly Nutanix_SSH_PASS=
readonly Prism_VIP=
readonly CVM_IP_1=
readonly CVM_IP_2=
readonly CVM_IP_3=
readonly Prism_LeaderURL="localhost:2019"
readonly CVM_Serial_1=
readonly CVM_Serial_2=
readonly CVM_Serial_3=


#PASSWORD=""
if [ -n "$PASSWORD" ]; then
  cat <<< "$PASSWORD"
  exit 0
fi

export PASSWORD=$SSH_PASS
export SSH_ASKPASS=$0
export DISPLAY=dummy:0

if [ -n "$Nutanix_PASSWORD" ]; then
  cat <<< "$Nutanix_PASSWORD"
  exit 0
fi

######################
### BIGIP Status   ###
######################
function BIGIP_Status () {

echo "### BIG-IP Status ###"
curl -s -k -H "Authorization: Basic ${BIGIP_Base64}" -H "Content-Type: application/json" -X GET https://${BIG_VIP}/mgmt/tm/cm/device | python -mjson.tool | grep -e configsyncIp -e failoverState | awk '{ print $2 }' | sed 's/"//g' | sed 's/,//g' > ${BIGIP_Status_File}

if [ ! -f ${BIGIP_Status_File} ]; then
    echo "     BigIP Status File export failed."
    exit 1
fi

COUNT=0
while read LINE
do
    COUNT=`expr $COUNT + 1`
    export EXP${COUNT}=${LINE}
done < ${BIGIP_Status_File}

if [ ${EXP1} = ${BIG_IP1} ]; then
    echo "     isso-bigip01:  ${EXP2}"
    echo "     isso-bigip02:  ${EXP4}"
else
    echo "     isso-bigip02:  ${EXP2}"
    echo "     isso-bigip01:  ${EXP4}"
fi

Sync_Status=`curl -s -k -H "Authorization: Basic YWRtaW46SXNzbzF0bzM=" -H "Content-Type: application/json" -X GET https://${BIG_VIP}/mgmt/tm/cm/sync-status | python -mjson.tool | grep description | tail -n 2 | head -n 1 | awk -F":" '{ print $2 }' | sed 's/"//g'`

if [ ! -n "${Sync_Status}" ]; then
    echo "     Sync_Status get failed."
    return 1
else
    echo "     Sync Status : ${Sync_Status}"
fi
echo ""
return 0
}

######################
### IceWall Server ###
######################
function IceWall_Server_Status () {

ARRAY=(iw01 iw02 iw03)

for host in ${ARRAY[@]}; do
    echo "### ${host} Status ###"
    echo "  # Network Interface #"
    Network_Interface_DeviceName=`exec setsid ssh -o "StrictHostKeyChecking=no" ${SSH_USER}@${host} "nmcli device show | grep GENERAL.デバイス | grep -v lo"`
    Extraction=`echo ${Network_Interface_DeviceName} | sed 's/GENERAL.デバイス://g'`

    for LINE in ${Extraction[@]}
    do
        Network_Interface_status=`exec setsid ssh -o "StrictHostKeyChecking=no" ${SSH_USER}@${host} "/usr/sbin/ethtool $LINE 2>/dev/null | grep -e Settings -e 'Link detected' -e Speed -e Duplex"`
        echo "     ${Network_Interface_status}"
    done
    echo ""

    # httpd Process
    httpd_Proc_Count=`exec setsid ssh -o "StrictHostKeyChecking=no" ${SSH_USER}@${host} "ps -ef | grep httpd | grep -v grep | grep -v root | wc -l"`
    echo "  # Proccess Status #"
    echo "     httpd Proccess Count : ${httpd_Proc_Count}"
    echo ""

    # Failover Cert
    DFW_PWD_Cert_Primary=`exec setsid ssh -o "StrictHostKeyChecking=no" ${SSH_USER}@${host} "grep -v -e '^\s*#' -e '^\s*$' ${DFW_PWD_conf} | grep CERT="`
    DFW_PWD_Cert_Standby=`exec setsid ssh -o "StrictHostKeyChecking=no" ${SSH_USER}@${host} "grep -v -e '^\s*#' -e '^\s*$' ${DFW_PWD_conf} | grep CERT= "`
    DFW_DGO_Cert_Primary=`exec setsid ssh -o "StrictHostKeyChecking=no" ${SSH_USER}@${host} "grep -v -e '^\s*#' -e '^\s*$' ${DFW_DGO_conf} | grep CERT= "`
    DFW_DGO_Cert_Standby=`exec setsid ssh -o "StrictHostKeyChecking=no" ${SSH_USER}@${host} "grep -v -e '^\s*#' -e '^\s*$' ${DFW_DGO_conf} | grep CERT= "`

    DFW_PWD_Cert_Primary_print=`echo ${DFW_PWD_Cert_Primary}| awk -F"=" '{ print $2 }' | awk -F"," '{ print $1 }' | awk -F":" '{ print $1 }'`
    DFW_PWD_Cert_Standby_print=`echo ${DFW_PWD_Cert_Standby}| awk -F"=" '{ print $2 }' | awk -F"," '{ print $2 }' | awk -F":" '{ print $1 }'`
    DFW_DGO_Cert_Primary_print=`echo ${DFW_DGO_Cert_Primary}| awk -F"=" '{ print $2 }' | awk -F"," '{ print $1 }' | awk -F":" '{ print $1 }'`
    DFW_DGO_Cert_Standby_print=`echo ${DFW_DGO_Cert_Standby}| awk -F"=" '{ print $2 }' | awk -F"," '{ print $2 }'| awk -F":" '{ print $1 }'`

    if [ ! -n "${DFW_PWD_Cert_Primary_print} " ] || [ ! -n "${DFW_PWD_Cert_Standby_print} " ] || [ ! -n "${DFW_DGO_Cert_Primary_print} " ] || [ ! -n "${DFW_DGO_Cert_Standby_print} " ]; then
        echo "Cert Failover Status get failed."
    else
        echo "  # Cert Failover Status #"
        echo "     DFW PWD Cert Primary : ${DFW_PWD_Cert_Primary_print} ,Standby : ${DFW_PWD_Cert_Standby_print}"
        echo "     DFW DGO Cert Primary : ${DFW_DGO_Cert_Primary_print} ,Standby : ${DFW_DGO_Cert_Standby_print}"
        echo ""
    fi
    # bigip health check flag
    echo "  # Check the flag for bigip health check #"
    BIGIP_Health_CheckFile_Status=`exec setsid ssh -o "StrictHostKeyChecking=no" ${SSH_USER}@${host} "ls ${BIGIP_Health_CheckFlag} 2>/dev/null"`
    if [ "${BIGIP_Health_CheckFile_Status}" != "" ]; then
        echo "     BIGIP health check Flag file exists."
        echo""
    else
        echo "     BIGIP health check Flag file does not exist."
        echo ""
    fi

done
return 0
}
######################
### Cert Server    ###
######################
function Cert_Server_Status () {

ARRAY=(cert01 cert02)

for host in ${ARRAY[@]}; do
    echo "### ${host} Status ###"
    echo "  # Network Interface #"
    Network_Interface_DeviceName=`exec setsid ssh -o "StrictHostKeyChecking=no" ${SSH_USER}@${host} "nmcli device show | grep GENERAL.デバイス | grep -v lo"`
    Extraction=`echo ${Network_Interface_DeviceName} | sed 's/GENERAL.デバイス://g'`

    for LINE in ${Extraction[@]}
    do
        Network_Interface_status=`exec setsid ssh -o "StrictHostKeyChecking=no" ${SSH_USER}@${host} "/usr/sbin/ethtool $LINE 2>/dev/null | grep -e Settings -e 'Link detected' -e Speed -e Duplex"`
        echo "     ${Network_Interface_status}"
    done
    echo ""
    # httpd Process
    httpd_Proc_Count=`exec setsid ssh -o "StrictHostKeyChecking=no" ${SSH_USER}@${host} "ps -ef | grep httpd | grep -v grep | grep -v root | wc -l"`
    echo "  # Proccess Status #"
    echo "     httpd Proccess Count : ${httpd_Proc_Count}"

    #Process tomcat
    Tomcat_PWD_Proc=`exec setsid ssh -o "StrictHostKeyChecking=no" ${SSH_USER}@${host} "ps -ef | grep java | grep tomcat_dmp_pwd | grep -v grep | wc -l"`
    Tomcat_DGO_Proc=`exec setsid ssh -o "StrictHostKeyChecking=no" ${SSH_USER}@${host} "ps -ef | grep java | grep tomcat_dmp_dgo | grep -v grep | wc -l"`

    if [ ${Tomcat_PWD_Proc} -eq 1 ]; then
        echo "     Tomcat PWD Proccess is alive."
    else
        echo "     Tomcat PWD Proccess is dead."
    fi

    if [ ${Tomcat_DGO_Proc} -eq 1 ]; then
        echo "     Tomcat DGO Proccess is alive."
    else
        echo "     Tomcat DGO Proccess is dead."
    fi

    # Process cert
    Certd_PWD_Proc=`exec setsid ssh -o "StrictHostKeyChecking=no" ${SSH_USER}@${host} "ps -ef | grep certd | grep "\/config\/" | grep -v grep | wc -l"`
    Certd_DGO_Proc=`exec setsid ssh -o "StrictHostKeyChecking=no" ${SSH_USER}@${host} "ps -ef | grep certd | grep "\/config_dgo\/" | grep -v grep | wc -l"`

    if [ ${Certd_PWD_Proc} -eq 1 ]; then
        echo "     Certd PWD Proccess is alive."
    else
        echo "     Certd PWD Proccess is dead."
    fi

    if [ ${Certd_DGO_Proc} -eq 1 ]; then
        echo "     Certd DGO Proccess is alive."
    else
        echo "     Certd DGO Proccess is dead."
    fi
    echo ""
    # Failover LDAP
    DFW_PWD_LDAP_Primary=`exec setsid ssh -o "StrictHostKeyChecking=no" ${SSH_USER}@${host} "grep -v -e '^\s*#' -e '^\s*$' ${Cert_PWD_conf} | grep DBHOST="`
    DFW_PWD_LDAP_Standby=`exec setsid ssh -o "StrictHostKeyChecking=no" ${SSH_USER}@${host} "grep -v -e '^\s*#' -e '^\s*$' ${Cert_PWD_conf} | grep DBHOST="`
    DFW_DGO_LDAP_Primary=`exec setsid ssh -o "StrictHostKeyChecking=no" ${SSH_USER}@${host} "grep -v -e '^\s*#' -e '^\s*$' ${Cert_DGO_conf} | grep DBHOST="`
    DFW_DGO_LDAP_Standby=`exec setsid ssh -o "StrictHostKeyChecking=no" ${SSH_USER}@${host} "grep -v -e '^\s*#' -e '^\s*$' ${Cert_DGO_conf} | grep DBHOST="`

    DFW_PWD_LDAP_Primary_print=`echo ${DFW_PWD_LDAP_Primary}| awk -F"=" '{ print $2 }' | awk -F"," '{ print $1 }' | awk -F":" '{ print $1 }'`
    DFW_PWD_LDAP_Standby_print=`echo ${DFW_PWD_LDAP_Standby}| awk -F"=" '{ print $2 }' | awk -F"," '{ print $2 }' | awk -F":" '{ print $1 }'`
    DFW_DGO_LDAP_Primary_print=`echo ${DFW_DGO_LDAP_Primary}| awk -F"=" '{ print $2 }' | awk -F"," '{ print $1 }' | awk -F":" '{ print $1 }'`
    DFW_DGO_LDAP_Standby_print=`echo ${DFW_DGO_LDAP_Standby}| awk -F"=" '{ print $2 }' | awk -F"," '{ print $2 }'| awk -F":" '{ print $1 }'`

    if [ ! -n "${DFW_PWD_LDAP_Primary_print} " ] || [ ! -n "${DFW_PWD_LDAP_Standby_print} " ] || [ ! -n "${DFW_DGO_LDAP_Primary_print} " ] || [ ! -n "${DFW_DGO_LDAP_Standby_print} " ]; then
        echo "LDAP Failover Status get failed."
    else
        echo "  # LDAP Failover Status #"
        echo "     DFW PWD Cert Primary : ${DFW_PWD_LDAP_Primary_print} ,Standby : ${DFW_PWD_LDAP_Standby_print}"
        echo "     DFW DGO Cert Primary : ${DFW_DGO_LDAP_Primary_print} ,Standby : ${DFW_DGO_LDAP_Standby_print}"
        echo ""
    fi

    # Failover DMP
    DMP_PWD_Cert_Primary=`exec setsid ssh -o "StrictHostKeyChecking=no" ${SSH_USER}@${host} "grep -v -e '^\s*#' -e '^\s*$' ${Cert_DMP_PWD_conf} | grep dmp:Active"`
    DMP_PWD_Cert_Standby=`exec setsid ssh -o "StrictHostKeyChecking=no" ${SSH_USER}@${host} "grep -v -e '^\s*#' -e '^\s*$' ${Cert_DMP_PWD_conf} | grep dmp:Standby"`
    DMP_DGO_Cert_Primary=`exec setsid ssh -o "StrictHostKeyChecking=no" ${SSH_USER}@${host} "grep -v -e '^\s*#' -e '^\s*$' ${Cert_DMP_DGO_conf} | grep dmp:Active"`
    DMP_DGO_Cert_Standby=`exec setsid ssh -o "StrictHostKeyChecking=no" ${SSH_USER}@${host} "grep -v -e '^\s*#' -e '^\s*$' ${Cert_DMP_DGO_conf} | grep dmp:Standby"`

    DMP_PWD_Cert_Primary_print=`echo ${DMP_PWD_Cert_Primary}| awk -F":" '{ print $2 }' | sed 's/Active>//g'`
    DMP_PWD_Cert_Standby_print=`echo ${DMP_PWD_Cert_Standby}| awk -F":" '{ print $2 }' | sed 's/Standby>//g'`
    DMP_DGO_Cert_Primary_print=`echo ${DMP_DGO_Cert_Primary}| awk -F":" '{ print $2 }' | sed 's/Active>//g'`
    DMP_DGO_Cert_Standby_print=`echo ${DMP_DGO_Cert_Standby}| awk -F":" '{ print $2 }' | sed 's/Standby>//g'`

    if [ ! -n "${DMP_PWD_Cert_Primary_print} " ] || [ ! -n "${DMP_PWD_Cert_Standby_print} " ] || [ ! -n "${DMP_DGO_Cert_Primary_print} " ] || [ ! -n "${DMP_DGO_Cert_Standby_print} " ]; then
        echo "DMP Failover Status get failed."
    else
        echo "  # DMP Failover Status #"
        echo "     DMP PWD Cert Primary : ${DMP_PWD_Cert_Primary_print} ,Standby : ${DMP_PWD_Cert_Standby_print}"
        echo "     DMP DGO Cert Primary : ${DMP_DGO_Cert_Primary_print} ,Standby : ${DMP_DGO_Cert_Standby_print}"
        echo ""
    fi
done
return 0
}
######################
### LDAP Server    ###
######################
function LDAP_Server_Status () {

ARRAY=(ldap01 ldap02)

for host in ${ARRAY[@]}; do
    echo "### ${host} Status ###"
    echo "  # Network Interface #"
    Network_Interface_DeviceName=`exec setsid ssh -o "StrictHostKeyChecking=no" ${SSH_USER}@${host} "nmcli device show | grep GENERAL.デバイス | grep -v lo"`
    Extraction=`echo ${Network_Interface_DeviceName} | sed 's/GENERAL.デバイス://g'`

    for LINE in ${Extraction[@]}
    do
        Network_Interface_status=`exec setsid ssh -o "StrictHostKeyChecking=no" ${SSH_USER}@${host} "/usr/sbin/ethtool $LINE 2>/dev/null | grep -e Settings -e 'Link detected' -e Speed -e Duplex"`
        echo "     ${Network_Interface_status}"
    done
    echo ""

    # LDAP Process
    echo "  # Proccess Status #"
    LDAP_Proc=`exec setsid ssh -o "StrictHostKeyChecking=no" ${SSH_USER}@${host} "ps -ef | grep slapd | grep -v grep | wc -l"`
    if [ ${LDAP_Proc} -eq 1 ]; then
        echo "     OpenLDAP Proccess is alive."
    else
        echo "     OpenLDAP Proccess is dead."
    fi
    echo ""
done
return 0
}
######################
### LDAP REP Server###
######################
function LDAPREP_Server_Status () {

ARRAY=(ldaprep01 ldaprep02)

for host in ${ARRAY[@]}; do
    echo "### ${host} Status ###"
    echo "  # Network Interface #"
    Network_Interface_DeviceName=`exec setsid ssh -o "StrictHostKeyChecking=no" ${SSH_USER}@${host} "nmcli device show | grep GENERAL.デバイス | grep -v lo"`
    Extraction=`echo ${Network_Interface_DeviceName} | sed 's/GENERAL.デバイス://g'`

    for LINE in ${Extraction[@]}
    do
        Network_Interface_status=`exec setsid ssh -o "StrictHostKeyChecking=no" ${SSH_USER}@${host} "/usr/sbin/ethtool $LINE 2>/dev/null | grep -e Settings -e 'Link detected' -e Speed -e Duplex"`
        echo "     ${Network_Interface_status}"
    done
    echo ""

    # LDAP Process
    echo "  # Proccess Status #"
    LDAP_Proc=`exec setsid ssh -o "StrictHostKeyChecking=no" ${SSH_USER}@${host} "ps -ef | grep slapd | grep -v grep | wc -l"`
    if [ ${LDAP_Proc} -eq 1 ]; then
        echo "     OpenLDAP Proccess is alive."
    else
        echo "     OpenLDAP Proccess is dead."
    fi

    Postfix_Proc=`exec setsid ssh -o "StrictHostKeyChecking=no" ${SSH_USER}@${host} "ps -ef | grep postfix | grep master | grep -v grep | wc -l"`
    if [ ${Postfix_Proc} -eq 1 ]; then
        echo "     Postfix Proccess is alive."
    else
        echo "     Postfix Proccess is dead."
    fi

    echo ""
done
return 0
}

######################
### Zabbix Server  ###
######################
function Zabbix_Server_Status () {

    echo "### isso-zabbix Status ###"
    echo "  # Network Interface #"
    #Network_Interface_DeviceName=`exec setsid ssh -o "StrictHostKeyChecking=no" ${SSH_USER}@${Zabbix_Server_IP} "nmcli device show | grep "GENERAL. デバイス" | grep -v lo"`
    Network_Interface_DeviceName=`exec setsid ssh -o "StrictHostKeyChecking=no" ${SSH_USER}@${Zabbix_Server_IP} "nmcli device show | grep GENERAL.デバイス | grep -v lo"`

    Extraction=`echo ${Network_Interface_DeviceName} | sed 's/GENERAL.デバイス://g'`

    for LINE in ${Extraction[@]}
    do
        Network_Interface_status=`exec setsid ssh -o "StrictHostKeyChecking=no" ${SSH_USER}@${Zabbix_Server_IP} "/usr/sbin/ethtool $LINE 2>/dev/null | grep -e Settings -e 'Link detected' -e Speed -e Duplex"`
        echo "     ${Network_Interface_status}"
    done
    echo ""

    # Zabbix Process
    echo "  # Proccess Status #"
    Zabbix_Server_Proc=`exec setsid ssh -o "StrictHostKeyChecking=no" ${SSH_USER}@${Zabbix_Server_IP} "ps -ef | grep zabbix_server.conf | grep -v grep | wc -l"`
    if [ ${Zabbix_Server_Proc} -eq 1 ]; then
        echo "     Zabbix Server Proccess is alive."
    else
        echo "     Zabbix Server Proccess is dead."
    fi

    httpd_Proc_Count=`exec setsid ssh -o "StrictHostKeyChecking=no" ${SSH_USER}@${Zabbix_Server_IP} "ps -ef | grep httpd | grep -v grep | grep -v root | wc -l"`
    echo "     httpd Proccess Count : ${httpd_Proc_Count}"

    MariaDB_Proc=`exec setsid ssh -o "StrictHostKeyChecking=no" ${SSH_USER}@${Zabbix_Server_IP} "ps -ef | grep mysqld | grep -v grep | wc -l"`
    if [ ${MariaDB_Proc} -eq 2 ]; then
        echo "     MariaDB Proccess is alive."
    else
        echo "     MariaDB Proccess is dead."
    fi
    echo ""

    echo "  # Zabbix Alert Message #"
    #Session ID
    Session_ID=`curl -s -d '{"auth": null,"method": "user.login","id": "null","params": {"password": "'${Zabbix_Password}'","user": "'${Zabbix_UserName}'"},"jsonrpc": "2.0"}' -H "Accept: application/json" -H "Content-Type: application/json-rpc" ${Zabbix_URL} | python -mjson.tool | grep result | awk -F":" '{ print $2 }' | sed 's/\"//g' | sed 's/ *//g'`

    #GET
    echo -e `curl -s -d '{"auth": "'${Session_ID}'","method": "alert.get","id": 1,"params": {"output": "extend"},"jsonrpc": "2.0"}' -H "Content-Type: application/json-rpc" ${Zabbix_URL} | python -mjson.tool` > ${Zabbix_TMP_File}

    #改行コード修正
    #sed -i -e 's/\"\,/\"\n/g' -i -e 's/\r//g' -i -e 's/^[ ]//g' -i -e 's/"//g' ${Zabbix_TMP_File}
    sed -i -e 's/\"\,/\"\n/g' -i -e 's/\r//g' ${Zabbix_TMP_File}
    sed -i -e 's/^[ ]//g' -i -e 's/"//g' ${Zabbix_TMP_File}

    #余計な行削除し、メッセージを出力
    grep -v -e '^retries:' -e '^sendto:' -e '^status:' -e '^userid:' -e '^alertid:' -e '^alerttype:' -e '^error:' -e '^esc_step:' -e '^eventid:' -e '^mediatypeid:' -e '^result:' -e '^{ id' -e '^subject:' -e '^\s*$' ${Zabbix_TMP_File} | while true
    #grep -v -e "^retries:" -e "^sendto:" -e "^status:" -e "^userid:" -e "^alertid:" -e "^alerttype:" -e "^error:" -e "^esc_step:" -e "^eventid:" -e "^mediatypeid:" -e "^result:" -e "^{ id" -e "^subject:" -e "^\s*$" ${Zabbix_TMP_File} | while true
do
        read line1
        if [ -z "$line1" ]; then break ; fi
        if [ `echo $line1 | grep clock | wc -l` -eq 1 ]; then
            echo "     --------------------------------------"
            Message=`echo  $line1 | awk -F"clock: " '{ print $2 }' | awk '{print strftime("%c",$1)}'`
            echo "     $Message"
        else
            if [ `echo  $line1 | grep message | wc -l` -ne 1 ]; then
                Message=`echo $line1 | grep -v ^-`
                if [ -n "$Message" ]; then
                    echo "     $Message"
                fi
            else
                Message=`echo $line1 | awk -F"message:" '{ print $2 }' | sed 's/^ //g'`
                echo "     $Message"
            fi
        fi

    done
    echo ""
    rm -f ${Zabbix_TMP_File}
return 0
}
######################
### Prism          ###
######################
function Prism_Status () {

export PASSWORD=$Nutanix_SSH_PASS
export SSH_ASKPASS=$0
export DISPLAY=dummy:0

echo "### Prism Status ###"
echo "  # Prism Leader Status #"

Prism_Leader_Status=`exec setsid ssh -o "StrictHostKeyChecking=no" ${Nutanix_SSH_USER}@${Prism_VIP} "curl -s -k -H 'Accept: application/json' -X GET ${Prism_LeaderURL}/prism/leader" 2>/dev/null`

Prism_Leader_IPAddress=`echo ${Prism_Leader_Status} | grep leader | awk -F":" '{ print $2}' | sed 's/\"//g' | sed 's/ *//g'`

case ${Prism_Leader_IPAddress} in
    ${CVM_IP_1})
    echo "     Prism Leader :CVM#1"
    ;;
    ${CVM_IP_2})
    echo "     Prism Leader :CVM#2"
    ;;
    ${CVM_IP_3})
    echo "     Prism Leader :CVM#3"
    ;;
    *)
    echo "     Prism Leader :none"
    ;;
esac
echo ""

echo "  # Prism Virtual Machine Status #"
# Virtual Machine UUIDを全て出力
curl -s -k -H "Authorization: Basic ${Prism_Base64}" -H 'Accept: application/json' -X GET "${Prism_URL}/api/nutanix/v2.0/vms/" | python -mjson.tool | grep -e "\"uuid\"" -e name| while true
do
    read line1
    read line2
    if [ -z "$line1" ] ; then break ; fi
    #Virtual_Machine_Name抽出
    Virtual_Machine_Name=`echo $line1 | awk -F":" '{ print $2}'| sed 's/\"//g' | awk -F"," '{ print $1 }'`
    #Virtual_Machine_UUID抽出
    Virtual_Machine_UUID=`echo $line2 | awk -F":" '{ print $2}'| sed 's/\"//g' | awk -F"," '{ print $1 }' | sed 's/ *//g'`
#    echo ${Virtual_Machine_Name} ${Virtual_Machine_UUID}

    # Virtual_Machine_UUIDから各仮想マシンの状態を出力
    curl -s -k -H "Authorization: Basic ${Prism_Base64}" -H 'Accept: application/json' -X GET "${Prism_URL}/PrismGateway/services/rest/v2.0/vms/${Virtual_Machine_UUID}" | python -mjson.tool | while true
    do
        read line1
        read line2
        read line3
        read line4
        read line5
        read line6
        read line7
        read line8
        read line9
        read line10
        read line11
        read line12
        read line13
        read line14
    if [ -z "$line1" ] ; then break ; fi
    if [ -z "$line6" ] ; then break ; fi

        Virtual_Machine_Name=`echo $line7 | awk -F":" '{ print $2}' | awk -F"," '{ print $1 }' | sed 's/ *//g' | sed 's/\"//g'`
        VCPU_num=`echo $line9 | awk -F":" '{ print $2}' | awk -F"," '{ print $1 }' | sed 's/ *//g' | sed 's/\"//g'`
        Core_Per_VCPU_num=`echo $line8 | awk -F":" '{ print $2}' | awk -F"," '{ print $1 }' | sed 's/ *//g' | sed 's/\"//g'`
        Memory_allocation=`echo $line6 | awk -F":" '{ print $2}' | awk -F"," '{ print $1 }' | sed 's/ *//g' | sed 's/\"//g'`
        Power_State=`echo $line10 | awk -F":" '{ print $2}' | awk -F"," '{ print $1 }' | sed 's/ *//g' | sed 's/\"//g'`
        UUID=`echo $line13 | awk -F":" '{ print $2}' | awk -F"," '{ print $1 }' | sed 's/ *//g' | sed 's/\"//g'`

        echo "    Virtual Machine Name : ${Virtual_Machine_Name}"
        echo "    VCPU num             : ${VCPU_num}"
        echo "    Core_Per_VCPU_num    : ${Core_Per_VCPU_num}"
        echo "    Memory allocation    : ${Memory_allocation}"
        echo "    Power State          : ${Power_State}"
        echo "    UUID                 : ${UUID}"
        echo ""
    done
done
}

######################
### ESXi           ###
######################
function ESXi_Status () {

export PASSWORD=$Nutanix_SSH_PASS
export SSH_ASKPASS=$0
export DISPLAY=dummy:0

echo "### ESXi Status ###"
echo "  # ESXi CPU Memory Usage #"
curl -s -k -H "Authorization: Basic ${Prism_Base64}" -H 'Accept: application/json' -X GET "${Prism_URL}/PrismGateway/services/rest/v2.0/hosts/" | python -mjson.tool | grep -e hypervisor_cpu_usage_ppm -e "\"serial\":" -e hypervisor_memory_usage_ppm | awk -F":" '{ print $2}' | sed 's/\"//g' | sed 's/ *//g' | sed 's/\,//g' | while true
do
read line1
read line2
read line3
if [ -z "$line1" ]; then break ; fi

case ${line1} in
    ${CVM_Serial_1})
    echo "     HostName : isso-esx01"
    ;;
    ${CVM_Serial_2})
    echo "     HostName : isso-esx02"
    ;;
    ${CVM_Serial_3})
    echo "     HostName : isso-esx03"
    ;;
    *)
    echo "     HostName : none"
    ;;
esac

echo "     CPU Usage : $((${line2}/10000))"\%""
echo "     Memory Usage : $((${line3}/10000))"\%""
echo ""
done

echo "  # Virtual Machine CPU Memory Usage #"
CVM1_Mem_Total=`exec setsid ssh -o "StrictHostKeyChecking=no" ${Nutanix_SSH_USER}@${CVM_IP_1} "cat /proc/meminfo | grep MemTotal | tr -cd '0123456789'" 2>/dev/null`

CVM1_Mem_Available=`exec setsid ssh -o "StrictHostKeyChecking=no" ${Nutanix_SSH_USER}@${CVM_IP_1} "cat /proc/meminfo | grep MemAvailable | tr -cd '0123456789'" 2>/dev/null`

CVM2_Mem_Total=`exec setsid ssh -o "StrictHostKeyChecking=no" ${Nutanix_SSH_USER}@${CVM_IP_2} "cat /proc/meminfo | grep MemTotal | tr -cd '0123456789'" 2>/dev/null`

CVM2_Mem_Available=`exec setsid ssh -o "StrictHostKeyChecking=no" ${Nutanix_SSH_USER}@${CVM_IP_2} "cat /proc/meminfo | grep MemAvailable | tr -cd '0123456789'" 2>/dev/null`

CVM3_Mem_Total=`exec setsid ssh -o "StrictHostKeyChecking=no" ${Nutanix_SSH_USER}@${CVM_IP_3} "cat /proc/meminfo | grep MemTotal | tr -cd '0123456789'" 2>/dev/null`

CVM3_Mem_Available=`exec setsid ssh -o "StrictHostKeyChecking=no" ${Nutanix_SSH_USER}@${CVM_IP_3} "cat /proc/meminfo | grep MemAvailable | tr -cd '0123456789'" 2>/dev/null`

CVM1_Mem_Usage=$((100 * ${CVM1_Mem_Available} / ${CVM1_Mem_Total}))
CVM2_Mem_Usage=$((100 * ${CVM2_Mem_Available} / ${CVM2_Mem_Total}))
CVM3_Mem_Usage=$((100 * ${CVM3_Mem_Available} / ${CVM3_Mem_Total}))

curl -s -k -H "Authorization: Basic ${Prism_Base64}" -H 'Accept: application/json' -X GET "${Prism_URL}/PrismGateway/services/rest/v1/vms" | python -mjson.tool | grep -e vmName -e hostName -e hypervisor_cpu_usage_ppm -e hypervisor_memory_usage_ppm -e hypervisor_io_bandwidth_kBps -e hypervisor_num_read_iops -e hypervisor_num_write_iops | awk -F":" '{ print $2}' | sed 's/\"//g' | sed 's/ *//g' | sed 's/\,//g' | while true
do
    read line1  #hostName
    read line2  #vmName
    read line3  #hypervisor_cpu_usage_ppm
    read line4  #hypervisor_io_bandwidth_kBps
    read line5  #hypervisor_memory_usage_ppm
    read line6  #hypervisor_num_read_iops
    read line7  #hypervisor_num_write_iops
    read line8  #vmName
    if [ -z "$line1" ]; then break ; fi
    echo "     Virtual Machine Name         : ${line2}"
    echo "     Placement of virtual machine : ${line1}"
    echo "     CPU Usage                    : $((${line3}/10000))"\%""

    case `echo ${line2} | awk -F"-" '{print $2 }'` in
        ${CVM_Serial_1})
         echo "     Memory Usage                 : ${CVM1_Mem_Usage}"\%""
         ;;
        ${CVM_Serial_2})
         echo "     Memory Usage                 : ${CVM2_Mem_Usage}"\%""
         ;;
        ${CVM_Serial_3})
         echo "     Memory Usage                 : ${CVM3_Mem_Usage}"\%""
         ;;
        *)
         echo "     Memory Usage                 : $((${line5}/10000))"\%""
         ;;
    esac
    echo "     I/O Bandwidth                : ${line4}kBps"
    echo "     Read IOPS                    : ${line6}"
    echo "     Write IOPS                   : ${line7}"
    echo ""
done

}

function TEST_Status () {

export PASSWORD=$Nutanix_SSH_PASS
export SSH_ASKPASS=$0
export DISPLAY=dummy:0

CVM1_Mem_Total=`exec setsid ssh -o "StrictHostKeyChecking=no" ${Nutanix_SSH_USER}@${CVM_IP_1} "cat /proc/meminfo | grep MemTotal | tr -cd '0123456789'"`

CVM1_Mem_Available=`exec setsid ssh -o "StrictHostKeyChecking=no" ${Nutanix_SSH_USER}@${CVM_IP_1} "cat /proc/meminfo | grep MemAvailable | tr -cd '0123456789'"`

CVM2_Mem_Total=`exec setsid ssh -o "StrictHostKeyChecking=no" ${Nutanix_SSH_USER}@${CVM_IP_2} "cat /proc/meminfo | grep MemTotal | tr -cd '0123456789'"`

CVM2_Mem_Available=`exec setsid ssh -o "StrictHostKeyChecking=no" ${Nutanix_SSH_USER}@${CVM_IP_2} "cat /proc/meminfo | grep MemAvailable | tr -cd '0123456789'"`

CVM3_Mem_Total=`exec setsid ssh -o "StrictHostKeyChecking=no" ${Nutanix_SSH_USER}@${CVM_IP_3} "cat /proc/meminfo | grep MemTotal | tr -cd '0123456789'"`

CVM3_Mem_Available=`exec setsid ssh -o "StrictHostKeyChecking=no" ${Nutanix_SSH_USER}@${CVM_IP_3} "cat /proc/meminfo | grep MemAvailable | tr -cd '0123456789'"`

CVM1_Mem_Usage=$((100 * ${CVM1_Mem_Available} / ${CVM1_Mem_Total}))
CVM2_Mem_Usage=$((100 * ${CVM2_Mem_Available} / ${CVM2_Mem_Total}))
CVM3_Mem_Usage=$((100 * ${CVM3_Mem_Available} / ${CVM3_Mem_Total}))

echo "     CVM1_Mem_Usage is : ${CVM1_Mem_Usage}"
echo "     CVM2_Mem_Usage is : ${CVM2_Mem_Usage}"
echo "     CVM3_Mem_Usage is : ${CVM3_Mem_Usage}"

}
######################
### Usage          ###
######################
function usage () {
    echo " Usage: $(basename ${0}) [<options>]"
    echo " The specified argument is $#."
    echo " The required argument is one."
    echo " options:iw,cert,ldap,rep,bigip,zabbix,prism,esxi,all"
    return 1
}
######################
### Execute Main   ###
######################

if [ $# -ne 1 ]; then
    usage
    exit 1
fi

case ${1} in
  iw)
    IceWall_Server_Status
    ;;
  cert)
    Cert_Server_Status
    ;;
  ldap)
    LDAP_Server_Status
    ;;
  rep)
    LDAPREP_Server_Status
    ;;
  bigip)
    BIGIP_Status
    ;;
  zabbix)
    Zabbix_Server_Status
    ;;
  prism)
    Prism_Status
    ;;
   esxi)
    ESXi_Status
    ;;
  all)
    BIGIP_Status
    IceWall_Server_Status
    Cert_Server_Status
    LDAP_Server_Status
    LDAPREP_Server_Status
    Zabbix_Server_Status
    Prism_Status
    ESXi_Status
    ;;
  test)
    TEST_Status
    ;;
  *)
    echo "[ERROR] Invalid option '${1}'"
    usage
    exit 1
    ;;
esac

exit 0

