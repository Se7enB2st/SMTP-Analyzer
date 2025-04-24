# SMTP-Analyzer

A command-line tool to diagnose and troubleshoot scan-to-email issues by analyzing SMTP configurations and testing email delivery. Uses only built-in bash commands and tools.

## Features

- Email address validation
- DNS record analysis (MX, A, TXT records)
- SMTP connection testing
- Test email sending capability
- Comprehensive diagnostic output
- Color-coded results for better visibility
- No external dependencies required

## Prerequisites

- Bash shell (version 4.0 or higher)
- Basic Unix tools (nslookup, telnet, timeout)
- These tools are typically pre-installed on most Unix-like systems

## Installation

1. Clone this repository:
```bash
git clone https://github.com/se7enb2st/SMTP-Analyzer.git
cd SMTP-Analyzer
```

2. Make the script executable:
```bash
chmod +x smtp_analyzer.sh
```

## Usage

Run the script:
```bash
./smtp_analyzer.sh
```

The script will prompt you for:
- SMTP server address
- SMTP port (defaults to 587)
- Sender email address
- Recipient email address
- SMTP username
- SMTP password

## What the Tool Checks

1. **Email Validation**
   - Validates email address format
   - Extracts domain for DNS checks

2. **DNS Configuration**
   - MX records (mail exchanger)
   - A records (IP addresses)
   - TXT records (including SPF)

3. **SMTP Connectivity**
   - Server reachability
   - Port accessibility
   - Connection establishment

4. **Email Testing**
   - SMTP authentication
   - Test email sending
   - Basic SMTP protocol testing

## Troubleshooting

If you encounter issues:
1. Check your network connectivity
2. Verify DNS resolution is working
3. Ensure the SMTP server is accessible
4. Check firewall settings
5. Verify email credentials
6. Check spam filters and quarantine settings
7. Verify email size limits

## Contributing

Feel free to submit issues and enhancement requests!

## License

This project is licensed under the MIT License - see the LICENSE file for details.