# ════════════════════════════════════════════════════════════════════
# DNS Configuration Script GUI Version
# Author: EXLOUD
# ════════════════════════════════════════════════════════════════════

#Requires -RunAsAdministrator

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

# ════════════════════════════════════════════════════════════════════
# CONFIGURATION SECTION
# ════════════════════════════════════════════════════════════════════

# DNS Providers Database
$script:dnsProviders = @{
    # Security & Privacy Focused
    "Cloudflare DNS" = @{
        IPv4 = @("1.1.1.1", "1.0.0.1")
        IPv6 = @("2606:4700:4700::1111", "2606:4700:4700::1001")
        Description = "Fast, Privacy-focused DNS resolver"
    }
    "Cloudflare (Malware Blocking)" = @{
        IPv4 = @("1.1.1.2", "1.0.0.2")
        IPv6 = @("2606:4700:4700::1112", "2606:4700:4700::1002")
        Description = "Cloudflare with malware protection"
    }
    "Quad9 DNS" = @{
        IPv4 = @("9.9.9.9", "149.112.112.112")
        IPv6 = @("2620:fe::fe", "2620:fe::9")
        Description = "Security-focused with malware blocking"
    }
    "AdGuard DNS" = @{
        IPv4 = @("94.140.14.14", "94.140.15.15")
        IPv6 = @("2a10:50c0::ad1:ff", "2a10:50c0::ad2:ff")
        Description = "Blocks ads, trackers and phishing"
    }
    "AdGuard DNS (Family)" = @{
        IPv4 = @("94.140.14.15", "94.140.15.16")
        IPv6 = @("2a10:50c0::bad1:ff", "2a10:50c0::bad2:ff")
        Description = "Family protection with adult content blocking"
    }
    "NextDNS" = @{
        IPv4 = @("45.90.28.167", "45.90.30.167")
        IPv6 = @("2a07:a8c0::0", "2a07:a8c1::0")
        Description = "Customizable filtering and privacy protection"
    }
    
    # Family & Content Filtering
    "CleanBrowsing (Family)" = @{
        IPv4 = @("185.228.168.168", "185.228.169.168")
        IPv6 = @("2a0d:2a00:1::1", "2a0d:2a00:2::1")
        Description = "Family-safe filtering, blocks adult content"
    }
    "CleanBrowsing (Adult Filter)" = @{
        IPv4 = @("185.228.168.10", "185.228.169.11")
        IPv6 = @("2a0d:2a00:1::", "2a0d:2a00:2::")
        Description = "Blocks adult content only"
    }
    "CleanBrowsing (Security)" = @{
        IPv4 = @("185.228.168.9", "185.228.169.9")
        IPv6 = @("2a0d:2a00:1::2", "2a0d:2a00:2::2")
        Description = "Malware and phishing protection"
    }
    "OpenDNS" = @{
        IPv4 = @("208.67.222.222", "208.67.220.220")
        IPv6 = @("2620:119:35::35", "2620:119:53::53")
        Description = "Customizable filtering with parental controls"
    }
    "OpenDNS (FamilyShield)" = @{
        IPv4 = @("208.67.222.123", "208.67.220.123")
        IPv6 = @("2620:119:35::123", "2620:119:53::123")
        Description = "Pre-configured family protection"
    }
    
    # Traditional & Performance
    "Google DNS" = @{
        IPv4 = @("8.8.8.8", "8.8.4.4")
        IPv6 = @("2001:4860:4860::8888", "2001:4860:4860::8844")
        Description = "Fast, reliable DNS by Google"
    }
    "Control D" = @{
        IPv4 = @("76.76.19.19", "76.76.2.22")
        IPv6 = @("2606:1a40::0", "2606:1a40:1::0")
        Description = "Customizable DNS with filtering options"
    }
    "Comodo Secure DNS" = @{
        IPv4 = @("8.26.56.26", "8.20.247.20")
        IPv6 = @("", "")  # IPv6 not provided
        Description = "Security focused DNS service"
    }
    
    # Additional popular providers
    "Cloudflare (Family)" = @{
        IPv4 = @("1.1.1.3", "1.0.0.3")
        IPv6 = @("2606:4700:4700::1113", "2606:4700:4700::1003")
        Description = "Cloudflare with adult content filtering"
    }
    "DNS.Watch" = @{
        IPv4 = @("84.200.69.80", "84.200.70.40")
        IPv6 = @("2001:1608:10:25::1c04:b12f", "2001:1608:10:25::9249:d69b")
        Description = "No logging, DNSSEC-enabled"
    }
    "Alternate DNS" = @{
        IPv4 = @("76.76.19.19", "76.223.122.150")
        IPv6 = @("2602:fcbc::ad", "2602:fcbc:2::ad")
        Description = "Free public DNS service"
    }
    "Quad9 (No Filtering)" = @{
        IPv4 = @("9.9.9.10", "149.112.112.10")
        IPv6 = @("2620:fe::10", "2620:fe::fe:10")
        Description = "No malware blocking, DNSSEC only"
    }
    "AdGuard DNS (Non-filtering)" = @{
        IPv4 = @("94.140.14.140", "94.140.14.141")
        IPv6 = @("2a10:50c0::1:ff", "2a10:50c0::2:ff")
        Description = "No filtering, just DNS resolution"
    }
}

# ════════════════════════════════════════════════════════════════════
# HELPER FUNCTIONS
# ════════════════════════════════════════════════════════════════════

function Get-DNSProviderName {
    param(
        [array]$ServerAddresses,
        [string]$AddressFamily = "IPv4"
    )
    
    if ($ServerAddresses.Count -eq 0) {
        return "Automatic (DHCP)"
    }
    
    $addressKey = ($ServerAddresses | Sort-Object) -join ","
    
    foreach ($provider in $script:dnsProviders.GetEnumerator()) {
        $providerAddresses = if ($AddressFamily -eq "IPv6") { 
            $provider.Value.IPv6 
        } else { 
            $provider.Value.IPv4 
        }
        
        if ($providerAddresses.Count -gt 0) {
            $providerKey = ($providerAddresses | Sort-Object) -join ","
            if ($addressKey -eq $providerKey) {
                return $provider.Key
            }
        }
    }
    
    return "Custom DNS"
}

function Test-IPAddress {
    param(
        [string]$IP,
        [string]$AddressFamily = "Any"
    )
    
    try {
        $parsedIP = [System.Net.IPAddress]::Parse($IP)
        
        if ($AddressFamily -eq "IPv4") {
            return $parsedIP.AddressFamily -eq [System.Net.Sockets.AddressFamily]::InterNetwork
        } elseif ($AddressFamily -eq "IPv6") {
            return $parsedIP.AddressFamily -eq [System.Net.Sockets.AddressFamily]::InterNetworkV6
        } else {
            return $true
        }
    } catch {
        return $false
    }
}

function Backup-CurrentDNS {
    param([object]$Adapter)
    
    $scriptPath = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Definition }
    $backupFolder = Join-Path -Path $scriptPath -ChildPath "Backup"
    
    if (-not (Test-Path -Path $backupFolder)) {
        New-Item -ItemType Directory -Path $backupFolder -Force | Out-Null
    }
    
    $backupFileName = "DNS_Backup_$(Get-Date -Format 'yyyyMMdd_HHmmss').json"
    $backupPath = Join-Path -Path $backupFolder -ChildPath $backupFileName
    
    try {
        $currentV4 = Get-DnsClientServerAddress -InterfaceAlias $Adapter.Name -AddressFamily IPv4
        $currentV6 = Get-DnsClientServerAddress -InterfaceAlias $Adapter.Name -AddressFamily IPv6
        
        $backup = @{
            Adapter = $Adapter.Name
            Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            ComputerName = $env:COMPUTERNAME
            UserName = $env:USERNAME
            IPv4 = @{
                ServerAddresses = $currentV4.ServerAddresses
                Provider = Get-DNSProviderName -ServerAddresses $currentV4.ServerAddresses -AddressFamily IPv4
            }
            IPv6 = @{
                ServerAddresses = $currentV6.ServerAddresses | Where-Object { $_ -notmatch "^fe80:" }
                Provider = Get-DNSProviderName -ServerAddresses ($currentV6.ServerAddresses | Where-Object { $_ -notmatch "^fe80:" }) -AddressFamily IPv6
            }
        }
        
        $backup | ConvertTo-Json -Depth 3 | Out-File -FilePath $backupPath -Encoding UTF8
        return $backupPath
    } catch {
        return $null
    }
}

