#!/bin/sh

DEVICE='default'
CONTROL='Master'

USAGE1="Usage: volcon <inc|dec|set> <value>"
USAGE2="       volcon <get|mute|unmute|toggle>"

if [ "$#" -lt 1 ]; then
   echo "$USAGE1"
   echo "$USAGE2"
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
   echo "$USAGE1"
   echo "$USAGE2"
   exit
fi

amixer -D "$DEVICE" set "$CONTROL" "$2$SUFFIX"

