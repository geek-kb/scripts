#!/bin/bash
# Script to check and display cpu utilization % .
# Tested and found to be working on both CentOS 5.x and 6.x .
# Script by Itai Ganot 2015 .
#
# Script exit status map:
# 0 = Ok.
# 1 = Warning.
# 2 = Critical
# 3 = Unknown (unable to run sar command)
# 4 = sysstat package is not installed
appname=$(basename "$0")
version="1.0"
author="Itai Ganot 2015, lel@lel.bz"
warnval="$1"
critval="$2"
warntxt="CPU Utilization is too High:"
oktxt="CPU Utilization is normal:"
unknowntxt="sar command failed"
warnstatus="Warning"
critstatus="Critical"
okstatus="Ok"
unknownstatus="3"
warnestatus="1"
critestatus="2"
okestatus="0"
export LC_TIME="POSIX" # Removes AM/PM from time format
yum list installed | grep sysstat &>/dev/null
	if [ "$?" -ne "0" ]; then
		echo "sysstat package is not installed, mandatory for this check"
		exit 4
	fi
function usage {
echo "$appname Version: $version"
echo "Author: $author"
echo "Usage: $appname <warn_val> <crit_val>" # Displays help
}
	if [[ -z "$1" ]] && [[ -z "$2" ]]; then # If no variables have been supplied display usage
		usage
		exit 4
	fi
util=$(sar -u | tail -2 | head -1 | awk '{print $9}')
	if [ -z "$util" ]; then
		util=$(sar -u | tail -2 | head -1 | awk '{print $8}')
	fi
	
	if [ -z "$util" ]; then 
		echo $unknowntxt
		exit $unknownstatus
	fi
int=${util%.*} # round of $util
calc=$((100-int)) 
	if [[ "$calc" -ge "$warnval" ]] && [[  "$calc" -le "$critval" ]]; then
		msg="$warntxt"
		stat="$warnstatus"
		exitstatus=$warnestatus
	elif [[ "$calc" -ge "$critval" ]]; then
		msg="$warntxt"
		stat="$critstatus"
		exitstatus=$critestatus
	elif [[ "$calc" -lt "$warnval" ]]; then
		msg="$oktxt"
		stat="$okstatus"
		exitstatus=$okestatus
	fi
echo "$stat: $msg $calc% | Utilization=$calc;$warnval;$critval;0;100"
exit  $exitstatus
