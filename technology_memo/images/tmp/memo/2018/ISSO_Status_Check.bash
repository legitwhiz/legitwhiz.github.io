#!/bin/bash
###########################################################################
#
#  システム名      ：  統合認証システム
#  サブシステム名  ：  統合認証システム
#  シェル名        ：  ISSO_Status_Check.bash
#  機能名          ：  統合認証の各サーバのステータスを取得する
#  機能概要        ：  引数に指定したサーバ種別毎にステータスを取得し標準出力に表示する。
#  CALLED BY       ：  NONE
#  CALL TO         ：  NONE
#  ARGUMENT        ：  1.サーバ種別(iw,cert,ldap,rep,bigip,zabbix,prism,esxi,sw24,idrac,ilo,all,iwdev,certdev,ldapdev,repdev,bigipdev,swdev,devall)
#                      2.none
#  RETURNS         ：  0      正常
#                      0以外  異常
#-------------------------------------------------------------------------
#  作成元          ：  新規
#  作成日　        ： 2018/11/21    作成者　：　D.SAKAMOTO(MT)
#  修正履歴　      ：
#
###########################################################################

###
readonly BIG_VIP="192.168.20.1"
readonly BIGIP_Base64="YWRtaW46SXNzbzF0bzM="
readonly BIG_IP1=172.16.1.1
readonly BIG_IP2=172.16.1.2
readonly BIGIP_Status_File=/tmp/bigip_status.log
readonly DFW_PWD_conf=/opt/icewall-sso/dfw/cgi-bin/dfw.conf
readonly DFW_DGO_conf=/opt/icewall-sso/dfw/cgi-bin/dfw_dgo.conf
readonly Cert_PWD_conf=/opt/icewall-sso/certd/config/cert.conf
readonly Cert_DGO_conf=/opt/icewall-sso/certd/config_dgo/cert.conf
readonly Cert_DMP_PWD_conf=/opt/icewall-sso/dmp/config/dmp.xml
readonly Cert_DMP_DGO_conf=/opt/icewall-sso/dmp/config/dmp_dgo.xml
readonly BIGIP_Health_CheckFlag=/opt/icewall-sso/dfw/html/bigip/bigipcheck.html
readonly SSH_USER=radmin
readonly SSH_PASS=Isso1to3
readonly Zabbix_Server_IP=192.168.1.37
readonly Zabbix_UserName="issoadmin"
readonly Zabbix_Password="issozabbix"
readonly Zabbix_Front_IP="192.168.20.37"
readonly Zabbix_URL="http://${Zabbix_Front_IP}/zabbix/api_jsonrpc.php"
readonly Zabbix_TMP_File=/tmp/zabbix_message.log
readonly Prism_Base64="YWRtaW46QHV0aElzc28xdG8z"
readonly Prism_URL=https://192.168.20.90:9440
readonly Nutanix_SSH_USER=nutanix
readonly Nutanix_SSH_PASS=@uthIsso1to3
readonly Prism_VIP=192.168.20.90
readonly CVM_IP_1=192.168.20.91
readonly CVM_IP_2=192.168.20.92
readonly CVM_IP_3=192.168.20.93
readonly Prism_LeaderURL="localhost:2019"
readonly Prism_Cluster_Status_File=/tmp/Prism_Cluster_Status.log
readonly Prism_Process_Count=35
readonly CVM_Serial_1=FFV1BQ2
readonly CVM_Serial_2=FFV3BQ2
readonly CVM_Serial_3=FFV5BQ2
readonly SW24_SSH_USER=admin
readonly SW24_SSH_PASS=Ch1to3
readonly SW24_IP=192.168.20.5
readonly SW24_Interface_Log=/tmp/SW24_Interface.log
readonly iDrac1_IP=192.168.20.98
readonly iDrac2_IP=192.168.20.99
readonly iDrac3_IP=192.168.20.100
readonly iDrac_Base64=cm9vdDpAdXRoSXNzbzF0bzM=
readonly iDrac_TMP_Status_File=/tmp/iDrac_TMP_Status.log
readonly iDrac_SSH_USER=root
readonly iDrac_SSH_PASS=@uthIsso1to3
readonly iLO_Address=192.168.20.79
readonly iLO_Base64=QWRtaW5pc3RyYXRvcjpQSlRZVERYOA==
readonly iLO_Summary_Status_File=/tmp/iLO_Summary_Status_File.log
#For Dev
readonly DEV_SSH_USER=radmin
readonly DEV_SSH_PASS=Isso1to3
readonly BIG_DEV_VIP="192.168.20.4"
readonly BIGIP_DEV_Base64="YWRtaW46SXNzbzF0bzM="
readonly SW24_DEV_SSH_USER=admin
readonly SW24_DEV_SSH_PASS=Ch1to3
readonly SW24_DEV_IP=192.168.20.6



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
echo "  # BIG-IP HA Status #"
curl -sk -H "Authorization: Basic ${BIGIP_Base64}" -H "Content-Type: application/json" -X GET https://${BIG_VIP}/mgmt/tm/cm/device | python -mjson.tool | grep -e configsyncIp -e failoverState | awk '{ print $2 }' | sed 's/"//g' | sed 's/,//g' > ${BIGIP_Status_File}

if [ ! -f ${BIGIP_Status_File} ]; then
    echo "     BigIP Status File export failed."
    return 1
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

Sync_Status=`curl -sk -H "Authorization: Basic ${BIGIP_Base64}" -H "Content-Type: application/json" -X GET https://${BIG_VIP}/mgmt/tm/cm/sync-status | python -mjson.tool | grep description | tail -n 2 | head -n 1 | awk -F":" '{ print $2 }' | sed 's/"//g'`

if [ ! -n "${Sync_Status}" ]; then
    echo "     Sync_Status get failed."
    return 1
else
    echo "     Sync Status : ${Sync_Status}"
fi
echo ""

# SSL証明書 更新日チェック
echo "  # Certificates Status #"

curl -sk -H "Authorization: Basic ${BIGIP_Base64}" -H "Content-Type: application/json" -X GET https://${BIG_VIP}/mgmt/tm/sys/crypto/cert/~Common~isso_CA.cer.crt | python -mjson.tool | grep -e name -e expiration -e publicKeyType -e country -e commonName  -e organization | sed 's/^[ \t]*//g' | while true
do
    read line1 #expiration
    read line2 #publicKeyType
    read line3 #commonName
    read line4 #country
    read line5 #name
    read line6 #organization
    if [ -z "$line1" ]; then break ; fi
    expiration=`echo $line1 | awk -F"\":" '{ print $2 }' | sed 's/^[ \t]*//g' | sed 's/\"//g' | sed 's/,//g'`
    expiration_JST=`date -d "${expiration}" +"%Y/%m/%d %H:%M:%S %Z"`
    echo "     expiration    : ${expiration_JST}"
    publicKeyType=`echo $line2 | awk -F":" '{ print $2 }' | sed 's/^[ \t]*//g' | sed 's/\"//g'`
    echo "     publicKeyType : ${publicKeyType}"
    commonName=`echo $line3 | awk -F":" '{ print $2 }' | sed 's/^[ \t]*//g' | sed 's/\"//g' | sed 's/,//g'`
    echo "     commonName    : ${commonName}"
    country=`echo $line4 | awk -F":" '{ print $2 }' | sed 's/^[ \t]*//g' | sed 's/\"//g' | sed 's/,//g'`
    echo "     country       : ${country}"
    name=`echo $line5 | awk -F":" '{ print $2 }' | sed 's/^[ \t]*//g' | sed 's/\"//g' | sed 's/,//g'`
    echo "     name          : ${name}"
    organization=`echo $line6 | awk -F":" '{ print $2 }' | sed 's/^[ \t]*//g' | sed 's/\"//g' | sed 's/,//g'`
    echo "     organization  : ${organization}"
    echo ""

done

curl -sk -H "Authorization: Basic ${BIGIP_Base64}" -H "Content-Type: application/json" -X GET https://${BIG_VIP}/mgmt/tm/sys/crypto/cert/~Common~isso_cert.crt | python -mjson.tool | grep -e name -e expiration -e publicKeyType -e country -e commonName  -e organization | sed 's/^[ \t]*//g' | while true
do
    read line1 #expiration
    read line2 #publicKeyType
    read line3 #commonName
    read line4 #country
    read line5 #name
    read line6 #organization
    if [ -z "$line1" ]; then break ; fi
    expiration=`echo $line1 | awk -F"\":" '{ print $2 }' | sed 's/^[ \t]*//g' | sed 's/\"//g' | sed 's/,//g'`
    expiration_JST=`date -d "${expiration}" +"%Y/%m/%d %H:%M:%S %Z"`
    echo "     expiration    : ${expiration_JST}"
    publicKeyType=`echo $line2 | awk -F":" '{ print $2 }' | sed 's/^[ \t]*//g' | sed 's/\"//g'`
    echo "     publicKeyType : ${publicKeyType}"
    commonName=`echo $line3 | awk -F":" '{ print $2 }' | sed 's/^[ \t]*//g' | sed 's/\"//g' | sed 's/,//g'`
    echo "     commonName    : ${commonName}"
    country=`echo $line4 | awk -F":" '{ print $2 }' | sed 's/^[ \t]*//g' | sed 's/\"//g' | sed 's/,//g'`
    echo "     country       : ${country}"
    name=`echo $line5 | awk -F":" '{ print $2 }' | sed 's/^[ \t]*//g' | sed 's/\"//g' | sed 's/,//g'`
    echo "     name          : ${name}"
    organization=`echo $line6 | awk -F":" '{ print $2 }' | sed 's/^[ \t]*//g' | sed 's/\"//g' | sed 's/,//g'`
    echo "     organization  : ${organization}"
    echo ""

done

