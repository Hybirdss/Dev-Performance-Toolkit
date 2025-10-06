# Contributing to Dev Performance Toolkit

First off, thank you for considering contributing to Dev Performance Toolkit! It's people like you that make this tool better for developers worldwide.

## Code of Conduct

This project and everyone participating in it is governed by our Code of Conduct. By participating, you are expected to uphold this code.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the issue list as you might find out that you don't need to create one. When you are creating a bug report, please include as many details as possible:

* **Use a clear and descriptive title**
* **Describe the exact steps which reproduce the problem**
* **Provide specific examples to demonstrate the steps**
* **Describe the behavior you observed after following the steps**
* **Explain which behavior you expected to see instead and why**
* **Include your OS version, Node.js version, and any relevant environment details**

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, please include:

* **Use a clear and descriptive title**
* **Provide a step-by-step description of the suggested enhancement**
* **Provide specific examples to demonstrate the steps**
* **Describe the current behavior and expected behavior**
* **Explain why this enhancement would be useful**

### Pull Requests

* Fill in the required template
* Do not include issue numbers in the PR title
* Include screenshots and animated GIFs in your pull request whenever possible
* Follow the PowerShell, Bash, and JavaScript style guides
* Document new code
* End all files with a newline

## Development Process

### 1. Fork and Clone

```bash
# Fork the repository on GitHub
# Then clone your fork
git clone https://github.com/YOUR_USERNAME/dev-performance-toolkit.git
cd dev-performance-toolkit
```

### 2. Create a Branch

```bash
git checkout -b feature/my-new-feature
# or
git checkout -b fix/my-bug-fix
```

### 3. Make Your Changes

#### For PowerShell Scripts (Windows)

