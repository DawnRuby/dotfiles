#!/bin/zsh
convertByteString() {
    local MiB=1024000
    local KiB=1024
    local fBytes=""
    if (( $1 > $MiB )); then
	fBytes=$(($1 / $MiB))
	printf -v j "%04d" $fBytes
	byteString="${j} Mbp/s"
    elif (( $1 > $KiB )); then
	fBytes=$(($1 / $KiB))
        printf -v j "%04d" $fBytes
	byteString="${j} Kbp/s"
    else
        printf -v j "%04d" $1
        byteString="${j} Bit/s"
    fi
    
    echo $byteString
}


if [ -z $1 ]; then
    echo "Please specify a refresh interval"
    exit
fi

if [ -z $2 ]; then
    echo "Please specify a redisplay interval"
    exit
fi

maxRxBytes=1
maxTxBytes=1

if [ ! -z $3 ]; then
    maxRxBytes=$3
fi

if [ ! -z $4 ]; then
    maxTxBytes=$4
fi

jsonData="[]"
prevtmpstr=""
lastOut=0
redisplayInterval=$(($2 * 1000))
refreshInterval=$(($1))
outJson=""

while [ true ]; do
    curEpoch=$(date +%s%N | cut -b1-13)
    rxBytes=0;
    txBytes=0;


    for file in /sys/class/net/*/statistics/rx_bytes;do
	if [[ $file == **docker** ]] || [[  $file == **lo** ]]; then
	   continue;
	fi

	fileVal=$(cat $file) 
	rxBytes=$(($rxBytes + $fileVal));
    done

    for file in /sys/class/net/*/statistics/tx_bytes;do
	if [[ $file == **docker** ]] || [[  $file == **lo** ]]; then
	    continue;
	fi

	fileVal=$(cat $file) 
	txBytes=$(($txBytes + $fileVal));
    done

    # We require a temp file to write our changes to to make sure we can have something to calculate our differential on
    historicalData=$(jq -c -n -M \
		  --arg epoch $curEpoch \
		  --arg rxBytes $rxBytes \
		  --arg txBytes $txBytes \
		  '$ARGS.named')

    jsonData=$(echo $jsonData | jq -c -M \
	        --argjson hisoricalData "$historicalData" \
		'. += ['$historicalData']')
    
    jsonDataLength=$(echo $jsonData | jq 'length')

    # Exit here if our previous file is empty.
    if ((jsonDataLength <= 1)); then
	sleep 0.01;
	continue
    fi

    # Capping json data to 10 items and waiting for it to populate completely.
    if ((jsonDataLength >= 10)); then
	jsonData=$(echo $jsonData | jq 'del(.[0])')
	jsonDataLength=$(($jsonDataLength - 1))
    else
	sleep 0.01;
	continue
    fi

    allTime=0
    startTime=0
    startRx=0
    startTx=0
    allRx=0
    allTx=0
    
    for i in {0..$(($jsonDataLength-1))}; do
	prevRx=$(echo $jsonData | jq '.['$i'].rxBytes')
	prevTx=$(echo $jsonData | jq '.['$i'].txBytes')
	prevEpoch=$(echo $jsonData | jq '.['$i'].epoch')

	# Doing this to determine the "earliest" data in our table, allowing us to set a starting point
	if [[ (( $prevEpoch < $startTime )) || (( $startTime == 0 )) ]]; then
	    startTime=$prevEpoch
	    startRx=$prevRx
	    startTx=$prevTx
	fi

	# We do this instead of actually using the highest time to average our data out and make it less fluctating due to small spikes
	allRx=$(($allRx + $prevRx))
	allTx=$(($allTx + $prevTx))
	allTime=$(($allTime + $prevEpoch))
    done

    timeAvg=$(($allTime / $jsonDataLength))
    rxAvg=$(($allRx / $jsonDataLength))
    txAvg=$(($allTx / $jsonDataLength))
    timeAvgDiff=$(($timeAvg - $startTime))


    rxAvgDiff=$(($rxAvg - $startRx))
    txAvgDiff=$(($txAvg - $startTx))
    rxBytesPerSec=$(((($rxAvgDiff / $timeAvgDiff) * 1000) * 8))
    txBytesPerSec=$(((($txAvgDiff / $timeAvgDiff) * 1000) * 8))
    
    rxString=$(convertByteString $rxBytesPerSec)
    txString=$(convertByteString $txBytesPerSec)

   

    lastOutDiff=$(($curEpoch - $lastOut))
    if (( $lastOutDiff > $redisplayInterval )); then
	lastOut=($curEpoch)
	txBytesPercent=$(bc <<< 'scale=2; '$txBytesPerSec'/'$maxTxBytes'')
	rxBytesPercent=$(bc <<< 'scale=2; '$rxBytesPerSec'/'$maxRxBytes'')      
	outJson=$(jq -c -n -M \
		  --arg tx $txString \
		  --arg txBytesPercent $txBytesPercent \
		  --arg rx $rxString \
		  --arg rxBytesPercent $rxBytesPercent \
		  '$ARGS.named')
	echo $outJson
    fi
    
    sleep $refreshInterval
done
