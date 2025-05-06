# BforeAI PowerShell Scripts

This repository contains two PowerShell scripts designed to process domain lists, send web requests, and log the results to a Syslog server. These scripts were created to capture log data from the BforeAI Intelligence feed and correlate them to an existing Azure Sentinel Instance.

> In order to forward logs correctly you will need to use the [Azure Monitor Agent](https://learn.microsoft.com/en-us/azure/azure-monitor/agents/azure-monitor-agent-overview)  Once installed you will need to configure Data Collection Rules, once you have ingested the data you can use the KQL query provided to correlate the web requests with the BforeAI TAXII feed and your other sources of Intelligence.

## KQL and Domains.txt

The KQL query and the provided domains.txt files are meant to be used to examine potentially malicious domains.  Ingest the domains by logging the web requests with Syslog (see WebRequestandLog.ps1) and then search for other sources of intelligence in Azure Sentinel that might match our IoFA's.

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
.\DomainListlog.ps1 -DomainListFile "C:\data\domains.txt" -SyslogServer "192.168.1.100"

# Process domains using a custom Syslog port
.\DomainListLog.ps1 -DomainListFile "C:\data\domains.txt" -SyslogServer "192.168.1.100" -SyslogPort 1514
```

### 2. `WebRequestandLog.ps1`
This script defines a function `Invoke-WebRequestAndLog` that sends a web request to a specified URI and logs the request details to a Syslog server.

#### Features:
- Sends web requests to a specified URI.
- Logs the request details, including domain, timestamp, and user information, to a Syslog server.
- Supports error handling and logging of failed requests.

#### Parameters:
- `Uri`: The URI to send the web request to.
- `SyslogServer`: IP address or hostname of the Syslog server.
- `SyslogPort` (optional): UDP port for the Syslog server (default is 514).
- `Passthru` (optional): Outputs the result of the web request.

#### Example Usage:
```powershell
# Send a request and log to a Syslog server
Invoke-WebRequestAndLog -Uri "https://www.example.com" -SyslogServer "192.168.1.100"

# Send a request, log, and output the web request result
$response = Invoke-WebRequestAndLog -Uri "https://www.google.com" -SyslogServer "192.168.1.100" -Passthru
$response.StatusCode
```

---

## Installation

1. Clone or download this repository to your local machine.
2. Ensure you have PowerShell 3.0 or later installed.
3. Place the scripts in a directory of your choice (e.g., `C:\Scripts`).

---

## Prerequisites

- Ensure that UDP traffic to the Syslog server and port is allowed through firewalls.
- The `Invoke-WebRequestAndLog` function must be loaded in the session for `DomainListLog.ps1` to work. You can dot-source the script to load the function:
  ```powershell
  . .\WebRequestandLog.ps1
  ```

---

## Notes

- The Syslog message format used in these scripts is basic. Adjustments may be needed based on your Syslog server's expected format (e.g., RFC 5424).
- The `DomainListLog.ps1` script assumes the input file contains one domain per line. Adjustments may be needed if the file format differs.

---