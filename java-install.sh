#!/bin/bash

FRESH_INSTALL=true
JAVA_URL="http://download.oracle.com/otn-pub/java/jdk/8u102-b14/jdk-8u102-linux-x64.tar.gz"


# DO NOT EDIT VARIABLES
RESET="\e[0m"
RED="\e[31m"

# Checks if java is installed properly or not
java_exists ()
{

if type -p java; then
    _java=java
elif [[ -n "$JAVA_HOME" ]] && [[ -x "$JAVA_HOME/bin/java" ]];  then
    _java="$JAVA_HOME/bin/java"
fi

if [[ "$_java" ]]; then
    echo "ORACLE JAVA is Successfully Installed at $_java"
else
    echo -e "${RED}Oops!!! No JAVA. Something went wrong...${RESET}"
fi

}



# Remove already installed JAVA instances
if [ $FRESH_INSTALL == "true" ]
then
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
	if [ -a ~/Downloads/OracleJDK.tar.gz ]
	then
		echo "Already Tar file exists!!! Extracting..."
	else
		sudo wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "$JAVA_URL" -O ~/Downloads/OracleJDK.tar.gz
	fi
	
	sudo tar -xzvf ~/Downloads/OracleJDK.tar.gz -C /usr/lib/jvm
	

	cd /usr/lib/jvm/*
	JAVA_HOME=`pwd`
	grep -q '^export JAVA_HOME=' ~/.bashrc && sed -i '/^export JAVA_HOME=.*/c\export JAVA_HOME="'${JAVA_HOME}'"' ~/.bashrc || echo 'export JAVA_HOME="'${JAVA_HOME}'"' >> ~/.bashrc	

	source ~/.bashrc

	cd ~
	
	java_exists		

else
	echo -e "Please set ${RED}FRESH_INSTALL${RESET} to remove existing java and install new JAVA..."
fi


java_exists ()
{

if type -p java; then
    _java=java
elif [[ -n "$JAVA_HOME" ]] && [[ -x "$JAVA_HOME/bin/java" ]];  then
    _java="$JAVA_HOME/bin/java"
fi

if [[ "$_java" ]]; then
    echo "ORACLE JAVA is Successfully Installed at $_java"
else
    echo -e "${RED}Oops!!! No JAVA. Something went wrong...${RESET}"
fi

}


 
