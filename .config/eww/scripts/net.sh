#!/bin/zsh
tempdir="/tmp/eww/netload"

#Create directory for netload application
mkdir -p $tempdir

#Get our current tick in ms
curepoch=$(date +%s%N | cut -b1-13) 

#Our previous temp file
prevtemp=$(ls -t $tempdir | head -n1)
echo rm -v !($prevtemp) $tempdir

prevtmpstr=(cat $prevtemp)
parts=(${(@s:;:)prevtmpstr})
echo $parts

#We assume this is polled every single second. If it isn't we may have an issue with calculating the actual byte differential.
tmpfile=$(mktemp --directory ""$tempdir"/tmp.XXXXXXXXXXXXX")


#This controlls the tick of the application. Remove at your own peril :)
rx_bytes=0;
tx_bytes=0;

for file in /sys/class/net/*/statistics/rx_bytes;do
    fileval=$(cat $file) 
    rx_bytes=$(($rx_bytes + $fileval));
done

for file in /sys/class/net/*/statistics/tx_bytes;do
    fileval=$(cat $file) 
    tx_bytes=$(($tx_bytes + $fileval));
done


#Remove the amount caused by loopback
rx_lodiff=$(cat "/sys/class/net/lo/statistics/rx_bytes")
tx_lodiff=$(cat "/sys/class/net/lo/statistics/tx_bytes")

rx_bytes=$(($rx_bytes - $rx_lodiff))
tx_bytes=$(($tx_bytes - $tx_lodiff))

echo "epochtime="$curepoch";rx_bytes="$rx_bytes";tx_bytes="$tx_bytes";" > tmpfile;
