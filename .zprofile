#!/bin/zsh
# Created by `pipx` on 2024-07-17 02:45:58                                                                                                                                                                                                                                                           
export PATH="$PATH:/home/dawn/.local/bin"
syncthing &
nextcloud &
nm-cli &

#Launch these commands on login
dbus-launch --exit-with-session Hyprland
