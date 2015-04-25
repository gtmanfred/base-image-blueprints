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
sed -i 's/Required DatabaseOptional/Optional TrustAll/g' /etc/pacman.conf
export arch=x86

pacman -Syy
pacman -Sy gzip wget grub bc --noconfirm
pacman -Sy base-devel --noconfirm

#set up locale
cat > /etc/locale.gen<<EOF
en_US.UTF-8 UTF-8
en_US ISO-8859-1
EOF
echo 'LANG="en_US.UTF-8"' > /etc/local.conf
locale-gen

# Install all the things
pacman -Sy grep --noconfirm
pacman -Sy base --noconfirm
pacman -Sy autoconf automake binutils bison dash dnssec-anchors eventlog fakeroot flex gcc git gpm grub haveged keyutils krb5 ldns libedit libidn libltdl libmpc libtool m4 make openssh patch perl-error pkg-config python python2 python2-setuptools rpmextract rsync sqlite syslog-ng sysvinit-tools net-tools sudo wget devtools bc --noconfirm

#Setup man database
/usr/bin/mandb --quiet

# install agent
pacman -Sy xe-guest-utilities --noconfirm
#wget https://aur.archlinux.org/packages/rp/rpm2targz/rpm2targz.tar.gz
ln -s '/usr/lib/systemd/system/xe-linux-distribution.service' '/etc/systemd/system/multi-user.target.wants/xe-linux-distribution.service'
systemctl enable xe-daemon.service
systemctl enable xe-linux-distribution.service

pacman -Sy openstack-guest-agents-unix --noconfirm
systemctl enable -f nova-agent.service
pacman -Sy python-setuptools --noconfirm
pacman -Sy cloud-init --noconfirm
mv /etc/cloud/cloud.cfg.ubuntu_default /etc/cloud/cloud.cfg #pacman build is overwriting default
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
resize_rootfs: 0
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

cat > /etc/cloud/cloud.cfg.d/90_dpkg.cfg<<EOF
# to update this file, run dpkg-reconfigure cloud-init
datasource_list: [ ConfigDrive, None ]
EOF

# cloud-init kludges
echo -n > /etc/udev/rules.d/70-persistent-net.rules
echo -n > /lib/udev/rules.d/75-persistent-net-generator.rules
sed -i 's$After=local-fs.target$After=local-fs.target rc-local.service$g' /usr/lib/systemd/system/cloud-init-local.service
sed -i 's$Type=oneshot$Type=oneshot\nExecStartPre=/usr/bin/sleep 10$g' /usr/lib/systemd/system/cloud-init-local.service
sed -i 's/ - \[ \*log_base, \*log_syslog ]/# - \[ \*log_base, \*log_syslog ]/g' /etc/cloud/cloud.cfg.d/05_logging.cfg
systemctl enable cloud-config.service
systemctl enable cloud-init-local.service
systemctl enable cloud-init.service
systemctl enable cloud-final.service

# Install kernel
rm -rf /boot/*linux*
cd /usr/src
url=https://www.kernel.org
url_suffix=$(curl -L $url| grep -A 1 "latest_link"| tail -1| cut -d "\"" -f 2 | cut -d "." -f 2-)
wget -c $url$url_suffix
filename=$(echo $url_suffix|cut -d "/" -f 6)
dirname=$(echo $filename|cut -d "." -f -3)
if [[ $dirname == *tar* ]]; then dirname=$(echo $filename|cut -d "." -f -2); fi
vername=$(echo $dirname|cut -d "-" -f 2)
tar -xJf $filename
cd $dirname
make mrproper
wget http://KICK_HOST/kickstarts/Arch_PVHVM_kernel_config
mv Arch_PVHVM_kernel_config .config
make olddefconfig
make && make modules_install
cp -v arch/x86/boot/bzImage /boot/vmlinuz-$dirname
mkinitcpio -k $vername -c /etc/mkinitcpio.conf -g /boot/initramfs-$dirname.img

# growpart
wget http://dd9ae84647939c3a4e29-34570634e5b2d7f40ba94fa8b6a989f4.r72.cf5.rackcdn.com/growpart-initramfs
mv growpart-initramfs /boot/

# Install bootloader
cat > /boot/grub/grub.cfg << EOF
timeout=5

menuentry 'Arch Linux $vername' {
root=hd0,1
linux /boot/vmlinuz-$dirname root=/dev/xvda1 init=/usr/lib/systemd/systemd
initrd /boot/growpart-initramfs
}
EOF
grub-install /dev/sda

# Configure services
systemctl enable cronie.service
systemctl enable syslog-ng
systemctl enable sshd

# last update
pacman -Syu --noconfirm

# log packages
wget http://KICK_HOST/kickstarts/package_postback.sh
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
for k in $(find /var/log -type f); do echo > $k; done
for k in $(find /tmp -type f); do rm -f $k; done
yes | pacman -Scc

# cleanup
rm -rf /archlinux-bootstrap*
echo "Exiting Chroot..."

