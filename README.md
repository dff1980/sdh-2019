# SAP Data Hub on SUSE CaaS Platform and SUSE Enterprise Storage 2019 PoC

This project is PoC installation SAP Data Hub on SUSE CaaS Platform and SUSE Enterprise Storage.

Using version:
- SUSE CaaSP 3
- SES 5
- SLES 12 SP3

This document currently in development state. Any comments and additions are welcome.
If you need some additional information about it please contact with Pavel Zhukov (pavel.zhukov@suse.com).


###### Disclaimer
###### _At the moment, no one is responsible if you try to use the information below for productive installations or commercial purposes._

## PoC Landscape
PoC can be deployed in any virtualization environment or on hardware servers.
Currently, PoC hosted on VMware VSphere.

## Requarments

### Tech Specs
- 1 dedicated infrastructure server ( DNS, DHCP, PXE, NTP, NAT, SMT, TFTP, SES admin, a console for SAP Data Hub admin)
    
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
All server connect to LAN network (isolate from another world). In current state - 192.168.20.0/24.
Infrastructure server also connects to WAN.

## Instalation Procedure
### Install infrastructure server
#### 1. Install SLES12 SP3
#### 2. Add FQDN to /etc/hosts
Exaple change:
_192.168.20.254 master_
to
_192.168.20.254 master.sdh.suse.ru master_
#### 3. Configure NTP.
```bash
yast2 ntp-client
```
#### 4. Configure Firewall.
```bash
yast2 firewall
```
#### 5. Configure SMT.
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
- SUSE-CaaS-Platform-3.0-DVD-x86_64-GM-DVD1.iso

Create install repositories:

