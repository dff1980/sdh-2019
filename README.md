# sdh-2019
SAP Data Hub on SUSE CaaS and SES5

## SUSE Enterprise Storage 5 Documentation
https://www.suse.com/documentation/suse-enterprise-storage-5/

`sudo zypper in -t pattern smt`

`for REPO in SLES12-SP3-{Pool,Updates} SUSE-Enterprise-Storage-5-{Pool,Updates} SUSE-CAASP-ALL-{Pool,Updates}; do
  smt-repos $REPO sle-12-x86_64 -e
done`

## AutoYast Fingerprint
 `cat /srv/www/htdocs/smt.crt | openssl x509 -noout -fingerprint -sha256`

## SUSE CaaS Platform 3 Documentation
https://www.suse.com/documentation/suse-caasp-3/index.html
