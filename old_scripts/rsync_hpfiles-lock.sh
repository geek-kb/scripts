#!/bin/bash
# This script copies files from massstorage1:/storage2/hpfiles_staging to hdedgenldr02:/hadoop/rsync/hpfiles , it creates a lock file at the beginning of the run and deletes it at the end of the run.
# Exit codes: 
# 0 - Lock file deleted successfully.
# 1 - Lock file exists or a running process with the script name exists.
# 2 - Lock file could not be deleted.
# 3 - No files older than 10 minutes are present.
# Script by Itai Ganot 2015

# Vars
filedir="/mass1/hpfiles_staging"
varfile="/tmp/varfile"
lockfile="/tmp/rsync_hpfiles.lock"
message="A previous process of this job is still running!"
nofiles="No files have been found which are older than 10 minutes!"
process="$$"

# Logging function
function print_log {
        echo $(date +'%d-%m-%y %H:%M:%S') $* >> /var/log/rsync_hpfiles.log
}

# Tests
#time=$(ps -p $process -o etime= | awk -F: '{print $2}') # number of seconds the process is running.
#
#if [ $(ps -ef | grep $(basename $0) &>/dev/null && echo $?) -eq "0" ] && [ "$time" -gt "5" ]; then # Check if there's a running process with the script name which is running for more than 5 seconds.
#	echo "$message"
#	print_log $message
#	print_log "--------- END --------"
#	exit 1
#fi
if [ -f "$lockfile" ]; then
        echo "$message"
	print_log $message
	print_log "--------- END --------"
        exit 1
fi

# Begin
touch "$lockfile"
if [ "$(find $filedir -name \*.gz -mmin +10 | wc -l)" -eq "0" ]; then
	echo "$nofiles"
	print_log "$nofiles"
	print_log "--------- END --------"
	exit 3
fi
print_log "------ Starting $0 -------"
find $filedir -name .snapshot -prune -o -name \*.gz -mmin +10 >> $varfile
#find $filedir -name \*.gz -mmin +10 >> $varfile
for line in $(awk -F"/" '{print $4}' $varfile); do
	rsync -raPv --ignore-existing --remove-source-files --exclude '.snapshot' --chmod=u+rwx $filedir/$line rsync://_peer39_app@10.11.1.57/hpfiles/ --password-file /etc/rsync.passwd	
done
echo "" > $varfile
print_log "Finished!"
rm -f "$lockfile"
	if [ "$?" -eq "0" ]; then
		echo "$lockfile deleted successfully!"
		print_log "$lockfile deleted successfully!"
		print_log "--------- END --------"
		exit 0
	else
		echo "$lockfile could not be deleted!!"
		print_log "$lockfile could not be deleted!!"
		print_log "--------- END --------"
		exit 2
	fi
# End
