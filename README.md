# SAP Data Hub on SUSE CaaS Platform and SUSE Enterprise Server 2019 PoC
SAP Data Hub on SUSE CaaS and SES5

## DNS + DHCP + NTP Install

## SMT Install
```bash
sudo zypper in -t pattern smt

for REPO in SLES12-SP3-{Pool,Updates} SUSE-Enterprise-Storage-5-{Pool,Updates} SUSE-CAASP-ALL-{Pool,Updates}; do
  smt-repos $REPO sle-12-x86_64 -e
done

smt-mirror -L /var/log/smt/smt-mirror.log
```

## AutoYast Fingerprint
```bash
openssl x509 -noout -fingerprint -sha256 -inform pem -in /srv/www/htdocs/smt.crt
```

# Install CaaS

## Add to AutoYaST

`# openssl x509 -noout -fingerprint -sha256 -inform pem -in /srv/www/htdocs/smt.crt`

to `<suse_register>`

`<reg_server>https://router.caasp.novell-cis.ru</reg_server>
 <reg_server_cert_fingerprint_type>SHA256</reg_server_cert_fingerprint_type>
 <reg_server_cert_fingerprint>76:9E:14:87:0F:3E:02:49:34:8C:E4:6C:DA:5B:7F:1A:9C:F3:64:BF:C8:E9:B2:21:E3:B4:B8:4F:D5:03:69:BB</reg_server_cert_fingerprint>`

to `<services>`

`<service>vmtoolsd</service>`

to `<software>`
 
`<packages config:type="list">
      <packages>open-vm-tools</packages>
    </packages>`

## SUSE Enterprise Storage 5 Documentation
https://www.suse.com/documentation/suse-enterprise-storage-5/

## SUSE CaaS Platform 3 Documentation
https://www.suse.com/documentation/suse-caasp-3/index.html

