<#
.SYNOPSIS
    Wrapper function for Invoke-WebRequest that logs the requested domain to a Syslog server.

.DESCRIPTION
    This function executes Invoke-WebRequest against a specified URI.
    After the request (successful or not), it extracts the domain name and sends
    a formatted Syslog message via UDP to the specified Syslog server and port.

.PARAMETER Uri
    The Uniform Resource Identifier (URI) to which the web request is sent.

.PARAMETER SyslogServer
    The IP address or hostname of the Syslog server.

.PARAMETER SyslogPort
    The UDP port number for the Syslog server (default is 514).

.PARAMETER Passthru
    If specified, the function will output the result of the Invoke-WebRequest cmdlet.

.EXAMPLE
    # Send a request and log to syslog server 192.168.1.100
    Invoke-WebRequestAndLog -Uri "https://www.example.com/test" -SyslogServer "192.168.1.100"

.EXAMPLE
    # Send a request, log, and also output the web request result
    $result = Invoke-WebRequestAndLog -Uri "https://www.google.com" -SyslogServer "10.0.0.5" -Passthru
    $result.StatusCode

.NOTES
    Author: Your Name/AI Assistant
    Date:   2025-05-05
    Requires: PowerShell 3.0 or later.
    Ensure UDP traffic to the Syslog server/port is allowed through firewalls.
    The Syslog message format used here is basic. You might need to adjust it
    based on your Syslog server's expected format (e.g., RFC 5424).
#>
function Invoke-WebRequestAndLog {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Uri,

        [Parameter(Mandatory=$true)]
        [string]$SyslogServer,

        [Parameter(Mandatory=$false)]
        [int]$SyslogPort = 514,

        [Parameter(Mandatory=$false)]
        [switch]$Passthru
    )

    #region Variables
    $ErrorActionPreference = 'SilentlyContinue' # Continue script even if IWR fails
    $webResult = $null
    $exceptionMessage = $null
    #endregion

    #region Execute Web Request
    Write-Verbose "Attempting web request to: $Uri"
    try {
        # Pass all remaining arguments (like -Method, -Headers etc.) to Invoke-WebRequest if needed
        # For simplicity, this example only passes -Uri
        $webResult = Invoke-WebRequest -Uri $Uri -ErrorAction Stop
        Write-Verbose "Web request successful."
    }
    catch {
        $exceptionMessage = $_.Exception.Message
        Write-Warning "Invoke-WebRequest failed: $exceptionMessage"
    }
    #endregion

    #region Prepare Syslog Message
    Write-Verbose "Preparing Syslog message."
    try {
        # Extract the hostname/domain from the URI
        $uriObject = [System.Uri]$Uri
        $domainName = $uriObject.Host
        $timestamp = Get-Date -Format "MMM dd HH:mm:ss" # Standard Syslog timestamp format
        $hostname = $env:COMPUTERNAME
        $username = $env:USERNAME
        $processId = $PID
        $appName = "PowerShell_IWR_Log" # Identifier for the log source

        # Basic Syslog message format (adjust PRI <facility*8+severity> if needed)
        # Example: <13> is <User-Level Messages.Notice>
        # Using <14> User-Level Messages.Informational
        $syslogMessage = "<14>$timestamp $hostname $appName[$processId]: User '$username' requested domain '$domainName' via Invoke-WebRequest."

        # Add error info if the request failed
        if ($exceptionMessage) {
            $syslogMessage += " Request failed: $exceptionMessage"
        }

        Write-Verbose "Syslog message: $syslogMessage"
    }
    catch {
        Write-Error "Failed to create URI object or prepare Syslog message: $($_.Exception.Message)"
        # Optionally, decide if you still want to send a partial log or just exit
        return # Stop processing if basic info extraction fails
    }
    #endregion

    #region Send Syslog Message
    Write-Verbose "Sending Syslog message to $SyslogServer`:$SyslogPort"
    try {
        $udpClient = New-Object System.Net.Sockets.UdpClient
        $udpClient.Connect($SyslogServer, $SyslogPort)
        $bytes = [System.Text.Encoding]::ASCII.GetBytes($syslogMessage)
        [void]$udpClient.Send($bytes, $bytes.Length)
        $udpClient.Close()
        Write-Verbose "Syslog message sent."
    }
    catch {
        Write-Error "Failed to send Syslog message to $SyslogServer`:$SyslogPort : $($_.Exception.Message)"
    }
    #endregion

    #region Output Result (Optional)
    if ($Passthru) {
        Write-Verbose "Passing through Invoke-WebRequest result."
        return $webResult
    }
    #endregion
}

# --- Example Usage ---

# Define your Syslog Server's IP or Hostname
$MySyslogServer = "192.168.1.100" # <-- CHANGE THIS

# Example 1: Just log the request
# Invoke-WebRequestAndLog -Uri "https://malicious-domain-example.com/path" -SyslogServer $MySyslogServer

# Example 2: Log the request and get the output from Invoke-WebRequest
# $response = Invoke-WebRequestAndLog -Uri "https://www.google.com" -SyslogServer $MySyslogServer -Passthru
# if ($response) {
#     Write-Host "Status Code: $($response.StatusCode)"
# }

# Example 3: Log a failed request
# Invoke-WebRequestAndLog -Uri "https://nonexistent-domain-askjdhaksjd.org" -SyslogServer $MySyslogServer -Verbose