#echo "  # Pool List Status #"
#COUNT=0
#curl -sk -H "Authorization: Basic ${BIGIP_Base64}" -H "Content-Type: application/json" -X GET https://${BIG_VIP}/mgmt/tm/ltm/pool |python -mjson.tool | grep "link\"\:" | awk -F"/" '{ print $8 '} | while read LINE
#do
#    curl -sk -H "Authorization: Basic ${BIGIP_Base64}" -H "Content-Type: application/json" -X GET https://${BIG_VIP}/mgmt/tm/ltm/pool/${LINE}/members/stats | python -mjson.tool | awk -e '/addr/ {a=NR} a && NR==a+1' -e '/monitorRule/ {b=NR} b && NR==b+1' -e '/monitorStatus/ {c=NR} c && NR==c+1' -e '/nodeName/ {d=NR} d && NR==d+1' -e '/poolName/ {e=NR} e && NR==e+1' -e '/port/ {f=NR} f && NR==f+1' -e '/status.statusReason/ {g=NR} g && NR==g+1' | while true
#    do
#        read line1 #addr
#        read line2 #monitorRule
#        read line3 #monitorStatus
#        read line4 #nodeName
#        read line5 #poolName
#        read line6 #port
#        read line7 #status.statusReason
#        if [ -z "$line1" ] ; then break ; fi
#
#        poolName=`echo $line5 | awk -F"/" '{print $3 }' | sed 's/\"//g'`
#        monitorRule=`echo $line2 | awk -F"/" '{print $3 }' | sed 's/\"//g'`
#        port=`echo $line6 | awk -F":" '{print $2 }'| sed 's/^[ \t]*//g'`
#        nodeName=`echo $line4 | awk -F"/" '{print $3 }'| sed 's/\"//g'`
#        addr=`echo $line1 | awk -F":" '{print $2 }' | sed 's/\"//g' | sed 's/^[ \t]*//g'`
#        monitorStatus=`echo $line3 | awk -F":" '{print $2 }'| sed 's/^[ \t]*//g' | sed 's/\"//g'`
#        status_statusReason=`echo $line7 | awk -F":" '{print $2 }'| sed 's/^[ \t]*//g' | sed 's/\"//g'`
#        COUNT=`expr $COUNT + 1`
#        if [ $COUNT -eq 1 ]; then
#            echo "     poolName            : ${poolName}"
#            echo "     monitorRule         : ${monitorRule}"
#            echo "     port                : ${port}"
#        fi
#        echo "     nodeName            : ${nodeName}"
#        echo "     addr                : ${addr}"
#        echo "     monitorStatus       : ${monitorStatus}"
#        echo "     status.statusReason : ${status_statusReason}"
#    done
#    echo ""
#done

echo "  # CPU Usage #"
curl -sk -H "Authorization: Basic ${BIGIP_Base64}" -H "Content-Type: application/json" -X GET https://${BIG_VIP}/mgmt/tm/sys/cpu | python -mjson.tool | awk -e '/cpuId/ {a=NR} a && NR==a+1' -e '/fiveMinAvgIdle/ {b=NR} b && NR==b+1' -e '/fiveMinAvgIdle/ {c=NR} c && NR==c+1' -e '/fiveMinAvgUser/ {d=NR} d && NR==d+1' -e '/fiveSecAvgIdle/ {e=NR} e && NR==e+1' -e '/fiveSecAvgSystem/ {f=NR} f && NR==f+1' -e '/fiveSecAvgUser/ {g=NR} g && NR==g+1' | while true
do
    read line1 #cpuId
    read line2 #fiveMinAvgIdle
    read line3 #fiveMinAvgSystem
    read line4 #fiveMinAvgUser
    read line5 #fiveSecAvgIdle
    read line6 #fiveSecAvgSystem
    read line7 #fiveSecAvgUser
    if [ -z "$line1" ] ; then break ; fi
    cpuId=`echo $line1 | awk -F":" '{print $2 }'| sed 's/^[ \t]*//g'`
    fiveMinAvgIdle=`echo $line2 | awk -F":" '{print $2 }'| sed 's/^[ \t]*//g'`
    fiveMinAvgSystem=`echo $line3 | awk -F":" '{print $2 }'| sed 's/^[ \t]*//g'`
    fiveMinAvgUser=`echo $line4 | awk -F":" '{print $2 }'| sed 's/^[ \t]*//g'`
    fiveSecAvgIdle=`echo $line5 | awk -F":" '{print $2 }'| sed 's/^[ \t]*//g'`
    fiveSecAvgSystem=`echo $line6 | awk -F":" '{print $2 }'| sed 's/^[ \t]*//g'`
    fiveSecAvgUser=`echo $line7 | awk -F":" '{print $2 }'| sed 's/^[ \t]*//g'`

    echo "     cpuId            : ${cpuId}"
    echo "     fiveMinAvgIdle   : ${fiveMinAvgIdle}"
    echo "     fiveMinAvgSystem : ${fiveMinAvgSystem}"
    echo "     fiveMinAvgUser   : ${fiveMinAvgUser}"
    echo "     fiveSecAvgIdle   : ${fiveSecAvgIdle}"
    echo "     fiveSecAvgSystem : ${fiveSecAvgSystem}"
    echo "     fiveSecAvgUser   : ${fiveSecAvgUser}"
    echo ""
done

echo "  # Memory Usage #"
curl -sk -H "Authorization: Basic ${BIGIP_Base64}" -H "Content-Type: application/json" -X GET https://${BIG_VIP}/mgmt/tm/sys/memory | python -mjson.tool | awk -e '/memoryFree/ {a=NR} a && NR==a+1' -e '/memoryTotal/ {b=NR} b && NR==b+1' -e '/memoryUsed/ {c=NR} c && NR==c+1' -e '/otherMemoryFree/ {d=NR} d && NR==d+1' -e '/otherMemoryTotal/ {e=NR} e && NR==e+1' -e '/otherMemoryUsed/ {f=NR} f && NR==f+1' -e '/swapFree/ {g=NR} g && NR==g+1' -e '/swapTotal/ {h=NR} h && NR==h+1' -e '/swapUsed/ {i=NR} i && NR==i+1' -e '/tmmMemoryFree/ {j=NR} j && NR==j+1' -e '/tmmMemoryTotal/ {k=NR} k && NR==k+1' -e '/tmmMemoryUsed/ {l=NR} l && NR==l+1' | while true
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
    memoryFree=`echo $line1 | awk -F":" '{print $2 }'| sed 's/^[ \t]*//g'`
    memoryTotal=`echo $line2 | awk -F":" '{print $2 }'| sed 's/^[ \t]*//g'`
    memoryUsed=`echo $line3 | awk -F":" '{print $2 }'| sed 's/^[ \t]*//g'`
    otherMemoryFree=`echo $line4 | awk -F":" '{print $2 }'| sed 's/^[ \t]*//g'`
    otherMemoryTotal=`echo $line5 | awk -F":" '{print $2 }'| sed 's/^[ \t]*//g'`
    otherMemoryUsed=`echo $line6 | awk -F":" '{print $2 }'| sed 's/^[ \t]*//g'`
    swapFree=`echo $line7 | awk -F":" '{print $2 }'| sed 's/^[ \t]*//g'`
    swapTotal=`echo $line8 | awk -F":" '{print $2 }'| sed 's/^[ \t]*//g'`
    swapUsed=`echo $line9 | awk -F":" '{print $2 }'| sed 's/^[ \t]*//g'`
    tmmMemoryFree=`echo $line10 | awk -F":" '{print $2 }'| sed 's/^[ \t]*//g'`
    tmmMemoryTotal=`echo $line11 | awk -F":" '{print $2 }'| sed 's/^[ \t]*//g'`
    tmmMemoryUsed=`echo $line12 | awk -F":" '{print $2 }'| sed 's/^[ \t]*//g'`

    echo "     memoryFree                : $(expr ${memoryFree} / 1024 / 1024 / 1024)GB"
    echo "     memoryTotal               : $(expr ${memoryTotal} / 1024 / 1024 / 1024)GB"
    echo "     memoryUsed                : $(expr ${memoryUsed} / 1024 / 1024 / 1024)GB"
    echo "     memory_Percent_Used       : $(expr 100 \* ${memoryUsed} / ${memoryTotal})"\%""
    echo "     otherMemoryFree           : $(expr ${otherMemoryFree} / 1024 / 1024 / 1024)GB"
    echo "     otherMemoryTotal          : $(expr ${otherMemoryTotal} / 1024 / 1024 / 1024)GB"
    echo "     otherMemoryUsed           : $(expr ${otherMemoryUsed} / 1024 / 1024 / 1024)GB"
    echo "     otherMemory_Percent_Used  : $(expr 100 \* ${otherMemoryUsed} / ${otherMemoryTotal})"\%""
    echo "     swapFree                  : $(expr ${swapFree} / 1024 / 1024 / 1024)GB"
    echo "     swapTotal                 : $(expr ${swapTotal} / 1024 / 1024 / 1024)GB"
    echo "     swapUsed                  : $(expr ${swapUsed} / 1024 / 1024 / 1024)GB"
    echo "     swap_Percent_Used         : $(expr 100 \* ${swapUsed} / ${swapTotal})"\%""
    echo "     tmmMemoryFree             : $(expr ${tmmMemoryFree} / 1024 / 1024 / 1024)GB"
    echo "     tmmMemoryTotal            : $(expr ${tmmMemoryTotal} / 1024 / 1024 / 1024)GB"
    echo "     tmmMemoryUsed             : $(expr ${tmmMemoryUsed} / 1024 / 1024 / 1024)GB"
    echo "     tmmMemory_Percent_Used    : $(expr 100 \* ${tmmMemoryUsed} / ${tmmMemoryTotal})"\%""
    echo ""
done

echo "  # Interface Status #"
curl -sk -H "Authorization: Basic ${BIGIP_Base64}" -H "Content-Type: application/json" -X GET https://${BIG_VIP}/mgmt/tm/net/interface/stats | python -mjson.tool | awk -e '/mediaActive/ {a=NR} a && NR==a+1' -e '/status/ {b=NR} b && NR==b+1' -e '/tmName/ {c=NR} c && NR==c+1' | while true
do
    read line1 #mediaActive
    read line2 #status
    read line3 #tmName
    if [ -z "$line1" ] ; then break ; fi
mediaActive=`echo $line1 | awk -F":" '{print $2 }'| sed 's/^[ \t]*//g' | sed 's/\"//g'`
status=`echo $line2 | awk -F":" '{print $2 }'| sed 's/^[ \t]*//g' | sed 's/\"//g'`
tmName=`echo $line3 | awk -F":" '{print $2 }'| sed 's/^[ \t]*//g' | sed 's/\"//g'`
echo "     tmName      : ${tmName}"
echo "     mediaActive : ${mediaActive}"
echo "     status      : ${status}"
echo ""

done

if [ -f ${BIGIP_Status_File} ]; then
    rm -f ${BIGIP_Status_File} >/dev/null 2>&1
