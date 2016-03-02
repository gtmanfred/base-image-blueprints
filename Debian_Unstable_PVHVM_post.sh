#!/bin/bash

# fix bootable flag
parted -s /dev/xvda set 1 boot on

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
ssh_pwauth: True
ssh_deletekeys: False
resize_rootfs: noblock
apt_preserve_sources_list: True
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
echo 'net.ipv4.conf.eth0.arp_notify = 1' >> /etc/sysctl.conf
echo 'vm.swappiness = 0' >> /etc/sysctl.conf

cat >> /etc/sysctl.conf <<'EOF'
net.ipv4.tcp_rmem = 4096 87380 33554432
net.ipv4.tcp_wmem = 4096 65536 33554432
net.core.rmem_max = 33554432
net.core.wmem_max = 33554432
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_timestamps = 1
net.ipv4.tcp_sack = 1
EOF

# our fstab is fonky
cat > /etc/fstab <<'EOF'
# /etc/fstab: static file system information.
#
# Use 'blkid' to print the universally unique identifier for a
# device; this may be used with UUID= as a more robust way to name devices
# that works even if disks are added and removed. See fstab(5).
#
# <file system> <mount point>   <type>  <options>       <dump>  <pass>
/dev/xvda1	/               ext3    errors=remount-ro,noatime,barrier=0 0       1
#/dev/xvdc1	none            swap    sw              0       0
EOF

# keep grub2 from using UUIDs and regenerate config
sed -i 's/#GRUB_DISABLE_LINUX_UUID.*/GRUB_DISABLE_LINUX_UUID="true"/g' /etc/default/grub
update-grub

# remove cd-rom from sources.list
sed -i '/.*cdrom.*/d' /etc/apt/sources.list

# cloud-init / nova-agent sad panda hacks
cat > /lib/systemd/system/cloud-init-local.service <<'EOF'
[Unit]
Description=Initial cloud-init job (pre-networking)
Wants=local-fs.target
After=local-fs.target

[Service]
Type=oneshot
ExecStartPre=/bin/sleep 20
ExecStart=/usr/bin/cloud-init init --local
RemainAfterExit=yes
TimeoutSec=0

# Output needs to appear in instance console output
StandardOutput=journal+console

[Install]
WantedBy=multi-user.target
EOF

# this is broken upstream now, not sure why
# but it's causing cloud-init services to start out of order and
# is starting cloud-config first, which is not good
cat > /lib/systemd/system/cloud-config.service <<'EOF'
[Unit]
Description=Apply the settings specified in cloud-config
After=network.target syslog.target cloud-init.service
Requires=cloud-init.service
Wants=network.target

[Service]
Type=oneshot
ExecStart=/usr/bin/cloud-init modules --mode=config
RemainAfterExit=yes
TimeoutSec=0

# Output needs to appear in instance console output
StandardOutput=journal+console

[Install]
WantedBy=multi-user.target
EOF

# some systemd workarounds
sed -i 's/XenServer Virtual Machine Tools/xe-linux-distribution/g' /etc/init.d/xe-linux-distribution
update-rc.d xe-linux-distribution defaults

# intention is to move this bit into nova-agent instead
cat > /lib/systemd/system/nova-agent.service <<'EOF'
[Unit]
Description=nova-agent
Wants=local-fs.target
After=local-fs.target xe-linux-distribution.service

[Service]
Type=oneshot
ExecStart=/etc/init.d/nova-agent start
RemainAfterExit=yes
TimeoutSec=0

# Output needs to appear in instance console output
StandardOutput=journal+console

[Install]
WantedBy=multi-user.target
EOF
systemctl enable xe-linux-distribution
systemctl enable nova-agent
systemctl enable cloud-init-local
systemctl enable cloud-init
systemctl enable cloud-config
systemctl enable cloud-final

# ssh permit rootlogin
sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/g' /etc/ssh/sshd_config

# cloud-init doesn't generate a ssh_host_ed25519_key
cat > /etc/rc.local <<'EOF'
#!/bin/bash
dpkg-reconfigure openssh-server
echo '#!/bin/bash' > /etc/rc.local
echo 'exit 0' >> /etc/rc.local
EOF

# log packages
wget http://10.69.246.205/kickstarts/package_postback.sh
bash package_postback.sh Debian_Unstable_PVHVM

# clean up
passwd -d root
apt-get -y clean
#apt-get -y autoremove
rm -f /etc/ssh/ssh_host_*
rm -f /var/cache/apt/archives/*.deb
rm -f /var/cache/apt/*cache.bin
rm -f /var/lib/apt/lists/*_Packages
rm -f /etc/hostname
rm -f /root/.bash_history
rm -f /root/.nano_history
rm -f /root/.lesshst
rm -f /root/.ssh/known_hosts
for k in $(find /var/log -type f); do echo > $k; done
for k in $(find /tmp -type f); do rm -f $k; done
