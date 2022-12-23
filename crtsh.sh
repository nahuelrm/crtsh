#!/bin/bash

# Dependencies: 
# - httprobe (https://github.com/tomnomnom/httprobe)

#Colors
green="\e[0;32m\033[1m"
endColor="\033[0m\e[0m"
red="\e[0;31m\033[1m"
blue="\e[0;34m\033[1m"
yellow="\e[0;33m\033[1m"
purple="\e[0;35m\033[1m"
cyan="\e[0;36m\033[1m"
gray="\e[0;37m\033[1m"

help_panel() {
	echo -e "Usage: crt.sh [options] <domain/file>"
	echo -e "\nWarning: If you perform a small target scan into a big target it may take forever."
	echo -e "\nOptions:"
	echo -e "\tNote: you can specify a single domain or a file with multiple domains to scan."
	echo -e "\n\t-s <domain>\tsmall target scan"
	echo -e "\t\t\tperforms a recursive subdomain research."
	echo -e "\n\t-b <domain>\tbig target scan"
	echo -e "\t\t\tperforms a simple indepth subdomain research."
	echo -e "\n\t-a <domain>\tautomatic scan"
	echo -e "\t\t\tit automatically scans every subdomain, adapting itself to"
	echo -e "\t\t\tbig targets and small ones."
	echo -e "\n\t-l\t\tcheck for alive hosts"
	echo -e "\t\t\tcheck for alive hosts using httprobe and save them under alive.txt file."
	echo -e "\t\t\tDepending on the number of subdomains it could take some time."
	echo -e "\n\t-i\t\tgrep important subdomains"
	echo -e "\t\t\tgreps interesting subdomains by grepping them with specific words"
	echo -e "\t\t\tthis subdomains will be additionally stored under 'importants.txt' file."
	echo -e "\n\t-o <path>\tpath to output"
	echo -e "\t\t\tmust put a directory that exists, where all the new directories with"
	echo -e "\t\t\tthe results of the scan will be stored in."
	echo -e "\n\t-c <domain>\tcheck target size"
	echo -e "\t\t\tif it the target has more than 50 subdomains at the beginning of the"
	echo -e "\t\t\tscan, it will be considered as a big target."
	echo -e "\n\t-d\t\tcheck for dependencies"
	echo -e "\n\t-h\t\tshow help panel"
	exit
}

ctrl_c() {
	rm -fr $dir 2>/dev/null
	echo -e "${red}[!] Exiting...${endColor}"
}

trap ctrl_c INT

if [[ $# == 0 ]]; then help_panel; fi

declare -g alive=false
declare -g important=false
declare -g output_dir="$(pwd)"

source /lib/libcrt.lib

optstring="ilc:s:b:hda:o:"

while getopts $optstring opt 2>/dev/null; do
	case $opt in
		"l") alive=true ;;
		"i") important=true ;;
		"d") check_dependencies ;;
		"c") 
			if [[ -f $OPTARG ]]; then
				multiple_domain_check $OPTARG
			else
				validate_domain $OPTARG
				check_target $OPTARG 
				exit 0
			fi
			;;
		"o")
			if [[ -d $OPTARG ]]; then
				output_dir=$OPTARG
			else
				echo -e "${red}[!] Output directory not found.${endColor}"
			fi
			;;
	esac
done

OPTIND=1

declare -g dir=$(echo "/tmp/crtsh-$(date_dir)-$(time_dir)")
rm -fr $dir 2>/dev/null; mkdir $dir 2>/dev/null

while getopts $optstring opt 2>/dev/null; do
	case $opt in
		"s") 
			if [[ -f $OPTARG ]]; then
				multiple_domain_scan "small" $OPTARG
			else
				validate_domain $OPTARG
				mkdir $OPTARG 2>/dev/null
				
				echo -e "${cyan}[*] ${gray}Scanning: ${yellow}$OPTARG${gray} subdomains${endColor}"
				scan_small_target $OPTARG 
				check_alive_hosts

				if ! [ -s $dir/alive.txt ]; then 
					rm $dir/alive.txt 2>/dev/null
				else
					mv $dir/alive.txt $OPTARG 2>/dev/null
				fi

				mv $dir/all.txt $OPTARG 2>/dev/null

				if ! [ -s $dir/importants.txt ]; then 
					rm $dir/importants.txt 2>/dev/null
				else
					mv $dir/importants.txt $OPTARG 2>/dev/null
				fi
			fi
			;;
		"b") 
			if [[ -f $OPTARG ]]; then
				multiple_domain_scan "big" $OPTARG
			else
				validate_domain $OPTARG
				mkdir $output_dir/$OPTARG 2>/dev/null

				scan_big_target $OPTARG
				check_alive_hosts

				if ! [ -s $dir/alive.txt ]; then
					rm $dir/alive.txt 2>/dev/null
				else
					mv $dir/alive.txt $output_dir/$OPTARG 2>/dev/null
				fi
				
				mv $dir/all.txt $output_dir/$OPTARG 2>/dev/null

				if ! [ -s $dir/importants.txt ]; then
					rm $dir/importants.txt 2>/dev/null
				else
					mv $dir/importants.txt $output_dir/$OPTARG 2>/dev/null
				fi
			fi
			;;
		"c") ;;
		"l") ;;
		"i") ;;		
		"d") ;;
		"o") ;;
		"a") 
			automatic_scan $OPTARG
			;;
		*) help_panel ;;
	esac
done

shift "$(($OPTIND - 1))"

if [[ -n $1 ]]; then help_panel; fi

rm -fr $dir
