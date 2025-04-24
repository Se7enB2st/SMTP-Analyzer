#!/bin/bash

# SMTP Analyzer Tool
# This script helps diagnose scan-to-email issues by checking various SMTP-related configurations
# Uses only basic bash commands and built-in tools

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to validate email format
validate_email() {
    local email=$1
    if [[ $email =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        return 0
    else
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

# Main function
main() {
    echo -e "${YELLOW}SMTP Analyzer Tool${NC}"
    echo "====================="
    
    # Get input from user
    read -p "Enter SMTP server address: " smtp_server
    read -p "Enter SMTP port (default 587): " smtp_port
    smtp_port=${smtp_port:-587}
    
    while true; do
        read -p "Enter sender email address: " from_email
        if validate_email "$from_email"; then
            break
        else
            echo -e "${RED}Invalid email format. Please try again.${NC}"
        fi
    done
    
    while true; do
        read -p "Enter recipient email address: " to_email
        if validate_email "$to_email"; then
            break
        else
            echo -e "${RED}Invalid email format. Please try again.${NC}"
        fi
    done
    
    read -p "Enter SMTP username: " smtp_username
    read -s -p "Enter SMTP password: " smtp_password
    echo "" # New line after password input
    
    # Extract domain from email
    domain=$(get_domain "$from_email")
    
    # Perform checks
    check_dns $domain
    if test_smtp $smtp_server $smtp_port; then
        test_email_send $smtp_server $smtp_port $from_email $to_email $smtp_username $smtp_password
    fi
    
    echo -e "\n${YELLOW}Additional Recommendations:${NC}"
    echo "1. Verify SMTP authentication settings"
    echo "2. Check firewall rules for port $smtp_port"
    echo "3. Verify email client configuration"
    echo "4. Check for any rate limiting on the SMTP server"
    echo "5. Verify DNS records are properly propagated"
    echo "6. Check spam filters and quarantine settings"
    echo "7. Verify email size limits"
}

# Run main function
main 