#!/bin/bash
# This script will check the relevant folder and will alert if there are files there which are older than 10 hours.
# Script by Itai Ganot 2015
function usage {
echo "Usage: $(basename $0) PATH_TO_CHECK"
echo "Available path's: hpfiles_staging / hp_offline_staging" 
}

if [ -z "$1" ]; then
    usage
    exit 4
fi
filesdir="$1"
dir="/storage2"
if [ $(find $dir/$filesdir -type f -name \*.gz -mtime +10 | wc -l) -eq "0" ];
        then
        stat="OK"
        exitcode="0"
        msg="There are currently no files in $filesdir which are older than 10 hours"
        else
        stat="Warning"
        exitcode="1"
        msg="There are files in $filesdir which are older than 10 hours!"
fi
echo "$stat: $msg"
exit $exitcode
