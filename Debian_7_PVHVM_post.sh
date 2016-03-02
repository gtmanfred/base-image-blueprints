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
cloud_init_modules:
 - resizefs
 - set_hostname
 - update_hostname
 - update_etc_hosts
 - ca-certs
 - rsyslog
 - ssh
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
127.0.0.1 localhost

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
/dev/xvda1  /               ext3    errors=remount-ro,noatime,barrier=0 0       1
#/dev/xvdc1 none            swap    sw              0       0
EOF

# keep grub2 from using UUIDs and regenerate config
sed -i 's/#GRUB_DISABLE_LINUX_UUID.*/GRUB_DISABLE_LINUX_UUID="true"/g' /etc/default/grub
update-grub

# remove cd-rom from sources.list
sed -i '/.*cdrom.*/d' /etc/apt/sources.list

# nova-agent decided to start throwing "no xenstore" errors
# temp hack around
cat > /etc/init.d/xe-linux-distribution <<'EOF'
#!/bin/bash
#
# xe-linux-distribution Write Linux distribution information to XenStore.
#
# chkconfig: 2345 14 86
# description: Writes Linux distribution version information to XenStore.
#
### BEGIN INIT INFO
# Provides:          xe-linux-distribution
# Required-Start:    $local_fs
# Required-Stop:     $local_fs
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: XenServer Virtual Machine daemon providing host integration services
# Description:       Writes Linux distribution version information to XenStore.
### END INIT INFO

LANG="C"
export LANG

if [ -f /etc/init.d/functions ] ; then
. /etc/init.d/functions
else
action()
{
    descr=$1 ; shift
    cmd=$@
    echo -n "$descr "
    $cmd
    ret=$?
    if [ $ret -eq 0 ] ; then
  echo "OK"
    else
  echo "Failed"
    fi
    return $ret
}
fi

XE_LINUX_DISTRIBUTION=/usr/sbin/xe-linux-distribution
XE_LINUX_DISTRIBUTION_CACHE=/var/cache/xe-linux-distribution
XE_DAEMON=/usr/sbin/xe-daemon
XE_DAEMON_PIDFILE=/var/run/xe-daemon.pid

if [ ! -x "${XE_LINUX_DISTRIBUTION}" ] ; then
    exit 0
fi

start()
{
    if [ ! -e /proc/xen/xenbus ] ; then
  if [ ! -d /proc/xen ] ; then
      action $"Mounting xenfs on /proc/xen:" /bin/false
      echo "Could not find /proc/xen directory."
      echo "You need a post 2.6.29-rc1 kernel with CONFIG_XEN_COMPAT_XENFS=y and CONFIG_XENFS=y|m"
      exit 1
  else
      # This is needed post 2.6.29-rc1 when /proc/xen support was pushed upstream as a xen filesystem
      action $"Mounting xenfs on /proc/xen:" mount -t xenfs none /proc/xen
  fi
    fi

    if [ -e /proc/xen/capabilities ] && grep -q control_d /proc/xen/capabilities ; then
  # Do not want daemon in domain 0
  exit 0
    fi

    action $"Detecting Linux distribution version:" \
  ${XE_LINUX_DISTRIBUTION} ${XE_LINUX_DISTRIBUTION_CACHE}

    action $"Starting xe daemon: " /bin/true
    mkdir -p $(dirname ${XE_DAEMON_PIDFILE})
    # This is equivalent to daemon() in C
    ( exec &>/dev/null ; ${XE_DAEMON} -p ${XE_DAEMON_PIDFILE} & )
}

stop()
{
    action $"Stopping xe daemon: "   kill -TERM $(cat ${XE_DAEMON_PIDFILE})
}

# fail silently if not running xen
if [ ! -d /proc/xen ]; then
   exit
fi

case "$1" in
  start)
        start
        ;;
  stop)
  stop
  ;;
  force-reload|restart)
  stop
  start
  ;;
  *)
        # do not advertise unreasonable commands that there is no reason
        # to use with this device
        echo $"Usage: $0 start|restart"
        exit 1
esac

exit $?
EOF

cat > /usr/share/nova-agent/1.39.0/etc/generic/nova-agent <<'EOF'
#!/bin/sh

# vim: tabstop=4 shiftwidth=4 softtabstop=4
#
#  Copyright (c) 2011 Openstack, LLC.
#  All Rights Reserved.
#
#     Licensed under the Apache License, Version 2.0 (the "License"); you may
#     not use this file except in compliance with the License. You may obtain
#     a copy of the License at
#
#          http://www.apache.org/licenses/LICENSE-2.0
#
#     Unless required by applicable law or agreed to in writing, software
#     distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#     WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#     License for the specific language governing permissions and limitations
#     under the License.
#
# nova-agent  Startup script for OpenStack nova guest agent
#
# RedHat style init header:
#
# chkconfig: 2345 15 85
# description: nova-agent is an agent meant to run on unix guest instances \
#              being managed by OpenStack nova.  Currently only works with \
#              Citrix XenServer for manipulating the guest through \
#              xenstore.
# processname: nova-agent
# pidfile: /var/run/nova-agent.pid
#
# LSB style init header:
#
### BEGIN INIT INFO
# Provides: Nova-Agent
# Required-Start: $remote_fs $syslog xe-linux-distribution
# Required-Stop: $remote_fs $syslog
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Short-Description: Start nova-agent at boot time
# Description: nova-agent is a guest agent for OpenStack nova.
### END INIT INFO

