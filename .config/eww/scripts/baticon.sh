#!/bin/zsh
bat_dir="/sys/class/power_supply/BAT0/capacity"

if [ ! -f "$bat_dir" ]; then
    echo "󰂃"
    exit 0;
fi

battery_percent=$(cat $bat_dir)
battery_status=$(cat "/sys/class/power_supply/BAT0/status")

if [[ $battery_status == "Charging" ]]; then
    if [[ $battery_percent > 90 ]]; then
        echo "󰂅"
    elif [[ $battery_percent > 80 ]]; then
        echo "󰂋"
    elif [[ $battery_percent > 70 ]]; then
        echo "󰂊"
    elif [[ $battery_percent > 60 ]]; then
        echo "󰢞"
    elif [[ $battery_percent > 50 ]]; then
        echo "󰂉"
    elif [[ $battery_percent > 40 ]]; then
        echo "󰢝"
    elif [[ $battery_percent > 30 ]]; then
        echo "󰂈"
    elif [[ $battery_percent > 20 ]]; then
        echo "󰂆"
    elif [[ $battery_percent > 10 ]]; then
        echo "󰢜"
    else
        echo "󰢟"
    fi
    exit
fi

if [[ $battery_percent > 90 ]]; then
    echo "󰁹"
elif [[ $battery_percent > 80 ]]; then
    echo "󰂂"
elif [[ $battery_percent > 70 ]]; then
    echo "󰂁"
elif [[ $battery_percent > 60 ]]; then
    echo "󰂀"elif [[ $battery_percent > 50 ]]; then
    echo "󰁿"
elif [[ $battery_percent > 40 ]]; then
    echo "󰁾"
elif [[ $battery_percent > 30 ]]; then
    echo "󰁽"
elif [[ $battery_percent > 20 ]]; then
    echo "󰁼"
elif [[ $battery_percent > 10 ]]; then
    echo "󰁻"
else
    echo "󰂎"
fi
