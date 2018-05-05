#!/bin/bash

# Change delimiter in string-to-array conversion
OLD_IFS=$IFS
IFS="
"

# Read possible outputs and filter out disconnected ones
DISPLAYS=`xrandr | grep ' connected'`
DISPLAY_ARR=($DISPLAYS)

# Restore old IFS, just to be sure
IFS=$OLD_IFS


CONFNUM=0
POWER=1
# Go through all displays. If a display is active, increase $CONFNUM by power(2, index).
for ((i=0; i<${#DISPLAY_ARR[@]}; ++i)); do
	DISPLAY_CURRENT=(${DISPLAY_ARR[i]})

	# Displays are reported as "NAME connected [primary] RESOLUTION (properties)".
	# Inactive displays lack the resolution. 
	# If the first char of the third/fourth field is "(", display is off.
	if [ "${DISPLAY_CURRENT[2]}" != "primary" ]; then
		DISPLAY_CHK=${DISPLAY_CURRENT[2]}
	else
		DISPLAY_CHK=${DISPLAY_CURRENT[3]}
	fi
	
	DISPLAY_CHK=${DISPLAY_CHK:0:1}
	if [ "$DISPLAY_CHK" != "(" ]; then
		CONFNUM=`expr $CONFNUM + $POWER`
	fi
	
	POWER=`expr $POWER '*' 2`
done


# Select next possible configuration, omitting option 0.
CONFNUM=`expr '(' $CONFNUM + 1 ')' '%' $POWER`
if [ "$CONFNUM" -eq 0 ]; then
	CONFNUM=1
fi


ARGS=""
# Go through all displays and concatenate the args string.
for ((i=0; i<${#DISPLAY_ARR[@]}; ++i)); do
	
	# Get display name
	DISP_NAME=`echo "${DISPLAY_ARR[$i]}" | cut -f1 -d' '`
	
	# Calculate the appropriate CONFNUM bit to determine if display
	# should be turned on or off.
	DISP_ON=`expr $CONFNUM '%' 2`
	if [ "$DISP_ON" -ne 0 ]; then
		DISP_ACTION="--auto"
	else
		DISP_ACTION="--off"
	fi
	
	ARGS="$ARGS --output $DISP_NAME $DISP_ACTION"
	
	# Cut off used bits.
	CONFNUM=`expr $CONFNUM / 2`
done

xrandr $ARGS
