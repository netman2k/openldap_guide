#!/bin/bash
[ "$1"  = "-h" ] && { echo "$0 <Debug Level>"; exit 0; }
debug_level="${1:-128}"
systemctl stop slapd
/usr/sbin/slapd -u ldap -h  "ldapi:/// ldaps:///" -d $debug_level
systemctl start slapd