```bash
mkdir -p /srv/www/htdocs/repo/SUSE/Install/SLE-SERVER/12-SP3
mkdir -p /srv/www/htdocs/repo/SUSE/Install/SUSE-CAASP/3.0

mkdir -p /srv/tftpboot/sle12sp3
mkdir -p /srv/tftpboot/caasp


mount SLE-12-SP3-Server-DVD-x86_64-GM-DVD1.iso /mnt
rsync -avP /mnt/ /srv/www/htdocs/repo/SUSE/Install/SLE-SERVER/12-SP3/x86_64/
cp /mnt/boot/x86_64/loader/{linux,initrd} /srv/tftpboot/sle12sp3/
umount /mnt

mount SUSE-CaaS-Platform-3.0-DVD-x86_64-GM-DVD1.iso /mnt
rsync -avP /mnt/ /srv/www/htdocs/repo/SUSE/Install/SUSE-CAASP/3.0/x86_64/
cp /mnt/boot/x86_64/loader/{linux,initrd} /srv/tftpboot/caasp/
umount /mnt
```
### 6. Configure DHCP
```bash
yast2 dhcp-server
```
or uses next [template](data/etc/dhcpd.conf) for /etc/dhcpd.conf
restart dhcp service.
```bash
systemctl restart dhcpd.service
```
### 7. Configure TFTP
```bash
yast2 tftp-server
```
copy [/srv/tftpboot/*](data/srv/tftpboot/) to server.

### 8. Configure DNS
```bash
yast2 dns-server
```
Configure zone for PoC and all nodes.

## Install SES
### 1. Stop firewall at Infrastructure server at installing SES time.
```bash
systemctl stop SuSEfirewall2
```
### 2. Configure AutoYast
Put [/srv/www/htdocs/autoyast/autoinst_osd.xml](data/srv/www/htdocs/autoyast/autoinst_osd.xml) to the server.

### 3. Install SES Nodes
Boot all SES Node from PXE and chose "Install OSD Node" from PXE boot menu.

### 4. Configure SES
1. Start [data/ses-install/restart.sh](data/ses-install/restart.sh) at infrastructure server.
2. Run
```bash
salt-run state.orch ceph.stage.0
```
3. Run
```bash
salt-run state.orch ceph.stage.1
```
4. Put [/srv/pillar/ceph/proposals/policy.cfg](data/srv/pillar/ceph/proposals/policy.cfg) to server.
5. Run
```bash
salt-run state.orch ceph.stage.2
```
After the command finishes, you can view the pillar data for minions by running:
```bash
salt '*' pillar.items
```
6. Run
```bash
salt-run state.orch ceph.stage.3
```
If it fails, you need to fix the issue and run the previous stages again. After the command succeeds, run the following to check the status:
```bash
ceph -s
```
7. Run
```bash
salt-run state.orch ceph.stage.4
```
8. Add rbd pool (you can use OpenAttic Web interface at infrastructure node)

### 5. Start firewall at Infrastructure Server
```bash
systemctl start SuSEfirewall2
```
## Install SUSE CaaSP
1. Boot CaaS admin Node from PXE and chose "Install CaaSP Manually" from PXE boot menu.
2. Install CaaS admin Node using FQDN of infrastructure server for SMT and NTP parameters.
3. Get AutoYaST file for CaaS and put it to /srv/www/htdocs/autoyast/autoinst_caas.xml
```bash
wget http://caas-admin.sdh.suse.ru/autoyast
mv autoyast /srv/www/htdocs/autoyast/autoinst_caas.xml
```
4. get AutoYast Fingerprint
```bash
openssl x509 -noout -fingerprint -sha256 -inform pem -in /srv/www/htdocs/smt.crt
```
5. Change /srv/www/htdocs/autoyast/autoinst_caas.xml
Add
- to `<suse_register>`

 `<reg_server>https://smt.sdh.suse.ru</reg_server>
  <reg_server_cert_fingerprint_type>SHA256</reg_server_cert_fingerprint_type>
  <reg_server_cert_fingerprint>YOUR SMT FINGERPRINT</reg_server_cert_fingerprint>`

- to `<services>`

 `<service>vmtoolsd</service>`

- to `<software>`
 
 `<packages config:type="list">
       <packages>open-vm-tools</packages>
     </packages>`

6. Boot other CaaS Node from PXE and chose "Install CaaSP Node (full automation)" from PXE boot menu.
7. Configure CaaS from Velum.
8. Dashboard Install

~~helm install --name heapster-default --namespace=kube-system stable/heapster --version=0.2.7 --set rbac.create=true
helm list | grep heapster~~

```bash
helm install --name heapster-default --namespace=kube-system stable/heapster --set rbac.create=true
```
Change Heapster deployment to using 10250 port:
```bash
kubectl edit deployment heapster-default-heapster -n kube-system
```
```yaml
    spec:
      containers:
      - command:
        - /heapster
        - --source=kubernetes.summary_api:https://kubernetes.default?kubeletPort=10250&kubeletHttps=true&insecure=true
```
```bash
helm install --namespace=kube-system --name=kubernetes-dashboard stable/kubernetes-dashboard --version=0.6.1
```

## Configure SUSE CaaSP and SES integration

Retrieve the Ceph admin secret. Get the key value from the file /etc/ceph/ceph.client.admin.keyring.

On the master node apply the configuration that includes the Ceph secret by using kubectl apply. Replace CEPH_SECRET with your Ceph secret.
```bash
tux > kubectl apply -f - << *EOF*
apiVersion: v1
kind: Secret
metadata:
  name: ceph-secret
type: "kubernetes.io/rbd"
data:
  key: "$(echo CEPH_SECRET | base64)"
*EOF*
```

## Configure nginx-ingress for micro-servises demo

helm install --name nginx-ingress stable/nginx-ingress --namespace kube-system --values nginx-ingress-config-values.yaml


## Configure SUSE CaaSP for SAP Data Hub
1. Add user
Using [LDIF File](addon/vgrachev.ldif) to create user. (Use /usr/sbin/slappasswd to generate the password hash.)
Retrieve the LDAP admin password. Note the password for later use.
```bash
cat /var/lib/misc/infra-secrets/openldap-password
```
Import the LDAP certificate to your local trusted certificate storage. On the administration node, run:
```bash
docker exec -it $(docker ps -q -f name=ldap) cat /etc/openldap/pki/ca.crt > ~/ca.pem
scp ~/ca.pem root@WORKSTATION:/usr/share/pki/trust/anchors/ca-caasp.crt.pem
```
Replace WORKSTATION with the appropriate hostname for the workstation where you wish to run the LDAP queries.
Then, on that workstation, run:
```bash
update-ca-certificates
```
```bash
zypper in openldap2
ldapadd -H ldap://ADMINISTRATION_NODE_FQDN:389 -ZZ \
-D cn=admin,dc=infra,dc=caasp,dc=local -w LDAP_ADMIN_PASSWORD -f LDIF_FILE
```
2. Add cluster role for this user (Requirements for Installing SAP Data Hub Foundation on Kubernetes)
```bash
kubectl create clusterrolebinding vgrachev-cluster-admin-binding --clusterrole=cluster-admin --user=vadim.grachev@sap.com
kubectl auth can-i '*' '*'
```
3. Install kubernetes-client and helm from /srv/www/htdocs/repo/SUSE/Updates/SUSE-CAASP/3.0/x86_64/update/x86_64
```bash
rpm -Uhv kubernetes-common-1.10.11-4.11.1.x86_64.rpm
rpm -Uhv kubernetes-client-1.10.11-4.11.1.x86_64.rpm
rpm -Uhv helm-2.8.2-3.3.1.x86_64.rpm
```
4. Configure local docker registry
```bash
zypper install docker-distribution-registry
systemctl enable registry
systemctl start registry
echo "{ "insecure-registries":["master.sdh.suse.ru:5000"] }" >> /etc/docker/daemon.json
usermod -a -G docker vgrachev
```
https://www.suse.com/documentation/sles-12/book_sles_docker/data/sec_docker_registry_installation.html

5. Add Storage Class
```bash
kubectl create -f rbd_storage.yaml
```
6. Add Registry to Velum
Add master.sdh.suse.ru:5000 to Registry in Velum

7. Add Role Binding (vsystem-vrep issue)
```bash
kubectl create -f clusterrolebinding.yaml 
```

## Test Enviroment
```bash
kubectl version
kubectl auth can-i '*' '*'
helm version
ceph status
rbd list
rbd create -s 10 rbd_test
rbd info rbd_test
kubectl apply -f - << *EOF*
 apiVersion: v1
 kind: Pod
 metadata:
   name: rbd-test
 spec:
   containers:
   - name: test-server
     image: nginx
     volumeMounts:
     - mountPath: /mnt/rbdvol
       name: rbdvol
   volumes:
   - name: rbdvol
     rbd:
       monitors:
       - '192.168.20.21:6789'
       - '192.168.20.22:6789'
       - '192.168.20.23:6789'
       pool: rbd
       image: rbd_test
       user: admin
       secretRef:
         name: ceph-secret
       fsType: ext4
       readOnly: false
*EOF*
kubectl get po
kubectl exec -it rbd-test -- df -h
kubectl delete pod rbd-test
rbd rm rbd_test
docker images -- master.sdh.suse.ru:5000/hello-world
docker push master.sdh.suse.ru:5000/hello-world
docker pull hello-world
docker tag docker.io/hello-world master.sdh.suse.ru:5000/hello-world
docker images -- master.sdh.suse.ru:5000/hello-world
docker pull master.sdh.suse.ru:5000/hello-world
```

## Appendix 
### SUSE Enterprise Storage 5 Documentation
https://www.suse.com/documentation/suse-enterprise-storage-5/

### SUSE CaaS Platform 3 Documentation
https://www.suse.com/documentation/suse-caasp-3/index.html
