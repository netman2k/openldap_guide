#!/bin/bash
declare -r VERSION="v1.0"
declare -r BASE_DIR="/opt/prometheus"

echo -e "\e[32mPreparing directory require...\e[0m"
[ -d $BASE_DIR/proms ] || mkdir -p $BASE_DIR/proms
[ -d $BASE_DIR/openldap_exporter ] || mkdir -p $BASE_DIR/openldap_exporter

echo -e "\e[32mDownload and install...\e[0m"
rpm -qi wget &> /dev/null
[ "$?" -eq "1" ] && yum install -y wget
wget https://github.com/tomcz/openldap_exporter/releases/download/$VERSION/openldap_exporter-linux \
-O $BASE_DIR/openldap_exporter/openldap_exporter-linux 
chmod u+x $BASE_DIR/openldap_exporter/openldap_exporter-linux 

echo -e "\e[32mSet configure file for the openldap_exporter daemon...\e[0m"
cat <<EOF > /etc/sysconfig/openldap_exporter
OPTS="-ldapUser cn=monitor,cn=Monitor -ldapPass 'nhnent123!@#' -ldapAddr localhost:389"
EOF

echo -e "\e[32mCreate openldap_exporter system unit file...\e[0m"
cat <<'EOF' > /etc/systemd/system/openldap_exporter.service
[Unit]
Description=OpenLDAP Exporter
Documentation=https://github.com/tomcz/openldap_exporter
Requires=network.target remote-fs.target
After=network.target remote-fs.target

[Service]
Type=simple
User=root
Group=root
PIDFile=/var/run/openldap_exporter.pid
EnvironmentFile=/etc/sysconfig/openldap_exporter
ExecStart=/opt/prometheus/openldap_exporter/openldap_exporter-linux $OPTS
ExecStop=/bin/kill -s QUIT $MAINPID
ExecReload=/bin/kill -s HUP $MAINPID

[Install]
WantedBy=multi-user.target
EOF

echo -e "\e[32mReload Systemd daemon...\e[0m"
systemctl daemon-reload
echo
echo -e "\e[32mYou might start openldap_exporter now...\e[0m"
echo -e "\e[31m> systemctl enable openldap_exporter && systemctl start \$_\e[0m"
