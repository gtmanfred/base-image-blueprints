#!/usr/bin/env bash

HDP_VERSION="2.1.7"
HADOOP_HOME=/usr/lib/hadoop

HDFS_USER=hdfs
YARN_USER=yarn
MAPRED_USER=mapred
PIG_USER=pig
OOZIE_USER=oozie
HIVE_USER=hive
HCATALOG_USER=hcat
HBASE_USER=hbase
SPARK_USER=spark
ZOOKEEPER_USER=zookeeper
HDFS_GROUP=hdfs
HADOOP_GROUP=hadoop
TEZ=tez

HADOOP_CONF_DIR="/etc/hadoop/conf"
HDFS_LOG_DIR="/var/log/hadoop/hdfs"
HDFS_PID_DIR="/var/run/hadoop/hdfs"
YARN_LOG_DIR="/var/log/hadoop/yarn"
YARN_PID_DIR="/var/run/hadoop/yarn"
MAPRED_LOG_DIR="/var/log/hadoop/mapred"
MAPRED_PID_DIR="/var/run/hadoop/mapred"
HIVE_CONF_DIR="/etc/hive/conf"
HIVE_LOG_DIR="/var/log/hive"
HIVE_PID_DIR="/var/run/hive"
HBASE_CONF_DIR="/etc/hbase/conf"
HBASE_LOG_DIR="/var/log/hbase"
HBASE_PID_DIR="/var/run/hbase"
ZOOKEEPER_CONF_DIR="/etc/zookeeper/conf"
ZOOKEEPER_LOG_DIR="/var/log/zookeeper"
ZOOKEEPER_PID_DIR="/var/run/zookeeper"
PIG_CONF_DIR="/etc/pig/conf"
PIG_LOG_DIR="/var/log/pig"
PIG_PID_DIR="/var/run/pig"
OOZIE_CONF_DIR="/etc/oozie/conf"
OOZIE_LOG_DIR="/var/log/oozie"
OOZIE_PID_DIR="/var/run/oozie"
OOZIE_TMP_DIR="/var/tmp/oozie"
SQOOP_CONF_DIR="/usr/lib/sqoop/conf"
TEZ_CONF_DIR="/etc/tez/conf"
SPARK_HOST="http://99d5e41fa2c0e2449387-c98cb03f28782f3d502758d80de5f65d.r57.cf1.rackcdn.com/"
SPARK_VERSION="spark-1.1.0.2.1.5.0-695-bin-2.4.0.2.1.5.0-695"
SPARK_TGZ="${SPARK_VERSION}.tgz"
SPARK_CONF_DIR="/etc/spark/conf"
SPARK_ROOT_DIR="/usr/lib/spark-yarn"
SPARK_LOG_DIR="/var/log/spark"
SPARK_PID_DIR="/var/run/spark"

RAX_REPO="rackspace-cbd.repo"

# Create the necessary directories
function create_hadoop_dirs() {
    echo "Creating dirs..."
    mkdir -p $HDFS_LOG_DIR
    chown -R $HDFS_USER:$HADOOP_GROUP $HDFS_LOG_DIR
    chmod -R 755 $HDFS_LOG_DIR

    mkdir -p $MAPRED_LOG_DIR
    chown -R $MAPRED_USER:$HADOOP_GROUP $MAPRED_LOG_DIR
    chmod -R 755 $MAPRED_LOG_DIR

    mkdir -p $HDFS_PID_DIR
    chown -R $HDFS_USER:$HADOOP_GROUP $HDFS_PID_DIR
    chmod -R 755 $HDFS_PID_DIR

    mkdir -p $MAPRED_PID_DIR
    chown -R $MAPRED_USER:$HADOOP_GROUP $MAPRED_PID_DIR
    chmod -R 755 $MAPRED_PID_DIR

    rm -rf $HADOOP_CONF_DIR
    mkdir -p $HADOOP_CONF_DIR
}

###############################################################################
# Base steps required for all RHEL/CENTOS based images                        #
###############################################################################

function base_image_setup() {
    yum_update
    install_agent
    install_templates
    install_topo_script
    install_xfs_progs
    install_ntp
    install_python27
}

function yum_update() {
    yum -y check-update
    yum -y update
}

function install_python27() {
    yum localinstall -y http://dl.iuscommunity.org/pub/ius/stable/CentOS/6/x86_64/ius-release-1.0-13.ius.centos6.noarch.rpm
    rm -f /etc/yum.repos.d/ius-*.repo
    yum install -y python27 python27-setuptools python27-pip
}

function install_open_jdk7() {
    echo "Installing Open JDK"
    yum -y install java-1.7.0-openjdk
    mkdir -p /usr/java
    ln -s /usr/lib/jvm/jre /usr/java/default
    echo "export JAVA_HOME=/usr/java/default" >>/etc/profile.d/java.sh
    echo "export PATH=$JAVA_HOME/bin:\$PATH" >>/etc/profile.d/java.sh
}

function install_agent() {
    echo "Installing agent"
    yum -y install python-setuptools
    easy_install argparse
    easy_install ashes
    yum -y install lava-agent
    initctl stop lava-agent
}

function install_topo_script() {
    echo "Installing topo.py"
    yum -y install lava-topo
}

function install_xfs_progs() {
    echo "Installing xfsprogs"
    yum -y install xfsprogs
}

function install_templates() {
    packagename="hdp2_1_templates"
    echo "Installing ${packagename}"
    yum -y install $packagename
}

function install_ntp() {
    yum -y install ntp
    chkconfig ntpd on
}

###############################################################################

