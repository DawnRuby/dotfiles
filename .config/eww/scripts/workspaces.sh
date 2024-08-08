#!/bin/zsh

prevJson="";

while [ true ];
do
    workspacesJson=$(hyprctl workspaces -j)
    activeWorkspacesJson=$(hyprctl activeworkspace -j)
    activeWorkspaceId=$(echo $activeWorkspacesJson | jq '.id')
    workspaceCount=$(echo $workspacesJson | jq 'length')
    monitorCount=$(hyprctl monitors -j | jq 'length')

    # Same amount of monitors and workspaces means there is no actual workspaces, just monitors :P
    if (( $workspaceCount == $monitorCount )); then
	continue;
    fi

    jsonArray="["

    # Interate through our list of Monitors
    for i in {0..$(($workspaceCount-1))}; do

	workspaceId=$(echo $workspacesJson | jq '.['$i'].id')
	if (( workspaceId < 0 )); then
	    continue;
	fi
	
	monitor=$(echo $workspacesJson | jq '.['$i'].monitor')
	monitor=$(echo $monitor | tr -d '"')
	monitorId=$(echo $workspacesJson | jq '.['$i'].monitorID')
	fullscreen=$(echo $workspacesJson | jq '.['$i'].hasfullscreen')
	workspaceJson=$(jq -n -c -M \
			      --arg workspaceId $workspaceId \
			      --arg monitor $monitor \
			      --arg hasFullscreen $fullscreen \
			      --arg monitorId $monitorId \
			      '$ARGS.named')
	if ((i == 0)); then
	    jsonArray="${jsonArray}${workspaceJson}"
	else
	    jsonArray="${jsonArray},${workspaceJson}"
	fi
    done

    jsonArray="${jsonArray}]"
    workspaceCount=$(echo $jsonArray | jq 'length')
    outputData=$(jq -c -n \
	  --arg workspaceCount $workspaceCount \
	  --arg monitorCount $monitorCount \
	  --argjson jsonData $jsonArray \
	  '$ARGS.named')

    if [[ $prevJson != $outputData ]]; then
        echo $outputData
    fi
    
    prevJson=$outputData;
done
