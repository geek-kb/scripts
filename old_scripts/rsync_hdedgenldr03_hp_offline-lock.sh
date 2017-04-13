#!/bin/bash
# This script copies files from massstorage1:/storage2/hp_offline_staging to hdedgenldr02:/hadoop/rsync/hp_offline .
# Exit codes: 
# 0 - Lock file deleted successfully.
# 1 - Lock file exists or a running process with the script name exists.
# 2 - Lock file could not be deleted.
# 3 - No files older than 10 minutes are present.
# Script by Itai Ganot 2015

# Vars
filedir="/shared/hadoop-test/hp_offline_staging"
varfile="/tmp/varfileoffline"
lockfile="/tmp/rsync_hp_offline.lock"
message="A previous process of this job is still running!"
process="$$"

# Logging function
function print_log {
        echo `/bin/date +"%Y-%m-%d"` $* >> /var/log/rsync_hp_offline.log
}

# Tests
time=$(ps -p $process -o etime= | awk -F: '{print $2}') # number of seconds the process is running.

if [ $(ps -ef | grep $(basename $0) &>/dev/null && echo $?) -eq "0" ] && [ "$time" -gt "10" ]; then # Check if there's a running process with the script name which is running for more than 10 seconds.
        echo "$message"
        print_log $message
        print_log "--------- END --------"
        exit 1
fi
if [ -f "$lockfile" ]; then
        echo "$message"
        print_log $message
        print_log "--------- END --------"
        exit 1
fi

# Begin
touch "$lockfile"
print_log "Finding files to transfer"
find $filedir -name \*.gz -mmin +600 | tee -a $varfile
print_log "Starting copy process - $0."
for line in $(awk -F"/" '{print $4}' $varfile); do
	rsync -raPv --ignore-existing --remove-source-files --chmod=u+rwx $filedir/$line rsync://_peer39_app@ihdedgenldr03.eyedcny.local/hp_offline/ --password-file /etc/rsync.passwd	
done
echo "" > $varfile
print_log "Finished!"

# Managing lock file
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

