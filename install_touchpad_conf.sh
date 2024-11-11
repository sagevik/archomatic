#! /bin/sh

# Script must be run with sudo

echo 'Section "InputClass"
    Identifier "libinput touchpad catchall"
    MatchIsTouchpad "on"
    MatchDevicePath "/dev/input/event*"
    Driver "libinput"
    Option "Tapping" "on"
EndSection' > /etc/X11/xorg.conf.d/40-libinput.conf
