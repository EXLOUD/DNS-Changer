# DNS configuration script with interactive adapter and provider selection

# Function to display menu
function Show-Menu {
    param(
        [string]$Title,
        [array]$Items
    )
    
    Write-Host "`n=== $Title ===" -ForegroundColor Green
    for ($i = 0; $i -lt $Items.Count; $i++) {
        Write-Host "$($i + 1). $($Items[$i])" -ForegroundColor Yellow
    }
    Write-Host "`n0. Exit" -ForegroundColor Red
}

# Function to identify DNS provider by IP addresses
function Get-DNSProviderName {
    param(
        [array]$ServerAddresses
    )
    
    if ($ServerAddresses.Count -eq 0) {
        return "Automatic (DHCP)"
    }
    
    # Create lookup table for quick provider identification
    $providerLookup = @{
        "8.8.8.8,8.8.4.4" = "Google DNS"
        "8.8.4.4,8.8.8.8" = "Google DNS"
        "1.1.1.1,1.0.0.1" = "Cloudflare DNS"
        "1.0.0.1,1.1.1.1" = "Cloudflare DNS"
        "208.67.222.222,208.67.220.220" = "OpenDNS"
        "208.67.220.220,208.67.222.222" = "OpenDNS"
        "9.9.9.9,149.112.112.112" = "Quad9 DNS"
        "149.112.112.112,9.9.9.9" = "Quad9 DNS"
        "94.140.14.14,94.140.15.15" = "AdGuard DNS"
        "94.140.15.15,94.140.14.14" = "AdGuard DNS"
        "45.90.28.167,45.90.30.167" = "NextDNS"
        "45.90.30.167,45.90.28.167" = "NextDNS"
        "76.76.19.19,76.76.2.22" = "Control D"
        "76.76.2.22,76.76.19.19" = "Control D"
        "185.228.168.168,185.228.169.168" = "CleanBrowsing (Family)"
        "185.228.169.168,185.228.168.168" = "CleanBrowsing (Family)"
        "185.228.168.10,185.228.169.11" = "CleanBrowsing (Adult)"
        "185.228.169.11,185.228.168.10" = "CleanBrowsing (Adult)"
        "185.228.168.9,185.228.169.9" = "CleanBrowsing (Security)"
        "185.228.169.9,185.228.168.9" = "CleanBrowsing (Security)"
        "8.26.56.26,8.20.247.20" = "Comodo Secure DNS"
        "8.20.247.20,8.26.56.26" = "Comodo Secure DNS"
    }
    
    # Create key from server addresses
    $addressKey = $ServerAddresses -join ","
    
    # Check if we have an exact match
    if ($providerLookup.ContainsKey($addressKey)) {
        return $providerLookup[$addressKey]
    }
    
    # Check for single server matches or partial matches
    foreach ($address in $ServerAddresses) {
        switch ($address) {
            { $_ -in @("8.8.8.8", "8.8.4.4") } { return "Google DNS (partial)" }
            { $_ -in @("1.1.1.1", "1.0.0.1") } { return "Cloudflare DNS (partial)" }
            { $_ -in @("208.67.222.222", "208.67.220.220") } { return "OpenDNS (partial)" }
            { $_ -in @("9.9.9.9", "149.112.112.112") } { return "Quad9 DNS (partial)" }
            { $_ -in @("94.140.14.14", "94.140.15.15") } { return "AdGuard DNS (partial)" }
            { $_ -in @("45.90.28.167", "45.90.30.167") } { return "NextDNS (partial)" }
            { $_ -in @("76.76.19.19", "76.76.2.22") } { return "Control D (partial)" }
            { $_ -in @("185.228.168.168", "185.228.169.168") } { return "CleanBrowsing (Family - partial)" }
            { $_ -in @("185.228.168.10", "185.228.169.11") } { return "CleanBrowsing (Adult - partial)" }
            { $_ -in @("185.228.168.9", "185.228.169.9") } { return "CleanBrowsing (Security - partial)" }
            { $_ -in @("8.26.56.26", "8.20.247.20") } { return "Comodo Secure DNS (partial)" }
        }
    }
    
    return "Custom DNS"
}

