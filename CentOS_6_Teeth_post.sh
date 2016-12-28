#!/bin/bash

# set rackspace mirrors
echo "Setting up Rackspace mirrors"
sed -i 's/mirror.centos.org/mirror.rackspace.com/g' /etc/yum.repos.d/CentOS-Base.repo
sed -i 's%baseurl.*%baseurl=http://mirror.rackspace.com/epel/6/x86_64/%g' /etc/yum.repos.d/epel.repo
sed -i '/baseurl/s/# *//' /etc/yum.repos.d/CentOS-Base.repo
sed -i '/baseurl/s/# *//' /etc/yum.repos.d/epel.repo
sed -i '/mirrorlist/s/^/#/' /etc/yum.repos.d/CentOS-Base.repo
sed -i '/mirrorlist/s/^/#/' /etc/yum.repos.d/epel.repo

#centos 6 specific, pin the kernel by downloading old one and removing current version
echo "Pinning kernel"
REMOVEKERNEL=$(rpm -q kernel)
wget http://KICK_HOST/packages/centos/6/kernel-2.6.32-504.30.3.el6.x86_64.rpm
wget http://KICK_HOST/packages/centos/6/kernel-headers-2.6.32-504.30.3.el6.x86_64.rpm
yum -y localinstall kernel*
echo "exclude=kernel*" >> /etc/yum.conf

# update all
echo "Installing all updates"
yum -y update

# Non-firewalld-firewall
echo -n "Writing static firewall"
cat > /etc/sysconfig/iptables <<'EOF'
# Simple static firewall loaded by iptables.service. Replace
# this with your own custom rules, run lokkit, or switch to
# shorewall or firewalld as your needs dictate.
*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
-A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
-A INPUT -p icmp -j ACCEPT
-A INPUT -i lo -j ACCEPT
-A INPUT -m conntrack --ctstate NEW -m tcp -p tcp --dport 22 -j ACCEPT
-A INPUT -j REJECT --reject-with icmp-host-prohibited
-A FORWARD -j REJECT --reject-with icmp-host-prohibited
COMMIT
EOF

echo -n "Network fixes"
# initscripts don't like this file to be missing.
cat > /etc/sysconfig/network << EOF
NETWORKING=yes
NOZEROCONF=yes
EOF

# For cloud images, 'eth0' _is_ the predictable device name, since
# we don't want to be tied to specific virtual (!) hardware
cat > /etc/udev/rules.d/70-persistent-net.rules <<'EOF'
#OnMetal v1
SUBSYSTEM=="net", ACTION=="add", KERNELS=="0000:08:00.0", NAME="eth0"
SUBSYSTEM=="net", ACTION=="add", KERNELS=="0000:08:00.1", NAME="eth1"

#OnMetal v2
SUBSYSTEM=="net", ACTION=="add", KERNELS=="0000:03:00.0", NAME="eth0"
SUBSYSTEM=="net", ACTION=="add", KERNELS=="0000:03:00.1", NAME="eth1"
EOF

# generic localhost names
cat > /etc/hosts << EOF
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
EOF

cat >> /etc/sysctl.conf <<'EOF'
net.ipv4.tcp_rmem = 4096 87380 33554432
net.ipv4.tcp_wmem = 4096 65536 33554432
net.core.rmem_max = 33554432
net.core.wmem_max = 33554432
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_timestamps = 1
net.ipv4.tcp_sack = 1
vm.dirty_ratio=5
EOF

# disable auto fsck on boot
cat > /etc/sysconfig/autofsck << EOF
AUTOFSCK_DEF_CHECK=yes
PROMPT=no
AUTOFSCK_OPT="-y"
AUTOFSCK_TIMEOUT=10
EOF

# install custom cloud-init and lock version
wget http://KICK_HOST/pyserial/pyserial-3.1.1.tar.gz
tar xvfz pyserial-3.1.1.tar.gz
cd pyserial-3.1.1 && python setup.py install
cd ..
rpm -Uvh --nodeps http://KICK_HOST/cloud-init/cloud-init-0.7.7-bzr1117.el6.noarch.rpm
yum versionlock add cloud-init
chkconfig cloud-init on
sed -i '/import sys/a reload(sys)\nsys.setdefaultencoding("Cp1252")' /usr/lib/python2.6/site-packages/configobj.py

# more cloud-init logging
sed -i 's/WARNING/DEBUG/g' /etc/cloud/cloud.cfg.d/05_logging.cfg

# hack for teeth sd* labeling
tune2fs -L / /dev/sda1
cat > /etc/fstab <<'EOF'
LABEL=/ / ext4 errors=remount-ro,noatime 0 1
EOF

# another teeth specific
cat > /etc/sysconfig/modules/onmetal.modules <<'EOF'
#!/bin/sh
exec /sbin/modprobe bonding >/dev/null 2>&1
exec /sbin/modprobe 8021q >/dev/null 2>&1
EOF
chmod +x /etc/sysconfig/modules/onmetal.modules
#
cat > /etc/modprobe.d/blacklist-mei.conf <<'EOF'
blacklist mei_me
EOF
dracut -f

# our cloud-init config
cat > /etc/cloud/cloud.cfg.d/10_rackspace.cfg <<'EOF'
datasource_list: [ ConfigDrive, None ]
disable_root: False
ssh_pwauth: True
ssh_deletekeys: False
resize_rootfs: noblock
manage_etc_hosts: True
growpart:
  mode: auto
  devices: ['/']
system_info:
  distro: rhel
  ssh_svcname: sshd
  default_user:
    name: root
    lock_passwd: True
    gecos: CentOS cloud-init user
    shell: /bin/bash
cloud_config_modules:
 - disk_setup
 - ssh-import-id
 - locale
 - set-passwords
 - package-update-upgrade-install
 - landscape
 - timezone
 - puppet
 - chef
 - salt-minion
 - mcollective
 - disable-ec2-metadata
 - runcmd
 - byobu
EOF

# force grub to use generic disk labels, bootloader above does not do this
sed -i 's%root=.*%root=LABEL=/ 8250.nr_uarts=5 modprobe.blacklist=mei_me acpi=noirq noapic selinux=0 console=ttyS0,57600n8%g' /boot/grub/grub.conf
sed -i '/splashimage/d' /boot/grub/grub.conf
sed -i 'g/SELINUX=*/SELINUX=permissive/s' /etc/selinux/config

# log packages
wget http://KICK_HOST/kickstarts/package_postback.sh
bash package_postback.sh CentOS_6_Teeth

# clean up
yum clean all
passwd -d root
passwd -l root
rm -f /etc/ssh/ssh_host_*
rm -f /root/.bash_history
rm -f /root/.nano_history
rm -f /root/.lesshst
rm -f /root/.ssh/known_hosts
rm -f /root/anaconda-ks.cfg
rm -rf /tmp/tmp
truncate -s 0 /etc/resolv.conf
find /tmp -type f -delete
find /root -type f ! -iname ".*" -delete
find /var/log -type f -exec truncate -s 0 {} \;