fi

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
    Network_Interface_DeviceName=`exec setsid ssh -o "StrictHostKeyChecking=no" ${SSH_USER}@${host} "nmcli device show | grep GENERAL.デバイス | grep -v lo" 2>/dev/null`
    Extraction=`echo ${Network_Interface_DeviceName} | sed 's/GENERAL.デバイス://g'`

    for LINE in ${Extraction[@]}
    do
        Network_Interface_status=`exec setsid ssh -o "StrictHostKeyChecking=no" ${SSH_USER}@${host} "/usr/sbin/ethtool $LINE 2>/dev/null | grep -e Settings -e 'Link detected' -e Speed -e Duplex" 2>/dev/null`
        echo "     ${Network_Interface_status}"
    done
    echo ""

    # httpd Process
    httpd_Proc_Count=`exec setsid ssh -o "StrictHostKeyChecking=no" ${SSH_USER}@${host} "ps -ef | grep httpd | grep -v grep | grep -v root | wc -l" 2>/dev/null`
    echo "  # Proccess Status #"
    echo "     httpd Proccess Count : ${httpd_Proc_Count}"
    echo ""

    # Failover Cert
    DFW_PWD_Cert_Primary=`exec setsid ssh -o "StrictHostKeyChecking=no" ${SSH_USER}@${host} "grep -v -e '^\s*#' -e '^\s*$' ${DFW_PWD_conf} | grep CERT=" 2>/dev/null`
    DFW_PWD_Cert_Standby=`exec setsid ssh -o "StrictHostKeyChecking=no" ${SSH_USER}@${host} "grep -v -e '^\s*#' -e '^\s*$' ${DFW_PWD_conf} | grep CERT= " 2>/dev/null`
    DFW_DGO_Cert_Primary=`exec setsid ssh -o "StrictHostKeyChecking=no" ${SSH_USER}@${host} "grep -v -e '^\s*#' -e '^\s*$' ${DFW_DGO_conf} | grep CERT= " 2>/dev/null`
    DFW_DGO_Cert_Standby=`exec setsid ssh -o "StrictHostKeyChecking=no" ${SSH_USER}@${host} "grep -v -e '^\s*#' -e '^\s*$' ${DFW_DGO_conf} | grep CERT= " 2>/dev/null`

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
    Network_Interface_DeviceName=`exec setsid ssh -o "StrictHostKeyChecking=no" ${SSH_USER}@${host} "nmcli device show | grep GENERAL.デバイス | grep -v lo" 2>/dev/null`
    Extraction=`echo ${Network_Interface_DeviceName} | sed 's/GENERAL.デバイス://g'`

    for LINE in ${Extraction[@]}
    do
        Network_Interface_status=`exec setsid ssh -o "StrictHostKeyChecking=no" ${SSH_USER}@${host} "/usr/sbin/ethtool $LINE 2>/dev/null | grep -e Settings -e 'Link detected' -e Speed -e Duplex" 2>/dev/null`
        echo "     ${Network_Interface_status}"
    done
    echo ""
    # httpd Process
    httpd_Proc_Count=`exec setsid ssh -o "StrictHostKeyChecking=no" ${SSH_USER}@${host} "ps -ef | grep httpd | grep -v grep | grep -v root | wc -l" 2>/dev/null`
    echo "  # Proccess Status #"
    echo "     httpd Proccess Count : ${httpd_Proc_Count}"

    #Process tomcat
    Tomcat_PWD_Proc=`exec setsid ssh -o "StrictHostKeyChecking=no" ${SSH_USER}@${host} "ps -ef | grep java | grep tomcat_dmp_pwd | grep -v grep | wc -l" 2>/dev/null`
    Tomcat_DGO_Proc=`exec setsid ssh -o "StrictHostKeyChecking=no" ${SSH_USER}@${host} "ps -ef | grep java | grep tomcat_dmp_dgo | grep -v grep | wc -l" 2>/dev/null`

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
    Certd_PWD_Proc=`exec setsid ssh -o "StrictHostKeyChecking=no" ${SSH_USER}@${host} "ps -ef | grep certd | grep "\/config\/" | grep -v grep | wc -l" 2>/dev/null`
    Certd_DGO_Proc=`exec setsid ssh -o "StrictHostKeyChecking=no" ${SSH_USER}@${host} "ps -ef | grep certd | grep "\/config_dgo\/" | grep -v grep | wc -l" 2>/dev/null`

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
    DFW_PWD_LDAP_Primary=`exec setsid ssh -o "StrictHostKeyChecking=no" ${SSH_USER}@${host} "grep -v -e '^\s*#' -e '^\s*$' ${Cert_PWD_conf} | grep DBHOST="  2>/dev/null`
    DFW_PWD_LDAP_Standby=`exec setsid ssh -o "StrictHostKeyChecking=no" ${SSH_USER}@${host} "grep -v -e '^\s*#' -e '^\s*$' ${Cert_PWD_conf} | grep DBHOST="  2>/dev/null`
    DFW_DGO_LDAP_Primary=`exec setsid ssh -o "StrictHostKeyChecking=no" ${SSH_USER}@${host} "grep -v -e '^\s*#' -e '^\s*$' ${Cert_DGO_conf} | grep DBHOST="  2>/dev/null`
    DFW_DGO_LDAP_Standby=`exec setsid ssh -o "StrictHostKeyChecking=no" ${SSH_USER}@${host} "grep -v -e '^\s*#' -e '^\s*$' ${Cert_DGO_conf} | grep DBHOST="  2>/dev/null`

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
    DMP_PWD_Cert_Primary=`exec setsid ssh -o "StrictHostKeyChecking=no" ${SSH_USER}@${host} "grep -v -e '^\s*#' -e '^\s*$' ${Cert_DMP_PWD_conf} | grep dmp:Active"  2>/dev/null`
    DMP_PWD_Cert_Standby=`exec setsid ssh -o "StrictHostKeyChecking=no" ${SSH_USER}@${host} "grep -v -e '^\s*#' -e '^\s*$' ${Cert_DMP_PWD_conf} | grep dmp:Standby"  2>/dev/null`
    DMP_DGO_Cert_Primary=`exec setsid ssh -o "StrictHostKeyChecking=no" ${SSH_USER}@${host} "grep -v -e '^\s*#' -e '^\s*$' ${Cert_DMP_DGO_conf} | grep dmp:Active"  2>/dev/null`
    DMP_DGO_Cert_Standby=`exec setsid ssh -o "StrictHostKeyChecking=no" ${SSH_USER}@${host} "grep -v -e '^\s*#' -e '^\s*$' ${Cert_DMP_DGO_conf} | grep dmp:Standby"  2>/dev/null`

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
    Network_Interface_DeviceName=`exec setsid ssh -o "StrictHostKeyChecking=no" ${SSH_USER}@${host} "nmcli device show | grep GENERAL.デバイス | grep -v lo"  2>/dev/null`
    Extraction=`echo ${Network_Interface_DeviceName} | sed 's/GENERAL.デバイス://g'`

    for LINE in ${Extraction[@]}
    do
        Network_Interface_status=`exec setsid ssh -o "StrictHostKeyChecking=no" ${SSH_USER}@${host} "/usr/sbin/ethtool $LINE 2>/dev/null | grep -e Settings -e 'Link detected' -e Speed -e Duplex"  2>/dev/null`
        echo "     ${Network_Interface_status}"
    done
    echo ""

    # LDAP Process
    echo "  # Proccess Status #"
    LDAP_Proc=`exec setsid ssh -o "StrictHostKeyChecking=no" ${SSH_USER}@${host} "ps -ef | grep slapd | grep -v grep | wc -l"  2>/dev/null`
    if [ ${LDAP_Proc} -eq 1 ]; then
        echo "     OpenLDAP Proccess is alive."
    else
        echo "     OpenLDAP Proccess is dead."
    fi

    Cron_Proc=`exec setsid ssh -o "StrictHostKeyChecking=no" ${SSH_USER}@${host} "ps -ef | grep crond | grep -v grep | wc -l"  2>/dev/null`
    if [ ${Cron_Proc} -eq 1 ]; then
        echo "     Cron Proccess is alive."
    else
        echo "     Cron Proccess is dead."
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
    Network_Interface_DeviceName=`exec setsid ssh -o "StrictHostKeyChecking=no" ${SSH_USER}@${host} "nmcli device show | grep GENERAL.デバイス | grep -v lo"  2>/dev/null`
    Extraction=`echo ${Network_Interface_DeviceName} | sed 's/GENERAL.デバイス://g'`

    for LINE in ${Extraction[@]}
    do
        Network_Interface_status=`exec setsid ssh -o "StrictHostKeyChecking=no" ${SSH_USER}@${host} "/usr/sbin/ethtool $LINE 2>/dev/null | grep -e Settings -e 'Link detected' -e Speed -e Duplex"  2>/dev/null`
        echo "     ${Network_Interface_status}"
    done
    echo ""

    # LDAP Process
    echo "  # Proccess Status #"
    LDAP_Proc=`exec setsid ssh -o "StrictHostKeyChecking=no" ${SSH_USER}@${host} "ps -ef | grep slapd | grep -v grep | wc -l"  2>/dev/null`
    if [ ${LDAP_Proc} -eq 1 ]; then
        echo "     OpenLDAP Proccess is alive."
    else
        echo "     OpenLDAP Proccess is dead."
    fi

    Postfix_Proc=`exec setsid ssh -o "StrictHostKeyChecking=no" ${SSH_USER}@${host} "ps -ef | grep postfix | grep master | grep -v grep | wc -l"  2>/dev/null`
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
    #Network_Interface_DeviceName=`exec setsid ssh -o "StrictHostKeyChecking=no" ${SSH_USER}@${Zabbix_Server_IP} "nmcli device show | grep "GENERAL. デバイス" | grep -v lo"  2>/dev/null`
    Network_Interface_DeviceName=`exec setsid ssh -o "StrictHostKeyChecking=no" ${SSH_USER}@${Zabbix_Server_IP} "nmcli device show | grep GENERAL.デバイス | grep -v lo"  2>/dev/null`

    Extraction=`echo ${Network_Interface_DeviceName} | sed 's/GENERAL.デバイス://g'`

    for LINE in ${Extraction[@]}
    do
        Network_Interface_status=`exec setsid ssh -o "StrictHostKeyChecking=no" ${SSH_USER}@${Zabbix_Server_IP} "/usr/sbin/ethtool $LINE 2>/dev/null | grep -e Settings -e 'Link detected' -e Speed -e Duplex"  2>/dev/null`
        echo "     ${Network_Interface_status}"
    done
    echo ""

    # Zabbix Process
    echo "  # Proccess Status #"
    Zabbix_Server_Proc=`exec setsid ssh -o "StrictHostKeyChecking=no" ${SSH_USER}@${Zabbix_Server_IP} "ps -ef | grep zabbix_server.conf | grep -v grep | wc -l"  2>/dev/null`
    if [ ${Zabbix_Server_Proc} -eq 1 ]; then
        echo "     Zabbix Server Proccess is alive."
    else
        echo "     Zabbix Server Proccess is dead."
    fi

    httpd_Proc_Count=`exec setsid ssh -o "StrictHostKeyChecking=no" ${SSH_USER}@${Zabbix_Server_IP} "ps -ef | grep httpd | grep -v grep | grep -v root | wc -l"  2>/dev/null`
    echo "     httpd Proccess Count : ${httpd_Proc_Count}"

    MariaDB_Proc=`exec setsid ssh -o "StrictHostKeyChecking=no" ${SSH_USER}@${Zabbix_Server_IP} "ps -ef | grep mysqld | grep -v grep | wc -l"  2>/dev/null`
    if [ ${MariaDB_Proc} -eq 2 ]; then
        echo "     MariaDB Proccess is alive."
    else
        echo "     MariaDB Proccess is dead."
    fi
    echo ""

    echo "  # Zabbix Alert Message (From 7 days ago) #"
    #Session ID
    Session_ID=`curl -s -d '{"auth": null,"method": "user.login","id": "null","params": {"password": "'${Zabbix_Password}'","user": "'${Zabbix_UserName}'"},"jsonrpc": "2.0"}' -H "Accept: application/json" -H "Content-Type: application/json-rpc" ${Zabbix_URL} | python -mjson.tool | grep result | awk -F":" '{ print $2 }' | sed 's/\"//g' | sed 's/ *//g'`

    #GET
    from_time=`date +"%s" --date "7 days ago"`
    echo -e `curl -s -d '{"auth": "'${Session_ID}'","method": "alert.get","id": 1,"params": {"output": "extend","time_from": "'"${from_time}"'"},"jsonrpc": "2.0"}' -H "Content-Type: application/json-rpc" ${Zabbix_URL} | python -mjson.tool` > ${Zabbix_TMP_File}

    #改行コード修正
    sed -i -e 's/\"\,/\"\n/g' -i -e 's/\r//g' ${Zabbix_TMP_File}
    sed -i -e 's/^[ ]//g' -i -e 's/"//g' ${Zabbix_TMP_File}

    #0件の場合
    if [ `grep -v -e '^retries:' -e '^sendto:' -e '^status:' -e '^userid:' -e '^alertid:' -e '^alerttype:' -e '^error:' -e '^esc_step:' -e '^eventid:' -e '^mediatypeid:' -e '^result:' -e '^{ id' -e '^subject:' -e '^\s*$' ${Zabbix_TMP_File} | wc -l` -eq 0 ]; then
        echo "     Zabbix Message is nothing."
    fi 

    #余計な行削除し、メッセージを出力
    grep -v -e '^retries:' -e '^sendto:' -e '^status:' -e '^userid:' -e '^alertid:' -e '^alerttype:' -e '^error:' -e '^esc_step:' -e '^eventid:' -e '^mediatypeid:' -e '^result:' -e '^{ id' -e '^subject:' -e '^\s*$' ${Zabbix_TMP_File} | while true
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
    rm -f ${Zabbix_TMP_File} >/dev/null 2>&1
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

