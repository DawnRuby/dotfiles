#!/bin/zsh
trap "killall waybar" EXIT

while true; do
    waybar &
    inotifywait -e create,modify $HOME/.config/waybar/config.jsonc $HOME/.config/waybar/style.css $HOME/.config/waybar/color.css
    killall waybar
done