# ════════════════════════════════════════════════════════════════════
# GUI CREATION
# ════════════════════════════════════════════════════════════════════

# Create Main Form
$form = New-Object System.Windows.Forms.Form
$form.Text = "DNS Configurator"
$form.Size = New-Object System.Drawing.Size(800, 700)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false
$form.Icon = [System.Drawing.SystemIcons]::Shield

# Color Scheme
$primaryColor = [System.Drawing.Color]::FromArgb(0, 120, 215)
$successColor = [System.Drawing.Color]::FromArgb(0, 128, 0)
$warningColor = [System.Drawing.Color]::FromArgb(255, 140, 0)
$errorColor = [System.Drawing.Color]::FromArgb(220, 20, 60)

# Title Panel
$titlePanel = New-Object System.Windows.Forms.Panel
$titlePanel.Size = New-Object System.Drawing.Size(800, 60)
$titlePanel.Location = New-Object System.Drawing.Point(0, 0)
$titlePanel.BackColor = $primaryColor
$form.Controls.Add($titlePanel)

$titleLabel = New-Object System.Windows.Forms.Label
$titleLabel.Text = "DNS CONFIGURATOR"
$titleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 20, [System.Drawing.FontStyle]::Bold)
$titleLabel.ForeColor = [System.Drawing.Color]::White
$titleLabel.AutoSize = $true
$titleLabel.Location = New-Object System.Drawing.Point(20, 12)
$titlePanel.Controls.Add($titleLabel)

$versionLabel = New-Object System.Windows.Forms.Label
$versionLabel.Text = "v1.1.2"
$versionLabel.Font = New-Object System.Drawing.Font("Segoe UI", 15, [System.Drawing.FontStyle]::Bold)
$versionLabel.ForeColor = [System.Drawing.Color]::White
$versionLabel.Location = New-Object System.Drawing.Point(680, 15)
$titlePanel.Controls.Add($versionLabel)

# Tab Control
$tabControl = New-Object System.Windows.Forms.TabControl
$tabControl.Location = New-Object System.Drawing.Point(10, 70)
$tabControl.Size = New-Object System.Drawing.Size(770, 540)
$tabControl.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$form.Controls.Add($tabControl)

# ════════════════════════════════════════════════════════════════════
# TAB 1: CONFIGURATION
# ════════════════════════════════════════════════════════════════════

$tabConfig = New-Object System.Windows.Forms.TabPage
$tabConfig.Text = "Configuration"
$tabConfig.UseVisualStyleBackColor = $true
$tabControl.Controls.Add($tabConfig)

# Network Adapter GroupBox
$gbAdapter = New-Object System.Windows.Forms.GroupBox
$gbAdapter.Text = "Network Adapter"
$gbAdapter.Location = New-Object System.Drawing.Point(10, 10)
$gbAdapter.Size = New-Object System.Drawing.Size(740, 80)
$gbAdapter.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$tabConfig.Controls.Add($gbAdapter)

$lblAdapter = New-Object System.Windows.Forms.Label
$lblAdapter.Text = "Select Adapter:"
$lblAdapter.Location = New-Object System.Drawing.Point(10, 30)
$lblAdapter.Size = New-Object System.Drawing.Size(110, 25)
$lblAdapter.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$gbAdapter.Controls.Add($lblAdapter)

$cmbAdapter = New-Object System.Windows.Forms.ComboBox
$cmbAdapter.Location = New-Object System.Drawing.Point(125, 28)
$cmbAdapter.Size = New-Object System.Drawing.Size(400, 25)
$cmbAdapter.DropDownStyle = "DropDownList"
$cmbAdapter.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$gbAdapter.Controls.Add($cmbAdapter)

$btnRefreshAdapters = New-Object System.Windows.Forms.Button
$btnRefreshAdapters.Text = "Refresh"
$btnRefreshAdapters.Location = New-Object System.Drawing.Point(540, 27)
$btnRefreshAdapters.Size = New-Object System.Drawing.Size(90, 30)
$btnRefreshAdapters.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$btnRefreshAdapters.FlatStyle = "Flat"
$gbAdapter.Controls.Add($btnRefreshAdapters)

$btnShowCurrent = New-Object System.Windows.Forms.Button
$btnShowCurrent.Text = "Current"
$btnShowCurrent.Location = New-Object System.Drawing.Point(640, 27)
$btnShowCurrent.Size = New-Object System.Drawing.Size(90, 30)
$btnShowCurrent.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$btnShowCurrent.FlatStyle = "Flat"
$gbAdapter.Controls.Add($btnShowCurrent)

# Current Settings GroupBox
$gbCurrent = New-Object System.Windows.Forms.GroupBox
$gbCurrent.Text = "Current DNS Settings"
$gbCurrent.Location = New-Object System.Drawing.Point(10, 100)
$gbCurrent.Size = New-Object System.Drawing.Size(740, 170)
$gbCurrent.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$tabConfig.Controls.Add($gbCurrent)

$txtCurrentSettings = New-Object System.Windows.Forms.TextBox
$txtCurrentSettings.Location = New-Object System.Drawing.Point(10, 25)
$txtCurrentSettings.Size = New-Object System.Drawing.Size(720, 135)
$txtCurrentSettings.Multiline = $true
$txtCurrentSettings.ReadOnly = $true
$txtCurrentSettings.Font = New-Object System.Drawing.Font("Consolas", 9)
$txtCurrentSettings.BackColor = [System.Drawing.Color]::FromArgb(245, 245, 245)
$txtCurrentSettings.ScrollBars = "Vertical"
$gbCurrent.Controls.Add($txtCurrentSettings)

# DNS Provider GroupBox
$gbProvider = New-Object System.Windows.Forms.GroupBox
$gbProvider.Text = "DNS Provider Selection"
$gbProvider.Location = New-Object System.Drawing.Point(10, 280)
$gbProvider.Size = New-Object System.Drawing.Size(740, 165)
$gbProvider.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$tabConfig.Controls.Add($gbProvider)

$lblProvider = New-Object System.Windows.Forms.Label
$lblProvider.Text = "Provider:"
$lblProvider.Location = New-Object System.Drawing.Point(10, 30)
$lblProvider.Size = New-Object System.Drawing.Size(70, 25)
$lblProvider.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$gbProvider.Controls.Add($lblProvider)

$cmbProvider = New-Object System.Windows.Forms.ComboBox
$cmbProvider.Location = New-Object System.Drawing.Point(85, 28)
$cmbProvider.Size = New-Object System.Drawing.Size(280, 25)
$cmbProvider.DropDownStyle = "DropDownList"
$cmbProvider.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$gbProvider.Controls.Add($cmbProvider)

$lblDescription = New-Object System.Windows.Forms.Label
$lblDescription.Location = New-Object System.Drawing.Point(380, 30)
$lblDescription.Size = New-Object System.Drawing.Size(350, 25)
$lblDescription.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Italic)
$lblDescription.ForeColor = [System.Drawing.Color]::Gray
$gbProvider.Controls.Add($lblDescription)

