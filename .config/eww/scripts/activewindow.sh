#!/bin/zsh
if [ -z $(hyprctl activewindow -j | jq '.title') ]; then
    echo ""
else
    echo $(hyprctl activewindow -j | jq '.title');
fi
