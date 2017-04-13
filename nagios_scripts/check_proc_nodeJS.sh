#!/bin/bash
# This script checks for running processes for mt.js and adb-server.js
# Script by Itai Ganot 2015 .
process="$1"
appname=$(basename $0)
if [ -z "$1" ]; then
	echo "Please specify a process to check"
	exit 1
fi
ps -ef | grep "$process" | egrep -v "grep|$appname" &>/dev/null
if [ "$?" -eq "0" ] ; then
	stat="OK"
	exitcode="0"
	msg="Process $process is running"
else
	stat="Critical"
	exitcode="2"
	msg="There are currently no running processes of $process"
fi
pid=$(ps -ef | grep "$process" | egrep -v "grep|$appname" | awk '{print $2}')
echo "$stat: $msg Process PID: $pid"
exit $exitcode
