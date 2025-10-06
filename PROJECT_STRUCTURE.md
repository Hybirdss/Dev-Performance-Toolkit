# 📁 Project Structure

```
dev-performance-toolkit/
│
├── 📄 README.md                          # Main documentation
├── 📄 QUICKSTART.md                      # Quick start guide
├── 📄 CONTRIBUTING.md                    # Contribution guidelines
├── 📄 CHANGELOG.md                       # Version history
├── 📄 LICENSE                            # MIT License
├── 📄 package.json                       # NPM package configuration
├── 📄 .gitignore                         # Git ignore rules
│
├── 🪟 windows/                           # Windows optimization tools
│   ├── network-optimizer.ps1            # Network stack optimizer
│   ├── system-optimizer.ps1             # System optimizer  
│   ├── browser-optimizer.ps1            # Browser optimizer (planned)
│   ├── vscode-optimizer.ps1             # VSCode optimizer (planned)
│   ├── run-all-optimizations.ps1        # Run all Windows optimizations
│   ├── backups/                         # Automatic backups
│   │   └── .gitkeep
│   └── reports/                         # Optimization reports
│       └── .gitkeep
│
├── 🍎 macos/                             # macOS optimization tools
│   ├── network-optimizer.sh             # Network stack optimizer
│   ├── system-optimizer.sh              # System optimizer (planned)
│   ├── browser-optimizer.sh             # Browser optimizer (planned)
│   ├── dev-tools-optimizer.sh           # Dev tools optimizer (planned)
│   ├── run-all-optimizations.sh         # Run all macOS optimizations
│   ├── backups/                         # Automatic backups
│   │   └── .gitkeep
│   └── reports/                         # Optimization reports
│       └── .gitkeep
│
├── 🌐 cross-platform/                    # Cross-platform Node.js tools
│   ├── git-optimizer.js                 # Git configuration optimizer
│   ├── npm-optimizer.js                 # npm/yarn optimizer (planned)
│   ├── docker-optimizer.js              # Docker Desktop optimizer (planned)
│   ├── backups/                         # Automatic backups
│   │   └── .gitkeep
│   └── reports/                         # Optimization reports
│       └── .gitkeep
│
├── 📚 docs/                              # Detailed documentation (planned)
│   ├── WINDOWS.md                       # Windows-specific guide
│   ├── MACOS.md                         # macOS-specific guide
│   ├── TROUBLESHOOTING.md               # Troubleshooting guide
│   ├── BENCHMARKING.md                  # Performance testing guide
│   └── FAQ.md                           # Frequently asked questions
│
├── 🛠️ tools/                             # Additional utilities
│   ├── benchmark.js                     # Performance benchmark tool (planned)
│   ├── restore-from-backup.ps1          # Windows restore utility (planned)
│   ├── restore-from-backup.sh           # macOS restore utility (planned)
│   └── legacy/                          # Legacy Korean versions
│       ├── network-optimizer.ps1        # Original Korean network optimizer
│       ├── system-optimizer.ps1         # Original Korean system optimizer
│       └── NETWORK_SETUP.md             # Original Korean documentation
│
└── 🧪 tests/                             # Test suite (planned)
    ├── windows/                         # Windows tests
    ├── macos/                           # macOS tests
    └── cross-platform/                  # Cross-platform tests
```

## File Descriptions

### Root Files

| File | Purpose |
|------|---------|
| `README.md` | Main project documentation with features, usage, and examples |
| `QUICKSTART.md` | 5-minute setup guide for quick start |
| `CONTRIBUTING.md` | Guidelines for contributors |
| `CHANGELOG.md` | Version history and roadmap |
| `LICENSE` | MIT License |
| `package.json` | NPM package configuration |
| `.gitignore` | Files and directories to ignore in Git |

### Windows Scripts

| Script | Purpose | Time | Status |
|--------|---------|------|--------|
| `network-optimizer.ps1` | Optimize network stack, DNS, TCP/IP | ~5 min | ✅ Complete |
| `system-optimizer.ps1` | Optimize CPU, memory, disk, GPU | ~8 min | ⏳ Planned |
| `browser-optimizer.ps1` | Optimize Chrome, Edge, Firefox | ~3 min | ⏳ Planned |
| `vscode-optimizer.ps1` | Optimize Visual Studio Code | ~2 min | ⏳ Planned |
| `run-all-optimizations.ps1` | Execute all optimizations | ~15 min | ✅ Complete |

### macOS Scripts

| Script | Purpose | Time | Status |
|--------|---------|------|--------|
| `network-optimizer.sh` | Optimize network stack, DNS, TCP/IP | ~3 min | ✅ Complete |
| `system-optimizer.sh` | Optimize memory, disk, power | ~5 min | ⏳ Planned |
| `browser-optimizer.sh` | Optimize Safari, Chrome | ~3 min | ⏳ Planned |
| `dev-tools-optimizer.sh` | Optimize Homebrew, Git, Node.js | ~4 min | ⏳ Planned |
| `run-all-optimizations.sh` | Execute all optimizations | ~12 min | ✅ Complete |

### Cross-Platform Tools

| Tool | Purpose | Platform | Status |
|------|---------|----------|--------|
| `git-optimizer.js` | Optimize Git configuration | All | ✅ Complete |
| `npm-optimizer.js` | Optimize npm/yarn settings | All | ⏳ Planned |
| `docker-optimizer.js` | Optimize Docker Desktop | All | ⏳ Planned |

## Directory Purposes

### `/windows`, `/macos`, `/cross-platform`
- Contains platform-specific optimization scripts
- Each has `backups/` for automatic backups
- Each has `reports/` for optimization reports

### `/docs`
- Detailed platform-specific documentation
- Troubleshooting guides
- FAQ and advanced topics

### `/tools`
- Utility scripts for benchmarking and restoration
- Legacy versions for reference

### `/tests`
- Automated testing (future)
- Integration tests
- Performance regression tests

## File Naming Conventions

- **PowerShell**: `kebab-case.ps1` (e.g., `network-optimizer.ps1`)
- **Bash**: `kebab-case.sh` (e.g., `network-optimizer.sh`)
- **JavaScript**: `kebab-case.js` (e.g., `git-optimizer.js`)
- **Documentation**: `SCREAMING-CASE.md` (e.g., `README.md`)
- **Backups**: `{type}-backup-YYYYMMDD-HHMMSS.{ext}`
- **Reports**: `{type}-report-YYYYMMDD-HHMMSS.txt`

## Version Control

```
master (main)
  ├── v2.0.0 (current) - English, macOS, cross-platform
  └── v1.0.0 (legacy) - Korean, Windows only
```

## Total Files

- **Scripts**: 15+ (6 complete, 9 planned)
- **Documentation**: 10+ files
- **Platforms**: 2 (Windows, macOS)
- **Languages**: 3 (PowerShell, Bash, JavaScript)

---

<p align="center">
  <sub>Project structure designed for scalability and maintainability</sub>
</p>
