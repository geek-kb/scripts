#!/bin/bash
# This script receives Scraper name and closes it's sockets on scrapermq.
# Written by Itai Ganot 2015.
scrapername="$1"
if [ -z "$1" ]; then
echo "Usage: $(basename $0) Server_Name"
exit 1
fi
path="/nfs/ops/component/scraper"
server="scrapermq.sj.peer39.com:1099"
cmd="java -jar $path/jmxterm-1.0-alpha-4-uber.jar -l $server"
domain="org.apache.activemq"
beanstemp="/tmp/jmx_beans"
bean1="BrokerName=localhost,Connection=Scraper_$scrapername,ConnectorName=openwire,Type=Connection"
echo beans -d $domain | $cmd  > $beanstemp
idnum=$(grep "ID_$scrapername" $beanstemp | grep openwire | awk -F- '{print $2"-"$3}')
idname="$scrapername-$idnum"
bean2="BrokerName=localhost,Connection=ID_"$idname"-2_0,ConnectorName=openwire,Type=Connection"

echo run stop -b $bean1 -d $domain | $cmd
echo run stop -b $bean2 -d $domain | $cmd


#for ip in `grep "172.29.100.51" /tmp/jmx_beans`; do echo $ip | awk -F/ '{print $2}'| awk -F, '{print $1}';done

