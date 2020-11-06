#!/bin/bash
set -e

# Update /etc/hosts
ADDRESS="$(ip -4 addr show eth1 | grep "inet" | head -1 |awk '{print $2}' | cut -d/ -f1)"
sed -e "s/^.*${HOSTNAME}.*/${ADDRESS}  ${HOSTNAME} ${HOSTNAME}.local/" -i /etc/hosts

cat >> /etc/hosts <<"EOF"
192.168.100.11  master-1
192.168.100.12  master-2
192.168.100.14  worker-1
192.168.100.15  worker-2
192.168.100.13  lb loadbalancer
EOF

# Update /etc/resolve.conf
sed -i -e 's/10.0.2.3/8.8.8.8/' /etc/resolv.conf

# Update motd
cat > /etc/motd <<"EOF"
##########################################################################################
| \    /\|\     /|(  ___ \ (  ____ \(  ____ )( (    /|(  ____ \\__   __/(  ____ \(  ____ \
|  \  / /| )   ( || (   ) )| (    \/| (    )||  \  ( || (    \/   ) (   | (    \/| (    \/
|  (_/ / | |   | || (__/ / | (__    | (____)||   \ | || (__       | |   | (__    | (_____ 
|   _ (  | |   | ||  __ (  |  __)   |     __)| (\ \) ||  __)      | |   |  __)   (_____  )
|  ( \ \ | |   | || (  \ \ | (      | (\ (   | | \   || (         | |   | (            ) |
|  /  \ \| (___) || )___) )| (____/\| ) \ \__| )  \  || (____/\   | |   | (____/\/\____) |
|_/    \/(_______)|/ \___/ (_______/|/   \__/|/    )_)(_______/   )_(   (_______/\_______)
                                                                                          
 _______ _________ _______  _______  _        _______ 
(  ____ \\__   __/(       )(  ____ )( \      (  ____ \
| (    \/   ) (   | () () || (    )|| (      | (    \/
| (_____    | |   | || || || (____)|| |      | (__    
(_____  )   | |   | |(_)| ||  _____)| |      |  __)   
      ) |   | |   | |   | || (      | |      | (      
/\____) |___) (___| )   ( || )      | (____/\| (____/\
\_______)\_______/|/     \||/       (_______/(_______/
##########################################################################################
EOF

echo -e "Hostname         : " $HOSTNAME >> /etc/motd
echo -e "IP Address       : " $ADDRESS >> /etc/motd

# set password for vagrant user
echo -e "vagrant123\nvagrant123" | passwd vagrant

# modify sshd config
sed -i -e 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
systemctl restart sshd

# Modify timezone
ln -sf /usr/share/zoneinfo/Australia/Brisbane /etc/localtime

# Update NF call IPTables
modprobe br_netfilter
sysctl net.bridge.bridge-nf-call-iptables=1
echo 'net.bridge.bridge-nf-call-iptables=1' | sudo tee -a /etc/sysctl.conf

# Install ssh key
cat >> /home/vagrant/.ssh/authorized_keys <<"EOF"
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCuVQC4OvpmgfDka4nIw36GkPWVN2rLS2zwWA1xTdx9TFiYKJpf5pFkjzIE9ZHQSgTepuSqMkDuHNSn0Iur73V3YvveC7ejki62yKuzSyoPRJ/6d5bjueou7ihpBBv84PyOLAWqeymgAy/RLpeAjOzqo7SaITRWJJ3LZVsfS5s8ILxbdo5lFmt3XFZGlb/SJ9AMbEUxTUpKeKGmoSIvjnue003Vsphkv4orm2O5IblUJ6TEmncQxHAXnk9oHsfeeU+cq3NxrmMywmYE4b/b2sK4Pah2NQTOnydDKHlDuvNhxKTq0vJy9GKpdhaYiaLA23+hHm0MFFXhSTiVFIyq27Vh vagrant@master-1
EOF

chmod 600 /home/vagrant/.ssh/id_rsa

# Install some important packages
wget http://mirror.centos.org/centos/7/os/x86_64/Packages/kernel-headers-3.10.0-1127.el7.x86_64.rpm
wget http://mirror.centos.org/centos/7/os/x86_64/Packages/kernel-devel-3.10.0-1127.el7.x86_64.rpm
wget http://download.virtualbox.org/virtualbox/6.1.14/VBoxGuestAdditions_6.1.14.iso
rpm -ivh kernel-headers-3.10.0-1127.el7.x86_64.rpm
yum -y install net-tools wget gcc make perl ntp
rpm -ivh kernel-devel-3.10.0-1127.el7.x86_64.rpm
rm kernel-headers-3.10.0-1127.el7.x86_64.rpm kernel-devel-3.10.0-1127.el7.x86_64.rpm

# Install Vbox guest addition
GUEST_ADDITION_VERSION=6.1.14
GUEST_ADDITION_ISO=VBoxGuestAdditions_${GUEST_ADDITION_VERSION}.iso
GUEST_ADDITION_MOUNT=/media/VBoxGuestAdditions

mkdir -p ${GUEST_ADDITION_MOUNT}
mount -o loop,ro ${GUEST_ADDITION_ISO} ${GUEST_ADDITION_MOUNT}
sh ${GUEST_ADDITION_MOUNT}/VBoxLinuxAdditions.run
rm ${GUEST_ADDITION_ISO}
umount ${GUEST_ADDITION_MOUNT}
rmdir ${GUEST_ADDITION_MOUNT}

# Setup env
cat >> /root/.bashrc <<"EOF"
export PATH=$PATH:/usr/local/bin:/usr/local/sbin
EOF

cat >> /home/vagrant/.bashrc <<"EOF"
export PATH=$PATH:/usr/local/bin:/usr/local/sbin
EOF

# Set executable files
chmod +x /home/vagrant/*.sh

# setup NTP
systemctl enable ntpd
systemctl restart ntpd

# disable SELinux
sed -i -e 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config

# disable swap on worker nodes
if [ $HOSTNAME == "worker-1" ] || [ $HOSTNAME == "worker-2" ]; then
 swapoff -a
 sed -i.bak -r 's/(.+ swap .+)/#\1/' /etc/fstab
fi
