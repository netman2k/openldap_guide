#  {#LDAP의모든것2-공개형LDAP엔진OpenLDAP}

# 3. OpenLDAP에 대한 이해 {#LDAP의모든것2-공개형LDAP엔진OpenLDAP}

## OpenLDAP에 대한 간단한 소개 {#LDAP의모든것2-OpenLDAP에대한간단한소개}

OpenLDAP는 LDAP의 전신이라고 할수 있는 Umich\(미시건대학\) LDAP 3.3을 기반으로 새로이 만든 LDAP프로젝트의 산물이다. 오픈소스 정책을 따르면서도 상용 LDAP서버 못지 않은 응용프로그램들과 서버툴들을 제공하겠다는 목적아래 인터넷의 많은 개발자들이 자원해서 이 프로젝트를 돕고 있다.

현재 OpenLDAP는 2.4.x 버전의 안정버전을 내놓고 있다. 1.2.x버전의 경우 LDAP v2 표준을 지원하는 반면 2.x 버전은 LDAP v3 표준을 기반으로 만들어졌다.

## LDAPv2 와 LDAPv3의 차이점 {#ldapv2와ldapv3의차이점}

LDAPv3는 LDAP 2를 대체하기 위해 1990에 개발되었으며 다음과 같은 기능들이 추가되었다:

* 강력한 인증 및 SASL을 통한 데이터 보안 서비스
* 인증서기반 인증 및 TLS\(SSL\)을 통한 데이터 보안 서비스
* 유니코드\(Unicode\)를 통한 국제화\(Internationalization\)
* Referrals and Continuations
* Schema Discovery
* 확장성 \(controls, extended operations, and more\)



### 설정 구조\(Configuration Layout\)

slapd 설정은 미리 정의된 스키마\(schema\)와 DIT를 통해 특수한 LDAP 디렉터리에 저장이 되도록 되어있다. 또한 전역\(global\) 설정 옵션, 스키마 정의, 백앤드와 데이터베이스 정의 그리고 이와 연관되어지는 다른 아이템들을 지니기 위해 특정 objectClass가 사용되어진다.

## ![](/assets/config_dit.png)

**\[그림 3.1\] 설정 트리 예**

그림 3.1은 이들의 예를 보여주는데, 일부 요소들은 이해도를 높이기 위해 생략되어져 있다.

slapd-config 설정 트리는 매우 특수한 구조를 가진다. 루트\(root\) 트리는 cn=config 이며, 전역 설정을 포함하고 있다. 추가적인 설정은 별도의 자식\(child\) 엔트리에 포함되어진다.

* 동적으로 불려진 모듈들
* 스키마 정의들
  * cn=schema,cn=config 엔트리는 slapd에 하드코딩된 스키마를 포함한다
  * 자식 엔트리들은 설정 파일 및 운영 시 추가된 스키마들을 포함한다 
* 백앤드 관련 설정
* 데이터베이스 관련 설정
  * 오버레이\(Overlay\)들은 데이터베이스 하위에 정의된다
  * 데이터베이스와 오버레이들은 기타 다른 자식들을 가질 수 있다

다음은 일반적인 설정  LDIF 를 보여준다:

```
# global configuration settings
dn: cn=config
objectClass: olcGlobal
cn: config
<global config settings>

# schema definitions
dn: cn=schema,cn=config
objectClass: olcSchemaConfig
cn: schema
<system schema>

dn: cn={X}core,cn=schema,cn=config
objectClass: olcSchemaConfig
cn: {X}core
<core schema>

# additional user-specified schema
...

# backend definitions
dn: olcBackend=<typeA>,cn=config
objectClass: olcBackendConfig
olcBackend: <typeA>
<backend-specific settings>

# database definitions
dn: olcDatabase={X}<typeA>,cn=config
objectClass: olcDatabaseConfig
olcDatabase: {X}<typeA>
<database-specific settings>

# subsequent definitions and settings
...
```

> 위 코드 중 이름에 {X}가 포함될 경우 순서를 나타내는데 이를 Numeric index라 불린다. 일반적으로 LDAP 데이터베이스는 비 순차적\(unordered\)이나, 이 Numberic Index를 사용할 경우 강제로 설정에 순서를 정의하게한다. 따라서 이로인해 각 설정간 순번 의존성을 걸 수 있게 되는 것이다. 하지만 이 순서는 자동적으로 생성되기 때문에 LDIF에 굳이 순번을 넣어 작성할 필요는 없다.
>
> 속성\(Attribute\)와 objectClass에는 대부분 olc라는 prefix가 붙는데 이는 \(OpenLDAP Configuration\)을 나타낸다.

