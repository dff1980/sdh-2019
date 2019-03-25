# SAP Data Hub on SUSE CaaS Platform and SUSE Enterprise Server 2019 PoC

This project is PoC installation SAP Data Hub on SUSE CaaS Platform and SUSE Enterprise Server.

Using version:
- SUSE CaaSP 3
- SES 5
- SLES 12 SP3

This document currently in development state. Any comments and additions are welcome.
If you need some additional information about it please contact with Pavel Zhukov (pavel.zhukov@suse.com).


###### Disclamer
###### _At the moment, no one is responsible if you try to use the information below for productive installations or commercial purposes._

## PoC Landscape
PoC can be deployed in any virtualization environment or on hardware server.
Currently PoC hosted on VmWare VSphere.

## Requarments

### Tech Specs
- 1 dedicated infrastructure server ( DNS, DHCP, PXE, NTP, NAT, SMT, TFTP, SES admin, console for SAP Data Hub admin)
  16GB RAM
  1 x HDD - 1TB
  1 LAN adapter
  1 WAN adapter

- 4 x SES Servers
    16GB RAM
    1 x HDD (System) - 100GB
    3 x HDD (Data) - 1 TB
    1 LAN

- 5 x CaaSP Nodes

  - 1 x Admin Node
    64 GB RAM
    1 x HDD 100 GB
    1 LAN
  
  - 1 x Master Node
    64 GB RAM
    1 x HDD 100 GB
    1 LAN
  
  - 3 x Worker Node
    64 GB RAM
    1 x HDD 100 GB
    1 LAN

### Network Architecture
All server connect to LAN network (isolate from other world).
Infrastructure server also connect to WAN.

## Instalation Procedure
### 1. Install SLES12 SP3 at infrastructure server.
### 2. Add FQDN to /etc/hosts
Exaple change:
_192.168.20.254 master_
to
_192.168.20.254 master.sdh.suse.ru master_
### 3. Configure NTP.
### 4. Configure SMT.
Execute SMT configuration wizard. During the server certificate setup, all possible DNS for this server has been added (SMT FQDN, etc).
Add repositories to replication.
```bash
sudo zypper in -t pattern smt

for REPO in SLES12-SP3-{Pool,Updates} SUSE-Enterprise-Storage-5-{Pool,Updates} SUSE-CAASP-3.0-{Pool,Updates}; do
  smt-repos $REPO sle-12-x86_64 -e
done

smt-mirror -L /var/log/smt/smt-mirror.log
```
Download next distro:
- SLE-12-SP3-Server-DVD-x86_64-GM-DVD1.iso
- SUSE-Enterprise-Storage-5-DVD-x86_64-GM-DVD1.iso
- SUSE-CaaS-Platform-3.0-DVD-x86_64-GM-DVD1.iso

Create install repositories:

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

## Configure DHCP
uses 


## Install SES
Shutt-off firewall at install SES time

## DNS + DHCP + NTP Install

## SMT Install
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


## SAP Data Hub specific

Requirements for Installing SAP Data Hub Foundation on Kubernetes

test

```bash
kubectl auth can-i '*' '*'
```

```bash
kubectl create clusterrolebinding vgrachev-cluster-admin-binding --clusterrole=cluster-admin --user=vadim.grachev@sap.com
```
## Dashboard Install
helm install --name heapster-default --namespace=kube-system stable/heapster --version=0.2.7 --set rbac.create=true
helm list | grep heapster
helm install --namespace=kube-system --name=kubernetes-dashboard stable/kubernetes-dashboard --version=0.6.1


need access to kubernetes-charts.storage.googleapis.com

https://caas-admin.sdh.suse.ru/

