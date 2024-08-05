#!/bin/zsh
/usr/bin/gentoo-pipewire-launcher &
logger 'Started pipewire'
sleep 5
killall xdg-desktop-portal-hyprland
killall xdg-desktop-portal-gnome
killall xdg-desktop-portal-wlr
killall xdg-desktop-portal
logger 'Killed all XDG-Desktops'
sleep 2
/usr/libexec/xdg-desktop-portal-wlr &
logger 'xdg-desktop-portal-wlr started'
sleep 2
/usr/libexec/xdg-desktop-portal &
logger 'xdg-desktop-portal started'
sleep 2
/usr/bin/hyprpaper &
logger 'hyprpaper started'
sleep 2
/usr/bin/swww-daemon &
logger 'started swww'
sleep 2
/usr/bin/mpd &
logger 'mpd started'
sleep 2
zsh /.config/hypr/hyprland/initconf.sh &
logger 'waybar launched'
