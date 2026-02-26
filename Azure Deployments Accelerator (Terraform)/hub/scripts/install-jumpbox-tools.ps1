<#
.SYNOPSIS
    Installs development and data tools on the Workshop Jumpbox VM.
.DESCRIPTION
    Executed by Terraform via VM Run Command during deployment.
    Installs Chocolatey, then uses it to install:
      - Azure CLI
      - Visual Studio Code
      - Git
      - Python 3
      - Azure Data Studio
      - SQL Server Management Studio (SSMS)
      - Terraform
      - Node.js LTS
      - Microsoft Edge (Chromium)
    Also installs the Azure PowerShell module and Python AI packages.
    Each tool installs independently so a single failure won't block others.
.NOTES
    Log file: C:\WindowsTemp\install-jumpbox-tools.log
#>

$ErrorActionPreference = 'Continue'
$logFile = 'C:\Windows\Temp\install-jumpbox-tools.log'

function Write-Log {
    param([string]$Message)
    $ts = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    "$ts  $Message" | Tee-Object -FilePath $logFile -Append
}

function Refresh-PathEnv {
    $env:PATH = [System.Environment]::GetEnvironmentVariable('PATH', 'Machine') + ';' +
    [System.Environment]::GetEnvironmentVariable('PATH', 'User')
}

Write-Log '=========================================='
Write-Log 'Starting Workshop Jumpbox Tools Installation'
Write-Log '=========================================='

# ──────────────────────────────────────────
# 1. Install Chocolatey
# ──────────────────────────────────────────
Write-Log 'Installing Chocolatey...'
try {
    if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = `
            [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString(
                'https://community.chocolatey.org/install.ps1'))
        Refresh-PathEnv
        Write-Log 'Chocolatey installed successfully'
    }
    else {
        Write-Log 'Chocolatey already installed - skipping'
    }
}
catch {
    Write-Log "ERROR installing Chocolatey: $_"
    Write-Log 'Cannot continue without Chocolatey - exiting'
    exit 1
}

# ──────────────────────────────────────────
# 2. Install packages via Chocolatey
# ──────────────────────────────────────────
$packages = @(
    'azure-cli'
    'vscode'
    'git'
    'python3'
    'azure-data-studio'
    'sql-server-management-studio'
    'terraform'
    'nodejs-lts'
    'microsoft-edge'
)

foreach ($pkg in $packages) {
    Write-Log "Installing $pkg ..."
    try {
        $output = choco install $pkg -y --no-progress --limit-output 2>&1 | Out-String
        if ($LASTEXITCODE -eq 0 -or $LASTEXITCODE -eq 3010) {
            Write-Log "  $pkg installed (exit code $LASTEXITCODE)"
        }
        else {
            Write-Log "  WARNING: $pkg exited with code $LASTEXITCODE"
            Write-Log "  $output"
        }
    }
    catch {
        Write-Log "  ERROR installing ${pkg}: $_"
    }
}

Refresh-PathEnv

# ──────────────────────────────────────────
# 3. Install Azure PowerShell module
# ──────────────────────────────────────────
Write-Log 'Installing Azure PowerShell (Az) module...'
try {
    if (-not (Get-Module -ListAvailable -Name Az.Accounts -ErrorAction SilentlyContinue)) {
        Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force | Out-Null
        Install-Module -Name Az -Force -AllowClobber -Scope AllUsers -Repository PSGallery
        Write-Log 'Az module installed successfully'
    }
    else {
        Write-Log 'Az module already installed - skipping'
    }
}
catch {
    Write-Log "WARNING: Failed to install Az module: $_"
}

# ──────────────────────────────────────────
# 4. Install Python packages for Azure AI
# ──────────────────────────────────────────
Write-Log 'Installing Python packages for Azure AI...'
try {
    Refresh-PathEnv
    $pipCmd = Get-Command pip -ErrorAction SilentlyContinue
    if ($pipCmd) {
        & pip install --upgrade pip 2>&1 | Out-Null
        & pip install azure-identity azure-ai-projects openai 2>&1 | Out-Null
        Write-Log 'Python AI packages installed successfully'
    }
    else {
        Write-Log 'WARNING: pip not found in PATH - skipping Python packages'
    }
}
catch {
    Write-Log "WARNING: Failed to install Python packages: $_"
}

# ──────────────────────────────────────────
# 5. Create desktop shortcuts
# ──────────────────────────────────────────
Write-Log 'Creating desktop shortcuts...'
try {
    $desktopPath = [System.Environment]::GetFolderPath('CommonDesktopDirectory')
    $shell = New-Object -ComObject WScript.Shell

    # AI Foundry portal
    $shortcut = $shell.CreateShortcut("$desktopPath\Azure AI Foundry.url")
    $shortcut.TargetPath = 'https://ai.azure.com'
    $shortcut.Save()

    # Azure Portal
    $shortcut = $shell.CreateShortcut("$desktopPath\Azure Portal.url")
    $shortcut.TargetPath = 'https://portal.azure.com'
    $shortcut.Save()

    Write-Log 'Desktop shortcuts created'
}
catch {
    Write-Log "WARNING: Failed to create desktop shortcuts: $_"
}

Write-Log '=========================================='
Write-Log 'Workshop Jumpbox Tools Installation Complete'
Write-Log '=========================================='
