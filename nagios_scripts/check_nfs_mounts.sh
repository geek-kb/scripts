#!/bin/bash
# Check mounts based on /etc/fstab
# Script by Itai Ganot 2015

# Variables
grep="/bin/grep"
egrep="/bin/egrep"
awk="/bin/awk"
df="/bin/df"
wc="/usr/bin/wc"
outfile="/tmp/1"
mounts=$($grep nfs /etc/fstab | $egrep -v '^#' | $awk '{printf "%s ", $2}') # Gets all nfs shares, ignoring commneted lines, returns the values in one straight line
mntnum=$(echo $mounts | wc -w) # Counts how many mounts were found

function clean_resource {
echo "" > $outfile # Cleans the resource $outfile
}

clean_resource

# Check if mounts exist
for mount in $mounts; do # For each mount
$df | $grep $mount &>/dev/null # Check if the mount is mounted


# Statements
	if [ "$?" -eq "0" ]; then
		mounted="yes"
		echo $mount $mounted >> $outfile # If a mount point is mounted, write it out to the resource file
		status="OK"
		exitcode="0"
	else
		mounted="no"
		echo $mount $mounted >> $outfile # If a mount point is mounted, write it out to the resource file
		status="Critical"
		exitcode="2"
	fi

done

yesmounted="$(grep "yes" $outfile | $awk '{printf "%s ", $1}' | uniq)" # Find all mounted points in $outfile 
	if [ $($grep "yes" $outfile | wc -l) -eq $mntnum ]; then
		echo -n "$status: Mounts found in /etc/fstab: $mounts--===-- Mounted: $yesmounted"
		exitcode="0"
#		clean_resource
		exit $exitcode
	else
		notmounted="$(grep "no" $outfile | $awk '{printf "%s ", $1}')" # Find all Not mounted points in $outfile 
		status="Critical"
		exitcode="2"
		echo -n "$status: Not mounted: $notmounted--===-- Mounted: $yesmounted"
#		clean_resource
		exit $exitcode
	fi
