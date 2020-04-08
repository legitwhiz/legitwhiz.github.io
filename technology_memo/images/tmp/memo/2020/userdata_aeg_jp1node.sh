#!/bin/bash

## install packages
yum install -y openldap sssd-common sssd sssd-client sssd-ldap oddjob-mkhomedir expect aws-cli gcc rsync mailx dstat
yum erase -y nscd

## tune ldap.conf
cp /etc/openldap/ldap.conf /etc/openldap/ldap.conf.default

cat <<EOF > /etc/openldap/ldap.conf
#
# LDAP Defaults
#
# See ldap.conf(5) for details
# This file should be world readable but not world writable.
#BASE   dc=example,dc=com
#URI    ldap://ldap.example.com ldap://ldap-master.example.com:666
#SIZELIMIT      12
#TIMELIMIT      15
#DEREF          never
TLS_CACERTDIR /etc/openldap/cacerts
URI ldap://${ldap_server}/
BASE dc=aws,dc=fastretailing,dc=com
EOF

## tune sssd.conf
if [ -e /etc/sssd/sssd.conf ]; then
  cp /etc/sssd/sssd.conf /etc/sssd/sssd.conf.default
fi
cat <<EOF > /etc/sssd/sssd.conf
[sssd]
debug_level         = 0
config_file_version = 2
services            = nss, pam, ssh, sudo
domains             = default
[domain/default]
id_provider     = ldap
auth_provider   = ldap
chpass_provider = ldap
sudo_provider   = ldap
access_provider = simple
ldap_uri              = ldap://${ldap_server}/
ldap_search_base      = dc=aws,dc=fastretailing,dc=com
ldap_id_use_start_tls = False
ldap_search_timeout              = 3
ldap_network_timeout             = 3
ldap_opt_timeout                 = 3
ldap_enumeration_search_timeout  = 60
ldap_enumeration_refresh_timeout = 300
ldap_connection_expire_timeout   = 600
ldap_sudo_smart_refresh_interval = 600
ldap_sudo_full_refresh_interval  = 10800
entry_cache_timeout = 1200
cache_credentials   = True
simple_allow_groups = ${login_allowed_groups}
[nss]
homedir_substring = /home
entry_negative_timeout        = 20
entry_cache_nowait_percentage = 50
[pam]
offline_credentials_expiration = 2
offline_failed_login_attempts = 3
offline_failed_login_delay = 5
[sudo]
[autofs]
[ssh]
[pac]
[ifp]
EOF

cp /etc/sssd/sssd.conf /etc/sssd/sssd.conf.cloud-init
chmod 600 /etc/sssd/sssd.conf
chown root:root /etc/sssd/sssd.conf
systemctl enable sssd
systemctl start sssd

authconfig \
  --enablesssd --enablesssdauth --enablelocauthorize \
  --disableldap --disableldapauth --disableldaptls \
  --update

authconfig \
  --enablemkhomedir \
  --update

cp /etc/sssd/sssd.conf.cloud-init /etc/sssd/sssd.conf
chmod 600 /etc/sssd/sssd.conf
chown root:root /etc/sssd/sssd.conf

systemctl stop sssd
systemctl restart messagebus
systemctl restart systemd-logind
systemctl start sssd
systemctl restart oddjobd

## tune sshd_config
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.default
egrep -v "" /etc/ssh/sshd_config.default | \
sed 's/#PermitRootLogin yes/PermitRootLogin no/g' | \
sed 's/PubkeyAuthentication yes/#PubkeyAuthentication yes/g' | \
sed 's|#AuthorizedKeysCommand none|AuthorizedKeysCommand /usr/bin/sss_ssh_authorizedkeys|g' | sed 's|#AuthorizedKeysCommandUser nobody|AuthorizedKeysCommandUser nobody|'g | \
sed 's/PasswordAuthentication yes/PasswordAuthentication no/g' | \
sed 's/#GSSAPIAuthentication no/GSSAPIAuthentication yes/g' | sed 's/#GSSAPICleanupCredentials yes/GSSAPICleanupCredentials no/g' | \
sed -e 's/AuthorizedKeysCommand .*/AuthorizedKeysCommand \/usr\/bin\/sss_ssh_authorizedkeys/g' | \
sed -e 's/AuthorizedKeysCommandUser .*/AuthorizedKeysCommandUser nobody/g' > /etc/ssh/sshd_config

systemctl restart sshd

##############################################
## tune sudoers
##############################################
cat << EOF > /etc/sudoers.d/${admin_user}
${admin_user} ALL=(ALL) NOPASSWD:ALL
EOF

cat << EOF > /etc/sudoers.d/ldap
%Infra-admin ALL=(ALL) NOPASSWD:ALL
%analytics-engines-common-jenkins-admin ALL=(ALL) NOPASSWD:ALL
EOF

chmod 440 /etc/sudoers.d/${admin_user} /etc/sudoers.d/ldap

