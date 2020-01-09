#!/bin/bash
echo -e "\e[32mStop OpenLDAP daemon...\e[0m"
systemctl stop slapd

echo -e "\n\e[32mDelete OpenLDAP configurations...\e[0m"
rm -rf /etc/openldap/slapd.d/*
rm -rf /var/log/ldap/* 2> /dev/null
rm -rf /var/lib/ldap/* 2> /dev/null
rm -f /var/run/ldapi 2> /dev/null
yum remove openldap-servers -y

echo -e "\n\e[32mInstall OpenLDAP package and contents...\e[0m"
yum install openldap-servers -y

echo -e "\n\e[32mReset OpenLDAP binding interfaces...\e[0m"
sed -i 's/^SLAPD_URLS.*$/SLAPD_URLS="ldapi:\/\/\/ ldap:\/\/127.0.0.1\/ ldaps:\/\/\/"/' /etc/sysconfig/slapd
#sed -i 's/^SLAPD_URLS.*$/SLAPD_URLS="ldapi:\/\/\/ ldap:\/\/\/ ldaps:\/\/\/"/' /etc/sysconfig/slapd

echo -e "\n\e[32mStop OpenLDAP daemon to delete test database...\e[0m"
systemctl stop slapd

if [ -f /etc/openldap/slapd.d/cn=config/olcDatabase=\{1\}monitor.ldif ];then
  echo -e "\n\e[32mDelete test monitor database...\e[0m"
  rm -vf /etc/openldap/slapd.d/cn=config/olcDatabase=\{1\}monitor.ldif
fi

if [ -f /etc/openldap/slapd.d/cn=config/olcDatabase=\{2\}hdb.ldif ];then
  echo -e "\n\e[32mDelete test database...\e[0m"
  rm -vf /etc/openldap/slapd.d/cn=config/olcDatabase=\{2\}hdb.ldif
fi

echo -e "\e[32mSetup ldap client configuration...\e[0m"
cat <<EOF > /etc/openldap/ldap.conf
#
# LDAP Defaults
#

# See ldap.conf(5) for details
# This file should be world readable but not world writable.

BASE   dc=example,dc=com
URI    ldapi:///

#SIZELIMIT      12
#TIMELIMIT      15
#DEREF          never

TLS_CACERTDIR   /etc/openldap/cacerts

# Turning this off breaks GSSAPI used with krb5 when rdns = false
SASL_NOCANON    on
TLS_REQCERT     always
TLS_CACERT      /etc/openldap/certs/root-ca.pem
TLS_CERT        /etc/openldap/certs/cert.pem
TLS_KEY         /etc/openldap/certs/cert.pem
EOF


echo -e "\n\e[32mStart OpenLDAP daemon to delete test database...\e[0m"
systemctl restart slapd

