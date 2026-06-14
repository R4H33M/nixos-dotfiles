#!/bin/sh
nm-applet &
blueman-applet &
flameshot &
fcitx5 &
ente-desktop --hidden --password-store=gnome-libsecret &
setxkbmap -option
setxkbmap usno -option caps:numlock,lv3:ralt_switch
