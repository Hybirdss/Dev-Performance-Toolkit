# 🚀 GitHub 저장소 설정 가이드

## 1단계: Git 설치 (필수)

### Windows

#### 방법 1: Git 공식 웹사이트에서 다운로드 (권장)

1. [Git for Windows](https://git-scm.com/download/win) 접속
2. "Download for Windows" 버튼 클릭
3. 다운로드된 설치 파일 실행
4. 설치 옵션:
   - ✅ "Git from the command line and also from 3rd-party software" 선택
   - ✅ "Use Windows' default console window" 선택
   - ✅ 나머지는 기본값으로 설치
5. 설치 완료 후 **PowerShell을 새로 열어야 합니다**

#### 방법 2: Chocolatey 사용 (이미 설치된 경우)

```powershell
# Run as Administrator
choco install git -y
```

#### 설치 확인

새 PowerShell 창을 열고:

```powershell
git --version
```

`git version 2.xx.x` 같은 버전 정보가 출력되면 성공!

---

## 2단계: Git 저장소 푸시 (자동화 스크립트)

Git 설치 후, 아래 스크립트를 실행하세요.

### 📝 `push-to-github.ps1` 스크립트

```powershell
#Requires -Version 5.1

<#
.SYNOPSIS
    Dev Performance Toolkit을 GitHub에 푸시
    
.DESCRIPTION
    로컬 프로젝트를 GitHub 저장소에 자동으로 커밋하고 푸시합니다.
#>

param(
    [string]$RepoUrl = "https://github.com/Hybirdss/Dev-Performance-Toolkit.git",
    [string]$Branch = "main"
)

$ErrorActionPreference = "Stop"

Write-Host "`n╔════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  🚀 GitHub Push Automation Script    ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Cyan

# Git 설치 확인
Write-Host "`n[1/7] Git 설치 확인 중..." -ForegroundColor Yellow
try {
    $gitVersion = git --version
    Write-Host "  ✅ $gitVersion" -ForegroundColor Green
} catch {
    Write-Host "  ❌ Git이 설치되어 있지 않습니다!" -ForegroundColor Red
    Write-Host "`n  Git 설치 방법:" -ForegroundColor Yellow
    Write-Host "  1. https://git-scm.com/download/win 접속" -ForegroundColor White
    Write-Host "  2. Git 다운로드 및 설치" -ForegroundColor White
    Write-Host "  3. PowerShell 재시작 후 이 스크립트 다시 실행" -ForegroundColor White
    exit 1
}

# 현재 디렉토리 확인
Write-Host "`n[2/7] 프로젝트 디렉토리 확인 중..." -ForegroundColor Yellow
$currentDir = Get-Location
Write-Host "  📁 $currentDir" -ForegroundColor White

if (-not (Test-Path "package.json")) {
    Write-Host "  ❌ package.json이 없습니다. 프로젝트 루트에서 실행하세요." -ForegroundColor Red
    exit 1
}

# Git 저장소 초기화
Write-Host "`n[3/7] Git 저장소 초기화 중..." -ForegroundColor Yellow
if (-not (Test-Path ".git")) {
    git init
    Write-Host "  ✅ Git 저장소 초기화 완료" -ForegroundColor Green
} else {
    Write-Host "  ✅ Git 저장소가 이미 존재합니다" -ForegroundColor Green
}

# Git 사용자 설정 확인
Write-Host "`n[4/7] Git 사용자 설정 확인 중..." -ForegroundColor Yellow
$userName = git config --global user.name
$userEmail = git config --global user.email

if (-not $userName -or -not $userEmail) {
    Write-Host "  ⚠️ Git 사용자 설정이 필요합니다" -ForegroundColor Yellow
    Write-Host "`n  Git 설정 명령:" -ForegroundColor Cyan
    Write-Host '  git config --global user.name "Your Name"' -ForegroundColor White
    Write-Host '  git config --global user.email "your.email@example.com"' -ForegroundColor White
    Write-Host "`n  위 명령을 실행한 후 이 스크립트를 다시 실행하세요." -ForegroundColor Yellow
    exit 1
} else {
    Write-Host "  ✅ User: $userName <$userEmail>" -ForegroundColor Green
}

# 원격 저장소 설정
Write-Host "`n[5/7] 원격 저장소 설정 중..." -ForegroundColor Yellow
try {
    $remoteUrl = git remote get-url origin 2>$null
    if ($remoteUrl -eq $RepoUrl) {
        Write-Host "  ✅ 원격 저장소가 이미 설정되어 있습니다" -ForegroundColor Green
    } else {
        git remote remove origin 2>$null
        git remote add origin $RepoUrl
        Write-Host "  ✅ 원격 저장소 설정 완료: $RepoUrl" -ForegroundColor Green
    }
} catch {
    git remote add origin $RepoUrl
    Write-Host "  ✅ 원격 저장소 설정 완료: $RepoUrl" -ForegroundColor Green
}

# 파일 스테이징
Write-Host "`n[6/7] 파일 스테이징 중..." -ForegroundColor Yellow
git add .

$stagedFiles = (git diff --cached --name-only | Measure-Object).Count
Write-Host "  ✅ $stagedFiles 개의 파일 스테이징 완료" -ForegroundColor Green

# 커밋
Write-Host "`n[7/7] 커밋 및 푸시 중..." -ForegroundColor Yellow
$commitMessage = "feat: Initial release - Dev Performance Toolkit v2.0.0

- Complete Windows optimization suite
- Full macOS support with shell scripts
- Cross-platform Git optimizer
- Comprehensive documentation
- Automatic backup system
- Performance benchmarking tools

This toolkit helps developers optimize their development environment
for 50-80% performance improvements across network, system, and tools."

git commit -m $commitMessage
Write-Host "  ✅ 커밋 완료" -ForegroundColor Green

# 브랜치 이름 변경 (master → main)
$currentBranch = git branch --show-current
if ($currentBranch -ne $Branch) {
    git branch -M $Branch
    Write-Host "  ✅ 브랜치 이름 변경: $currentBranch → $Branch" -ForegroundColor Green
}

# GitHub에 푸시
Write-Host "`n  📤 GitHub에 푸시 중..." -ForegroundColor Yellow
Write-Host "  ⚠️  GitHub 자격 증명을 입력해야 할 수 있습니다." -ForegroundColor Yellow
Write-Host ""

try {
    git push -u origin $Branch --force
    Write-Host "`n  ✅ GitHub 푸시 성공!" -ForegroundColor Green
} catch {
    Write-Host "`n  ❌ 푸시 실패" -ForegroundColor Red
    Write-Host "  오류: $_" -ForegroundColor Red
    Write-Host "`n  문제 해결 방법:" -ForegroundColor Yellow
    Write-Host "  1. GitHub 자격 증명이 올바른지 확인" -ForegroundColor White
    Write-Host "  2. 네트워크 연결 확인" -ForegroundColor White
    Write-Host "  3. Personal Access Token 사용 (권장):" -ForegroundColor White
    Write-Host "     - GitHub Settings → Developer settings → Personal access tokens" -ForegroundColor Gray
    Write-Host "     - Generate new token (classic)" -ForegroundColor Gray
    Write-Host "     - Select scopes: repo (전체)" -ForegroundColor Gray
    Write-Host "     - Password 대신 토큰 사용" -ForegroundColor Gray
    exit 1
}

# 성공 메시지
Write-Host "`n╔════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║  🎉 GitHub 푸시 완료!                ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Green

Write-Host "`n📊 저장소 정보:" -ForegroundColor Cyan
Write-Host "  🔗 URL: https://github.com/Hybirdss/Dev-Performance-Toolkit" -ForegroundColor White
Write-Host "  🌿 Branch: $Branch" -ForegroundColor White
Write-Host "  📦 Commit: $(git rev-parse --short HEAD)" -ForegroundColor White

Write-Host "`n✨ 다음 단계:" -ForegroundColor Yellow
Write-Host "  1. GitHub 저장소 방문: https://github.com/Hybirdss/Dev-Performance-Toolkit" -ForegroundColor White
Write-Host "  2. README.md가 제대로 표시되는지 확인" -ForegroundColor White
Write-Host "  3. Repository Settings → About → 설명 추가:" -ForegroundColor White
Write-Host "     'Comprehensive performance optimization toolkit for developers'" -ForegroundColor Gray
Write-Host "  4. Topics 추가: performance, optimization, developer-tools, windows, macos" -ForegroundColor White
Write-Host "  5. Release 생성: v2.0.0" -ForegroundColor White
Write-Host ""
Write-Host "🚀 이제 전 세계 개발자들이 이 툴킷을 사용할 수 있습니다!" -ForegroundColor Magenta
Write-Host ""
