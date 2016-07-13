#!/bin/bash
source /etc/profile
export PS1="(chroot) $PS1"

# change root password
(echo novaagentneedsunlockedrootaccountsowedeletepasswordinpost ; sleep 3; echo novaagentneedsunlockedrootaccountsowedeletepasswordinpost) | passwd

# update tz info
cp /usr/share/zoneinfo/UTC /etc/localtime
echo "UTC" > /etc/timezone

# set locale
echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen
echo 'en_US ISO-8859-1' >> /etc/locale.gen
locale-gen
eselect locale set en_US.utf8

# setup config for portage
cat > /etc/portage/make.conf <<'EOF'
# These settings were set by the catalyst build script that automatically
# built this stage.
# Please consult /usr/share/portage/config/make.conf.example for a more
# detailed example.
CFLAGS="-O2 -pipe"
CXXFLAGS="${CFLAGS}"
# WARNING: Changing your CHOST is not something that should be done lightly.
# Please consult http://www.gentoo.org/doc/en/change-chost.xml before changing.
CHOST="x86_64-pc-linux-gnu"
# These are the USE flags that were used in addition to what is provided by the
# profile used for building.
USE=""
MAKEOPTS="-j2"
SYNC="rsync://rsync.namerica.gentoo.org/gentoo-portage"
GENTOO_MIRRORS="http://mirror.rackspace.com/gentoo/"
PORTDIR="/usr/portage"
DISTDIR="${PORTDIR}/distfiles"
PKGDIR="${PORTDIR}/packages"
EOF

#make swapfile and enable
#dd if=/dev/zero of=/swapfile1 bs=1024 count=1048576 && mkswap /swapfile1 && chown root:root /swapfile1 && chmod 0600 /swapfile1 && swapon /swapfile1

emerge-webrsync
emerge --sync --quiet
emerge -u world

# setup networking
cd /etc/init.d
ln -s net.lo net.eth0
ln -s net.lo net.eth1
rc-update add net.lo default
rc-update add net.eth0 default
rc-update add net.eth1 default
rc-update add netmount default
rc-update add sshd default

# kernel recompile
emerge gentoo-sources
cd /usr/src/linux
wget http://KICK_HOST/kickstarts/Gentoo_PVHVM_kernel_config
mv Gentoo_PVHVM_kernel_config .config
make olddefconfig
make  && make modules_install
cp arch/x86_64/boot/bzImage /boot/kernel-gentoo-pvhvm
cp .config /boot/config

# update fstab
cat > /etc/fstab<<EOF
# /etc/fstab: static file system information.
#
# Use 'blkid' to print the universally unique identifier for a
# device; this may be used with UUID= as a more robust way to name devices
# that works even if disks are added and removed. See fstab(5).
#
# <file system> <mount point>   <type>  <options>       <dump>  <pass>
/dev/xvda1  /               ext4    errors=remount-ro,noatime,barrier=0 0       1
#/dev/xvdc1 none            swap    sw              0       0

EOF

# misc portage installs
emerge iproute2
emerge vim
emerge logrotate
emerge syslog-ng
rc-update add syslog-ng default
emerge vixie-cron
rc-update add vixie-cron default

cd /boot
wget http://dd9ae84647939c3a4e29-34570634e5b2d7f40ba94fa8b6a989f4.r72.cf5.rackcdn.com/growpart-initramfs

# setup grub legacy
USE="-ncurses" emerge sys-boot/grub:0
cat > /boot/grub/grub.conf<<EOF
# This is a sample grub.conf for use with Genkernel, per the Gentoo handbook
# http://www.gentoo.org/doc/en/handbook/handbook-x86.xml?part=1&chap=10#doc_chap2
# If you are not using Genkernel and you need help creating this file, you
# should consult the handbook. Alternatively, consult the grub.conf.sample that
# is included with the Grub documentation.

default 0
timeout 5
#splashimage=(hd0,0)/boot/grub/splash.xpm.gz

title Gentoo Linux PVHVM
root (hd0,0)
kernel /boot/kernel-gentoo-pvhvm root=/dev/xvda1 ro
initrd /boot/growpart-initramfs
# vim:ft=conf:

EOF

cat > /boot/grub/device.map<<EOF
(fd0)   /dev/fd0
(hd0)   /dev/sda
(hd1)   /dev/sdb
(hd2)   /dev/sdc
EOF
grep -v rootfs /proc/mounts > /etc/mtab
grub-install --no-floppy /dev/sda

# install xen tools
mkdir /root/xe-guest-utilities
cd /root/xe-guest-utilities
emerge app-arch/rpm2targz
emerge app-arch/rpm
wget http://KICK_HOST/packages/xstools/6.2/xe-guest-utilities-6.2.0-1120.x86_64.rpm
wget http://KICK_HOST/packages/xstools/6.2/xe-guest-utilities-xenstore-6.2.0-1120.x86_64.rpm
wget http://ce3598b91333d7474379-b85ce4d8c2253d3876bef92f62a263f8.r84.cf5.rackcdn.com/gentoo-install-xe-guest-utilities.sh
chmod +x gentoo-install-xe-guest-utilities.sh
./gentoo-install-xe-guest-utilities.sh /root/xe-guest-utilities x86_64
rc-update add xe-daemon default

# guest utilities kludge
/usr/bin/xenstore-write attr/PVAddons/MajorVersion 6
/usr/bin/xenstore-write attr/PVAddons/MinorVersion 1
/usr/bin/xenstore-write attr/PVAddons/MicroVersion 0
/usr/bin/xenstore-write data/updated 1

