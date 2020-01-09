#!/bin/bash
SHOW_SCHEMA="yes"

if [ $SHOW_SCHEMA == "yes" ];then
    slapcat -b cn=config -o ldif-wrap=no -a '(!(objectClass=olcSchemaConfig))'
else
    slapcat -b cn=config -o ldif-wrap=no
fi
