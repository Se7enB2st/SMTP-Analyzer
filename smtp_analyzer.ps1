# SMTP Analyzer Tool for PowerShell
# This script helps diagnose scan-to-email issues by checking various SMTP-related configurations

# Set console colors
$Host.UI.RawUI.ForegroundColor = "White"
$Host.UI.RawUI.BackgroundColor = "Black"

# Function to print colored output
function Write-ColorOutput {
    param(
        [string]$Text,
        [string]$Color = "White"
    )
    $Host.UI.RawUI.ForegroundColor = $Color
    Write-Output $Text
    $Host.UI.RawUI.ForegroundColor = "White"
}

# Function to print menu
function Show-Menu {
    Write-ColorOutput "`nSMTP Analyzer Menu" "Cyan"
    Write-Output "====================="
    Write-Output "1. Quick Test (All Checks)"
    Write-Output "2. Check Email Format"
    Write-Output "3. Check DNS Records"
    Write-Output "4. Test SMTP Connection"
    Write-Output "5. Test Email Sending"
    Write-Output "6. Troubleshooting Guide"
    Write-Output "7. Exit"
    Write-Output "=====================`n"
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
    
    # Check MX records
    Write-Output "MX Records:"
    try {
        $mxRecords = Resolve-DnsName -Name $Domain -Type MX -ErrorAction Stop
        $mxRecords | ForEach-Object { Write-Output "  $($_.NameExchange) (Priority: $($_.Preference))" }
    } catch {
        Write-ColorOutput "  No MX records found" "Red"
    }
    
    # Check A records
    Write-Output "`nA Records:"
    try {
        $aRecords = Resolve-DnsName -Name $Domain -Type A -ErrorAction Stop
        $aRecords | ForEach-Object { Write-Output "  $($_.IPAddress)" }
    } catch {
        Write-ColorOutput "  No A records found" "Red"
    }
    
    # Check TXT records
    Write-Output "`nTXT Records:"
    try {
        $txtRecords = Resolve-DnsName -Name $Domain -Type TXT -ErrorAction Stop
        $txtRecords | ForEach-Object { Write-Output "  $($_.Strings)" }
    } catch {
        Write-ColorOutput "  No TXT records found" "Red"
    }
}

# Function to test SMTP connection
function Test-SMTPConnection {
    param(
        [string]$Server,
        [int]$Port
    )
    Write-ColorOutput "`nTesting SMTP connection to $Server`:$Port..." "Yellow"
    
    try {
        $tcpClient = New-Object System.Net.Sockets.TcpClient
        $result = $tcpClient.BeginConnect($Server, $Port, $null, $null)
        $success = $result.AsyncWaitHandle.WaitOne(5000)
        
        if ($success) {
            Write-ColorOutput "SMTP connection successful" "Green"
            $tcpClient.EndConnect($result)
            $tcpClient.Close()
            return $true
        } else {
            Write-ColorOutput "SMTP connection failed" "Red"
            $tcpClient.Close()
            return $false
        }
    } catch {
        Write-ColorOutput "SMTP connection failed: $($_.Exception.Message)" "Red"
        return $false
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
    
    try {
        $smtpClient = New-Object System.Net.Mail.SmtpClient($Server, $Port)
        $smtpClient.EnableSsl = $true
        $smtpClient.Credentials = New-Object System.Net.NetworkCredential($Username, $Password)
        
        $mailMessage = New-Object System.Net.Mail.MailMessage($FromEmail, $ToEmail)
        $mailMessage.Subject = "SMTP Test"
        $mailMessage.Body = "This is a test email from SMTP Analyzer"
        
        $smtpClient.Send($mailMessage)
        Write-ColorOutput "Email sent successfully" "Green"
        return $true
    } catch {
        Write-ColorOutput "Failed to send email: $($_.Exception.Message)" "Red"
        return $false
    }
}

# Function to show troubleshooting guide
function Show-TroubleshootingGuide {
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
}

# Function to get user input
function Get-UserInput {
    $script:smtpServer = Read-Host "Enter SMTP server address"
    $script:smtpPort = Read-Host "Enter SMTP port (default 587)"
    if ([string]::IsNullOrWhiteSpace($script:smtpPort)) {
        $script:smtpPort = 587
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
    Test-DNSRecords $domain
    if (Test-SMTPConnection $script:smtpServer $script:smtpPort) {
        Test-EmailSend $script:smtpServer $script:smtpPort $script:fromEmail $script:toEmail $script:smtpUsername $script:smtpPassword
    }
}

# Main function
function Start-SMTPAnalyzer {
    while ($true) {
        Show-Menu
        $choice = Read-Host "Select an option (1-7)"
        
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
                $port = Read-Host "Enter port (default 587)"
                if ([string]::IsNullOrWhiteSpace($port)) {
                    $port = 587
                }
                Test-SMTPConnection $server $port
            }
            "5" { 
                Get-UserInput
                Test-EmailSend $script:smtpServer $script:smtpPort $script:fromEmail $script:toEmail $script:smtpUsername $script:smtpPassword
            }
            "6" { Show-TroubleshootingGuide }
            "7" { 
                Write-Output "Exiting..."
                exit
            }
            default { Write-ColorOutput "Invalid option. Please try again." "Red" }
        }
        
        Read-Host "Press Enter to continue..."
    }
}

# Start the analyzer
Start-SMTPAnalyzer 