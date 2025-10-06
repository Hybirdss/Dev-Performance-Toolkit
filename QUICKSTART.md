# 🚀 Quick Start Guide

Get started with Dev Performance Toolkit in less than 5 minutes!

## Windows Users

### Step 1: Clone the Repository

```powershell
# Open PowerShell
cd C:\dev
git clone https://github.com/hybirdss/dev-performance-toolkit.git
cd dev-performance-toolkit
```

### Step 2: Run Optimizations

```powershell
# Open PowerShell as Administrator
# Right-click PowerShell → "Run as Administrator"

cd C:\dev\dev-performance-toolkit\windows

# Option A: Run all optimizations (recommended)
.\run-all-optimizations.ps1

# Option B: Run individual optimizations
.\network-optimizer.ps1  # Network optimization (~5 min)
.\system-optimizer.ps1   # System optimization (~8 min)
```

### Step 3: Restart

```powershell
# Restart your computer for all changes to take effect
Restart-Computer
```

### Step 4: Verify

```powershell
# Test network performance
Test-NetConnection google.com -InformationLevel Detailed

# Check DNS speed
Measure-Command { Resolve-DnsName google.com }
```

---

## macOS Users

### Step 1: Clone the Repository

```bash
# Open Terminal
cd ~/dev
git clone https://github.com/hybirdss/dev-performance-toolkit.git
cd dev-performance-toolkit
```

### Step 2: Run Optimizations

```bash
cd macos

# Make scripts executable
chmod +x *.sh

# Option A: Run all optimizations (recommended)
sudo ./run-all-optimizations.sh

# Option B: Run individual optimizations
sudo ./network-optimizer.sh  # Network optimization (~3 min)
sudo ./system-optimizer.sh   # System optimization (~5 min)
```

### Step 3: Restart

```bash
# Restart your Mac for all changes to take effect
sudo shutdown -r now
```

### Step 4: Verify

```bash
# Test network performance
nc -zv google.com 443

# Check DNS speed
dig google.com @1.1.1.1
```

---

## Cross-Platform Tools (Node.js)

### Git Optimizer

```bash
# Optimize Git configuration
node cross-platform/git-optimizer.js

# Or use npm script
npm run optimize:git
```

### npm Optimizer

```bash
# Optimize npm/yarn settings
node cross-platform/npm-optimizer.js

# Or use npm script
npm run optimize:npm
```

### Docker Optimizer

```bash
# Optimize Docker Desktop
node cross-platform/docker-optimizer.js

# Or use npm script
npm run optimize:docker
```

---

## What Gets Optimized?

### ✅ Network
- TCP/IP stack (Fast Open, CUBIC)
- DNS (Cloudflare 1.1.1.1)
- MTU optimization
- QoS policies
- Network adapter settings

### ✅ System
- CPU & Power management
- Memory & Virtual memory
- Disk & SSD (TRIM)
- GPU acceleration
- Visual effects
- Background apps
- Windows services (Windows)
- Launch services (macOS)

### ✅ Development Tools
- Git configuration
- npm/yarn settings
- Docker Desktop
- VSCode settings
- Browser performance

---

## Expected Results

After optimization, you should see:

| Metric | Improvement |
|--------|-------------|
| Boot Time | **50%** faster |
| DNS Response | **70-80%** faster |
| npm install | **40-50%** faster |
| HMR Speed | **50-70%** faster |
| Dev Server Start | **50%** faster |
| Memory Usage | **25%** reduction |

---

## Troubleshooting

### Windows: "Scripts are disabled on this system"

```powershell
# Run this in PowerShell as Administrator
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### macOS: "Permission denied"

```bash
# Make scripts executable
chmod +x *.sh

# Run with sudo
sudo ./run-all-optimizations.sh
```

### Changes didn't apply

```
1. Restart your computer
2. Check backup files in backups/ folder
3. Review reports/ folder for details
```

---

## Backup & Recovery

All scripts create automatic backups before making changes:

- **Windows**: `backups/network-backup-YYYYMMDD-HHMMSS.txt`
- **macOS**: `backups/network-backup-YYYYMMDD-HHMMSS.txt`

To restore:
1. Check the backup file
2. Manually revert settings
3. Or use system restore point (recommended)

---

## Next Steps

1. ✅ **Restart your computer**
2. 📊 **Run benchmark**: `npm run benchmark`
3. 🧪 **Test your dev environment**: `npm run dev`
4. 📚 **Read full docs**: Check [README.md](README.md)
5. ⭐ **Star the repo**: Help others discover this tool!

---

## Support

- 📖 [Full Documentation](README.md)
- 🐛 [Report Issues](https://github.com/hybirdss/dev-performance-toolkit/issues)
- 💬 [Discussions](https://github.com/hybirdss/dev-performance-toolkit/discussions)
- 📧 Contact: [@hybirdss](https://github.com/hybirdss)

---

<p align="center">
  Made with ❤️ by <a href="https://github.com/hybirdss">@hybirdss</a>
</p>
