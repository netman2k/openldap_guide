# OpenLDAP + SSSD integratation on CentOS 7
***NSLCD WILL NOT WORK WITH RFC2307BIS***

## Package Installation
```
[root@ker002 vagrant]# yum install sssd-ldap
```

## Configuration

```bash
cat <<EOF > /etc/sssd/sssd.conf
[domain/example.com]
id_provider = ldap
auth_provider = ldap
autofs_provider = ldap
chpass_provider = ldap
ldap_uri = ldaps://ker001.example.com
ldap_schema = rfc2307bis
ldap_search_base = dc=example,dc=com
ldap_tls_reqcert = never
# primary and backup ldap servers below [first server and],[second server]
ldap_default_bind_dn = cn=lookup,dc=example,dc=com
ldap_default_authtok = lookup@pwd
cache_credentials = False
#debug_level = 5

[sssd]
config_file_version = 2
reconnection_retries = 3
sbus_timeout = 30
services = nss, pam, autofs
domains = example.com
#debug_level = 9

[pam]
reconnection_retries = 3
offline_credentials_expiration = 2
offline_failed_login_attempts = 3
offline_failed_login_delay = 5
#pam_verbosity = 5
#debug_level = 5

[nss]
filter_groups = root
filter_users = root,ldap,named,avahi,haldaemon,dbus,radiusd,news,nscd
#debug_level = 5

[autofs]
EOF
```

## RUN
```bash
systemctl start sssd
```

## References
* <https://tylersguides.com/guides/configure-sssd-for-ldap-on-centos-7/>
* <https://mapr.com/support/s/article/How-to-configure-LDAP-client-by-using-SSSD-for-authentication-on-CentOS?language=en_US>

