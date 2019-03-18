#!/bin/bash
salt-run  state.orch ceph.stage.5
salt '*' grains.delval deepsea destructive=True
salt-key -D -y
zypper rm -y deepsea salt-api salt-minion salt-master salt ceph-common
rm -r /srv/modules
rm -r /srv/pillar
rm -r /srv/salt
rm -r /etc/salt
rm -r /var/cache/salt
rm /srv/pillar/ceph/master_minion.sls.rpmsave /srv/pillar/ceph/deepsea_minions.sls.rpmsave /etc/salt/master.d/sharedsecret.conf.rpmsave
for i in 1 2 3 4; do ssh osd-0$i 'zypper rm -y salt salt-minion ceph-common; rm -r /etc/salt /var/lib/ceph /var/cache/salt /etc/salt; echo -e "d\n2\nd\nw\n" | fdisk /dev/sdb; reboot'; done

sleep 30

for i in 1 2 3 4
 do
  echo "wait to start osd-0$i after reboot"
  until (ping osd-0$i -c 1 > /dev/null) ; do sleep 10; done
 done

sleep 30

for i in 1 2 3 4; do ssh osd-0$i 'rm -r /var/lib/ceph'; done