* Follow [PowerShell Best Practices](https://poshcode.gitbook.io/powershell-practice-and-style/)
* Use meaningful variable names
* Add comments for complex logic
* Include error handling with try/catch
* Test on both Windows 10 and Windows 11

```powershell
# Good example
function Optimize-NetworkSettings {
    try {
        # Clear description of what this does
        $adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
        # ... implementation
    }
    catch {
        Write-Host "Error: $_" -ForegroundColor Red
    }
}
```

#### For Bash Scripts (macOS)

* Follow [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html)
* Use `#!/bin/bash` shebang
* Check return codes
* Quote variables
* Use `set -e` for error handling

```bash
# Good example
optimize_network_settings() {
    local adapter="$1"
    
    if [ -z "$adapter" ]; then
        echo "Error: No adapter specified" >&2
        return 1
    fi
    
    # ... implementation
}
```

#### For JavaScript (Node.js)

* Follow [Airbnb JavaScript Style Guide](https://github.com/airbnb/javascript)
* Use ES6+ features
* Add JSDoc comments
* Handle errors properly

```javascript
/**
 * Optimize Git configuration
 * @param {string} configKey - Configuration key
 * @param {string} configValue - Configuration value
 * @returns {boolean} Success status
 */
function optimizeGitConfig(configKey, configValue) {
    try {
        // ... implementation
        return true;
    } catch (error) {
        console.error(`Error: ${error.message}`);
        return false;
    }
}
```

### 4. Test Your Changes

#### Windows Testing

```powershell
# Test as Administrator
.\windows\network-optimizer.ps1

# Check for errors
$Error[0]

# Test specific functions
. .\windows\network-optimizer.ps1
Test-NetworkPerformance
```

#### macOS Testing

```bash
# Test with sudo
sudo ./macos/network-optimizer.sh

# Check exit codes
echo $?

# Test specific functions
source ./macos/network-optimizer.sh
test_network_performance
```

#### Cross-Platform Testing

```bash
# Test Node.js scripts
node cross-platform/git-optimizer.js

# Run on different Node versions
nvm use 14 && node cross-platform/git-optimizer.js
nvm use 16 && node cross-platform/git-optimizer.js
nvm use 18 && node cross-platform/git-optimizer.js
```

### 5. Commit Your Changes

```bash
# Stage your changes
git add .

# Commit with a descriptive message
git commit -m "feat: add DNS-over-TLS support"

# Follow conventional commits:
# feat: A new feature
# fix: A bug fix
# docs: Documentation only changes
# style: Changes that don't affect code meaning
# refactor: Code change that neither fixes a bug nor adds a feature
# perf: Code change that improves performance
# test: Adding missing tests
# chore: Changes to build process or auxiliary tools
```

### 6. Push and Create Pull Request

```bash
# Push to your fork
git push origin feature/my-new-feature

# Go to GitHub and create a Pull Request
```

## Style Guides

### PowerShell Style Guide

* Use PascalCase for function names: `Optimize-NetworkSettings`
* Use PascalCase for variables: `$NetworkAdapter`
* Use approved verbs: `Get-`, `Set-`, `New-`, `Remove-`, etc.
* Indent with 4 spaces
* Use Write-Host with colors for user feedback
* Always include error handling

### Bash Style Guide

* Use snake_case for function names: `optimize_network_settings`
* Use UPPERCASE for constants: `SCRIPT_DIR`
* Use lowercase for local variables: `local adapter`
* Indent with 4 spaces
* Always quote variables: `"$variable"`
* Check command success: `command || handle_error`

### JavaScript Style Guide

* Use camelCase for functions and variables: `optimizeSettings`
* Use PascalCase for classes: `NetworkOptimizer`
* Use UPPER_SNAKE_CASE for constants: `MAX_RETRIES`
* Indent with 2 spaces
* Use template literals: \`Message: ${value}\`
* Use async/await instead of callbacks

## Documentation

### Code Comments

* Explain **why**, not **what**
* Keep comments up-to-date
* Remove commented-out code

### README Updates

If you add new features:

* Update the main README.md
* Add usage examples
* Update the feature list
* Add to the Table of Contents

### Documentation Files

Update relevant docs:

* `docs/WINDOWS.md` - for Windows-specific changes
* `docs/MACOS.md` - for macOS-specific changes
* `docs/TROUBLESHOOTING.md` - for new issues/solutions

## Adding New Optimizations

### Checklist for New Optimization Scripts

- [ ] Script includes header with author and version
- [ ] Backup function implemented
- [ ] All changes are logged
- [ ] Error handling for all operations
- [ ] Success/failure messages
- [ ] Performance test function
- [ ] Report generation
- [ ] Documentation added to README
- [ ] Tested on target OS
- [ ] Added to all-in-one script

### Template for New Windows Script

```powershell
# ⚡ [Tool Name] Optimizer for Windows
# [Description]
# 
# Author: @hybirdss
# Date: YYYY-MM-DD
# Version: 2.0.0

if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "Administrator privileges required"
    exit 1
}

function Backup-Settings {
    # Backup implementation
}

function Optimize-Feature {
    # Optimization implementation
}

function Test-Performance {
    # Testing implementation
}

function Main {
    Backup-Settings
    Optimize-Feature
    Test-Performance
}

Main
```

### Template for New macOS Script

```bash
#!/bin/bash

# ⚡ [Tool Name] Optimizer for macOS
# [Description]
# 
# Author: @hybirdss
# Date: YYYY-MM-DD
# Version: 2.0.0

set -e

if [ "$EUID" -ne 0 ]; then 
    echo "Error: Must run as root"
    exit 1
fi

backup_settings() {
    # Backup implementation
}

optimize_feature() {
    # Optimization implementation
}

test_performance() {
    # Testing implementation
}

main() {
    backup_settings
    optimize_feature
    test_performance
}

main
```

## Release Process

1. Update version in all scripts
2. Update CHANGELOG.md
3. Update README.md if needed
4. Create git tag
5. Push tag to trigger release

## Questions?

* Open an issue with the `question` label
* Join our [Discussions](https://github.com/hybirdss/dev-performance-toolkit/discussions)

## Recognition

Contributors will be added to the README.md Contributors section.

Thank you for contributing! 🚀
