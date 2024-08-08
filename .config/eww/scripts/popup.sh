#!/bin/zsh
if [ -z $1 ]; then
    echo "Need to set input parameter to ensure toggle off is only called after x seconds"
    exit
fi

/usr/bin/eww open $1 --toggle
sleep 0.1