# Source function library.
if [ -e "/etc/rc.d/init.d/functions" ]
then
  . /etc/rc.d/init.d/functions
fi

prefix="/usr"
exec_prefix="${prefix}"
sbindir="${exec_prefix}/sbin"
datadir="${prefix}/share/nova-agent"
reallibdir="/usr/share/nova-agent/1.39.0/lib"

nova_agent="${sbindir}/nova-agent"
agent_config="/usr/share/nova-agent/nova-agent.py"
pidfile="/var/run/nova-agent.pid"
logfile="/var/log/nova-agent.log"
loglevel="debug"

#####
# Setting PYTHONPATH Environment Variable:
#   Use NOVA-AGENT packaged Python libraries in precedence, if required then
#     depend on System Python library packages.
#   This helps with Bintar made on earlier minor version say v2.6 to be used
#     with system having v2.7 default python setup.
#####
NOVA_PYTHONPATH=`ls -l $reallibdir | grep '^d' | awk '{print \$NF}'`
NOVA_PYTHONPATH=`echo $NOVA_PYTHONPATH | grep 'python[0-9]\.[0-9]'`
NOVA_PYTHONPATH="${reallibdir}/${NOVA_PYTHONPATH}"
NOVA_PYTHONPATH="${NOVA_PYTHONPATH}:${NOVA_PYTHONPATH}/site-packages"

if [ `which python > /dev/null 2>&1 ; echo $?` -eq 0 ]; then
  PYTHONPATH="$(python -c 'import sys; print ":".join(sys.path)')"
fi
export PYTHONPATH="$NOVA_PYTHONPATH:$PYTHONPATH"


do_start() {
  LD_LIBRARY_PATH="${reallibdir}"
  export LD_LIBRARY_PATH
  ${nova_agent} -q -p ${pidfile} -o ${logfile} -l ${loglevel} ${agent_config}
}

do_stop() {
  num_tries=0
  while [ $num_tries -lt 10 ] ; do
    if [ ! -f ${pidfile} ] ; then
        break
    fi
    if [ $num_tries -eq 0 ] ; then
      pid=`cat ${pidfile}`
      if [ $? -eq 0 ] ; then
        kill $pid
      fi
    fi
    num_tries=`expr $num_tries + 1`
    sleep 1
  done
  rm -f ${pidfile}
}

SCRIPTNAME=$0

case "$1" in
  start)
    do_start
    ;;
  stop)
    do_stop
    ;;
  restart)
    do_stop
    do_start
    ;;
  *)
    echo "Usage: $SCRIPTNAME {start|stop|restart}" >&2
    exit 3
    ;;
esac
EOF

# cloud-init / nova-agent sad panda hack
cat > /etc/init.d/cloud-init-local <<'EOF'
#! /bin/sh
### BEGIN INIT INFO
# Provides:          cloud-init-local
# Required-Start:    $local_fs $remote_fs $network
# Required-Stop:
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Cloud init local
# Description:       Cloud configuration initialization
### END INIT INFO

# Authors: Julien Danjou <acid@debian.org>
#          Juerg Haefliger <juerg.haefliger@hp.com>

PATH=/sbin:/usr/sbin:/bin:/usr/bin
DESC="Cloud service"
NAME=cloud-init
DAEMON=/usr/bin/$NAME
DAEMON_ARGS="init --local"
SCRIPTNAME=/etc/init.d/$NAME

sleep 10

# Exit if the package is not installed
[ -x "$DAEMON" ] || exit 0

# Read configuration variable file if it is present
[ -r /etc/default/$NAME ] && . /etc/default/$NAME

# Define LSB log_* functions.
# Depend on lsb-base (>= 3.2-14) to ensure that this file is present
# and status_of_proc is working.
. /lib/lsb/init-functions

if init_is_upstart; then
  case "$1" in
  stop)
    exit 0
  ;;
  *)
    exit 1
  ;;
  esac
fi

case "$1" in
start)
  log_daemon_msg "Starting $DESC" "$NAME"
  $DAEMON ${DAEMON_ARGS}
  case "$?" in
    0|1) log_end_msg 0 ;;
    2) log_end_msg 1 ;;
  esac
;;
stop|restart|force-reload)
  echo "Error: argument '$1' not supported" >&2
  exit 3
;;
*)
  echo "Usage: $SCRIPTNAME {start}" >&2
  exit 3
;;
esac

:
EOF

insserv xe-linux-distribution
insserv nova-agent

# log packages
wget http://10.69.246.205/kickstarts/package_postback.sh
bash package_postback.sh Debian_7_PVHVM

# clean up
passwd -d root
apt-get -y clean
apt-get -y autoremove
rm -f /etc/ssh/ssh_host_*
rm -f /var/cache/apt/archives/*.deb
rm -f /var/cache/apt/*cache.bin
rm -f /var/lib/apt/lists/*_Packages
rm -f /root/.bash_history
rm -f /root/.nano_history
rm -f /root/.lesshst
rm -f /root/.ssh/known_hosts
for k in $(find /var/log -type f); do echo > $k; done
for k in $(find /tmp -type f); do rm -f $k; done
