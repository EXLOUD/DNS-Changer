<div align="center">

### 🔽

[![Download My Script](https://img.shields.io/badge/Download_This_Script-darkgreen?style=for-the-badge&logo=powershell&logoColor=white)](https://github.com/EXLOUD/DNS-Changer/archive/refs/heads/main.zip)

---

# Universal DNS Configurator

### 👀 Repository Views

<img alt="count" src="https://count.getloli.com/get/@:EXLOUD-DNS-Configurator?theme=rule34" />

**⭐ If this tool helped you, please consider giving it a star! ⭐**

---

<img src="assets/preview.gif" alt="DNS Changer by EXLOUD aka BOBER" width="600" height="400">

![License](http://www.wtfpl.net/download/wtfpl-badge-3/)
![PowerShell](https://img.shields.io/badge/PowerShell-5%2B-blue.svg)
![Windows](https://img.shields.io/badge/Windows-7%2F8%2F10%2F11-blue.svg)
![DNS](https://img.shields.io/badge/DNS-Universal-orange.svg)

A comprehensive PowerShell-based DNS configuration tool with interactive network adapter and DNS provider selection. Supports all Windows versions and provides easy switching between popular DNS services.

</div>

## 🚀 Features

- **Universal Windows support**: Works with Windows 7, 8, 10, and 11
- **Interactive adapter selection**: Choose from all active network adapters
- **Multiple DNS providers**: 12+ pre-configured DNS services
- **Current settings display**: Shows active DNS configuration and provider identification
- **Automatic elevation**: Requests administrator privileges when needed
- **PowerShell version detection**: Supports PowerShell 5.1, 7, and 7 Preview
- **DNS cache clearing**: Automatically flushes DNS cache after changes
- **Provider identification**: Automatically identifies current DNS provider
- **Safe execution**: Comprehensive error handling and validation

## 🌐 Supported DNS Providers

### Security & Privacy Focused
| Provider | Primary | Secondary | Features |
|----------|---------|-----------|----------|
| **Cloudflare DNS** | 1.1.1.1 | 1.0.0.1 | Fast, Privacy-focused |
| **Quad9 DNS** | 9.9.9.9 | 149.112.112.112 | Malware blocking |
| **AdGuard DNS** | 94.140.14.14 | 94.140.15.15 | Ad blocking |
| **NextDNS** | 45.90.28.167 | 45.90.30.167 | Customizable filtering |

### Family & Content Filtering
| Provider | Primary | Secondary | Features |
|----------|---------|-----------|----------|
| **CleanBrowsing (Family)** | 185.228.168.168 | 185.228.169.168 | Family-safe filtering |
| **CleanBrowsing (Adult)** | 185.228.168.10 | 185.228.169.11 | Adult content filtering |
| **CleanBrowsing (Security)** | 185.228.168.9 | 185.228.169.9 | Malware protection |
| **OpenDNS** | 208.67.222.222 | 208.67.220.220 | Parental controls |

### Traditional & Performance
| Provider | Primary | Secondary | Features |
|----------|---------|-----------|----------|
| **Google DNS** | 8.8.8.8 | 8.8.4.4 | Fast, Reliable |
| **Control D** | 76.76.19.19 | 76.76.2.22 | Custom filtering |
| **Comodo Secure DNS** | 8.26.56.26 | 8.20.247.20 | Security focused |

## 🛠️ Installation & Usage

### Method 1: Using the Launcher (Recommended)
1. Download both files:
   - `Launcher.bat` (Automatic elevation and PowerShell detection)
   - `dns_changer.ps1` (Main DNS configuration script)
2. Place both files in the same directory
3. **Double-click** on `Launcher.bat` or **Right-click** and select "Run as administrator"
4. The launcher will automatically:
   - Request administrator privileges
   - Detect best PowerShell version
   - Launch the DNS configurator
5. Follow the interactive prompts

### Method 2: Direct PowerShell Execution
1. Download `dns_changer.ps1`
2. Open PowerShell **as Administrator**
3. Navigate to the script directory
4. Run: `Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process`
5. Execute: `.\dns_changer.ps1`

## 🎯 How It Works

### Step 1: Network Adapter Selection
- Displays all active network adapters
- Shows adapter names and descriptions
- Allows selection of specific adapter to configure

### Step 2: Current DNS Display
- Shows current DNS provider (automatically identified)
- Displays current DNS server addresses
- Indicates if using automatic (DHCP) configuration

### Step 3: DNS Provider Selection
- Lists all available DNS providers
- Shows primary and secondary DNS addresses
- Option to reset to automatic (DHCP)

### Step 4: Configuration Applied
- Sets new DNS servers on selected adapter
- Clears DNS cache for immediate effect
- Displays new configuration for verification

## 🔧 Technical Requirements

- **Operating System**: Windows 7, 8, 10, or 11
- **PowerShell**: Version 5.1 or higher (automatically detected)
- **Privileges**: Administrator rights (automatically requested)
- **Network**: At least one active network adapter
- **Dependencies**: Native Windows PowerShell cmdlets only

## 🤖 Automatic Features

### PowerShell Version Detection
The launcher automatically detects and uses the best available PowerShell:
1. **PowerShell 7 Preview** (modern features)
2. **PowerShell 7** (modern features)
3. **PowerShell 5.1** (Windows PowerShell - fallback)

### DNS Provider Identification
Automatically identifies current DNS provider by comparing server addresses:
- Exact matches for popular providers
- Partial matches when only one server configured
- Custom DNS detection for unknown configurations

### Administrator Privilege Management
- Checks current privileges before execution
- Automatically requests elevation if needed
- Uses best available PowerShell for elevation

## 📸 Interface Overview

### Main Menu Interface
```
=== Select Network Adapter ===
1. Ethernet (Realtek PCIe GBE Family Controller)
2. Wi-Fi (Intel(R) Wi-Fi 6 AX201 160MHz)

0. Exit
```

### Current DNS Display
```
=== Current DNS Settings ===
Adapter: Ethernet
DNS Provider: Google DNS
DNS Servers: 8.8.8.8, 8.8.4.4
```

### DNS Provider Selection
```
=== Select DNS Provider ===
1. AdGuard DNS
2. CleanBrowsing (Adult)
3. CleanBrowsing (Family)
4. CleanBrowsing (Security)
5. Cloudflare DNS
6. Comodo Secure DNS
7. Control D
8. Google DNS
9. NextDNS
10. OpenDNS
11. Quad9 DNS
12. Restore Automatic DNS

n. Reset to Automatic (DHCP)
0. Exit
```

## 🛡️ Safety Features

- **Input validation**: Robust input parsing and validation
- **Error handling**: Comprehensive error catching and reporting
- **Automatic DNS cache clearing**: Ensures changes take effect immediately
- **Non-destructive**: Only modifies DNS settings, no system changes
- **Reversible changes**: Easy restoration to automatic (DHCP) settings
- **Privilege checking**: Prevents execution without proper rights

## 🔄 DNS Provider Benefits

### For Privacy
- **Cloudflare (1.1.1.1)**: No logging, fastest DNS
- **Quad9**: Blocks malicious domains
- **AdGuard**: Blocks ads and trackers

### For Families
- **CleanBrowsing Family**: Filters adult content
- **OpenDNS**: Customizable parental controls

### For Performance
- **Google DNS**: Global infrastructure
- **Cloudflare**: Fastest response times globally

### For Security
- **Quad9**: Threat intelligence blocking
- **Comodo Secure DNS**: Real-time protection

## 🚨 Important Notes

1. **Administrator Rights**: Required for modifying network adapter settings
2. **Network Impact**: Changes take effect immediately
3. **Cache Clearing**: DNS cache is automatically flushed
4. **Backup**: Current settings are displayed before changes
5. **Restoration**: Easy restoration to automatic/DHCP settings

## 📄 What happens after configuration?

After successful execution:
- DNS servers are changed on selected adapter
- DNS cache is cleared for immediate effect
- New DNS provider is active
- Network applications will use new DNS servers
- Changes persist until manually changed or reset

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

### Development Guidelines
- Use PowerShell best practices
- Maintain cross-Windows compatibility
- Include comprehensive error handling
- Follow the existing code structure
- Test on multiple Windows versions

## 📜 License

This project is licensed under the WTFPL - see the [LICENSE](LICENSE) file for details.

## ⚠️ Disclaimer

This script modifies network DNS settings. While designed to be safe, use at your own risk. DNS changes affect internet connectivity. The authors are not responsible for any network connectivity issues.

## 🙏 Acknowledgments

- Microsoft for PowerShell and networking cmdlets
- DNS providers for offering public DNS services
- Community feedback for feature improvements

## 📞 Support

If you encounter any issues:
1. Check the [Issues](../../issues) section
2. Ensure you're running as Administrator
3. Verify your network adapter is active
4. Check PowerShell version compatibility
5. Review console output for specific error messages
6. Try using the launcher for automatic setup

### Common Solutions
- **"Script requires administrator rights"**: Use the launcher or run PowerShell as Administrator
- **"No active network adapters found"**: Enable your network adapter
- **"PowerShell execution policy"**: The launcher handles this automatically

---

<div align="center">

**Made with ❤️ by [EXLOUD](https://github.com/EXLOUD)**

*Simplifying DNS configuration across all Windows versions, one click at a time.*

</div>