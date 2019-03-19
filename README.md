# SAP Data Hub on SUSE CaaS Platform and SUSE Enterprise Server 2019 PoC
SAP Data Hub on SUSE CaaS and SES5

change /etc/hosts
192.168.20.254 master
to
192.168.20.254 master.sdh.suse.ru master

Shutt-off firewall at install SES

## DNS + DHCP + NTP Install

## SMT Install
```bash
sudo zypper in -t pattern smt

for REPO in SLES12-SP3-{Pool,Updates} SUSE-Enterprise-Storage-5-{Pool,Updates} SUSE-CAASP-3.0-{Pool,Updates}; do
  smt-repos $REPO sle-12-x86_64 -e
done

smt-mirror -L /var/log/smt/smt-mirror.log
```

```bash
mkdir -p /srv/www/htdocs/repo/SUSE/Install/SLE-SERVER/12-SP3
mkdir -p /srv/www/htdocs/repo/SUSE/Install/SUSE-CAASP/3.0
mkdir -p /srv/www/htdocs/repo/SUSE/Install/Storage/5

mkdir -p /srv/tftpboot/sle12sp3
mkdir -p /srv/tftpboot/caasp


mount SLE-12-SP3-Server-DVD-x86_64-GM-DVD1.iso /mnt
rsync -avP /mnt/ /srv/www/htdocs/repo/SUSE/Install/SLE-SERVER/12-SP3/x86_64/
cp /mnt/boot/x86_64/loader/{linux,initrd} /srv/tftpboot/sle12sp3/
umount /mnt

mount SUSE-Enterprise-Storage-5-DVD-x86_64-GM-DVD1.iso /mnt
rsync -avP /mnt/ /srv/www/htdocs/repo/SUSE/Install/Storage/5/x86_64/
umount /mnt

mount SUSE-CaaS-Platform-3.0-DVD-x86_64-GM-DVD1.iso /mnt
rsync -avP /mnt/ /srv/www/htdocs/repo/SUSE/Install/SUSE-CAASP/3.0/x86_64/
cp /mnt/boot/x86_64/loader/{linux,initrd} /srv/tftpboot/caasp/
umount /mnt
```

## AutoYast Fingerprint
```bash
openssl x509 -noout -fingerprint -sha256 -inform pem -in /srv/www/htdocs/smt.crt
```

# Install CaaS

## Add to AutoYaST

`# openssl x509 -noout -fingerprint -sha256 -inform pem -in /srv/www/htdocs/smt.crt`

to `<suse_register>`

`<reg_server>https://smt.sdh.suse.ru</reg_server>
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