# Function to display current DNS settings
function Show-CurrentDNSSettings {
    param(
        [object]$Adapter
    )
    
    Write-Host "`n=== Current DNS Settings ===" -ForegroundColor Green
    Write-Host "Adapter: $($Adapter.Name)" -ForegroundColor Yellow
    
    try {
        $currentDNS = Get-DnsClientServerAddress -InterfaceAlias $Adapter.Name -AddressFamily IPv4
        if ($currentDNS.ServerAddresses.Count -gt 0) {
            $providerName = Get-DNSProviderName -ServerAddresses $currentDNS.ServerAddresses
            Write-Host "DNS Provider: $providerName" -ForegroundColor Cyan
            Write-Host "DNS Servers: $($currentDNS.ServerAddresses -join ', ')" -ForegroundColor Yellow
        } else {
            Write-Host "DNS Provider: Automatic (DHCP)" -ForegroundColor Cyan
            Write-Host "DNS Servers: Automatic (DHCP)" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "Error retrieving current DNS settings: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Check administrator rights
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "WARNING: Script requires administrator rights!" -ForegroundColor Red
    Write-Host "Please restart PowerShell as Administrator." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit
}

# Get active network adapters
Write-Host "Getting list of network adapters..." -ForegroundColor Cyan
$adapters = Get-NetAdapter | Where-Object Status -eq "Up"

if ($adapters.Count -eq 0) {
    Write-Host "No active network adapters found!" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit
}

# Ensure $adapters is always an array, even with single adapter
if ($adapters -isnot [Array]) {
    $adapters = @($adapters)
}

# DNS providers list
$dnsProviders = @{
    "Google DNS" = @("8.8.8.8", "8.8.4.4")
    "Cloudflare DNS" = @("1.1.1.1", "1.0.0.1")
    "OpenDNS" = @("208.67.222.222", "208.67.220.220")
    "Quad9 DNS" = @("9.9.9.9", "149.112.112.112")
    "AdGuard DNS" = @("94.140.14.14", "94.140.15.15")
    "NextDNS" = @("45.90.28.167", "45.90.30.167")
    "Control D" = @("76.76.19.19", "76.76.2.22")
    "CleanBrowsing (Family)" = @("185.228.168.168", "185.228.169.168")
    "CleanBrowsing (Adult)" = @("185.228.168.10", "185.228.169.11")
    "CleanBrowsing (Security)" = @("185.228.168.9", "185.228.169.9")
    "Comodo Secure DNS" = @("8.26.56.26", "8.20.247.20")
    "Restore Automatic DNS" = @("auto")
}

# Network adapter selection
Clear-Host
# ── Banner ─────────────────────────────────────────────────────────
Write-Host ("`n" + ("=" * 75)) -ForegroundColor Cyan
Write-Host ""
Write-Host ("DNS Configurator".PadLeft(44)) -ForegroundColor Green
Write-Host ""
Write-Host ("Powered by EXLOUD aka BOBER".PadLeft(49)) -ForegroundColor Yellow
Write-Host ("https://github.com/EXLOUD".PadLeft(48)) -ForegroundColor Blue
Write-Host ""
Write-Host ("=" * 75) -ForegroundColor Cyan
Write-Host ""
# ───────────────────────────────────────────────────────────────────

$adapterNames = $adapters | ForEach-Object { "$($_.Name) ($($_.InterfaceDescription))" }
Show-Menu -Title "Select Network Adapter" -Items $adapterNames

# --- Fixed input loop -------------------------------------------------
do {
    $raw = Read-Host "`nEnter adapter number (0 = Exit)"
    $raw = $raw.Trim()  # Remove whitespace
    
    if ($raw -eq '0') {
        Write-Host "Exiting program..." -ForegroundColor Yellow
        exit
    }

    $index = $null
    $validInput = [int]::TryParse($raw, [ref]$index)
    
    if ($validInput -and $index -ge 1 -and $index -le $adapters.Count) {
        $selectedAdapter = $adapters[$index - 1]  # Convert 1-based to 0-based
        Write-Host "Selected: $($selectedAdapter.Name)" -ForegroundColor Green
        Start-Sleep -Milliseconds 500
        break
    } else {
        Write-Host "Invalid selection. Please enter a number between 1 and $($adapters.Count), or 0 to exit." -ForegroundColor Red
    }
} while ($true)

# Display current DNS settings for selected adapter
Clear-Host
Show-CurrentDNSSettings -Adapter $selectedAdapter

# DNS provider selection
$selectedProvider = $null
$selectedDNS = $null

do {
    Clear-Host
    Show-CurrentDNSSettings -Adapter $selectedAdapter

    $providerNames = $dnsProviders.Keys | Sort-Object
    Show-Menu -Title "Select DNS Provider" -Items $providerNames

    Write-Host "`nn. Reset to Automatic (DHCP)" -ForegroundColor Cyan

    # --- Fixed provider selection --------------------------------------------
    $raw = Read-Host "`nEnter provider number, or 'n' for Reset, or 0 to Exit"
    $raw = $raw.Trim()
    
    if ($raw -eq '0') {
        Write-Host "Exiting program..." -ForegroundColor Yellow
        exit
    }
    
    if ($raw -eq 'n' -or $raw -eq 'N') {
        $selectedProvider = "Reset to Automatic"
        $selectedDNS = @("auto")
        Write-Host "Selected: Reset to Automatic DNS" -ForegroundColor Green
        Start-Sleep -Milliseconds 500
        break
    }

    $index = $null
    $validInput = [int]::TryParse($raw, [ref]$index)
    
    if ($validInput -and $index -ge 1 -and $index -le $providerNames.Count) {
        $selectedProvider = $providerNames[$index - 1]  # Convert 1-based to 0-based
        $selectedDNS = $dnsProviders[$selectedProvider]
        Write-Host "Selected: $selectedProvider" -ForegroundColor Green
        Start-Sleep -Milliseconds 500
        break
    } else {
        Write-Host "Invalid selection. Please enter a number between 1 and $($providerNames.Count), 'n' for automatic, or 0 to exit." -ForegroundColor Red
        Start-Sleep -Milliseconds 1000
    }
} while ($true)

# Apply DNS settings
Clear-Host
Write-Host "=== Applying Settings ===" -ForegroundColor Green
Write-Host "Adapter: $($selectedAdapter.Name)" -ForegroundColor Yellow
Write-Host "DNS Provider: $selectedProvider" -ForegroundColor Yellow

if ($selectedDNS[0] -eq "auto") {
    Write-Host "DNS Servers: Automatic (DHCP)" -ForegroundColor Yellow
} else {
    Write-Host "DNS Servers: $($selectedDNS -join ', ')" -ForegroundColor Yellow
}

$confirm = Read-Host "`nContinue? (Y/N)"

if ($confirm -match '^[Yy]$') {
    try {
        if ($selectedDNS[0] -eq "auto") {
            # Restore automatic DNS settings
            Set-DnsClientServerAddress -InterfaceAlias $selectedAdapter.Name -ResetServerAddresses
            Write-Host "`nDNS settings restored to automatic!" -ForegroundColor Green
        } else {
            # Set selected DNS servers
            Set-DnsClientServerAddress -InterfaceAlias $selectedAdapter.Name -ServerAddresses $selectedDNS
            Write-Host "`nDNS settings successfully applied!" -ForegroundColor Green
        }
        
        # Clear DNS cache
        Write-Host "Clearing DNS cache..." -ForegroundColor Cyan
        Clear-DnsClientCache
        Write-Host "DNS cache cleared!" -ForegroundColor Green
        
        # Display new DNS settings
        Show-CurrentDNSSettings -Adapter $selectedAdapter
        
    } catch {
        Write-Host "`nError applying settings: $($_.Exception.Message)" -ForegroundColor Red
    }
} else {
    Write-Host "Operation cancelled." -ForegroundColor Yellow
}

Read-Host "`nPress Enter to exit"