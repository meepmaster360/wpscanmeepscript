#!/bin/bash

# Author: meepmaster
# Date: 06-04-2024
# Description: Enhanced WPSCAN SCRIPT with multiple wordlist options

# Color variables 
RED="\033[1;31m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
NOCOLOR="\033[0m"

# Global variables
website_url=""
PASSWORDLIST=""
USERLIST=""
WORDLISTS_DIR="wordlists"
RESULTS_DIR="scan_results"
LOG_FILE="wpscan_log.txt"

# Create directories if they don't exist
mkdir -p "$WORDLISTS_DIR" "$RESULTS_DIR"

# Banner
function banner() {
    clear
    echo -e "${GREEN}"
    echo -e " __      ___ __  ___  ___ __ _ _ __  _ __ ___   ___  ___ _ __  "
    echo -e " \\ \\ /\\ / / '_ \\/ __|/ __/ _\` | '_ \\| '_ \` _ \\ / _ \\/ _ \\ '_ \\ "
    echo -e "  \\ V  V /| |_) \\__ \\ (_| (_| | | | | | | | | |  __/  __/ |_) |"
    echo -e "   \\_/\\_/ | .__/|___/\\___\\__,_|_| |_|_| |_| |_|\\___|\\___| .__/ "
    echo -e "          | |                                           | |    "
    echo -e "          |_|                                           |_|    "
    echo -e "${NOCOLOR}v1.3.0" 
    sleep 1
}

# Internet Check
function connect() {
    echo -e "\n${BLUE}[*]${NOCOLOR} Checking internet connection..."
    ping -c 1 -w 3 google.com > /dev/null 2>&1
    if [ "$?" != 0 ]; then
        echo -e "\n${RED}[!]${NOCOLOR} This script needs an active internet connection!${NOCOLOR}"
        sleep 2
        exit 1
    fi
    echo -e "${GREEN}[+]${NOCOLOR} Internet connection detected."
}

# Wpscan installation
function wpscan_install() {
    echo -e "\n${BLUE}[*]${NOCOLOR} Checking for WPScan..."
    if [ ! -x "$(command -v wpscan)" ]; then
        echo -e "${YELLOW}[+]${NOCOLOR} WPScan not detected... Installing"
        sudo apt-get update && sudo apt-get install wpscan -y
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}[+]${NOCOLOR} WPScan installed successfully!"
        else
            echo -e "${RED}[!]${NOCOLOR} Failed to install WPScan."
            exit 1
        fi
    else
        echo -e "${GREEN}[+]${NOCOLOR} WPScan is already installed."
        echo -e "${BLUE}[*]${NOCOLOR} WPScan version: $(wpscan --version | head -n 1)"
    fi
}

# Check if URL is WordPress
function check_wordpress() {
    local site_url="$1"
    if [ -z "$site_url" ]; then
        echo -e "${RED}[!]${NOCOLOR} No URL provided."
        return 1
    fi

    echo -e "\n${BLUE}[*]${NOCOLOR} Checking if $site_url is a WordPress site..."
    
    # Check if URL is reachable first
    if ! curl --output /dev/null --silent --head --fail "$site_url"; then
        echo -e "${RED}[!]${NOCOLOR} Site $site_url is not reachable."
        return 1
    fi
    
    # Fetch HTML source code of the website
    html=$(wget -qO- "$site_url" 2>/dev/null)
    
    if [ -z "$html" ]; then
        echo -e "${RED}[!]${NOCOLOR} Could not fetch website content."
        return 1
    fi
    
    # Check for WordPress indicators
    if [[ $html =~ "wp-content" || $html =~ "wp-includes" || $html =~ "wp-json" ]]; then
        echo -e "${GREEN}[+]${NOCOLOR} The site $site_url is built with WordPress."
        return 0
    else
        echo -e "${YELLOW}[-]${NOCOLOR} The site $site_url does not appear to be built with WordPress."
        return 1
    fi
}

