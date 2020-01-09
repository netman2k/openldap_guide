#!/bin/bash
set -e
read -s -p "Enter the password of the cn=Manager: " APASS

echo -e "\n\e[32mImport organizational...\e[0m"
ldapadd -D cn=Manager,dc=example,dc=com -w $APASS -H ldapi:/// -f example.com_O.ldif

echo -e "\n\e[32mImport organizationalRole...\e[0m"
ldapadd -D cn=Manager,dc=example,dc=com -w $APASS -H ldapi:/// -f example.com_Roles.ldif

echo -e "\n\e[32mImport organizationalUnit...\e[0m"
ldapadd -D cn=Manager,dc=example,dc=com -w $APASS -H ldapi:/// -f example.com_OUs.ldif

echo -e "\n\e[32mImport organizationalRole...\e[0m"
ldapadd -D cn=Manager,dc=example,dc=com -w $APASS -H ldapi:/// -f example.com_Groups.ldif

echo -e "\n\e[32mImport all except above...\e[0m"
ldapadd -D cn=Manager,dc=example,dc=com -w $APASS -H ldapi:/// -f example.com_Accounts.ldif