$chkIPv6 = New-Object System.Windows.Forms.CheckBox
$chkIPv6.Text = "Configure IPv6 DNS"
$chkIPv6.Location = New-Object System.Drawing.Point(10, 65)
$chkIPv6.Size = New-Object System.Drawing.Size(200, 25)
$chkIPv6.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$chkIPv6.Checked = $true
$gbProvider.Controls.Add($chkIPv6)

$chkBackup = New-Object System.Windows.Forms.CheckBox
$chkBackup.Text = "Create backup before applying"
$chkBackup.Location = New-Object System.Drawing.Point(220, 65)
$chkBackup.Size = New-Object System.Drawing.Size(250, 25)
$chkBackup.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$chkBackup.Checked = $true
$gbProvider.Controls.Add($chkBackup)

# Custom DNS Panel - ОНОВЛЕНА ВЕРСІЯ З IPv6
$pnlCustom = New-Object System.Windows.Forms.Panel
$pnlCustom.Location = New-Object System.Drawing.Point(10, 95)
$pnlCustom.Size = New-Object System.Drawing.Size(720, 75)
$pnlCustom.Visible = $false
$gbProvider.Controls.Add($pnlCustom)

# IPv4 Controls
$lblCustomIPv4 = New-Object System.Windows.Forms.Label
$lblCustomIPv4.Text = "IPv4:"
$lblCustomIPv4.Location = New-Object System.Drawing.Point(0, 5)
$lblCustomIPv4.Size = New-Object System.Drawing.Size(40, 25)
$lblCustomIPv4.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$pnlCustom.Controls.Add($lblCustomIPv4)

$lblIPv4Primary = New-Object System.Windows.Forms.Label
$lblIPv4Primary.Text = "Primary:"
$lblIPv4Primary.Location = New-Object System.Drawing.Point(45, 5)
$lblIPv4Primary.Size = New-Object System.Drawing.Size(60, 25)
$lblIPv4Primary.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$pnlCustom.Controls.Add($lblIPv4Primary)

$txtIPv4Primary = New-Object System.Windows.Forms.TextBox
$txtIPv4Primary.Location = New-Object System.Drawing.Point(105, 3)
$txtIPv4Primary.Size = New-Object System.Drawing.Size(130, 25)
$txtIPv4Primary.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$txtIPv4Primary.PlaceholderText = "e.g. 8.8.8.8"
$pnlCustom.Controls.Add($txtIPv4Primary)

$lblIPv4Secondary = New-Object System.Windows.Forms.Label
$lblIPv4Secondary.Text = "Secondary:"
$lblIPv4Secondary.Location = New-Object System.Drawing.Point(245, 5)
$lblIPv4Secondary.Size = New-Object System.Drawing.Size(75, 25)
$lblIPv4Secondary.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$pnlCustom.Controls.Add($lblIPv4Secondary)

$txtIPv4Secondary = New-Object System.Windows.Forms.TextBox
$txtIPv4Secondary.Location = New-Object System.Drawing.Point(320, 3)
$txtIPv4Secondary.Size = New-Object System.Drawing.Size(130, 25)
$txtIPv4Secondary.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$txtIPv4Secondary.PlaceholderText = "e.g. 8.8.4.4"
$pnlCustom.Controls.Add($txtIPv4Secondary)

# IPv6 Controls
$lblCustomIPv6 = New-Object System.Windows.Forms.Label
$lblCustomIPv6.Text = "IPv6:"
$lblCustomIPv6.Location = New-Object System.Drawing.Point(0, 38)
$lblCustomIPv6.Size = New-Object System.Drawing.Size(40, 25)
$lblCustomIPv6.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$pnlCustom.Controls.Add($lblCustomIPv6)

$lblIPv6Primary = New-Object System.Windows.Forms.Label
$lblIPv6Primary.Text = "Primary:"
$lblIPv6Primary.Location = New-Object System.Drawing.Point(45, 38)
$lblIPv6Primary.Size = New-Object System.Drawing.Size(60, 25)
$lblIPv6Primary.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$pnlCustom.Controls.Add($lblIPv6Primary)

$txtIPv6Primary = New-Object System.Windows.Forms.TextBox
$txtIPv6Primary.Location = New-Object System.Drawing.Point(105, 36)
$txtIPv6Primary.Size = New-Object System.Drawing.Size(250, 25)
$txtIPv6Primary.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$txtIPv6Primary.PlaceholderText = "e.g. 2001:4860:4860::8888"
$pnlCustom.Controls.Add($txtIPv6Primary)

$lblIPv6Secondary = New-Object System.Windows.Forms.Label
$lblIPv6Secondary.Text = "Secondary:"
$lblIPv6Secondary.Location = New-Object System.Drawing.Point(365, 38)
$lblIPv6Secondary.Size = New-Object System.Drawing.Size(75, 25)
$lblIPv6Secondary.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$pnlCustom.Controls.Add($lblIPv6Secondary)

$txtIPv6Secondary = New-Object System.Windows.Forms.TextBox
$txtIPv6Secondary.Location = New-Object System.Drawing.Point(440, 36)
$txtIPv6Secondary.Size = New-Object System.Drawing.Size(250, 25)
$txtIPv6Secondary.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$txtIPv6Secondary.PlaceholderText = "e.g. 2001:4860:4860::8844"
$pnlCustom.Controls.Add($txtIPv6Secondary)

$lblCustomNote = New-Object System.Windows.Forms.Label
$lblCustomNote.Text = "(Optional: Leave IPv6 fields empty to skip IPv6 configuration)"
$lblCustomNote.Location = New-Object System.Drawing.Point(460, 2)
$lblCustomNote.Size = New-Object System.Drawing.Size(250, 29)
$lblCustomNote.Font = New-Object System.Drawing.Font("Segoe UI", 8, [System.Drawing.FontStyle]::Italic)
$lblCustomNote.ForeColor = [System.Drawing.Color]::Gray
$pnlCustom.Controls.Add($lblCustomNote)

# Action Buttons Panel
$pnlActions = New-Object System.Windows.Forms.Panel
$pnlActions.Location = New-Object System.Drawing.Point(10, 420)
$pnlActions.Size = New-Object System.Drawing.Size(740, 80)
$tabConfig.Controls.Add($pnlActions)

$btnApply = New-Object System.Windows.Forms.Button
$btnApply.Text = "Apply Settings"
$btnApply.Location = New-Object System.Drawing.Point(120, 35)
$btnApply.Size = New-Object System.Drawing.Size(150, 40)
$btnApply.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
$btnApply.BackColor = $successColor
$btnApply.ForeColor = [System.Drawing.Color]::White
$btnApply.FlatStyle = "Flat"
$pnlActions.Controls.Add($btnApply)

$btnReset = New-Object System.Windows.Forms.Button
$btnReset.Text = "Reset to DHCP"
$btnReset.Location = New-Object System.Drawing.Point(300, 35)
$btnReset.Size = New-Object System.Drawing.Size(150, 40)
$btnReset.Font = New-Object System.Drawing.Font("Segoe UI", 11)
$btnReset.BackColor = $warningColor
$btnReset.ForeColor = [System.Drawing.Color]::White
$btnReset.FlatStyle = "Flat"
$pnlActions.Controls.Add($btnReset)

$btnTest = New-Object System.Windows.Forms.Button
$btnTest.Text = "Test DNS"
$btnTest.Location = New-Object System.Drawing.Point(480, 35)
$btnTest.Size = New-Object System.Drawing.Size(120, 40)
$btnTest.Font = New-Object System.Drawing.Font("Segoe UI", 11)
$btnTest.BackColor = $primaryColor
$btnTest.ForeColor = [System.Drawing.Color]::White
$btnTest.FlatStyle = "Flat"
$pnlActions.Controls.Add($btnTest)

