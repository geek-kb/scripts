#!/bin/bash
# Script to check cpu usage % .
# Script by Itai Ganot 2015 .
yum list installed | grep sysstat &>/dev/null
	if [ "$?" -ne "0" ]; then
		echo "sysstat package is not installed, mandatory for this check"
		exit 4
	fi
export LC_TIME="POSIX" # Removes AM/PM from time format
appname=$(basename "$0") # Gets filename
warnval="$1"
critval="$2"
function usage {
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
int=${util%.*} # round of $util
calc=$((100-int)) 
	if [[ "$calc" -ge "$warnval" ]] && [[  "$calc" -le "$critval" ]]; then
		echo "WARNING: CPU Utilization is too High: $calc%"
		exit 1
	elif [[ "$calc" -ge "$critval" ]]; then
		echo "CRITICAL: CPU Utilization is too High: $calc%"
		exit 2
	elif [[ "$calc" -lt "$warnval" ]]; then
		echo "OK: CPU Utilization is normal: $calc%"
	exit 0
	fi
