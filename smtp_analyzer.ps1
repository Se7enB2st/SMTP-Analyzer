# SMTP Analyzer Tool for PowerShell
# This script helps diagnose scan-to-email issues by checking various SMTP-related configurations

# Set console colors and window title
$Host.UI.RawUI.WindowTitle = "SMTP Analyzer"
$Host.UI.RawUI.ForegroundColor = "White"
$Host.UI.RawUI.BackgroundColor = "Black"

# Script configuration
$script:config = @{
    LogFile = "smtp_analyzer.log"
    DefaultPort = 587
    Timeout = 5000
    EnableLogging = $true
    EnableSSL = $true
    TestEmailSubject = "SMTP Test"
    TestEmailBody = "This is a test email from SMTP Analyzer"
}

# Function to write to log file
function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    if ($script:config.EnableLogging) {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $logMessage = "[$timestamp] [$Level] $Message"
        Add-Content -Path $script:config.LogFile -Value $logMessage
    }
}

# Function to print colored output
function Write-ColorOutput {
    param(
        [string]$Text,
        [string]$Color = "White"
    )
    $Host.UI.RawUI.ForegroundColor = $Color
    Write-Output $Text
    $Host.UI.RawUI.ForegroundColor = "White"
    Write-Log -Message $Text -Level "INFO"
}

# Function to show progress
function Show-Progress {
    param(
        [string]$Activity,
        [string]$Status,
        [int]$PercentComplete
    )
    Write-Progress -Activity $Activity -Status $Status -PercentComplete $PercentComplete
}

# Function to print menu
function Show-Menu {
    Clear-Host
    Write-ColorOutput "`nSMTP Analyzer Menu" "Cyan"
    Write-Output "====================="
    Write-Output "1. Quick Test (All Checks)"
    Write-Output "2. Check Email Format"
    Write-Output "3. Check DNS Records"
    Write-Output "4. Test SMTP Connection"
    Write-Output "5. Test Email Sending"
    Write-Output "6. Troubleshooting Guide"
    Write-Output "7. Settings"
    Write-Output "8. View Log"
    Write-Output "9. Help"
    Write-Output "0. Exit"
    Write-Output "=====================`n"
}

# Function to show help
function Show-Help {
    Clear-Host
    Write-ColorOutput "`nSMTP Analyzer Help" "Cyan"
    Write-Output "====================="
    Write-Output "This tool helps diagnose scan-to-email issues by performing various checks:"
    Write-Output ""
    Write-Output "1. Quick Test - Performs all available checks in sequence"
    Write-Output "2. Email Format - Validates email address syntax"
    Write-Output "3. DNS Records - Checks MX, A, and TXT records"
    Write-Output "4. SMTP Connection - Tests server reachability"
    Write-Output "5. Email Sending - Tests email delivery"
    Write-Output "6. Troubleshooting - Shows common solutions"
    Write-Output "7. Settings - Configure tool options"
    Write-Output "8. View Log - Display log file contents"
    Write-Output "9. Help - Show this help screen"
    Write-Output "0. Exit - Close the program"
    Write-Output ""
    Write-Output "Common Issues:"
    Write-Output "- Invalid email format"
    Write-Output "- DNS configuration problems"
    Write-Output "- SMTP connection failures"
    Write-Output "- Authentication issues"
    Write-Output "- Firewall blocking"
    Write-Output ""
    Write-Output "For more detailed help, see the troubleshooting guide."
    Write-Output "=====================`n"
}

