#!/bin/bash

USAGE=$(cat <<EOT
Usage: howmanyinternets [-0|-r|-t|-s|-f FORMAT] [-h] DEVICE
  DEVICE must name a network device present on the system.
  
  -0  Zero the statistics.
  -r  Print total number of received bytes.
  -t  Print total number of transferred (sent) bytes.
  -s  Print the sum of sent and received bytes (default).
  
  -f  Print a custom string. Inside the format string,
      %r, %t, %s sequences can be used to print relevant info.
      Use %% to display a literal percent sign.
  
  -h  Use a human-readable format. 
EOT
);

if [ "$#" -lt 1 ] || [ "$1" == "--help" ]; then
   echo "$USAGE"
   exit
fi


ZERO='0'
FORMAT='%s'
DEVICE=''
HUMAN_READABLE=0

while [ "$#" -gt 0 ]; do
	case "$1" in
		-0 )
			ZERO='1'
		;;
		
		-r )
			ZERO='0'
			FORMAT='%r'
		;;
		
		-t )
			ZERO='0'
			FORMAT='%t'
		;;
		
		-s )
			ZERO='0'
			FORMAT='%s'
		;;
		
		-f )
			if [[ "$#" -eq 1 ]]; then
				echo "howmanyinternets: the -f switch must be followed by a format string"
				echo "$USAGE"
				exit
			else
				FORMAT=$2
				shift
			fi
		;;
		
		-h )
			HUMAN_READABLE=1
		;;
		
		* )
			DEVICE=$1
	esac
	
	shift
done

if [ "$DEVICE" == "" ]; then
	echo -e "howmanyinternets: No DEVICE provided\n"
	echo "$USAGE"
	exit
fi

if [ ! -d "/sys/class/net/$DEVICE" ]; then
	echo "howmanyinternets: The device '$DEVICE' does not seem to exist"
	exit
fi


mkdir -p "$HOME/.local/share/suve/howmanyinternets/"
if [[ "$?" -ne 0 ]]; then
	echo "howmanyinternets: failed to create data directory"
	exit
fi


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
		RESULT=$1
		return
	fi
	
	local SCALE=0
	local SCALE_ARR=('B' 'KiB' 'MiB' 'GiB' 'TiB' 'PiB' 'EiB')
	
	local ORIGINAL=$1
	local CURRENT=$1
	while [ "$CURRENT" -ge 1024 ]; do
		SCALE=`expr $SCALE + 1`
		CURRENT=`expr $CURRENT / 1024`
	done
	
	if [ "$SCALE" -eq 0 ]; then
		RESULT="${ORIGINAL}${SCALE_ARR[0]}"
	else
		local NUMBER=`echo 'scale=2; '"$ORIGINAL"' / 1024^'"$SCALE" | bc`
		RESULT="${NUMBER}${SCALE_ARR[$SCALE]}"
	fi
}


# Format data
format_data $IN_BYTES_TOTAL $HUMAN_READABLE
FMT_IN=$RESULT

format_data $OUT_BYTES_TOTAL $HUMAN_READABLE
FMT_OUT=$RESULT

format_data `expr $IN_BYTES_TOTAL + $OUT_BYTES_TOTAL` $HUMAN_READABLE
FMT_SUM=$RESULT


# Print what the user wanted
echo "$FORMAT" | sed -e "s/%r/$FMT_IN/g" -e "s/%t/$FMT_OUT/g" -e "s/%s/$FMT_SUM/g" -e "s/%%/%/g"
