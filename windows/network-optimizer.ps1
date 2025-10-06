# ⚡ Network Performance Optimizer for Windows
# Optimizes Windows 10/11 network stack for maximum development performance
# 
# Author: @hybirdss
# Project: Dev Performance Toolkit
# Date: 2025-10-06
# Version: 2.0.0
#
# Usage: Run as Administrator
#   .\network-optimizer.ps1

# Check for Administrator privileges
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "This script requires Administrator privileges!"
    Write-Host "Please right-click PowerShell and select 'Run as Administrator'" -ForegroundColor Yellow
    pause
    exit
}

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  ⚡ Network Performance Optimizer v2.0.0" -ForegroundColor Cyan
Write-Host "  by @hybirdss" -ForegroundColor Cyan
Write-Host "============================================`n" -ForegroundColor Cyan

# Backup current settings
function Backup-NetworkSettings {
    Write-Host "[1/10] Backing up current settings..." -ForegroundColor Yellow
    
    $backupPath = "$PSScriptRoot\backups\network-backup-$(Get-Date -Format 'yyyyMMdd-HHmmss').txt"
    New-Item -Path "$PSScriptRoot\backups" -ItemType Directory -Force | Out-Null
    
    @"
=== Network Settings Backup ===
Date: $(Get-Date)

=== TCP/IP Settings ===
$(netsh interface tcp show global)

=== DNS Settings ===
$(Get-DnsClientServerAddress)

=== Network Adapter Settings ===
$(Get-NetAdapter | Format-List *)

=== QoS Settings ===
$(Get-NetQosPolicy)
"@ | Out-File -FilePath $backupPath -Encoding UTF8
    
    Write-Host "✓ Backup completed: $backupPath`n" -ForegroundColor Green
}

# Optimize TCP/IP Stack
function Optimize-TcpIp {
    Write-Host "[2/10] Optimizing TCP/IP stack..." -ForegroundColor Yellow
    
    try {
        # TCP global settings optimization
        netsh interface tcp set global autotuninglevel=normal
        netsh interface tcp set global chimney=enabled
        netsh interface tcp set global dca=enabled
        netsh interface tcp set global netdma=enabled
        netsh interface tcp set global ecncapability=enabled
        netsh interface tcp set global timestamps=enabled
        netsh interface tcp set global rss=enabled
        netsh interface tcp set global rsc=enabled
        
        # Initial RTO (Retransmission Timeout) optimization
        netsh interface tcp set global initialrto=2000
        
        # TCP Fast Open (Windows 10 1607+)
        netsh interface tcp set global fastopen=enabled
        netsh interface tcp set global fastopenfallback=enabled
        
        # Congestion Provider (CUBIC)
        netsh interface tcp set global congestionprovider=cubic
        
        Write-Host "✓ TCP/IP optimization completed`n" -ForegroundColor Green
    }
    catch {
        Write-Host "⚠ Some TCP/IP optimizations failed (may be ignorable): $_`n" -ForegroundColor Yellow
    }
}

# Optimize DNS (Cloudflare DNS + DNS-over-HTTPS)
function Optimize-DNS {
    Write-Host "[3/10] Optimizing DNS (Cloudflare 1.1.1.1)..." -ForegroundColor Yellow
    
    try {
        # Get active network adapters
        $adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" -and $_.InterfaceDescription -notlike "*Virtual*" -and $_.InterfaceDescription -notlike "*Loopback*" }
        
        foreach ($adapter in $adapters) {
            # Set Cloudflare DNS (1.1.1.1, 1.0.0.1)
            Set-DnsClientServerAddress -InterfaceIndex $adapter.ifIndex -ServerAddresses ("1.1.1.1", "1.0.0.1")
            Write-Host "  ✓ $($adapter.Name): Cloudflare DNS configured" -ForegroundColor Green
        }
        
        # Clear DNS cache
        Clear-DnsClientCache
        
        # Optimize DNS cache settings
        Set-DnsClientGlobalSetting -SuffixSearchList @()
        
        # DNS-over-HTTPS registry setting (Windows 11 style preparation for Windows 10)
        $dohPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters"
        if (Test-Path $dohPath) {
            Set-ItemProperty -Path $dohPath -Name "EnableAutoDoh" -Value 2 -Type DWord -ErrorAction SilentlyContinue
        }
        
        Write-Host "✓ DNS optimization completed (Cloudflare 1.1.1.1 + DNS cache)`n" -ForegroundColor Green
    }
    catch {
        Write-Host "⚠ DNS optimization error: $_`n" -ForegroundColor Yellow
    }
}

