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
pkg install -fy py27-jsonpatch
pkg install -fy py27-requests
pkg install -fy py27-argparse
pkg install -fy py27-configobj
pkg install -fy py27-pyserial
pkg install -fy py27-oauth
pkg install -fy py27-prettytable
pkg install -fy py27-cheetah
pkg install -fy py27-jsonpointer
pip install pyyaml
pip install pyserial
pip install six
echo 'sshd_enable="YES"' >> /etc/rc.conf
echo 'xenguest_enable="YES"' >> /etc/rc.conf
echo 'nova_agent_enable="YES"' >> /etc/rc.conf
echo 'cloudinit_enable="YES"' >> /etc/rc.conf
echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
cat >> /boot/loader.conf <<'EOF'
# shorter boot delay
autoboot_delay=1
# Disable gpt/gptid labels
kern.geom.label.gptid.enable=0
kern.geom.label.gpt.enable=0
EOF
cat > /etc/rc.local <<'EOF'
#!/bin/sh
rm /tmp/installscript
cat > /etc/rc.local <<'IOF'
#!/bin/sh
exit 0
IOF
EOF
wget http://dd9ae84647939c3a4e29-34570634e5b2d7f40ba94fa8b6a989f4.r72.cf5.rackcdn.com/cloud-init-fbsd.tar.gz
tar xzvf cloud-init*
cd cloud-init-fbsd
python setup.py install
gsed 's%# BEFORE.*%# BEFORE: FILESYSTEMS cloudinit cloudconfig cloudfinal\n# AFTER: NETWORKING%g' sysvinit/freebsd/cloudinitlocal
cp sysvinit/freebsd/cloud* /usr/local/etc/rc.d/
chmod +x /usr/local/etc/rc.d/cloud*
gsed -i 's/ - \[ \*log_base, \*log_syslog ]/# - \[ \*log_base, \*log_syslog ]/g' /etc/cloud/cloud.cfg.d/05_logging.cfg
gsed -i 's/WARNING/DEBUG/g' /etc/cloud/cloud.cfg.d/05_logging.cfg
#
cat > /etc/cloud/cloud.cfg.d/10_rackspace.cfg <<'EOF'
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
 - gpart resize -i 2 ada0
 - zpool online -e zroot ada0p2
EOF
# doing this breaks things with cloud-init
#pkg remove -fy py27-setuptools27 py27-pip
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
wget --no-check-certificate https://github.com/rackerlabs/openstack-guest-agents-unix/releases/download/v1.39.0/nova-agent-FreeBSD-amd64-1.39.0.tar.gz
tar xzvf nova-agent-FreeBSD-amd64-1.39.0.tar.gz
sh installer.sh
# clean up
rm -rf /root/tmp
rm -rf /var/lib/cloud
rm -f /etc/ssh/ssh_host*
rm -f /var/log/*