groupadd -g 502 jobuser
useradd -g jobuser -u 502 -s /bin/bash jobuser
mkdir -p /home/jobuser/.ssh

## Add ssh auth
cat << EOF >> /home/jobuser/.ssh/authorized_keys
${jenkins-key}
${central-jp1node-key}
${jobuser-key-1}
${jobuser-key-2}
${jobuser02-key-1}
${jobuser02-key-2}
EOF

chown -R jobuser:jobuser /home/jobuser
chmod 700 /home/jobuser/.ssh
chmod 600 /home/jobuser/.ssh/authorized_keys

##############################################
# Setup Jobkicker
##############################################
mkdir -p /aeg
chown jobuser:jobuser /aeg

yum -y install python3 python3-virtualenv python3-pip jq
python3 -m pip install boto3 psycopg2-binary fluent-logger

aws s3 cp s3://${s3_bucket}/common/aeg/${subsystem_id}/jobkicker/deploy.sh /aeg/deploy.sh
su - jobuser -c ""

##############################################
# PIP AWS CLI Version up
##############################################
python3 -m pip install --upgrade pip
python3 -m pip install --upgrade awscli

## monitoring/operation steps

##############################################
# install ossec
##############################################
groupadd ossec
groupadd ossecagt
useradd -g ossec -s /sbin/nologin -d /var/ossec -k /etc/skel -m ossec
useradd -g ossec -s /sbin/nologin -d /var/ossec -M ossecm
useradd -g ossec -s /sbin/nologin -d /var/ossec -M ossecr
useradd -g ossecagt ossecagt

mkdir -p /home/ossecagt/.ssh/
cat << EOF >> /home/ossecagt/.ssh/authorized_keys
${ossecagt_pub_key}
EOF
chmod 600 /home/ossecagt/.ssh/authorized_keys
chown -R ossecagt:ossecagt /home/ossecagt

cat << EOF > /etc/sudoers.d/ossecagt
ossecagt    ALL=(ALL)    NOPASSWD: /var/ossec/bin/manage_agents,/var/ossec/bin/ossec-control
EOF

#cd /var && aws s3 cp s3://${s3_bucket_infra}/infra/install/ossec-bin/${envstage}/ossec-v2.9.0.tar.gz . && tar zxvf ossec-v2.9.0.tar.gz
mkdir -p /var/tmp/install/ossec && cd /var/tmp/install/ossec
aws s3 cp s3://${s3_bucket_infra}/infra/install/ossec-src/ossec-hids-2.9.0.tar.gz - | tar -zxvf -
cd ossec-hids-2.9.0
./install.sh << EOF
en
agent
${ossec_server_host}
y
y
n
EOF
cd /var/ossec
aws s3 cp s3://${s3_bucket_infra}/infra/install/ossec-config/etc/ etc/ --recursive
sed -i 's/OSSEC_SERVER_HOSTNAME/${ossec_server_host}/g' etc/ossec.conf
aws s3 cp s3://${s3_bucket_infra}/infra/install/ossec-script/env/${ossec_client_key} /var/ossec/etc/client.keys

chown -R ossec:ossec /var/ossec

cat << EOF > /etc/systemd/system/ossec-agent.service
[Unit]
Description = ossec agent
[Service]
ExecStart = /var/ossec/bin/ossec-control start
ExecStop  = /var/ossec/bin/ossec-control stop
Restart = always
Type = forking
[Install]
WantedBy = multi-user.target
EOF

systemctl enable ossec-agent
systemctl start ossec-agent

