#!/bin/bash

source /etc/profile
export PS1="(chroot) $PS1"

# change root password
(echo novaagentneedsunlockedrootaccountsowedeletepasswordinpost ; sleep 3; echo novaagentneedsunlockedrootaccountsowedeletepasswordinpost) | passwd

# update tz info
cp /usr/share/zoneinfo/UTC /etc/localtime
echo "UTC" > /etc/timezone

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

mv /dev/random /dev/random.bak && ln -s /dev/urandom /dev/random
pacman-key --init
pacman-key --populate archlinux
rm -rf /dev/random && mv /dev/random.bak /dev/random
export arch=x86

pacman -Syy
pacman -Sy grep sed --noconfirm

#set up locale
cat > /etc/locale.gen<<EOF
en_US.UTF-8 UTF-8
en_US ISO-8859-1
EOF
echo 'LANG="en_US.UTF-8"' > /etc/local.conf
locale-gen

# Install all the things
pacman -S base --noconfirm
## extra packages
pacman -S grub openssh rsyslog cronie sudo rsync wget python python-setuptools python2 python2-setuptools --noconfirm

# install agent
pacman -S xe-guest-utilities --noconfirm
ln -s '/usr/lib/systemd/system/xe-linux-distribution.service' '/etc/systemd/system/multi-user.target.wants/xe-linux-distribution.service'
systemctl enable xe-daemon.service
systemctl enable xe-linux-distribution.service

pacman -S openstack-guest-agents-unix --noconfirm
systemctl enable -f nova-agent.service

## install cloud-init
pacman -S python2-requests cloud-init --noconfirm
#sed -i 's/self.update_package_sources/#self.update_package_sources/g' /usr/lib/python2.7/site-packages/cloudinit/distros/arch.py  # Hack to get lower flavors installing pkgs 

cat > /etc/cloud/cloud.cfg.d/10_rackspace.cfg <<'EOF'
system_info:
   distro: arch
   default_user:
      name: arch
      lock_passwd: True
      gecos: Arch
      groups: []
      sudo: ["ALL=(ALL) NOPASSWD:ALL"]
      shell: /bin/bash
      package_mirrors: []

locale: en_US.UTF-8 UTF-8
disable_root: 0
ssh_pwauth: 1
ssh_deletekeys:   0
resize_rootfs: noblock
syslog_fix_perms:

# The modules that run in the 'config' stage
cloud_config_modules:
# Emit the cloud config ready event
# this can be used by upstart jobs for 'start on cloud-config'.
 - emit_upstart
 - disk_setup
 - mounts
 - ssh-import-id
 - locale
 - set-passwords
 - package-update-upgrade-install
 - timezone
 - puppet
 - chef
 - salt-minion
 - mcollective
 - disable-ec2-metadata
 - runcmd
 - byobu
EOF

cat > /etc/cloud/cloud.cfg.d/90_dpkg.cfg<<EOF
# to update this file, run dpkg-reconfigure cloud-init
datasource_list: [ ConfigDrive, None ]
EOF

# cloud-init kludges
echo -n > /etc/udev/rules.d/70-persistent-net.rules
mkdir -p /etc/systemd/system/cloud-init.service.d
cat > /etc/systemd/system/cloud-init.service.d/delaystart.conf <<'EOF'
[Service]
ExecStartPre=/usr/bin/sleep 12
EOF
#sed -i 's/ - \[ \*log_base, \*log_syslog ]/# - \[ \*log_base, \*log_syslog ]/g' /etc/cloud/cloud.cfg.d/05_logging.cfg
systemctl enable cloud-config.service
systemctl enable cloud-init-local.service
systemctl enable cloud-init.service
systemctl enable cloud-final.service

cat > /etc/sysctl.conf <<'EOF'
net.ipv4.tcp_rmem = 4096 87380 33554432
net.ipv4.tcp_wmem = 4096 65536 33554432
net.core.rmem_max = 33554432
net.core.wmem_max = 33554432
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_timestamps = 1
net.ipv4.tcp_sack = 1
EOF

## rebuild the initramfs with Xen drivers
sed -i '/^MODULES/s/""/"xenfs xen_netfront xen_blkfront crc32_generic crc32c-intel"/g' /etc/mkinitcpio.conf
mkinitcpio -p linux

# get a current version of growpart from launchpad
wget http://bazaar.launchpad.net/~cloud-utils-dev/cloud-utils/trunk/download/head:/growpart-20110225134600-d84xgz6209r194ob-1/growpart -O /usr/bin/growpart && chmod +x /usr/bin/growpart

# Install bootloader
sed -i '/^#GRUB_DISABLE_LINUX_UUID/s/^#//' /etc/default/grub
sed -i '/^GRUB_CMDLINE_LINUX_DEFAULT/s/"quiet"/""/' /etc/default/grub
echo 'GRUB_DISABLE_SUBMENU=y' >> /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg
#sed -i '/^\s*search/s/^/#/' /boot/grub/grub.cfg
sed -i 's#/dev/loop0p1#/dev/xvda1#' /boot/grub/grub.cfg

# Configure services
systemctl enable cronie.service
systemctl enable rsyslog.service
systemctl enable sshd.service

# last update
pacman -Syu --noconfirm

# log packages
wget http://10.69.246.205/kickstarts/package_postback.sh
bash package_postback.sh Arch_PVHVM

# guest utilities kludge
/usr/bin/xenstore-write attr/PVAddons/MajorVersion 6
/usr/bin/xenstore-write attr/PVAddons/MinorVersion 1
/usr/bin/xenstore-write attr/PVAddons/MicroVersion 0
/usr/bin/xenstore-write data/updated 1

# enable systemd resolv config
systemctl enable systemd-resolved.service
resolvconf -u

# clean up
passwd -d root
echo "" > /etc/machine-id
rm -f /etc/ssh/ssh_host_*
rm -f /etc/resolv.conf
rm -f /root/.bash_history
rm -f /root/.nano_history
rm -f /root/.lesshst
rm -f /root/.ssh/known_hosts
rm -rf /root/nova-agent
rm -f /installer.sh #crap pacman guest agent leftovers
rm -rf /tmp/build
find /var/log -type f -exec cp -f /dev/null {} \;
find /tmp -type f -delete
yes | pacman -Scc

# cleanup
echo "Exiting Chroot..."

