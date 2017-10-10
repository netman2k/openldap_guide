# 2. LDAP란 무엇인가?

## Directory Service와 Lightweight Directory Access Protocol\(LDAP\)

LDAP란 무엇일까? Lightweight Directory Access Protocol이라는 말인데 우리말로 하면 '경량의 디렉토리 액세스 프로토콜'이라는 말이 된다. 그럼 디렉토리\(Directory\)란 무엇일까? 디렉토리란 특별한 형태의 데이터베이스라고 할 수가 있다. 그리고 쓰기 작업보다 읽기 작업이 더 많을 뿐 아니라 어떤 것을 찾는 작업이 많은 곳에 더더욱 적합한 서비스라고 할 수가 있다.

현재로부터 시간을 조금 거슬러 올라가서 1980년대 말에 특정분야의 디렉토리 서비스의 이용,개발 요구가 높아감에 따라 CCITT\(International Telegraph and Telephone Consultative Committee, 현재 ITU\)와 ISO\(International Organization for Standardization\) 두 단체가 함께 X.500이라는 디렉토리 서비스 표준을 만들기 시작하였다. 결국 1990년에 CCITT가 표준을 발표했고 1993년, 1997년 몇번의 수정작업을 거쳐 현재에 이르렀다. 이 X.500은 최초의 일반적인 목적의 디렉토리 시스템이었고 다양한 쿼리를 사용하는 강력한 검색기능을 제공하였을 뿐만 아니라 서버와 데이터의 분산이 용이했고 그리고 무엇보다도 특정 운영체제나 특정 네트웍,특정 응용프로그램에 구애받지 않고 사용될 수 있는 표준이라는 점이 눈길을 끌 수 있었다.

하지만 X.500 개발자들은 DAP\(X.500의 directory client access protocol\)가 너무 방대한데다 복잡하고 구현하기 어렵다는 점 때문에 그당시의 일반 PC급에서는 적용해서 사용하기가 힘들다는걸 알았고 이의 해결책을 모색하기 시작했고 그렇게 해서 나온 것이 LDAP이다. LDAP는 DAP의 기능을 거의 다 지원을 했고 복잡했던 부분이나 잘 쓰이지 않았던 부분은 단순화하거나 없애버렸다. 그리고 대부분의 데이터 형식에 있어서 단순한 문자열을 사용하므로써 구현을 단순화하고 퍼포먼스를 늘릴수가 있었다. 이렇게 LDAP는 처음에 X.500 디렉토리 서비스의 프론트엔드로 사용되었다. 그후 최초이면서 많이 알려진 미시건대학의 LDAP\(U-M LDAP\)가 나오게되었고 현재 많은 상용 또는 오픈소스의 LDAP제품들이 나와있다.

## LDAP 들여다 보기 {#LDAP의모든것2-LDAP들여다보기}

![](/assets/image001.jpg)

**\[그림 1\] 파일 시스템에서의 간단한 디렉토리의 구조의 예**

![](/assets/image002.jpg)

**\[그림 2\] LDAP에서의 간단한 디렉토리의 구조의 예**

