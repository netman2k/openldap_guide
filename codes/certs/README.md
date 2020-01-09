# How to create Self-signed certificate for OpenLDAP

## Create openssl.cnf

```bash
cat <<'EOF' > openssl.cnf
[req]
default_bits       = 4096
distinguished_name = req_distinguished_name
req_extensions     = req_ext

[ req_distinguished_name ]
countryName                 = Country Name (2 letter code)
countryName_default         = KR

localityName                = Locality Name (eg, city)
localityName_default        = Seoul

organizationName            = Organization Name (eg, company)
organizationName_default    = Example

commonName                  = Common Name (e.g. server FQDN or YOUR name)
commonName_default          = localhost
commonName_max              = 64

[ req_ext ]
subjectAltName = ${ENV::SAN}
EOF
```

## Generate Root CA certificate

```bash
openssl genrsa -out root-ca-key.pem 4096
openssl req -new -x509 -days 3650 -sha256 -key root-ca-key.pem -out root-ca.pem -subj "/C=KR/L=Seoul/O=Example/CN=ROOT CA"
```

## Generate Host certificate

* Set environment variable

```bash
HOST="ker001.example.com"
SAN="DNS:kerberos1.example.com,DNS:kerberos.example.com"
```
> The certificate will have another subject name via SAN environment variable
> In this case, generated certificate can serve kerberos1.example.com and kerberos.example.com as well

* Generate certificate

```bash
openssl genrsa -out $HOST-key.pem 4096
openssl req -new -key $HOST-key.pem -out $HOST.csr -config openssl.cnf -subj "/C=KR/L=Seoul/O=Example/CN=$HOST" 
openssl x509 -req -days 3650 -in $HOST.csr -CA root-ca.pem -CAkey root-ca-key.pem -CAcreateserial -sha256 -extensions req_ext -extfile openssl.cnf -out $HOST.pem
```

* Check

```bash
openssl x509 -noout -text -in $HOST.pem
```

## Bulk creation
```bash
HOSTS=(ker001.example.com ker002.example.com ker003.example.com)
```
```bash
for host in "${HOSTS[@]}";do
  # Extract only hostname not FQDN
  S_HOSTNAME=${host/.example.com/}
  # Extract sequence number only
  SEQ=${S_HOSTNAME:$((${#S_HOSTNAME}-1))}
  # Set Alternative DNS name
  export SAN="DNS:kerberos${SEQ}.example.com,DNS:kerberos.example.com"
  openssl genrsa -out $host-key.pem 4096
  openssl req -new -key $host-key.pem -out $host.csr -config openssl.cnf -subj "/C=KR/L=Seoul/O=Example/CN=$host"
  openssl x509 -req -days 3650 -in $host.csr -CA root-ca.pem -CAkey root-ca-key.pem -CAcreateserial -sha256 -extensions req_ext -extfile openssl.cnf -out $host.pem
  rm -f $host.csr
done
```

