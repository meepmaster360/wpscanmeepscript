#!/bin/bash

# Author: meepmaster
# Date: 06-05-2022
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
    echo -e "${NOCOLOR}v1.6.2" 
}

# Function to check internet connection
function check_internet() {
    ping -c 1 -w 3 google.com > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo -e "\n${RED}[!]${NOCOLOR} ${GREEN}This script requires an active internet connection.${NOCOLOR}"
        exit 1
    fi
}

# Function to install necessary applications
function install_apps() {
    if ! command -v wpscan &>/dev/null; then
        echo -e "${RED}[+]${NOCOLOR} ${GREEN}Wpscan not detected... Installing${NOCOLOR}"
        sudo apt-get install wpscan -y
    else
        echo -e "${GREEN}[+]${NOCOLOR} wpscan detected"
    fi
}

# Function to display the main menu
function display_menu() {
    clear
    echo -e "*-*-*- ${GREEN}WPSCAN BY MEEPMASTER${NOCOLOR} -*-*-*"
    echo -e "*-*-*- ${GREEN}WPSCAN FOR USERS${NOCOLOR} -*-*-*"
    echo
    echo " [1] Update and Upgrade System"
    echo " [2] RPI-Upgrade (Only on Raspberry Pi)"
    echo " [3] Install Essential Software"
    echo " [4] Install Useful Software"
    echo " [5] System Information"
    echo " [6] Add User to System"
    echo " [7] Remove User from System"
    echo " [0] Exit"
    echo
    read -p ">>> Enter your choice: " option
    echo
    
    case $option in
        1) update_upgrade ;;
        2) rpi_upgrade ;;
        3) install_essential ;;
        4) install_useful ;;
        5) system_info ;;
        6) add_user ;;
        7) remove_user ;;
        0) exit ;;
        *) echo -e "${RED}Invalid option.${NOCOLOR}" ;;
    esac
}

# Function to perform user enumeration
function user_enum() {
    read -p "Enter the URL of the website: " website_url

    # Call the function to check if the website is built with WordPress
    check_wordpress "$website_url"
}

# Function to check if a website is built with WordPress
function check_wordpress() {
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

# Function to update and upgrade the system
function update_upgrade() {
    sudo apt-get update && sudo apt-get upgrade -y
}

# Function to perform RPI upgrade (for Raspberry Pi)
function rpi_upgrade() {
    # Add RPI upgrade logic here
    echo "RPI upgrade not implemented yet."
}

# Function to install essential software
function install_essential() {
    # Add installation logic for essential software here
    echo "Installing essential software..."
}

# Function to install useful software
function install_useful() {
    # Add installation logic for useful software here
    echo "Installing useful software..."
}

# Function to display system information
function system_info() {
    # Add system information display logic here
    echo "Displaying system information..."
}

# Function to add a user to the system
function add_user() {
    # Add logic to add user to the system here
    echo "Adding user to the system..."
}

# Function to remove a user from the system
function remove_user() {
    # Add logic to remove user from the system here
    echo "Removing user from the system..."
}

# Main function
function main() {
    banner
    check_internet
    install_apps
    display_menu
}

# Call the main function
main
