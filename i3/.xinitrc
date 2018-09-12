#!/bin/sh

[[ -f ~/.Xresources ]] && xrdb -merge ~/.Xresources
conky -d -c $HOME/.config/polybar/conky_wrapper
dunst -config $HOME/.config/dunst/dunstrc &
compton -b --config $HOME/.config/compton.conf 
$HOME/.bin/urxvt_daemon &
nitrogen --restore 2> /dev/null
clipit &

numlockx
setxkbmap -layout us,ru -option grp:shift_caps_switch,grp_led:caps,terminate:ctrl_alt_bksp

eval $(dbus-launch --sh-syntax)

exec i3
