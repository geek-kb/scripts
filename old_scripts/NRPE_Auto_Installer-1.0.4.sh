#!/bin/bash
# This script automatically Installs and Configures NRPE on CentOS / RHEL machines, Tested on CentOS 5.x/6.x .
# It is recommended to exchange ssh keys with your Nagios server as the script checks the server's cpu architecture.
# Edit the relevant variables to match your settings.
# Run as root.
# Script by Itai Ganot 2014 mailto:lel@lel.bz.
# Version 1.0.4 (21/10/14)

######                             #    # ######
#     # ###### ###### #    #       #   #  #     #      ####   ####  #    #
#       #      #      #   #        #  #   #     #     #    # #    # ##  ##
#  #### #####  #####  ####   ##### ###    ######      #      #    # # ## #
#     # #      #      #  #         #  #   #     # ### #      #    # #    #
#     # #      #      #   #        #   #  #     # ### #    # #    # #    #
 #####  ###### ###### #    #       #    # ######  ###  ####   ####  #    #

USER=$(whoami)
LOCALARCH=$(/bin/uname -p)
##########################----- Edit only these Variables --------#####################
NGPLUGINS64="/usr/lib64/nagios/plugins" # Default plug-ins folder on 64bit machines
NGPLUGINS32="/usr/lib/nagios/plugins" # Default plug-ins folder on 32bit machines
NRPECFG="/etc/nagios/nrpe.cfg" # NRPE configuration file
NRPESVC="/etc/init.d/nrpe" # NRPE daemon file
XINETDSVC="/etc/init.d/xinetd" # NRPE daemon file
YUMREPOS="/etc/yum.repos.d" # Yum repository path
SCP="$(which scp) -r" # scp path
NGUSER="nagios" # Nagios user	
NGGROUP="nagios" # Nagios group
NAGIOSSRV="10.13.0.11" # Nagios server IP address
NRPEPORT="5666" # NRPE port
XINETDFILE="/etc/xinetd.d/nrpe" # Xinetd file
NRPEPIDFILE="/var/run/nrpe/nrpe.pid" # NRPE pid file
SUDOERS="/etc/sudoers" # sudoers file
NAGSRVUSR="root" # A user which is allowed to log into Nagios server
####################### */* DO NOT EDIT BELOW THIS LINE *\* ############################
NAGIOSSRVETC=/usr/local/nagios
NAGIOSINSTMODE="source"
if [ "$USER" != "root" ]; then
	echo "Run as root!"
  exit 3
fi
echo "Checking if Nagios (server) was compiled from source or installed through YUM"
ssh $NAGSRVUSR@$NAGIOSSRV 'yum list installed | grep "^nagios\."' 
if [ "$?" -eq "0" ]; then
	NAGIOSSRVETC=/etc/nagios ; NAGIOSINSTMODE="yum"
	echo "Nagios has been installed through YUM"
else
	ssh $NAGSRVUSR@$NAGIOSSRV '/usr/bin/which nagios'
	if [ "$?" -eq "0" ]; then
		ssh $NAGSRVUSR@$NAGIOSSRV '[ -e $NAGIOSSRVETC ]'
			if [ "$?" -eq "0" ]; then
			NAGIOSSRVETC=$NAGIOSSRVETC && NAGIOSINSTMODE="source"
			echo "Nagios has been installed from source"
			else
			read -r -p "Can't find Nagios installation on $NAGIOSSRV, please supply installation path (where Nagios etc/ is)" INSTPATH
			NAGIOSSRVETC="$INSTPATH"
			fi
	fi
fi

echo "Retrieving Nagios server Architecture..."
NGSRVARCH=$(ssh $NAGSRVUSR@$NAGIOSSRV "uname -p")
if [ "$NGSRVARCH" = "x86_64" ] ; then
	NGSARCH="64"
 else
	NGSARCH="32"
fi

