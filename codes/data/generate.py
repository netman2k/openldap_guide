#!/usr/bin/env python
import hydra
import types
import os
import random
import logging
from faker import Faker
from pySSHA import ssha
from collections import OrderedDict

# A logger for this file
log = logging.getLogger(__name__)

groups_ou = {}

@hydra.main(config_path='conf/config.yaml')
def main(cfg):
    #log.info(cfg.pretty())
    log.info(f"Working dir: {os.getcwd()}")

    # Create a file contain Organization
    f = open(f'{cfg.organization.o}_O.ldif', 'w')
    create_org(f, cfg.organization)
    log.info(f"Generated: {f.name}")
    f.close()

    # Create a file contain Org. Roles
    f = open(f'{cfg.organization.o}_Roles.ldif', 'w')
    create_org_roles(f, cfg.organization.dn, cfg.organizational_roles)
    f.close()
    log.info(f"Generated: {f.name}")

    # Create a file contain Org. Units
    f = open(f'{cfg.organization.o}_OUs.ldif', 'w')
    create_org_units(f, cfg.organization.dn, cfg.organizational_units)
    f.close()
    log.info(f"Generated: {f.name}")

    # Create a file contain groups
    f = open(f'{cfg.organization.o}_Groups.ldif', 'w')
    create_groups(f, cfg.organization.dn, cfg.groups)
    f.close()
    log.info(f"Generated: {f.name}")

    # Create a file contain accounts
    f = open(f'{cfg.organization.o}_Accounts.ldif', 'w')
    create_persons(f, cfg.organization.dn, cfg.organizational_persons)

    if cfg.enable_auto_generation:
        group_table = generate_fake_persons(f, cfg.organization.dn,
            cfg.auto_generation_options)
    f.close()
    log.info(f"Generated: {f.name}")

    # Create a file for adding accounts into the specific groups
    f = open(f'{cfg.organization.o}_memberof.ldif', 'w')
    f.write("# Assign members to one of the groups\n")
    for gid in groups_ou.keys():
        group_dn = groups_ou[gid]["dn"]
        f.write(f"dn: {group_dn}\n")
        f.write("changetype: modify\n")
        f.write("add: member\n")
        for member in groups_ou[gid]["members"]:
            f.write(f"member: {member}\n")
        f.write("\n")
    f.close()
    log.info(f"Generated: {f.name}")

def generate_salted_password(password, encode="ssha512"):
    return ssha.hashPassword(encode, password)

def create_org(f, org):
    f.write("# Organization\n")
    f.write(f"dn: {org.dn}\n")
    f.write("objectClass: top\n")
    f.write("objectClass: dcObject\n")
    f.write("objectClass: organization\n")
    f.write(f"dc: {org.dc}\n")
    f.write(f"o: {org.o}\n")
    f.write("\n")

def create_org_roles(f, base_dn,roles):
    f.write("# Organizational Roles\n")
    for role in roles:
        f.write(f"dn: cn={role.cn},{base_dn}\n")
        f.write("objectClass: top\n")
        f.write("objectClass: organizationalRole\n")
        f.write(f"cn: {role.cn}\n")
    f.write("\n")

def create_org_units(f, base_dn, o_units):
    f.write("# Organizational Units\n")
    for ou in o_units:
        dn = f"ou={ou},{base_dn}"
        f.write(f"dn: {dn}\n")
        f.write(f"ou: {ou}\n")
        f.write("objectClass: top\n")
        f.write("objectClass: organizationalUnit\n\n")

def create_groups(f, base_dn, groups):
    f.write("# Groups\n")
    for group in groups:
        dn = f"cn={group.cn},{group.parent_ou},{base_dn}"
        f.write(f"dn: {dn}\n")
        f.write(f"cn: {group.cn}\n")
        f.write(f"gidNumber: {group.gid}\n")
        f.write("objectClass: top\n")
        for oc in group.objectclasses:
            f.write(f"objectClass: {oc}\n")
        for member in group.members:
            f.write(f"member: {member},{base_dn}\n")
        f.write("\n")
        groups_ou[group.gid] = { "dn": dn, "members": set([]) }
    f.write("\n")