echo "  # Prism Cluster Status #"

if [ -f ${Prism_Cluster_Status_File} ]; then
    rm -f ${Prism_Cluster_Status_File} >/dev/null 2>&1
fi

Prism_Cluster_Status=`exec setsid ssh -o "StrictHostKeyChecking=no" ${Nutanix_SSH_USER}@${Prism_VIP} "/usr/local/nutanix/cluster/bin/cluster status" > ${Prism_Cluster_Status_File} 2>/dev/null`

#exec setsid ssh -o "StrictHostKeyChecking=no" ${Nutanix_SSH_USER}@${Prism_VIP} "/usr/local/nutanix/cluster/bin/cluster status" > ${Prism_Cluster_Status_File} 2>/dev/null
#exec setsid ssh -o "StrictHostKeyChecking=no" ${Nutanix_SSH_USER}@${Prism_VIP} "bash /home/nutanix/test.bash" > ${Prism_Cluster_Status_File} 
#echo ${Prism_Cluster_Status} > ${Prism_Cluster_Status_File}

#Prism_Server_Status=`cat ${Prism_Cluster_Status_File} | grep "CVM:" | awk '{ print $2,$3 }' | sed 's/,//g'`
Prism_Cluster_Status=`cat ${Prism_Cluster_Status_File} | grep "The state of the cluster"`

echo "     ${Prism_Cluster_Status}"
cat ${Prism_Cluster_Status_File} | grep "CVM:" | awk '{ print $2,$3 }' | sed 's/,//g' | while true
do

    read line1
    if [ -z "$line1" ] ; then break ; fi
    CVM_IP=`echo $line1 | awk '{ print $1 }'`
    CVM_Status=`echo $line1 | awk '{ print $2 }'`

    case ${CVM_IP} in
        ${CVM_IP_1})
        echo "     CVM#1 : ${CVM_Status}"
        ;;
        ${CVM_IP_2})
        echo "     CVM#2 : ${CVM_Status}"
        ;;
        ${CVM_IP_3})
        echo "     CVM#3 : ${CVM_Status}"
        ;;
    esac
done

CVM1_Server_Process_Count=`cat ${Prism_Cluster_Status_File} | awk '/192.168.20.91/,/192.168.20.92/' | sed -e '$d' | sed -e '1d' | sed -e '/^$/d' | grep UP | wc -l`
CVM2_Server_Process_Count=`cat ${Prism_Cluster_Status_File} | awk '/192.168.20.92/,/192.168.20.93/' | sed -e '$d' | sed -e '1d' | sed -e '/^$/d' | grep UP | wc -l`
CVM3_Server_Process_Count=`cat ${Prism_Cluster_Status_File} | tac | sed '/192.168.20.93/q' | tac | sed -e '1d' | grep UP | wc -l`

echo "     CVM#1 Process is ${CVM1_Server_Process_Count}/${Prism_Process_Count}"
echo "     CVM#2 Process is ${CVM2_Server_Process_Count}/${Prism_Process_Count}"
echo "     CVM#3 Process is ${CVM3_Server_Process_Count}/${Prism_Process_Count}"
echo ""

if [ -f ${Prism_Cluster_Status_File} ]; then
    rm -f ${Prism_Cluster_Status_File} >/dev/null 2>&1
fi

#echo "  # Prism Virtual Machine Status #"
# Virtual Machine UUIDを全て出力
#curl -s -k -H "Authorization: Basic ${Prism_Base64}" -H 'Accept: application/json' -X GET "${Prism_URL}/api/nutanix/v2.0/vms/" | python -mjson.tool | grep -e "\"uuid\"" -e name| while true
#do
#    read line1
#    read line2
#    if [ -z "$line1" ] ; then break ; fi
    #Virtual_Machine_Name抽出
#    Virtual_Machine_Name=`echo $line1 | awk -F":" '{ print $2}'| sed 's/\"//g' | awk -F"," '{ print $1 }'`
    #Virtual_Machine_UUID抽出
#    Virtual_Machine_UUID=`echo $line2 | awk -F":" '{ print $2}'| sed 's/\"//g' | awk -F"," '{ print $1 }' | sed 's/ *//g'`
#    echo ${Virtual_Machine_Name} ${Virtual_Machine_UUID}

    # Virtual_Machine_UUIDから各仮想マシンの状態を出力
#    curl -s -k -H "Authorization: Basic ${Prism_Base64}" -H 'Accept: application/json' -X GET "${Prism_URL}/PrismGateway/services/rest/v2.0/vms/${Virtual_Machine_UUID}" | python -mjson.tool | while true
#    do
#        read line1
#        read line2
#        read line3
#        read line4
#        read line5
#        read line6
#        read line7
#        read line8
#        read line9
#        read line10
#        read line11
#        read line12
#        read line13
#        read line14
#    if [ -z "$line1" ] ; then break ; fi
#    if [ -z "$line6" ] ; then break ; fi

#        Virtual_Machine_Name=`echo $line7 | awk -F":" '{ print $2}' | awk -F"," '{ print $1 }' | sed 's/ *//g' | sed 's/\"//g'`
#        VCPU_num=`echo $line9 | awk -F":" '{ print $2}' | awk -F"," '{ print $1 }' | sed 's/ *//g' | sed 's/\"//g'`
#        Core_Per_VCPU_num=`echo $line8 | awk -F":" '{ print $2}' | awk -F"," '{ print $1 }' | sed 's/ *//g' | sed 's/\"//g'`
#        Memory_allocation=`echo $line6 | awk -F":" '{ print $2}' | awk -F"," '{ print $1 }' | sed 's/ *//g' | sed 's/\"//g'`
#        Power_State=`echo $line10 | awk -F":" '{ print $2}' | awk -F"," '{ print $1 }' | sed 's/ *//g' | sed 's/\"//g'`
#        UUID=`echo $line13 | awk -F":" '{ print $2}' | awk -F"," '{ print $1 }' | sed 's/ *//g' | sed 's/\"//g'`

#        echo "    Virtual Machine Name : ${Virtual_Machine_Name}"
#        echo "    vCPU num             : ${VCPU_num}"
#        echo "    Core_Per_vCPU_num    : ${Core_Per_VCPU_num}"
#        echo "    Memory allocation    : ${Memory_allocation}"
#        echo "    Power State          : ${Power_State}"
#        echo "    UUID                 : ${UUID}"
#        echo ""
#    done
#done

echo "  # Prism Alert Status #"
Total_Count=`curl -sk -H "Authorization: Basic ${Prism_Base64}" -H 'Accept: application/json' -X GET ${Prism_URL}/PrismGateway/services/rest/v2.0/alerts/?severity=WARNING,CRITICAL\&resolved=false | python -mjson.tool | grep grand_total_entities | awk '{ print $2 }' | sed 's/,//g'`

if [ ${Total_Count} -eq 0 ]; then
    echo "    The total of alerts was 0"
else
    echo "    The total of alerts was ${Total_Count}"
    
    curl -sk -H "Authorization: Basic ${Prism_Base64}" -H 'Accept: application/json' -X GET ${Prism_URL}/PrismGateway/services/rest/v2.0/alerts/?severity=WARNING,CRITICAL\&resolved=false | python -mjson.tool | grep -e acknowledged_time_stamp_in_usecs -e "\"entity_type\"" -e alert_title -e "\"message\"" -e severity | while true
    do
        read line1 #acknowledged_time_stamp_in_usec
        read line2 #entity_type
        read line3 #alert_title
        read line4 #message
        read line5 #severity
        if [ -z "$line1" ] ; then break ; fi
        acknowledged_time_stamp_in_usec=`echo $line1 | awk -F":" '{ print$2 }' | cut -c 1-11 | awk '{print strftime("%c",$1)}'`
        entity_type=`echo $line2 | awk -F":" '{ print$2 }' | sed 's/^ //g' | sed 's/"//g' | sed 's/,$//g'`
        alert_title=`echo $line3 | awk -F":" '{ print$2 }' | sed 's/^ //g' | sed 's/"//g' | sed 's/,$//g'`
        message=`echo $line4 | awk -F":" '{ print$2 }' | sed 's/^ //g' | sed 's/"//g'`
        severity=`echo $line5 | awk -F":" '{ print$2 }' | sed 's/^ //g' | sed 's/"//g' | sed 's/^k//g' | sed 's/,$//g'`

       echo "     Time Stamp   : ${acknowledged_time_stamp_in_usec}"
       echo "     Entity Type  : ${entity_type}"
       echo "     Alert Title  : ${alert_title}"
       echo "     Alert Mesage : ${message}"
       echo "     Severity     : ${severity}"
       echo ""
    done
fi
echo ""
return 0
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
return 0
}

