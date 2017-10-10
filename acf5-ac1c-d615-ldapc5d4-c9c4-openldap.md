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

# OpenLDAP 설정

CentOS 7 에서 제공하는 패키지를 통하여 설치하였을 경우, 다음과 같은 디렉토리에



