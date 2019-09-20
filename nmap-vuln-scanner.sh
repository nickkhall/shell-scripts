#!/usr/bin/env bash
# Use at your own risk. I am not responsible for any malicious use of this script. Do not use this script on any machine
# you do not have persmission to do so. This script is for educational purposes only.

# IP
ip=10.11.1.0

# IP Range
ip_range=0

# Ports
ports=0

# Scripts
scripts=0

# Directory Mode
dir=0

args=( "$@" )

for ((i = 0; i < $#; i++)); do
	case "${args[$(($i))]}" in
		-h | --help )
			echo "A script for enumerating a host, or a list of hosts, using a list of nmap scripts."
			echo -e "\e[33mWARNING\e[39m: This script by default will create a file per .nse script you give it in current working directory."
			echo "If you want this script to create directory for each IP address scanned, and put the output file in that directory, use the -d flag for directory mode."
			echo ""
			echo "Flags:"
			echo "----------------------------------------------------------------------------------"
			echo -e "\e[32m-h  \e[39mor \e[32m--help                  \e[39mPrint out help."
			echo -e "\e[32m-ip \e[39mor \e[32m--ip-address            \e[39mThe IP address you wish to scan. Default is 10.11.1.0."
			echo -e "\e[32m-r  \e[39mor \e[32m--range      \e[96mOPTIONAL\e[39m   The IP address range to scan. The default range is 0."
			echo -e "\e[32m-p  \e[39mor \e[32m--ports      \e[96mOPTIONAL\e[39m   The ports you wish to scan for. Specify the port or list of ports separated by a comma with no spaces. Just how you would do it in a real nmap scan."
			echo "                               Example: -p 139,445"
			echo "                               If you do no specify any ports, it will scan all 65535 ports."
			echo -e "\e[32m-s  \e[39mor \e[32m--scripts    \e[96mREQUIRED\e[39m   The list of scripts you wish to run agains the IP and port(s). Please note, this list must contain .nse files."
			echo -e "\e[32m-d  \e[39mor \e[32m--directory  \e[96mOPTIONAL\e[39m   Will create a directory per IP address scanned in the current working directory, and will place the output file in the directory it created."
			echo ""
			echo "Usage: ./script.sh -ip 192.168.0.0 -r 150 -p 139,445 -s /path/to/scripts."
			exit 1;
			;;
		-ip | --ip-address )
			ip="${args[$(($i+1))]}"
			;;
		-r | --range )
			ip_range="${args[$(($i+1))]}"
			;;
		-p | --ports )
			ports="${args[$(($i+1))]}"
			;;
		-s | --scripts )
			scripts="${args[$(($i+1))]}"
			;;
		-d | --directory )
			dir=1
			;;
		*)
			;;
	esac
done

# If the user does not supply a nse list, abort and show error
if [[ ! -f "$scripts" ]]; then
	echo -e "\e[31m[-] ERROR: \e[39mYou must supply a script file."
	echo -e "Use -h for the help menu"
	exit 1
fi

# Function for iterating through nse file and executing nmap commands
read_scripts() {
	nmap_command="$1"
	current_ip="$2"
	final_nmap_command=""

	echo "NMAP COMING IN: $nmap_command"

	cat "$scripts" | while read nse
		do
                        if [[ $dir -ne 0 ]]; then
                                final_nmap_command="$nmap_command -script=$nse -oA $current_ip/${nse/'.nse'/''} $current_ip &"
				echo -e "\e[33mEXECUTING: \e[39m$final_nmap_command"
                        else
                                final_nmap_command="$nmap_command -script=$nse -oA ${nse/'.nse'/''} $current_ip &"
				echo -e "\e[33mEXECUTING: \e[39m$final_nmap_command"
                        fi

			eval $final_nmap_command
                done
}

# If the user supplied an IP range to scan
if [[ $ip_range -gt 0 ]]; then
	# Iterate over the IP range
	for ((cur_ip_range = 0; cur_ip_range <= $ip_range; cur_ip_range++)); do
		IFS="."
		updated_ip=""
		read -ra ip_array <<< "$ip"

		# Iterate over the split IP address array
		for ((index = 0; index < "${#ip_array[@]}"; index++)); do
			octet="${ip_array[$index]}"

			# If the current index is the last octet
			if [[ $index -eq $((${#ip_array[@]} - 1))  ]]; then
				# Change the last octet to the current IP range
				updated_ip+="$cur_ip_range"
			# Otherwise, we are still iterating through the IP octets
			else
				# Append the current octet to the updated IP
				updated_ip+="$octet."
			fi
		done

		nmap_command="nmap"

		# If the user specified directory mode
		if [[ $dir -ne 0 ]]; then
			# Create a directory with the current IP address as the name
			eval "mkdir $updated_ip"
		fi

		# If the user specified a list of ports
		if [[ $ports -ne 0 ]]; then
			nmap_command+=" -p $ports"
		fi

		# Iterate over scripts and run nmap command(s)
		read_scripts "$nmap_command" "$updated_ip"

	done

# Otherwise, the user only wants to scan one IP address
else
	nmap_command_single="nmap"
	echo "THIS IS SINGLE IP WITH NO RANGE"
	# If the user specified a list of ports
	if [[ $ports -ne 0 ]]; then
		nmap_command_single+=" -p $ports"
	fi

	# If the user specified directory mode
	if [[ $dir -ne 0 ]]; then
		# Create a directory with the current IP address as the name
		mkdir_command="mkdir $ip"
		eval $mkdir_command
	fi

	# Iterate over scripts and run nmap command(s)
	read_scripts "$nmap_command_single" $ip
fi