mkdir -p /opt/ossec
aws s3 cp s3://${s3_bucket_infra}/infra/install/ossec-script/ /opt/ossec/ --recursive
ln -s /opt/ossec /opt/script
chmod 600 /opt/ossec/env/*.pem
export ENVSTAGE=${envstage}
chmod 755 /opt/ossec/bin/*.sh

touch /var/ossec/etc/shared/agent.conf
chown :ossec /var/ossec/etc/shared/agent.conf

/opt/ossec/bin/ossec_import_key.sh

##############################################
# install prometheus
##############################################
#create prometheus group
groupadd prometheus
useradd -d /etc/prometheus -g prometheus -m prometheus

#make directory for node_exporter and process_exporter
mkdir -p /etc/prometheus/node_exporter/run /etc/prometheus/node_exporter/log
mkdir -p /etc/prometheus/process_exporter/run /etc/prometheus/process_exporter/log

#download node_exporter and unzip gz file
cd /etc/prometheus/node_exporter
curl -OL https://github.com/prometheus/node_exporter/releases/download/v0.15.2/node_exporter-0.15.2.linux-amd64.tar.gz
tar zxvf node_exporter-0.15.2.linux-amd64.tar.gz
rm -rf node_exporter-0.15.2.linux-amd64.tar.gz

#add sudoers permission to prometheus user
cat << EOF > /etc/sudoers.d/prometheus
prometheus      ALL=(ALL)       NOPASSWD: /etc/prometheus/process_exporter/process-exporter-0.1.0.linux-amd64/process-exporter -config.path config.yml, /etc/init.d/process_exporter, /etc/prometheus/node_exporter/node_exporter-0.15.2.linux-amd64/node_exporter, /etc/init.d/node_exporter
EOF
chown -R prometheus:prometheus /etc/prometheus

##register node_exporter and process_exporter as service
#aws s3 cp ${s3_blue_resource}/Installer/Prometheus/node_exporter/node_exporter.sh ./

#cp -f ./node_exporter.sh /etc/init.d/node_exporter
#chown root:prometheus /etc/init.d/node_exporter
#chmod 775 /etc/init.d/node_exporter

cat << EOF > /etc/systemd/system/node-exporter.service
[Unit]
Description = node exporter
[Service]
User = prometheus
Environment = stdout_log=/etc/prometheus/node_exporter/log/node_exporter.log
Environment = stderr_log=/etc/prometheus/node_exporter/log/node_exporter.err
ExecStart = /usr/bin/bash -c ""
ExecStop  = /usr/bin/kill \$MAINPID
Restart   = always
Type      = simple
[Install]
WantedBy = multi-user.target
EOF

systemctl enable node-exporter
systemctl start node-exporter

##############################################
#For system log aggregation on amazonlinux2
##############################################
mkdir -p /var/tmp/td-agent
aws s3 cp s3://${s3_bucket_infra}/infra/install/td-agent/amazonlinux2/td-agent-3.3.0-0.amazon2.x86_64.rpm /var/tmp/td-agent/
rpm -ivh /var/tmp/td-agent/td-agent-3.3.0-0.amazon2.x86_64.rpm

td-agent-gem install fluent-plugin-ec2-metadata:0.1.1
td-agent-gem install fluent-plugin-prometheus:1.0.1

mkdir -p /var/log/td-agent/pos/ /etc/td-agent/.ssh

usermod -s /bin/bash td-agent
usermod -d /etc/td-agent td-agent
chown -R td-agent:td-agent /var/log/td-agent
chmod -R 700 /etc/td-agent/.ssh

cat << EOF > /etc/sudoers.d/td-agent
td-agent      ALL=(ALL)       NOPASSWD: /etc/init.d/td-agent start,/etc/init.d/td-agent stop,/etc/init.d/td-agent restart,/etc/init.d/td-agent status,/etc/init.d/td-agent reload,/usr/bin/systemctl * td-agent
EOF

cp /etc/td-agent/td-agent.conf /etc/td-agent/td-agent.conf.default
aws s3 cp s3://${s3_bucket}/common/aeg/${subsystem_id}/td-agent/ecs/td-agent.conf /etc/td-agent/td-agent.conf

cat << EOF >> /etc/sysconfig/td-agent
SYSTEM_LOGGING_SERVER_HOST=${aggregator_host}
EOF

cat << EOF >> /etc/td-agent/.ssh/authorized_keys
${jenkins-key}
EOF
chmod 600 /etc/td-agent/.ssh/authorized_keys
chown -R td-agent:td-agent /etc/td-agent

cp /usr/lib/systemd/system/td-agent.service /usr/lib/systemd/system/td-agent.service.default
aws s3 cp s3://${s3_bucket_infra}/infra/install/td-agent/amazonlinux2/td-agent.service /usr/lib/systemd/system/td-agent.service
chmod 644 /usr/lib/systemd/system/td-agent.service

##############################################
#Modify logrotate config
##############################################
#td-agent.log
sed -i -e "" /etc/logrotate.d/td-agent

#syslog
cp -p /etc/logrotate.d/syslog /etc/logrotate.d/syslog.default
sed -i -e "" /etc/logrotate.d/syslog
logrotate --force /etc/logrotate.d/syslog

systemctl daemon-reload
systemctl enable td-agent
systemctl start td-agent

#####################################
# Install SEP
#####################################
yum install -y glibc.i686 libgcc.i686 libX11.i686 unzip
aws s3 cp ${s3_blue_resource}/Installer/Symantec/Agent/${sep_environment}/amazon_linux/SymantecEndpointProtection.zip ./

unzip SymantecEndpointProtection.zip  -d ./SymantecEndpointProtection
chmod 755 ./SymantecEndpointProtection/install.sh

./SymantecEndpointProtection/install.sh -i

#####################################
# Install psql
#####################################
yum -y install postgresql

##############################################
# Setup Ope-tool
##############################################
mkdir /aeg/operation-tools
chown jobuser:jobuser /aeg/operation-tools

aws s3 cp s3://${s3_bucket}/common/aeg/${subsystem_id}/operation-tools/deploy.sh /aeg/operation-tools/deploy.sh
su - jobuser -c ""