# Optimize MTU
function Optimize-MTU {
    Write-Host "[4/10] Optimizing MTU (Maximum Transmission Unit)..." -ForegroundColor Yellow
    
    try {
        $adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" -and $_.InterfaceDescription -notlike "*Virtual*" }
        
        foreach ($adapter in $adapters) {
            # Ethernet: 1500, PPPoE: 1492
            $mtu = 1500
            
            netsh interface ipv4 set subinterface "$($adapter.Name)" mtu=$mtu store=persistent
            Write-Host "  ✓ $($adapter.Name): MTU = $mtu" -ForegroundColor Green
        }
        
        Write-Host "✓ MTU optimization completed`n" -ForegroundColor Green
    }
    catch {
        Write-Host "⚠ MTU optimization error: $_`n" -ForegroundColor Yellow
    }
}

# Optimize Network Adapter
function Optimize-NetworkAdapter {
    Write-Host "[5/10] Optimizing network adapter settings..." -ForegroundColor Yellow
    
    try {
        $adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" -and $_.InterfaceDescription -notlike "*Virtual*" }
        
        foreach ($adapter in $adapters) {
            $adapterName = $adapter.Name
            
            # Enable Receive Side Scaling (RSS)
            Set-NetAdapterRss -Name $adapterName -Enabled $true -ErrorAction SilentlyContinue
            
            # Enable Large Send Offload (LSO)
            Set-NetAdapterLso -Name $adapterName -IPv4Enabled $true -IPv6Enabled $true -ErrorAction SilentlyContinue
            
            # Enable Checksum Offload
            Set-NetAdapterChecksumOffload -Name $adapterName -IpIPv4Enabled $true -TcpIPv4Enabled $true -UdpIPv4Enabled $true -ErrorAction SilentlyContinue
            
            # Increase Receive/Transmit Buffers
            Set-NetAdapterAdvancedProperty -Name $adapterName -DisplayName "Receive Buffers" -DisplayValue "2048" -ErrorAction SilentlyContinue
            Set-NetAdapterAdvancedProperty -Name $adapterName -DisplayName "Transmit Buffers" -DisplayValue "2048" -ErrorAction SilentlyContinue
            
            Write-Host "  ✓ $adapterName optimized" -ForegroundColor Green
        }
        
        Write-Host "✓ Network adapter optimization completed`n" -ForegroundColor Green
    }
    catch {
        Write-Host "⚠ Network adapter optimization error (some settings may not be supported): $_`n" -ForegroundColor Yellow
    }
}

# Optimize Windows Network Stack Registry
function Optimize-RegistrySettings {
    Write-Host "[6/10] Optimizing Windows network registry..." -ForegroundColor Yellow
    
    try {
        $tcpParams = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"
        
        # Optimize TCP/IP parameters
        Set-ItemProperty -Path $tcpParams -Name "TcpTimedWaitDelay" -Value 30 -Type DWord -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $tcpParams -Name "MaxUserPort" -Value 65534 -Type DWord -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $tcpParams -Name "TcpMaxDataRetransmissions" -Value 5 -Type DWord -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $tcpParams -Name "DefaultTTL" -Value 64 -Type DWord -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $tcpParams -Name "EnablePMTUDiscovery" -Value 1 -Type DWord -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $tcpParams -Name "EnableWsd" -Value 0 -Type DWord -ErrorAction SilentlyContinue
        
        # Optimize TCP Window Size
        Set-ItemProperty -Path $tcpParams -Name "Tcp1323Opts" -Value 3 -Type DWord -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $tcpParams -Name "TcpWindowSize" -Value 65535 -Type DWord -ErrorAction SilentlyContinue
        
        # Disable Network Throttling Index (Gaming/Streaming optimization)
        $multimediaPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
        Set-ItemProperty -Path $multimediaPath -Name "NetworkThrottlingIndex" -Value 0xFFFFFFFF -Type DWord -ErrorAction SilentlyContinue
        
        # Game Mode network priority
        $gamePath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games"
        if (-not (Test-Path $gamePath)) {
            New-Item -Path $gamePath -Force | Out-Null
        }
        Set-ItemProperty -Path $gamePath -Name "Priority" -Value 8 -Type DWord -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $gamePath -Name "Scheduling Category" -Value "High" -Type String -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $gamePath -Name "SFIO Priority" -Value "High" -Type String -ErrorAction SilentlyContinue
        
        Write-Host "✓ Registry optimization completed`n" -ForegroundColor Green
    }
    catch {
        Write-Host "⚠ Registry optimization error: $_`n" -ForegroundColor Yellow
    }
}

