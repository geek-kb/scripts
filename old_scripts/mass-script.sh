#!/bin/bash

function usage {
	echo "Usage: $(basename $0) [optional:OPTIONS] [LIST(s)] -s [SCRIPT]"
	echo ""
	echo "Arguments:"
	echo "   -s [FILE] :     Script file to copy/execute"
	echo ""
	echo "Options:"
	echo "   -clean    :     Do not print hostname at all"
	echo "   -color    :     Don't print hostname with color"
	echo "                   (useless if -clean is provided)"
	echo "   -peer     :     Run commands as user peeradmin"
}

MASSEXEC=/root/mass_scripts/massexec.sh

if [ ! -f "$MASSEXEC" ] ; then
	echo "ERROR: $MASSEXEC is missing"
	exit 1
fi

if [ -z "$3" ] ; then
	usage
	exit 1
fi

ARGUMENTS=()
for a in "$@" ; do
	if [[ $a == -* ]] ; then
		case $(tr -d "-" <<< "$a") in
			"clean") ARGUMENTS+=("$a");;
			"color") ARGUMENTS+=("$a");;
			"peer") ARGUMENTS+=("$a");;
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
		LIST+=("$f")
		shift
	else	
		break
	fi
done

if [ ${#LIST[@]} -eq 0 ] ; then
	echo "ERROR: No lists provided or lists are empty"
	echo "passed argument: $@"
	exit 1
fi

SCRIPT=""
if [ "$1" = "-s" ] ; then
	shift
	if [ -f "$1" ] ; then
		SCRIPT="$1"
	else
		echo "ERROR: script not found $1"
		exit 1
	fi
else
	echo "ERROR: no script provided"
	exit 1
fi

SCRIPT_FILENAME=$(basename $SCRIPT)
COMMAND="[ -x "/tmp/$SCRIPT_FILENAME" ] && /tmp/$SCRIPT_FILENAME"

for l in ${LIST[@]} ; do
	for s in $(cat $l) ; do
		echo -n "Copying to $s: "
		echo "$(rsync -P --chmod=u+rx,g+rx,o+rwx $SCRIPT $s:/tmp/$SCRIPT_FILENAME | grep sent)"
	done
done

if [ $? -eq 0 ] ; then
	$MASSEXEC ${ARGUMENTS[@]} ${LIST[@]} $COMMAND
fi

exit 0