# Function to show settings
function Show-Settings {
    Clear-Host
    Write-ColorOutput "`nSMTP Analyzer Settings" "Cyan"
    Write-Output "====================="
    Write-Output "1. Enable/Disable Logging (Current: $($script:config.EnableLogging))"
    Write-Output "2. Change Default Port (Current: $($script:config.DefaultPort))"
    Write-Output "3. Change Timeout (Current: $($script:config.Timeout)ms)"
    Write-Output "4. Enable/Disable SSL (Current: $($script:config.EnableSSL))"
    Write-Output "5. Change Test Email Subject"
    Write-Output "6. Change Test Email Body"
    Write-Output "7. Back to Main Menu"
    Write-Output "=====================`n"
    
    $choice = Read-Host "Select an option (1-7)"
    switch ($choice) {
        "1" { 
            $script:config.EnableLogging = -not $script:config.EnableLogging
            Write-ColorOutput "Logging $(if ($script:config.EnableLogging) { 'enabled' } else { 'disabled' })" "Green"
        }
        "2" { 
            $port = Read-Host "Enter new default port"
            if ($port -match '^\d+$') {
                $script:config.DefaultPort = [int]$port
                Write-ColorOutput "Default port set to $port" "Green"
            } else {
                Write-ColorOutput "Invalid port number" "Red"
            }
        }
        "3" { 
            $timeout = Read-Host "Enter new timeout in milliseconds"
            if ($timeout -match '^\d+$') {
                $script:config.Timeout = [int]$timeout
                Write-ColorOutput "Timeout set to ${timeout}ms" "Green"
            } else {
                Write-ColorOutput "Invalid timeout value" "Red"
            }
        }
        "4" { 
            $script:config.EnableSSL = -not $script:config.EnableSSL
            Write-ColorOutput "SSL $(if ($script:config.EnableSSL) { 'enabled' } else { 'disabled' })" "Green"
        }
        "5" { 
            $script:config.TestEmailSubject = Read-Host "Enter new test email subject"
            Write-ColorOutput "Test email subject updated" "Green"
        }
        "6" { 
            $script:config.TestEmailBody = Read-Host "Enter new test email body"
            Write-ColorOutput "Test email body updated" "Green"
        }
        "7" { return }
        default { Write-ColorOutput "Invalid option" "Red" }
    }
    Read-Host "Press Enter to continue..."
}

# Function to view log
function Show-Log {
    Clear-Host
    Write-ColorOutput "`nSMTP Analyzer Log" "Cyan"
    Write-Output "====================="
    if (Test-Path $script:config.LogFile) {
        Get-Content $script:config.LogFile | Select-Object -Last 20
    } else {
        Write-ColorOutput "No log file found" "Yellow"
    }
    Write-Output "=====================`n"
    Read-Host "Press Enter to continue..."
}

# Function to validate email format
function Test-EmailFormat {
    param(
        [string]$Email
    )
    $pattern = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    if ($Email -match $pattern) {
        Write-ColorOutput "Email format is valid" "Green"
        return $true
    } else {
        Write-ColorOutput "Invalid email format" "Red"
        return $false
    }
}

# Function to extract domain from email
function Get-EmailDomain {
    param(
        [string]$Email
    )
    return ($Email -split '@')[1]
}

# Function to check DNS records
function Test-DNSRecords {
    param(
        [string]$Domain
    )
    Write-ColorOutput "`nChecking DNS records for $Domain..." "Yellow"
    Show-Progress -Activity "Checking DNS Records" -Status "Processing..." -PercentComplete 0
    
    # Check MX records
    Write-Output "MX Records:"
    try {
        $mxRecords = Resolve-DnsName -Name $Domain -Type MX -ErrorAction Stop
        $mxRecords | ForEach-Object { Write-Output "  $($_.NameExchange) (Priority: $($_.Preference))" }
        Show-Progress -Activity "Checking DNS Records" -Status "MX Records Found" -PercentComplete 33
    } catch {
        Write-ColorOutput "  No MX records found" "Red"
        Write-Log -Message "MX record check failed: $($_.Exception.Message)" -Level "ERROR"
    }
    
    # Check A records
    Write-Output "`nA Records:"
    try {
        $aRecords = Resolve-DnsName -Name $Domain -Type A -ErrorAction Stop
        $aRecords | ForEach-Object { Write-Output "  $($_.IPAddress)" }
        Show-Progress -Activity "Checking DNS Records" -Status "A Records Found" -PercentComplete 66
    } catch {
        Write-ColorOutput "  No A records found" "Red"
        Write-Log -Message "A record check failed: $($_.Exception.Message)" -Level "ERROR"
    }
    
    # Check TXT records
    Write-Output "`nTXT Records:"
    try {
        $txtRecords = Resolve-DnsName -Name $Domain -Type TXT -ErrorAction Stop
        $txtRecords | ForEach-Object { Write-Output "  $($_.Strings)" }
        Show-Progress -Activity "Checking DNS Records" -Status "TXT Records Found" -PercentComplete 100
    } catch {
        Write-ColorOutput "  No TXT records found" "Red"
        Write-Log -Message "TXT record check failed: $($_.Exception.Message)" -Level "ERROR"
    }
    
    Write-Progress -Activity "Checking DNS Records" -Completed
}