### 정적 설정 파일의 변환 처리

만약 기존에 사용되던 설정을 동적 설정 방식으로 변경하고자 한다면 다음 명령을 사용하여 변환가능하다

```
slaptest -f /usr/local/etc/openldap/slapd.conf -F /usr/local/etc/openldap/slapd.d
```

변환이 완료되었다면 다음 명령으로 설정된 rootdn과 rootpw로 cn=config가 접근 가능한지 테스트를 하도록 한다.

```
ldapsearch -x -D cn=config -w VerySecret -b cn=config
```

### 설정 지시자\(Configuration Directives\)

이 항목에서는 빈번히 사용되는 설정 지시자들을 설명한다. 모든 지시자를 보고자 한다면, slapd-config manual page를 이용하기 바란다.

#### cn=config

이 엔트리에 저장된 지시자들은 서버 전체에 영향을 미친다. 대부분은 시스템 혹은 연결과 관련되며, 데이터베이스와는 연관이 없다. 또한 이 엔트리는 반드시 _olcGlobal_ objectClass를 포함해야한다.

```
dn: cn=config
objectClass: olcGlobal
cn: config
olcArgsFile: /var/run/openldap/slapd.args
olcPidFile: /var/run/openldap/slapd.pid
olcTLSCACertificatePath: /etc/openldap/certs
structuralObjectClass: olcGlobal
<생략>
```

##### olcIdleTimeout: &lt;integer&gt;

유휴\(idle\) 클라이언트의 연결을 강제적으로 끊기 전 기다리는 시간\(초\)을 정의, 기본값은 0이며, 이는 이 기능의 해제를 의미한다.

##### olcLogLevel: &lt;level&gt;

로그 레벨은 정의된 숫자 혹은 키워드를 통해 설정가능하며,  로그 레벨 조합 \(OR연산 혹은 리스트 형태\) 또한 가능하다. 다음 표는 정의되어져 있는 로그 레벨들을 보여준다.

**\[표 3.1\] 디버깅\(Debuggin\) 로그 레벨**

| Level | **Keyword** | **Description** |
| :--- | :--- | :--- |
| -1 | any | enable all debugging |
| 0 |  | no debugging |
| 1 | \(0x1 trace\) | trace function calls |
| 2 | \(0x2 packets\) | debug packet handling |
| 4 | \(0x4 args\) | heavy trace debugging |
| 8 | \(0x8 conns\) | connection management |
| 16 | \(0x10 BER\) | print out packets sent and received |
| 32 | \(0x20 filter\) | search filter processing |
| 64 | \(0x40 config\) | configuration processing |
| 128 | \(0x80 ACL\) | access control list processing |
| 256 | \(0x100 stats\) | stats log connections/operations/results |
| 512 | \(0x200 stats2\) | stats log entries sent |
| 1024 | \(0x400 shell\) | print communication with shell backends |
| 2048 | \(0x800 parse\) | print entry parsing debugging |
| 16384 | \(0x4000 sync\) | syncrepl consumer processing |
| 32768 | \(0x8000 none\) | only messages that get logged whatever log level is set |

```
olcLogLevel 129
olcLogLevel 0x81
olcLogLevel 128 1
olcLogLevel 0x80 0x1
olcLogLevel acl trace
```

#### cn=module

이 엔트리는 동적으로  모듈을 올리고자 할 때 사용되며, 반드시 _olcModuleList_ objectClass 포함 하여야 한다.

```
dn: cn=module{0},cn=config
objectClass: olcModuleList
cn: module
cn: module{0}
olcModuleLoad: {0}pw-sha2.la
olcModuleLoad: {1}auditlog.la
olcModuleLoad: {2}syncprov.la
olcModuleLoad: {3}accesslog.la
olcModuleLoad: {4}rwm.la
olcModuleLoad: {5}back_relay.la
olcModuleLoad: {6}memberof.la
olcModuleLoad: {7}refint.la
<생략>
```

##### olcModuleLoad: &lt;filename&gt;

동적 로딩이 가능한 모듈의 이름을 정의

##### olcModulePath: &lt;pathspec&gt;