if [ "$LOCALARCH" = "x86_64" ] ; then
	ARCH="64"
else
	ARCH="32"
fi

if [ ! -e $YUMREPOS/epel.repo ] ;
	then echo "EPEL repo is not installed."
	read -r -p "Would you like to add it? [y/n] " EPEL 
		if [[ "$EPEL" = [Nn] ]]; then 
			echo "Quitting NRPE agent installation"
			exit 2
		elif [[ "$EPEL" = [Yy] ]] && [ "$LOCALARCH" = "x86_64" ]; then 
			cd /tmp && wget http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm 
			cd /tmp && wget http://rpms.famillecollet.com/enterprise/remi-release-6.rpm
			cd /tmp && rpm -Uvh remi-release-6*.rpm epel-release-6*.rpm
			/bin/sed -i 's/https/http/g' "$YUMREPOS"/epel.repo
		elif [[ "$EPEL" = [Yy] ]] && [ "$LOCALARCH" = "i686" ]; then
			cd /tmp && wget http://dl.fedoraproject.org/pub/epel/5/x86_64/epel-release-5-4.noARCH.rpm
			cd /tmp && wget http://rpms.famillecollet.com/enterprise/remi-release-5.rpm 
			cd /tmp && rpm -Uvh remi-release-5*.rpm epel-release-5*.rpm
			/bin/sed -i 's/https/http/g' "$YUMREPOS"/epel.repo
			fi
	fi
echo "Installing required packages"
yum install -y nagios-plugins-nrpe nrpe openssl glibc openssl098e-0.9.8e-18.el6_5.2.x86_64 openssl098e-0.9.8e-18.el6_5.2.i686

case "$ARCH" in
32)
echo "Configuring $NRPECFG"
cat <<EOF > $NRPECFG
pid_file=$NRPEPIDFILE
server_port=$NRPEPORT
nrpe_user=$NGUSER
nrpe_group=$NGGROUP
dont_blame_nrpe=1
debug=1
command_timeout=60
allowed_hosts=127.0.0.1,$NAGIOSSRV
 