# Function to test SMTP connection
function Test-SMTPConnection {
    param(
        [string]$Server,
        [int]$Port
    )
    Write-ColorOutput "`nTesting SMTP connection to $Server`:$Port..." "Yellow"
    Show-Progress -Activity "Testing SMTP Connection" -Status "Connecting..." -PercentComplete 0
    
    try {
        $tcpClient = New-Object System.Net.Sockets.TcpClient
        $result = $tcpClient.BeginConnect($Server, $Port, $null, $null)
        $success = $result.AsyncWaitHandle.WaitOne($script:config.Timeout)
        
        if ($success) {
            Write-ColorOutput "SMTP connection successful" "Green"
            $tcpClient.EndConnect($result)
            $tcpClient.Close()
            Show-Progress -Activity "Testing SMTP Connection" -Status "Connected" -PercentComplete 100
            Write-Log -Message "SMTP connection successful to $Server`:$Port" -Level "INFO"
            return $true
        } else {
            Write-ColorOutput "SMTP connection failed" "Red"
            $tcpClient.Close()
            Write-Log -Message "SMTP connection failed to $Server`:$Port" -Level "ERROR"
            return $false
        }
    } catch {
        Write-ColorOutput "SMTP connection failed: $($_.Exception.Message)" "Red"
        Write-Log -Message "SMTP connection error: $($_.Exception.Message)" -Level "ERROR"
        return $false
    } finally {
        Write-Progress -Activity "Testing SMTP Connection" -Completed
    }
}

# Function to test email sending
function Test-EmailSend {
    param(
        [string]$Server,
        [int]$Port,
        [string]$FromEmail,
        [string]$ToEmail,
        [string]$Username,
        [string]$Password
    )
    Write-ColorOutput "`nTesting email sending..." "Yellow"
    Show-Progress -Activity "Testing Email Sending" -Status "Preparing..." -PercentComplete 0
    
    try {
        $smtpClient = New-Object System.Net.Mail.SmtpClient($Server, $Port)
        $smtpClient.EnableSsl = $script:config.EnableSSL
        $smtpClient.Credentials = New-Object System.Net.NetworkCredential($Username, $Password)
        
        Show-Progress -Activity "Testing Email Sending" -Status "Authenticating..." -PercentComplete 33
        
        $mailMessage = New-Object System.Net.Mail.MailMessage($FromEmail, $ToEmail)
        $mailMessage.Subject = $script:config.TestEmailSubject
        $mailMessage.Body = $script:config.TestEmailBody
        
        Show-Progress -Activity "Testing Email Sending" -Status "Sending..." -PercentComplete 66
        
        $smtpClient.Send($mailMessage)
        Write-ColorOutput "Email sent successfully" "Green"
        Show-Progress -Activity "Testing Email Sending" -Status "Sent" -PercentComplete 100
        Write-Log -Message "Test email sent successfully from $FromEmail to $ToEmail" -Level "INFO"
        return $true
    } catch {
        Write-ColorOutput "Failed to send email: $($_.Exception.Message)" "Red"
        Write-Log -Message "Email send failed: $($_.Exception.Message)" -Level "ERROR"
        return $false
    } finally {
        Write-Progress -Activity "Testing Email Sending" -Completed
    }
}

# Function to show troubleshooting guide
function Show-TroubleshootingGuide {
    Clear-Host
    Write-ColorOutput "`nTroubleshooting Guide" "Yellow"
    Write-Output "====================="
    Write-Output "1. If email format is invalid:"
    Write-Output "   - Check for typos in the email address"
    Write-Output "   - Ensure the domain is correct"
    Write-Output "   - Verify special characters are allowed"
    
    Write-Output "`n2. If DNS checks fail:"
    Write-Output "   - Verify domain is registered"
    Write-Output "   - Check MX records are properly configured"
    Write-Output "   - Ensure A records point to correct IP"
    Write-Output "   - Verify SPF records are set up"
    
    Write-Output "`n3. If SMTP connection fails:"
    Write-Output "   - Check if server is online"
    Write-Output "   - Verify port is correct"
    Write-Output "   - Check firewall settings"
    Write-Output "   - Ensure network connectivity"
    
    Write-Output "`n4. If email sending fails:"
    Write-Output "   - Verify SMTP credentials"
    Write-Output "   - Check authentication method"
    Write-Output "   - Verify sender/recipient addresses"
    Write-Output "   - Check for rate limiting"
    
    Write-Output "`n5. General tips:"
    Write-Output "   - Try different SMTP ports (25, 465, 587)"
    Write-Output "   - Check spam filters"
    Write-Output "   - Verify email size limits"
    Write-Output "   - Check server logs for errors"
    Write-Output "=====================`n"
    Read-Host "Press Enter to continue..."
}

