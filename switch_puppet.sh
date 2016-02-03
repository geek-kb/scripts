#!/bin/bash
# This script helps you in configuring a server to work against different puppet servers.
# Script by Itai Ganot 2016.

# Variables
puppetvar="/var/lib/puppet"
puppetconf="/etc/puppet/puppet.conf"
puppetdmn="/etc/init.d/puppet"

# Functions
function restart_puppet {
/etc/init.d/puppet start
sleep 2
/bin/rm -f /var/lib/puppet/state/agent_catalog_run.lock
}

# Script
echo "Currently configured Puppet server is:"
curpup=$(grep server /etc/puppet/puppet.conf | awk -F= '{print $2}' | awk -F. '{print $1}' | tr -d " ") # find the word server in puppet.conf and cut the hostname
if [ -z $curpup ]; then # if server is not found in puppet.conf
	curpup="puppet" #then understand that the configured server is puppet.nj.peer39.com
fi
if [[ $(grep server $puppetconf | wc -l) -gt 1 ]]; then
	sed -i 's/.*server.*//g' /etc/puppet/puppet.conf
fi
echo $curpup
sed -i 's/^#.*server/server/g' /etc/puppet/puppet.conf
curropts=$(ls -1 $puppetvar | grep ssl | awk -F. '{print $2}')
echo "Current optional servers to work with: "
echo $curropts
read -r -p "Which server would you like to configure? " puppetsrv
case $puppetsrv in
	[pP][uU][pP][pP][eE][tT])
		echo "Stopping Puppet service!"
    /etc/init.d/puppet stop # stopping puppet service
		puppetsrv="puppet"
		$puppetdmn stop &>/dev/null # stopping puppet service
		if [[ $(/bin/grep -q server $puppetconf && echo $?) -eq "0" ]]; then  # if the word server is found in /etc/puppet/puppet.conf and exits with status code 0
			sed -i "s@server.*@server = $puppetsrv.nj.peer39.com@" $puppetconf # Replace server* with server = puppet.nj
		else
			echo "server = puppet.nj.peer39.com" >> $puppetconf # if server is not found echo it to the file
		fi
		cd $puppetvar && mv ssl ssl.$curpup # cd /var/lib/puppet and move ssl to ssl.current_puppet_srv
		if [ -d $puppetvar/ssl.$puppetsrv ]; then
			cd $puppetvar && mv ssl.$puppetsrv ssl # cd /var/lib/puppet and move ssl.userchoice to ssl
		fi
		restart_puppet
		echo "Done!"
	;;
	puppy*)
		echo "Stopping Puppet service!"
		/etc/init.d/puppet stop # stopping puppet service

		if [ -d $puppetvar/ssl ]; then
      cd $puppetvar && /bin/mv ssl ssl.$curpup
      cd $puppetvar && /bin/mv ssl.$puppetsrv ssl &>/dev/null
		fi

		if [ -d $puppetvar/ssl.$puppetsrv ]; then # if a directory exists with user supplied name
			echo "$puppetsrv folder already exists!"
			cd $puppetsrv && mv ssl ssl.$curpup
			cd $puppetvar && mv ssl.$puppetsrv ssl # mov
		fi
		
		grep -q server $puppetconf
		if [ "$?" -eq "0" ]; then
			sed -i "s@server.*@server = $puppetsrv.peer39dom.com@" $puppetconf
		else
			echo "server = $puppetsrv.peer39dom.com" >> $puppetconf
			echo "This server is now set to work against $puppetsrv !"	
		fi
		restart_puppet
		echo "Done!"
		;;
	*)
		echo "Exiting script!"
		exit 1
		;;
esac
