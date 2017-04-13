#!/bin/bash

function usage {
	echo "Usage: $(basename $0) [optional:OPTIONS] [LIST(s)] COMMANDS"
	echo ""
	echo "Options:"
	echo "   -clean    :     Do not print hostname at all"
	echo "   -color    :     Don't print hostname with color"
	echo "                   (useless if -clean is provided)"
	echo "   -peer     :     Run commands as user peeradmin"
}

if [ -z "$1" ] || [ -z "$2" ] ; then
	usage
	exit 1
fi

OPTION_NOCOLOR="false"
OPTION_CLEAN="false"
OPTION_PEERADMIN="false"

# Process arguments
for a in "$@" ; do
	if [[ $a == -* ]] ; then
		case $(tr -d "-" <<< "$a") in
			"clean") OPTION_CLEAN="true";;
			"color") OPTION_NOCOLOR="true";;
			"peer") OPTION_PEERADMIN="true";;
			*) echo "ERROR: Invalid argument $a"
			   exit 1;;
		esac
		shift
	else
		break
	fi
done

LIST=()
for f in "$@" ; do
	if [ -f "$f" ] && [[ $f == *.lst* ]] || [[ $f == *.list* ]]; then
		LIST+=($(cat $f))
		shift
	else	
		break
	fi
done

if [ ${#LIST[@]} -eq 0 ] ; then
	echo "!!! massexec error"
	echo "    No lists provided or lists are empty"
	echo "    REMEMBER: list files must have .lst or .list suffix"
	echo "    passed arguments: $@"
	exit 1
elif [ ${#@} -eq 0 ] ; then
	echo "ERROR: No commands given"
	echo "passed argument: $@"
	exit 1
fi

COMMANDS=""

#Run commands as peeradmin?
if [ "$OPTION_PEERADMIN" = "true" ] ; then
	COMMANDS="su - peeradmin -c '$@'"
else
	COMMANDS="$@"
fi

function hostname_print {
	if [ "$OPTION_CLEAN" = "false" ] ; then
		if [ "$OPTION_NOCOLOR" = "false" ] ; then
			echo -e "\e[1m<< \e[92m${1} \e[0m\e[1m>>\e[0m"
		else
			echo "<< ${1} >>"
		fi
	fi
}

for i in "${LIST[@]}" ; do
	hostname_print "$i"
	ssh  -o ConnectTimeout=5 -o ConnectionAttempts=1 root@$i "$COMMANDS"
done

exit 0