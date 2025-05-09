# SMTP-Analyzer

A command-line tool to diagnose and troubleshoot scan-to-email issues by analyzing SMTP configurations and testing email delivery. Available in both Bash and PowerShell versions.

## Features

- Interactive menu-driven interface
- Email address validation
- DNS record analysis (MX, A, TXT records)
- SMTP connection testing
- Test email sending capability
- Comprehensive troubleshooting guide
- Color-coded results for better visibility
- Configuration management
- Logging system
- Progress indicators
- Help system
- No external dependencies required

## Prerequisites

### Bash Version
- Bash shell (version 4.0 or higher)
- Basic Unix tools (nslookup, telnet, timeout)
- These tools are typically pre-installed on most Unix-like systems

### PowerShell Version
- PowerShell 5.1 or higher
- Windows 7/8/10/11 or Windows Server 2008 R2 or later
- .NET Framework 4.5 or later

## Installation

### Bash Version
1. Clone this repository:
```bash
git clone https://github.com/se7enb2st/SMTP-Analyzer.git
cd SMTP-Analyzer
```

2. Make the script executable:
```bash
chmod +x smtp_analyzer.sh
```

### PowerShell Version
1. Clone this repository:
```powershell
git clone https://github.com/se7enb2st/SMTP-Analyzer.git
cd SMTP-Analyzer
```

2. Set execution policy (if needed):
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## Usage

### Bash Version
Run the script:
```bash
./smtp_analyzer.sh
```

### PowerShell Version
Run the script:
```powershell
.\smtp_analyzer.ps1
```

The interactive menu provides the following options:

1. **Quick Test (All Checks)**
   - Performs all available checks in sequence
   - Validates email addresses
   - Checks DNS records
   - Tests SMTP connection
   - Attempts to send a test email
   - Shows progress indicators

2. **Check Email Format**
   - Validates email address syntax
   - Provides immediate feedback
   - Color-coded results

3. **Check DNS Records**
   - Checks MX records
   - Checks A records
   - Checks TXT records
   - Provides detailed DNS information
   - Shows progress indicators

4. **Test SMTP Connection**
   - Tests server reachability
   - Verifies port accessibility
   - Checks connection establishment
   - Shows progress indicators

5. **Test Email Sending**
   - Tests SMTP authentication
   - Attempts to send a test email
   - Provides detailed feedback
   - Shows progress indicators

6. **Troubleshooting Guide**
   - Shows comprehensive troubleshooting steps
   - Provides solutions for common issues
   - Offers best practices and tips

7. **Settings**
   - Configure tool options
   - Enable/disable logging
   - Change default port
   - Adjust timeout settings
   - Enable/disable SSL
   - Customize test email content

8. **View Log**
   - Display recent log entries
   - View operation history
   - Track errors and successes

9. **Help**
   - Show detailed help information
   - Explain all menu options
   - List common issues
   - Provide usage tips

0. **Exit**
   - Close the program

## Interactive Features

- Color-coded output for better visibility
- Step-by-step guidance
- Immediate feedback on each operation
- Progress indicators for long-running operations
- Pause between operations for better readability
- Detailed error messages
- Comprehensive troubleshooting guide
- Configuration management
- Logging system
- Help system

## Configuration

The tool can be configured through the Settings menu or by editing the configuration file:

### Bash Version
- Configuration file: `smtp_analyzer.conf`
- Log file: `smtp_analyzer.log`

### PowerShell Version
- Configuration file: `smtp_analyzer.json`
- Log file: `smtp_analyzer.log`

Configurable options include:
- Default SMTP port
- Connection timeout
- Logging enabled/disabled
- SSL enabled/disabled
- Test email subject and body

## Troubleshooting

The built-in troubleshooting guide provides solutions for:
1. Email format issues
2. DNS configuration problems
3. SMTP connection failures
4. Email sending issues
5. General tips and best practices

## Contributing

Feel free to submit issues and enhancement requests!