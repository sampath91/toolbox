#!/bin/bash -   
#title          :setup-spark.sh
#description    :This script is used to remove old installation of spark and install new version of spark
#		 Modify the modify configuration parameters below and run   
#author         :Sampath sree kumar.K
#date           :20161009
#version        :1.0    
#usage          :./setup-spark.sh
#notes          :Do Not Edit the Script in Windows - Might give EOL error       
#bash_version   :4.3.46(1)-release
#============================================================================


# User Configuration
SPARK_URL="http://www-us.apache.org/dist/spark/spark-2.0.0/spark-2.0.0-bin-hadoop2.7.tgz" 
USER="sam"
VERSION="2.0.0"

/usr/bin/clear

# DO NOT EDIT VARIABLES
RESET="\e[0m"
RED="\e[31m"
BLUE="\e[34m"
MAG="\e[35m"
USER_HOME="/home/${USER}"


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

scala_exists()
{
if type -p scala; then
        echo -e "${BLUE}SCALA Exists!!!${RESET}"
elif [[ -n "$SCALA_HOME" ]] && [[ -x "$SCALA_HOME/bin/scala" ]];  then
        _scala="$SCALA_HOME/bin/scala"
        echo -e "${BLUE}SCALA Exists at - ${RED}${_scala}${RESET}"
else
        echo -e "${RED}Oops!!! No SCALA.${RESET}"
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

stop_delete_spark()
{
	echo -e ${BLUE}
	${SPARK_HOME}/sbin/stop-master.sh
	${SPARK_HOME}/sbin/stop-slave.sh
	echo -e ${RESET}
	if [ -d /opt/spark/spark* ]
	then
        	echo -e "${RED}Deleting existing SPARK installation at /opt/spark/\n${RESET}"
        	sudo rm -rf /opt/spark/*
	fi

}


java_exists

scala_exists

setup_ssh_hosts

stop_delete_spark

#START-----INSTALL SPARK-----#
if [ -a ${USER_HOME}/Downloads/spark-${VERSION}.tar.gz ]
then
	echo -e "${MAG}Tar file already exists!!! Extracting Now...\n${RESET}"
else
	sudo wget "$SPARK_URL" -O ${USER_HOME}/Downloads/spark-${VERSION}.tar.gz
fi

sudo mkdir -p /opt/spark

sudo tar -xzf ${USER_HOME}/Downloads/spark-${VERSION}.tar.gz -C /opt/spark/

cd /opt/spark/*
S_HOME=`pwd`

echo -e "Configuring files...\n"

# Update .bashrc
sudo grep -q '^export SPARK_HOME=' ${USER_HOME}/.bashrc && sed -i '/^export SPARK_HOME=.*/c\export SPARK_HOME="'${S_HOME}'"' ${USER_HOME}/.bashrc || echo -e "export SPARK_HOME=\"${S_HOME}\"" >> ${USER_HOME}/.bashrc

sudo grep -q '^export PATH=\$PATH:\$SPARK_HOME\/bin' ${USER_HOME}/.bashrc || echo -e "export PATH=\$PATH:\$SPARK_HOME/bin" >> ${USER_HOME}/.bashrc

source ~/.bashrc

# Grant Permission to spark home to user
sudo chown -R ${USER}:${USER} ${S_HOME}
sudo chgrp -R ${USER} ${S_HOME}

j=`echo $(type -p java) | rev | cut -d "/" -f3- | rev`


cp ${S_HOME}/conf/spark-env.sh.template ${S_HOME}/conf/spark-env.sh
echo "export JAVA_HOME=${j}" >> ${S_HOME}/conf/spark-env.sh
echo "export SPARK_WORKER_MEMORY=2g" >> ${S_HOME}/conf/spark-env.sh


# Grant Permission to spark home to user
sudo chown -R ${USER}:${USER} ${S_HOME}
sudo chgrp -R ${USER} ${S_HOME}

echo -e "SPARK_HOME = ${BLUE}${S_HOME}${RESET}\n"
