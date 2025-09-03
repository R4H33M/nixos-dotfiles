#!/bin/sh
setxkbmap -option ctrl:nocaps
nm-applet &
blueman-applet &
flameshot &
fcitx5 &
setxkbmap -option
setxkbmap -option caps:numlock