command[check_ping]=$NGPLUGINS32/check_ping -w \$ARG1$ -c \$ARG2$
command[check_ifstatus]=$NGPLUGINS32/check_ifstatus -w \$ARG1$ -c \$ARG2$
command[check_local_load]=$NGPLUGINS32/check_load -w \$ARG1$ -c \$ARG2$
command[check_local_disk]=$NGPLUGINS32/check_disk -w \$ARG1$ -c \$ARG2$ -p \$ARG3$
#command[check_disk_root]=$NGPLUGINS32/check_disk -a '-w 20% -c 10% -p /'
command[check_local_procs]=$NGPLUGINS32/check_procs -w \$ARG1$ -c \$ARG2$ -s \$ARG3$
command[check_cpu_load]=$NGPLUGINS32/check_procs -w \$ARG1$ -c \$ARG2$ -m \$ARG3$ -v
command[check_procs_by_name]=$NGPLUGINS32/check_procs -w \$ARG1$ -c \$ARG2$ -C \$ARG3$
command[check_local_mysql]=$NGPLUGINS32/check_mysql -u root -w \$ARG1$ -c \$ARG2$ -S
command[check_provider_ftp]=$NGPLUGINS32/check_ftp -H \$ARG1$ -w \$ARG2$ -c \$ARG3$
############################## Additional Centerity Command Args ###########################################
command[check_openfiles]=$NGPLUGINS32/check_openfiles \$ARG1$
############################## Begin Centerity Command Args ###########################################
command[version]=$NGPLUGINS32/version
command[centerity_event_command]=$NGPLUGINS32/centerity_command \$ARG1$ \$ARG2$
command[check_disk]=$NGPLUGINS32/check_disk \$ARG1$
command[check_users]=sudo \$NGPLUGINS32/check_users \$ARG1$
command[check_load]=$NGPLUGINS32/check_load \$ARG1$
command[check_procs]=$NGPLUGINS32/check_procs \$ARG1$
command[check_zombie_procs]=$NGPLUGINS32/check_procs \$ARG1$
command[check_total_procs]=$NGPLUGINS32/check_procs \$ARG1$
command[check_uptime]=$NGPLUGINS32/check_uptime \$ARG1$
command[check_netstat]=$NGPLUGINS32/check_netstat \$ARG1$
command[check_veritas_disks]=$NGPLUGINS32/check_vxdisk
command[check_swap]=$NGPLUGINS32/check_swap  -w 50% -c 38%
command[check_memory]=$NGPLUGINS32/check_memory \$ARG1$
command[check_log]=$NGPLUGINS32/check_log \$ARG1$
command[check_log2]=$NGPLUGINS32/check_log2 \$ARG1$
command[check_date]=$NGPLUGINS32/check_date \$ARG1$
command[check_file_age]=$NGPLUGINS32/check_file_age \$ARG1$
command[check_mailq]=$NGPLUGINS32/check_mailq \$ARG1$
command[check_netstat]=$NGPLUGINS32/check_netstat \$ARG1$
command[check_oracle]=$NGPLUGINS32/check_oracle \$ARG1$
command[check_mysql]=$NGPLUGINS32/check_mysql \$ARG1$
command[check_sensors]=$NGPLUGINS32/check_sensors \$ARG1$
command[check_vxdisk]=$NGPLUGINS32/check_vxdisk \$ARG1$
command[check_tcp]=$NGPLUGINS32/check_tcp \$ARG1$
command[check_udp]=$NGPLUGINS32/check_udp \$ARG1$
command[check_by_ssh]=$NGPLUGINS32/check_by_ssh \$ARG1$
command[check_dummy]=$NGPLUGINS32/check_dummy \$ARG1$
command[check_flexlm]=$NGPLUGINS32/check_flexlm \$ARG1$
command[check_proc_load]=$NGPLUGINS32/check_proc_load \$ARG1$
command[check_veritas_cluster]=$NGPLUGINS32/check_vcs \$ARG1$
command[check_dell_storage]=$NGPLUGINS32/check_openmanage --only storage
command[check_dell_fans]=$NGPLUGINS32/check_openmanage --only fans
command[check_dell_memory]=$NGPLUGINS32/check_openmanage --only memory
command[check_dell_power]=$NGPLUGINS32/check_openmanage --only power
command[check_dell_temp]=$NGPLUGINS32/check_openmanage --only temp
command[check_dell_cpu]=$NGPLUGINS32/check_openmanage --only cpu
command[check_dell_voltage]=$NGPLUGINS32/check_openmanage --only voltage
command[check_dell_batteries]=$NGPLUGINS32/check_openmanage --only batteries
command[check_dell_amperage]=$NGPLUGINS32/check_openmanage --only amperage
command[check_dell_intrusion]=$NGPLUGINS32/check_openmanage --only intrusion
command[check_dell_sdcard]=$NGPLUGINS32/check_openmanage --only sdcard
command[check_dell_esmhealth]=$NGPLUGINS32/check_openmanage --only esmhealth
command[check_dell_esmlog]=$NGPLUGINS32/check_openmanage --only esmlog
command[check_dell_alertlog]=$NGPLUGINS32/check_openmanage --only alertlog
command[check_dell_critical]=$NGPLUGINS32/check_openmanage --only critical
command[check_dell_warning]=$NGPLUGINS32/check_openmanage --only warning
command[check_openmanage]=$NGPLUGINS32/check_openmanage
command[check_kvm]=sudo $NGPLUGINS32/check_kvm
EOF
echo "Adding user $NGUSER to $SUDOERS"
echo "Defaults:$NGUSER !requiretty" >> $SUDOERS
echo "nagios ALL = NOPASSWD:$NGPLUGINS32/*" >> $SUDOERS
echo "Setting ownership of /etc/nagios and Nagios Plug-ins folders to $NGUSER"
chown -R $NGUSER.$NGGROUP /etc/nagios ; chown -R $NGUSER.$NGGROUP $NGPLUGINS32
;;

