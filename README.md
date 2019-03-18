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
cat /srv/www/htdocs/smt.crt | openssl x509 -noout -fingerprint -sha256
```
## SUSE Enterprise Storage 5 Documentation
https://www.suse.com/documentation/suse-enterprise-storage-5/

## SUSE CaaS Platform 3 Documentation
https://www.suse.com/documentation/suse-caasp-3/index.html