# ════════════════════════════════════════════════════════════════════
# TAB 2: BACKUP & RESTORE
# ════════════════════════════════════════════════════════════════════

$tabBackup = New-Object System.Windows.Forms.TabPage
$tabBackup.Text = "Backup & Restore"
$tabBackup.UseVisualStyleBackColor = $true
$tabControl.Controls.Add($tabBackup)

$gbBackupList = New-Object System.Windows.Forms.GroupBox
$gbBackupList.Text = "Available Backups"
$gbBackupList.Location = New-Object System.Drawing.Point(10, 10)
$gbBackupList.Size = New-Object System.Drawing.Size(740, 350)
$gbBackupList.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$tabBackup.Controls.Add($gbBackupList)

$dgvBackups = New-Object System.Windows.Forms.DataGridView
$dgvBackups.Location = New-Object System.Drawing.Point(10, 25)
$dgvBackups.Size = New-Object System.Drawing.Size(720, 280)
$dgvBackups.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$dgvBackups.AllowUserToAddRows = $false
$dgvBackups.AllowUserToDeleteRows = $false
$dgvBackups.ReadOnly = $true
$dgvBackups.SelectionMode = "FullRowSelect"
$dgvBackups.MultiSelect = $false
$dgvBackups.RowHeadersVisible = $false
$dgvBackups.AutoSizeColumnsMode = "Fill"
$gbBackupList.Controls.Add($dgvBackups)

# Add columns to DataGridView
$dgvBackups.Columns.Add("Date", "Date") | Out-Null
$dgvBackups.Columns.Add("Adapter", "Adapter") | Out-Null
$dgvBackups.Columns.Add("IPv4Provider", "IPv4 Provider") | Out-Null
$dgvBackups.Columns.Add("IPv6Provider", "IPv6 Provider") | Out-Null
$dgvBackups.Columns.Add("FilePath", "FilePath") | Out-Null
$dgvBackups.Columns["FilePath"].Visible = $false

$pnlBackupActions = New-Object System.Windows.Forms.Panel
$pnlBackupActions.Location = New-Object System.Drawing.Point(10, 310)
$pnlBackupActions.Size = New-Object System.Drawing.Size(720, 35)
$gbBackupList.Controls.Add($pnlBackupActions)

$btnRestoreBackup = New-Object System.Windows.Forms.Button
$btnRestoreBackup.Text = "Restore Selected"
$btnRestoreBackup.Location = New-Object System.Drawing.Point(110, 0)
$btnRestoreBackup.Size = New-Object System.Drawing.Size(150, 30)
$btnRestoreBackup.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$btnRestoreBackup.BackColor = $successColor
$btnRestoreBackup.ForeColor = [System.Drawing.Color]::White
$btnRestoreBackup.FlatStyle = "Flat"
$pnlBackupActions.Controls.Add($btnRestoreBackup)

$btnDeleteBackup = New-Object System.Windows.Forms.Button
$btnDeleteBackup.Text = "Delete Selected"
$btnDeleteBackup.Location = New-Object System.Drawing.Point(290, 0)
$btnDeleteBackup.Size = New-Object System.Drawing.Size(150, 30)
$btnDeleteBackup.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$btnDeleteBackup.BackColor = $errorColor
$btnDeleteBackup.ForeColor = [System.Drawing.Color]::White
$btnDeleteBackup.FlatStyle = "Flat"
$pnlBackupActions.Controls.Add($btnDeleteBackup)

$btnRefreshBackups = New-Object System.Windows.Forms.Button
$btnRefreshBackups.Text = "Refresh List"
$btnRefreshBackups.Location = New-Object System.Drawing.Point(470, 0)
$btnRefreshBackups.Size = New-Object System.Drawing.Size(150, 30)
$btnRefreshBackups.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$btnRefreshBackups.BackColor = $primaryColor
$btnRefreshBackups.ForeColor = [System.Drawing.Color]::White
$btnRefreshBackups.FlatStyle = "Flat"
$pnlBackupActions.Controls.Add($btnRefreshBackups)

$gbBackupDetails = New-Object System.Windows.Forms.GroupBox
$gbBackupDetails.Text = "Backup Details"
$gbBackupDetails.Location = New-Object System.Drawing.Point(10, 370)
$gbBackupDetails.Size = New-Object System.Drawing.Size(740, 120)
$gbBackupDetails.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$tabBackup.Controls.Add($gbBackupDetails)

$txtBackupDetails = New-Object System.Windows.Forms.TextBox
$txtBackupDetails.Location = New-Object System.Drawing.Point(10, 25)
$txtBackupDetails.Size = New-Object System.Drawing.Size(720, 85)
$txtBackupDetails.Multiline = $true
$txtBackupDetails.ReadOnly = $true
$txtBackupDetails.Font = New-Object System.Drawing.Font("Consolas", 9)
$txtBackupDetails.BackColor = [System.Drawing.Color]::FromArgb(245, 245, 245)
$txtBackupDetails.ScrollBars = "Vertical"
$gbBackupDetails.Controls.Add($txtBackupDetails)

# ════════════════════════════════════════════════════════════════════
# TAB 3: DIAGNOSTICS
# ════════════════════════════════════════════════════════════════════

$tabDiagnostics = New-Object System.Windows.Forms.TabPage
$tabDiagnostics.Text = "Diagnostics"
$tabDiagnostics.UseVisualStyleBackColor = $true
$tabControl.Controls.Add($tabDiagnostics)

$gbDiagnostics = New-Object System.Windows.Forms.GroupBox
$gbDiagnostics.Text = "Network Diagnostics"
$gbDiagnostics.Location = New-Object System.Drawing.Point(10, 10)
$gbDiagnostics.Size = New-Object System.Drawing.Size(740, 480)
$gbDiagnostics.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$tabDiagnostics.Controls.Add($gbDiagnostics)

$pnlDiagButtons = New-Object System.Windows.Forms.Panel
$pnlDiagButtons.Location = New-Object System.Drawing.Point(10, 25)
$pnlDiagButtons.Size = New-Object System.Drawing.Size(720, 40)
$gbDiagnostics.Controls.Add($pnlDiagButtons)

$btnPingTest = New-Object System.Windows.Forms.Button
$btnPingTest.Text = "Ping Test"
$btnPingTest.Location = New-Object System.Drawing.Point(0, 5)
$btnPingTest.Size = New-Object System.Drawing.Size(110, 30)
$btnPingTest.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$btnPingTest.FlatStyle = "Flat"
$pnlDiagButtons.Controls.Add($btnPingTest)

$btnDNSLookup = New-Object System.Windows.Forms.Button
$btnDNSLookup.Text = "DNS Lookup"
$btnDNSLookup.Location = New-Object System.Drawing.Point(120, 5)
$btnDNSLookup.Size = New-Object System.Drawing.Size(110, 30)
$btnDNSLookup.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$btnDNSLookup.FlatStyle = "Flat"
$pnlDiagButtons.Controls.Add($btnDNSLookup)

$btnFlushDNS = New-Object System.Windows.Forms.Button
$btnFlushDNS.Text = "Flush DNS"
$btnFlushDNS.Location = New-Object System.Drawing.Point(240, 5)
$btnFlushDNS.Size = New-Object System.Drawing.Size(110, 30)
$btnFlushDNS.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$btnFlushDNS.FlatStyle = "Flat"
$pnlDiagButtons.Controls.Add($btnFlushDNS)

