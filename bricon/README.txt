bricon
========================================
Usage: bricon get
       bricon <inc|dec|set> <value>

When called with the "get" parameter, bricon returns the current
backlight brightness. Two values are returned: one is the level,
while the other is the raw brightness value.

When called with the "set" parameter, bricon expects a parameter in
the <0 - 10> range. It will set the backlight brightness to given level.

The "inc" and "dec" parameters can be used to set the brightness to
a relative value - to increase, or decrease it by given value from
the current level.

----------------------------------------

In order to use bricon on your machine, you must first modify the script. 
The LIGHTDIR variable at the top of the script points to the directory
where the backlight control files reside. You should change it to match
the paths found on your system.

An important thing to note is that, since everything inside /sys is
governed by the kernel, on almost every system, regular users will have
no write access to the brightness controls - and thus, the script won't work.

If you're using a distribution using systemd, you can use the attached
bricon.service to make the system change the file group to "brigrp" and set
write access for group members to it. You will need to modify the paths
in the service to point at your device, and also to create the "brigrp" group
and add users to it.

To actually make the system use the service during startup, you have to
either place the service file itself, or a symlink to it, inside
`/etc/systemd/system/multi-user.target.wants/`.
