# wpscanmeepscript
Wpscan script


Here's a Bash script that uses WPScan to perform user enumeration and then conducts a brute force attack using a specified password list:

    # WordPress Vulnerability Scanner

    This script is designed to assist in the identification and potential exploitation of vulnerabilities in WordPress websites. It leverages the WPScan tool, a black box WordPress vulnerability scanner. Below is a detailed explanation of the script functionalities:

    ## Color Variables
    Defines color variables for enhancing the script output.

    ## Banner
    Displays a banner representing the name and version of the script.

    ## Internet Connect
    Checks for an active internet connection before executing the script.

    ## Wpscan Installation
    Checks for the presence of WPScan and installs it if not already available.

    ## Function to Check if a Website is Built with WordPress
    Examines the HTML source of a given website URL to determine if it's built with WordPress.

    ## Input URL
    Prompts the user to input the URL of the website for scanning.

    ## Prompt User to Choose a Wordlist
    Allows the user to choose a wordlist for potential brute force attacks.

    ## Perform User Enumeration
    Performs user enumeration on the WordPress website.

    ## Perform Brute Force Attack for Each Username
    Executes a brute force attack for each enumerated username using the selected wordlist.

    ## Main Menu Function
    Displays a menu with options for various actions such as checking if WPScan is installed, choosing a URL to scan, selecting a wordlist, checking if a URL uses WordPress, user enumeration, scanning, and brute force with a wordlist for users, and displaying help.

    ## Call Functions
    Invokes the banner, connect, and menu functions sequentially.

    ## Usage
    - Ensure you have an active internet connection.
    - Run the script and choose from the available options in the menu.
    - Follow the prompts and instructions provided by the script.

Please make sure you have permission from the site owner before running this script against any WordPress site. Unauthorized access attempts can have legal consequences. Use this script responsibly and only on systems where you have explicit permission to do so.

Version style
v1.0.0

v ..* - Version

v1.. - Major Changes / New Functions

v*.0.* - New Tools / New Directory

v*.*.0 - Minor Changes