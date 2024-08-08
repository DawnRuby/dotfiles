#Author : Dawn Ruby <Sudoredact> (https://github.com/dawnruby)
ZSH_THEME_GIT_PROMPT_PREFIX=" %{$fg[green]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY=" %{$fg[red]%}⚡"
ZSH_THEME_GIT_PROMPT_CLEAN=""
COLOR={165}
SEC_COLOR={063}
ERR_COLOR={red}


PROMPT='
%F'$SEC_COLOR'╔═══█%f $(get_ip_address) %F'$SEC_COLOR'█%f
%F'$SEC_COLOR'╚═%f $(get_user)@:%F'$SEC_COLOR'$(get_working_directory)%f: '


get_user(){
    if [ $USER = root ]; then
       echo '%F{red}'$USER'%f'
    else
       echo '%F{063}'$USER'%f'
    fi
}

get_working_directory() {
    #Check if we're in the user directory
    if [[ "$PWD" == *$USER* ]]; then
       #Check if we're root
       if [[ $UID == 0 || $EUID == 0 ]]; then
               #Running as Roooty
               parts=(${(@s:/root:)PWD})
               subdir="${(@j:/:)${(@s:/:)parts}[0,20]}"
               if [[ -z "${subdir// }" ]]; then
                   echo '~/'
               else
                   echo '~'${subdir}'/'
               fi
        else
	       #Running as "normal" user
               # Get current parts of directory
               parts=(${(@s:/home/$USER/:)PWD})
               subdir="${(@j:/:)${(@s:/:)parts}[4,20]}"
       	       if [[ -z "${subdir// }" ]]; then
       	           echo '~/'
	       else
    	           echo '~/'${subdir}'/'
               fi
	fi
    else
	echo $PWD
    fi
}

 get_ip_address() {
	#Initialize variables
	if_count=0
	interfaces=( "${(@fA)$( ip link | awk -F: '$0 !~ "lo|vir|^[^0-9]"{print $2;}' )}" )
	for interface in $interfaces; do
	    interface=$( echo $interface | xargs )
	    interface=${interface%@*}
	    if_ip=$(ip -f inet -o addr show $interface | cut -d' ' -f7 | cut -d'/' -f1 )
	    is_eth=true
	    
	    if ! [ -z "$if_ip" ]; then
		if [[ $interface == wlan* ]] || [[ $interface == wlp* ]]; then
		   is_eth=false
		fi
		
		if_count=`expr $if_count + 1`

		if (( if_count > 1 )); then
		   sep="\x00"
		fi
		
		if $is_eth; then
		   ips=''${ips}${sep}'%F'$COLOR'󰈁 - '${if_ip}'%f'
		else
		   ips=''${ips}${sep}'%F'$COLOR'󰖩 - '${if_ip}'%f'
		fi
		
	    fi
	done

	ip_list=(${(ps.$sep.)ips})
	if [ -z "$ips// " ]; then
      	      echo '%F'$ERR_COLOR' - Disconnected%f'
	elif [[ $if_count > 1 ]]; then
	     echo '%F'$COLOR''${(@j: || :)ip_list[1,4]}'%f'
 	else
	     echo $ips
	fi
}