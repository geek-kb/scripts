#!/bin/bash
# This script checks network transfer speed using dd between a server and one of the provided mounts.
# Script by Itai Ganot 2014.
function usage {
echo "Usage: $0 MOUNTPATH"
echo "Available path's: proxy_dump / proxy_logs / sync_logs"
}
	if [ -z "$1" ]; then
		usage
		exit 4
	fi
CAT="/bin/cat"
AWK="/bin/awk"
RM="/bin/rm"
DD="/bin/dd"
DF="/bin/df"
GREP="/bin/grep"
DDLOG="/tmp/dd.log"
OKVAL="15"
WARNVAL="10"
CRITVAL="5"
FILENAME="$(hostname).dat"
MOUNTPATH=$1
	if [ ! -d "/$MOUNTPATH" ]; then
		echo "Path /$MOUNTPATH is not mounted"
		exit 4
	fi
$DD if=/dev/zero of=/$MOUNTPATH/$FILENAME bs=1024 count=102 > $DDLOG 2>&1
SPEEDVALUE=$( $CAT $DDLOG | $AWK 'NR==3' | $AWK '{print $8}')
SPEEDMETRIC=$( $CAT $DDLOG | $AWK 'NR==3' | $AWK '{print $9}')
ROUNDVALUE=$($AWK -v v="$SPEEDVALUE" 'BEGIN{printf "%d", v}')
	if [ "$(echo ${SPEEDMETRIC:0:2})" = "MB" ]; then
		ROUNDMETRIC="MB"
	else
		ROUNDMETRIC="KB"
	fi

# Statements
case $ROUNDMETRIC in
"MB")
	if [ "$ROUNDVALUE" -ge "$OKVAL" ]; then
		STATUSTXT="OK: speed is $SPEEDVALUE $SPEEDMETRIC"
		EXITCODE="0"
	elif [ "$ROUNDVALUE" -ge "$WARNVAL" ] && [ "$ROUNDVALUE" -lt "$OKVAL" ]; then
		STATUSTXT="WARNING: Speed is $SPEEDVALUE $SPEEDMETRIC"
		EXITCODE="1"
	elif [ "$ROUNDVALUE" -le "$CRITVAL" ]; then
		STATUSTXT="CRITICAL: Speed is ${SPEEDVALUE} ${SPEEDMETRIC}"
                EXITCODE="2"
	fi
;;
"KB")
		STATUSTXT="CRITICAL: Speed is ${SPEEDVALUE} ${SPEEDMETRIC}"
		EXITCODE="2"
;;
esac
$RM -f /$MOUNTPATH/$FILENAME
# Output
echo "$STATUSTXT , Checked against /$MOUNTPATH | Speed=$ROUNDVALUE;$WARNVAL;$CRITVAL;$OKVAL;;"
exit $EXITCODE
