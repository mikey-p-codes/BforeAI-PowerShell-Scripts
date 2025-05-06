# BforeAI PowerShell Scripts

This repository contains two PowerShell scripts designed to process domain lists, send web requests, and log the results to a Syslog server. These scripts are useful for analyzing domain activity and integrating with logging systems.

## Scripts Overview

### 1. `DomainListLog.ps1`
This script reads a list of domains from a text file, sends web requests to each domain, and logs the activity to a Syslog server.

#### Features:
- Reads domains from a text file (one domain per line).
- Sends HTTPS requests to each domain.
- Logs the request details to a Syslog server.
- Handles errors gracefully and continues processing.

#### Parameters:
- `DomainListFile`: Path to the text file containing the list of domains.
- `SyslogServer`: IP address or hostname of the Syslog server.
- `SyslogPort` (optional): UDP port for the Syslog server (default is 514).

#### Example Usage:
```powershell
# Process domains from a file and log to a Syslog server
[DomainListLog.ps1](http://_vscodecontentref_/0) -DomainListFile "C:\data\domains.txt" -SyslogServer "192.168.1.100"

# Process domains using a custom Syslog port
[DomainListLog.ps1](http://_vscodecontentref_/1) -DomainListFile "C:\data\domains.txt" -SyslogServer "192.168.1.100" -SyslogPort 1514