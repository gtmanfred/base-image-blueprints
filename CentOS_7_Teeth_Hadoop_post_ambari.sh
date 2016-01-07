#!/usr/bin/env bash
###############################################################################
# Ambari Base Image Setup for CentOS                                          #
###############################################################################
#                                                                             #
# This script provides all the functionality to setup the necessary packages  #
# for Ambari Server/Agent on CentOS                                           #
#                                                                             #
###############################################################################

# make any command failure fatal
set -e

# automatically output all commands before executing them
set -x

# redirect all STDERR to STDOUT so it all shows up in the job logs
exec 2>&1

AMBARI_VERSION=${AMBARI_VERSION:-"2.1.1"}
HDP_VERSION=${HDP_VERSION:-"2.3.0.0"}
ES_HADOOP_VERSION=${ES_HADOOP_VERSION:-"2.1.0"}
MONGO_HADOOP_VERSION=${MONGO_HADOOP_VERSION:-"1.4.1"}


function setup_repos() {
    wget -O /etc/yum.repos.d/ambari.repo http://public-repo-1.hortonworks.com/ambari/centos7/2.x/updates/${AMBARI_VERSION}/ambari.repo
    wget -O /etc/yum.repos.d/hdp.repo http://public-repo-1.hortonworks.com/HDP/centos7/2.x/updates/${HDP_VERSION}/hdp.repo
    wget -O /etc/yum.repos.d/cbd.repo http://mirrors.dev.cbd.rackspace.com/cbd.repo
}

function yum_refresh() {
    rm -rf /var/cache/yum

    # if the fastestmirror plugin gets some 404s it exits non-zero even though it succeeds :(
    set +e
    yum -y check-update
    set -e
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
    yum install -y mysql-connector-java yum-utils
    yum_refresh
    yum install -y tez hadoop
    yum_refresh
    yum install -y hive pig sqoop
    yum_refresh
    yum install -y oozie falcon
    yum_refresh
    yum install -y spark kafka
    yum_refresh
    yum install -y storm zookeeper flume
    yum_refresh
    yum install -y hbase phoenix
    yum_refresh
    yum install -y knox ranger slider
    yum_refresh
    yum -y install python-devel libgfortran openblas-devel lapack-devel python-pip gcc
    yum_refresh
    yum install -y ambari-metrics-monitor ambari-metrics-hadoop-sink httpd

    # the CentOS version of numpy is too old, surprise
    pip install --upgrade numpy
    pip install --upgrade ashes

    # Do some preconfig work here, mostly copying over jars
    cp -f /usr/hdp/current/hadoop-client/hadoop-aws-*.jar /usr/hdp/current/hadoop-mapreduce-client/
    cp -f /usr/hdp/current/hadoop-client/lib/aws-java-sdk-*.jar /usr/hdp/current/hadoop-mapreduce-client/
}

function install_connectors() {
    connector_cdn="http://999de0f7d1ef7a5cfa54-6430c2523f428825ca7e0391febfc422.r82.cf5.rackcdn.com"
    version=`echo $HDP_VERSION | cut -d '.' -f1-2`

    # elastic-hadoop
    elastic_dir="/usr/hdp/current/elastic-hadoop"
    mkdir -p $elastic_dir
    wget -P $elastic_dir $connector_cdn/elasticsearch-hadoop-$ES_HADOOP_VERSION-hdp$version.jar

    # mongo-hadoop
    mongo_dir="/usr/hdp/current/mongo-hadoop"
    mkdir -p $mongo_dir
    wget -P $mongo_dir $connector_cdn/mongo-hadoop-core-$MONGO_HADOOP_VERSION-hdp$version.jar
    wget -P $mongo_dir $connector_cdn/mongo-hadoop-flume-$MONGO_HADOOP_VERSION-hdp$version.jar
    wget -P $mongo_dir $connector_cdn/mongo-hadoop-hive-$MONGO_HADOOP_VERSION-hdp$version.jar
    wget -P $mongo_dir $connector_cdn/mongo-hadoop-pig-$MONGO_HADOOP_VERSION-hdp$version.jar
    wget -P $mongo_dir $connector_cdn/mongo-hadoop-streaming-$MONGO_HADOOP_VERSION-hdp$version.jar
    wget -P $mongo_dir $connector_cdn/mongo-java-driver-3.0.2.jar
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
    install_connectors
    create_rmstore
    switch_firewalld_iptables
}

function create_rmstore() {
    # until https://issues.apache.org/jira/browse/AMBARI-11131 is fixed
    mkdir -p /hadoop/yarn/rmstore
    chown yarn:hadoop /hadoop/yarn/rmstore
}

function install_topo_script() {
    echo "Installing topo.py"
    yum -y install lava-topo
}

function install_hadoop_extras() {
    echo "Installing hadoop extras"
    yum -y install snappy snappy-devel
}

function install_hdfs_scp() {
    echo "Installing hfds-scp"
    yum install -y hdfs-scp-2.0*
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

echo "Building Ambari Image for Ambari Version: $AMBARI_VERSION, HDP Version: $HDP_VERSION"
ambari_base_image_setup
install_topo_script
install_hadoop_extras
yum install -y ambari-agent
install_hdfs_scp
cleanup

