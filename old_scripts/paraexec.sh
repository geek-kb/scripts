#!/bin/bash

function usage {
	echo "Usage: $(basename $0) [OPTIONS] [LIST(s)] COMMANDS"
	echo ""
	echo "Options:"
	echo "   -peer     :     Run commands as user peeradmin"
	echo ""
}

if [ -z "$1" ] || [ -z "$2" ] ; then
	usage
	exit 1
fi

TIMEOUT=5
SESSIONS=8
LISTFILE=/tmp/paraexeclist.lst

OPTION_PEERADMIN="false"

# Process arguments
for a in "$@" ; do
	if [[ $a == -* ]] ; then
		case $(tr -d "-" <<< "$a") in
			#"clean") OPTION_CLEAN="true";;
			#"color") OPTION_NOCOLOR="true";;
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
		LIST+=($(cat -v $f))
		shift
	else	
		break
	fi
done

if [ ${#LIST[@]} -eq 0 ] ; then
	echo "!!! paraexec error"
	echo "    No lists provided or lists are empty"
	echo "    REMEMBER: list files must have .lst or .list suffix"
	echo "    passed arguments: $@"
	exit 1
elif [ ${#@} -eq 0 ] ; then
	echo "ERROR: No commands given"
	echo "passed argument: $@"
	exit 1
fi

if ! printf "%s\n" "${LIST[@]}" > $LISTFILE ; then
	echo "!!! paraexec error"
	echo "    Can't write to $LISTFILE"
	exit 1
fi

COMMANDS=""

#Run commands as peeradmin?
if [ "$OPTION_PEERADMIN" = "true" ] ; then
	COMMANDS="su - peeradmin -c '$@'"
else
	COMMANDS="$@"
fi

#time pssh -P -i -p $SESSIONS -O ConnectTimeout=$TIMEOUT -h $LISTFILE "$COMMANDS"
pssh -i -p $SESSIONS -O ConnectTimeout=$TIMEOUT -h $LISTFILE "$COMMANDS"
