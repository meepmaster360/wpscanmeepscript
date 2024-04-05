#!/bin/bash

# Author: meepmaster
# Date: 06-04-2023
# Description: WPSCAN SCRIPT 


# Color variables 

RED="\033[1;31m"
GREEN="\033[1;32m"
NOCOLOR="\033[0m"

# Banner
                                                                              
function banner() {
	clear
	echo -e "${GREEN}"
    echo -e "__  _  ________   ______  ____  _____     ____    _____    ____   ____  ______   "
    echo -e "\ \/ \/ /\____ \ /  ___/_/ ___\ \__  \   /    \  /     \ _/ __ \_/ __ \ \____ \  "
    echo -e " \     / |  |_> >\___ \ \  \___  / __ \_|   |  \|  Y Y  \\  ___/\  ___/ |  |_> > "
    echo -e "  \/\_/  |   __//____  > \___  >(____  /|___|  /|__|_|  / \___  >\___  >|   __/  "
    echo -e "         |__|        \/      \/      \/      \/       \/      \/     \/ |__|     "
    echo -e "${NOCOLOR}v1.2.0" 
    sleep 2
}

# Internet Connect

function connect() {
	ping -c 1 -w 3 google.com > /dev/null 2>&1																
	if [ "$?" != 0 ];then
		echo -e "\n${RED}[!]${NOCOLOR} ${GREEN}This script needs an active internet connection!${NOCOLOR}"
        sleep 2
		exit 1
	fi
}


# Wpscan installation

function wpscan_install () {
	if [ ! -x "$(command -v wpscan)" ];then																	
        echo -e "${RED}[+]${NOCOLOR} ${GREEN}Wpscan not detected...Installing${NOCOLOR}"
        sudo apt-get install wpscan -y
		else
    	echo -e "\n${GREEN}[+]${NOCOLOR}WPscan detected"
	fi
}

# Função Menu Principal

function menu () {
    echo -e ""
    echo -e "${GREEN}1${NOCOLOR} Check if Wpscan is instaled"
    echo -e ""
    echo -e "${GREEN}1${NOCOLOR} Chose URL to scan"
    echo -e "${GREEN}2${NOCOLOR} Chose Wordlist"
    echo -e ""
    echo -e "${GREEN}3${NOCOLOR} Check if URL uses Wordpress"
    echo -e "${GREEN}3${NOCOLOR} Scan and Force Brute with Wordlist for Users"
    echo -e "${GREEN}4${NOCOLOR} Help"
    echo -e ""
	echo -e "${GREEN}0${NOCOLOR} Exit/Quit"
    echo -e ""
    read -p -e "${GREEN} Select one : ${NOCOLOR}\n" option
    echo -e ""
        case $option in
            1) wpscan_install ;;
            2) RPI_Upgrade ;;
            3) Essencial ;;
            4) Util ;;
            5) Sistema ;;
            6) Adicionar ;;
            7) Remover ;;
            0) echo -e "Exiting." ; exit 0 ;;
            *) echo -e "Invalid option." ; menu ;;
        esac
}  


while true; do
    menu
done


###



function wpscan_install () {

# Wpscan installation	

	if [ ! -x "$(command -v wpscan)" ];then																	
        echo -e "${RED}[+]${NOCOLOR} ${GREEN}Wpscan not detected...Installing${NOCOLOR}"
        sudo apt-get install wpscan -y
		else
    	echo -e "\n${GREEN}[+]${NOCOLOR}WPscan detected"
	fi
}

  

###

# Function to check if a website is built with WordPress
check_wordpress() {
    site_url="$1"
    # Fetch HTML source code of the website
    html=$(wget -qO- "$site_url")
    
    # Check if WordPress specific strings are present in the HTML source
    if [[ $html =~ "wp-content" || $html =~ "wp-includes" || $html =~ "wp-json" ]]; then
        echo "The site $site_url is built with WordPress."
    else
        echo "The site $site_url does not appear to be built with WordPress."
    fi
}

# Main function
main() {
    read -p "Enter the URL of the website: " website_url

    # Call the function to check if the website is built with WordPress
    check_wordpress "$website_url"
}

# Call the main function
main

#### 

# Prompt user for WordPress URL
read -p "Enter the target WordPress URL: " TARGET_URL

# Prompt user to choose a wordlist
echo "Choose a wordlist from the options below: "
select FILENAME in $(ls /path/to/wordlists/*.txt); do
    if [ -n "$FILENAME" ]; then
        PASSWORDLIST="$FILENAME"
        break
    else
        echo "Invalid selection. Please choose a valid option."
    fi
done

# Perform user enumeration
echo "Performing user enumeration..."
wpscan --url "$TARGET_URL" --enumerate u > user_enum.txt

# Extract usernames from the user enumeration result
USERLIST=$(grep 'Username:' user_enum.txt | awk '{print $2}')

# Perform brute force attack for each username
for USERNAME in $USERLIST; do
    echo "Performing brute force attack for user: $USERNAME..."
    wpscan --url "$TARGET_URL" --passwords "$PASSWORDLIST" --user "$USERNAME" --max-threads 50 --disable-tls-checks --max-retries 3 --retry-connrefused --output "brute_force_result_$USERNAME.txt"
done

# Call Functions

banner
connect
    while true; do
    menu
    done


###
# need to give option from many distionary e scan global, com todos os dicionarios