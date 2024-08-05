#!/bin/bash

function slice_loop () { # grab a slice of a string, and if you go past the end loop back around
    local str="$1"
    local start=$2
    local how_many=$3
    local len=${#str};

    local result="";

    for ((i=0; i < how_many; i++))
    do
        local index=$(((start+i) % len)) ## Grab the index of the needed char (wrapping around if need be)
        local char="${str:index:1}" ## Select the character at that index
        local result="$result$char" ## Append to result
    done
    
    echo -n $result
}

strleng=($1)

#This controlls the tick of the application. Changing the division down here will make the music moving faster, changing it up will make it slower
curtseconds=$(($(date +%s%1N)/10))

# Check if MPD is running
if ! pgrep -x "mpd" > /dev/null; then
    echo ""
fi

if pgrep -x "mpd" > /dev/null; then
    msg=""
    music_status=$(timeout 5 mpc | sed -n '2 p')
    artist=$(mpc -f "%artist%" | sed -n '1 p')
    title=$(mpc -f "%title%" | sed -n '1 p')
    album=$(mpc -f "%album%" | sed -n '1 p')
    curtime=$(mpc status | awk 'NR==2 { split($3, a, "/"); print a[1]}')
    songlength=$(mpc status | awk 'NR==2 { split($3, a, "/"); print a[2]}')
    if [[ $curtime == *0:* ]]; then
	curtime=""${curtime:(-2)}"s"
    fi

    if [[ $music_status == *"[playing]"* ]]; then
       msg=" "$curtime"/"$songlength" - "$artist" - ["$album"] - "$title" "
    elif [[ $music_status == *"[paused]"* ]]; then
       echo "  "$curtime"/"$songlength" - "$artist" - "$title""
       return;
    fi

    slice=$(slice_loop "$msg" "$curtseconds" $strleng);
    echo $slice;
fi