# Input URL
function input_url() {
    echo -e "\n${BLUE}[*]${NOCOLOR} Enter the target website URL"
    echo -e "${YELLOW}[?]${NOCOLOR} Example: https://example.com or http://192.168.1.1"
    read -e -r -p "URL: " website_url
    
    # Validate URL format
    if [[ ! "$website_url" =~ ^https?:// ]]; then
        echo -e "${YELLOW}[!]${NOCOLOR} URL should start with http:// or https:// - trying to fix..."
        website_url="http://$website_url"
    fi
    
    check_wordpress "$website_url"
}

# Download wordlists
function download_wordlists() {
    echo -e "\n${BLUE}[*]${NOCOLOR} Downloading common wordlists..."
    
    # Common WordPress passwords
    if [ ! -f "$WORDLISTS_DIR/wp_passwords.txt" ]; then
        wget -q https://raw.githubusercontent.com/meepmaster360/wpscanmeepscript/main/wordlist/wp_passwords.txt -O "$WORDLISTS_DIR/wp_passwords.txt"
        echo -e "${GREEN}[+]${NOCOLOR} Downloaded WordPress common passwords"
    fi
    
    # RockYou wordlist
    if [ ! -f "$WORDLISTS_DIR/rockyou.txt" ]; then
        if [ -f "/usr/share/wordlists/rockyou.txt.gz" ]; then
            gunzip -c "/usr/share/wordlists/rockyou.txt.gz" > "$WORDLISTS_DIR/rockyou.txt"
            echo -e "${GREEN}[+]${NOCOLOR} Extracted rockyou.txt"
        else
            wget -q https://downloads.skullsecurity.org/passwords/rockyou.txt.bz2 -O "$WORDLISTS_DIR/rockyou.txt.bz2"
            bunzip2 "$WORDLISTS_DIR/rockyou.txt.bz2"
            echo -e "${GREEN}[+]${NOCOLOR} Downloaded rockyou.txt"
        fi
    fi
    
    # Common admin usernames
    if [ ! -f "$WORDLISTS_DIR/common_admins.txt" ]; then
        echo -e "admin\nadministrator\nroot\nwordpress\nwpadmin\nuser\ntest" > "$WORDLISTS_DIR/common_admins.txt"
        echo -e "${GREEN}[+]${NOCOLOR} Created common admin usernames list"
    fi
    
    echo -e "${GREEN}[+]${NOCOLOR} Wordlists are ready in $WORDLISTS_DIR/"
}

# Choose wordlist
function wordlist_list() {
    if [ -z "$(ls -A $WORDLISTS_DIR)" ]; then
        download_wordlists
    fi
    
    echo -e "\n${BLUE}[*]${NOCOLOR} Available wordlists:"
    local wordlists=($(ls "$WORDLISTS_DIR"))
    
    PS3="Select a wordlist (1-${#wordlists[@]}): "
    select wordlist in "${wordlists[@]}" "Enter custom path" "Download more"; do
        case $REPLY in
            $(( ${#wordlists[@]} + 1 )) )
                read -e -p "Enter full path to wordlist: " custom_path
                if [ -f "$custom_path" ]; then
                    PASSWORDLIST="$custom_path"
                    break
                else
                    echo -e "${RED}[!]${NOCOLOR} File not found!"
                fi
                ;;
            $(( ${#wordlists[@]} + 2 )) )
                download_wordlists
                wordlist_list
                return
                ;;
            *)
                if [ -n "$wordlist" ]; then
                    PASSWORDLIST="$WORDLISTS_DIR/$wordlist"
                    echo -e "${GREEN}[+]${NOCOLOR} Selected wordlist: $wordlist"
                    break
                else
                    echo -e "${RED}[!]${NOCOLOR} Invalid selection."
                fi
                ;;
        esac
    done
}

# User enumeration
function user_enumeration() {
    if [ -z "$website_url" ]; then
        echo -e "${RED}[!]${NOCOLOR} No URL specified. Please choose option 2 first."
        return
    fi
    
    echo -e "\n${BLUE}[*]${NOCOLOR} Performing user enumeration on $website_url..."
    local output_file="$RESULTS_DIR/user_enum_$(date +%Y%m%d_%H%M%S).txt"
    
    wpscan --url "$website_url" --enumerate u --no-update --random-user-agent --output "$output_file"
    
    if [ $? -eq 0 ]; then
        USERLIST=$(grep -oP '\[\+\] Found user: \K\w+' "$output_file" 2>/dev/null)
        if [ -n "$USERLIST" ]; then
            echo -e "\n${GREEN}[+]${NOCOLOR} Found users:"
            echo "$USERLIST" | tr ' ' '\n'
            echo -e "\nResults saved to: $output_file"
        else
            echo -e "${YELLOW}[-]${NOCOLOR} No users found through enumeration."
        fi
    else
        echo -e "${RED}[!]${NOCOLOR} User enumeration failed."
    fi
}

# Brute force attack
function brute_force() {
    if [ -z "$website_url" ]; then
        echo -e "${RED}[!]${NOCOLOR} No URL specified. Please choose option 2 first."
        return
    fi
    
    if [ -z "$PASSWORDLIST" ]; then
        echo -e "${RED}[!]${NOCOLOR} No wordlist selected. Please choose option 3 first."
        return
    fi
    
    if [ -z "$USERLIST" ]; then
        echo -e "${YELLOW}[!]${NOCOLOR} No users enumerated. Using common admin usernames..."
        USERLIST="admin administrator wordpress wpadmin test"
    fi
    
    echo -e "\n${BLUE}[*]${NOCOLOR} Starting brute force attack..."
    echo -e "${BLUE}[*]${NOCOLOR} Target: $website_url"
    echo -e "${BLUE}[*]${NOCOLOR} Wordlist: $PASSWORDLIST"
    echo -e "${BLUE}[*]${NOCOLOR} Users: $USERLIST"
    
    local timestamp=$(date +%Y%m%d_%H%M%S)
    
    for USERNAME in $USERLIST; do
        echo -e "\n${YELLOW}[*]${NOCOLOR} Attacking user: $USERNAME"
        local output_file="$RESULTS_DIR/brute_${USERNAME}_${timestamp}.txt"
        
        wpscan --url "$website_url" \
               --passwords "$PASSWORDLIST" \
               --usernames "$USERNAME" \
               --max-threads 50 \
               --throttle 100 \
               --request-timeout 10 \
               --random-user-agent \
               --no-update \
               --output "$output_file"
        
        echo -e "${GREEN}[+]${NOCOLOR} Results saved to: $output_file"
        
        # Check if any passwords were found
        if grep -q "Valid Combinations" "$output_file"; then
            echo -e "${RED}[!]${NOCOLOR} PASSWORD FOUND for user $USERNAME!"
            grep -A5 "Valid Combinations" "$output_file"
        fi
    done
}

# Full scan
function full_scan() {
    if [ -z "$website_url" ]; then
        echo -e "${RED}[!]${NOCOLOR} No URL specified. Please choose option 2 first."
        return
    fi
    
    echo -e "\n${BLUE}[*]${NOCOLOR} Starting comprehensive WordPress scan..."
    local output_file="$RESULTS_DIR/full_scan_$(date +%Y%m%d_%H%M%S).txt"
    
    wpscan --url "$website_url" \
           --enumerate u,vp,vt,tt,cb,dbe \
           --plugins-detection aggressive \
           --plugins-version-detection aggressive \
           --random-user-agent \
           --no-update \
           --output "$output_file"
    
    echo -e "\n${GREEN}[+]${NOCOLOR} Full scan completed. Results saved to: $output_file"
}

# Help function
function help() {
    clear
    echo -e "${GREEN}WPSCAN SCRIPT HELP${NOCOLOR}"
    echo -e "------------------"
    echo -e "This script provides a menu-driven interface for WordPress vulnerability scanning using WPScan."
    echo -e ""
    echo -e "${BLUE}OPTIONS:${NOCOLOR}"
    echo -e "1. Check/Install WPScan - Verifies if WPScan is installed and installs it if missing"
    echo -e "2. Enter Target URL - Specify the WordPress site to scan (e.g., https://example.com)"
    echo -e "3. Select Wordlist - Choose from available password wordlists for brute force attacks"
    echo -e "4. Verify WordPress - Check if the target URL is running WordPress"
    echo -e "5. Enumerate Users - Identify valid usernames on the WordPress site"
    echo -e "6. Brute Force Attack - Attempt to crack passwords for found users"
    echo -e "7. Full Scan - Perform comprehensive WordPress vulnerability scan"
    echo -e "8. Help - Display this help information"
    echo -e "0. Exit - Quit the script"
    echo -e ""
    echo -e "${YELLOW}NOTES:${NOCOLOR}"
    echo -e "- Ensure you have proper authorization before scanning any website"
    echo -e "- Some features require an internet connection"
    echo -e "- Results are saved in the '$RESULTS_DIR' directory"
    echo -e ""
    read -n 1 -s -r -p "Press any key to return to the menu..."
}

# Main menu
function menu() {
    while true; do
        clear
        echo -e "${GREEN}WPSCAN MENU${NOCOLOR}"
        echo -e "------------"
        echo -e "${BLUE}Current target:${NOCOLOR} ${YELLOW}$website_url${NOCOLOR}"
        echo -e "${BLUE}Selected wordlist:${NOCOLOR} ${YELLOW}$PASSWORDLIST${NOCOLOR}"
        echo -e "${BLUE}Enumerated users:${NOCOLOR} ${YELLOW}$(echo $USERLIST | tr '\n' ' ')${NOCOLOR}"
        echo -e ""
        echo -e "${GREEN}1${NOCOLOR} Check/Install WPScan"
        echo -e "${GREEN}2${NOCOLOR} Enter Target URL"
        echo -e "${GREEN}3${NOCOLOR} Select Wordlist"
        echo -e "${GREEN}4${NOCOLOR} Verify WordPress"
        echo -e "${GREEN}5${NOCOLOR} Enumerate Users"
        echo -e "${GREEN}6${NOCOLOR} Brute Force Attack"
        echo -e "${GREEN}7${NOCOLOR} Full Comprehensive Scan"
        echo -e "${GREEN}8${NOCOLOR} Help"
        echo -e "${GREEN}0${NOCOLOR} Exit"
        echo -e ""
        
        read -p "$(echo -e "${GREEN}"'Select an option: '"${NOCOLOR}")" option
        
        case $option in
            1) wpscan_install ;;
            2) input_url ;;
            3) wordlist_list ;;
            4) check_wordpress "$website_url" ;;
            5) user_enumeration ;;
            6) brute_force ;;
            7) full_scan ;;
            8) help ;;
            0) echo -e "\n${GREEN}[+]${NOCOLOR} Exiting. Goodbye!"; exit 0 ;;
            *) echo -e "\n${RED}[!]${NOCOLOR} Invalid option. Please try again."; sleep 1 ;;
        esac
        
        echo -e "\n${BLUE}[*]${NOCOLOR} Press any key to continue..."
        read -n 1 -s
    done
}

# Main execution
banner
connect
menu
