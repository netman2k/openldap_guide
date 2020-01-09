#!/bin/bash
set -e

declare -r TLSCERT_DIR=/etc/openldap/certs
declare -r DATA_DIR=/var/lib/ldap

echo -e "\n\e[32mCopy certificates...\e[0m"
cp certs/root-ca.pem $TLSCERT_DIR/
cat certs/$(hostname).pem \
    certs/$(hostname)-key.pem > $TLSCERT_DIR/cert.pem

echo -e "\n\e[32mCreate DH parameter file...\e[0m"
if [ ! -f /etc/openldap/certs/slapd.dh.params ];then
    openssl dhparam -out /etc/openldap/certs/slapd.dh.params.tmp 1024
    mv /etc/openldap/certs/slapd.dh.params.tmp /etc/openldap/certs/slapd.dh.params
fi
chmod 0640 $TLSCERT_DIR/*.pem
chown root:ldap $TLSCERT_DIR/*.{pem,params}

echo -e "\n\e[32mCreate directories to store data...\e[0m"
mkdir -p $DATA_DIR/{data,deltalog,log}
chown ldap: -R $DATA_DIR
chmod 700 $DATA_DIR

echo -e "\n\e[32mLoad additional modules...\e[0m"
ldapadd -Y EXTERNAL -H ldapi:/// -f init_LDIFs/modules.ldif -v

echo -e "\n\e[32mSet ACL on cn=config...\e[0m"
ldapmodify -Y EXTERNAL -H ldapi:/// -f init_LDIFs/cn_config.ldif -v

echo -e "\n\e[32mSet TLS for activating LDAPS...\e[0m"
ldapmodify -Y EXTERNAL -H ldapi:/// -f init_LDIFs/tls.ldif -v

echo -e "\n\e[32mCopy additional schema...\e[0m"
if [ ! -f /etc/openldap/schema/rfc2307bis.ldif ];then
    cp -v schemas/rfc2307bis.ldif /etc/openldap/schema/rfc2307bis.ldif
fi

echo -e "\n\e[32mSet schemas to load...\e[0m"
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/cosine.ldif
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/inetorgperson.ldif
# rfc2307bis and nis schema cannot be used at the same time, both have gecos
#ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/nis.ldif
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/openldap.ldif
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/dyngroup.ldif
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/ppolicy.ldif
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/rfc2307bis.ldif

echo -e "\n\e[32mSet frontend database...\e[0m"
ldapmodify -Y EXTERNAL -H ldapi:/// -f init_LDIFs/frontend.ldif -v

echo -e "\n\e[32mSet backend database...\e[0m"
ldapadd -Y EXTERNAL -H ldapi:/// -f init_LDIFs/monitor_cn.ldif -v
ldapadd -Y EXTERNAL -H ldapi:/// -f init_LDIFs/delta-syncrepl.ldif -v
ldapadd -Y EXTERNAL -H ldapi:/// -f init_LDIFs/database.ldif -v

echo -e "\n\e[32mSet logrotation logs...\e[0m"
cat <<EOF > /etc/logrotate.d/slapd-auditlog
/var/lib/ldap/log/*.log {
    notifempty
    missingok
    monthly
    rotate 3
    compress
    copytruncate
}
EOF

echo -e "\n\e[32mCreate a cron job to renew DH parameter file...\e[0m"
cat <<'EOF' > /etc/cron.weekly/renew_dhparam
#!/bin/sh
echo "Renew Diffie-Helman parameter for slapd"
openssl dhparam -out /etc/openldap/certs/slapd.dh.params.tmp 1024 &> /dev/null
mv /etc/openldap/certs/slapd.dh.params.tmp  /etc/openldap/certs/slapd.dh.params &> /dev/null
echo "$(md5sum /etc/openldap/certs/slapd.dh.params)"
EOF
chmod +x /etc/cron.weekly/renew_dhparam
