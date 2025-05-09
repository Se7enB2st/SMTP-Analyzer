#!/bin/bash

# SMTP Analyzer Tool
# This script helps diagnose scan-to-email issues by checking various SMTP-related configurations

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
CONFIG_FILE="smtp_analyzer.conf"
LOG_FILE="smtp_analyzer.log"
DEFAULT_PORT=587
TIMEOUT=5
ENABLE_LOGGING=true
ENABLE_SSL=true
TEST_EMAIL_SUBJECT="SMTP Test"
TEST_EMAIL_BODY="This is a test email from SMTP Analyzer"

# Load configuration if exists
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi

# Function to save configuration
save_config() {
    cat > "$CONFIG_FILE" << EOF
DEFAULT_PORT=$DEFAULT_PORT
TIMEOUT=$TIMEOUT
ENABLE_LOGGING=$ENABLE_LOGGING
ENABLE_SSL=$ENABLE_SSL
TEST_EMAIL_SUBJECT="$TEST_EMAIL_SUBJECT"
TEST_EMAIL_BODY="$TEST_EMAIL_BODY"
EOF
}

# Function to write to log file
write_log() {
    local message="$1"
    local level="${2:-INFO}"
    if [ "$ENABLE_LOGGING" = true ]; then
        local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
        echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
    fi
}

# Function to print colored output
print_color() {
    local color="$1"
    local text="$2"
    echo -e "${color}${text}${NC}"
    write_log "$text" "INFO"
}

# Function to show progress
show_progress() {
    local width=50
    local percent=$1
    local filled=$((width * percent / 100))
    local empty=$((width - filled))
    local bar="["
    for ((i=0; i<filled; i++)); do
        bar+="="
    done
    for ((i=0; i<empty; i++)); do
        bar+=" "
    done
    bar+="] $percent%"
    echo -ne "\r$bar"
}

# Function to clear screen
clear_screen() {
    clear
}

# Function to print menu
show_menu() {
    clear_screen
    print_color "$CYAN" "\nSMTP Analyzer Menu"
    echo "====================="
    echo "1. Quick Test (All Checks)"
    echo "2. Check Email Format"
    echo "3. Check DNS Records"
    echo "4. Test SMTP Connection"
    echo "5. Test Email Sending"
    echo "6. Troubleshooting Guide"
    echo "7. Settings"
    echo "8. View Log"
    echo "9. Help"
    echo "0. Exit"
    echo "=====================\n"
}

# Function to show help
show_help() {
    clear_screen
    print_color "$CYAN" "\nSMTP Analyzer Help"
    echo "====================="
    echo "This tool helps diagnose scan-to-email issues by performing various checks:"
    echo ""
    echo "1. Quick Test - Performs all available checks in sequence"
    echo "2. Email Format - Validates email address syntax"
    echo "3. DNS Records - Checks MX, A, and TXT records"
    echo "4. SMTP Connection - Tests server reachability"
    echo "5. Email Sending - Tests email delivery"
    echo "6. Troubleshooting - Shows common solutions"
    echo "7. Settings - Configure tool options"
    echo "8. View Log - Display log file contents"
    echo "9. Help - Show this help screen"
    echo "0. Exit - Close the program"
    echo ""
    echo "Common Issues:"
    echo "- Invalid email format"
    echo "- DNS configuration problems"
    echo "- SMTP connection failures"
    echo "- Authentication issues"
    echo "- Firewall blocking"
    echo ""
    echo "For more detailed help, see the troubleshooting guide."
    echo "=====================\n"
    read -p "Press Enter to continue..."
}

# Function to show settings
show_settings() {
    clear_screen
    print_color "$CYAN" "\nSMTP Analyzer Settings"
    echo "====================="
    echo "1. Enable/Disable Logging (Current: $ENABLE_LOGGING)"
    echo "2. Change Default Port (Current: $DEFAULT_PORT)"
    echo "3. Change Timeout (Current: ${TIMEOUT}s)"
    echo "4. Enable/Disable SSL (Current: $ENABLE_SSL)"
    echo "5. Change Test Email Subject"
    echo "6. Change Test Email Body"
    echo "7. Back to Main Menu"
    echo "=====================\n"
    
    read -p "Select an option (1-7): " choice
    case $choice in
        1)
            if [ "$ENABLE_LOGGING" = true ]; then
                ENABLE_LOGGING=false
            else
                ENABLE_LOGGING=true
            fi
            print_color "$GREEN" "Logging $(if [ "$ENABLE_LOGGING" = true ]; then echo "enabled"; else echo "disabled"; fi)"
            ;;
        2)
            read -p "Enter new default port: " port
            if [[ $port =~ ^[0-9]+$ ]]; then
                DEFAULT_PORT=$port
                print_color "$GREEN" "Default port set to $port"
            else
                print_color "$RED" "Invalid port number"
            fi
            ;;
        3)
            read -p "Enter new timeout in seconds: " timeout
            if [[ $timeout =~ ^[0-9]+$ ]]; then
                TIMEOUT=$timeout
                print_color "$GREEN" "Timeout set to ${timeout}s"
            else
                print_color "$RED" "Invalid timeout value"
            fi
            ;;
        4)
            if [ "$ENABLE_SSL" = true ]; then
                ENABLE_SSL=false
            else
                ENABLE_SSL=true
            fi
            print_color "$GREEN" "SSL $(if [ "$ENABLE_SSL" = true ]; then echo "enabled"; else echo "disabled"; fi)"
            ;;
        5)
            read -p "Enter new test email subject: " TEST_EMAIL_SUBJECT
            print_color "$GREEN" "Test email subject updated"
            ;;
        6)
            read -p "Enter new test email body: " TEST_EMAIL_BODY
            print_color "$GREEN" "Test email body updated"
            ;;
        7)
            return
            ;;
        *)
            print_color "$RED" "Invalid option"
            ;;
    esac
    save_config
    read -p "Press Enter to continue..."
}