$btnIPConfig = New-Object System.Windows.Forms.Button
$btnIPConfig.Text = "IP Config"
$btnIPConfig.Location = New-Object System.Drawing.Point(360, 5)
$btnIPConfig.Size = New-Object System.Drawing.Size(110, 30)
$btnIPConfig.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$btnIPConfig.FlatStyle = "Flat"
$pnlDiagButtons.Controls.Add($btnIPConfig)

$btnClearOutput = New-Object System.Windows.Forms.Button
$btnClearOutput.Text = "Clear"
$btnClearOutput.Location = New-Object System.Drawing.Point(610, 5)
$btnClearOutput.Size = New-Object System.Drawing.Size(100, 30)
$btnClearOutput.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$btnClearOutput.FlatStyle = "Flat"
$pnlDiagButtons.Controls.Add($btnClearOutput)

$txtDiagOutput = New-Object System.Windows.Forms.TextBox
$txtDiagOutput.Location = New-Object System.Drawing.Point(10, 70)
$txtDiagOutput.Size = New-Object System.Drawing.Size(720, 400)
$txtDiagOutput.Multiline = $true
$txtDiagOutput.ReadOnly = $true
$txtDiagOutput.Font = New-Object System.Drawing.Font("Consolas", 9)
$txtDiagOutput.BackColor = [System.Drawing.Color]::Black
$txtDiagOutput.ForeColor = [System.Drawing.Color]::Lime
$txtDiagOutput.ScrollBars = "Both"
$gbDiagnostics.Controls.Add($txtDiagOutput)

# Status Bar
$statusBar = New-Object System.Windows.Forms.StatusStrip
$statusLabel = New-Object System.Windows.Forms.ToolStripStatusLabel
$statusLabel.Text = "Ready"
$statusBar.Items.Add($statusLabel) | Out-Null
$form.Controls.Add($statusBar)

# Progress Bar (hidden by default)
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(10, 620)
$progressBar.Size = New-Object System.Drawing.Size(770, 25)
$progressBar.Visible = $false
$form.Controls.Add($progressBar)

# ════════════════════════════════════════════════════════════════════
# HELPER FUNCTIONS FOR GUI (with approved verbs)
# ════════════════════════════════════════════════════════════════════

function Update-Status {
    param(
        [string]$Message,
        [string]$Type = "Info"
    )
    
    $statusLabel.Text = $Message
    
    switch ($Type) {
        "Success" { $statusLabel.ForeColor = $successColor }
        "Error" { $statusLabel.ForeColor = $errorColor }
        "Warning" { $statusLabel.ForeColor = $warningColor }
        default { $statusLabel.ForeColor = [System.Drawing.Color]::Black }
    }
    
    [System.Windows.Forms.Application]::DoEvents()
}

function Show-Progress {
    param(
        [int]$Value,
        [string]$Status = ""
    )
    
    if ($Value -eq 0) {
        $progressBar.Visible = $false
        $progressBar.Value = 0
    } else {
        $progressBar.Visible = $true
        $progressBar.Value = [Math]::Min($Value, 100)
    }
    
    if ($Status) {
        Update-Status -Message $Status
    }
    
    [System.Windows.Forms.Application]::DoEvents()
}

function Initialize-NetworkAdapters {
    $cmbAdapter.Items.Clear()
    Update-Status -Message "Loading network adapters..."
    
    $adapters = Get-NetAdapter | Where-Object Status -eq "Up"
    
    if ($adapters.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show(
            "No active network adapters found!", 
            "Error", 
            [System.Windows.Forms.MessageBoxButtons]::OK, 
            [System.Windows.Forms.MessageBoxIcon]::Error
        )
        return
    }
    
    foreach ($adapter in $adapters) {
        $cmbAdapter.Items.Add("$($adapter.Name) - $($adapter.InterfaceDescription)")
    }
    
    if ($cmbAdapter.Items.Count -gt 0) {
        $cmbAdapter.SelectedIndex = 0
    }
    
    Update-Status -Message "Ready" -Type "Info"
}

function Initialize-DNSProviders {
    $cmbProvider.Items.Clear()
    $cmbProvider.Items.Add("-- Select Provider --")
    $cmbProvider.Items.Add("Automatic (DHCP)")
    $cmbProvider.Items.Add("─────────────────────")
    
    # Security & Privacy Focused
    $cmbProvider.Items.Add("▼ Security & Privacy")
    $cmbProvider.Items.Add("  Cloudflare DNS")
    $cmbProvider.Items.Add("  Cloudflare (Malware Blocking)")
    $cmbProvider.Items.Add("  Quad9 DNS")
    $cmbProvider.Items.Add("  AdGuard DNS")
    $cmbProvider.Items.Add("  NextDNS")
    $cmbProvider.Items.Add("─────────────────────")
    
    # Family & Content Filtering
    $cmbProvider.Items.Add("▼ Family Protection")
    $cmbProvider.Items.Add("  CleanBrowsing (Family)")
    $cmbProvider.Items.Add("  CleanBrowsing (Adult Filter)")
    $cmbProvider.Items.Add("  CleanBrowsing (Security)")
    $cmbProvider.Items.Add("  OpenDNS")
    $cmbProvider.Items.Add("  OpenDNS (FamilyShield)")
    $cmbProvider.Items.Add("  Cloudflare (Family)")
    $cmbProvider.Items.Add("  AdGuard DNS (Family)")
    $cmbProvider.Items.Add("─────────────────────")
    
    # Traditional & Performance
    $cmbProvider.Items.Add("▼ Traditional DNS")
    $cmbProvider.Items.Add("  Google DNS")
    $cmbProvider.Items.Add("  Control D")
    $cmbProvider.Items.Add("  Comodo Secure DNS")
    $cmbProvider.Items.Add("─────────────────────")
    
    # Additional
    $cmbProvider.Items.Add("▼ Other Providers")
    $cmbProvider.Items.Add("  DNS.Watch")
    $cmbProvider.Items.Add("  Alternate DNS")
    $cmbProvider.Items.Add("  Quad9 (No Filtering)")
    $cmbProvider.Items.Add("  AdGuard DNS (Non-filtering)")
    $cmbProvider.Items.Add("─────────────────────")
    
    $cmbProvider.Items.Add("Custom DNS")
    $cmbProvider.SelectedIndex = 0
}

function Update-CurrentSettings {
    if ($cmbAdapter.SelectedIndex -lt 0) { return }
    
    $adapterName = $cmbAdapter.SelectedItem.ToString().Split(' - ')[0]
    Update-Status -Message "Loading current DNS settings..."
    
    try {
        $currentV4 = Get-DnsClientServerAddress -InterfaceAlias $adapterName -AddressFamily IPv4 -ErrorAction SilentlyContinue
        $currentV6 = Get-DnsClientServerAddress -InterfaceAlias $adapterName -AddressFamily IPv6 -ErrorAction SilentlyContinue
        
        $settings = "Adapter: $adapterName`r`n"
        $settings += "========================================`r`n"
        
        if ($currentV4) {
            $providerV4 = Get-DNSProviderName -ServerAddresses $currentV4.ServerAddresses -AddressFamily IPv4
            $settings += "IPv4 Provider: $providerV4`r`n"
            
            if ($currentV4.ServerAddresses.Count -gt 0) {
                $settings += "IPv4 Servers: $($currentV4.ServerAddresses -join ', ')`r`n"
            } else {
                $settings += "IPv4 Servers: Automatic (DHCP)`r`n"
            }
        }
        
        $settings += "`r`n"
        
        if ($currentV6) {
            $v6Addresses = $currentV6.ServerAddresses | Where-Object { $_ -notmatch "^fe80:" }
            $providerV6 = Get-DNSProviderName -ServerAddresses $v6Addresses -AddressFamily IPv6
            $settings += "IPv6 Provider: $providerV6`r`n"
            
            if ($v6Addresses.Count -gt 0) {
                $settings += "IPv6 Servers: $($v6Addresses -join ', ')`r`n"
            } else {
                $settings += "IPv6 Servers: Automatic (DHCP/SLAAC)`r`n"
            }
        }
        
        $txtCurrentSettings.Text = $settings
        Update-Status -Message "Current settings loaded" -Type "Success"
    } catch {
        $txtCurrentSettings.Text = "Error loading settings: $_"
        Update-Status -Message "Error loading settings" -Type "Error"
    }
}

