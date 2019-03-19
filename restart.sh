#!/bin/bash
zypper in -y deepsea
echo "master: master.sdh.suse.ru" > /etc/salt/minion.d/minion.conf
systemctl enable salt-master salt-minion
systemctl start salt-master
systemctl start salt-minion
for i in 1 2 3 4; do ssh osd-0$i 'zypper in -y salt-minion; systemctl enable salt-minion; echo "master: master.sdh.suse.ru" > /etc/salt/minion.d/minion.conf; systemctl start salt-minion'; done
sleep 5
salt-key
salt-key -A -y
sleep 15
salt '*' test.ping
salt '*' cmd.run date
#salt 'osd-*' grains.append deepsea default
salt '*' grains.append deepsea default

