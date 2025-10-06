#Requires -Version 5.1
#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Git PATH 환경변수 설정 도구
    
.DESCRIPTION
    Git 설치 위치를 찾아서 시스템 환경변수에 자동으로 추가합니다.
#>

$ErrorActionPreference = "Stop"

Write-Host "`n╔════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  🔧 Git PATH 환경변수 자동 설정 도구        ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# 관리자 권한 확인
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "❌ 이 스크립트는 관리자 권한이 필요합니다!" -ForegroundColor Red
    Write-Host ""
    Write-Host "우클릭 → '관리자 권한으로 실행'으로 PowerShell을 다시 실행하세요" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "또는 다음 명령을 실행:" -ForegroundColor Yellow
    Write-Host "  Start-Process powershell -Verb RunAs -ArgumentList `"-File `"`"$PSCommandPath`"`"`"" -ForegroundColor White
    exit 1
}

Write-Host "✅ 관리자 권한 확인 완료" -ForegroundColor Green
Write-Host ""

# Git 설치 위치 검색
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
Write-Host "🔍 [1/4] Git 설치 위치 검색 중..." -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
Write-Host ""

$possiblePaths = @(
    "C:\Program Files\Git",
    "C:\Program Files (x86)\Git",
    "$env:LOCALAPPDATA\Programs\Git",
    "$env:USERPROFILE\AppData\Local\Programs\Git",
    "C:\Git",
    "D:\Program Files\Git",
    "E:\Program Files\Git"
)

$gitPath = $null

foreach ($path in $possiblePaths) {
    Write-Host "  검색 중: $path" -ForegroundColor Gray
    if (Test-Path "$path\cmd\git.exe") {
        $gitPath = $path
        Write-Host "  ✅ Git 발견!" -ForegroundColor Green
        break
    }
}