function TEST_Status () {

export PASSWORD=$Nutanix_SSH_PASS
export SSH_ASKPASS=$0
export DISPLAY=dummy:0

CVM1_Mem_Total=`exec setsid ssh -o "StrictHostKeyChecking=no" ${Nutanix_SSH_USER}@${CVM_IP_1} "cat /proc/meminfo | grep MemTotal | tr -cd '0123456789'"  2>/dev/null`

CVM1_Mem_Available=`exec setsid ssh -o "StrictHostKeyChecking=no" ${Nutanix_SSH_USER}@${CVM_IP_1} "cat /proc/meminfo | grep MemAvailable | tr -cd '0123456789'"  2>/dev/null`

CVM2_Mem_Total=`exec setsid ssh -o "StrictHostKeyChecking=no" ${Nutanix_SSH_USER}@${CVM_IP_2} "cat /proc/meminfo | grep MemTotal | tr -cd '0123456789'"  2>/dev/null`

CVM2_Mem_Available=`exec setsid ssh -o "StrictHostKeyChecking=no" ${Nutanix_SSH_USER}@${CVM_IP_2} "cat /proc/meminfo | grep MemAvailable | tr -cd '0123456789'"  2>/dev/null`

CVM3_Mem_Total=`exec setsid ssh -o "StrictHostKeyChecking=no" ${Nutanix_SSH_USER}@${CVM_IP_3} "cat /proc/meminfo | grep MemTotal | tr -cd '0123456789'"  2>/dev/null`

CVM3_Mem_Available=`exec setsid ssh -o "StrictHostKeyChecking=no" ${Nutanix_SSH_USER}@${CVM_IP_3} "cat /proc/meminfo | grep MemAvailable | tr -cd '0123456789'"  2>/dev/null`

CVM1_Mem_Usage=$((100 * ${CVM1_Mem_Available} / ${CVM1_Mem_Total}))
CVM2_Mem_Usage=$((100 * ${CVM2_Mem_Available} / ${CVM2_Mem_Total}))
CVM3_Mem_Usage=$((100 * ${CVM3_Mem_Available} / ${CVM3_Mem_Total}))

echo "     CVM1_Mem_Usage is : ${CVM1_Mem_Usage}"
echo "     CVM2_Mem_Usage is : ${CVM2_Mem_Usage}"
echo "     CVM3_Mem_Usage is : ${CVM3_Mem_Usage}"
return 0
}

###########################
### ISSO-SW24(Cisco3850)###
###########################
function SW24_Status () {

export PASSWORD=$SW24_SSH_PASS
export SSH_ASKPASS=$0
export DISPLAY=dummy:0

echo "### SW24 Status ###"
echo "  # SW24 I/F Summary Status #"

exec setsid ssh -o "StrictHostKeyChecking=no" ${SW24_SSH_USER}@${SW24_IP} "show interfaces status"  2>/dev/null | grep -v disabled | grep -v test | sed '1,4d' > ${SW24_Interface_Log} 

sed -i -e '1,2d' ${SW24_Interface_Log}
sed -i -e 's/^/      /g' ${SW24_Interface_Log}
cat ${SW24_Interface_Log}
echo ""

echo "  # SW24 I/F Individual Status #"

for line in `cat ${SW24_Interface_Log} | awk '{ print $1 }'`
do
    Interface_Name=$line
    if [ "$Interface_Name" != "Port" ]; then
        exec setsid ssh -n -o "StrictHostKeyChecking=no" ${SW24_SSH_USER}@${SW24_IP} "show interfaces ${Interface_Name}" 2>/dev/null | grep -e "line protocol" -e "input errors" -e "output errors" -e "unknown protocol drops" -e "babbles" -e "lost carrier" -e "output buffer failures" | while true
        do
            read line1
            read line2
            read line3
            read line4
            read line5
            read line6
            read line7
            if [ -z "$line1" ]; then break ; fi
            echo "     `echo $line1 | sed 's/^ *//g'`"
            echo "      `echo $line2 | sed 's/^ *//g'`"
            echo "      `echo $line3 | sed 's/^ *//g'`"
            echo "      `echo $line4 | sed 's/^ *//g'`"
            echo "      `echo $line5 | sed 's/^ *//g'`"
            echo "      `echo $line6 | sed 's/^ *//g'`"
            echo "      `echo $line7 | sed 's/^ *//g'`"
            echo ""
        done
    fi

done

echo "  # SW24 CPU Usage #"

exec setsid ssh -o "StrictHostKeyChecking=no" ${SW24_SSH_USER}@${SW24_IP} "show processes cpu sort | exclude 0.0" 2>/dev/null | grep "CPU utilization" | awk -F":" '{ print $2 $3 $4 }' | awk '{ print $1,$4,$7 }' | while true
do
    read line1
    if [ -z "$line1" ]; then break ; fi
    echo "    Five Seconds : `echo $line1 | awk '{ print $1 }' | sed 's/\;//g'`"
    echo "    One Minute   : `echo $line1 | awk '{ print $2 }' | sed 's/\;//g'`"
    echo "    Five Minutes : `echo $line1 | awk '{ print $3 }'`"
    echo ""
done


echo "  # SW24 Memory Usage #"

exec setsid ssh -o "StrictHostKeyChecking=no" ${SW24_SSH_USER}@${SW24_IP} "show processes memory" 2>/dev/null | grep Processor | awk '{ print $4,$6,$8 }' | while true
do
    read line1
    if [ -z "$line1" ]; then break ; fi
    Memory_Total=`echo $line1 | awk '{ print $1 }'`
    Memory_Total_MB="$(expr ${Memory_Total} / 1024 / 1024 / 8)"
    Memory_Used=`echo $line1 | awk '{ print $2 }'`
    Memory_Used_MB="$(expr ${Memory_Used} / 1024 / 1024 / 8)"
    Memory_Free=`echo $line1 | awk '{ print $3 }' | sed 's/\r//g'`
    Memory_Free_MB="$(expr ${Memory_Free} / 1024 / 1024 / 8)"
    Memory_Utilization="$(expr 100 \* ${Memory_Used} / ${Memory_Total})"\%""
    echo "     Memory Total       : ${Memory_Total_MB}"MB""
    echo "     Memory Used        : ${Memory_Used_MB}"MB""
    echo "     Memory Free        : ${Memory_Free_MB}"MB""
    echo "     Memory Utilization : ${Memory_Utilization}"
    echo ""
done

if [ -f ${SW24_Interface_Log} ]; then
    rm -f ${SW24_Interface_Log} >/dev/null 2>&1
fi
return 0
}

######################
### iDrac          ###
######################
function iDrac_Status () {

export PASSWORD=$iDrac_SSH_PASS
export SSH_ASKPASS=$0
export DISPLAY=dummy:0

if [ -f ${iDrac_TMP_Status_File} ]; then
    rm -f $iDrac_TMP_Status_File} >/dev/null 2>&1
fi
ARRAY=(${iDrac1_IP} ${iDrac2_IP} ${iDrac3_IP})
for iDrac_IP in ${ARRAY[@]}; do

    iDrac_URL="https://${iDrac_IP}"
    case ${iDrac_IP} in
        ${iDrac1_IP})
        echo "### iDrac#1 Status ###"
        ;;
        ${iDrac2_IP})
        echo "### iDrac#2 Status ###"
        ;;
        ${iDrac3_IP})
        echo "### iDrac#3 Status ###"
        ;;
        *)
        echo "     Target iDrac is none."
        ;;
    esac

    #System Summary Status
    curl -sk -H "Authorization: Basic ${iDrac_Base64}" -H 'Accept: application/json' -X GET ${iDrac_URL}/redfish/v1/Systems/System.Embedded.1 | python -mjson.tool > ${iDrac_TMP_Status_File}

    #CPU Summary Status
    CPU_Status=`cat ${iDrac_TMP_Status_File} | awk -e '/ProcessorSummary/ {a=NR} a && NR==a+4' | awk -F":" '{ print $2 }' | sed 's/^[ \t]*//g' | sed 's/\"//g' | sed 's/,//g'`
    echo "     CPU Status             : ${CPU_Status}"

    #MEM Summary Status
    Memory_Status=`cat ${iDrac_TMP_Status_File} | awk -e '/MemorySummary/ {a=NR} a && NR==a+3' | awk -F":" '{ print $2 }' | sed 's/^[ \t]*//g' | sed 's/\"//g' | sed 's/,//g'`
    echo "     Memory Status          : ${Memory_Status}"

    #Disk Summary Status
    Disk_Status=`cat ${iDrac_TMP_Status_File} | awk -e '/SimpleStorage/ {a=NR} a && NR==a+4' | awk -F":" '{ print $2 }' | sed 's/^[ \t]*//g' | sed 's/\"//g' | sed 's/,//g'`

    echo "     Disk Status            : ${Disk_Status}"

    #PowerSupply
    PS1_Status=`curl -sk -H "Authorization: Basic ${iDrac_Base64}" -H 'Accept: application/json' -X GET ${iDrac_URL}/redfish/v1/Chassis/System.Embedded.1/Power/PowerSupplies/PSU.Slot.1 | python -mjson.tool | awk -e '/SparePartNumber/ {a=NR} a && NR==a+2' | awk -F":" '{ print $2 }' | sed 's/^[ \t]*//g' | sed 's/\"//g' | sed 's/,//g'`

    PS2_Status=`curl -sk -H "Authorization: Basic ${iDrac_Base64}" -H 'Accept: application/json' -X GET ${iDrac_URL}/redfish/v1/Chassis/System.Embedded.1/Power/PowerSupplies/PSU.Slot.2 | python -mjson.tool | awk -e '/SparePartNumber/ {a=NR} a && NR==a+2' | awk -F":" '{ print $2 }' | sed 's/^[ \t]*//g' | sed 's/\"//g' | sed 's/,//g'`

    echo "     PS1 Status             : ${PS1_Status}"
    echo "     PS2 Status             : ${PS2_Status}"

    #fan and voltage
    curl -sk -H "Authorization: Basic ${iDrac_Base64}" -H 'Accept: application/json' -X GET ${iDrac_URL}/redfish/v1/Chassis/System.Embedded.1/Thermal | python -mjson.tool | grep -e Health -e "\"Name\"" | grep -v Thermal | while true
    do
        read line1
        read line2
        if [ -z "$line1" ] ; then break ; fi
        Target_Name=`echo $line1 | awk -F":" '{ print$2 }' | sed 's/^[ \t]*//g' | sed 's/\"//g' | sed 's/,$//g'`
        Target_Status=`echo $line2 | awk -F":" '{ print$2 }' | sed 's/^[ \t]*//g' | sed 's/\"//g' | sed 's/,$//g'`
        echo "     ${Target_Name} Status : ${Target_Status}"
    done

    #System Board Intrusion
    System_Board_Intrusion=`curl -sk -H "Authorization: Basic ${iDrac_Base64}" -H 'Accept: application/json' -X GET ${iDrac_URL}/redfish/v1/Chassis/System.Embedded.1 | python -mjson.tool | awk -e '/PhysicalSecurity/ {a=NR} a && NR==a+1' | awk -F":" '{ print $2 }' | sed 's/^[ \t]*//g' | sed 's/\"//g' | sed 's/,//g'`
    echo "     System Board Intrusion : ${System_Board_Intrusion}"

    if [ -f ${iDrac_TMP_Status_File} ]; then
        rm -f $iDrac_TMP_Status_File} >/dev/null 2>&1
    fi

    CMOS_Battery_Status=`exec setsid ssh -o "StrictHostKeyChecking=no" ${iDrac_SSH_USER}@${iDrac_IP} "racadm getsensorinfo" 2>/dev/null | grep "System Board CMOS Battery" | awk '{ print $5 }'`
    echo "     CMOS Battery Status  : ${CMOS_Battery_Status}"
    echo "" 