64)
echo "Configuring $NRPECFG"
cat << EOF > "$NRPECFG"
pid_file="$NRPEPIDFILE"
server_port=$NRPEPORT
nrpe_user=$NGUSER
nrpe_group=$NGGROUP
dont_blame_nrpe=1
debug=1
command_timeout=60
allowed_hosts=127.0.0.1,$NAGIOSSRV
 
 
command[check_ping]=$NGPLUGINS64/check_ping -w \$ARG1$ -c \$ARG2$
command[check_ifstatus]=$NGPLUGINS64/check_ifstatus -w \$ARG1$ -c \$ARG2$
command[check_local_load]=$NGPLUGINS64/check_load -w \$ARG1$ -c \$ARG2$
command[check_local_disk]=$NGPLUGINS64/check_disk -w \$ARG1$ -c \$ARG2$ -p \$ARG3$
#command[check_disk_root]=$NGPLUGINS64/check_disk -a '-w 20% -c 10% -p /'
command[check_local_procs]=$NGPLUGINS64/check_procs -w \$ARG1$ -c \$ARG2$ -s \$ARG3$
command[check_cpu_load]=$NGPLUGINS64/check_procs -w \$ARG1$ -c \$ARG2$ -m \$ARG3$ -v
command[check_procs_by_name]=$NGPLUGINS64/check_procs -w \$ARG1$ -c \$ARG2$ -C \$ARG3$
command[check_local_mysql]=$NGPLUGINS64/check_mysql -u root -w \$ARG1$ -c \$ARG2$ -S
command[check_provider_ftp]=$NGPLUGINS64/check_ftp -H \$ARG1$ -w \$ARG2$ -c \$ARG3$
############################## Additional Centerity Command Args ###########################################
command[check_openfiles]=$NGPLUGINS64/check_openfiles \$ARG1$
############################## Begin Centerity Command Args ###########################################
command[version]=$NGPLUGINS64/version
command[centerity_event_command]=$NGPLUGINS64/centerity_command \$ARG1$ \$ARG2$
command[check_disk]=$NGPLUGINS64/check_disk \$ARG1$
command[check_users]=sudo \$NGPLUGINS64/check_users \$ARG1$
command[check_load]=$NGPLUGINS64/check_load \$ARG1$
command[check_procs]=$NGPLUGINS64/check_procs \$ARG1$
command[check_zombie_procs]=$NGPLUGINS64/check_procs \$ARG1$
command[check_total_procs]=$NGPLUGINS64/check_procs \$ARG1$
command[check_uptime]=$NGPLUGINS64/check_uptime \$ARG1$
command[check_netstat]=$NGPLUGINS64/check_netstat \$ARG1$
command[check_veritas_disks]=$NGPLUGINS64/check_vxdisk
command[check_swap]=$NGPLUGINS64/check_swap  -w 50% -c 38%
command[check_memory]=$NGPLUGINS64/check_memory \$ARG1$
command[check_log]=$NGPLUGINS64/check_log \$ARG1$
command[check_log2]=$NGPLUGINS64/check_log2 \$ARG1$
command[check_date]=$NGPLUGINS64/check_date \$ARG1$
command[check_file_age]=$NGPLUGINS64/check_file_age \$ARG1$
command[check_mailq]=$NGPLUGINS64/check_mailq \$ARG1$
command[check_netstat]=$NGPLUGINS64/check_netstat \$ARG1$
command[check_oracle]=$NGPLUGINS64/check_oracle \$ARG1$
command[check_mysql]=$NGPLUGINS64/check_mysql \$ARG1$
command[check_sensors]=$NGPLUGINS64/check_sensors \$ARG1$
command[check_vxdisk]=$NGPLUGINS64/check_vxdisk \$ARG1$
command[check_tcp]=$NGPLUGINS64/check_tcp \$ARG1$
command[check_udp]=$NGPLUGINS64/check_udp \$ARG1$
command[check_by_ssh]=$NGPLUGINS64/check_by_ssh \$ARG1$
command[check_dummy]=$NGPLUGINS64/check_dummy \$ARG1$
command[check_flexlm]=$NGPLUGINS64/check_flexlm \$ARG1$
command[check_proc_load]=$NGPLUGINS64/check_proc_load \$ARG1$
command[check_veritas_cluster]=$NGPLUGINS64/check_vcs \$ARG1$
command[check_dell_storage]=$NGPLUGINS64/check_openmanage --only storage
command[check_dell_fans]=$NGPLUGINS64/check_openmanage --only fans
command[check_dell_memory]=$NGPLUGINS64/check_openmanage --only memory
command[check_dell_power]=$NGPLUGINS64/check_openmanage --only power
command[check_dell_temp]=$NGPLUGINS64/check_openmanage --only temp
command[check_dell_cpu]=$NGPLUGINS64/check_openmanage --only cpu
command[check_dell_voltage]=$NGPLUGINS64/check_openmanage --only voltage
command[check_dell_batteries]=$NGPLUGINS64/check_openmanage --only batteries
command[check_dell_amperage]=$NGPLUGINS64/check_openmanage --only amperage
command[check_dell_intrusion]=$NGPLUGINS64/check_openmanage --only intrusion
command[check_dell_sdcard]=$NGPLUGINS64/check_openmanage --only sdcard
command[check_dell_esmhealth]=$NGPLUGINS64/check_openmanage --only esmhealth
command[check_dell_esmlog]=$NGPLUGINS64/check_openmanage --only esmlog
command[check_dell_alertlog]=$NGPLUGINS64/check_openmanage --only alertlog
command[check_dell_critical]=$NGPLUGINS64/check_openmanage --only critical
command[check_dell_warning]=$NGPLUGINS64/check_openmanage --only warning
command[check_openmanage]=$NGPLUGINS64/check_openmanage
command[check_kvm]=sudo $NGPLUGINS64/check_kvm
EOF
echo "Adding user $NGUSER to $SUDOERS"
echo "Defaults:$NGUSER !requiretty" >> $SUDOERS
echo "nagios ALL = NOPASSWD:$NGPLUGINS64/*" >> $SUDOERS
echo "Setting ownership of /etc/nagios and Nagios Plug-ins folders to $NGUSER"
chown -R $NGUSER.$NGGROUP /etc/nagios ; chown -R $NGUSER.$NGGROUP $NGPLUGINS64
esac