if (-not $gitPath) {
    Write-Host ""
    Write-Host "❌ Git을 자동으로 찾을 수 없습니다!" -ForegroundColor Red
    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
    Write-Host "💡 수동 설치 경로 입력" -ForegroundColor Yellow
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Git 설치 경로를 입력하세요 (예: C:\Program Files\Git)" -ForegroundColor White
    Write-Host "또는 Enter를 눌러 Git 재설치 안내를 확인하세요" -ForegroundColor Gray
    Write-Host ""
    $manualPath = Read-Host "Git 설치 경로"
    
    if ([string]::IsNullOrWhiteSpace($manualPath)) {
        Write-Host ""
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
        Write-Host "📥 Git 재설치 안내" -ForegroundColor Magenta
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
        Write-Host ""
        Write-Host "1. Git 다운로드:" -ForegroundColor White
        Write-Host "   👉 https://git-scm.com/download/win" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "2. 설치 시 중요 옵션:" -ForegroundColor White
        Write-Host "   ✅ 'Git from the command line and also from 3rd-party software'" -ForegroundColor Green
        Write-Host "   ✅ 기본 설치 경로 사용 (C:\Program Files\Git)" -ForegroundColor Green
        Write-Host ""
        Write-Host "3. 설치 완료 후 PowerShell 재시작" -ForegroundColor White
        Write-Host ""
        Write-Host "4. 이 스크립트를 다시 실행" -ForegroundColor White
        Write-Host ""
        exit 1
    }
    
    if (Test-Path "$manualPath\cmd\git.exe") {
        $gitPath = $manualPath
        Write-Host "  ✅ Git 확인 완료: $gitPath" -ForegroundColor Green
    } else {
        Write-Host "  ❌ 해당 경로에 Git이 없습니다: $manualPath" -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "📍 Git 설치 위치: $gitPath" -ForegroundColor Cyan
Write-Host ""

# PATH에 추가할 경로들
$gitCmdPath = "$gitPath\cmd"
$gitBinPath = "$gitPath\bin"
$gitMingwBinPath = "$gitPath\mingw64\bin"

Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
Write-Host "📋 [2/4] 현재 PATH 확인 중..." -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
Write-Host ""

# 시스템 PATH 가져오기
$systemPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
$pathsToAdd = @()

# 필요한 경로 확인
$requiredPaths = @(
    @{ Path = $gitCmdPath; Name = "Git CMD" },
    @{ Path = $gitBinPath; Name = "Git Bin" },
    @{ Path = $gitMingwBinPath; Name = "Git MinGW" }
)

foreach ($item in $requiredPaths) {
    if ($systemPath -like "*$($item.Path)*") {
        Write-Host "  ✅ $($item.Name): 이미 PATH에 있음" -ForegroundColor Green
    } else {
        Write-Host "  ⚠️  $($item.Name): PATH에 없음 - 추가 필요" -ForegroundColor Yellow
        $pathsToAdd += $item.Path
    }
}

if ($pathsToAdd.Count -eq 0) {
    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
    Write-Host "🎉 모든 Git 경로가 이미 PATH에 설정되어 있습니다!" -ForegroundColor Green
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
    Write-Host ""
    Write-Host "💡 PowerShell을 재시작한 후 'git --version'을 실행하세요" -ForegroundColor Yellow
    Write-Host ""
    exit 0
}

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
Write-Host "➕ [3/4] PATH에 경로 추가 중..." -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
Write-Host ""

# 백업 생성
$backupPath = "$PSScriptRoot\backups"
if (-not (Test-Path $backupPath)) {
    New-Item -ItemType Directory -Path $backupPath -Force | Out-Null
}

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$backupFile = "$backupPath\PATH-backup-$timestamp.txt"
$systemPath | Out-File -FilePath $backupFile -Encoding UTF8

Write-Host "  💾 현재 PATH 백업: $backupFile" -ForegroundColor Cyan
Write-Host ""

# 새 경로 추가
$newSystemPath = $systemPath

foreach ($path in $pathsToAdd) {
    Write-Host "  ➕ 추가 중: $path" -ForegroundColor White
    
    # 끝에 세미콜론이 없으면 추가
    if (-not $newSystemPath.EndsWith(";")) {
        $newSystemPath += ";"
    }
    
    $newSystemPath += "$path;"
}

# PATH 업데이트 (시스템 레벨)
try {
    [Environment]::SetEnvironmentVariable("Path", $newSystemPath, "Machine")
    Write-Host ""
    Write-Host "  ✅ 시스템 PATH 업데이트 완료!" -ForegroundColor Green
} catch {
    Write-Host ""
    Write-Host "  ❌ PATH 업데이트 실패: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
Write-Host "✅ [4/4] 현재 세션에 경로 적용 중..." -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
Write-Host ""

# 현재 PowerShell 세션에도 적용
$env:Path = $newSystemPath
Write-Host "  ✅ 현재 세션 PATH 업데이트 완료" -ForegroundColor Green

# Git 버전 확인
Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
Write-Host "🧪 Git 동작 테스트" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
Write-Host ""

try {
    $gitVersion = & "$gitCmdPath\git.exe" --version
    Write-Host "  ✅ $gitVersion" -ForegroundColor Green
    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
    Write-Host "🎉 Git PATH 설정 완료!" -ForegroundColor Green
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
    Write-Host ""
    Write-Host "✨ 이제 Git을 사용할 수 있습니다!" -ForegroundColor Magenta
    Write-Host ""
    Write-Host "📝 다음 단계:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  1. 이 PowerShell 창에서 바로 사용 가능:" -ForegroundColor White
    Write-Host "     git --version" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  2. 다른 PowerShell 창은 재시작 필요" -ForegroundColor White
    Write-Host ""
    Write-Host "  3. Git 사용자 설정 (처음 사용 시):" -ForegroundColor White
    Write-Host '     git config --global user.name "Your Name"' -ForegroundColor Cyan
    Write-Host '     git config --global user.email "your@email.com"' -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  4. GitHub에 푸시:" -ForegroundColor White
    Write-Host "     cd c:\dev\Capella" -ForegroundColor Cyan
    Write-Host "     .\push-to-github.ps1" -ForegroundColor Cyan
    Write-Host ""
    
} catch {
    Write-Host "  ⚠️  Git 실행 테스트 실패" -ForegroundColor Yellow
    Write-Host "  새 PowerShell 창에서 'git --version'을 실행해보세요" -ForegroundColor Yellow
    Write-Host ""
}

Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
Write-Host ""