done

if [ -f ${iDrac_TMP_Status_File} ]; then
    rm -f ${iDrac_TMP_Status_File} >/dev/null 2>&1
fi
return 0
}

######################
### iLO            ###
######################
function iLO_Status () {

if [ -f ${iLO_Summary_Status_File} ]; then
    rm -f ${iLO_Summary_Status_File} >/dev/null 2>&1
fi

curl -sk -H "Authorization: Basic ${iLO_Base64}" -H 'Accept: application/json' -X GET https://${iLO_Address}/rest/v1/systems/1 --insecure -L | python -mjson.tool > ${iLO_Summary_Status_File}

if [ -s ${iLO_Summary_Status_File} ]; then

    BIOS_HW_Status=`cat ${iLO_Summary_Status_File} | awk -e '/BiosOrHardwareHealth/ {a=NR} a && NR==a+2' | awk -F":" '{ print $2 }' | sed 's/^[ \t]*//g' | sed 's/\"//g' | sed 's/,//g'`

    Fan_Redundancy_Status=`cat ${iLO_Summary_Status_File} | grep FanRedundancy | awk -F":" '{ print $2 }' | sed 's/^[ \t]*//g' | sed 's/\"//g' | sed 's/,//g'`

    Fans_Status=`cat ${iLO_Summary_Status_File} | awk -e '/\"Fans\"/ {a=NR} a && NR==a+2' | awk -F":" '{ print $2 }' | sed 's/^[ \t]*//g' | sed 's/\"//g' | sed 's/,//g'`

    Memory_Status=`cat ${iLO_Summary_Status_File} | awk -e '/\"Memory\"/ {a=NR} a && NR==a+2' | tail -n 1 | awk -F":" '{ print $2 }' | sed 's/^[ \t]*//g' | sed 's/\"//g' | sed 's/,//g'`

    Network_Interface1=`curl -sk -H "Authorization: Basic ${iLO_Base64}" -H 'Accept: application/json' -X GET https://${iLO_Address}/rest/v1/Systems/1/EthernetInterfaces/1 --insecure -L | python -mjson.tool | grep Health | awk -F":" '{ print $2 }' | sed 's/^[ \t]*//g' | sed 's/\"//g' | sed 's/,//g'`
   
    Network_Interface2=`curl -sk -H "Authorization: Basic ${iLO_Base64}" -H 'Accept: application/json' -X GET https://${iLO_Address}/rest/v1/Systems/1/EthernetInterfaces/2 --insecure -L | python -mjson.tool | grep Health | awk -F":" '{ print $2 }' | sed 's/^[ \t]*//g' | sed 's/\"//g' | sed 's/,//g'`

    Network_Interface5=`curl -sk -H "Authorization: Basic ${iLO_Base64}" -H 'Accept: application/json' -X GET https://${iLO_Address}/rest/v1/Systems/1/EthernetInterfaces/5 --insecure -L | python -mjson.tool | grep Health | awk -F":" '{ print $2 }' | sed 's/^[ \t]*//g' | sed 's/\"//g' | sed 's/,//g'`

    Network_Interface6=`curl -sk -H "Authorization: Basic ${iLO_Base64}" -H 'Accept: application/json' -X GET https://${iLO_Address}/rest/v1/Systems/1/EthernetInterfaces/6 --insecure -L | python -mjson.tool | grep Health | awk -F":" '{ print $2 }' | sed 's/^[ \t]*//g' | sed 's/\"//g' | sed 's/,//g'`

    Power_Supply_Redundancy_Status=`cat ${iLO_Summary_Status_File} | grep PowerSupplyRedundancy | awk -F":" '{ print $2 }' | sed 's/^[ \t]*//g' | sed 's/\"//g' | sed 's/,//g'`

    Power_Supplies_Status=`cat ${iLO_Summary_Status_File} | awk -e '/\"PowerSupplies\"/ {a=NR} a && NR==a+3' | awk -F":" '{ print $2 }' | sed 's/^[ \t]*//g' | sed 's/\"//g' | sed 's/,//g'`

    Processor_Status=`cat ${iLO_Summary_Status_File} | awk -e '/ProcessorSummary/ {a=NR} a && NR==a+4' | awk -F":" '{ print $2 }' | sed 's/^[ \t]*//g' | sed 's/\"//g' | sed 's/,//g'`

    Storage_Status=`cat ${iLO_Summary_Status_File} | awk -e '/\"Storage\"/ {a=NR} a && NR==a+2' | head -n 1 | awk -F":" '{ print $2 }' | sed 's/^[ \t]*//g' | sed 's/\"//g' | sed 's/,//g'`

    Temperature_Status=`cat ${iLO_Summary_Status_File} | awk -e '/Temperatures/ {a=NR} a && NR==a+2' | awk -F":" '{ print $2 }' | sed 's/^[ \t]*//g' | sed 's/\"//g' | sed 's/,//g'`

    echo "### iLO Status ###"
    echo "     Processor Status               : ${Processor_Status}"
    echo "     Memory Status                  : ${Memory_Status}"
    echo "     Storage Status                 : ${Storage_Status}"
    echo "     Power Supplies Status          : ${Power_Supplies_Status}"
    echo "     Power Supply Redundancy Status : ${Power_Supply_Redundancy_Status}"
    echo "     Network Interface1 Status      : ${Network_Interface1}"
    echo "     Network_Interface2 Status      : ${Network_Interface2}"
    echo "     Network_Interface5 Status      : ${Network_Interface6}"
    echo "     Network_Interface6 Status      : ${Network_Interface6}"
    echo "     Fans Status                    : ${Fans_Status}"
    echo "     Fan Redundancy Status          : ${Fan_Redundancy_Status}"
    echo "     BIOS HW Status                 : ${BIOS_HW_Status}"
    echo "     Temperature Status             : ${Temperature_Status}"
    echo ""

fi

if [ -f ${iLO_Summary_Status_File} ]; then
    rm -f ${iLO_Summary_Status_File} >/dev/null 2>&1
fi
return 0
}

