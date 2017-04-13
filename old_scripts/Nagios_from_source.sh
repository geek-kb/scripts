#!/bin/bash
echo "Enter nagios user to use"
read NAGUSR
echo "Enter nagios group to use"
read NAGGRP

# Requirements Installation
yum install -y wget httpd php gcc glibc glibc-common gd gd-devel make net-snmp

# Nagios Installation
echo "Downloading latest Nagios Core and Plugins..."
cd /tmp && wget http://sourceforge.net/projects/nagios/files/nagios-4.x/nagios-4.1.0/nagios-4.1.0rc1.tar.gz && wget http://nagios-plugins.org/download/nagios-plugins-2.0.tar.gz
echo "Adding $NAGUSR and $NAGGRP..."
useradd $NAGUSR -g $NAGGRP
echo "Uncompressing..."
cd /tmp && tar xvzf nagios-4.1.0rc1.tar.gz
cd /tmp && tar xvzf nagios-plugins-2.0.tar.gz
echo "Configuring Nagios"
cd /tmp/nagios-4.1.0rc1 && ./configure --with-command-group=nagios && make all && make install && make install-init && make install-config  && make install-commandmode && make install-webconf

cp -R /tmp/nagios-4.1.0rc1/contrib/eventhandlers/ /usr/local/nagios/libexec/
chown -R nagios:nagios /usr/local/nagios/libexec/eventhandlers

# Check Nagios configuration and start service
/usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg
/etc/init.d/nagios start

cd /usr/local/nagios/etc && htpasswd –c htpasswd.users nagiosadmin

# Nagios Plugins Install
cd /tmp/nagios-plugins-2.0 && ./configure --with-nagios-user=nagios --with-nagios-group=nagios && make && make install

# Service Setup

chkconfig --add nagios
chkconfig --level 35 nagios on
chkconfig --add httpd
chkconfig --level 35 httpd on
/etc/init.d/httpd start

# Management User
read -r -p "Would you like to add an administrative user?" adm
if [[ "$adm" = [Yy] ]];
	then
	read -r -p "Enter username" user
	htpasswd -c /usr/local/nagios/etc/htpasswd.users $user
else
exit 0
fi
	
	
echo "Done!"
