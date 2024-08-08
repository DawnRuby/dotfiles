#!/bin/zsh

maxLen=35;

if [ ! -z $1 ]; then
    maxLen=$1;
fi

if [ -z $(hyprctl activewindow -j | jq '.title') ]; then
    echo ""
else
    winTitle=$(hyprctl activewindow -j | jq '.title');
    titleLen=$(expr length $winTitle)
    if (($titleLen > $maxLen)); then
	winTitle=$(echo -n $winTitle | head -c $maxLen)
	winTitle="${winTitle}..."
    fi
    echo $winTitle
fi
