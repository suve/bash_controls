#!/bin/sh

DEVICE='default'
CONTROL='Master'
MICROPHONE='Capture'

USAGE=$(cat <<EOT
Usage: volcon [-d device] [-c control] [-mnq] <inc|dec|set> <value>
       volcon [-d device] [-c control] [-mnq] <get|mute|unmute|toggle>
  -d  Specify the amixer device to use. Defaults to '$DEVICE'.
  -c  Specify the amixer control to use. Defaults to '$CONTROL'.
  -m  Use the microphone control. Equivalent to -c '$MICROPHONE'.
  -n  Display a desktop notification with control status and volume.
      Requires 'notify-send' present on the system.
  -q  Do not print amixer output.
EOT
);

function volcon() {
   OUTPUT=`amixer $@`
   
   if [ "$QUIET" == '' ]; then
      echo "$OUTPUT"
   fi
   
   if [ "$NOTIFY" != '' ]; then
      LEVELS=`echo "$OUTPUT" | grep -o -e '\[[[:digit:]]*%\]'`
      NUM=`echo "$LEVELS" | wc -l`
      SUM=`echo "$LEVELS 0" | tr '[%]\n' '  + ' | xargs expr`
      AVG=`expr $SUM / $NUM`
      
      if [ `echo "$OUTPUT" | grep -c -e '\[on\]'` -gt 0 ]; then
         STATUS="$AVG%"
      else
         STATUS="$AVG%  [MUTE]"
      fi
      
      notify-send -a 'volcon' -t 1500 "$CONTROL: $STATUS"
   fi
}

# Use getopts to check for -options
while getopts 'd:c:mnq' OPTNAME; do
   if [ "$OPTNAME" == 'd' ]; then
      DEVICE="OPTARG"
   elif [ "$OPTNAME" == 'c' ]; then
      CONTROL="$OPTARG"
   elif [ "$OPTNAME" == 'm' ]; then
      CONTROL="$MICROPHONE"
   elif [ "$OPTNAME" == 'n' ]; then
      NOTIFY=1
   elif [ "$OPTNAME" == 'q' ]; then
      QUIET=1
   fi
done
# Shift -options and start the script proper
shift $((OPTIND-1))

if [ "$#" -lt 1 ]; then
   echo "$USAGE"
   exit
fi

if [ "$1" == 'get' ]; then
   volcon -D "$DEVICE" get "$CONTROL"
   exit
fi

if [ "$1" == 'mute' ] || [ "$1" == 'unmute' ] || [ "$1" == 'toggle' ]; then
   volcon -D "$DEVICE" set "$CONTROL" "$1"
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

volcon -D "$DEVICE" set "$CONTROL" "$2$SUFFIX"

