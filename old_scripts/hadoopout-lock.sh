#!/bin/bash
# This script copies files from pgdb01.nj.peer39.com:/mass1/mt_data/hadoop_out to MTNLDR02.eyedcny.local:/hadoop_out/, it creates a lock file at the beginning of the run and deletes it at the end of the run.

# Exit codes: 
# 0 - Lock file deleted successfully.
# 1 - Lock file exists or a running process with the script name exists.
# 2 - Lock file could not be deleted.
# 3 - No files older than 10 minutes are present.
# Script by Itai Ganot 2015

# Vars
mins="60"
sourcedir="/mass1/mt_data/hadoop_out"
varfile="/tmp/varfile"
lockfile="/tmp/rsync_hadoopout.lock"
logfile="/var/log/hadoopout_rsync.log"
message="A previous process of this job is still running!"
nofiles="No files have been found which are older than $mins minutes!"
process="$$"

# Logging function
function print_log {
        echo $(date +'%d-%m-%y %H:%M:%S') $* >> $logfile
}

# Tests
#time=$(ps -p $process -o etime= | awk -F: '{print $2}') # number of seconds the process is running.

#if [ $(ps -ef | grep $(basename $0) &>/dev/null && echo $?) -eq "0" ] && [ "$time" -gt "5" ]; then # Check if there's a running process with the script name which is running for more than 5 seconds.
#        echo "$message"
#        print_log $message
#        print_log "--------- END --------"
#        exit 1
#fi
if [ -f "$lockfile" ]; then
        echo "$message"
        print_log $message
        print_log "--------- END --------"
        exit 1
else
				touch "$lockfile"
fi

# Begin
if [ "$(find $sourcedir -name \*.complete -mmin +$mins | wc -l)" -eq "0" ]; then
        echo "$nofiles"
        print_log "$nofiles"
        print_log "--------- END --------"
        exit 3
fi
find $sourcedir -name \*.complete -mmin +$mins >> $varfile # This is a tricky part, I find all *.complete files which are older than $mins , and paste the list to $varfile, then I run on this list and rsync the file and it's 
# parent folder to the destination
for line in $(awk -F"/" '{print $5}' $varfile); do
                rsync -raPv --ignore-existing --chmod=u+rwx $sourcedir/$line rsync://postgres@10.11.0.61/hadoop_out/ --password-file /etc/rsync.passwd --exclude '*.merged'
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