# Function to get user input
function Get-UserInput {
    $script:smtpServer = Read-Host "Enter SMTP server address"
    $script:smtpPort = Read-Host "Enter SMTP port (default $($script:config.DefaultPort))"
    if ([string]::IsNullOrWhiteSpace($script:smtpPort)) {
        $script:smtpPort = $script:config.DefaultPort
    }
    
    do {
        $script:fromEmail = Read-Host "Enter sender email address"
    } while (-not (Test-EmailFormat $script:fromEmail))
    
    do {
        $script:toEmail = Read-Host "Enter recipient email address"
    } while (-not (Test-EmailFormat $script:toEmail))
    
    $script:smtpUsername = Read-Host "Enter SMTP username"
    $script:smtpPassword = Read-Host "Enter SMTP password" -AsSecureString
    $script:smtpPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($script:smtpPassword))
}

# Function to perform quick test
function Invoke-QuickTest {
    Get-UserInput
    $domain = Get-EmailDomain $script:fromEmail
    
    Write-ColorOutput "`nRunning Quick Test..." "Yellow"
    Show-Progress -Activity "Quick Test" -Status "Starting..." -PercentComplete 0
    
    Test-DNSRecords $domain
    Show-Progress -Activity "Quick Test" -Status "DNS Check Complete" -PercentComplete 33
    
    if (Test-SMTPConnection $script:smtpServer $script:smtpPort) {
        Show-Progress -Activity "Quick Test" -Status "Connection Test Complete" -PercentComplete 66
        Test-EmailSend $script:smtpServer $script:smtpPort $script:fromEmail $script:toEmail $script:smtpUsername $script:smtpPassword
    }
    
    Show-Progress -Activity "Quick Test" -Status "Complete" -PercentComplete 100
    Write-Progress -Activity "Quick Test" -Completed
}

# Main function
function Start-SMTPAnalyzer {
    # Create log file if it doesn't exist
    if (-not (Test-Path $script:config.LogFile)) {
        New-Item -Path $script:config.LogFile -ItemType File -Force | Out-Null
    }
    
    Write-Log -Message "SMTP Analyzer started" -Level "INFO"
    
    while ($true) {
        Show-Menu
        $choice = Read-Host "Select an option (0-9)"
        
        switch ($choice) {
            "1" { Invoke-QuickTest }
            "2" { 
                $email = Read-Host "Enter email address to validate"
                Test-EmailFormat $email
            }
            "3" { 
                $domain = Read-Host "Enter domain to check"
                Test-DNSRecords $domain
            }
            "4" { 
                $server = Read-Host "Enter SMTP server"
                $port = Read-Host "Enter port (default $($script:config.DefaultPort))"
                if ([string]::IsNullOrWhiteSpace($port)) {
                    $port = $script:config.DefaultPort
                }
                Test-SMTPConnection $server $port
            }
            "5" { 
                Get-UserInput
                Test-EmailSend $script:smtpServer $script:smtpPort $script:fromEmail $script:toEmail $script:smtpUsername $script:smtpPassword
            }
            "6" { Show-TroubleshootingGuide }
            "7" { Show-Settings }
            "8" { Show-Log }
            "9" { Show-Help }
            "0" { 
                Write-Output "Exiting..."
                Write-Log -Message "SMTP Analyzer stopped" -Level "INFO"
                exit
            }
            default { Write-ColorOutput "Invalid option. Please try again." "Red" }
        }
        
        Read-Host "Press Enter to continue..."
    }
}

# Start the analyzer
Start-SMTPAnalyzer 