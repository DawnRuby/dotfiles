#!/bin/zsh

sign() {
	USAGE="Usage: $0 <text> <delay> [loop]
	
	Arguments:
	 <text>              The text to scroll.
	 <delay>             Delay in seconds (positive number).
	 [loop]              Loop the scrolling: true | false (default: true).
	
	Examples:
	 $0 \"LINUX\" 0.5
	 $0 \"LINUX\" 0.5 false
	"
	
	function usage() {
	 echo "$USAGE"
	}
	
	# Check number of arguments
	if [ $# -lt 2 ] || [ $# -gt 3 ]; then
	 usage
	 exit 1
	fi
	
	text=$1
	delay=$2
	loop=${3:-true}
	
	# Validate delay
	if ! [[ "$delay" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
	 echo "Error: Invalid argument for delay."
	 usage
	 exit 1
	fi
	
	# Validate loop
	if [ "$loop" != "true" ] && [ "$loop" != "false" ]; then
	 echo "Error: Invalid argument for loop: must be 'true' or 'false'."
	 exit 1
	fi
	
	# Function to scroll text
	scroll_text() {
	 local text=$1
	 local delay=$2
	 local loop=$3
	 local spaced_text="${text} ${text}"
	 local len=${#text}
	
	 while true; do
	   for ((i = 0; i < len; ++i)); do
	     echo -ne "\r${spaced_text:i:len} " 
	     sleep "$delay"
	   done
	   [[ "$loop" == "false" ]] && break
	 done
	}
	
	scroll_text "$text" "$delay" "$loop"
}

while true; do

    # Check if Spotify is running
    while ! pgrep -x "mpd"; do
        sleep 2
    done

    while pgrep -x "mpd" > /dev/null; do
        # Get the status and metadata of the current song
        music_status=$(timeout 5 mpc | sed -n '2 p')
        artist=$(mpc -f "%artist%" | sed -n '1 p')
        title=$(mpc -f "%title%" | sed -n '1 p')
        album=$(mpc -f "%album%" | sed -n '1 p')
	
	if [[ $music_status == *"[playing]"* ]]; then
	    echo "{\"class\":\"Playing\",\"text\":\"$artist - $title\",\"tooltip\": \"$artist - $title - $album\"}"
	elif [[ $music_status == *"[paused]"* ]]; then
	    echo "{\"class\":\"Paused\",\"text\":\"$artist - $title\",\"tooltip\": \"$artist - $title - $album\"}"
	else
	    echo ""
	fi

	
        sleep 1
    done

    # Wait until Spotify is closed
    while pgrep -x "mpd" > /dev/null; do
        sleep 2
    done

done
