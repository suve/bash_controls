batmon
========================================
batmon is a small script which prints out how much power remains
in your notebook's battery, along with state information (full,
charging, discharging).

To find out the battery power level (*cough cough* over 9000!)
and its status, the script accesses `/sys/class/power_supply`.

If the script doesn't work for you (or always prits that your
battery is not present), you should call:
$ ls -lhp /sys/class/power_supply/
and check what name the battery registers itself under.
On my system, it's "BATA" - may be different on yours.
You should then modify the BATTDIR declaration in the script.

The script makes use of the system's notification system to
display a small popup containing the battery information.
To see the popup, you will need to have installed:
  
  1. `libnotify`
     The notification handling library.
  
  2. A notification server
     GNOME and KDE ship with a notification server installed
     by default. On other desktop environments, you may need to
     install one yourself. Possible candidates may be
     `mate-notification-server` or `xfce4-notifyd`.
