#!/bin/bash -   
#title          :setup-hadoop.sh
#description    :This script is used to remove old installation of hadoop and install new version of hadoop
#		 Modify the configuration parameters below and run   
#author         :Sampath sree kumar.K
#date           :20161009
#version        :1.0    
#usage          :./setup-hadoop.sh
#notes          :Do Not Edit the Script in Windows - Might give EOL error       
#bash_version   :4.3.46(1)-release
#============================================================================


# User Configuration
HADOOP_URL="http://www-us.apache.org/dist/hadoop/common/hadoop-2.7.3/hadoop-2.7.3.tar.gz"
USER="sam"
VERSION="2.7.3"

/usr/bin/clear

# DO NOT EDIT VARIABLES
RESET="\e[0m"
RED="\e[31m"
BLUE="\e[34m"
MAG="\e[35m"
USER_HOME="/home/${USER}"
NAMENODE_DIR=${USER_HOME}/hdfs/namenode
DATANODE_DIR=${USER_HOME}/hdfs/datanode


# Checks if java is installed properly or not
java_exists ()
{
if type -p java; then
        echo -e "${BLUE}ORACLE JAVA Exists!!!${RESET}"
elif [[ -n "$JAVA_HOME" ]] && [[ -x "$JAVA_HOME/bin/java" ]];  then
        _java="$JAVA_HOME/bin/java"
        echo -e "${BLUE}ORACLE JAVA Exists at - ${RED}${_java}${RESET}"
else
        echo -e "${RED}Oops!!! No JAVA.${RESET}"
	exit
fi

}

setup_ssh_hosts()
{
	# Given a list of machines, this script will copy the ssh id to all these machines
	# If we need password less ssh from every machine to every other machine run this script on all the machines in the cluster

	declare -a MACHINES=(127.0.0.1 localhost)
	sudo apt-get install -y ssh
        sudo apt-get install -y rsync
	sudo apt-get install -y sshpass        

        echo -e "y\n" | ssh-keygen -t rsa -f ${USER_HOME}/.ssh/id_rsa -q -N ""
	
	ssh-keyscan localhost,127.0.0.1,127.0.1.1 >> ${USER_HOME}/.ssh/known_hosts
	
	cat ${USER_HOME}/.ssh/id_rsa.pub >> ${USER_HOME}/.ssh/authorized_keys
	
	chmod -R 700 ${USER_HOME}/.ssh
	
	ssh-add
}

