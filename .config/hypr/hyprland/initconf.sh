#!/bin/zsh
killall xdg-desktop-portal-hyprland
killall xdg-desktop-portal-gnome
killall xdg-desktop-portal-wlr
killall xdg-desktop-portal
logger 'Killed all XDG-Desktops'
sleep 2
/usr/libexec/xdg-desktop-portal-wlr &
logger 'xdg-desktop-portal-wlr started'
/usr/libexec/xdg-desktop-portal &
logger 'xdg-desktop-portal started'
