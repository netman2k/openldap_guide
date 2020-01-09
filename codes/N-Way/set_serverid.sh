#!/bin/bash
#
# Step 1: Set ServerID
#
# +---------------------------------+
# | DO IT ON ALL MASTER SERVERS !!! |
# +---------------------------------+
#
# http://www.openldap.org/doc/admin24/replication.html#N-Way%20Multi-Master%20replication
#

declare -r DEFAULT_ROOTPW="{SSHA512}DNvaESSRbwmEB87vAUdrL99tuVmCl3JJdR8k2bzDpOlvzVZw0AXW1OwJvi/gxkun/9s26wdSDsd0t0fsQw9XvfBQMZ52fwRqcyUle8M2AKE="
declare -r DATA_FILE="/tmp/serverid.ldif"

# Remove domain section to extract sequence number from hostname
declare -r S_HOSTNAME="${HOSTNAME/.example.com/}"

SEQ=${S_HOSTNAME:$((${#S_HOSTNAME}-1))}
if [[ $SEQ =~ [^0-9]+ ]];then
  echo -e "\e[31mUnable to extract sequence number from hostname!\e[0m"
  exit
fi

echo -e "\n\e[32mGenerate cn=config LDIF...\e[0m"
cat <<EOF > $DATA_FILE
dn: cn=config
changetype: modify
add: olcServerID
olcServerID: ${SEQ}
EOF

ldapmodify -Y EXTERNAL -H ldapi:/// -f ${DATA_FILE} -v

