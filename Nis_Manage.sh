#!/bin/bash
# This script will simplicate NIS user management.
# You will not be able to change password or delete users peeradmin and root through this script.
# Written by Itai Ganot 2014.

# Edit only this variable:
PROTECTEDUSERS="root" # Separate values with spaces.

# Variables
USER=$1
GREP="/bin/grep"
PASSWDFILE="/etc/passwd"
YPPASSWD="/usr/bin/yppasswd"
USERDEL="/usr/sbin/userdel"
USERADD="/usr/sbin/useradd"
PASSWD="/usr/bin/passwd"
YPCAT="/usr/bin/ypcat passwd.byname"

# Functions
function usage {
echo -e "Usage: $0 <username to manage>"
}

function updatenis {
echo -e "\e[36m #===#  Uptdating NIS database... \e[0m"
cd /var/yp && make
}

# Script
if [ -z "$USER" ]; then
usage
exit 1
fi
if [ "$(id -u)" != "0" ]; then
echo -e "Run as root!"
exit 1
fi
"$GREP" -q "$USER" "$PASSWDFILE"
if [ "$?" = "0" ]; then
	echo -e "\e[36m #===#  User already exists \e[0m"
	echo -e "\e[36m #===#  How would you like to continue? \e[0m"
	USERID=$(id -u $USER)
	select CHOICE in 'Change user password' 'Remove user' 'View user' 'Exit'; do
		case $CHOICE in
		"Change user password")
		if [[ "$PROTECTEDUSERS" =~ $USER ]]; then # Defense against changing Protected users password
                        echo -e "\e[36m #===#  User $USER should never be edited! \e[0m"
                        exit 1
                        fi

		echo -e "\e[36m #===#  Provide root password for NIS server... \e[0m"
		"$YPPASSWD" "$USER"
		break
		;;
		"Remove user")
			if [[ "$PROTECTEDUSERS" =~ $USER ]]; then # Defense against changing Protected users password
			echo -e "\e[36m #===#  User $USER should never be edited! \e[0m"
			exit 1
			fi
		read -r -p "Remove home directory and mail? [y/n] " ANSWER1
		if [[ "$ANSWER1" = [Yy] ]]; then
		"$USERDEL" -r "$USER"
		updatenis
		echo -e "\e[36m #===#  User $USER has been deleted along with the user's home folder and mail \e[0m"
		break
		else
		"$USERDEL" "$USER"
		echo -e "\e[36m #===#  User $USER has been deleted \e[0m"
		updatenis
		break
		fi
		;;
		"View user")
		echo -e "\e[36m #===# Displaying user $USER \e[0m"
		$YPCAT | $GREP "$USER"
		break		
		;;
		"Exit")
		echo -e "\e[36m #===#  Exiting, No changes done.  \e[0m"
		exit 0
		;;
		esac
	done
else
	read -r -p "User doesn't exist, would you like to add it? [y/n] " ANSWER2
	if [[ "$ANSWER2" = [Yy] ]]; then
		echo -e "\e[36m #===#  Collecting required information... \e[0m"
		sleep 2
		LASTUID=$(tail -n 1 $PASSWDFILE | awk -F: '{print $3}')
		NEXTUID=$(( LASTUID + 1 ))
		$USERADD -g users $USER -u $NEXTUID
		echo -e "\e[36m #===#  Set password for the new user \e[0m"
		$PASSWD $USER
		updatenis
		read -r -p "Would you like to test the creation of the user? [y/n] " ANSWER3
			if [[ "$ANSWER3" = [Yy] ]]; then
			$YPCAT | $GREP "$USER"
				if [ "$?" = "0" ]; then
				echo -e "\e[36m #===#  User $USER created successfully!  \e[0m"
				fi
			fi
	elif [[ "$ANSWER2" = [Nn] ]]; then
		echo -e "\e[36m #===#  Exiting, no changes done. \e[0m"
		exit 0
	fi
fi
