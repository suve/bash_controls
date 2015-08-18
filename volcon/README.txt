volcon
========================================
Usage: volcon [-d device] [-c control] [-m] <inc|dec|set> <value>
       volcon [-d device] [-c control] [-m] <get|mute|unmute|toggle>
  -d  Specify the amixer device to use. Defaults to 'default'.
  -c  Specify the amixer control to use. Defaults to 'Master'.
  -m  Use the microphone control. Equivalent to -c 'Capture'.
  -n  Display a desktop notification with control status and volume.
      Requires 'notify-send' present on the system.
  -q  Do not print amixer output.

When called with the "get" parameter, volcon returns the current
audio volume. "mute" and "unmute" are self-explanatory. "toggle"
mutes the device if it's unmuted, and unmutes it if it's mute.

When called with the "set" parameter, volcon expects a parameter in
the <0 - 100> range. It will set the volume to given percentage.

The "inc" and "dec" parameters can be used to set the volume to
a relative value - to increase, or decrease it by given value from
the current level.

----------------------------------------

volcon uses amixer to perform its duty, so it will only work on
systems which use ALSA for audio handling.

By default, volcon operates on the default audio device, on the master
channel. The -d, -c and -m options can be used to operate on different
devices or channels. If you find that the default devices/controls do
not work for you, these can be easily changed by editing the variables
at the beginning of the script.

If you have notify-send present on the system (and a notification server
running), the -n option can be used to display a desktop notification
with the control status (audible/mute) and volume level.
