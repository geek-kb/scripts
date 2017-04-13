#!/bin/bash
# This script monitors the puppet log file ($file) and the puppet lock file ($puppet_lock)
# script by Itai Ganot 2015

# Variables
file="/var/lib/puppet/state/last_run_summary.yaml"
file_tmp="/tmp/puppet_last_run_summary.yaml"
puppet_init="/etc/init.d/puppet"
puppet_lock="/var/lock/subsys/puppet"
hostname=$(hostname)
		sudo cat $file > $file_tmp 2&>/dev/null
	if [ ! -f $puppet_init ]; then
		status="1"
		txt="Warning"
		echo "$txt: Puppet-agent is not installed"
		exit $status
	else
		sudo cat $file > $file_tmp
		puppet_ver=$(grep puppet $file_tmp | awk '{print $2}')
		config_num=$(grep "config:" $file_tmp | awk '{print $2}')
		changes=$(sed '29!d' $file_tmp | awk '{print $2}')
		#events_total=$(tail -10 $file_tmp | grep "" | awk '{print $2}')
		#events_failure=$(tail -10 $file_tmp | grep "failure:" | awk '{print $2}')
		#events_success=$(tail -8 $file_tmp | grep "success:" | awk '{print $2}')
		last_run=$(date -d@$(grep "last_run" $file_tmp | awk '{print $2}'))
		ps -ef |grep puppet |grep ruby &>/dev/null
			if [ "$?" -eq "0" ]; then
				ppid_alive="yes"
			else
				ppid_alive="no"
			fi
	fi

if [ -f "$puppet_lock" ] && [ "$ppid_alive" = "yes" ]; then
	puppet_alive="yes"
	status="0"
	txt="OK"
else
	puppet_alive="no"
	status="2"
	txt="Critical"
fi

if [ "$puppet_alive" = "yes" ]; then
	#echo "Puppet on $hostname : Version- $puppet_ver Last run- $last_run Events: Total- $events_total Failures- $events_failure Success- $events_success"
	echo "$txt: Puppet is Running on $hostname : Version- $puppet_ver Last run- $last_run "
	exit $status
else
	echo "Puppet-agnet service is not running!"
	exit $status
fi
