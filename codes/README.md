# About
## (Optional) Init VMs
> This section can be done if you are willing to test these configs

* Install Plugin
```bash
vagrant plugin install vagrant-hostmanager
```

* Bring up masters

```bash
vagrant up
```

* Access VM via SSH
```bash
vagrant ssh <master1 or master2 or master3>
```
* Access the codes
```bash
[vagrant@ker001 ~]$ sudo su -
[root@ker001 ~]# cd /vagrant/
```

## Initialize OpenLDAP Server

> Run this command on <b style="color: red">every master!</b>

* Reset OpenLDAP server
```bash
./reset.sh
```

## Initialize master OpenLDAP server

> Run this command on <b style="color: red">every master!</b>

```bash
bash master_init.sh
```

## N-Way Multi-Master replication 

### Generate LDIF files for SyncRepl

> Run this command on <b style="color: red">every master!</b>
> or copy generated ldifs from a server first run this command

```bash
N-Way/gen_ldif.sh 
```
<pre>
How many masters do you want to create? <b>3</b>
Enter the credential of cn=config: 
Enter the DN of the backend to set syncrepl (default: olcDatabase={3}mdb,cn=config): 
Enter the BaseDN of the backend to set syncrepl (default: dc=example,dc=com): 
Enter the BindDN for syncrepl (default: cn=Replicator,dc=example,dc=com): 
Enter the credential of Backend BindDN: 
Enter the URL of ServerID 1 (i.e., ldaps://ker001.example.com): <b>ldaps://ker001.example.com</b>
Enter the URL of ServerID 2 (i.e., ldaps://ker002.example.com): <b>ldaps://ker002.example.com</b>
Enter the URL of ServerID 3 (i.e., ldaps://ker003.example.com): <b>ldaps://ker003.example.com</b>
Create a LDIF file...

Creating is done...

1. Run the below command on every master...
ldapmodify -Y EXTERNAL -H ldapi:/// -f /tmp/cn_config_syncrepl.ldif

2. Run the below command on every master...
ldapmodify -Y EXTERNAL -H ldapi:/// -f /tmp/backend_syncrepl.ldif

3. Accommodate your data on first master only!!!...

</pre>
### Set SyncRepl on cn=config

> Run this command on <b style="color: red">every master!</b>

```bash
ldapmodify -Y EXTERNAL -H ldapi:/// -f /tmp/cn_config_syncrepl.ldif
```

### Set SyncRepl on backend database

> Now you have a N-Way master OpenLDAP Cluster
> Run this command on <b style="color: red">every master!</b>


Still, you need to set the backend to replicate actual data
Every entry of the backend will be in sync after running this command

```bash
ldapmodify -Y EXTERNAL -H ldapi:/// -f /tmp/backend_syncrepl.ldif
```


### Accommodate data

> Run this command on <b style="color: red">first master only!</b>

```bash
cd data
./import.sh
```


### Retrieve and check entry count from each masters

```bash
ldapsearch -b dc=example,dc=com -D cn=Manager,dc=example,dc=com -W -H ldaps://ker001.example.com dn | grep '# numEntries'
ldapsearch -b dc=example,dc=com -D cn=Manager,dc=example,dc=com -W -H ldaps://ker002.example.com dn | grep '# numEntries'
ldapsearch -b dc=example,dc=com -D cn=Manager,dc=example,dc=com -W -H ldaps://ker003.example.com dn | grep '# numEntries'
```