stop_delete_hadoop()
{
echo -e "${BLUE}"
if [ -f /tmp/hadoop-${USER}-namenode.pid ]
then
	echo -e "Killing Namenode..."
	kill -9 $(cat /tmp/hadoop-${USER}-namenode.pid)
	rm -f /tmp/hadoop-${USER}-namenode.pid
fi

if [ -f /tmp/hadoop-${USER}-datanode.pid ]
then
        echo -e "Killing Datanode..."
        kill -9 $(cat /tmp/hadoop-${USER}-datanode.pid)
        rm -f /tmp/hadoop-${USER}-datanode.pid
fi

if [ -f /tmp/hadoop-${USER}-secondarynamenode.pid ]
then
        echo -e "Killing Secondary Namenode..."
        kill -9 $(cat /tmp/hadoop-${USER}-secondarynamenode.pid)
        rm -f /tmp/hadoop-${USER}-secondarynamenode.pid
fi

echo -e "${RESET}"

if [ -d /opt/hadoop/hadoop* ]
then
        echo -e "${RED}Deleting existing HADOOP installation at /opt/hadoop/\n${RESET}"
        sudo rm -rf /opt/hadoop/*
fi

}


java_exists

setup_ssh_hosts

stop_delete_hadoop

#START-----INSTALL HADOOP-----#
if [ -a ${USER_HOME}/Downloads/hadoop-${VERSION}.tar.gz ]
then
	echo -e "${MAG}Tar file already exists!!! Extracting Now...\n${RESET}"
else
	sudo wget "$HADOOP_URL" -O ${USER_HOME}/Downloads/hadoop-${VERSION}.tar.gz
fi

sudo mkdir -p /opt/hadoop

sudo tar -xzf ${USER_HOME}/Downloads/hadoop-${VERSION}.tar.gz -C /opt/hadoop/

cd /opt/hadoop/*
H_HOME=`pwd`

echo -e "Configuring files...\n"

# Update .bashrc
sudo grep -q '^export HADOOP_HOME=' ${USER_HOME}/.bashrc && sed -i '/^export HADOOP_HOME=.*/c\export HADOOP_HOME="'${H_HOME}'"' ${USER_HOME}/.bashrc || echo -e "export HADOOP_HOME=\"${H_HOME}\"" >> ${USER_HOME}/.bashrc

sudo grep -q '^export HADOOP_COMMON_HOME=' ${USER_HOME}/.bashrc && sed -i '/^export HADOOP_COMMON_HOME=.*/c\export HADOOP_COMMON_HOME=\$HADOOP_HOME' ${USER_HOME}/.bashrc || echo -e "export HADOOP_COMMON_HOME=\$HADOOP_HOME" >> ${USER_HOME}/.bashrc

sudo grep -q '^export HADOOP_CONF_DIR=' ${USER_HOME}/.bashrc && sed -i '/^export HADOOP_CONF_DIR=.*/c\export HADOOP_CONF_DIR=\$HADOOP_HOME/etc/hadoop' ${USER_HOME}/.bashrc || echo -e "export HADOOP_CONF_DIR=\$HADOOP_HOME/etc/hadoop" >> ${USER_HOME}/.bashrc

sudo grep -q '^export HADOOP_HDFS_HOME=' ${USER_HOME}/.bashrc && sed -i '/^export HADOOP_HDFS_HOME=.*/c\export HADOOP_HDFS_HOME=\$HADOOP_HOME' ${USER_HOME}/.bashrc || echo -e "export HADOOP_HDFS_HOME=\$HADOOP_HOME" >> ${USER_HOME}/.bashrc

sudo grep -q '^export HADOOP_MAPRED_HOME=' ${USER_HOME}/.bashrc && sed -i '/^export HADOOP_MAPRED_HOME=.*/c\export HADOOP_MAPRED_HOME=\$HADOOP_HOME' ${USER_HOME}/.bashrc || echo -e "export HADOOP_MAPRED_HOME=\$HADOOP_HOME" >> ${USER_HOME}/.bashrc

sudo grep -q '^export HADOOP_YARN_HOME=' ${USER_HOME}/.bashrc && sed -i '/^export HADOOP_YARN_HOME=.*/c\export HADOOP_YARN_HOME=\$HADOOP_HOME' ${USER_HOME}/.bashrc || echo -e "export HADOOP_YARN_HOME=\$HADOOP_HOME" >> ${USER_HOME}/.bashrc

sudo grep -q '^export PATH=\$PATH:\$HADOOP_HOME/sbin:\$HADOOP_HOME/bin' ${USER_HOME}/.bashrc || echo -e "export PATH=\$PATH:\$HADOOP_HOME/sbin:\$HADOOP_HOME/bin" >> ${USER_HOME}/.bashrc

source ~/.bashrc


j=`echo $(type -p java) | rev | cut -d "/" -f3- | rev`


sudo sed -i '/^export JAVA_HOME=*/c\export JAVA_HOME='${j}'' $H_HOME/etc/hadoop/hadoop-env.sh

# Configure core-site.xml
sudo sed -i '/<\/configuration>/i \    <property>\n        <name>fs.defaultFS</name>\n        <value>hdfs://localhost:9000</value>\n    </property>' $H_HOME/etc/hadoop/core-site.xml

# Create Name Node Directory
sudo mkdir -p ${NAMENODE_DIR}
if [ -n "$(ls -A ${NAMENODE_DIR})" ]
then
	sudo rm -r ${NAMENODE_DIR}/*
fi
sudo chown -R ${USER}:${USER} ${NAMENODE_DIR}
sudo chgrp -R ${USER} ${NAMENODE_DIR}

# Create Data Node Directory
sudo mkdir -p ${DATANODE_DIR}
if [ -n "$(ls -A ${DATANODE_DIR})" ]
then
	sudo rm -r ${DATANODE_DIR}/*
fi
sudo chown -R ${USER}:${USER} ${DATANODE_DIR}
sudo chgrp -R ${USER} ${DATANODE_DIR}

# Configure hdfs-site.xml
sudo sed -i '/<\/configuration>/i \    <property>\n        <name>dfs.replication</name>\n        <value>1</value>\n    </property>' ${H_HOME}/etc/hadoop/hdfs-site.xml
sudo sed -i '/<\/configuration>/i \    <property>\n        <name>dfs.permissions</name>\n        <value>false</value>\n    </property>' ${H_HOME}/etc/hadoop/hdfs-site.xml
sudo sed -i '/<\/configuration>/i \    <property>\n        <name>dfs.namenode.name.dir</name>\n        <value>file://'"${NAMENODE_DIR}"'</value>\n    </property>' ${H_HOME}/etc/hadoop/hdfs-site.xml
sudo sed -i '/<\/configuration>/i \    <property>\n        <name>dfs.datanode.data.dir</name>\n        <value>file://'"${DATANODE_DIR}"'</value>\n    </property>' ${H_HOME}/etc/hadoop/hdfs-site.xml

# Configure mapred-site.xml
sudo cp ${H_HOME}/etc/hadoop/mapred-site.xml.template ${H_HOME}/etc/hadoop/mapred-site.xml
sudo sed -i '/<\/configuration>/i \    <property>\n        <name>mapreduce.jobtracker.address</name>\n        <value>localhost:54311</value>\n    </property>' ${H_HOME}/etc/hadoop/mapred-site.xml

# Grant Permission to hadoop home to user
sudo chown -R ${USER}:${USER} ${H_HOME}
sudo chgrp -R ${USER} ${H_HOME}


# Format the New Hadoop FileSystem
echo -e "${RED}Formatting Name Node...See Log at /tmp/namenode_format.log${RESET}\n"
rm -f /tmp/namenode_format.log 2>&1
${H_HOME}/bin/hdfs namenode -format &>> /tmp/namenode_format.log

echo -e "HADOOP HOME = ${BLUE}${H_HOME}${RESET}\n"
