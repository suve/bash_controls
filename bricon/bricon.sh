#!/bin/sh

LIGHTDIR='/sys/class/backlight/panasonic/'


USAGE1="Usage: bricon get" 
USAGE1="       bricon <inc|dec|set> <value>"

if [ "$#" -lt 1 ]; then
   echo "$USAGE1"
   echo "$USAGE2"
   exit
fi

BRIVAL=`cat "$LIGHTDIR/brightness"`

BRIMAX=`cat "$LIGHTDIR/max_brightness"`
BRIMOD=`expr $BRIMAX % 10`
BRIDIV=`expr $BRIMAX / 10`

BRILEV=`expr $BRIVAL / $BRIDIV`

if [ "$1" == 'get' ]; then
   echo "Level: $BRILEV; Value: $BRIVAL"
   exit
fi

if [ "$#" -lt 2 ]; then
   echo "$USAGE1"
   echo "$USAGE2"
   exit
fi

if [ "$1" == 'set' ]; then
   BRILEV="$2"
else
   if [ "$1" == 'inc' ]; then
      BRILEV=`expr $BRILEV \+ "$2"`
   else
      if [ "$1" == 'dec' ]; then
         BRILEV=`expr $BRILEV - "$2"`
      else
         echo "$USAGE1"
         echo "$USAGE2"
         exit
      fi
   fi
fi

if [ "$BRILEV" -lt 0 ]; then
   BRILEV='0'
else
   if [ "$BRILEV" -gt 10 ]; then
      BRILEV='10'
   fi
fi

if [ -w "$LIGHTDIR/brightness" ]; then
   BRIVAL=`expr \( $BRILEV \* $BRIDIV \) \+ $BRIMOD`
   
   echo "Level: $BRILEV; Value: $BRIVAL"
   echo "$BRIVAL" > "$LIGHTDIR/brightness"
else
   echo "Access to $LIGHTDIR/brightness denied!"
fi