function setup_cbd_repo() {
    echo "[rackspace-cbd]" >> /etc/yum.repos.d/$RAX_REPO
    echo "name=Rackspace-CBD-$releasever - Base" >> /etc/yum.repos.d/$RAX_REPO
    echo "baseurl=http://mirrors.dev.cbd.rackspace.com/cbd/rhel/" >> /etc/yum.repos.d/$RAX_REPO
    echo "gpgcheck=0" >> /etc/yum.repos.d/$RAX_REPO
}

function cleanup_cbd_repo() {
    rm /etc/yum.repos.d/$RAX_REPO
}

function setup_hdp_repo() {
    echo "Setting up HDP Repo..."
    wget -O /etc/yum.repos.d/hdp.repo http://public-repo-1.hortonworks.com/HDP/centos6/2.x/updates/${HDP_VERSION}.0/hdp.repo
    yum -y check-update
}

###############################################################################
# Base steps required for Hadoop Core                                         #
###############################################################################

# Create default groups and users
function create_hadoop_users() {
    echo "Creating Users..."
    groupadd $HADOOP_GROUP
    groupadd sudo
    sed -i "s/# %wheel\tALL=(ALL)\tALL/%sudo\tALL=(ALL)\tALL/" /etc/sudoers
    useradd -MN -g $HADOOP_GROUP $HDFS_USER
    useradd -MN -g $HADOOP_GROUP $MAPRED_USER
    useradd -MN -g $HADOOP_GROUP $HIVE_USER
    useradd -MN -g $HADOOP_GROUP $PIG_USER
}


function install_hadoop_deps() {
    echo "Installing deps..."
    yum -y install snappy snappy-devel hadoop-lzo lzo lzo-devel hadoop-lzo-native openssl
    ln -sf /usr/lib64/libsnappy.so /usr/lib/hadoop/lib/native/Linux-amd64-64/.
}

###############################################################################

###############################################################################
# Base steps required for Hadoop2 Core                                        #
###############################################################################

function base_hadoop2_setup() {
    create_hadoop_users
    create_hadoop2_users
    install_hadoop2
    install_hadoop_deps
    install_hadoop2_swift
}


# Create default groups and users
function create_hadoop2_users() {
    echo "Creating Yarn and related Users..."
    useradd -MN -g $HADOOP_GROUP $YARN_USER
    useradd -MN -g $HADOOP_GROUP $HCATALOG_USER
    useradd -MN -g $HADOOP_GROUP $TEZ
}


function install_hadoop2() {
    echo "Installing Hadoop..."
    yum -y install hadoop hadoop-hdfs hadoop-libhdfs hadoop-yarn hadoop-mapreduce hadoop-client tez
}


function install_hadoop2_swift() {
    echo "Installing Hadoop Swift plugin..."
    yum -y install hadoop-openstack
}


# Create the necessary directories
function create_hadoop2_dirs() {
    echo "Creating dirs..."
    create_hadoop_dirs

    mkdir -p $YARN_LOG_DIR
    chown -R $YARN_USER:$HADOOP_GROUP $YARN_LOG_DIR
    chmod -R 755 $YARN_LOG_DIR

    mkdir -p $YARN_PID_DIR
    chown -R $YARN_USER:$HADOOP_GROUP $YARN_PID_DIR
    chmod -R 755 $YARN_PID_DIR
}

function create_tez_conf_dir() {
    rm -rf $TEZ_CONF_DIR
    mkdir -p $TEZ_CONF_DIR
    chown -R $TEZ:$HADOOP_GROUP $TEZ_CONF_DIR
    chmod -R 755 TEZ_CONF_DIR
}

###############################################################################

###############################################################################
# Misc Hadoop Components                                                      #
###############################################################################


function install_spark() {
    echo "Installing Spark..."

    set -e

    # MLLib dependencies - also needs netlib-java which isn't available because of license issues
    yum -y install python-devel libgfortran openblas-devel lapack-devel python-pip gcc
    # the CentOS version of numpy is too old, surprise
    pip install --upgrade numpy

    wget $SPARK_HOST/$SPARK_TGZ -O /tmp/$SPARK_TGZ
    tar --directory /tmp -xzf /tmp/$SPARK_TGZ

    rm -rf $SPARK_CONF_DIR
    mkdir -p $SPARK_CONF_DIR

    rm -rf $SPARK_ROOT_DIR
    mkdir -p $SPARK_ROOT_DIR

    # move everything else to the spark root dir
    cp -r /tmp/$SPARK_VERSION/* $SPARK_ROOT_DIR

    echo "export PATH=$SPARK_ROOT_DIR/bin:\$PATH" >/etc/profile.d/spark.sh

    rm -rf /tmp/$SPARK_VERSION
    rm -f /tmp/$SPARK_TGZ

    useradd -MN -g $HADOOP_GROUP -G $HDFS_GROUP $SPARK_USER
    mkdir -p $SPARK_LOG_DIR
    chown -R $SPARK_USER:$HADOOP_GROUP $SPARK_LOG_DIR
    chmod -R 755 $SPARK_LOG_DIR

    mkdir -p $SPARK_PID_DIR
    chown -R $SPARK_USER:$HADOOP_GROUP $SPARK_PID_DIR
    chmod -R 755 $SPARK_PID_DIR

    set +e
}

function install_init_scripts() {
    echo "Installing Hadoop init scripts..."
    yum -y install hadoop2-init
}

# Steps to install all the packages
echo "USING THE NEW SCRIPT"
setup_cbd_repo
base_image_setup
install_open_jdk7
setup_hdp_repo
base_hadoop2_setup
create_tez_conf_dir

create_hadoop2_dirs
install_init_scripts
install_spark
cleanup_cbd_repo