모듈이 위치한 디렉토리들을 정의, 일반적으로 디렉토리들은 콜론\(:\)으로 구분한다.

#### cn=schema

이 엔트리는 slapd에 하드코딩되어진 모든 스키마 정의들을 가지고 있다.  사용자 정의 스키마 경우 이 엔트리 하위에 위치하게 되며, 스키마 엔트리들은 반드시 _olcSchemaConfig_ objectClass를 포함해야 한다.

```
dn: cn=schema,cn=config
objectClass: olcSchemaConfig
cn: schema

dn: cn=test,cn=schema,cn=config
objectClass: olcSchemaConfig
cn: test
olcAttributeTypes: ( 1.1.1
  NAME 'testAttr'
  EQUALITY integerMatch
  SYNTAX 1.3.6.1.4.1.1466.115.121.1.27 )
olcAttributeTypes: ( 1.1.2 NAME 'testTwo' EQUALITY caseIgnoreMatch
  SUBSTR caseIgnoreSubstringsMatch SYNTAX 1.3.6.1.4.1.1466.115.121.1.44 )
olcObjectClasses: ( 1.1.3 NAME 'testObject'
  MAY ( testAttr $ testTwo ) AUXILIARY )
```

##### olcAttributeTypes: &lt;RFC4512 Attribute Type Description&gt;

이 지시자는 속성 타입을 정의한다. 자세한 사항은 스키마 정의서 부분에서 설명한다.

##### olcObjectClasses: &lt;RFC4512 Object Class Description&gt;

이 지시자는 object class를 정의한다. 자세한 사항은 스키마 정의서 부분에서 설명한다.

#### 백앤드\(Backend\) 관련 지시자

백앤드 지시자는 같은 타입의 모든 데이터베이스 인스턴스들에 적용된다. 그리고 데이터베이스 지시자에 의해 재정의\(overridden\) 될 수 있다. 백앤드 앤트리들은 반드시 _olcBackendConfig_ objectClass를 포함해야 한다.

```
dn: olcBackend=bdb,cn=config
objectClass: olcBackendConfig
olcBackend: bdb
```

OpenLDAP 2.4는 다음과 같은 백앤드 타입을 지원한다:

\[표 3.2\] 지원하는 데이터베이스 백앤드들

| Types | **Description** |
| :--- | :--- |
| bdb | Berkeley DB transactional backend \(deprecated\) |
| config | Slapd configuration backend |
| dnssrv | DNS SRV backend |
| hdb | Hierarchical variant of bdb backend \(deprecated\) |
| ldap | Lightweight Directory Access Protocol \(Proxy\) backend |
| ldif | Lightweight Data Interchange Format backend |
| mdb | Memory-Mapped DB backend |
| meta | Meta Directory backend |
| monitor | Monitor backend |
| passwd | Provides read-only access to_passwd_\(5\) |
| perl | Perl Programmable backend |
| shell | Shell \(extern program\) backend |
| sql | SQL Programmable backend |

#### 데이터베이스 관련 지시자

##### 공통 지시자

다음 지시자들은 모든 데이터베이스가 지원한다. 모든 데이터베이스 엔트리들은 반드시 _olcDatabaseConfig_ objectClass를 포함해야한다.

###### olcDatabase: \[{&lt;index&gt;}\]&lt;type&gt;

특정 데이터베이스 인스턴스 이름을 정의한다.

* {&lt;index&gt;} 숫자는 같은 여러 타입의 데이터베이스를 구별 하기위해 쓰여지며, 일반적으로 생략할 경우, slapd가 자동으로 할당하게된다.
* &lt;type&gt;은 반드시 표 3.2 에 표시되어있는 지원되는 데이터베이스 타입이나 _frontend_ 타입을 지정해야한다.

###### olcAccess: to &lt;what&gt; \[ by &lt;who&gt; \[&lt;accesslevel&gt;\] \[&lt;control&gt;\] \]+

특정 엔트리들 이나 속성들을 요청자들\(requesters\)에게 접근 허락\(grant\)하는데 사용되어진다.  자세한 사항은 Access Control 섹센에서 설명한다.

> 만일 아무런 olcAccess 지시자가 정의되어있지 않을 경우, \* by \* read 가 적용되어진다. 이는 모든 사용자\(익명 포함\)에게 읽기 권한이 주어지는 것이다.
>
> frontend에 정의된 접근 제어들은 다른 모든 데이터베이스에 추가되어진다.

