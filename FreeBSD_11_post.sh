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
CONFIG_LABEL=FreeBSD_11
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
