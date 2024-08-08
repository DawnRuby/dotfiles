#Initialize variables
ifCount=0
interfaces=$( ip link | awk -F: '$0 !~ "lo|vir|^[^0-9]"{print $2;}' )
json="[]"

for interface in $interfaces; do
   interface=$( echo $interface | xargs )
   interface=${interface%@*}
   ifIp=$(ip -f inet -o addr show $interface | cut -d' ' -f7 | cut -d'/' -f1 )
   isEth=true

   if ! [ -z $ifIp ]; then
	if [[ $interface == wlan* ]] || [[ $interface == wlp* ]]; then
	  isEth=false
	fi
	
	ifCount=$(($ifCount+1))

	if $isEth; then
	  ipI='󰈁'
	else
	  ipI='󰖩'
	fi

	jsonData=$(jq -c -n -M \
		      --arg ip $ifIp \
		      --arg ipI $ipI \
		  --arg isEth $isEth \
		  '$ARGS.named')
	json=$(echo $json | jq -c -M \
	        --argjson data "$jsonData" \
		'. += ['$jsonData']')
   fi
   
done

if [ -z "$ips// " ]; then
     echo ' - Disconnected'
elif (( $ifCount >= 1 )); then
    echo $json
else
    echo $ips
fi