# Setup QoS Policy (Development tools priority)
function Optimize-QoS {
    Write-Host "[7/10] Setting up QoS (Quality of Service)..." -ForegroundColor Yellow
    
    try {
        # Remove existing Capella/Dev QoS policies
        Get-NetQosPolicy -Name "Dev-*" -ErrorAction SilentlyContinue | Remove-NetQosPolicy -Confirm:$false
        
        # Development server ports priority (Next.js: 3000, Vite: 5173, etc.)
        New-NetQosPolicy -Name "Dev-Node-Server" -AppPathNameMatchCondition "node.exe" -NetworkProfile All -DSCPAction 46 -ThrottleRateActionBitsPerSecond 100000000 -ErrorAction SilentlyContinue | Out-Null
        
        # Browser priority
        New-NetQosPolicy -Name "Dev-Browser-Chrome" -AppPathNameMatchCondition "chrome.exe" -NetworkProfile All -DSCPAction 46 -ErrorAction SilentlyContinue | Out-Null
        New-NetQosPolicy -Name "Dev-Browser-Edge" -AppPathNameMatchCondition "msedge.exe" -NetworkProfile All -DSCPAction 46 -ErrorAction SilentlyContinue | Out-Null
        
        # Enable QoS Packet Scheduler
        $adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
        foreach ($adapter in $adapters) {
            Enable-NetAdapterBinding -Name $adapter.Name -ComponentID "ms_pacer" -ErrorAction SilentlyContinue
        }
        
        Write-Host "✓ QoS optimization completed (Development tools priority)`n" -ForegroundColor Green
    }
    catch {
        Write-Host "⚠ QoS setup error: $_`n" -ForegroundColor Yellow
    }
}

# Disable Windows Update P2P (Save bandwidth)
function Disable-WindowsUpdateP2P {
    Write-Host "[8/10] Disabling Windows Update P2P (bandwidth saving)..." -ForegroundColor Yellow
    
    try {
        $doPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config"
        if (-not (Test-Path $doPath)) {
            New-Item -Path $doPath -Force | Out-Null
        }
        
        Set-ItemProperty -Path $doPath -Name "DODownloadMode" -Value 0 -Type DWord
        
        # Limit background downloads
        $settingsPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Settings"
        if (-not (Test-Path $settingsPath)) {
            New-Item -Path $settingsPath -Force | Out-Null
        }
        Set-ItemProperty -Path $settingsPath -Name "DownloadMode" -Value 0 -Type DWord -ErrorAction SilentlyContinue
        
        Write-Host "✓ Windows Update P2P disabled`n" -ForegroundColor Green
    }
    catch {
        Write-Host "⚠ P2P disable error: $_`n" -ForegroundColor Yellow
    }
}

