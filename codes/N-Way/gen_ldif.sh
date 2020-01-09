#!/bin/bash
#set -x
set -e

declare -A MASTERS=()

declare -r DATA_DIR="/tmp"
declare -r CN_CONFIG_FILE="${DATA_DIR}/cn_config_syncrepl.ldif"
declare -r BACKEND_FILE="${DATA_DIR}/backend_syncrepl.ldif"

declare -r DEFAULT_LDAP_URL="ldaps://ker001.example.com"
declare -r DEFAULT_BACKEND_DN="olcDatabase={3}mdb,cn=config"
declare -r DEFAULT_BACKEND_BASEDN="dc=example,dc=com"
declare -r DEFAULT_BACKEND_BINDDN="cn=Replicator,dc=example,dc=com"
declare -r DEFAULT_CN_CREDENTIAL="STRONGpassword"
declare -r DEFAULT_BINDDN_CREDENTIAL="replicator@pwd"

read -p "How many masters do you want to create? " num_of_masters
if [ "x${num_of_masters}" == "x" ] || [ $num_of_masters -le "2" ];then 
  echo -e "\e[31mN-way master needs 3 servers, exit!\e[0m" 
  exit
fi

#read -s -p "Enter the credential of cn=config: " cn_config_credential
#[ ${cn_config_credential} ] || cn_config_credential=$DEFAULT_CN_CREDENTIAL
#echo

read -p "Enter the BindDN for syncrepl (default: ${DEFAULT_BACKEND_BINDDN}): " backend_binddn
[ ${backend_binddn} ] || backend_binddn=$DEFAULT_BACKEND_BINDDN

read -s -p "Enter the credential of BindDN: " binddn_credential
[ $binddn_credential ] || binddn_credential=$DEFAULT_BINDDN_CREDENTIAL
echo

read -p "Enter the DN of the backend to set syncrepl (default: ${DEFAULT_BACKEND_DN}): " backend_dn
[ ${backend_dn} ] || backend_dn=$DEFAULT_BACKEND_DN

read -p "Enter the BaseDN of the backend to set syncrepl (default: ${DEFAULT_BACKEND_BASEDN}): " backend_basedn
[ ${backend_basedn} ] || backend_basedn=$DEFAULT_BACKEND_BASEDN

for i in `seq 1 $num_of_masters`;do
  url="${DEFAULT_LDAP_URL/1/$i}"
  read -p "Enter the URL of ServerID ${i} (i.e., $url) : " ldap_url
  if [ $ldap_url ];then 
    MASTERS[$i]=$ldap_url
  else
    MASTERS[$i]=$url
  fi
done

# http://www.openldap.org/doc/admin24/replication.html#N-Way%20Multi-Master%20replication
echo -e "\e[32mCreate a LDIF file\e[0m..."

mkdir -p $DATA_DIR

######################################
# CN=CONFIG SYNCREPL SETTINGS        #
######################################
cat <<EOF > $CN_CONFIG_FILE
dn: cn=config
changetype: modify
replace: olcServerID
EOF
for key in "${!MASTERS[@]}";do echo -e "olcServerID: $key ${MASTERS[$key]}" >> $CN_CONFIG_FILE;done

echo "" >> $CN_CONFIG_FILE

#cat <<EOF >> $CN_CONFIG_FILE
#dn: olcDatabase={0}config,cn=config
#changetype: modify
#add: olcRootPW
#olcRootPW: ${cn_config_credential}
#EOF

#echo "" >> $CN_CONFIG_FILE

cat <<EOF >> $CN_CONFIG_FILE
dn: olcOverlay=syncprov,olcDatabase={0}config,cn=config
changetype: add
objectClass: olcOverlayConfig
objectClass: olcSyncProvConfig
olcOverlay: syncprov
EOF

echo "" >> $CN_CONFIG_FILE

cat <<EOF >> $CN_CONFIG_FILE
dn: olcDatabase={0}config,cn=config
changetype: modify
add: olcSyncRepl
EOF
for key in "${!MASTERS[@]}";do
  echo "olcSyncRepl: rid=$(printf "%03d" "${key}") provider=${MASTERS[$key]} binddn=\"${backend_binddn}\" bindmethod=simple credentials=\"${binddn_credential}\" searchbase=\"cn=config\" type=refreshAndPersist retry=\"5 5 300 +\" timeout=1" >> $CN_CONFIG_FILE
done

cat <<EOF >> $CN_CONFIG_FILE
-
add: olcMirrorMode
olcMirrorMode: TRUE
EOF

######################################
# BACKEND DATABASE SYNCREPL SETTINGS #
######################################
cat <<EOF > $BACKEND_FILE
dn: ${backend_dn}
changetype: modify
add: olcSyncRepl
EOF
for key in "${!MASTERS[@]}";do
  echo -e "olcSyncRepl: rid=$(printf "%03d" "$(( ${key} + num_of_masters ))") provider=${MASTERS[$key]} binddn=\"${backend_binddn}\" bindmethod=simple credentials=\"${binddn_credential}\" searchbase=\"${backend_basedn}\" attrs="*,+" logbase=\"cn=deltalog\" logfilter=\"(&(objectClass=auditWriteObject)(reqResult=0))\" schemachecking=on type=refreshAndPersist retry=\"5 5 300 +\" syncdata=accesslog timeout=1" >> $BACKEND_FILE
done

cat <<EOF >> $BACKEND_FILE
-
add: olcMirrorMode
olcMirrorMode: TRUE
EOF

echo
echo -e "\e[32mCreating is done\e[0m..."
echo
echo -e "\e[32m1. Run the below command on every master\e[0m..."
echo -e "\e[4mldapmodify -Y EXTERNAL -H ldapi:/// -f ${CN_CONFIG_FILE}\e[0m"
echo
echo -e "\e[32m2. Run the below command on every master\e[0m..."
echo -e "\e[4mldapmodify -Y EXTERNAL -H ldapi:/// -f ${BACKEND_FILE}\e[0m"
echo 
echo -e "\e[32m3. Accommodate your data on first master only!!!\e[0m..."
echo 
