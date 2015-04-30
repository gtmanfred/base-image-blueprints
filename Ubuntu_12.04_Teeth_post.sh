#!/bin/bash
# fix bootable flag
parted -s /dev/sda set 1 boot on

# tmp tmp
mkdir /tmp/tmp
cd /tmp/tmp

# custom cloud-init
#wget https://be3c4d5274cd5307ce4a-fa55afd7e9be71a29fceec8b7b5e23fe.ssl.cf2.rackcdn.com/cloud-init_0.7.5-1rackspace5_all.deb
wget http://KICK_HOST/cloud-init/cloud-init-teeth-python2.deb
dpkg -i *.deb
apt-mark hold cloud-init

# our cloud-init config
cat > /etc/cloud/cloud.cfg.d/10_rackspace.cfg <<'EOF'
disable_root: False
ssh_pwauth: False
ssh_deletekeys: False
resize_rootfs: noblock
manage_etc_hosts: localhost
apt_preserve_sources_list: True
system_info:
   distro: ubuntu
   default_user:
     name: root
     lock_passwd: True
     gecos: Ubuntu
     shell: /bin/bash
# this bit scales some sysctl parameters to flavor type
bootcmd:
  - echo "net.ipv4.tcp_rmem = $(cat /proc/sys/net/ipv4/tcp_mem)" >> /etc/sysctl.conf
  - echo "net.ipv4.tcp_wmem = $(cat /proc/sys/net/ipv4/tcp_mem)" >> /etc/sysctl.conf
  - echo "net.core.rmem_max = $(cat /proc/sys/net/ipv4/tcp_mem | awk {'print $3'})" >> /etc/sysctl.conf
  - echo "net.core.wmem_max = $(cat /proc/sys/net/ipv4/tcp_mem | awk {'print $3'})" >> /etc/sysctl.conf
  - echo 'net.ipv4.tcp_window_scaling = 1' >> /etc/sysctl.conf
  - echo 'net.ipv4.tcp_timestamps = 1' >> /etc/sysctl.conf
  - echo 'net.ipv4.tcp_sack = 1' >> /etc/sysctl.conf
  - sysctl -p
EOF

# cloud-init kludges
addgroup --system --quiet netdev
echo -n > /etc/udev/rules.d/70-persistent-net.rules
echo -n > /lib/udev/rules.d/75-persistent-net-generator.rules

# cloud-init must be beaten with hammer
# preseeding these values isnt working, forcing it here
#echo "cloud-init cloud-init/datasources multiselect ConfigDrive" > /tmp/tmp/debconf-selections
#/usr/bin/debconf-set-selections /tmp/tmp/debconf-selections
#dpkg-reconfigure cloud-init

# both the above and preseed values quit working :(
#cat > /etc/cloud/cloud.cfg.d/90_dpkg.cfg <<'EOF'
# to update this file, run dpkg-reconfigure cloud-init
#datasource_list: [ ConfigDrive ]
#EOF
# change this if cloud-init version is ever 7.5+
# to one below

cat > /etc/cloud/cloud.cfg.d/90_dpkg.cfg <<'EOF'
# to update this file, run dpkg-reconfigure cloud-init
datasource_list: [ ConfigDrive, None ]
EOF

# minimal network conf that doesnt dhcp
# causes boot delay if left out, no bueno
cat > /etc/network/interfaces <<'EOF'
auto lo
iface lo inet loopback
EOF

# stage a clean hosts file
cat > /etc/hosts <<'EOF'
# The following lines are desirable for IPv6 capable hosts
::1     ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
127.0.0.1 localhost
EOF

# set some stuff
#echo 'net.ipv4.conf.eth0.arp_notify = 1' >> /etc/sysctl.conf
#echo 'vm.swappiness = 0' >> /etc/sysctl.conf

# our fstab is fonky
cat > /etc/fstab <<'EOF'
# /etc/fstab: static file system information.
#
# Use 'blkid' to print the universally unique identifier for a
# device; this may be used with UUID= as a more robust way to name devices
# that works even if disks are added and removed. See fstab(5).
#
# <file system> <mount point>   <type>  <options>       <dump>  <pass>
/dev/sda1	/               ext4    errors=remount-ro 0       1
EOF