# Function to view log
view_log() {
    clear_screen
    print_color "$CYAN" "\nSMTP Analyzer Log"
    echo "====================="
    if [ -f "$LOG_FILE" ]; then
        tail -n 20 "$LOG_FILE"
    else
        print_color "$YELLOW" "No log file found"
    fi
    echo "=====================\n"
    read -p "Press Enter to continue..."
}

# Function to validate email format
validate_email() {
    local email=$1
    if [[ $email =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        print_color "$GREEN" "Email format is valid"
        return 0
    else
        print_color "$RED" "Invalid email format"
        return 1
    fi
}

# Function to extract domain from email
get_domain() {
    local email=$1
    echo "$email" | cut -d'@' -f2
}

# Function to check DNS records
check_dns() {
    local domain=$1
    print_color "$YELLOW" "\nChecking DNS records for $domain..."
    show_progress 0
    
    # Check MX records
    echo "MX Records:"
    if nslookup -type=mx "$domain" 2>/dev/null | grep "mail exchanger"; then
        show_progress 33
    else
        print_color "$RED" "  No MX records found"
        write_log "MX record check failed for $domain" "ERROR"
    fi
    
    # Check A records
    echo -e "\nA Records:"
    if nslookup -type=a "$domain" 2>/dev/null | grep "Address:"; then
        show_progress 66
    else
        print_color "$RED" "  No A records found"
        write_log "A record check failed for $domain" "ERROR"
    fi
    
    # Check TXT records
    echo -e "\nTXT Records:"
    if nslookup -type=txt "$domain" 2>/dev/null | grep "text ="; then
        show_progress 100
    else
        print_color "$RED" "  No TXT records found"
        write_log "TXT record check failed for $domain" "ERROR"
    fi
    
    echo ""
}

# Function to test SMTP connection
test_smtp() {
    local server=$1
    local port=$2
    print_color "$YELLOW" "\nTesting SMTP connection to $server:$port..."
    show_progress 0
    
    if timeout "$TIMEOUT" bash -c "cat < /dev/tcp/$server/$port" 2>/dev/null; then
        print_color "$GREEN" "SMTP connection successful"
        show_progress 100
        write_log "SMTP connection successful to $server:$port" "INFO"
        return 0
    else
        print_color "$RED" "SMTP connection failed"
        write_log "SMTP connection failed to $server:$port" "ERROR"
        return 1
    fi
}

# Function to test email sending
test_email_send() {
    local server=$1
    local port=$2
    local from_email=$3
    local to_email=$4
    local username=$5
    local password=$6
    
    print_color "$YELLOW" "\nTesting email sending..."
    show_progress 0
    
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
Subject: $TEST_EMAIL_SUBJECT
Date: $(date -R)

$TEST_EMAIL_BODY
.
QUIT
EOF
    
    show_progress 33
    
    # Try to send the email
    if timeout "$TIMEOUT" telnet "$server" "$port" < "$temp_file" 2>/dev/null | grep -q "250"; then
        print_color "$GREEN" "Email sent successfully"
        show_progress 100
        write_log "Test email sent successfully from $from_email to $to_email" "INFO"
        rm "$temp_file"
        return 0
    else
        print_color "$RED" "Failed to send email"
        write_log "Email send failed from $from_email to $to_email" "ERROR"
        rm "$temp_file"
        return 1
    fi
}

# Function to show troubleshooting guide
show_troubleshooting_guide() {
    clear_screen
    print_color "$YELLOW" "\nTroubleshooting Guide"
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
    echo "=====================\n"
    read -p "Press Enter to continue..."
}

# Function to get user input
get_user_input() {
    read -p "Enter SMTP server address: " smtp_server
    read -p "Enter SMTP port (default $DEFAULT_PORT): " smtp_port
    smtp_port=${smtp_port:-$DEFAULT_PORT}
    
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
    
    print_color "$YELLOW" "\nRunning Quick Test..."
    show_progress 0
    
    check_dns "$domain"
    show_progress 33
    
    if test_smtp "$smtp_server" "$smtp_port"; then
        show_progress 66
        test_email_send "$smtp_server" "$smtp_port" "$from_email" "$to_email" "$smtp_username" "$smtp_password"
    fi
    
    show_progress 100
    echo ""
}

# Main function
main() {
    # Create log file if it doesn't exist
    touch "$LOG_FILE"
    write_log "SMTP Analyzer started" "INFO"
    
    while true; do
        show_menu
        read -p "Select an option (0-9): " choice
        
        case $choice in
            1) quick_test ;;
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
                read -p "Enter port (default $DEFAULT_PORT): " port
                port=${port:-$DEFAULT_PORT}
                test_smtp "$server" "$port"
                ;;
            5)
                get_user_input
                test_email_send "$smtp_server" "$smtp_port" "$from_email" "$to_email" "$smtp_username" "$smtp_password"
                ;;
            6) show_troubleshooting_guide ;;
            7) show_settings ;;
            8) view_log ;;
            9) show_help ;;
            0)
                print_color "$YELLOW" "Exiting..."
                write_log "SMTP Analyzer stopped" "INFO"
                exit 0
                ;;
            *)
                print_color "$RED" "Invalid option. Please try again."
                ;;
        esac
        
        read -p "Press Enter to continue..."
    done
}

# Start the analyzer
main 