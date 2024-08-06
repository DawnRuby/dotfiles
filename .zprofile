#!/bin/zsh
export PATH="$PATH:/home/dawn/.local/bin"
mpd & > /dev/null 2&1
gentoo-pipewire-launcher & > /dev/null 2&1
syncthing & > /dev/null 2&1
nextcloud & > /dev/null 2&1
nm-cli & > /dev/null 2&1

#Launch these commands on login
dbus-launch --exit-with-session Hyprland