###### olcReadonly { TRUE \| FALSE }

읽기만 가능하도록 데이터베이스를 설정한다.

###### olcRootDN: &lt;DN&gt;

접근 제한 혹은 데이터베이스 관리 제한을 받지않는 DN을 지정하는 지시자이다. 단순히 생각하여 관리자 ID로 보면 된다.

```
olcRootDN: "cn=Manager,dc=example,dc=com"
```

###### olcRootPW: &lt;password&gt;

rootdn의 패스워드를 설정하는데 사용되는 지시자이다. 패스워드는 RFC2307 해시\(hash\) 형태의 패스워드를 사용하거나 plain text 방식을 사용할 수 있다.

> RFC2307 해시 패스워드는 slappasswd 명령을 통하여 생성 가능하다
>
> ```
> slappasswd -h {ssha}
> New password: 
> Re-enter new password: 
> {SSHA}Cd8tC8IsGwjdkKPTzMmG9SyPn6evXxOq
> ```

###### olcSizeLimit: &lt;integer&gt;

검색시 반환할 최대 엔트리 수를 정의한다.

```
olcSizeLimit: 500
```

###### olcSuffix: &lt;dn suffix&gt;

백앤드 데이터베이스에 전달될 LDAP 쿼리의 DN suffix를 지정한다.

아래 예제의 경우 쿼리는 DN 끝에 "dc=example,dc=com"을 백앤드에 전달하게 된다.

```
olcSuffix: "dc=example,dc=com"
```

###### olcSyncrepl

provider parameter에 명시된 마스터 서버로부터 컨텐츠를 복재해올 수 있도록 설정하는데 사용된다.

자세한 사항은 Replication 섹션에서 다루도록 한다.

```
olcSyncrepl: rid=<replica ID>
        provider=ldap[s]://<hostname>[:port]
        [type=refreshOnly|refreshAndPersist]
        [interval=dd:hh:mm:ss]
        [retry=[<retry interval> <# of retries>]+]
        searchbase=<base DN>
        [filter=<filter str>]
        [scope=sub|one|base]
        [attrs=<attr list>]
        [attrsonly]
        [sizelimit=<limit>]
        [timelimit=<limit>]
        [schemachecking=on|off]
        [bindmethod=simple|sasl]
        [binddn=<DN>]
        [saslmech=<mech>]
        [authcid=<identity>]
        [authzid=<identity>]
        [credentials=<passwd>]
        [realm=<realm>]
        [secprops=<properties>]
        [starttls=yes|critical]
        [tls_cert=<file>]
        [tls_key=<file>]
        [tls_cacert=<file>]
        [tls_cacertdir=<path>]
        [tls_reqcert=never|allow|try|demand]
        [tls_cipher_suite=<ciphers>]
        [tls_crlcheck=none|peer|all]
        [logbase=<base DN>]
        [logfilter=<filter str>]
        [syncdata=default|accesslog|changelog]
```

###### olcTimeLimit: &lt;integer&gt;

slapd가 검색 후 응답을 해야할 최대 시간\(초\)을 지정하는 데 사용된다. 만일 요청이 해당 시간에 끝나지 않았다면, 결과에 exceeded timelimit 이 반환되게 된다.

```
olcTimeLimit: 3600
```

##### MDB/BDB/HDB 데이터베이스 지시자

다음 지시자들은 MDB, BDB 그리고 HDB에만 적용가능하다.

###### olcDbDirectory: &lt;directory&gt;

데이터베이스 및 인덱싱 파일이 위치할 디렉토리를 지정하는데 사용된다.

```
olcDbDirectory: /var/lib/ldap
```

###### olcDbCacheSize: &lt;integer&gt;

해당 백앤드 타입의 데이터베이스 인스턴스가 관리하는 인메모리 케시의 엔트리 수를 지정하는데 사용된다.

```
olcDbCachesize: 1000
```

###### olcDbCheckpoing: &lt;kbyte&gt; &lt;min&gt;

얼마나 자주 트랜젝션 로그를 디스크에 쓸것인지를 지정하는데 사용된다.

예를 들어 다음 설정은 1024 kbyte가 쓰여지거나 10분이 지났을 때 Checkpoint가 발생되도록 하는 설정이다.

```
olcDbCheckpoint: 1024 10
```

###### olcDbIndex: {&lt;attrlist&gt;&gt; \| default} \[pres,eq,approx,sub,none\]

