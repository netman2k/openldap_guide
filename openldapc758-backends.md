# OpenLDAP의 기본 설정

본 장에서는 OpenLDAP을 설치하고 기본 설정을 통하여 서비스 준비 상태로 만드는 것을 목표로 한다.

## OpenLDAP 설치 {#openldap설치}

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

## slapd 설정 {#configuratio}

OpenLDAP 패키지를 설치를 완료하게되면, slapd를 설정할 수 있는 준비 상태가 되어진다.

> slapd는 독립 서비스\(standalone service\)를 수행할 수 있도록 해주는 데몬 프로그램이다.

OpenLDAP 2.3 이후 버전에서는 기본적으로 이전 버전까지 사용된 정적 설정 파일을 통한 설정이 아닌, 동적 런타임 설정 엔진\(Dynamic runtime configuration engine\) - slapd-config 을 사용하도록 되어져있다.

> OpenLDAP 2.3 이전에서는 slapd.conf 파일 수정을 통하여 시스템 설정을 진행하였음.  
> 만일 설정이 변경될 경우 데몬 프로그램의 재시작이 필수 불가결이었다.
>
> 자세한 사항은 slapd-config man page를 통해 확인 가능하다. 참고로 기본으로 제공되는 공식 관리자 가이드에서는 설정 방식의 상당 부분이 기존 정적 설정 파일 방식만 보여줄 뿐, 동적 런타임 설정 방법은 빠져있다. 따라서 가급적 man page 활용을 할 수 있도록 한다.

slapd-config는 다음과 같은 특징을 가진다:

* 표준 LDAP 동작들\(operations\)을 통하여 관리
* 설정 데이터를 LDIF 데이터베이스에 저장, 일반적으로 /etc/openldap/slapd.d 혹은 /usr/local/etc/openldap/slapd.d 디렉토리에 위치
* 서비스 재시작 없이, 즉시\(On the fly\) 설정 변경을 가능케 함



