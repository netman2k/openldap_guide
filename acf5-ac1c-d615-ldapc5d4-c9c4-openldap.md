# 3. 공개형 LDAP엔진 OpenLDAP {#LDAP의모든것2-공개형LDAP엔진OpenLDAP}

## OpenLDAP에 대한 간단한 소개 {#LDAP의모든것2-OpenLDAP에대한간단한소개}

OpenLDAP는 LDAP의 전신이라고 할수 있는 Umich\(미시건대학\) LDAP 3.3을 기반으로 새로이 만든 LDAP프로젝트의 산물이다. 오픈소스 정책을 따르면서도 상용 LDAP서버 못지 않은 응용프로그램들과 서버툴들을 제공하겠다는 목적아래 인터넷의 많은 개발자들이 자원해서 이 프로젝트를 돕고 있다.

현재 OpenLDAP는 2.4.x 버전의 안정버전을 내놓고 있다. 1.2.x버전의 경우 LDAP v2 표준을 지원하는 반면 2.x 버전은 LDAP v3 표준을 기반으로 만들어졌다.

## LDAPv2 와 LDAPv3의 차이점 {#LDAP의모든것2-LDAPv2와LDAPv3의차이점}

LDAPv3는 LDAP 2를 대체하기 위해 1990에 개발되었으며 다음과 같은 기능들이 추가되었다:

* 강력한 인증 및 SASL을 통한 데이터 보안 서비스
* 인증서기반 인증 및 TLS\(SSL\)을 통한 데이터 보안 서비스
* 유니코드\(Unicode\)를 통한 국제화\(Internationalization\)
* Referrals and Continuations
* Schema Discovery
* 확장성 \(controls, extended operations, and more\)

## OpenLDAP 설치

본 가이드는 CentOS 7.X 를 기본 OS로 사용하며, 기본적으로 제공하는 OpenLDAP 패키지를 사용할 것이다. 만일 다른 OS 플랫폼을 사용하거나 본 가이드와 맞지 않는 경우, 공식 관리자 가이드의 [4. Building and Installing OpenLDAP Software](http://www.openldap.org/doc/admin24/install.html) 참고하도록 한다.

```
# yum install openldap-servers
```

테스트 시 사용된 버전은 다음과 같다

```
# cat /etc/redhat-release 
CentOS Linux release 7.3.1611 (Core)

# rpm -qa|grep openldap
openldap-2.4.40-13.el7.x86_64
openldap-clients-2.4.40-13.el7.x86_64
openldap-servers-2.4.40-13.el7.x86_64
openldap-devel-2.4.40-13.el7.x86_64
```

## slapd 설정

OpenLDAP 패키지를 설치를 완료하게되면, slapd[^1]를 설정할 수 있는 준비 상태가 되어진다.

OpenLDAP 2.3 이후 버전에서는 기본적으로 이전 버전까지 사용된 정적 설정 파일[^2]을 통한 설정이 아닌, 동적 런타임 설정 엔진\(Dynamic runtime configuration engine\) - slapd-config[^3] 을 사용하도록 되어져있다.

slapd-config는 다음과 같은 특징을 가진다:

* 표준 LDAP 동작들\(operations\)을 통하여 관리
* 설정 데이터를 LDIF 데이터베이스에 저장, 일반적으로 /etc/openldap/slapd.d 혹은 /usr/local/etc/openldap/slapd.d 디렉토리에 위치
* 서비스 재시작 없이, 즉시\(On the fly\) 설정 변경을 가능케 함

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

**\[표 3-1\] 디버깅\(Debuggin\) 로그 레벨**

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

이 엔트리는 slapd에 하드코딩되어진 모든 스키마 정의들을 가지고 있다.  사용자 정의 스키마 경우 이 엔트리 하위에 위치하게 되며, 스키마 엔트리는 반드시 _olcSchemaConfig_ objectClass를 포함해야 한다.

##### olcAttributeTypes: &lt;RFC4512 Attribute Type Description&gt;

이 지시자는 속성 타입을 정의한다. 자세한 사항은 스키마 정의서 부분에서 설명한다.

##### olcObjectClasses: &lt;RFC4512 Object Class Description&gt;

이 지시자는 object class를 정의한다. 자세한 사항은 스키마 정의서 부분에서 설명한다.





[^1]: slapd는 독립 서비스\(standalone service\)를 수행할 수 있도록 해주는 데몬 프로그램이다.

[^2]: 기존 버전은 slapd.conf 파일 수정을 통하여 시스템 설정을 진행하였음. 만일 설정이 변경될 경우 데몬 프로그램의 재시작이 필수 불가결이었다.

[^3]: 자세한 사항은 slapd-config man page를 통해 확인 가능하다. 참고로 기본으로 제공되는 공식 관리자 가이드에서는 설정 방식의 상당 부분이 기존 정적 설정 파일 방식만 보여줄 뿐, 동적 런타임 설정 방법은 빠져있다. 따라서 가급적 man page 활용을 할 수 있도록 한다.

