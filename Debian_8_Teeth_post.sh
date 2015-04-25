#!/bin/bash

# fix bootable flag
parted -s /dev/sda set 1 boot on

# Debian puts these in the wrong order from what we need
# should be ConfigDrive, None but preseed populates with
# None, Configdrive which breaks user-data scripts
cat > /etc/cloud/cloud.cfg.d/90_dpkg.cfg <<'EOF'
# to update this file, run dpkg-reconfigure cloud-init
datasource_list: [ ConfigDrive, None ]
EOF

# our cloud-init config
cat > /etc/cloud/cloud.cfg.d/10_rackspace.cfg <<'EOF'
disable_root: False
ssh_pwauth: False
ssh_deletekeys: True
resize_rootfs: noblock
manage_etc_hosts: localhost
apt_preserve_sources_list: True
system_info:
   distro: debian
   default_user:
     name: root
     lock_passwd: True
     gecos: Debian
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
echo -n > /etc/udev/rules.d/70-persistent-net.rules
echo -n > /lib/udev/rules.d/75-persistent-net-generator.rules

# minimal network conf that doesnt dhcp
# causes boot delay if left out, no bueno
cat > /etc/network/interfaces <<'EOF'
auto lo
iface lo inet loopback
EOF

cat > /etc/hosts <<'EOF'
127.0.0.1	localhost

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
EOF

# set some stuff
#echo 'net.ipv4.conf.eth0.arp_notify = 1' >> /etc/sysctl.conf
#echo 'vm.swappiness = 0' >> /etc/sysctl.conf

# remove cd-rom from sources.list
sed -i '/.*cdrom.*/d' /etc/apt/sources.list

# update
#apt-get update
#apt-get -y dist-upgrade

# keep grub2 from using UUIDs and regenerate config
sed -i 's/#GRUB_DISABLE_LINUX_UUID.*/GRUB_DISABLE_LINUX_UUID="true"/g' /etc/default/grub
#sed -i 's/#GRUB_TERMINAL=console/GRUB_TERMINAL=console/g' /etc/default/grub
sed -i 's/#GRUB_TERMINAL=console/GRUB_TERMINAL=/g' /etc/default/grub
#sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT.*/GRUB_CMDLINE_LINUX_DEFAULT="console=ttyS4,115200n8 8250.nr_uarts=5 splash quiet"/g' /etc/default/grub
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT.*/GRUB_CMDLINE_LINUX_DEFAULT="8250.nr_uarts=5 quiet"/g' /etc/default/grub
sed -i 's/GRUB_TIMEOUT.*/GRUB_TIMEOUT=0/g' /etc/default/grub
#echo 'GRUB_SERIAL_COMMAND="serial --unit=0 --speed=115200n8 --word=8 --parity=no --stop=1"' >> /etc/default/grub
update-grub

# log packages
wget http://KICK_HOST/kickstarts/package_postback.sh
bash package_postback.sh Debian_8_Teeth

# teeth cloud-init workaround, hopefully goes away with upstream cloud-init changes?
wget http://KICK_HOST/kickstarts/Teeth-cloud-init
cp Teeth-cloud-init /usr/share/pyshared/cloudinit/sources/DataSourceConfigDrive.py

# another teeth specific
echo "bonding" >> /etc/modules
echo "8021q" >> /etc/modules
cat > /etc/modprobe.d/blacklist-mei.conf <<'EOF'
blacklist mei_me
EOF
update-initramfs -u

# more teeth console changes
cat >> /etc/inittab <<'EOF'
T0:23:respawn:/sbin/getty -L ttyS0 115200 xterm
T4:23:respawn:/sbin/getty -L ttyS4 115200 xterm
EOF

# fsck no autorun on reboot
sed -i 's/#FSCKFIX=no/FSCKFIX=yes/g' /etc/default/rcS

# clean up
passwd -d root
passwd -l root
apt-get -y clean
apt-get -y autoremove
rm -f /etc/ssh/ssh_host_*
rm -f /var/cache/apt/archives/*.deb
rm -f /var/cache/apt/*cache.bin
rm -f /var/lib/apt/lists/*_Packages
#rm -f /etc/resolv.conf
rm -f /root/.bash_history
rm -f /root/.nano_history
rm -f /root/.lesshst
rm -f /root/.ssh/known_hosts
for k in $(find /var/log -type f); do echo > $k; done
for k in $(find /tmp -type f); do rm -f $k; done
