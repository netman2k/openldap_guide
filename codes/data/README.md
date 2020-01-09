# How to use generate.py

## Install Python 3
<span style="color: red">You need to install Python 3 to run gnerate.py script</span>

## Import python modules

```bash
pip install -r requirements.txt
```

## Edit configuration file 
You could change or create another configuration file.
The conf/env directory contains various configuration files.
The generate.py uses conf/env/dev.yaml by default; otherwise, you run this script with the env option.

## Run


```bash
python generate.py

or 

python generate.py env=prod
```

## Import Data

```bash
WORKING_DIR=<Paste working dir from the output of the script>
ldapadd -D cn=Manager,dc=example,dc=com -W -H ldapi:/// -f $WORKING_DIR/example.com_O.ldif
ldapadd -D cn=Manager,dc=example,dc=com -W -H ldapi:/// -f $WORKING_DIR/example.com_Roles.ldif
ldapadd -D cn=Manager,dc=example,dc=com -W -H ldapi:/// -f $WORKING_DIR/example.com_OUs.ldif
ldapadd -D cn=Manager,dc=example,dc=com -W -H ldapi:/// -f $WORKING_DIR/example.com_Groups.ldif
ldapadd -D cn=Manager,dc=example,dc=com -W -H ldapi:/// -f $WORKING_DIR/example.com_Accounts.ldif
```