############################################ For Dev ############################################
##########################
### BIGIP DEV Status   ###
##########################
function BIGIP_DEV_Status () {

export PASSWORD=$DEV_SSH_PASS
export SSH_ASKPASS=$0
export DISPLAY=dummy:0

echo "### BIG-IP DEV Status ###"

# SSL証明書 更新日チェック
echo "  # Certificates Status #"

curl -sk -H "Authorization: Basic ${BIGIP_DEV_Base64}" -H "Content-Type: application/json" -X GET https://${BIG_DEV_VIP}/mgmt/tm/sys/crypto/cert/~Common~isso_CA.cer.crt | python -mjson.tool | grep -e name -e expiration -e publicKeyType -e country -e commonName  -e organization | sed 's/^[ \t]*//g' | while true
do
    read line1 #expiration
    read line2 #publicKeyType
    read line3 #commonName
    read line4 #country
    read line5 #name
    read line6 #organization
    if [ -z "$line1" ]; then break ; fi
    expiration=`echo $line1 | awk -F"\":" '{ print $2 }' | sed 's/^[ \t]*//g' | sed 's/\"//g' | sed 's/,//g'`
    expiration_JST=`date -d "${expiration}" +"%Y/%m/%d %H:%M:%S %Z"`
    echo "     expiration    : ${expiration_JST}"
    publicKeyType=`echo $line2 | awk -F":" '{ print $2 }' | sed 's/^[ \t]*//g' | sed 's/\"//g'`
    echo "     publicKeyType : ${publicKeyType}"
    commonName=`echo $line3 | awk -F":" '{ print $2 }' | sed 's/^[ \t]*//g' | sed 's/\"//g' | sed 's/,//g'`
    echo "     commonName    : ${commonName}"
    country=`echo $line4 | awk -F":" '{ print $2 }' | sed 's/^[ \t]*//g' | sed 's/\"//g' | sed 's/,//g'`
    echo "     country       : ${country}"
    name=`echo $line5 | awk -F":" '{ print $2 }' | sed 's/^[ \t]*//g' | sed 's/\"//g' | sed 's/,//g'`
    echo "     name          : ${name}"
    organization=`echo $line6 | awk -F":" '{ print $2 }' | sed 's/^[ \t]*//g' | sed 's/\"//g' | sed 's/,//g'`
    echo "     organization  : ${organization}"
    echo ""

done

curl -sk -H "Authorization: Basic ${BIGIP_DEV_Base64}" -H "Content-Type: application/json" -X GET https://${BIG_DEV_VIP}/mgmt/tm/sys/crypto/cert/~Common~isso_cert_dev.crt | python -mjson.tool | grep -e name -e expiration -e publicKeyType -e country -e commonName  -e organization | sed 's/^[ \t]*//g' | while true
do
    read line1 #expiration
    read line2 #publicKeyType
    read line3 #commonName
    read line4 #country
    read line5 #name
    read line6 #organization
    if [ -z "$line1" ]; then break ; fi
    expiration=`echo $line1 | awk -F"\":" '{ print $2 }' | sed 's/^[ \t]*//g' | sed 's/\"//g' | sed 's/,//g'`
    expiration_JST=`date -d "${expiration}" +"%Y/%m/%d %H:%M:%S %Z"`
    echo "     expiration    : ${expiration_JST}"
    publicKeyType=`echo $line2 | awk -F":" '{ print $2 }' | sed 's/^[ \t]*//g' | sed 's/\"//g'`
    echo "     publicKeyType : ${publicKeyType}"
    commonName=`echo $line3 | awk -F":" '{ print $2 }' | sed 's/^[ \t]*//g' | sed 's/\"//g' | sed 's/,//g'`
    echo "     commonName    : ${commonName}"
    country=`echo $line4 | awk -F":" '{ print $2 }' | sed 's/^[ \t]*//g' | sed 's/\"//g' | sed 's/,//g'`
    echo "     country       : ${country}"
    name=`echo $line5 | awk -F":" '{ print $2 }' | sed 's/^[ \t]*//g' | sed 's/\"//g' | sed 's/,//g'`
    echo "     name          : ${name}"
    organization=`echo $line6 | awk -F":" '{ print $2 }' | sed 's/^[ \t]*//g' | sed 's/\"//g' | sed 's/,//g'`
    echo "     organization  : ${organization}"
    echo ""

done


echo "  # CPU Usage #"
curl -sk -H "Authorization: Basic ${BIGIP_DEV_Base64}" -H "Content-Type: application/json" -X GET https://${BIG_DEV_VIP}/mgmt/tm/sys/cpu | python -mjson.tool | awk -e '/cpuId/ {a=NR} a && NR==a+1' -e '/fiveMinAvgIdle/ {b=NR} b && NR==b+1' -e '/fiveMinAvgIdle/ {c=NR} c && NR==c+1' -e '/fiveMinAvgUser/ {d=NR} d && NR==d+1' -e '/fiveSecAvgIdle/ {e=NR} e && NR==e+1' -e '/fiveSecAvgSystem/ {f=NR} f && NR==f+1' -e '/fiveSecAvgUser/ {g=NR} g && NR==g+1' | while true
do
    read line1 #cpuId
    read line2 #fiveMinAvgIdle
    read line3 #fiveMinAvgSystem
    read line4 #fiveMinAvgUser
    read line5 #fiveSecAvgIdle
    read line6 #fiveSecAvgSystem
    read line7 #fiveSecAvgUser
    if [ -z "$line1" ] ; then break ; fi
    cpuId=`echo $line1 | awk -F":" '{print $2 }'| sed 's/^[ \t]*//g'`
    fiveMinAvgIdle=`echo $line2 | awk -F":" '{print $2 }'| sed 's/^[ \t]*//g'`
    fiveMinAvgSystem=`echo $line3 | awk -F":" '{print $2 }'| sed 's/^[ \t]*//g'`
    fiveMinAvgUser=`echo $line4 | awk -F":" '{print $2 }'| sed 's/^[ \t]*//g'`
    fiveSecAvgIdle=`echo $line5 | awk -F":" '{print $2 }'| sed 's/^[ \t]*//g'`
    fiveSecAvgSystem=`echo $line6 | awk -F":" '{print $2 }'| sed 's/^[ \t]*//g'`
    fiveSecAvgUser=`echo $line7 | awk -F":" '{print $2 }'| sed 's/^[ \t]*//g'`

    echo "     cpuId            : ${cpuId}"
    echo "     fiveMinAvgIdle   : ${fiveMinAvgIdle}"
    echo "     fiveMinAvgSystem : ${fiveMinAvgSystem}"
    echo "     fiveMinAvgUser   : ${fiveMinAvgUser}"
    echo "     fiveSecAvgIdle   : ${fiveSecAvgIdle}"
    echo "     fiveSecAvgSystem : ${fiveSecAvgSystem}"
    echo "     fiveSecAvgUser   : ${fiveSecAvgUser}"
    echo ""
done

echo "  # Memory Usage #"
curl -sk -H "Authorization: Basic ${BIGIP_DEV_Base64}" -H "Content-Type: application/json" -X GET https://${BIG_DEV_VIP}/mgmt/tm/sys/memory | python -mjson.tool | awk -e '/memoryFree/ {a=NR} a && NR==a+1' -e '/memoryTotal/ {b=NR} b && NR==b+1' -e '/memoryUsed/ {c=NR} c && NR==c+1' -e '/otherMemoryFree/ {d=NR} d && NR==d+1' -e '/otherMemoryTotal/ {e=NR} e && NR==e+1' -e '/otherMemoryUsed/ {f=NR} f && NR==f+1' -e '/swapFree/ {g=NR} g && NR==g+1' -e '/swapTotal/ {h=NR} h && NR==h+1' -e '/swapUsed/ {i=NR} i && NR==i+1' -e '/tmmMemoryFree/ {j=NR} j && NR==j+1' -e '/tmmMemoryTotal/ {k=NR} k && NR==k+1' -e '/tmmMemoryUsed/ {l=NR} l && NR==l+1' | while true
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
    memoryFree=`echo $line1 | awk -F":" '{print $2 }'| sed 's/^[ \t]*//g'`
    memoryTotal=`echo $line2 | awk -F":" '{print $2 }'| sed 's/^[ \t]*//g'`
    memoryUsed=`echo $line3 | awk -F":" '{print $2 }'| sed 's/^[ \t]*//g'`
    otherMemoryFree=`echo $line4 | awk -F":" '{print $2 }'| sed 's/^[ \t]*//g'`
    otherMemoryTotal=`echo $line5 | awk -F":" '{print $2 }'| sed 's/^[ \t]*//g'`
    otherMemoryUsed=`echo $line6 | awk -F":" '{print $2 }'| sed 's/^[ \t]*//g'`
    swapFree=`echo $line7 | awk -F":" '{print $2 }'| sed 's/^[ \t]*//g'`
    swapTotal=`echo $line8 | awk -F":" '{print $2 }'| sed 's/^[ \t]*//g'`
    swapUsed=`echo $line9 | awk -F":" '{print $2 }'| sed 's/^[ \t]*//g'`
    tmmMemoryFree=`echo $line10 | awk -F":" '{print $2 }'| sed 's/^[ \t]*//g'`
    tmmMemoryTotal=`echo $line11 | awk -F":" '{print $2 }'| sed 's/^[ \t]*//g'`
    tmmMemoryUsed=`echo $line12 | awk -F":" '{print $2 }'| sed 's/^[ \t]*//g'`

    echo "     memoryFree                : $(expr ${memoryFree} / 1024 / 1024 / 1024)GB"
    echo "     memoryTotal               : $(expr ${memoryTotal} / 1024 / 1024 / 1024)GB"
    echo "     memoryUsed                : $(expr ${memoryUsed} / 1024 / 1024 / 1024)GB"
    echo "     memory_Percent_Used       : $(expr 100 \* ${memoryUsed} / ${memoryTotal})"\%""
    echo "     otherMemoryFree           : $(expr ${otherMemoryFree} / 1024 / 1024 / 1024)GB"
    echo "     otherMemoryTotal          : $(expr ${otherMemoryTotal} / 1024 / 1024 / 1024)GB"
    echo "     otherMemoryUsed           : $(expr ${otherMemoryUsed} / 1024 / 1024 / 1024)GB"
    echo "     otherMemory_Percent_Used  : $(expr 100 \* ${otherMemoryUsed} / ${otherMemoryTotal})"\%""
    echo "     swapFree                  : $(expr ${swapFree} / 1024 / 1024 / 1024)GB"
    echo "     swapTotal                 : $(expr ${swapTotal} / 1024 / 1024 / 1024)GB"
    echo "     swapUsed                  : $(expr ${swapUsed} / 1024 / 1024 / 1024)GB"
    echo "     swap_Percent_Used         : $(expr 100 \* ${swapUsed} / ${swapTotal})"\%""
    echo "     tmmMemoryFree             : $(expr ${tmmMemoryFree} / 1024 / 1024 / 1024)GB"
    echo "     tmmMemoryTotal            : $(expr ${tmmMemoryTotal} / 1024 / 1024 / 1024)GB"
    echo "     tmmMemoryUsed             : $(expr ${tmmMemoryUsed} / 1024 / 1024 / 1024)GB"
    echo "     tmmMemory_Percent_Used    : $(expr 100 \* ${tmmMemoryUsed} / ${tmmMemoryTotal})"\%""
    echo ""
done

echo "  # Interface Status #"
curl -sk -H "Authorization: Basic ${BIGIP_DEV_Base64}" -H "Content-Type: application/json" -X GET https://${BIG_DEV_VIP}/mgmt/tm/net/interface/stats | python -mjson.tool | awk -e '/mediaActive/ {a=NR} a && NR==a+1' -e '/status/ {b=NR} b && NR==b+1' -e '/tmName/ {c=NR} c && NR==c+1' | while true
do
    read line1 #mediaActive
    read line2 #status
    read line3 #tmName
    if [ -z "$line1" ] ; then break ; fi
mediaActive=`echo $line1 | awk -F":" '{print $2 }'| sed 's/^[ \t]*//g' | sed 's/\"//g'`
status=`echo $line2 | awk -F":" '{print $2 }'| sed 's/^[ \t]*//g' | sed 's/\"//g'`
tmName=`echo $line3 | awk -F":" '{print $2 }'| sed 's/^[ \t]*//g' | sed 's/\"//g'`
echo "     tmName      : ${tmName}"
echo "     mediaActive : ${mediaActive}"
echo "     status      : ${status}"
echo ""

done

if [ -f ${BIGIP_Status_File} ]; then
    rm -f ${BIGIP_Status_File} >/dev/null 2>&1
fi

return 0
}