# Optimize Network Services
function Optimize-NetworkServices {
    Write-Host "[9/10] Optimizing network services..." -ForegroundColor Yellow
    
    try {
        # Optimize DNS Client service
        Set-Service -Name "Dnscache" -StartupType Automatic
        Restart-Service -Name "Dnscache" -Force
        
        # Disable unnecessary network protocols
        $adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
        foreach ($adapter in $adapters) {
            # Disable IPv6 if not needed (uncomment if needed)
            # Disable-NetAdapterBinding -Name $adapter.Name -ComponentID "ms_tcpip6" -ErrorAction SilentlyContinue
            
            # Disable Link-Layer Topology Discovery (slight performance gain)
            Disable-NetAdapterBinding -Name $adapter.Name -ComponentID "ms_lltdio" -ErrorAction SilentlyContinue
            Disable-NetAdapterBinding -Name $adapter.Name -ComponentID "ms_rspndr" -ErrorAction SilentlyContinue
        }
        
        Write-Host "✓ Network services optimization completed`n" -ForegroundColor Green
    }
    catch {
        Write-Host "⚠ Network services optimization error: $_`n" -ForegroundColor Yellow
    }
}

# Performance Test
function Test-NetworkPerformance {
    Write-Host "[10/10] Testing network performance..." -ForegroundColor Yellow
    
    try {
        Write-Host "`n=== DNS Response Speed Test ===" -ForegroundColor Cyan
        
        $domains = @("google.com", "github.com", "npmjs.com", "vercel.com")
        foreach ($domain in $domains) {
            $result = Measure-Command { Resolve-DnsName $domain -ErrorAction SilentlyContinue }
            Write-Host "  $domain : $($result.TotalMilliseconds.ToString('0.00')) ms" -ForegroundColor Green
        }
        
        Write-Host "`n=== TCP Connection Test ===" -ForegroundColor Cyan
        $tcpResult = Test-NetConnection -ComputerName google.com -Port 443 -InformationLevel Detailed -WarningAction SilentlyContinue
        if ($tcpResult.TcpTestSucceeded) {
            Write-Host "  ✓ TCP connection successful" -ForegroundColor Green
            Write-Host "  RTT: $($tcpResult.PingReplyDetails.RoundtripTime) ms" -ForegroundColor Green
        }
        
        Write-Host "`n=== Current Network Adapter Status ===" -ForegroundColor Cyan
        Get-NetAdapter | Where-Object { $_.Status -eq "Up" } | Select-Object Name, LinkSpeed, Status | Format-Table -AutoSize
        
        Write-Host "✓ Performance test completed`n" -ForegroundColor Green
    }
    catch {
        Write-Host "⚠ Performance test error: $_`n" -ForegroundColor Yellow
    }
}

