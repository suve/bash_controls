#!/bin/bash

BATTDIR='/sys/class/power_supply/BATA/';


if [ -a "$BATTDIR" ]; then
	LEVEL="Battery level: `cat $BATTDIR/capacity`%"
	STATUS="Status: `cat $BATTDIR/status`"
else
	LEVEL="Battery level: Unknown"
	STATUS="Status: Not present"
fi


echo "$LEVEL"
echo "$STATUS" 
notify-send -t 3333 "$LEVEL" "$STATUS"