def create_persons(f, base_dn, persons):
    f.write("# Persons\n")

    for person in persons:
        cn = sn = person.cn
        create_person(f,
            base_dn=base_dn,
            cn=cn,
            sn=cn,
            uid_number=None,gid_number=None,
            password=person.password,
            parent_ou=None,
            objectclasses=person.objectclasses)

def create_person(f, base_dn, cn, sn, uid_number, gid_number, password, parent_ou,
    shadow_max=60, shadow_min=7, shadow_warn=10,
    shadow_inactive=-1, shadow_expire=-1,
    login_shell="/bin/bash", home=None,
    gecos=None, email=None,
    objectclasses=["posixAccount","shadowAccount"]):

    if "organizationalPerson" in objectclasses:
        if parent_ou is not None:
            f.write(f"dn: cn={cn},{parent_ou},{base_dn}\n")
        else:
            f.write(f"dn: cn={cn},{base_dn}\n")

        f.write("objectClass: top\n")
        f.write("objectClass: organizationalPerson\n")
        f.write(f"cn: {cn}\n")
        f.write(f"sn: {cn}\n")
        salted_password = generate_salted_password(password)
        f.write(f"# Password: {password}\n")
        f.write(f"userPassword: {salted_password}\n")
    else:
        if parent_ou is not None:
            parent_ou = "ou=People"

        dn = f"uid={cn},{parent_ou},{base_dn}"
        f.write(f"dn: {dn}\n")
        f.write("objectClass: top\n")
        for oc in objectclasses:
            f.write(f"objectClass: {oc}\n")
        f.write(f"uid: {cn}\n")
        f.write(f"uidNumber: {uid_number}\n")
        f.write(f"gidNumber: {gid_number}\n")
        f.write(f"cn: {cn}\n")
        f.write(f"sn: {sn}\n")
        f.write(f"homeDirectory: {home}\n")
        salted_password = generate_salted_password(password)
        f.write(f"# Password: {password}\n")
        f.write(f"userPassword: {salted_password}\n")
        f.write(f"shadowMax: {shadow_max}\n")
        f.write(f"shadowMin: {shadow_min}\n")
        f.write(f"shadowWarning: {shadow_warn}\n")
        f.write(f"shadowInactive: {shadow_inactive}\n")
        f.write(f"shadowExpire: {shadow_expire}\n")
        f.write(f"loginShell: {login_shell}\n")
        if gecos is not None:
            f.write(f"gecos: {gecos}\n")
        if email is not None:
            f.write(f"mail: {email}\n")
        # Save account DN in the group table
        groups_ou[gid_number]['members'].add(dn)

    f.write("\n")


def generate_fake_persons(f, base_dn, options={}):
    fake = Faker(['en_US'])
    count = options.num_of_persons
    password_postfix = options.password_postfix
    min_uid = options.start_uid
    for i in range(0, count):
        f.write(f"# Generated Person {i+1}\n")
        sn = fake.last_name()
        cn = f"{fake.first_name()}.{sn}".lower()
        password = f"{cn}{password_postfix}"
        uid = min_uid+i
        gid = random.sample(list(options.gids),1)[0]
        gecos = f"{fake.country_code(representation='alpha-2')}{uid}"
        email = None
        home = f"{options.homedir_prefix}/{cn}"
        if options.gen_email:
            email = fake.safe_email()
        create_person(f,
            base_dn=base_dn,
            cn=cn,
            sn=sn,
            uid_number=uid,
            gid_number=gid,
            home=home,
            password=password,
            parent_ou=options.parent_ou,
            objectclasses=options.objectclasses,
            shadow_max=options.shadow_max,
            shadow_min=options.shadow_min,
            shadow_warn=options.shadow_warn,
            shadow_inactive=options.shadow_inactive,
            email=email,
            gecos=gecos)

if __name__ == "__main__":
    main()