function Initialize-Backups {
    $dgvBackups.Rows.Clear()
    
    $scriptPath = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Definition }
    $backupFolder = Join-Path -Path $scriptPath -ChildPath "Backup"
    
    if (Test-Path -Path $backupFolder) {
        $backups = Get-ChildItem -Path $backupFolder -Filter "DNS_Backup_*.json" | Sort-Object -Property CreationTime -Descending
        
        foreach ($backup in $backups) {
            try {
                $content = Get-Content -Path $backup.FullName -Raw | ConvertFrom-Json
                $dgvBackups.Rows.Add(
                    $content.Date,
                    $content.Adapter,
                    $content.IPv4.Provider,
                    $content.IPv6.Provider,
                    $backup.FullName
                )
            } catch {
                # Skip corrupted backup files
            }
        }
    }
    
    Update-Status -Message "Loaded $($dgvBackups.Rows.Count) backup(s)" -Type "Info"
}

# ════════════════════════════════════════════════════════════════════
# EVENT HANDLERS
# ════════════════════════════════════════════════════════════════════

$btnRefreshAdapters.Add_Click({
    Initialize-NetworkAdapters
})

$btnShowCurrent.Add_Click({
    Update-CurrentSettings
})

$cmbAdapter.Add_SelectedIndexChanged({
    if ($cmbAdapter.SelectedIndex -ge 0) {
        Update-CurrentSettings
    }
})

$cmbProvider.Add_SelectedIndexChanged({
    $selectedItem = $cmbProvider.SelectedItem.ToString()

    if ($selectedItem -match "^─+$" -or $selectedItem -match "^▼") {
        $cmbProvider.SelectedIndex = 0
        return
    }
    
    $selectedProvider = $selectedItem.TrimStart()
    
    if ($cmbProvider.SelectedIndex -le 0) {
        $lblDescription.Text = ""
        $pnlCustom.Visible = $false
        return
    }
    
    if ($selectedProvider -eq "Custom DNS") {
        $lblDescription.Text = "Enter custom DNS server addresses"
        $pnlCustom.Visible = $true
        # Clear custom fields when switching to another provider
    } elseif ($selectedProvider -eq "Automatic (DHCP)") {
        $lblDescription.Text = "Use automatic DNS from DHCP"
        $pnlCustom.Visible = $false
        # Clear custom fields
        $txtIPv4Primary.Clear()
        $txtIPv4Secondary.Clear()
        $txtIPv6Primary.Clear()
        $txtIPv6Secondary.Clear()
    } elseif ($script:dnsProviders.ContainsKey($selectedProvider)) {
        $lblDescription.Text = $script:dnsProviders[$selectedProvider].Description
        $pnlCustom.Visible = $false
        # Clear custom fields
        $txtIPv4Primary.Clear()
        $txtIPv4Secondary.Clear()
        $txtIPv6Primary.Clear()
        $txtIPv6Secondary.Clear()
    } else {
        $lblDescription.Text = ""
        $pnlCustom.Visible = $false
    }
})

