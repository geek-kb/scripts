#!/bin/bash
# This script checks how many failed NZFiles exist in /storage/nzfiles .
# Edit the variables to change thresholds.
# Script by Itai Ganot
OKVAL="3"
WARNVAL="4"
CRITVAL="20"
LOCATION="/storage/nzfiles"
NUMFAILED=$(find $LOCATION -name \*failed\* |wc -l)
TEXT="There are currently $NUMFAILED failed files in $LOCATION"
if [ "$NUMFAILED" -le "$OKVAL" ]; then
STATUS="OK:"
EXITCODE="0"
elif [ "$NUMFAILED" -ge "$WARNVAL" ] && [ "$NUMFAILED" -lt "$CRITVAL" ]; then
STATUS="WARNING:"
EXITCODE="1"
elif [ "$NUMFAILED" -ge "$CRITVAL" ]; then
STATUS="CRITICAL:"
EXITCODE="2"
fi
echo "$STATUS $TEXT -- OK Value: $OKVAL Warn Value: $WARNVAL Crit Value: $CRITVAL | FailedNum=$NUMFAILED;$WARNVAL;$CRITVAL;0;"
exit "$EXITCODE" 