# install agent
mkdir /root/nova-agent
cd /root/nova-agent
wget http://KICK_HOST/nova-agent/nova-agent-Linux-x86_64-1.39.1.tar.gz
tar xzvf nova-agent-Linux-x86_64-1.39.1.tar.gz
sh installer.sh
rc-update del nova-agent default
rc-update add nova-agent boot

#install cloud-init
cat > /etc/portage/package.accept_keywords <<'EOF'
=dev-python/oauth-1.0.1-r1 ~amd64
=app-emulation/cloud-init-0.7.5-r1 ~amd64
=dev-python/jsonpointer-1.7 ~amd64
=dev-python/jsonpatch-1.9 ~amd64
EOF
eselect python set python2.7
emerge cloud-init

sed -i 's?depend() {?depend() {\n  after net?g' /etc/init.d/cloud-init-local
chmod +x /etc/init.d/cloud*
cat > /etc/cloud/cloud.cfg.d/10_rackspace.cfg <<'EOF'
system_info:
   distro: gentoo
   default_user:
      name: gentoo
      lock_passwd: True
      gecos: Gentoo
      groups: []
      sudo: ["ALL=(ALL) NOPASSWD:ALL"]
      shell: /bin/bash
      package_mirrors: []

locale: en_US.UTF-8 UTF-8
disable_root: 0
ssh_pwauth: 1
ssh_deletekeys:   0
resize_rootfs: 0
syslog_fix_perms:
ssh_genkeytypes: ['rsa', 'dsa']
bootcmd:
 - ip address flush dev eth1
 - /etc/init.d/net.eth1 restart
runcmd:
 - echo "net.ipv4.tcp_rmem = $(cat /proc/sys/net/ipv4/tcp_mem)" >> /etc/sysctl.conf
 - echo "net.ipv4.tcp_wmem = $(cat /proc/sys/net/ipv4/tcp_mem)" >> /etc/sysctl.conf
 - echo "net.core.rmem_max = $(cat /proc/sys/net/ipv4/tcp_mem | awk {'print $3'})" >> /etc/sysctl.conf
 - echo "net.core.wmem_max = $(cat /proc/sys/net/ipv4/tcp_mem | awk {'print $3'})" >> /etc/sysctl.conf
 - echo 'net.ipv4.tcp_window_scaling = 1' >> /etc/sysctl.conf
 - echo 'net.ipv4.tcp_timestamps = 1' >> /etc/sysctl.conf
 - echo 'net.ipv4.tcp_sack = 1' >> /etc/sysctl.conf
 - sysctl -p
EOF

cat > /etc/cloud/cloud.cfg.d/90_dpkg.cfg<<EOF
# to update this file, run dpkg-reconfigure cloud-init
datasource_list: [ ConfigDrive, None ]
EOF
rc-update add cloud-config default
rc-update add cloud-init-local default
rc-update add cloud-init default
rc-update add cloud-final default
rm -rf /root/cloud*

# cloud-init kludges
echo -n > /etc/udev/rules.d/70-persistent-net.rules
echo -n > /lib/udev/rules.d/75-persistent-net-generator.rules
# fix logging
sed -i 's/ - \[ \*log_base, \*log_syslog ]/# - \[ \*log_base, \*log_syslog ]/g' /etc/cloud/cloud.cfg.d/05_logging.cfg

#Adding in for upcoming dhcp net options
emerge dhcpcd
#Prevent dhcpcd from blowing away working resolv.conf
#sed -i 's$config_0="dhcp"$#config_0="dhcp"$g' /etc/init.d/net.lo

cat > /etc/hosts <<'EOF'
127.0.0.1   localhost

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
EOF

# set some stuff
echo 'net.ipv4.conf.eth0.arp_notify = 1' >> /etc/sysctl.conf
echo 'vm.swappiness = 0' >> /etc/sysctl.conf
rc-update del swapfiles boot

# one shots
emerge --oneshot --verbose ">=dev-libs/openssl-0.9.8z_p5-r1"
USE='+bindist' emerge --oneshot --verbose ">=dev-libs/openssl-1.0.1l-r1"
emerge net-misc/curl
emerge sudo
emerge gentoolkit
revdep-rebuild
sleep 5

# Fix networking nova-agent bug - REMOVE after nova-agent fix gets upstream
sed -i 's?export PYTHONHOME="$NOVA_PYTHONPATH:$PYTHONPATH"?export PYTHONHOME="$NOVA_PYTHONPATH:$PYTHONPATH"\n\nconfig="/etc/conf.d/nova-agent"\nif [ -f "$config" ]\nthen\n  source $config\nfi?g' /etc/init.d/nova-agent

# log packages
wget http://KICK_HOST/kickstarts/package_postback.sh
bash package_postback.sh Gentoo_PVHVM

# clean up
eselect news read all
eclean-dist --destructive
passwd -d root
rm -f /usr/portage/distfiles/*
rm -f /etc/ssh/ssh_host_*
rm -f /etc/resolv.conf
rm -f /root/.bash_history
rm -f /root/.nano_history
rm -f /root/.lesshst
rm -f /root/.ssh/known_hosts
rm -rf /root/nova-agent
rm -rf /root/xe-guest-utilities
for k in $(find /var/log -type f); do echo > $k; done
for k in $(find /tmp -type f); do rm -f $k; done

# cleanup
#swapoff /swapfile1 && rm -rf /swapfile1
rm -rf /stage3-amd64*
echo "Exiting Chroot..."