$btnApply.Add_Click({
    if ($cmbAdapter.SelectedIndex -lt 0) {
        [System.Windows.Forms.MessageBox]::Show("Please select a network adapter", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
        return
    }
    
    if ($cmbProvider.SelectedIndex -le 0) {
        [System.Windows.Forms.MessageBox]::Show("Please select a DNS provider", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
        return
    }
    
    $adapterName = $cmbAdapter.SelectedItem.ToString().Split(' - ')[0]
    $selectedProvider = $cmbProvider.SelectedItem.ToString()
    
    # Validate custom DNS if selected
    if ($selectedProvider -eq "Custom DNS") {
        # Validate IPv4
        if ([string]::IsNullOrWhiteSpace($txtIPv4Primary.Text)) {
            [System.Windows.Forms.MessageBox]::Show("Please enter at least a primary IPv4 DNS server", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
            return
        }
        
        if (-not (Test-IPAddress $txtIPv4Primary.Text -AddressFamily IPv4)) {
            [System.Windows.Forms.MessageBox]::Show("Invalid IPv4 primary DNS address", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
            return
        }
        
        if (-not [string]::IsNullOrWhiteSpace($txtIPv4Secondary.Text) -and -not (Test-IPAddress $txtIPv4Secondary.Text -AddressFamily IPv4)) {
            [System.Windows.Forms.MessageBox]::Show("Invalid IPv4 secondary DNS address", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
            return
        }
        
        # Validate IPv6 (optional)
        if (-not [string]::IsNullOrWhiteSpace($txtIPv6Primary.Text)) {
            if (-not (Test-IPAddress $txtIPv6Primary.Text -AddressFamily IPv6)) {
                [System.Windows.Forms.MessageBox]::Show("Invalid IPv6 primary DNS address", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
                return
            }
            
            if (-not [string]::IsNullOrWhiteSpace($txtIPv6Secondary.Text) -and -not (Test-IPAddress $txtIPv6Secondary.Text -AddressFamily IPv6)) {
                [System.Windows.Forms.MessageBox]::Show("Invalid IPv6 secondary DNS address", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
                return
            }
        }
    }
    
    $result = [System.Windows.Forms.MessageBox]::Show(
        "Apply DNS settings to $adapterName`?`n`nProvider: $selectedProvider", 
        "Confirm", 
        [System.Windows.Forms.MessageBoxButtons]::YesNo, 
        [System.Windows.Forms.MessageBoxIcon]::Question
    )
    
    if ($result -eq [System.Windows.Forms.DialogResult]::No) { return }
    
    try {
        Show-Progress -Value 10 -Status "Starting configuration..."
        
        # Create backup if requested
        if ($chkBackup.Checked) {
            Show-Progress -Value 20 -Status "Creating backup..."
            $adapterObj = Get-NetAdapter | Where-Object { $_.Name -eq $adapterName }
            $backupPath = Backup-CurrentDNS -Adapter $adapterObj
            if ($backupPath) {
                Update-Status -Message "Backup created" -Type "Success"
            }
        }
        
        Show-Progress -Value 40 -Status "Applying DNS settings..."
        
        # Apply settings based on selection
        if ($selectedProvider -eq "Automatic (DHCP)") {
            Set-DnsClientServerAddress -InterfaceAlias $adapterName -ResetServerAddresses
            
            if ($chkIPv6.Checked) {
                netsh interface ipv6 set dnsservers "$adapterName" dhcp | Out-Null
            }
        } elseif ($selectedProvider -eq "Custom DNS") {
            # Apply IPv4
            $ipv4Servers = @($txtIPv4Primary.Text)
            if (-not [string]::IsNullOrWhiteSpace($txtIPv4Secondary.Text)) {
                $ipv4Servers += $txtIPv4Secondary.Text
            }
            Set-DnsClientServerAddress -InterfaceAlias $adapterName -ServerAddresses $ipv4Servers
            
            # Apply IPv6 if provided and checkbox is checked
            if ($chkIPv6.Checked -and -not [string]::IsNullOrWhiteSpace($txtIPv6Primary.Text)) {
                netsh interface ipv6 set dnsservers "$adapterName" static $txtIPv6Primary.Text primary | Out-Null
                
                if (-not [string]::IsNullOrWhiteSpace($txtIPv6Secondary.Text)) {
                    netsh interface ipv6 add dnsservers "$adapterName" $txtIPv6Secondary.Text index=2 | Out-Null
                }
            } elseif ($chkIPv6.Checked -and [string]::IsNullOrWhiteSpace($txtIPv6Primary.Text)) {
                # Reset IPv6 to automatic if no custom IPv6 provided
                netsh interface ipv6 set dnsservers "$adapterName" dhcp | Out-Null
            }
        } else {
            $selectedProvider = $selectedProvider.TrimStart()
            
            $providerData = $script:dnsProviders[$selectedProvider]
            
            if ($providerData -and $providerData.IPv4.Count -gt 0) {
                Set-DnsClientServerAddress -InterfaceAlias $adapterName -ServerAddresses $providerData.IPv4
            }
            
            if ($chkIPv6.Checked -and $providerData -and $providerData.IPv6.Count -gt 0 -and $providerData.IPv6[0] -ne "") {
                netsh interface ipv6 set dnsservers "$adapterName" static $providerData.IPv6[0] primary | Out-Null
                if ($providerData.IPv6.Count -gt 1 -and $providerData.IPv6[1] -ne "") {
                    netsh interface ipv6 add dnsservers "$adapterName" $providerData.IPv6[1] index=2 | Out-Null
                }
            } elseif ($chkIPv6.Checked) {
                # Reset IPv6 to automatic if provider doesn't have IPv6
                netsh interface ipv6 set dnsservers "$adapterName" dhcp | Out-Null
            }
        }
        
        Show-Progress -Value 70 -Status "Flushing DNS cache..."
        Clear-DnsClientCache
        ipconfig /flushdns | Out-Null
        
        Show-Progress -Value 90 -Status "Registering DNS..."
        ipconfig /registerdns | Out-Null
        
        Show-Progress -Value 100 -Status "Configuration complete!"
        Start-Sleep -Milliseconds 500
        Show-Progress -Value 0
        
        Update-CurrentSettings
        
        [System.Windows.Forms.MessageBox]::Show(
            "DNS settings applied successfully!", 
            "Success", 
            [System.Windows.Forms.MessageBoxButtons]::OK, 
            [System.Windows.Forms.MessageBoxIcon]::Information
        )
        
        Update-Status -Message "DNS configuration completed successfully" -Type "Success"
    } catch {
        Show-Progress -Value 0
        [System.Windows.Forms.MessageBox]::Show(
            "Error applying DNS settings:`n`n$_", 
            "Error", 
            [System.Windows.Forms.MessageBoxButtons]::OK, 
            [System.Windows.Forms.MessageBoxIcon]::Error
        )
        Update-Status -Message "Error applying settings" -Type "Error"
    }
})

$btnReset.Add_Click({
    if ($cmbAdapter.SelectedIndex -lt 0) {
        [System.Windows.Forms.MessageBox]::Show("Please select a network adapter", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
        return
    }
    
    $adapterName = $cmbAdapter.SelectedItem.ToString().Split(' - ')[0]
    
    $result = [System.Windows.Forms.MessageBox]::Show(
        "Reset DNS settings to automatic (DHCP) for $adapterName`?", 
        "Confirm", 
        [System.Windows.Forms.MessageBoxButtons]::YesNo, 
        [System.Windows.Forms.MessageBoxIcon]::Question
    )
    
    if ($result -eq [System.Windows.Forms.DialogResult]::No) { return }
    
    try {
        Set-DnsClientServerAddress -InterfaceAlias $adapterName -ResetServerAddresses
        netsh interface ipv6 set dnsservers "$adapterName" dhcp | Out-Null
        Clear-DnsClientCache
        
        Update-CurrentSettings
        
        [System.Windows.Forms.MessageBox]::Show(
            "DNS settings reset to automatic successfully!", 
            "Success", 
            [System.Windows.Forms.MessageBoxButtons]::OK, 
            [System.Windows.Forms.MessageBoxIcon]::Information
        )
        
        Update-Status -Message "DNS reset to automatic" -Type "Success"
    } catch {
        [System.Windows.Forms.MessageBox]::Show(
            "Error resetting DNS settings:`n`n$_", 
            "Error", 
            [System.Windows.Forms.MessageBoxButtons]::OK, 
            [System.Windows.Forms.MessageBoxIcon]::Error
        )
        Update-Status -Message "Error resetting DNS" -Type "Error"
    }
})

$btnTest.Add_Click({
    if ($cmbAdapter.SelectedIndex -lt 0) {
        [System.Windows.Forms.MessageBox]::Show("Please select a network adapter", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
        return
    }
    
    $adapterName = $cmbAdapter.SelectedItem.ToString().Split(' - ')[0]
    
    Update-Status -Message "Testing DNS servers..."
    
    try {
        $currentDNS = Get-DnsClientServerAddress -InterfaceAlias $adapterName -AddressFamily IPv4
        $testResults = ""
        
        if ($currentDNS.ServerAddresses.Count -eq 0) {
            $testResults = "No DNS servers configured (using automatic)`n"
        } else {
            foreach ($server in $currentDNS.ServerAddresses) {
                try {
                    $result = Resolve-DnsName -Name "google.com" -Server $server -ErrorAction Stop -QuickTimeout
                    $testResults += "[OK] $server - Working`n"
                } catch {
                    $testResults += "[FAIL] $server - Not responding`n"
                }
            }
        }
        
        # Test general connectivity
        $testResults += "`nGeneral DNS Resolution:`n"
        try {
            $result = Resolve-DnsName -Name "google.com" -ErrorAction Stop
            $testResults += "[OK] DNS resolution working`n"
            $testResults += "Resolved IPs: $($result.IPAddress -join ', ')`n"
        } catch {
            $testResults += "[FAIL] DNS resolution failed`n"
        }
        
        [System.Windows.Forms.MessageBox]::Show(
            $testResults, 
            "DNS Test Results", 
            [System.Windows.Forms.MessageBoxButtons]::OK, 
            [System.Windows.Forms.MessageBoxIcon]::Information
        )
        
        Update-Status -Message "DNS test completed" -Type "Success"
    } catch {
        [System.Windows.Forms.MessageBox]::Show(
            "Error testing DNS:`n`n$_", 
            "Error", 
            [System.Windows.Forms.MessageBoxButtons]::OK, 
            [System.Windows.Forms.MessageBoxIcon]::Error
        )
        Update-Status -Message "DNS test failed" -Type "Error"
    }
})

# Backup tab events
$btnRefreshBackups.Add_Click({
    Initialize-Backups
})

$dgvBackups.Add_SelectionChanged({
    if ($dgvBackups.SelectedRows.Count -gt 0) {
        $selectedRow = $dgvBackups.SelectedRows[0]
        $backupPath = $selectedRow.Cells["FilePath"].Value
        
        if (Test-Path $backupPath) {
            try {
                $content = Get-Content -Path $backupPath -Raw | ConvertFrom-Json
                
                $details = "Backup Date: $($content.Date)`r`n"
                $details += "Computer: $($content.ComputerName)`r`n"
                $details += "User: $($content.UserName)`r`n"
                $details += "Adapter: $($content.Adapter)`r`n"
                $details += "`r`nIPv4 Configuration:`r`n"
                $details += "  Provider: $($content.IPv4.Provider)`r`n"
                $details += "  Servers: $($content.IPv4.ServerAddresses -join ', ')`r`n"
                $details += "`r`nIPv6 Configuration:`r`n"
                $details += "  Provider: $($content.IPv6.Provider)`r`n"
                $details += "  Servers: $($content.IPv6.ServerAddresses -join ', ')"
                
                $txtBackupDetails.Text = $details
            } catch {
                $txtBackupDetails.Text = "Error reading backup file"
            }
        }
    }
})

$btnRestoreBackup.Add_Click({
    if ($dgvBackups.SelectedRows.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("Please select a backup to restore", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
        return
    }
    
    if ($cmbAdapter.SelectedIndex -lt 0) {
        [System.Windows.Forms.MessageBox]::Show("Please select a network adapter first", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
        $tabControl.SelectedIndex = 0
        return
    }
    
    $selectedRow = $dgvBackups.SelectedRows[0]
    $backupPath = $selectedRow.Cells["FilePath"].Value
    $adapterName = $cmbAdapter.SelectedItem.ToString().Split(' - ')[0]
    
    $result = [System.Windows.Forms.MessageBox]::Show(
        "Restore DNS settings from this backup?", 
        "Confirm Restore", 
        [System.Windows.Forms.MessageBoxButtons]::YesNo, 
        [System.Windows.Forms.MessageBoxIcon]::Question
    )
    
    if ($result -eq [System.Windows.Forms.DialogResult]::No) { return }
    
    try {
        $backup = Get-Content -Path $backupPath -Raw | ConvertFrom-Json
        
        # Restore IPv4
        if ($backup.IPv4.ServerAddresses.Count -gt 0) {
            Set-DnsClientServerAddress -InterfaceAlias $adapterName -ServerAddresses $backup.IPv4.ServerAddresses
        } else {
            Set-DnsClientServerAddress -InterfaceAlias $adapterName -ResetServerAddresses
        }
        
        # Restore IPv6
        if ($backup.IPv6.ServerAddresses.Count -gt 0) {
            netsh interface ipv6 set dnsservers "$adapterName" static $backup.IPv6.ServerAddresses[0] primary | Out-Null
            if ($backup.IPv6.ServerAddresses.Count -gt 1) {
                netsh interface ipv6 add dnsservers "$adapterName" $backup.IPv6.ServerAddresses[1] index=2 | Out-Null
            }
        } else {
            netsh interface ipv6 set dnsservers "$adapterName" dhcp | Out-Null
        }
        
        Clear-DnsClientCache
        
        [System.Windows.Forms.MessageBox]::Show(
            "DNS settings restored successfully!", 
            "Success", 
            [System.Windows.Forms.MessageBoxButtons]::OK, 
            [System.Windows.Forms.MessageBoxIcon]::Information
        )
        
        # Switch to config tab and update
        $tabControl.SelectedIndex = 0
        Update-CurrentSettings
        
        Update-Status -Message "Backup restored successfully" -Type "Success"
    } catch {
        [System.Windows.Forms.MessageBox]::Show(
            "Error restoring backup:`n`n$_", 
            "Error", 
            [System.Windows.Forms.MessageBoxButtons]::OK, 
            [System.Windows.Forms.MessageBoxIcon]::Error
        )
        Update-Status -Message "Restore failed" -Type "Error"
    }
})

$btnDeleteBackup.Add_Click({
    if ($dgvBackups.SelectedRows.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("Please select a backup to delete", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
        return
    }
    
    $selectedRow = $dgvBackups.SelectedRows[0]
    $backupPath = $selectedRow.Cells["FilePath"].Value
    
    $result = [System.Windows.Forms.MessageBox]::Show(
        "Delete this backup file?", 
        "Confirm Delete", 
        [System.Windows.Forms.MessageBoxButtons]::YesNo, 
        [System.Windows.Forms.MessageBoxIcon]::Warning
    )
    
    if ($result -eq [System.Windows.Forms.DialogResult]::No) { return }
    
    try {
        Remove-Item -Path $backupPath -Force
        
        # Also remove .txt file if exists
        $txtPath = $backupPath -replace '\.json$', '.txt'
        if (Test-Path $txtPath) {
            Remove-Item -Path $txtPath -Force
        }
        
        Initialize-Backups
        $txtBackupDetails.Clear()
        
        Update-Status -Message "Backup deleted" -Type "Success"
    } catch {
        [System.Windows.Forms.MessageBox]::Show(
            "Error deleting backup:`n`n$_", 
            "Error", 
            [System.Windows.Forms.MessageBoxButtons]::OK, 
            [System.Windows.Forms.MessageBoxIcon]::Error
        )
        Update-Status -Message "Delete failed" -Type "Error"
    }
})

# Diagnostics tab events
$btnPingTest.Add_Click({
    $txtDiagOutput.AppendText("`r`n=== PING TEST ===" + "`r`n")
    $txtDiagOutput.AppendText("Testing connectivity to 1.1.1.1..." + "`r`n")
    
    try {
        $result = Test-Connection -ComputerName "1.1.1.1" -Count 4 -ErrorAction Stop
        foreach ($reply in $result) {
            $txtDiagOutput.AppendText("Reply from $($reply.Address): time=$($reply.ResponseTime)ms" + "`r`n")
        }
        $txtDiagOutput.AppendText("Ping test completed successfully!" + "`r`n")
    } catch {
        $txtDiagOutput.AppendText("Ping test failed: $_" + "`r`n")
    }
    
    $txtDiagOutput.ScrollToCaret()
})

$btnDNSLookup.Add_Click({
    Add-Type -AssemblyName Microsoft.VisualBasic
    $domain = [Microsoft.VisualBasic.Interaction]::InputBox("Enter domain to lookup:", "DNS Lookup", "google.com")
    
    if ([string]::IsNullOrWhiteSpace($domain)) { return }
    
    $txtDiagOutput.AppendText("`r`n=== DNS LOOKUP ===" + "`r`n")
    $txtDiagOutput.AppendText("Looking up: $domain" + "`r`n")
    
    try {
        $result = Resolve-DnsName -Name $domain -ErrorAction Stop
        foreach ($record in $result) {
            $txtDiagOutput.AppendText("Type: $($record.Type), Address: $($record.IPAddress)" + "`r`n")
        }
    } catch {
        $txtDiagOutput.AppendText("DNS lookup failed: $_" + "`r`n")
    }
    
    $txtDiagOutput.ScrollToCaret()
})

$btnFlushDNS.Add_Click({
    $txtDiagOutput.AppendText("`r`n=== FLUSH DNS CACHE ===" + "`r`n")
    
    try {
        Clear-DnsClientCache
        ipconfig /flushdns | Out-Null
        $txtDiagOutput.AppendText("DNS cache cleared successfully!" + "`r`n")
    } catch {
        $txtDiagOutput.AppendText("Failed to flush DNS cache: $_" + "`r`n")
    }
    
    $txtDiagOutput.ScrollToCaret()
})

$btnIPConfig.Add_Click({
    $txtDiagOutput.AppendText("`r`n=== IP CONFIGURATION ===" + "`r`n")
    
    try {
        $config = ipconfig /all
        $txtDiagOutput.AppendText($config -join "`r`n")
    } catch {
        $txtDiagOutput.AppendText("Failed to get IP configuration: $_" + "`r`n")
    }
    
    $txtDiagOutput.ScrollToCaret()
})

$btnClearOutput.Add_Click({
    $txtDiagOutput.Clear()
})

# Form load event
$form.Add_Load({
    # Check for admin rights
    if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
        [System.Windows.Forms.MessageBox]::Show(
            "This application requires Administrator privileges.`nPlease run as Administrator.", 
            "Administrator Required", 
            [System.Windows.Forms.MessageBoxButtons]::OK, 
            [System.Windows.Forms.MessageBoxIcon]::Error
        )
        $form.Close()
        return
    }
    
    Initialize-NetworkAdapters
    Initialize-DNSProviders
    Initialize-Backups
    Update-Status -Message "Application loaded successfully" -Type "Success"
})

# Show the form
[System.Windows.Forms.Application]::Run($form)
