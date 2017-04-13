#!/bin/bash
# Itai Ganot 2013 lel@lel.bz
# This script auto-configures a NIS client to work with a NIS server.
# Tested on Centos 6.3
# Run as root .
who=`whoami`
if [ `echo $who` != "root" ];
	then echo "Please run the script using root" 
	exit 
else

/bin/rpm -qa |grep ypbind && /bin/rpm -qa |grep yp-tools
if [ $? != 0 ];
	then yum install ypbind yp-tools -y
else
read -r -p 'What is your NIS domain name?' nisdomain
echo 'Adding NIS server to /etc/sysconfig/network'
echo 'NISDOMAIN="$nisdomain"' >> /etc/sysconfig/network
read -r -p 'What is your NIS server IP?' nisip
echo 'Setting /etc/yp.conf'
echo 'domain $nisdomain server $nisip' >> /etc/yp.conf
##### This section is optional, uncomment if needed: #####
#echo 'Setting /etc/sysconfig/authconfig'
#/bin/sed -i 's/USENIS=no/USENIS=yes/g'
#echo 'session     optional      pam_mkhomedir.so skel=/etc/skel umask=077' >> /etc/pam.d/system-auth
####### End of optional section #######
read -r -p 'What is your NIS server hostname?' nishost
echo 'Adding NIS server to /etc/hosts'
echo '$nisip $nishost' >>/etc/hosts
echo 'Setting domain name'
/bin/domainname $nisdomain
/bin/ypdomainname $nisdomain
echo "Setting /etc/nsswitch.conf"
cat <<EOF > /etc/nsswitch.conf
passwd:     files       nis
shadow:     files       nis
group:      files       nis
hosts:      files nis dns
bootparams: nisplus [NOTFOUND=return] files
ethers:     files
netmasks:   files
networks:   files
protocols:  files
rpc:        files
services:   files
netgroup:   nisplus
publickey:  nisplus
automount:  files nisplus
aliases:    files nisplus
EOF
echo "Starting bind service"
/etc/init.d/ypbind start
echo "Setting rpcbind and bind to start on boot"
/sbin/chkconfig ypbind on
/sbin/chkconfig rpcbind on
fi
fi
