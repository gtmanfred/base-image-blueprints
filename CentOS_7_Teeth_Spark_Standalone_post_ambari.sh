#!/usr/bin/env bash
###############################################################################
# Ambari Setup for CentOS                                        #
###############################################################################
#                                                                             #
# This script provides all the functionality to setup the necessary packages  #
# for Ambari on CentOS                                           #
#                                                                             #
###############################################################################

AMBARI_VERSION=${AMBARI_VERSION:-"2.1.1"}
HDP_VERSION=${HDP_VERSION:-"2.3.0.0"}


function setup_repos() {
    wget -O /etc/yum.repos.d/ambari.repo http://public-repo-1.hortonworks.com/ambari/centos7/2.x/updates/${AMBARI_VERSION}/ambari.repo
    wget -O /etc/yum.repos.d/hdp.repo http://public-repo-1.hortonworks.com/HDP/centos7/2.x/updates/${HDP_VERSION}/hdp.repo

    # Switch to our local mirror
    sed -i "s/public-repo-1.hortonworks.com/mirrors.dev.cbd.rackspace.com\/hortonworks/g" /etc/yum.repos.d/ambari.repo
    sed -i "s/public-repo-1.hortonworks.com/mirrors.dev.cbd.rackspace.com\/hortonworks/g" /etc/yum.repos.d/hdp.repo

    wget -O /etc/yum.repos.d/cbd.repo http://mirrors.dev.cbd.rackspace.com/cbd.repo
}

function yum_refresh() {
    rm -rf /var/cache/yum
    yum -y check-update
}

function yum_update() {
    yum_refresh
    yum -y update
    yum_refresh
}

function install_xfs_progs() {
    echo "Installing xfsprogs"
    yum -y install xfsprogs
}

function install_open_jdk_devel() {
    echo "Installing OpenJDK 8 + devel"
    yum -y install java-1.8.0-openjdk-devel
    echo "export JAVA_HOME=/usr/lib/jvm/java-openjdk" >>/etc/profile.d/java.sh
    echo "export PATH=$JAVA_HOME/bin:\$PATH" >>/etc/profile.d/java.sh
}

function install_ntp() {
    yum -y install ntp
    systemctl enable ntpd
}

function install_unbound() {
    yum -y install unbound
    systemctl enable unbound
    rm -f /etc/unbound/conf.d/example.com.conf
    rm -f /etc/unbound/local.d/block-example.com.conf
}

function install_hdp_dependencies() {
    # the bulk of Ambari install time is taken by these packages and their dependencies
    # since they don't include any actual services, just libraries, they're safe to pre-install
    echo "Pre-installing HDP packages"
    # GANGLIA_MONITOR needs python-rrdtool and httpd and is on all nodes
    yum install -y mysql-connector-java yum-utils rpcbind
    yum_refresh
    yum install -y hadoop-hdfs hadoop-client hadoop-libhdfs zookeeper
    yum_refresh
    yum -y install python-devel libgfortran openblas-devel lapack-devel python-pip gcc
    yum_refresh
    yum install -y ambari-metrics-monitor ambari-metrics-hadoop-sink httpd

    # the CentOS version of numpy is too old, surprise
    pip install --upgrade pip
    pip install --upgrade numpy
    pip install --upgrade ashes

    # Symlinks needed when using a separate SPARK stack in Ambari
    ln -s /usr/hdp/current/hadoop-client /usr/lib/hadoop
    ln -s /usr/hdp/current/zookeeper-client /usr/lib/zookeeper
}

function switch_firewalld_iptables() {
    systemctl mask firewalld
    systemctl disable firewalld
    systemctl enable iptables
}

function ambari_base_image_setup() {
    setup_repos
    yum_update
    install_xfs_progs
    install_open_jdk_devel
    install_ntp
    install_unbound
    install_hdp_dependencies
    switch_firewalld_iptables
}

function install_spark_distro() {
    yum -y --nogpgcheck install spark-standalone spark-standalone-master spark-standalone-slave spark-standalone-history-server
    yum -y --nogpgcheck install tachyon tachyon-master tachyon-worker
    yum -y --nogpgcheck install zeppelin
    # Install R for usage of SparkR.
    # Doing the below to overcome installation of Java 7 and utilize Java 8 which is already installed
    rpm -ivh http://99d5e41fa2c0e2449387-c98cb03f28782f3d502758d80de5f65d.r57.cf1.rackcdn.com/R-java-devel-3.2.2-1.el7.x86_64.rpm --nodeps
    yum install -y R
    yum_refresh
}

function install_topo_script() {
    echo "Installing topo.py"
    yum install -y lava-topo
}

function install_hadoop_extras() {
    echo "Installing lzo"
    yum install -y snappy snappy-devel hadoop-lzo lzo lzo-devel hadoop-lzo-native
}

function install_hdfs_scp() {
    echo "Installing hfds-scp"
    yum install -y hdfs-scp-2.0*
}

function update_role_command() {
    version=`echo $HDP_VERSION | cut -c1-3`
    cat <<EOF > /var/lib/ambari-agent/cache/stacks/HDP/$version/role_command_order.json
{
  "_comment" : "Record format:",
  "_comment" : "blockedRole-blockedCommand: [blockerRole1-blockerCommand1, blockerRole2-blockerCommand2, ...]",
  "general_deps" : {
    "_comment" : "dependencies for all cases",
    "MAHOUT_SERVICE_CHECK-SERVICE_CHECK": ["NODEMANAGER-START", "RESOURCEMANAGER-START"],
    "RANGER_KMS_SERVER-START" : ["RANGER_ADMIN-START"],
    "RANGER_KMS_SERVICE_CHECK-SERVICE_CHECK" : ["RANGER_KMS_SERVER-START"],
    "PHOENIX_QUERY_SERVER-START": ["HBASE_MASTER-START"],
    "ATLAS_SERVICE_CHECK-SERVICE_CHECK": ["ATLAS_SERVER-START"],
    "SPARKS_HISTORY_SERVER-START" : ["NAMENODE-START"],
    "TACHYON_MASTER-START" : ["NAMENODE-START"],
    "TACHYON_WORKER-START" : ["TACHYON_MASTER-START"],
    "ZEPPELIN_SERVER-START" : ["SPARKS_MASTER-START"]
  }
}
EOF

}

function cleanup() {
    rm -f /etc/yum.repos.d/cbd.repo
    rm -f /etc/yum.repos.d/hdp.repo
    rm -f /var/lib/rpm/__db*
    rpm -v --rebuilddb
    yum clean dbcache
    yum history new
    yum -y check-update || true
}


echo "Building Ambari Image"
ambari_base_image_setup
install_topo_script
install_hadoop_extras
install_spark_distro
yum install -y ambari-agent
install_hdfs_scp
update_role_command
cleanup
