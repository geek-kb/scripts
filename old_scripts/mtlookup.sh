#!/bin/bash
# This script syncs data from pgdb01.nj.peer39.com:/mass1/mt_lookups to MTNLDR02.eyedcny.local:/verfiles/rsync/mt_lookups_out/
# Script by Itai Ganot 2015
DATE=$(/bin/date +%F)
TIME=$(/bin/date +%R)
LOG="/var/log/hadoop_rsync.log"
FIND="/bin/find"
DIRPATH="/mass1/mt_lookups"
echo "$DATE $TIME --- Starting sync! ---"
for DIR in $(ls -l $DIRPATH | grep ^d | awk '{print $9}'); do
	$FIND $DIRPATH/$DIR/
	ls $DIRPATH/$DIR/*.complete 2>/dev/null
	if [ "$?" -eq "0" ]; then
		rsync -raPv --ignore-existing --chmod=u+rwx  $DIRPATH/$DIR/*.complete rsync://postgres@10.11.0.61/mt_lookups/$DIR/ --password-file /etc/rsync.passwd --exclude '*.merged'
	fi
done
echo "$DATE $TIME --- Finished sync! ---"
