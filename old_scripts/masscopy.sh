#!/bin/bash

function usage {
	echo "Usage: $(basename $0) [optional:OPTIONS] [SERVER LIST(s)] -s [SOURCE FILES] -d [REMOTE DESTINATION]"
	echo ""
	echo "Arguments:"
	echo "   -s [FILES]:     Provide source file(s) to be copied"
	echo "   -d [DEST] :     Provide destination file/folder on remote system"
	echo ""
	echo "Options:"
	echo "   -clean    :     Do not print hostname at all"
	echo "   -color    :     Don't print hostname with color"
	echo "                   (useless if -clean is provided)"
}

if [ -z "$1" ] || [ -z "$2" ] ; then
	usage
	exit 1
fi

OPTION_NOCOLOR="false"
OPTION_CLEAN="false"
OPTION_RSYNC="false"

# Process arguments
for a in "$@" ; do
	if [[ $a == -* ]] ; then
		case $(tr -d "-" <<< "$a") in
			"clean") OPTION_CLEAN="true";;
			"color") OPTION_NOCOLOR="true";;
			"rsync") OPTION_RSYNC="true";;
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
	if [ -f "$f" ] ; then
		LIST+=($(cat $f))
		shift
	else	
		break
	fi
done

SOURCE_FILES=()
if [ ! "$1" = "-s" ] ; then
	usage
	exit 1
fi

shift

for f in "$@" ; do
	if [ ! "$f" = "-d" ] ; then
		SOURCE_FILES+=("$f")
		shift
	else
		break
	fi
done

if [ ! "$1" = "-d" ] || [ -z "$2" ] ; then
	echo "ERROR: No destination provided"
	usage
	exit 1
fi

shift
DEST_PATH="$1"

if [ ${#LIST[@]} -eq 0 ] ; then
	echo "ERROR: No lists provided or lists are empty"
	echo "passed argument: $@"
	exit 1
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
	#echo "destination: ${DEST_PATH}"
	scp -r -o ConnectTimeout=5 -o ConnectionAttempts=1 ${SOURCE_FILES[@]} root@$i:${DEST_PATH}
done

exit 0