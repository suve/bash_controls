#!/bin/sh

DEVICE='default'
CONTROL='Master'
MICROPHONE='Capture'

USAGE=$(cat <<EOT
Usage: volcon [-d device] [-c control] [-m] <inc|dec|set> <value>
       volcon [-d device] [-c control] [-m] <get|mute|unmute|toggle>
  -d  Specify the amixer device to use. Defaults to '$DEVICE'.
  -c  Specify the amixer control to use. Defaults to '$CONTROL'.
  -m  Use the microphone control. Equivalent to -c '$MICROPHONE'.
EOT
);

# Use getopts to check for -options
while getopts 'd:c:m' OPTNAME; do
   if [ "$OPTNAME" == 'd' ]; then
      DEVICE="OPTARG"
   elif [ "$OPTNAME" == 'c' ]; then
      CONTROL="$OPTARG"
   elif [ "$OPTNAME" == 'm' ]; then
      CONTROL="$MICROPHONE"
   fi
done
# Shift -options and start the script proper
shift $((OPTIND-1))

if [ "$#" -lt 1 ]; then
   echo "$USAGE"
   exit
fi

if [ "$1" == 'get' ]; then
   amixer -D "$DEVICE" get "$CONTROL"
   exit
fi

if [ "$1" == 'mute' ] || [ "$1" == 'unmute' ] || [ "$1" == 'toggle' ]; then
   amixer -D "$DEVICE" set "$CONTROL" "$1"
   exit
fi

if [ "$1" == 'inc' ]; then
   SUFFIX='%+'
else
   if [ "$1" == 'dec' ]; then
      SUFFIX='%-'
   else
      if [ "$1" == 'set' ]; then
         SUFFIX='%'
      fi
   fi
fi

if [ "$SUFFIX" == '' ] || [ "$#" -lt 2 ]; then
   echo "$USAGE"
   exit
fi

amixer -D "$DEVICE" set "$CONTROL" "$2$SUFFIX"