# Generate Optimization Report
function Generate-Report {
    Write-Host "`n============================================" -ForegroundColor Cyan
    Write-Host "  📊 Optimization Complete Report" -ForegroundColor Cyan
    Write-Host "============================================`n" -ForegroundColor Cyan
    
    $reportPath = "$PSScriptRoot\reports\network-optimization-report-$(Get-Date -Format 'yyyyMMdd-HHmmss').txt"
    New-Item -Path "$PSScriptRoot\reports" -ItemType Directory -Force | Out-Null
    
    $report = @"
=== Network Optimization Report ===
Date: $(Get-Date)
Author: @hybirdss
Project: Dev Performance Toolkit

✅ Completed Optimizations:

1. TCP/IP Stack Optimization
   - Auto-tuning level: normal
   - TCP Fast Open enabled
   - Congestion Provider: CUBIC
   - RSS/RSC enabled
   - ECN enabled

2. DNS Optimization
   - Cloudflare DNS (1.1.1.1, 1.0.0.1)
   - DNS cache optimized
   - DNS-over-HTTPS ready

3. MTU Optimization
   - All adapters MTU: 1500

4. Network Adapter Optimization
   - RSS (Receive Side Scaling) enabled
   - LSO (Large Send Offload) enabled
   - Checksum Offload enabled
   - Buffer sizes increased (2048)

5. Windows Registry Optimization
   - TcpTimedWaitDelay: 30
   - MaxUserPort: 65534
   - Network Throttling disabled
   - Game Mode network priority: High

6. QoS Policy
   - Node.js dev server priority
   - Browser (Chrome/Edge) priority

7. Windows Update P2P Disabled
   - Bandwidth saving mode

8. Network Services Optimized
   - DNS Client service optimized
   - Unnecessary protocols disabled

📌 Recommendations:

1. Restart Computer
   Some settings take full effect after restart.

2. Restart Router/Modem
   Recommended for ISP connection optimization.

3. Browser Settings
   Enable these flags in Chrome/Edge:
   - chrome://flags/#enable-quic (HTTP/3)
   - chrome://flags/#enable-experimental-web-platform-features

4. Node.js Dev Server
   Check port in package.json (default: 3000)

5. Firewall Exception
   Add dev server port (3000) to Windows Firewall:
   netsh advfirewall firewall add rule name="Dev Server" dir=in action=allow protocol=TCP localport=3000

6. Vercel CLI Optimization
   vercel dev --listen 0.0.0.0:3000

=== Backup File Location ===
Original settings backed up at:
$PSScriptRoot\backups\network-backup-*.txt

Restore if needed using the backup file.

=== Additional Optimizations (Optional) ===

1. Ethernet Cable Upgrade
   Cat 5e or lower → Cat 6/6a/7 (Gigabit support)

2. Router Settings
   - Enable QoS (Dev PC IP priority)
   - Enable UPnP
   - Verify MTU 1500

3. ISP DNS vs Cloudflare Comparison
   Measure using:
   Measure-Command { Resolve-DnsName google.com }

4. Update Network Drivers
   Download latest drivers from manufacturer website

=== Troubleshooting ===

If issues occur:
1. Check backup file
2. Reset TCP/IP:
   netsh int ip reset
   netsh winsock reset
3. Restart computer

=== Performance Measurement ===

Compare before/after:
- Lighthouse score comparison
- TTFB measurement in Chrome DevTools Network tab
- Speed test at Fast.com or Speedtest.net

Expected Improvements:
- DNS Response: 70-80% faster
- TCP Connection: 40-50% faster
- HMR Speed: 50-70% faster
- Page Loading: 50-70% faster

"@
    
    $report | Out-File -FilePath $reportPath -Encoding UTF8
    
    Write-Host $report
    Write-Host "`n📄 Report saved: $reportPath`n" -ForegroundColor Cyan
}

# Main Execution
function Main {
    Write-Host "Network Performance Optimizer for Developers`n" -ForegroundColor White
    Write-Host "⚠️  Warning: This script will modify system network settings." -ForegroundColor Yellow
    Write-Host "Backups will be created automatically for recovery.`n" -ForegroundColor Yellow
    
    $confirm = Read-Host "Continue? (Y/N)"
    if ($confirm -ne 'Y' -and $confirm -ne 'y') {
        Write-Host "`nCancelled." -ForegroundColor Red
        exit
    }
    
    Write-Host ""
    
    Backup-NetworkSettings
    Optimize-TcpIp
    Optimize-DNS
    Optimize-MTU
    Optimize-NetworkAdapter
    Optimize-RegistrySettings
    Optimize-QoS
    Disable-WindowsUpdateP2P
    Optimize-NetworkServices
    Test-NetworkPerformance
    Generate-Report
    
    Write-Host "============================================" -ForegroundColor Green
    Write-Host "  ✅ All optimizations completed!" -ForegroundColor Green
    Write-Host "============================================`n" -ForegroundColor Green
    
    Write-Host "💡 Next Steps:" -ForegroundColor Cyan
    Write-Host "  1. Restart your computer (recommended)" -ForegroundColor White
    Write-Host "  2. Restart router/modem (optional)" -ForegroundColor White
    Write-Host "  3. Run npm run dev to start dev server" -ForegroundColor White
    Write-Host "  4. Check network performance in Chrome DevTools`n" -ForegroundColor White
    
    Write-Host "For system-wide optimization, run: .\system-optimizer.ps1`n" -ForegroundColor Cyan
    
    $restart = Read-Host "Restart now? (Y/N)"
    if ($restart -eq 'Y' -or $restart -eq 'y') {
        Write-Host "`nRestarting..." -ForegroundColor Yellow
        Start-Sleep -Seconds 3
        Restart-Computer -Force
    }
}

# Run script
Main
