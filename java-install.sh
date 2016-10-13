#!/bin/bash -   
#title          :java-install.sh
#description    :This script is used to remove old installation of java and install new version of java
#                Modify the configuration parameters below and run    
#author         :Sampath sree kumar.K
#date           :20161009
#version        :1.0    
#usage          :./java-install.sh
#notes          :Do Not Edit the Script in Windows - Might give EOL error       
#bash_version   :4.3.46(1)-release
#============================================================================

# User Configurations
JAVA_URL="http://download.oracle.com/otn-pub/java/jdk/8u102-b14/jdk-8u102-linux-x64.tar.gz"
USER="sam"
VERSION="8u102"

/usr/bin/clear

# DO NOT EDIT VARIABLES
RESET="\e[0m"
RED="\e[31m"
BLUE="\e[34m"
USER_HOME="/home/${USER}"

# Checks if java is installed properly or not
java_exists ()
{
if type -p java; then
	echo -e "${BLUE}ORACLE JAVA is Successfully Installed${RESET}"
elif [[ -n "$JAVA_HOME" ]] && [[ -x "$JAVA_HOME/bin/java" ]];  then
    	_java="$JAVA_HOME/bin/java"
	echo -e "${BLUE}ORACLE JAVA is Successfully Installed at - ${RED}${_java}${RESET}"
else
    	echo -e "${RED}Oops!!! No JAVA. Something went wrong...${RESET}"
fi

}



# Remove already installed JAVA instances

#START#-----REMOVE JAVA-----#
# Remove all instances of java from multiple vendors 
dpkg-query -W -f='${binary:Package}\n' | grep -E -e '^(ia32-)?(sun|oracle)-java' -e '^openjdk-' -e '^icedtea' -e '^(default|gcj)-j(re|dk)' -e '^gcj-(.*)-j(re|dk)' -e '^java-common' | xargs sudo apt-get -y remove;

# Remove all the unused packages
sudo apt-get -y auto-remove;

# Purge all the Config Files of Removed packages
dpkg -l | grep ^rc | awk '{print($2)}' | xargs sudo apt-get -y purge;

# Remove manually installed JVMs
sudo rm -rf /usr/lib/jvm/*;

# Remove java entries, if there is still any from the alternatives
sudo update-alternatives --remove-all java;
#END-----REMOVE JAVA-----#


#START-----INSTALL JAVA-----#
if [ -a ${USER_HOME}/Downloads/OracleJDK-${VERSION}.tar.gz ]
then
	echo -e "${RED}Tar file already exists!!! Extracting Now... ${RESET}"
else
	sudo wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "$JAVA_URL" -O ${USER_HOME}/Downloads/OracleJDK-${VERSION}.tar.gz
fi
	
sudo tar -xzf ${USER_HOME}/Downloads/OracleJDK-${VERSION}.tar.gz -C /usr/lib/jvm
		

cd /usr/lib/jvm/*
JAVA_HOME=`pwd`
grep -q '^export JAVA_HOME=' ${USER_HOME}/.bashrc && sed -i '/^export JAVA_HOME=.*/c\export JAVA_HOME="'${JAVA_HOME}'"' ${USER_HOME}/.bashrc || echo 'export JAVA_HOME="'${JAVA_HOME}'"' >> ${USER_HOME}/.bashrc	

grep -q '^export PATH=$JAVA_HOME\/bin:' ${USER_HOME}/.bashrc && sed -i '/^export PATH=$JAVA_HOME\/bin:*/c\export PATH=$JAVA_HOME/bin:$PATH' ${USER_HOME}/.bashrc || echo 'export PATH=$JAVA_HOME/bin:$PATH' >> ${USER_HOME}/.bashrc

source ${USER_HOME}/.bashrc
	
java_exists
