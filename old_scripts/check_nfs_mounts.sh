#!/bin/bash
# Check mounts based on /etc/fstab
# Script by Itai Ganot 2015
grep="/bin/grep"
awk="/bin/awk"
df="/bin/df"
wc="/usr/bin/wc"
outfile="/tmp/1"
mounts=$($awk '/nfs/{printf "%s ", $2}END{if(f)print ""}' /etc/fstab)
mntnum=$(echo $mounts | wc -w)
echo "" > $outfile
# Check if mounts exist
for mount in $mounts; do
$df | $grep $mount &>/dev/null
if [ "$?" -eq "0" ]; then
mounted="yes"
else
mounted="no"
fi
if [ "$mounted" = "yes" ]; then
echo $mount $mounted >> $outfile
fi
done
if [ $($grep "yes" $outfile | wc -l) -eq $mntnum ]; then
echo -n "Mounts found in /etc/fstab: $mounts Mounted=YES $mounts"
fi
