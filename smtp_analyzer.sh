#!/bin/bash

# SMTP Analyzer Tool
# This script helps diagnose scan-to-email issues by checking various SMTP-related configurations
# Uses only basic bash commands and built-in tools

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print menu
print_menu() {
    echo -e "\n${BLUE}SMTP Analyzer Menu${NC}"
    echo "====================="
    echo "1. Quick Test (All Checks)"
    echo "2. Check Email Format"
    echo "3. Check DNS Records"
    echo "4. Test SMTP Connection"
    echo "5. Test Email Sending"
    echo "6. Troubleshooting Guide"
    echo "7. Exit"
    echo -e "=====================\n"
}

# Function to validate email format
validate_email() {
    local email=$1
    if [[ $email =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        echo -e "${GREEN}Email format is valid${NC}"
        return 0
    else
        echo -e "${RED}Invalid email format${NC}"
        return 1
    fi
}

# Function to extract domain from email
get_domain() {
    local email=$1
    echo "$email" | cut -d'@' -f2
}

# Function to check DNS records using nslookup
check_dns() {
    local domain=$1
    echo -e "\n${YELLOW}Checking DNS records for $domain...${NC}"
    
    # Check MX records
    echo "MX Records:"
    nslookup -type=mx $domain 2>/dev/null | grep "mail exchanger"
    
    # Check A records
    echo -e "\nA Records:"
    nslookup -type=a $domain 2>/dev/null | grep "Address:"
    
    # Check TXT records (for SPF)
    echo -e "\nTXT Records:"
    nslookup -type=txt $domain 2>/dev/null | grep "text ="
}

# Function to test SMTP connection using telnet
test_smtp() {
    local server=$1
    local port=$2
    echo -e "\n${YELLOW}Testing SMTP connection to $server:$port...${NC}"
    
    # Try to establish a connection
    if timeout 5 bash -c "cat < /dev/tcp/$server/$port" 2>/dev/null; then
        echo -e "${GREEN}SMTP connection successful${NC}"
        return 0
    else
        echo -e "${RED}SMTP connection failed${NC}"
        return 1
    fi
}

# Function to test email sending using telnet
test_email_send() {
    local server=$1
    local port=$2
    local from_email=$3
    local to_email=$4
    local username=$5
    local password=$6
    
    echo -e "\n${YELLOW}Testing email sending...${NC}"
    
    # Create a temporary file for the SMTP commands
    local temp_file=$(mktemp)
    
    # Write SMTP commands to the file
    cat > "$temp_file" << EOF
EHLO localhost
AUTH LOGIN
$(echo -n "$username" | base64)
$(echo -n "$password" | base64)
MAIL FROM:<$from_email>
RCPT TO:<$to_email>
DATA
From: $from_email
To: $to_email
Subject: SMTP Test
Date: $(date -R)

This is a test email from SMTP Analyzer
.
QUIT
EOF
    
    # Try to send the email
    if timeout 30 telnet $server $port < "$temp_file" 2>/dev/null | grep -q "250"; then
        echo -e "${GREEN}Email sent successfully${NC}"
        rm "$temp_file"
        return 0
    else
        echo -e "${RED}Failed to send email${NC}"
        rm "$temp_file"
        return 1
    fi
}

# Function to show troubleshooting guide
show_troubleshooting_guide() {
    echo -e "\n${YELLOW}Troubleshooting Guide${NC}"
    echo "====================="
    echo "1. If email format is invalid:"
    echo "   - Check for typos in the email address"
    echo "   - Ensure the domain is correct"
    echo "   - Verify special characters are allowed"
    
    echo -e "\n2. If DNS checks fail:"
    echo "   - Verify domain is registered"
    echo "   - Check MX records are properly configured"
    echo "   - Ensure A records point to correct IP"
    echo "   - Verify SPF records are set up"
    
    echo -e "\n3. If SMTP connection fails:"
    echo "   - Check if server is online"
    echo "   - Verify port is correct"
    echo "   - Check firewall settings"
    echo "   - Ensure network connectivity"
    
    echo -e "\n4. If email sending fails:"
    echo "   - Verify SMTP credentials"
    echo "   - Check authentication method"
    echo "   - Verify sender/recipient addresses"
    echo "   - Check for rate limiting"
    
    echo -e "\n5. General tips:"
    echo "   - Try different SMTP ports (25, 465, 587)"
    echo "   - Check spam filters"
    echo "   - Verify email size limits"
    echo "   - Check server logs for errors"
}

# Function to get user input
get_user_input() {
    read -p "Enter SMTP server address: " smtp_server
    read -p "Enter SMTP port (default 587): " smtp_port
    smtp_port=${smtp_port:-587}
    
    while true; do
        read -p "Enter sender email address: " from_email
        if validate_email "$from_email"; then
            break
        fi
    done
    
    while true; do
        read -p "Enter recipient email address: " to_email
        if validate_email "$to_email"; then
            break
        fi
    done
    
    read -p "Enter SMTP username: " smtp_username
    read -s -p "Enter SMTP password: " smtp_password
    echo "" # New line after password input
}

# Function to perform quick test
quick_test() {
    get_user_input
    domain=$(get_domain "$from_email")
    
    echo -e "\n${YELLOW}Running Quick Test...${NC}"
    check_dns $domain
    if test_smtp $smtp_server $smtp_port; then
        test_email_send $smtp_server $smtp_port $from_email $to_email $smtp_username $smtp_password
    fi
}

# Main function
main() {
    while true; do
        print_menu
        read -p "Select an option (1-7): " choice
        
        case $choice in
            1)
                quick_test
                ;;
            2)
                read -p "Enter email address to validate: " email
                validate_email "$email"
                ;;
            3)
                read -p "Enter domain to check: " domain
                check_dns "$domain"
                ;;
            4)
                read -p "Enter SMTP server: " server
                read -p "Enter port (default 587): " port
                port=${port:-587}
                test_smtp "$server" "$port"
                ;;
            5)
                get_user_input
                test_email_send $smtp_server $smtp_port $from_email $to_email $smtp_username $smtp_password
                ;;
            6)
                show_troubleshooting_guide
                ;;
            7)
                echo "Exiting..."
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid option. Please try again.${NC}"
                ;;
        esac
        
        read -p "Press Enter to continue..."
    done
}

# Run main function
main 