echo "How would you like to configure the NRPE daemon?"
select DMN in 'Xinetd' 'Standalone Daemon'; do
if [ "$DMN" = "Xinetd" ]; then
	DMNMODE="xinetd"
		if [ -e $XINETDSVC ]; then
			echo "Configuring Xinetd..."
			cat << EOF > $XINETDFILE
service nrpe
{
        flags           = REUSE
        type            = UNLISTED
        port            = $NRPEPORT
        socket_type     = stream
        wait            = no
        user            = $NGUSER 
        group           = $NGGROUP
        server          = /usr/sbin/nrpe
        server_args     = -c $NRPECFG --inetd
        log_on_failure  += USERID
        disable         = no
        only_from       = 127.0.0.1 $NAGIOSSRV
}
EOF
	$XINETDSVC restart
break
		else
		echo "Xinetd is not installed, please choose again"
		fi
elif [ "$DMN" = "Standalone Daemon" ]; then 
	DMNMODE="daemon"
	chkconfig nrpe on ; $NRPESVC start
	break
fi
done
function CheckInstMode {
	if [ "$DMNMODE" = "daemon" ]; then
			$NRPESVC restart
	else
			$XINETDSVC restart
	fi
}

read -r -p "Would you like to pull NRPE plugins from Nagios server? [y/n] " ANS1
if [[ "$ANS1" = [Yy] ]]; then
case $NAGIOSINSTMODE in
source)
		if [ "$ARCH" -eq "64" -a "$NGSARCH" -eq "64" ] ; then
			$SCP $NAGSRVUSR@$NAGIOSSRV:"$NAGIOSSRVETC"/libexec/* "$NGPLUGINS64"/
			chown -R $NGUSER.$NGGROUP "$NGPLUGINS64"
			CheckInstMode
		elif [ "$ARCH" -eq "64" -a "$NGSARCH" -eq "32" ] ; then
			$SCP $NAGSRVUSR@$NAGIOSSRV:"$NAGIOSSRVETC"/libexec/* "$NGPLUGINS64"/
			chown -R $NGUSER.$NGGROUP "$NGPLUGINS64"
			CheckInstMode
		elif [ "$ARCH" -eq "32" -a "$NGSARCH" -eq "32" ] ; then
			$SCP $NAGSRVUSR@$NAGIOSSRV:"$NAGIOSSRVETC"/libexec/* "$NGPLUGINS32"/
			chown -R $NGUSER.$NGGROUP "$NGPLUGINS32"
			CheckInstMode
		elif [ "$ARCH" -eq "32" -a  "$NGSARCH" -eq "64" ] ; then
			$SCP $NAGSRVUSR@$NAGIOSSRV:"$NAGIOSSRVETC"/libexec/* "$NGPLUGINS32"/
			chown -R $NGUSER.$NGGROUP "$NGPLUGINS32"
			CheckInstMode
		fi
;;
yum)
		if [ "$ARCH" -eq "64" -a "$NGSARCH" -eq "64" ] ; then
			$SCP $NAGSRVUSR@$NAGIOSSRV:"$NGPLUGINS64"/* "$NGPLUGINS64"/
			chown -R $NGUSER.$NGGROUP "$NGPLUGINS64"
			CheckInstMode
		elif [ "$ARCH" -eq "64" -a "$NGSARCH" -eq "32" ] ; then
			$SCP $NAGSRVUSR@$NAGIOSSRV:"$NGPLUGINS32"/* "$NGPLUGINS64"/
			chown -R $NGUSER.$NGGROUP "$NGPLUGINS64"
			CheckInstMode
		elif [ "$ARCH" -eq "32" -a "$NGSARCH" -eq "32" ] ; then
			$SCP $NAGSRVUSR@$NAGIOSSRV:"$NGPLUGINS32"/* "$NGPLUGINS32"/
			chown -R $NGUSER.$NGGROUP "$NGPLUGINS32"
			CheckInstMode
		elif [ "$ARCH" -eq "32" -a  "$NGSARCH" -eq "64" ] ; then
			$SCP $NAGSRVUSR@$NAGIOSSRV:"$NGPLUGINS64"/* "$NGPLUGINS32"/
			chown -R $NGUSER.$NGGROUP "$NGPLUGINS32"
			CheckInstMode
		fi
;;
esac
fi
# Preparationg for check_filemtime #################################
stat --format='%Y' /etc/passwd > /usr/local/share/applications/file
chmod +x /usr/local/share/applications/file
####################################################################
read -r -p "Would you like to test NRPE? [y/n] " ANS2
if [[ "$ANS2" = [Yy] ]]; then
		if [ "$ARCH" -eq "64" ]; then 
				"$NGPLUGINS64"/check_nrpe -H 127.0.0.1
		else
				"$NGPLUGINS32"/check_nrpe -H 127.0.0.1
		fi
fi
if [ $? = 0 ]; then
		echo "NRPE installed successfully!"
		exit 0
else
		echo "Failed NRPE installation!"
		exit 2
fi

