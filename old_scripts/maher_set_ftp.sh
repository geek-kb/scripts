#!/bin/bash

if [[ $USER != "peeradmin" ]]; then
    echo "--> Please run with peeradmin only!"
    exit 1
fi

# No need to run if not on edgeupdater system
if [[ ! $HOSTNAME =~ ^edgeupdater[[:digit:]]+ ]]; then
	echo "!! This is NOT an EdgeUpdater system, bye ..."
	exit 1
fi

# Copy jar file, extract and get FTPs from XML
if [[ $# -lt 1 ]]; then
    echo -e "\nUsage: set_ftp [enable|disable] FTP"
	tmpJAR=$(ls -1 /workspace/production/edgeupdater/peer39-edgeupdater/lib/ | grep edgeupdater)
	tmpXML=com/peer39/edgeupdater/etc/prod/common/ftpConfiguration.xml
	if cp -f /workspace/production/edgeupdater/peer39-edgeupdater/lib/$tmpJAR /tmp/ &>/dev/null ; then
		cd /tmp && jar xvf $tmpJAR $tmpXML &>/dev/null
		# If extraction of jar fails
		if [ $? -ne 0 ] ; then
			echo "ERROR: error while extracting XML"
			echo "Possible cause: /tmp/com is present and not owned by peeradmin"
			exit 1
		fi
		ServerList=$(cat $tmpXML | grep -F -v '<!--' | grep -F -v ">-->" | grep server | awk '{print $3}' | sed 's/server="//' | sed 's/"//')
		echo -e "\n### Available FTPs:"
		echo "$ServerList"
		echo -e "\nRemember to copy/paste the FTP as-is (ftp:port) when enabling/disabling\n"
		rm -f /tmp/$tmpJAR &>/dev/null
		rm -rf /tmp/com &> /dev/null
		exit 0
	else
		echo "ERROR: error while copying jar file $tmpJAR to /tmp"
		rm -f /tmp/$tmpJAR &>/dev/null
		rm -rf /tmp/$tmpXML &> /dev/null
		exit 1
	fi
fi

if [ "$1" = "enable" ] && [ ! -z "$2" ] ; then
	echo -e "\nEnabling FTP: $2"
	echo "Executing: ant manage-ftp-location -Dcommand=update -Dlocation=\"${2}\"\n"
	cd /workspace/production/edgeupdater/peer39-edgeupdater/scripts/ && ant manage-ftp-location -Dcommand=update -Dlocation="${2}"
elif [ "$1" = "disable" ] && [ ! -z "$2" ] ; then
	echo -e "\nDisabling FTP: $2"
	echo "Executing: ant manage-ftp-location -Dcommand=remove -Dlocation=\"${2}\"\n"
	cd /workspace/production/edgeupdater/peer39-edgeupdater/scripts/ && ant manage-ftp-location -Dcommand=remove -Dlocation="${2}"
else
	echo "Argument error : \$1=$1 \$2=$2"
	exit 1
fi

exit 0