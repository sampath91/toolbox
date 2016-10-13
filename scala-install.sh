#!/bin/bash -   
#title          :scala-install.sh
#description    :This script is used to remove old installation of scala and install new version of scala
#		 Modify the configuration parameters below and run   
#author         :Sampath sree kumar.K
#date           :20161009
#version        :1.0    
#usage          :./scala-install.sh
#notes          :Do Not Edit the Script in Windows - Might give EOL error       
#bash_version   :4.3.46(1)-release
#============================================================================


# User Configuration
SCALA_URL="http://downloads.lightbend.com/scala/2.11.8/scala-2.11.8.tgz"
USER="sam"
VERSION="2.11.8"

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
remove_scala()
{
	sudo apt-get -y remove scala
	sudo apt-get -y remove --auto-remove scala
	sudo apt-get -y purge --auto-remove scala
}
java_exists

remove_scala

if [ -d /usr/local/share/scala* ]
then
        echo -e "${RED}Deleting existing SCALA installation at /usr/local/share/\n${RESET}"
        sudo rm -rf /usr/local/share/scala*
fi


#START-----INSTALL SPARK-----#
if [ -a ${USER_HOME}/Downloads/scala-${VERSION}.tar.gz ]
then
	echo -e "${MAG}Tar file already exists!!! Extracting Now...\n${RESET}"
else
	sudo wget "$SCALA_URL" -O ${USER_HOME}/Downloads/scala-${VERSION}.tar.gz
fi


	sudo tar -xzf ${USER_HOME}/Downloads/scala-${VERSION}.tar.gz -C /usr/local/share/

cd /usr/local/share/scala*
S_HOME=`pwd`

echo -e "Configuring files...\n"

# Update .bashrc
sudo grep -q '^export SCALA_HOME=' ${USER_HOME}/.bashrc && sed -i '/^export SCALA_HOME=.*/c\export SCALA_HOME="'${S_HOME}'"' ${USER_HOME}/.bashrc || echo -e "export SCALA_HOME=\"${S_HOME}\"" >> ${USER_HOME}/.bashrc

sudo grep -q '^export PATH=\$PATH:\$SCALA_HOME\/bin' ${USER_HOME}/.bashrc || echo -e "export PATH=\$PATH:\$SCALA_HOME/bin" >> ${USER_HOME}/.bashrc

source ~/.bashrc
