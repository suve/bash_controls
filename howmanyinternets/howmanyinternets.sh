#!/bin/bash

USAGE=$(cat <<EOT
Usage: howmanyinternets [-0|-r|-t|-s] [-h] DEVICE
  DEVICE must name a network device present on the system.
  
  -0  Zero the statistics.
  -r  Print total number of received bytes.
  -t  Print total number of transferred (sent) bytes.
  -s  Print the sum of sent and received bytes (default).
  
  -h  Use a human-readable format.
EOT
);

if [ "$#" -lt 1 ] || [ "$1" == "--help" ]; then
   echo "$USAGE"
   exit
fi


MODE='-s'
DEVICE=''
HUMAN_READABLE=0

while [ "$#" -gt 0 ]; do
	if [ "$1" == "-r" ] || [ "$1" == "-t" ] || [ "$1" == "-s" ] || [ "$1" == "-0" ]; then
		MODE=$1
	else
		if [ "$1" == "-h" ]; then
			HUMAN_READABLE=1
		else
			DEVICE=$1
		fi
	fi
	
	shift
done

if [ "$DEVICE" == "" ]; then
	echo "$USAGE"
	exit
fi
if [ "$MODE" != "-r" ] && [ "$MODE" != "-t" ] && [ "$MODE" != "-s" ] && [ "$MODE" != "-0" ]; then
	echo "$USAGE"
	exit
fi

if [ ! -d "/sys/class/net/$DEVICE" ]; then
	echo "The device '$DEVICE' does not seem to exist"
	exit
fi


mkdir -p "$HOME/.local/share/suve/howmanyinternets/" || exit

FILENAME="$HOME/.local/share/suve/howmanyinternets/$DEVICE.txt"
if [ -a "$FILENAME" ] && [ "$MODE" != "-0" ]; then
	. "$FILENAME"
else
	IN_BYTES=0
	OUT_BYTES=0
	IN_BYTES_TOTAL=0
	OUT_BYTES_TOTAL=0
fi


IN_BYTES_PREVIOUS=$IN_BYTES
OUT_BYTES_PREVIOUS=$OUT_BYTES

IN_BYTES=`cat /sys/class/net/$DEVICE/statistics/rx_bytes`
OUT_BYTES=`cat /sys/class/net/$DEVICE/statistics/tx_bytes`

# If old byte counts are larger than current ones, assume the system was rebooted and the counters were reset.
if [ "$IN_BYTES_PREVIOUS" -gt "$IN_BYTES" ] || [ "$OUT_BYTES_PREVIOUS" -gt "$OUT_BYTES" ]; then
	IN_BYTES_PREVIOUS=0
	OUT_BYTES_PREVIOUS=0
fi

IN_BYTES_TOTAL=`expr $IN_BYTES_TOTAL + $IN_BYTES - $IN_BYTES_PREVIOUS`
OUT_BYTES_TOTAL=`expr $OUT_BYTES_TOTAL + $OUT_BYTES - $OUT_BYTES_PREVIOUS`


# Save stats
touch "$FILENAME"
echo '# howmanyinternets.sh' > "$FILENAME"
echo "IN_BYTES=$IN_BYTES" >> "$FILENAME"
echo "OUT_BYTES=$OUT_BYTES" >> "$FILENAME"
echo "IN_BYTES_TOTAL=$IN_BYTES_TOTAL" >> "$FILENAME"
echo "OUT_BYTES_TOTAL=$OUT_BYTES_TOTAL" >> "$FILENAME"


function format_data() {
	if [ "$2" -eq 0 ]; then
		echo "$1"
		return
	fi
	
	SCALE=0
	SCALE_ARR=('B' 'KiB' 'MiB' 'GiB' 'TiB' 'PiB' 'EiB')
	
	ORIGINAL=$1
	CURRENT=$1
	while [ "$CURRENT" -ge 1024 ]; do
		SCALE=`expr $SCALE + 1`
		CURRENT=`expr $CURRENT / 1024`
	done
	
	if [ "$SCALE" -eq 0 ]; then
		echo "${ORIGINAL}${SCALE_ARR[0]}"
	else
		NUMBER=`echo 'scale=2; '"$ORIGINAL"' / 1024^'"$SCALE" | bc`
		echo "${NUMBER}${SCALE_ARR[$SCALE]}"
	fi
}


# Print what the user wanted
if [ "$MODE" == "-r" ]; then
	format_data $IN_BYTES_TOTAL $HUMAN_READABLE
else
	if [ "$MODE" == "-t" ]; then
		format_data $OUT_BYTES_TOTAL $HUMAN_READABLE
	else
		if [ "$MODE" == "-s" ]; then
			format_data `expr $IN_BYTES_TOTAL + $OUT_BYTES_TOTAL` $HUMAN_READABLE
		fi
	fi
fi
