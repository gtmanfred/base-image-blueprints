#!/bin/bash

# update
apt-get update
apt-get -y dist-upgrade

# fix bootable flag
parted -s /dev/sda set 1 boot on
e2label /dev/sda1 root

# Remove mdadm conf for universal
rm /etc/mdadm/mdadm.conf

# custom teeth cloud-init bit
#wget https://244cb001e7940f815e7d-eed332c78fa1ec49f5728fa74ebb315e.ssl.cf2.rackcdn.com/cloud-init_0.7.5-1rackspace5_all.deb
wget http://KICK_HOST/cloud-init/cloud-init_0.7.7_upstart.deb
dpkg -i *.deb
apt-mark hold cloud-init

# cloud-init kludges
addgroup --system --quiet netdev
#echo -n > /etc/udev/rules.d/70-persistent-net.rules
#echo -n > /lib/udev/rules.d/75-persistent-net-generator.rules
#echo -n > /etc/udev/rules.d/80-net-name-slot.rules

# cloud-init debug logging
sed -i 's/WARNING/DEBUG/g' /etc/cloud/cloud.cfg.d/05_logging.cfg

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

cloud_config_modules:
 - emit_upstart
 - disk_setup
 - ssh-import-id
 - locale
 - set-passwords
 - snappy
 - grub-dpkg
 - apt-pipelining
 - apt-configure
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

# preseeds/debconf do not work for this anymore :(
cat > /etc/cloud/cloud.cfg.d/90_dpkg.cfg <<'EOF'
# to update this file, run dpkg-reconfigure cloud-init
datasource_list: [ ConfigDrive, None ]
EOF

# minimal network conf
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

# Grub fixups
cat /dev/null > /etc/default/grub.d/dmraid2mdadm.cfg
echo "GRUB_DEVICE_LABEL=root" >> /etc/default/grub

# keep grub2 from using UUIDs and regenerate config
sed -i 's/#GRUB_DISABLE_LINUX_UUID.*/GRUB_DISABLE_LINUX_UUID="true"/g' /etc/default/grub
sed -i 's/#GRUB_TERMINAL=console/GRUB_TERMINAL=/g' /etc/default/grub
#sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT.*/GRUB_CMDLINE_LINUX_DEFAULT="console=ttyS4,115200n8 cgroup_enable=memory swapaccount=1 splash quiet"/g' /etc/default/grub
#sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT.*/GRUB_CMDLINE_LINUX_DEFAULT="net.ifnames=0 biosdevname=0 cgroup_enable=memory swapaccount=1 quiet"/g' /etc/default/grub
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT.*/GRUB_CMDLINE_LINUX_DEFAULT="rd.fstab=no acpi=off noapic cgroup_enable=memory swapaccount=1 quiet"/g' /etc/default/grub
sed -i 's/GRUB_TIMEOUT.*/GRUB_TIMEOUT=0/g' /etc/default/grub
#echo 'GRUB_SERIAL_COMMAND="serial --unit=0 --speed=115200n8 --word=8 --parity=no --stop=1"' >> /etc/default/grub
#echo 'GRUB_PRELOAD_MODULES="8021q bonding"' >> /etc/default/grub
update-grub

# TODO: make update-grub generate root=LABEL=root configs
sed -i 's#/dev/sda1#LABEL=root#g' /boot/grub/grub.cfg
sed -i 's#/dev/sda1#LABEL=root#g' /etc/fstab

# Make sure mdadm hooks gets copied to initrd
echo "INITRDSTART='all'" >> /etc/default/mdadm

# Set udev rule to not add by-label symlinks for v2 blockdevs if not raid
wget http://KICK_HOST/misc/60-persistent-storage.rules -O /etc/udev/rules.d/60-persistent-storage.rules

# The root delay kernel param borked some time ago so wee need to manually do it.
echo "sleep 5" > /etc/initramfs-tools/scripts/init-premount/delay_for_raid
chmod a+x /etc/initramfs-tools/scripts/init-premount/delay_for_raid

# setup a usable console
#cat > /etc/init/ttyS0.conf <<'EOF'
# ttyS0 - getty
#
# This service maintains a getty on ttyS1 from the point the system is
# started until it is shut down again.

#start on stopped rc RUNLEVEL=[2345]
#stop on runlevel [!2345]

#respawn
#exec /sbin/getty -L 115200 ttyS0 xterm
#EOF

# setup a usable console
#cat > /etc/init/ttyS4.conf <<'EOF'
# ttyS4 - getty
#
# This service maintains a getty on ttyS1 from the point the system is
# started until it is shut down again.

#start on stopped rc RUNLEVEL=[2345]
#stop on runlevel [!2345]

#respawn
#exec /sbin/getty -L 115200 ttyS4 xterm
#EOF

# fsck no autorun on reboot
sed -i 's/#FSCKFIX=no/FSCKFIX=yes/g' /etc/default/rcS

# fix growpart for raid
wget http://KICK_HOST/misc/growroot -O /usr/share/initramfs-tools/scripts/local-bottom/growroot
chmod a+x /usr/share/initramfs-tools/scripts/local-bottom/growroot
wget http://KICK_HOST/misc/growpart -O /usr/bin/growpart
chmod a+x /usr/bin/growpart

# another teeth specific
echo "bonding" >> /etc/modules
echo "8021q" >> /etc/modules
cat > /etc/modprobe.d/blacklist-mei.conf <<'EOF'
blacklist mei_me
EOF
depmod -a
update-initramfs -u -k all
#sed -i 's/start on.*/start on net-device-added and filesystem/g' /etc/init/network-interface.conf
sed -i 's/start on.*/start on net-device-added INTERFACE=bond0/g' /etc/init/cloud-init-local.conf

# log packages
wget http://KICK_HOST/kickstarts/package_postback.sh
bash package_postback.sh Ubuntu_14.04_Teeth

# clean up
passwd -d root
passwd -l root
apt-get -y clean
#apt-get -y autoremove
sed -i '/.*cdrom.*/d' /etc/apt/sources.list
# this file copies the installer's /etc/network/interfaces to the VM
# but we want to overwrite that with a "clean" file instead
# so we must disable that copying action in kickstart/preseed
rm -f /usr/lib/finish-install.d/55netcfg-copy-config
rm -f /etc/ssh/ssh_host_*
rm -f /var/cache/apt/archives/*.deb
rm -f /var/cache/apt/*cache.bin
rm -f /var/lib/apt/lists/*_Packages
rm -f /root/.bash_history
rm -f /root/.nano_history
rm -f /root/.lesshst
rm -f /root/.ssh/known_hosts
rm -rf /tmp/tmp
find /var/log -type f -exec truncate -s 0 {} \;
find /tmp -type f -delete
find /root -type f ! -iname ".*" -delete
