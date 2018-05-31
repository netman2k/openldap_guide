## OpenLDAP의 고급 설정

### SHA2 암호 사용
LDAP 암호는 일반적으로 [RFC4519](http://www.rfc-editor.org/rfc/rfc4519.txt)::2.41. userPassword 명세에 따라 암호화 되지 않은 8비트 문자를 사용하도록 되어있다. 이 느슨한 명세로 인해 다양한 암호 인증 방식을 지원한다는데 의미를 둘 수 있는데, 문제는 OpenLDAP 서버가 Salted SHA1(SSHA) 를 기본 사용하도록 설정되어있다는데 있다. 이제 이를 SHA2를 사용하여 보안성을 높이도록 하자

> 참조: [Password Storage](http://www.openldap.org/doc/admin24/guide.html#Password%20Storage)

**모듈 확인**

요즘 대부분의 배포본에서 제공하는 OpenLDAP 서버 패키지에는 이미 SHA2용 모듈이 포함되어있다. 이 모듈은 pw-sha2.la 라는 이름을 갖는데 CentOS 7에서 확인한 결과는 다음과 같다.

```bash
[root@master1 openldap-servers]# rpm -ql openldap-servers |grep pw-sha2.la
/usr/lib64/openldap/pw-sha2.la
```

**모듈 로드**

TODO

```

```

> 참조: [Planning of LDAP DIT Structure and Config of Overlays ( access, ppolicy )](https://devopsideas.com/planning-of-ldap-dit-structure-and-config-of-overlays-access-ppolicy/)









