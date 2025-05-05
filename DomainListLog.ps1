<#
.SYNOPSIS
    Reads a list of domains from a text file and uses the Invoke-WebRequestAndLog
    function to attempt a connection and log the request to Syslog for each domain.

.DESCRIPTION
    This script requires the Invoke-WebRequestAndLog function to be available
    in the current session (either defined directly or imported from a module).
    It reads domains (one per line) from a specified input file, prepends "https://",
    and then calls Invoke-WebRequestAndLog for each resulting URI.

.PARAMETER DomainListFile
    The full path to the text file containing the list of domains (one domain per line).
    Example: "C:\temp\domains.txt"

.PARAMETER SyslogServer
    The IP address or hostname of the Syslog server.

.PARAMETER SyslogPort
    The UDP port number for the Syslog server (default is 514).

.EXAMPLE
    # Process domains from C:\data\domainlist.txt and log to syslog server 10.10.1.5
    .\Process-DomainListLog.ps1 -DomainListFile "C:\data\domainlist.txt" -SyslogServer "10.10.1.5"

.EXAMPLE
    # Process domains using a different syslog port
    .\Process-DomainListLog.ps1 -DomainListFile ".\domains_to_check.txt" -SyslogServer "syslog.corp.local" -SyslogPort 1514

.NOTES
    Author: Your Name/AI Assistant
    Date:   2025-05-05
    Requires: PowerShell 3.0 or later.
    Requires: The Invoke-WebRequestAndLog function must be loaded in the session.
    Assumes the input file contains one domain name per line (e.g., example.com).
    Prepends "https://" to each domain. Adjust if you need http:// or have full URIs in the file.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$DomainListFile,

    [Parameter(Mandatory=$true)]
    [string]$SyslogServer,

    [Parameter(Mandatory=$false)]
    [int]$SyslogPort = 514
)

# --- Prerequisites Check ---

# Check if the Invoke-WebRequestAndLog function exists
if (-not (Get-Command Invoke-WebRequestAndLog -ErrorAction SilentlyContinue)) {
    Write-Error "The required function 'Invoke-WebRequestAndLog' was not found. Please ensure it is defined in the session or imported from a module."
    # You might want to add: Write-Error "Try dot-sourcing the script containing the function: . C:\path\to\LogWebRequest.ps1"
    exit 1 # Stop the script
}

# Check if the input file exists
if (-not (Test-Path -Path $DomainListFile -PathType Leaf)) {
    Write-Error "The specified domain list file was not found: $DomainListFile"
    exit 1 # Stop the script
}

# --- Main Processing Logic ---

Write-Host "Starting domain processing from file: $DomainListFile"
Write-Host "Logging to Syslog server: $SyslogServer`:$SyslogPort"

# Get the content of the file, line by line
$domains = Get-Content -Path $DomainListFile

# Loop through each domain in the file
foreach ($domain in $domains) {
    # Trim whitespace just in case
    $trimmedDomain = $domain.Trim()

    # Skip empty lines
    if ([string]::IsNullOrWhiteSpace($trimmedDomain)) {
        Write-Verbose "Skipping empty line."
        continue
    }

    # Construct the URI (assuming HTTPS)
    $uriToTest = "https://$($trimmedDomain)"
    Write-Host "Processing URI: $uriToTest ..."

    # Call the logging function
    # Note: We are not using -Passthru here, just logging. Add it if you need the results.
    try {
        Invoke-WebRequestAndLog -Uri $uriToTest -SyslogServer $SyslogServer -SyslogPort $SyslogPort -ErrorAction Stop
        Write-Verbose "Successfully processed and logged request for $uriToTest"
    }
    catch {
        # Catch errors specifically from Invoke-WebRequestAndLog if it stops execution
        Write-Warning "An error occurred while processing $uriToTest : $($_.Exception.Message)"
        # Continue to the next domain even if one fails
    }

    # Optional: Add a small delay between requests to avoid overwhelming the network or target servers
    # Start-Sleep -Milliseconds 500
}

Write-Host "Finished processing all domains from the file."
