howmanyinternets
========================================
Usage: howmanyinternets [-0|-r|-t|-s] [-h] DEVICE
  DEVICE must name a network device present on the system.
  
  -0  Zero the statistics.
  -r  Print total number of received bytes.
  -t  Print total number of transferred (sent) bytes.
  -s  Print the sum of sent and received bytes (default).
  
  -h  Use a human-readable format.

----------------------------------------

howmanyinternets uses the /sys pseudo-FS (precisely: the `/sys/class/net/`
interface) to perform its duty. By taking a look at the statistics/rx_bytes 
and statistics/tx_bytes files, it reads how many bytes were used by the device
during the current OS boot. 

When run for the first time, howmanyinternets will create itself a directory
to store its data files (~/.local/share/suve/howmanyinternets). Inside this
directory, each device will receive its own $DEVICENAME.txt file. These files
store the total number of bytes used, and the usage for current OS boot.

On each run, howmanyinternets takes a look at the /sys statistics and its
stored data. If the current-boot usage reported by /sys is lower than the
stored one, an OS reboot is assumed - and the amounts reported by /sys are
added to the total. Otherwise, only the additional amount since last run
is added to the total. This means that, in order to report accurate numbers,
howmanyinternets should be run at least twice during each system boot:
once at the very beginning, and the second time just before shutdown.

To sum up: either run the script at each system start and shutdown, or
add it to cron, conky, or something else that will run it periodically.
When your data cap resets, run the script with -0 switch to reset the stats.

----------------------------------------

Note that, currently, howmanyinternets allows only to track network devices 
as a whole and does not differentiate between e.g. different Wi-Fi SSIDs.
As such, it will mostly be of usage to:
  a) people using a WWAN modem
  b) NEETs who permanently locked themselves in the basement
  c) data nerds who just like to keep stats of everything