# set ssh keys to regenerate at first boot if missing
# this is a fallback to catch when cloud-init fails doing the same
# it will do nothing if the keys already exist
#cat > /etc/rc.local <<'EOF'
#dpkg-reconfigure openssh-server
#echo > /etc/rc.local
#EOF

# another teeth specific
echo "bonding" >> /etc/modules
echo "8021q" >> /etc/modules
cat > /etc/modprobe.d/blacklist-mei.conf <<'EOF'
blacklist mei_me
blacklist mei
EOF
update-initramfs -u

# keep grub2 from using UUIDs and regenerate config
sed -i 's/#GRUB_DISABLE_LINUX_UUID.*/GRUB_DISABLE_LINUX_UUID="true"/g' /etc/default/grub
sed -i 's/#GRUB_TERMINAL=console/GRUB_TERMINAL=/g' /etc/default/grub
#sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT.*/GRUB_CMDLINE_LINUX_DEFAULT="console=ttyS4,115200n8 cgroup_enable=memory swapaccount=1"/g' /etc/default/grub
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT.*/GRUB_CMDLINE_LINUX_DEFAULT="cgroup_enable=memory swapaccount=1"/g' /etc/default/grub
sed -i 's/GRUB_TIMEOUT.*/GRUB_TIMEOUT=0/g' /etc/default/grub
#echo 'GRUB_SERIAL_COMMAND="serial --unit=0 --speed=115200n8 --word=8 --parity=no --stop=1"' >> /etc/default/grub
update-grub

# setup a usable console
cat > /etc/init/ttyS0.conf <<'EOF'
# ttyS0 - getty
#
# This service maintains a getty on ttyS0 from the point the system is
# started until it is shut down again.

start on stopped rc RUNLEVEL=[2345]
stop on runlevel [!2345]

respawn
exec /sbin/getty -L 115200 ttyS0 xterm
EOF

# setup a usable console
cat > /etc/init/ttyS4.conf <<'EOF'
# ttyS4 - getty
#
# This service maintains a getty on ttyS4 from the point the system is
# started until it is shut down again.

start on stopped rc RUNLEVEL=[2345]
stop on runlevel [!2345]

respawn
exec /sbin/getty -L 115200 ttyS4 xterm
EOF

cat > /etc/apt/apt.conf.d/00InstallRecommends <<'EOF'
APT::Install-Recommends "true";
EOF

# update
apt-get update
apt-get -y dist-upgrade

# fsck no autorun on reboot
sed -i 's/FSCKFIX=no/FSCKFIX=yes/g' /etc/default/rcS

# log packages
wget http://KICK_HOST/kickstarts/package_postback.sh
bash package_postback.sh Ubuntu_12.04_Teeth

# clean up
passwd -d root
passwd -l root
apt-get -y clean
apt-get -y autoremove
sed -i '/.*cdrom.*/d' /etc/apt/sources.list
rm -f /etc/ssh/ssh_host_*
rm -f /var/cache/apt/archives/*.deb
rm -f /var/cache/apt/*cache.bin
rm -f /var/lib/apt/lists/*_Packages
# breaks newest nova-agent if removed
#rm -f /etc/resolv.conf
# this file copies the installer's /etc/network/interfaces to the VM 
# but we want to overwrite that with a "clean" file instead
# so we must disable that copying action in kickstart/preseed
rm -f /usr/lib/finish-install.d/55netcfg-copy-config
rm -f /root/.bash_history
rm -f /root/.nano_history
rm -f /root/.lesshst
rm -f /root/.ssh/known_hosts
rm -rf /tmp/tmp
for k in $(find /var/log -type f); do echo > $k; done
for k in $(find /tmp -type f); do rm -f $k; done
for k in $(find /root -type f \( ! -iname ".*" \)); do rm -f $k; done