어떠한 속성을 인덱싱 할 것인지에 대한 설정으로, 만약 &lt;attrlist&gt; 만 정의될 경우 디폴트 인덱스들만이 관리되어진다. 아래 예의 경우 pres\(ent\), eq\(uality\).

```
olcDbIndex: default pres,eq
olcDbIndex: uid
olcDbIndex: cn,sn pres,eq,sub
olcDbIndex: objectClass eq
```

> sub: substring

### 접근 제어\(Access Control\)

접근제어를 통해 우리는 마치 파일시스템의 파일과 디렉토리에 소유자와 권한을 설정해 주는 것과 같이, OpenLDAP은 접근제어를 통하여 각각의 엔트리\(Entry\)나 속성\(Attribute\)에 접근 권한을 설정할 수 있다. 다음은 접근 정의서\(Access specification\)에서는 각 Access 라인에 대한 일반적 형식을 보여준다.

```
    olcAccess: <access directive>
    <access directive> ::= to <what>
        [by <who> [<access>] [<control>] ]+
    <what> ::= * |
        [dn[.<basic-style>]=<regex> | dn.<scope-style>=<DN>]
        [filter=<ldapfilter>] [attrs=<attrlist>]
    <basic-style> ::= regex | exact
    <scope-style> ::= base | one | subtree | children
    <attrlist> ::= <attr> [val[.<basic-style>]=<regex>] | <attr> , <attrlist>
    <attr> ::= <attrname> | entry | children
    <who> ::= * | [anonymous | users | self
            | dn[.<basic-style>]=<regex> | dn.<scope-style>=<DN>]
        [dnattr=<attrname>]
        [group[/<objectclass>[/<attrname>][.<basic-style>]]=<regex>]
        [peername[.<basic-style>]=<regex>]
        [sockname[.<basic-style>]=<regex>]
        [domain[.<basic-style>]=<regex>]
        [sockurl[.<basic-style>]=<regex>]
        [set=<setspec>]
        [aci=<attrname>]
    <access> ::= [self]{<level>|<priv>}
    <level> ::= none | disclose | auth | compare | search | read | write | manage
    <priv> ::= {=|+|-}{m|w|r|s|c|x|d|0}+
    <control> ::= [stop | continue | break]
```

이것만 보면 정말 어렵게 느껴지니 간단한 예제들을 통하여 설명하도록 한다.

#### 어떤 것\(what\)을 설정 할 것인가?

&lt;what&gt; 파트는 어떤 엔트리나 속성에 접근 제어를 적용할 지에 대한 설정을 할 수 있도록 해준다. 일반적으로 엔트리는 DN과 필터\(filter\)를 통하여 설정되어지는데 다음은 DN을 통하여 접근 대상을 설정하는 방식을 보여준다.

```
    to *
    to dn[.<basic-style>]=<regex>
    to dn.<scope-style>=<DN>
```

* 첫번째 라인: 모든 엔트리 지정
* 두번째 라인: 정규표현식을 통하여 DN 지정
* 세번째 라인: 범위 지정을 통한 DN 지정

DIT가 \[그림3.2\]과 같이 구성되어있을 경우, &lt;what&gt;이 어떻게 구성되어질 수 있는지 대해 확인해 보자.

![](/assets/Selection_005.png)

**\[그림3.2\] 예제 그래프**

**dn.base="ou=people,o=suffix"**

dn.base는 단일 DIT 객체를 가르킨다. 따라서 여기서는 ou=people만 해당되게된다.

![](/assets/Selection_006.png)

**dn.one="ou=people,o=suffix"**

dn.one은 지정된 DIT 객체의 1차 자식 개체를 가르킨다. 따라서 여기서는 ou=people의 자식 노드에 해당되는 uid=kdz,ou=people,o=suffix와  uid=hyc,ou=people,o=suffix 해당되게된다.

![](/assets/Selection_007.png)

**dn.subtree="ou=people,o=suffix"**

dn.subtree는 지정된 DIT 객체 자신을 포함한 모든 하위 자식 개체를 가르킨다. 따라서 여기서는 ou=people 및 하위 모든 자식 노드에 해당된다.

![](/assets/Selection_008.png)

##### dn.children="ou=people,o=suffix"

dn.children은 subtree와 달리 지정된 DIT 객체 자신을 포함하지 않는다는 것을 제외하고는 모든게 동일한다.