##########################
### IceWall Server DEV ###
##########################
function IceWall_Server_DEV_Status () {

export PASSWORD=$DEV_SSH_PASS
export SSH_ASKPASS=$0
export DISPLAY=dummy:0

host=iwdev

    echo "### ${host} Status ###"
    echo "  # Network Interface #"
    Network_Interface_DeviceName=`exec setsid ssh -o "StrictHostKeyChecking=no" ${DEV_SSH_USER}@${host} "nmcli device show | grep GENERAL.デバイス | grep -v lo" 2>/dev/null`
    Extraction=`echo ${Network_Interface_DeviceName} | sed 's/GENERAL.デバイス://g'`

    for LINE in ${Extraction[@]}
    do
        Network_Interface_status=`exec setsid ssh -o "StrictHostKeyChecking=no" ${DEV_SSH_USER}@${host} "/usr/sbin/ethtool $LINE 2>/dev/null | grep -e Settings -e 'Link detected' -e Speed -e Duplex" 2>/dev/null`
        echo "     ${Network_Interface_status}"
    done
    echo ""

    # httpd Process
    httpd_Proc_Count=`exec setsid ssh -o "StrictHostKeyChecking=no" ${DEV_SSH_USER}@${host} "ps -ef | grep httpd | grep -v grep | grep -v root | wc -l" 2>/dev/null`
    echo "  # Proccess Status #"
    echo "     httpd Proccess Count : ${httpd_Proc_Count}"
    echo ""

return 0
}
#######################
### Cert Server DEV ###
#######################
function Cert_Server_DEV_Status () {

export PASSWORD=$DEV_SSH_PASS
export SSH_ASKPASS=$0
export DISPLAY=dummy:0

host=certdev

    echo "### ${host} Status ###"
    echo "  # Network Interface #"
    Network_Interface_DeviceName=`exec setsid ssh -o "StrictHostKeyChecking=no" ${DEV_SSH_USER}@${host} "nmcli device show | grep GENERAL.デバイス | grep -v lo" 2>/dev/null`
    Extraction=`echo ${Network_Interface_DeviceName} | sed 's/GENERAL.デバイス://g'`

    for LINE in ${Extraction[@]}
    do
        Network_Interface_status=`exec setsid ssh -o "StrictHostKeyChecking=no" ${DEV_SSH_USER}@${host} "/usr/sbin/ethtool $LINE 2>/dev/null | grep -e Settings -e 'Link detected' -e Speed -e Duplex" 2>/dev/null`
        echo "     ${Network_Interface_status}"
    done
    echo ""
    # httpd Process
    httpd_Proc_Count=`exec setsid ssh -o "StrictHostKeyChecking=no" ${DEV_SSH_USER}@${host} "ps -ef | grep httpd | grep -v grep | grep -v root | wc -l" 2>/dev/null`
    echo "  # Proccess Status #"
    echo "     httpd Proccess Count : ${httpd_Proc_Count}"

    #Process tomcat
    Tomcat_PWD_Proc=`exec setsid ssh -o "StrictHostKeyChecking=no" ${DEV_SSH_USER}@${host} "ps -ef | grep java | grep tomcat_dmp_pwd | grep -v grep | wc -l" 2>/dev/null`
    Tomcat_DGO_Proc=`exec setsid ssh -o "StrictHostKeyChecking=no" ${DEV_SSH_USER}@${host} "ps -ef | grep java | grep tomcat_dmp_dgo | grep -v grep | wc -l" 2>/dev/null`

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
    Certd_PWD_Proc=`exec setsid ssh -o "StrictHostKeyChecking=no" ${DEV_SSH_USER}@${host} "ps -ef | grep certd | grep "\/config\/" | grep -v grep | wc -l" 2>/dev/null`
    Certd_DGO_Proc=`exec setsid ssh -o "StrictHostKeyChecking=no" ${DEV_SSH_USER}@${host} "ps -ef | grep certd | grep "\/config_dgo\/" | grep -v grep | wc -l" 2>/dev/null`

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

return 0
}
#######################
### LDAP Server DEV ###
#######################
function LDAP_Server_DEV_Status () {

export PASSWORD=$DEV_SSH_PASS
export SSH_ASKPASS=$0
export DISPLAY=dummy:0

host=ldapdev

    echo "### ${host} Status ###"
    echo "  # Network Interface #"
    Network_Interface_DeviceName=`exec setsid ssh -o "StrictHostKeyChecking=no" ${DEV_SSH_USER}@${host} "nmcli device show | grep GENERAL.デバイス | grep -v lo"  2>/dev/null`
    Extraction=`echo ${Network_Interface_DeviceName} | sed 's/GENERAL.デバイス://g'`

    for LINE in ${Extraction[@]}
    do
        Network_Interface_status=`exec setsid ssh -o "StrictHostKeyChecking=no" ${DEV_SSH_USER}@${host} "/usr/sbin/ethtool $LINE 2>/dev/null | grep -e Settings -e 'Link detected' -e Speed -e Duplex"  2>/dev/null`
        echo "     ${Network_Interface_status}"
    done
    echo ""

    # LDAP Process
    echo "  # Proccess Status #"
    LDAP_Proc=`exec setsid ssh -o "StrictHostKeyChecking=no" ${DEV_SSH_USER}@${host} "ps -ef | grep slapd | grep -v grep | wc -l"  2>/dev/null`
    if [ ${LDAP_Proc} -eq 1 ]; then
        echo "     OpenLDAP Proccess is alive."
    else
        echo "     OpenLDAP Proccess is dead."
    fi
    echo ""
return 0
}
######################
### LDAP REP Server###
######################
function LDAPREP_Server_DEV_Status () {

export PASSWORD=$DEV_SSH_PASS
export SSH_ASKPASS=$0
export DISPLAY=dummy:0

host=ldaprepdev

    echo "### ${host} Status ###"
    echo "  # Network Interface #"
    Network_Interface_DeviceName=`exec setsid ssh -o "StrictHostKeyChecking=no" ${DEV_SSH_USER}@${host} "nmcli device show | grep GENERAL.デバイス | grep -v lo"  2>/dev/null`
    Extraction=`echo ${Network_Interface_DeviceName} | sed 's/GENERAL.デバイス://g'`

    for LINE in ${Extraction[@]}
    do
        Network_Interface_status=`exec setsid ssh -o "StrictHostKeyChecking=no" ${DEV_SSH_USER}@${host} "/usr/sbin/ethtool $LINE 2>/dev/null | grep -e Settings -e 'Link detected' -e Speed -e Duplex"  2>/dev/null`
        echo "     ${Network_Interface_status}"
    done
    echo ""

    # LDAP Process
    echo "  # Proccess Status #"
    LDAP_Proc=`exec setsid ssh -o "StrictHostKeyChecking=no" ${DEV_SSH_USER}@${host} "ps -ef | grep slapd | grep -v grep | wc -l"  2>/dev/null`
    if [ ${LDAP_Proc} -eq 1 ]; then
        echo "     OpenLDAP Proccess is alive."
    else
        echo "     OpenLDAP Proccess is dead."
    fi

    Postfix_Proc=`exec setsid ssh -o "StrictHostKeyChecking=no" ${DEV_SSH_USER}@${host} "ps -ef | grep postfix | grep master | grep -v grep | wc -l"  2>/dev/null`
    if [ ${Postfix_Proc} -eq 1 ]; then
        echo "     Postfix Proccess is alive."
    else
        echo "     Postfix Proccess is dead."
    fi

    echo ""
return 0
}

###############################
### ISSO-SW24 DEV(Cisco3850)###
###############################
function SW24_DEV_Status () {

export PASSWORD=$SW24_DEV_SSH_PASS
export SSH_ASKPASS=$0
export DISPLAY=dummy:0

echo "### SWDEV Status ###"
echo "  # SW24 I/F Summary Status #"

exec setsid ssh -o "StrictHostKeyChecking=no" ${SW24_DEV_SSH_USER}@${SW24_DEV_IP} "show interfaces status"  2>/dev/null | grep -v disabled | grep -v test | sed '1,4d' > ${SW24_Interface_Log} 

sed -i -e '1,2d' ${SW24_Interface_Log}
sed -i -e 's/^/      /g' ${SW24_Interface_Log}
cat ${SW24_Interface_Log}
echo ""

echo "  # SW24 I/F Individual Status #"

for line in `cat ${SW24_Interface_Log} | awk '{ print $1 }'`
do
    Interface_Name=$line
    if [ "$Interface_Name" != "Port" ]; then
        exec setsid ssh -n -o "StrictHostKeyChecking=no" ${SW24_DEV_SSH_USER}@${SW24_DEV_IP} "show interfaces ${Interface_Name}" 2>/dev/null | grep -e "line protocol" -e "input errors" -e "output errors" -e "unknown protocol drops" -e "babbles" -e "lost carrier" -e "output buffer failures" | while true
        do
            read line1
            read line2
            read line3
            read line4
            read line5
            read line6
            read line7
            if [ -z "$line1" ]; then break ; fi
            echo "     `echo $line1 | sed 's/^ *//g'`"
            echo "      `echo $line2 | sed 's/^ *//g'`"
            echo "      `echo $line3 | sed 's/^ *//g'`"
            echo "      `echo $line4 | sed 's/^ *//g'`"
            echo "      `echo $line5 | sed 's/^ *//g'`"
            echo "      `echo $line6 | sed 's/^ *//g'`"
            echo "      `echo $line7 | sed 's/^ *//g'`"
            echo ""
        done
    fi

done

echo "  # SW24 CPU Usage #"

exec setsid ssh -o "StrictHostKeyChecking=no" ${SW24_DEV_SSH_USER}@${SW24_DEV_IP} "show processes cpu sort | exclude 0.0" 2>/dev/null | grep "CPU utilization" | awk -F":" '{ print $2 $3 $4 }' | awk '{ print $1,$4,$7 }' | while true
do
    read line1
    if [ -z "$line1" ]; then break ; fi
    echo "    Five Seconds : `echo $line1 | awk '{ print $1 }' | sed 's/\;//g'`"
    echo "    One Minute   : `echo $line1 | awk '{ print $2 }' | sed 's/\;//g'`"
    echo "    Five Minutes : `echo $line1 | awk '{ print $3 }'`"
    echo ""
done


echo "  # SW24 Memory Usage #"

exec setsid ssh -o "StrictHostKeyChecking=no" ${SW24_DEV_SSH_USER}@${SW24_DEV_IP} "show processes memory" 2>/dev/null | grep Processor | awk '{ print $4,$6,$8 }' | while true
do
    read line1
    if [ -z "$line1" ]; then break ; fi
    Memory_Total=`echo $line1 | awk '{ print $1 }'`
    Memory_Total_MB="$(expr ${Memory_Total} / 1024 / 1024 / 8)"
    Memory_Used=`echo $line1 | awk '{ print $2 }'`
    Memory_Used_MB="$(expr ${Memory_Used} / 1024 / 1024 / 8)"
    Memory_Free=`echo $line1 | awk '{ print $3 }' | sed 's/\r//g'`
    Memory_Free_MB="$(expr ${Memory_Free} / 1024 / 1024 / 8)"
    Memory_Utilization="$(expr 100 \* ${Memory_Used} / ${Memory_Total})"\%""
    echo "     Memory Total       : ${Memory_Total_MB}"MB""
    echo "     Memory Used        : ${Memory_Used_MB}"MB""
    echo "     Memory Free        : ${Memory_Free_MB}"MB""
    echo "     Memory Utilization : ${Memory_Utilization}"
    echo ""
done

if [ -f ${SW24_Interface_Log} ]; then
    rm -f ${SW24_Interface_Log} >/dev/null 2>&1
fi
    return 0
}
######################
### Usage          ###
######################
function usage () {
    echo " Usage: $(basename ${0}) [<options>]"
    echo " The specified argument is $#."
    echo " The required argument is one."
    echo " options:iw,cert,ldap,rep,bigip,zabbix,prism,esxi,sw24,idrac,ilo,all,iwdev,certdev,ldapdev,repdev,bigipdev,swdev,devall"
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
   sw24)
    SW24_Status
    ;;
   idrac)
    iDrac_Status
    ;;
   ilo)
    iLO_Status
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
    SW24_Status
    iDrac_Status
    iLO_Status
    ;;
  iwdev)
    IceWall_Server_DEV_Status
    ;;
  certdev)
    Cert_Server_DEV_Status
    ;;
  ldapdev)
    LDAP_Server_DEV_Status
    ;;
  repdev)
    LDAPREP_Server_DEV_Status
    ;;
  swdev)
    SW24_DEV_Status
    ;;
  bigipdev)
    BIGIP_DEV_Status
    ;;
   devall)
    BIGIP_DEV_Status
    IceWall_Server_DEV_Status
    Cert_Server_DEV_Status
    LDAP_Server_DEV_Status
    LDAPREP_Server_DEV_Status
    SW24_DEV_Status
    ;;
  *)
    echo "[ERROR] Invalid option '${1}'"
    usage
    exit 1
    ;;
esac

exit 0


