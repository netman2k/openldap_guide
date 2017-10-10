# 공개형 LDAP엔진 OpenLDAP {#LDAP의모든것2-공개형LDAP엔진OpenLDAP}

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

# OpenLDAP 설치

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

# slapd 설정

OpenLDAP 패키지를 설치를 완료하게되면, slapd[^1]를 설정할 수 있는 준비 상태가 되어진다.

OpenLDAP 2.3 이후 버전에서는 기본적으로 이전 버전까지 사용된 정적 설정 파일[^2]을 통한 설정이 아닌, 동적 런타임 설정 엔진\(Dynamic runtime configuration engine\)을 사용하도록 되어져있다.

## 설정 구조\(Configuration Layout\)

slapd 설정은 미리 정의된 스키마\(schema\)와 DIT를 통해 특수한 LDAP 디렉터리에 저장이 되도록 되어있다. 또한 전역\(global\) 설정 옵션, 스키마 정의, 백앤드와 데이터베이스 정의 그리고 이와 연관되어지는 다른 아이템들을 지니기 위해 특정 objectClass가 사용되어진다.

## ![](/assets/config_dit.png) 

**\[그림 4\] 설정 트리 예**



[^1]: slapd는 독립 서비스\(standalone service\)를 수행할 수 있도록 해주는 데몬 프로그램이다.

[^2]: 기존 버전은 slapd.conf 파일 수정을 통하여 시스템 설정을 진행하였음. 만일 설정이 변경될 경우 데몬 프로그램의 재시작이 필수 불가결이었다.

