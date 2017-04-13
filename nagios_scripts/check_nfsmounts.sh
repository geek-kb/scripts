#!/bin/bash
# This script checks if the provided mount point is MOUNTED and writeable.
# Script by Itai Ganot
if [ -z "$1" ]; then
	echo "Usage: $(basename $0) PATH_TO_CHECK"
	echo "Available PATH's: /mass1/hp_offline -- /mass1/hpfiles -- /mass2/hpfiles"
	exit 3
fi
DF="/bin/df -t nfs"
GREP="/bin/grep -q"
AWK="/bin/awk"
TOUCH="/bin/touch"
LS="/bin/ls"
WC="/usr/bin/wc"
TESTFILE="test.dat"
USER="peeradmin"
SUDO="/usr/bin/sudo"
NFS_MOUNT="$1"
$DF | $GREP "$NFS_MOUNT" 
	if [ "$?" -eq "0" ]; then
                MOUNTED="yes"
        else
                MOUNTED="no"
        fi
	if [[ "$MOUNTED" = "yes" ]] && [[ $($LS -A "$NFS_MOUNT" | "$WC" -l) -gt "0"  ]]; then
		"$SUDO" -u "$USER" $TOUCH $NFS_MOUNT/$TESTFILE 2>/dev/null
        		if [ $? = 0 ]; then
                		TOUCHED="yes"
       			else
                		TOUCHED="no"
        		fi
	elif [[ "$MOUNTED" = "yes" ]] && [[ $($LS -A "$NFS_MOUNT" | "$WC" -l) -eq "0"  ]]; then
		TXT="$NFS_MOUNT is MOUNTED but directory is empty!"
	        RETVAL="1"
        	STATUS="Warning"
	elif [ "$MOUNTED" = "no" ]; then
		TXT="$NFS_MOUNT NOT MOUNTED!"
		RETVAL="2"
		STATUS="Critical"
	fi



	if [[ "$MOUNTED" = "yes" ]] && [[ "$TOUCHED" = "yes" ]]; then
	TXT="$NFS_MOUNT is MOUNTED properly and writeable for user $USER"
	RETVAL="0"
	STATUS="Ok"
	fi
echo "$STATUS: $TXT"
exit $RETVAL