![](/assets/Selection_009.png)

##### 필터\(filter\)를 통한 엔트리 선택

위 방법 외에도 필터를 통한 엔트리가 선택될 수 있다.

```
to filter=<ldap filter>
```

```
to dn.one="ou=people,o=suffix" filter=(objectClass=person)
```

\[그림 3.2\]의 형태의 데이터를 가질 경우, 위 코드는 반드시 ou=people DIT가 person objectClass로 정의되어야 한다.

#### 누구\(who\)에게 허용 할 것인가?

&lt;who&gt; 부분은 어떤 _엔티티\(entity\)_에 접근 제어를 허용할 지에 대한 설정이다.

**\[표 3.3\] 접근 엔티티 정의서 **

| **Specifier** | **Entities** |
| :--- | :--- |
|  | 익명 사용자와 인증한 사용자를 포함한 전체 사용자 |
| anonymous | \(인증 받지 않은\) 익명 사용자 |
| users | 인증 받은 사용자 |
| self | 목적 엔트리와 연관된 사용자 |
| dn\[.&lt;basic-style&gt;\]=&lt;regex&gt; | 정규 표현식에 연결되는 사용자 |
| dn.&lt;scope-style&gt;=&lt;DN&gt; | 해당 DN의 scope에 해당되는 사용자 |

#### 어느 정도의 접근을 허용 할 것인가?

&lt;access&gt;는 위에서 정의한 &lt;what&gt;을 &lt;who&gt;에게 어느 정도 단계\(Level\)까지 허용할 것인지에 대한 설정이라 볼 수 있다.

다음 표는 접근 단계를 보여준다. 여기서 상위 단계는 하위 모든단계를 묵시적으로 포함한다.

**\[표 3.4\] 접근 단계**

| **Level** | **Privileges** | **Description** |
| :--- | :--- | :--- |
| none = | 0 | no access |
| disclose = | d | needed for information disclosure on error |
| auth = | dx | needed to authenticate \(bind\) |
| compare = | cdx | needed to compare |
| search = | scdx | needed to apply search filters |
| read = | rscdx | needed to read search results |
| write = | wrscdx | needed to modify/rename |
| manage = | mwrscdx | needed to manage |

#### 접근 제어 예제

다양한 예제를 통하여 접근 제어를 확인해보자

```
olcAccess: to * by * read
```

위 접근 지시자는 모든 사용자에게 읽기 권한을 주는 예이다.

```
olcAccess: to *
   by self write
   by anonymous auth
   by * read
```

위의 경우 자신의 엔트리는 수정할 수 있으며, 익명 사용자경우 엔트리들에 대해 인증을 강제화하고 그외에는 읽을 수 있는 권한을 주는 예이다.

```
olcAccess: to dn.subtree="dc=example,dc=com" attrs=homePhone
    by self write
    by dn.children=dc=example,dc=com" search
    by peername.regex=IP=10\..+ read
olcAccess: to dn.subtree="dc=example,dc=com"
    by self write
    by dn.children="dc=example,dc=com" search
    by anonymous auth
```

위는 우선 순위\(ordering\) 중요성을 보여주는 예제로 homePhone 속성을 제외한 모든 속성을 스스로 변경이 가능하고,  example.com 하위 엔트리들은 검색을 허용지만 그외 사용자는 인증을 받도록 강제화한다. 여기서 homePhone은 엔트리 자신만 변경가능하고 example.com 하위 엔트리들은 검색을 허용하며, 접근 피어\(혹은 클라이언트\)는 반드시 10.0.0.0 네트워크 IP를 가져야한다.

마지막으로 여기서는 생략되어있으나 맨하위 접근 지시자, _by \* none_은 암묵적으로 적용되어지게된다.

#### 접근 제어 디버깅

OpenLDAP의 slapd는 접근 제어 디버깅을 쉽게 할 수 있도록 별도의 디버깅 값을 지정해 놓았다. 본인 경우 다음과 같은 짧은 스크립트를 작성해 놓고 접근 제어를 테스트 하곤 한다.

```
# cat debug_slapd.sh 
#!/bin/bash
systemctl stop slapd
/usr/sbin/slapd -u ldap -h  "ldapi:/// ldaps:///" -d 128
systemctl start slapd
```

테스트 시 위 스크립트를 실행하여 콘솔을 통하여 접근제어가 어떻게 진행되어지는지 확인이 가능하다.

