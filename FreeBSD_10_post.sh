#!/bin/sh
export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:
env ASSUME_ALWAYS_YES=YES pkg bootstrap
pkg install -fy xen-tools
pkg install -fy xe-guest-utilities
pkg install -fy wget
pkg install -fy sudo
pkg install -fy gsed
pkg install -fy e2fsprogs
pkg install -fy curl
pkg install -fy python
pkg install -fy py27-setuptools27
pkg install -fy py27-pip
echo 'sshd_enable="YES"' >> /etc/rc.conf
echo 'xenguest_enable="YES"' >> /etc/rc.conf
echo 'nova_agent_enable="YES"' >> /etc/rc.conf
echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
cat >> /boot/loader.conf <<'EOF'
# shorter boot delay
autoboot_delay=1
# Disable gpt/gptid labels
kern.geom.label.gptid.enable=0
kern.geom.label.gpt.enable=0
EOF
##cat > /etc/rc.local <<'EOF'
###!/bin/sh
##rm /tmp/installscript
##cat > /etc/rc.local <<'IOF'
###!/bin/sh
##exit 0
##IOF
##EOF

##
## cloud-init
##

echo "Installing cloud-init..."
pkg install -fy py27-cloud-init
pkg lock -y py27-cloud-init
gsed -i '/^# REQUIRE:/s/.*/# REQUIRE: mountcritlocal mountcritremote FILESYSTEMS/' /usr/local/etc/rc.d/cloudinitlocal
gsed -i '/^# BEFORE/s/.*/# BEFORE: cloudinit cloudconfig cloudfinal\n# AFTER: NETWORKING/g' /usr/local/etc/rc.d/cloudinitlocal
gsed -i '/starting/a\        sleep 20' /usr/local/etc/rc.d/cloudinit
echo 'cloudinit_enable="YES"' >> /etc/rc.conf

patch /usr/local/lib/python2.7/site-packages/cloudinit/sources/DataSourceConfigDrive.py <<'EOF'
40,42c40,41
< POSSIBLE_MOUNTS = ('sr', 'cd')
< OPTICAL_DEVICES = tuple(('/dev/%s%s' % (z, i) for z in POSSIBLE_MOUNTS
<                   for i in range(0, 2)))
---
> #POSSIBLE_MOUNTS = ('sr', 'cd')
> OPTICAL_DEVICES = tuple(('/dev/ada%s' % i for i in range(2, 4)))
76c75
<                     if dev.startswith("/dev/cd"):
---
>                     if self.distro.osfamily == 'freebsd':
EOF
rm -f /usr/local/lib/python2.7/site-packages/cloudinit/sources/DataSourceConfigDrive.pyc

patch /usr/local/lib/python2.7/site-packages/cloudinit/distros/freebsd.py <<'EOF'
374c374
<         return
---
>         self.package_command('install', pkgs=pkglist)
376,377c376,396
<     def package_command(self, cmd, args=None, pkgs=None):
<         return
---
>     def package_command(self, command, args=None, pkgs=None):
>         if pkgs is None:
>             pkgs = []
>
>         cmd = ['pkg']
>
>         if args and isinstance(args, str):
>             cmd.append(args)
>         elif args and isinstance(args, list):
>             cmd.extend(args)
>
>         if command:
>             cmd.append(command)
>
>         cmd.append('-y')
>
>         pkglist = util.expand_package_list('%s-%s', pkgs)
>         cmd.extend(pkglist)
>
>         # Allow the output of this to flow outwards (ie not be captured)
>         util.subp(cmd, capture=False)
EOF
rm -f /usr/local/lib/python2.7/site-packages/cloudinit/distros/freebsd.pyc

## the config
ln -s /usr/local/etc/cloud /etc/cloud
gsed -i '/^datasource_list/s/^/#/' /usr/local/etc/cloud/cloud.cfg
gsed -i '/^ - growpart/s/^/#/' /usr/local/etc/cloud/cloud.cfg
gsed -i '/^ - resizefs/s/^/#/' /usr/local/etc/cloud/cloud.cfg
gsed -i '/^# - package-update-upgrade-install/s/^#//' /usr/local/etc/cloud/cloud.cfg
gsed -i '/^ - \[ \*log_base, \*log_syslog ]/s/^/#/' /usr/local/etc/cloud/cloud.cfg.d/05_logging.cfg

cat > /usr/local/etc/cloud/cloud.cfg.d/10_rackspace.cfg <<'EOF'
datasource_list: [ ConfigDrive , None ]
disable_root: False
disable_root_opts: no-port-forwarding,no-agent-forwarding,no-X11-forwarding
ssh_pwauth: True
ssh_deletekeys: False
resize_rootfs: False
syslog_fix_perms:
system_info:
  distro: freebsd
  default_user:
    name: freebsd
    lock_passwd: True
    gecos: FreeBSD
    groups: []
    sudo: ["ALL=(ALL) NOPASSWD:ALL"]
    shell: /bin/sh
    package_mirrors: []
bootcmd:
 - gpart recover ada0
 - gpart resize -i 3 ada0
 - zpool online -e zroot ada0p3
EOF
echo 'Done'

pkg upgrade -fy
gsed -i 's/3600/30/g' /usr/sbin/freebsd-update
freebsd-update cron
freebsd-update install
gsed -i 's/30/3600/g' /usr/sbin/freebsd-update

# installed packages list
cat > /root/tmp/packages.sh <<'EOF'
#!/bin/csh
foreach i ( `pkg info | awk -F '  ' '{print $1}'` )
	echo $i $i
end
EOF
chmod +x /root/tmp/packages.sh
CONFIG_LABEL=FreeBSD_10
IMAGE_ID=$(curl -X GET -H 'Accept: text/plain' http://POSTBACK_HOST/api/image_id/$CONFIG_LABEL)
/root/tmp/packages.sh > /root/tmp/packages.txt
curl -X POST -H 'Accept: application/json' -H "Content-Type: application/json" -d "$(cat /root/tmp/packages.txt)" http://POSTBACK_HOST/api/pkg_info/$CONFIG_LABEL/$IMAGE_ID/pkg
wget http://KICK_HOST/nova-agent/nova-agent-FreeBSD-amd64-1.39.1.tar.gz
tar xzvf nova-agent-FreeBSD-amd64-1.39.1.tar.gz
sh installer.sh
# clean up
rm -rf /root/tmp
rm -rf /var/lib/cloud
rm -f /etc/ssh/ssh_host*
rm -f /var/log/*
