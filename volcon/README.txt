volcon
========================================
Usage: volcon <get|mute|unmute|toggle>
       bricon <inc|dec|set> <value>

When called with the "get" parameter, volcon returns the current
audio volume. "mute" and "unmute" are self-explanatory. "toggle"
mutes the device if it's unmuted, and unmutes it if it's mute.

When called with the "set" parameter, volcon expects a parameter in
the <0 - 100> range. It will set the volume to given percentage.

The "inc" and "dec" parameters can be used to set the volume to
a relative value - to increase, or decrease it by given value from
the current level.

----------------------------------------

volcon uses amixer to perform it's duty, to it will only work on
systems which use ALSA for audio handling.

volcon always operates on the default audio device, on the master
channel. Although this can be changed via editing the variables
at the beginning of the script, there is currently no support
for specifying the device/channel via arguments.