위 두 그림들은 파일 시스템의 구조와 LDAP 디렉토리 구조의 대표적인 예를 보여준다. 이러한 LDAP 디렉토리 트리 구조를 특별히 _DIT\(Directory Information Tree\)_라고 부른다. LDAP 트리\(Tree\) 구조에서 각 노드들을 _엔트리\(Entry\)_라고 부르고 엔트리는 LDAP에서 하나의 데이터를 나타낸다. RDBMS와 비교를 한다면 하나의 레코드와 일치한다고 할수 있다. 모든 엔트리는 그 자신의 위치와 고유성을 나타내는 _DN\(Distinguished Name\)_으로 구분된다. 이는 마치 파일 시스템에서의 디렉토리 구조를 보면서 "최상위에 루트디렉토리가 있고 그 아래에 /usr 디렉토리와 /home 디렉토리가 있고 /usr 디렉토리 아래에는 /usr/local 과 /usr/src 두개의 디렉토리가 있고 등등등..."으로 말할 수가 있는 것 처럼 위의 LDAP 디렉토리 구조 그림에서 트리 구조의 최상위 DN은 dc=database,dc=sarang,dc=net 이고 이 엔트리의 아래에 두개의 엔트리가 존재한다. 이 두개의 엔트리의 DN은 각각 ou=people, dc=database, dc=sarang, dc=net 과 ou=manager, dc=database, dc=sarang, dc=net 이다. 이것은 우리가 파일시스템을 읽을 때 하위 디렉토리로 내려갈수록 /usr/local/bin과 같이 오른쪽으로 붙여나가는 방식과는 반대로 하위 엔트리로 내려갈수록 왼쪽으로 붙여나가는 방식이다. 그리고 위 예제의 구조를 보면 "데이터베이스 사랑넷에 people\(사람들\) 그룹과 manager\(관리자\) 그룹으로 나뉘고 관리자 그룹에는 유저 아이디가 advance라는 관리자가 한명 있으며 사람들 그룹아래로는 member\(회원\)그룹과 guest\(손님\)그룹이 존재한다." 라는 식으로 이해를 할수 있겠다. 이제 엔트리,DN 이라는 것에 대해 이해를 했을것이다.

위의 DIT 그림 2에서 각각의 엔트리의 위치를 나타내는 전체 DN이 아니라 단지 ou=people과 같은 앞부분만 써놓았는데 이것을 _Relative Distinguished Name_. 즉, _RDN_이라고 한다. 파일 시스템 디렉토리 구조에서 절대 패스, 상대 패스가 있는것과 같이 LDAP도 DN,RDN으로 \(굳이 우리말로 하면 절대 DN, 상대 DN정도로 표현하면 될까?\) 나타낼수 있다. 이제 엔트리에 대해서 좀더 자세히 보기로 하자.

**\[표 1\] 엔트리 예**

| Attribute Type | Attribute Value |
| :--- | :--- |
| cn | Barbara Jensen Babs Jensen |
| sn | Jensen |
| mail | babs@foo.bar.com |
| telephonenumber | +1 408 555 1212 |

위의 표는 하나의 엔트리를 나타낸 예이다. 하나의 엔트리는 마치 RDBMS의 필드처럼 _attribute\(속성\)_들을 가지고 이러한 attribute의 값들은 RDBMS의 하나의 필드값과는 다르게 하나 이상의 값을 가질수가 있다. 위이 예에서 _cn_이란 _common name_을, _sn_은 _sirname_을 각각 대표한다. _organization unit_을 _ou_라고 쓰는 것 처럼 왜 그러면 이렇게 줄여서 사용하는 것일까? 이유는 _ou\(organization unit\), o\(organization\), c\(country\), cn\(common name\)_과 같이 dn에 쓰이는 attribute들은 보다 간결한 dn을 위해서 축약이 될 필요가 있어서 이다.

한가지 설명에서 빠진 것이 있는데 바로 objectclass이다. 모든 엔트리는 한가지 이상의 obejctclass에 속하게 되며 objectclass의 정의대로 attribute를 가지게 된다. 쉽게 비유를 하자면 objectclass란 붕어빵을 찍어내는 붕어빵 틀과 같다고 할 수가 있겠다. 붕어빵틀에 생긴대로 붕어빵이 나오듯이 우리가 objectclass를 정의한대로 엔트리가 생성되는 것이다. 이러한 objectclass에 대해서 좀더 자세한 이해를 하여야 할 필요가 있는데 지금 당장 알고 싶은 분은 'LDAP 스키마 작성'섹션을 지금 읽어보아도 좋다.

다음 그림은 전형적인 LDAP의 구조를 엔트리 내용을 좀더 자세히 해서 보여주는 예이다.

![](/assets/image003.jpg)

**\[그림 3\] 좀더 자세히 그린 엔트리와 LDAP디렉토리 구조**

