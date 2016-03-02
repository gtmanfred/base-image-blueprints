# configs
#preseed partman-basicfilesystems/no_swap boolean false
#preseed debian-installer/exit/poweroff boolean true
#preseed finish-install/reboot_in_progress note
#preseed partman/mount_style select traditional
#preseed user-setup/allow-password-weak boolean true
#preseed cdrom-detect/eject boolean false
#preseed cloud-init/datasources string NoCloud, ConfigDrive

# apt preseeds, note the release versions here
#preseed apt-setup/security_host string mirror.rackspace.com
#preseed apt-setup/security_path string /ubuntu lucid-security

# fix bootable flag
parted -s /dev/xvda set 1 boot on

# tmp tmp
mkdir /tmp/tmp
cd /tmp/tmp

# install xen tools
#wget http://ce3598b91333d7474379-b85ce4d8c2253d3876bef92f62a263f8.r84.cf5.rackcdn.com/xe-guest-utilities_6.2.0-1120_amd64.deb
#dpkg -i xe-guest-utilities_6.2.0-1120_amd64.deb

# install agent
#wget https://github.com/rackerlabs/openstack-guest-agents-unix/releases/download/1.39.1/nova-agent_1.39.1_all.deb
#dpkg -i nova-agent_1.39.1_all.deb
wget http://10.69.246.205/nova-agent/nova-agent-Linux-x86_64-1.39.1.tar.gz
tar xzvf nova-agent*tar.gz
sh installer.sh
# 10.04 won't add startup scripts properly, forcing it
update-rc.d -f nova-agent defaults

# cloud-init kludges
echo -n > /etc/udev/rules.d/70-persistent-net.rules
echo -n > /lib/udev/rules.d/75-persistent-net-generator.rules

# cloud-init config
#cat > /etc/cloud/cloud.cfg.d/10_rackspace.cfg <<'EOF'
#user: root
#disable_root: 0
#ssh_pwauth:   1
#ssh_deletekeys:   0
#resize_rootfs: False
#EOF

# cloud-init must be beaten with hammer
# preseeding these values isnt working, forcing it here
#echo "cloud-init cloud-init/datasources string NoCloud, ConfigDrive" > /tmp/tmp/debconf-selections
#/usr/bin/debconf-set-selections /tmp/tmp/debconf-selections
#dpkg-reconfigure cloud-init

# set some stuff
echo 'net.ipv4.conf.eth0.arp_notify = 1' >> /etc/sysctl.conf
echo 'vm.swappiness = 0' >> /etc/sysctl.conf

# our fstab is fonky
cat > /etc/fstab <<'EOF'
# /etc/fstab: static file system information.
#
# Use 'blkid' to print the universally unique identifier for a
# device; this may be used with UUID= as a more robust way to name devices
# that works even if disks are added and removed. See fstab(5).
#
# <file system> <mount point>   <type>  <options>       <dump>  <pass>
/dev/xvda1  /               ext3    errors=remount-ro,noatime 0       1
#/dev/xvdc1 none            swap    sw              0       0
EOF

# set ssh keys to regenerate at first boot only
# 10.04 can't do ecsda
cat > /etc/rc.local <<'EOF'
ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N ''
ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key -N ''
echo > /etc/rc.local
EOF

# keep grub2 from using UUIDs and regenerate config
#sed -i 's/#GRUB_DISABLE_LINUX_UUID.*/GRUB_DISABLE_LINUX_UUID="true"/g' /etc/default/grub
#update-grub

# bleh sources is bunk
cat > /etc/apt/sources.list <<'EOF'
deb http://mirror.rackspace.com/ubuntu lucid main restricted
deb-src http://mirror.rackspace.com/ubuntu lucid main restricted
deb http://mirror.rackspace.com/ubuntu lucid-updates main restricted
deb-src http://mirror.rackspace.com/ubuntu lucid-updates main restricted

deb http://mirror.rackspace.com/ubuntu lucid universe
deb-src http://mirror.rackspace.com/ubuntu lucid universe
#deb http://mirror.rackspace.com/ubuntu lucid-updates universe
#deb-src http://mirror.rackspace.com/ubuntu lucid-updates universe

deb http://mirror.rackspace.com/ubuntu lucid multiverse
deb-src http://mirror.rackspace.com/ubuntu lucid multiverse
#deb http://mirror.rackspace.com/ubuntu lucid-updates multiverse
#deb-src http://mirror.rackspace.com/ubuntu lucid-updates multiverse
EOF

# update
echo 'mirror.rackspace.com 74.205.112.120' > /tmp/tmp/hosts
export HOSTALIASES=/tmp/tmp/hosts
ping -c1 mirror.rackspace.com >> /var/log/installer.log
DEBIAN_FRONTEND=noninteractive
export DEBIAN_FRONTEND=noninteractive
apt-get update >> /var/log/installer.log
apt-get -o Dpkg::Options::="--force-confnew" --force-yes -fuy upgrade >> /var/log/installer.log

# grub legacy for PV Xen guests
#apt-get -y remove --purge grub*
rm -rf /boot/grub
mkdir /boot/grub
yes | apt-get -o Dpkg::Options::="--force-confnew" --force-yes -fuym install grub-legacy-ec2 >> /var/log/installer.log
rm -f /boot/grub/menu.lst
update-grub-legacy-ec2 -y
sed -i 's/# indomU.*/# indomU=false/' /boot/grub/menu.lst
sed -i 's/# kopt=.*/# kopt=root=\/dev\/xvda1 console=hvc0 ro quiet splash/' /boot/grub/menu.lst
update-grub-legacy-ec2 -y

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

# minimal network conf that doesnt dhcp
# causes boot delay if left out, no bueno
cat > /etc/network/interfaces <<'EOF'
auto lo
iface lo inet loopback
auto eth0
iface eth0 inet static
address 0.0.0.0
netmask 0.0.0.0
gateway 0.0.0.0
EOF

# 10.04 console fixes
cat > /etc/init/hvc0.conf <<'EOF'
# hvc0 - getty
#
# This service maintains a getty on hvc0 from the point the system is
# started until it is shut down again.

start on stopped rc RUNLEVEL=[2345]
stop on runlevel [!2345]

respawn
exec /sbin/getty -8 38400 hvc0
EOF

cat >> /etc/securetty <<'EOF'
# Standard hypervisor virtual console
hvc0

# Oldstyle Xen console
xvc0
EOF

# log packages
wget http://10.69.246.205/kickstarts/package_postback.sh
bash package_postback.sh Ubuntu_10.04

# clean up
passwd -d root
apt-get -y clean
apt-get -y autoremove
sed -i '/.*cdrom.*/d' /etc/apt/sources.list
rm -f /etc/ssh/ssh_host_*
rm -f /var/cache/apt/archives/*.deb
rm -f /var/cache/apt/*cache.bin
rm -f /var/lib/apt/lists/*_Packages
#rm -f /etc/resolv.conf
rm -f /root/.bash_history
rm -f /root/.nano_history
rm -f /root/.lesshst
rm -f /root/.ssh/known_hosts
rm -rf /tmp/tmp
for k in $(find /var/log -type f); do echo > $k; done
for k in $(find /tmp -type f); do rm -f $k; done
for k in $(find /root -type f \( ! -iname ".*" \)); do rm -f $k; done

