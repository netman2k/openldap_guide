# OpenLDAP의 기본 설정

본 장에서는 OpenLDAP을 설치하고 기본 설정을 통하여 서비스 준비 상태로 만드는 것을 목표로 한다.

## OpenLDAP 설치 및 시작 {#openldap설치}

본 가이드는 CentOS 7.X 를 기본 OS로 사용하며, 기본적으로 제공하는 OpenLDAP 패키지를 사용할 것이다. 만일 다른 OS 플랫폼을 사용하거나 본 가이드와 맞지 않는 경우, 공식 관리자 가이드의 [4. Building and Installing OpenLDAP Software](http://www.openldap.org/doc/admin24/install.html) 참고하도록 한다.

```
# yum makecache fast
# yum install openldap-servers openldap-clients -y
```

테스트 시 사용된 버전은 다음과 같다

```
# cat /etc/redhat-release 
CentOS Linux release 7.3.1611 (Core)

# rpm -qa|grep openldap
openldap-2.4.44-5.el7.x86_64
openldap-servers-2.4.44-5.el7.x86_64
openldap-clients-2.4.44-5.el7.x86_64
```

다음 명령을 통하여 OpenLDAP 데몬을 구동한다.

```
[root@master openldap]# systemctl start slapd
[root@master openldap]# systemctl status slapd
● slapd.service - OpenLDAP Server Daemon
   Loaded: loaded (/usr/lib/systemd/system/slapd.service; disabled; vendor preset: disabled)
   Active: active (running) since Mon 2017-10-16 06:25:09 UTC; 4s ago
     Docs: man:slapd
           man:slapd-config
           man:slapd-hdb
           man:slapd-mdb
           file:///usr/share/doc/openldap-servers/guide.html
  Process: 13943 ExecStart=/usr/sbin/slapd -u ldap -h ${SLAPD_URLS} $SLAPD_OPTIONS (code=exited, status=0/SUCCESS)
  Process: 13929 ExecStartPre=/usr/libexec/openldap/check-config.sh (code=exited, status=0/SUCCESS)
 Main PID: 13946 (slapd)
   CGroup: /system.slice/slapd.service
           └─13946 /usr/sbin/slapd -u ldap -h ldapi:/// ldap:///

Oct 16 06:25:09 master systemd[1]: Starting OpenLDAP Server Daemon...
Oct 16 06:25:09 master runuser[13932]: pam_unix(runuser:session): session opened for user ldap by (uid=0)
Oct 16 06:25:09 master slapd[13943]: @(#) $OpenLDAP: slapd 2.4.44 (Aug  4 2017 14:23:27) $
                                             mockbuild@c1bm.rdu2.centos.org:/builddir/build/BUILD/openldap-2.4.44/openldap-2.4.44/servers/slapd
Oct 16 06:25:09 master slapd[13946]: hdb_db_open: warning - no DB_CONFIG file found in directory /var/lib/ldap: (2).
                                     Expect poor performance for suffix "dc=my-domain,dc=com".
Oct 16 06:25:09 master slapd[13946]: slapd starting
Oct 16 06:25:09 master systemd[1]: Started OpenLDAP Server Daemon.
```

## slapd 기본 설정 {#configuratio}

위에서 언급한 것 처럼 OpenLDAP 패키지를 설치를 완료하게되면, slapd를 사용할 수 있는 준비 상태가 된다. 하지만 이를 서비스가 가능한 상태로 보면 위험하다. 하지만 이에 대한 설정은 차츰 보기로 하자!

> slapd는 독립 서비스\(standalone service\)를 수행할 수 있도록 해주는 데몬 프로그램이다.

OpenLDAP 2.3 이후 버전에서는 기본적으로 이전 버전까지 사용된 정적 설정 파일을 통한 설정이 아닌, 동적 런타임 설정 엔진\(Dynamic runtime configuration engine\) - slapd-config 을 사용하도록 되어져있다.

> OpenLDAP 2.3 이전에서는 slapd.conf 파일 수정을 통하여 시스템 설정을 진행하였음.  
> 만일 설정이 변경될 경우 데몬 프로그램의 재시작이 필수 불가결이었다.
>
> 자세한 사항은 slapd-config man page를 통해 확인 가능하다. 참고로 기본으로 제공되는 공식 관리자 가이드에서는 설정 방식의 상당 부분이 기존 정적 설정 파일 방식만 보여줄 뿐, 동적 런타임 설정 방법은 빠져있다. 따라서 가급적 man page 활용을 할 수 있도록 한다.

slapd-config는 다음과 같은 특징을 가진다:

* 표준 LDAP 동작들\(operations\)을 통하여 관리
* 설정 데이터를 LDIF 데이터베이스에 저장, 일반적으로 /etc/openldap/slapd.d 혹은 /usr/local/etc/openldap/slapd.d 디렉터리에 위치
* 서비스 재시작 없이, 즉시\(On the fly\) 설정 변경을 가능케 함

**CentOS 7.X 환경 하에서 패키지 설치에의해 생성된 기본 설정 디렉터리 예제**

```
[root@master openldap]# tree /etc/openldap
/etc/openldap
├── certs
│   ├── cert8.db
│   ├── key3.db
│   ├── password
│   └── secmod.db
├── check_password.conf
├── ldap.conf
├── schema
│   ├── collective.ldif
│   ├── collective.schema
│   ├── corba.ldif
│   ├── corba.schema
│   ├── core.ldif
│   ├── core.schema
│   ├── cosine.ldif
│   ├── cosine.schema
│   ├── duaconf.ldif
│   ├── duaconf.schema
│   ├── dyngroup.ldif
│   ├── dyngroup.schema
│   ├── inetorgperson.ldif
│   ├── inetorgperson.schema
│   ├── java.ldif
│   ├── java.schema
│   ├── misc.ldif
│   ├── misc.schema
│   ├── nis.ldif
│   ├── nis.schema
│   ├── openldap.ldif
│   ├── openldap.schema
│   ├── pmi.ldif
│   ├── pmi.schema
│   ├── ppolicy.ldif
│   └── ppolicy.schema
└── slapd.d
    ├── cn=config
    │   ├── cn=schema
    │   │   └── cn={0}core.ldif
    │   ├── cn=schema.ldif
    │   ├── olcDatabase={0}config.ldif
    │   ├── olcDatabase={-1}frontend.ldif
    │   ├── olcDatabase={1}monitor.ldif
    │   └── olcDatabase={2}hdb.ldif
    └── cn=config.ldif

5 directories, 39 files
```

### 서비스 접근 방식 변경

기본적으로 CentOS 7.X이나 RHEL 7.X 환경에서는 IP뿐만아니라 Unix 소켓을 통한 서버 질의가 가능하도록 기본 설정되어져 있다. 하지만 기본으로 시스템의 모든 인터페이스 IP에 대하여 서비스가 바인딩됨에 따라 아무런 보안 조치가 되어있지 않은 slapd가 외부에 노출되게되는 문제점을 가진다.

일차적으로 Unix 도메인 소켓\(혹은 IPC 소켓\)만 접속을 허용하도록 설정을 변경하도록 하자. Unix 도메인 소켓을 사용할 경우 서비스를 외부에 노출시키지 않고 설정이나 테스트를 진행할 수 있다.

**기본 설정으로 열려진 slapd 프로세스**

```
[root@master ~]# netstat -lnp |grep 'slapd'
tcp        0      0 0.0.0.0:389             0.0.0.0:*               LISTEN      13946/slapd         
tcp6       0      0 :::389                  :::*                    LISTEN      13946/slapd         
unix  2      [ ACC ]     STREAM     LISTENING     39504    13946/slapd          /var/run/ldapi
```

/etc/sysconfig/sldapd 파일을 열어 SLAPD\_URLS 변수에 해당하는 값 중 ldap:///를 삭제한 후 서비스를 다시 구동시킨다.

다음 명령을 사용할 경우 간단히 처리할 수 있다.

```
sed -i 's|ldap:///||' /etc/sysconfig/slapd && systemctl restart slapd
```

**변경된 slapd 프로세스**

```
[root@master ~]# netstat -lnp |grep 'slapd'
unix  2      [ ACC ]     STREAM     LISTENING     40045    14004/slapd          /var/run/ldapi
```

보는 바와 같이 389/tcp로 열려진 프로세스가 더 이상 존재하지 않음을 확인할 수 있다.

## 데이터베이스 생성 및 관리 툴

본 파트에서는 slapd 데이터베이스를 생성하고 생성된 데이터베이스에 LDAP 클라이언트 툴을 사용하여 엔트리들을 추가하는 방법을 설명한다.

### 데이터베이스 생성

데이터베이스를 생성하기 위해서는 먼저 원하는 타입의 데이터베이스를 cn=config에 추가해주어야 한다.

다음과 같이 mdb.ldif 파일을 생성한 후 ldapadd 커맨드를 통하여 cn=config에 데이터베이스 설정을 해주도록 한다.

```
dn: olcDatabase=mdb,cn=config
objectClass: olcDatabaseConfig
objectClass: olcMdbConfig
olcSuffix: dc=example,dc=com
olcDatabase: mdb
olcDbDirectory: /var/lib/ldap
olcRootDN: cn=Manager,dc=example,dc=com
olcRootPW: secret
olcDbIndex: cn,sn,uid pres,eq,approx,sub
olcDbIndex: objectClass eq
```

```
[root@master works]# ldapadd -Y EXTERNAL -H ldapi:/// -f mdb.ldif 
SASL/EXTERNAL authentication started
SASL username: gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth
SASL SSF: 0
adding new entry "olcDatabase=mdb,cn=config"
```

> -Y EXTERNAL은 ldapadd 커맨드에게 SASL 프로토콜을 통하여 현재 로그인된 시스템 계정을 사용하도록 하는 옵션이다.
>
> 자세한 사항은 [http://www.openldap.org/doc/admin24/sasl.html를](http://www.openldap.org/doc/admin24/sasl.html를) 참고한다.
>
> LDIF에 대한 사항은 http://www.openldap.org/doc/admin24/dbtools.html 의 10.3. The LDIF text entry format을 참고한다.

이제 ldapsearch라는 쿼리를 사용하여 현재 설정된 사항을 확인해 보도록 하자.

```
[root@master works]# ldapsearch -Y EXTERNAL -H ldapi:/// -b cn=config \
> '(&(objectClass=olcDatabaseConfig)(objectClass=olcMdbConfig))'
SASL/EXTERNAL authentication started
SASL username: gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth
SASL SSF: 0
# extended LDIF
#
# LDAPv3
# base <cn=config> with scope subtree
# filter: (&(objectClass=olcDatabaseConfig)(objectClass=olcMdbConfig))
# requesting: ALL
#

# {3}mdb, config
dn: olcDatabase={3}mdb,cn=config
objectClass: olcDatabaseConfig
objectClass: olcMdbConfig
olcDatabase: {3}mdb
olcDbDirectory: /var/lib/ldap
olcSuffix: dc=example,dc=com
olcRootDN: cn=Manager,dc=example,dc=com
olcRootPW: secret
olcDbIndex: cn,sn,uid pres,eq,approx,sub
olcDbIndex: objectClass eq

# search result
search: 2
result: 0 Success

# numResponses: 2
# numEntries: 1
```

> 위 커맨드 중 맨 마지막 _\(&\(objectClass=olcDatabaseConfig\)\(objectClass=olcMdbConfig\)\)_ 는 LDAP filter query를 나타낸다.
>
> 자세한 커맨드 사용법은 man ldapsearch 를 참고한다.

결과적으로  {3}mdb라는 데이터베이스가 생성됨을 확인할 수 있다.

#### RootDN의 암호 변경과 slappasswd

olcRootDN은 이전 파트에서 관리자 계정과 같은 역할을 한다고 하였다. 문제는 olcRootPW인데 보시다시피 평문\(Plain text\)형태로 나타내어진다. 이미 접근 제어에서 언급했듯이 기본 접근 제어는 익명을 포함한 모든 사용자 Read 권한을 가진다고 하였다. 만일 외부에 본 서비스가 열려있다면 민감한 데이터가 보일 수 있을 것이다.

접근 제어는 추후에 변경하더라도 우선 RootDN의 암호를 평문이 아닌 암호화된 문장을 사용하도록 처리하자.

openldap-servers 패키지는 /sbin/slappasswd라는 커맨드를 제공한다. 이 커맨드는 관리자나 사용자가 쉽게 암호화 형태의 암호문을 작성할 수 있도록 해준다. 사용법은 다음과 같다.

```
Usage: slappasswd [options]
  -c format    crypt(3) salt format
  -g        generate random password
  -h hash    password scheme
  -n        omit trailing newline
  -o <opt>[=val] specify an option with a(n optional) value
      module-path=<pathspec>
      module-load=<filename>
  -s secret    new password
  -u        generate RFC2307 values (default)
  -v        increase verbosity
  -T file    read file for new password
```

그런데 과연 이것을 어떻게 사용하는 것인가? 단순히 slappasswd를 실행했을 경우는 다음과 같이 새로운 암호를 물어보게된다.

```
[root@master works]# slappasswd 
New password: 
Re-enter new password: 
{SSHA}ul6f8CMblG3OW4l8tOES8AZBPiIZe9pW
```

이제 olcRootPW를 변경해 보도록 하자. 변경은 ldapmodify라는 커맨드를 통하여 할 수 있다.

일단 다음과 같이 update\_rootpw.ldif라는 파일을 생성한 후 다음 내용을 삽입하도록 한다.

```
dn: olcDatabase={3}mdb,cn=config
changetype: modify
replace: olcRootPW
olcRootPW: {SSHA}ul6f8CMblG3OW4l8tOES8AZBPiIZe9pW
```

ldapmodify 경우는 좀 다른 형태의 ldif 을 필요로 하는데 보는 바와 같이 변경할 엔트리의DN 및 변경 형태\(changetype\)을 기술해 주어야한다.

위 예제 경우는 변경 형태가 변경\(replace\)이고 변경 대상은 olcDatabase={3}mdb,cn=confg 엔트리의 olcRootPW 엔티티 임을 알 수 있다.

이제 다음과 같이 ldapmodify 명령을 실행 시키도록 한다.

```
[root@master works]# ldapmodify -Y EXTERNAL -H ldapi:/// -f update_rootpw.ldif 
SASL/EXTERNAL authentication started
SASL username: gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth
SASL SSF: 0
modifying entry "olcDatabase={3}mdb,cn=config"
```

```
[root@master works]# ldapsearch -Y EXTERNAL -H ldapi:/// -b cn=config \
> '(&(objectClass=olcDatabaseConfig)(objectClass=olcMdbConfig))'
SASL/EXTERNAL authentication started
SASL username: gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth
SASL SSF: 0
# extended LDIF
#
# LDAPv3
# base <cn=config> with scope subtree
# filter: (&(objectClass=olcDatabaseConfig)(objectClass=olcMdbConfig))
# requesting: ALL
#

# {3}mdb, config
dn: olcDatabase={3}mdb,cn=config
objectClass: olcDatabaseConfig
objectClass: olcMdbConfig
olcDatabase: {3}mdb
olcDbDirectory: /var/lib/ldap
olcSuffix: dc=example,dc=com
olcRootDN: cn=Manager,dc=example,dc=com
olcDbIndex: cn,sn,uid pres,eq,approx,sub
olcDbIndex: objectClass eq
olcRootPW:: e1NTSEF9dWw2ZjhDTWJsRzNPVzRsOHRPRVM4QVpCUGlJWmU5cFc

# search result
search: 2
result: 0 Success

# numResponses: 2
# numEntries: 1
```

동일한 ldapsearch 명령을 수행해 본 결과 정상적으로 변경되었으며, 평문이 아닌 암호화 형태의 문장으로 보임을 확인할 수 있다.

이제 데이터베이스가 생성되었으니 이 데이터베이스에 실 데이터를 저장해보도록 하자.

새로운 파일 entries.ldif를 생성한 후 다음 내용을 저장하고 ldapadd 명령을 실행해 보자

```
# Organization for Example Corporation
dn: dc=example,dc=com
objectClass: dcObject
objectClass: organization
dc: example
o: Example Corporation
description: The Example Corporation

# Organizational Role for Directory Manager
dn: cn=Manager,dc=example,dc=com
objectClass: organizationalRole
cn: Manager
description: Directory Manager
```

```
[root@master works]# ldapadd -Y EXTERNAL -H ldapi:/// -f entries.ldif 
SASL/EXTERNAL authentication started
SASL username: gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth
SASL SSF: 0
adding new entry "dc=example,dc=com"
ldap_add: Insufficient access (50)
    additional info: no write access to parent
```

위 데이터베이스 생성 시는 아무런 문제가 없었지만 이제는 오류가 발생되며 진행이 되지 않음을 볼 수 있다.

원인은 dc=example,dc=com의 suffix를 가지는 데이터베이스에 현재 로그인 계정인 root의 정보가 접근 제어 지시자로 들어가 있지 않아서 그렇다. 이 경우 기본 접근 제한 설정인 모든 사용자 읽기 가능 권한이 부여되며, 그 외의 권한은 RootDN에게만 주어지게 된다.

이로 인해 이제 부터 모든 명령은 설정된 RootDN과 RootPW를 필요로 한다.

```
[root@master works]# ldapadd -H ldapi:/// -D cn=Manager,dc=example,dc=com -W -f entries.ldif 
Enter LDAP Password: 
adding new entry "dc=example,dc=com"

adding new entry "cn=Manager,dc=example,dc=com"
```

결과와 같이 RootDN을 사용할 경우 문제 없이 추가가 되었음을 확인할 수 있다.

이제 ldapsearch 커맨드를 통하여 확인해보자.

```
[root@master works]# ldapsearch -Y EXTERNAL -H ldapi:/// -b dc=example,dc=com
SASL/EXTERNAL authentication started
SASL username: gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth
SASL SSF: 0
# extended LDIF
#
# LDAPv3
# base <dc=example,dc=com> with scope subtree
# filter: (objectclass=*)
# requesting: ALL
#

# example.com
dn: dc=example,dc=com
objectClass: dcObject
objectClass: organization
dc: example
o: Example Corporation
description: The Example Corporation

# Manager, example.com
dn: cn=Manager,dc=example,dc=com
objectClass: organizationalRole
cn: Manager
description: Directory Manager

# search result
search: 2
result: 0 Success

# numResponses: 3
# numEntries: 2
```



