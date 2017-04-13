#!/bin/bash

#==== Verify user & arguments ====#
if [[ $# == 0 ]]; then
    echo "--> No arguments supplied, exiting!"
    echo "usage: $0 VERSION MD5_DESIRED NEW_VER_PATH"
    exit 1
fi
if [[ $USER != "peeradmin" ]]; then
	    echo "--> Please run with peeradmin only!"
    exit 1
fi


VERSION=$1			#1-1-1-44
MD5_DESIRED=$2 		#17a6dc99cea2fedc1e5970276be361f1__
NEW_VER_PATH=$3     #/proxy_dump/peer39-proxy-$VERSION.bin.zip

TOMCAT=/workspace/development/org/apache/tomcat/6.0.29/
TOMCAT_BIN=$TOMCAT/bin/
LOG=/workspace/repository/proxy/log/all.log
SCRIPTS_DIR=$TOMCAT/webapps/ROOT/WEB-INF/scripts
SCRIPTS_DIR_OPS=/proxy_dump/peer39-ops/scripts
SLEEP_SEC=2
SLEEP_SEC_LONG=15
MY_IP=$(/sbin/ifconfig | grep -Po '(?<=inet addr:)[\d\.]+' | head -1)
LIST=''

############ Functions ############
#Adds proxy to the LB
function lb_in {
	cd $SCRIPTS_DIR && ./setValue.sh /workspace/temp/1.txt ppp && ./setValue.sh /workspace/temp/1 1
}

#Checks if tomcat is up yet
function checklog {
	TEST=$(grep " done." /workspace/repository/proxy/log/all.log > /dev/null 2>&1 ; echo $?)
}

#Checks if tomcat is up yet
function stopApp {
	AppToStop=$1
	echo "---> Stop $AppToStop"
	APP_PID=$(jps -l | grep "$AppToStop" | awk '{print $1}')
	if [ -n "$APP_PID" ]; then ## If the application is running
	    echo "-> Kill $APP_PID process"
	    kill -9 "$APP_PID" && echo "-> Proceed in $((SLEEP_SEC+SLEEP_SEC)) sec" && sleep $((SLEEP_SEC+SLEEP_SEC))
	    if ps -p "$APP_PID" > /dev/null; then
			echo "-> Can't kill the application $AppToStop ($APP_PID), retrying"
	    	kill -9 "$APP_PID" && echo "-> Proceed in $SLEEP_SEC_LONG sec" && sleep $SLEEP_SEC_LONG
	    	if ps -p "$APP_PID" > /dev/null; then
				echo "-> Can't kill the application $AppToStop ($APP_PID), exiting"
				exit 1
			fi
		fi
	else
		echo "-> $AppToStop is not running, no need to stop it"
	fi
}
############


#==== Check MD5 ====#
echo "---> Check MD5"
MD5=`md5sum $NEW_VER_PATH/peer39-proxy-$VERSION.context.zip  | awk '{print $1}'`
if [[ $MD5 != $MD5_DESIRED ]]; then
	echo "-> MD5 doesn't match: $MD5 != $MD5_DESIRED, exiting"
	exit 1
else
	echo "-> MD5 matches - $MD5 == $MD5_DESIRED"
fi
echo -e "---> Proceed in $SLEEP_SEC sec\n"; sleep $SLEEP_SEC

#==== Stop tomcat java ====#
stopApp "catalina" 
jps -l

#==== Stop rmi.registry java ====#
stopApp "rmi.registry"
jps -l

#==== Stop previous script instances ====#
echo "---> Stop previous script instances"
pkill startup.sh
jps -l
echo -e "---> Proceed in $SLEEP_SEC sec\n"; sleep $SLEEP_SEC


#==== Release the new files  ====#
echo "---> Release the new files"

rm -rf /workspace/production/proxy/peer39-proxy-$VERSION
unlink /workspace/production/proxy/peer39-proxy

cd /workspace/production/proxy/ && mkdir peer39-proxy-$VERSION
cd peer39-proxy-$VERSION && cp -f $NEW_VER_PATH/peer39-proxy-$VERSION.context.zip .
unzip peer39-proxy-$VERSION.context.zip

echo "-> Proceed in $SLEEP_SEC sec" && sleep $SLEEP_SEC
cd /workspace/production/proxy/ && ln -s peer39-proxy-$VERSION peer39-proxy
ls -l
echo "-> Proceed in $SLEEP_SEC sec" && sleep $SLEEP_SEC

#==== Fix files  ====#
cd $SCRIPTS_DIR
chmod 755 *.sh
dos2unix *.sh


### ---> WE WANT TO START THE PROXY SEPARATELY ###

#
#==== Starting rmiregistry  ====#
#echo "---> Starting rmiregistry"
#cd $TOMCAT_BIN && nohup rmiregistry -J-Xms1024m -J-Xmx1024m &
#cd $SCRIPTS_DIR
#ant rmiregistry
#echo -e "---> Proceed in $SLEEP_SEC sec\n"; sleep $SLEEP_SEC
#
#==== Starting tomcat  ====#
#echo "---> Starting tomcat"
#cd $TOMCAT_BIN && nohup ./startup.sh &
#echo -e "---> Proceed in $SLEEP_SEC sec\n"; sleep $SLEEP_SEC
#
#==== Wait for proxy to finish loading to switch to 'ppp'  ====#
#echo "---> Wait for proxy to finish loading to switch to 'ppp'"
#while :
#	do
#    	checklog
#	if [ "$TEST" = "0" ]; then
#		echo "-> The proxy is up! Switching to 'ppp' and we're DONE! :)"
#		lb_in; sleep $SLEEP_SEC
#		lb_in; sleep $SLEEP_SEC
#		break
#elif  [ "$TEST" != "0" ]; then
#	echo "-> The proxy is still starting, proceed in $SLEEP_SEC_LONG, zzzzZZzzZz..."
#	sleep $SLEEP_SEC_LONG
#fi
#done
#
#==== How to see the log  ====#
#echo "---> To see the tomcat log"
#echo "tail -f $LOG"
#echo -e "---> Proceed in $SLEEP_SEC sec\n"; sleep $SLEEP_SEC
