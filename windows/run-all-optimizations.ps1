# 🚀 Run All Optimizations - Windows
# Executes all optimization scripts in sequence
# 
# Author: @hybirdss
# Project: Dev Performance Toolkit
# Version: 2.0.0

# Check for Administrator privileges
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "This script requires Administrator privileges!"
    Write-Host "Please right-click PowerShell and select 'Run as Administrator'" -ForegroundColor Yellow
    pause
    exit
}

Write-Host "============================================" -ForegroundColor Magenta
Write-Host "  🚀 Dev Performance Toolkit v2.0.0" -ForegroundColor Magenta
Write-Host "  All-in-One Optimization Suite" -ForegroundColor Magenta
Write-Host "  by @hybirdss" -ForegroundColor Magenta
Write-Host "============================================`n" -ForegroundColor Magenta

$scripts = @(
    @{Name="Network Optimizer"; File="network-optimizer.ps1"; Time=5},
    @{Name="System Optimizer"; File="system-optimizer.ps1"; Time=8}
)

$totalTime = ($scripts | Measure-Object -Property Time -Sum).Sum

Write-Host "This will run the following optimizations:`n" -ForegroundColor White

foreach ($script in $scripts) {
    Write-Host "  ✓ $($script.Name) (~$($script.Time) min)" -ForegroundColor Cyan
}

Write-Host "`nEstimated total time: ~$totalTime minutes`n" -ForegroundColor Yellow

$confirm = Read-Host "Continue with all optimizations? (Y/N)"
if ($confirm -ne 'Y' -and $confirm -ne 'y') {
    Write-Host "`nCancelled." -ForegroundColor Red
    exit
}

Write-Host ""

# Execute each script
$completed = 0
foreach ($script in $scripts) {
    $completed++
    Write-Host "`n[$completed/$($scripts.Count)] Running $($script.Name)..." -ForegroundColor Green
    Write-Host "=" * 50 -ForegroundColor Green
    
    try {
        & ".\$($script.File)"
    }
    catch {
        Write-Host "`n⚠ Error running $($script.Name): $_" -ForegroundColor Red
        Write-Host "Continuing with next optimization...`n" -ForegroundColor Yellow
    }
}

Write-Host "`n`n" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host "  ✅ ALL OPTIMIZATIONS COMPLETED!" -ForegroundColor Green
Write-Host "============================================`n" -ForegroundColor Green

Write-Host "📊 Summary:" -ForegroundColor Cyan
Write-Host "  • Network optimization: ✓" -ForegroundColor Green
Write-Host "  • System optimization: ✓" -ForegroundColor Green
Write-Host "`n📌 IMPORTANT: Restart your computer for all changes to take effect!`n" -ForegroundColor Yellow

$restart = Read-Host "Restart now? (Y/N)"
if ($restart -eq 'Y' -or $restart -eq 'y') {
    Write-Host "`nRestarting in 10 seconds... (Ctrl+C to cancel)" -ForegroundColor Yellow
    Start-Sleep -Seconds 10
    Restart-Computer -Force
}
else {
    Write-Host "`nPlease restart manually when convenient." -ForegroundColor Cyan
}
