# Install Azure Data Studio
# This script downloads and installs the latest version of Azure Data Studio

param(
    [Parameter(Mandatory = $false)]
    [ValidateSet("User", "System")]
    [string]$InstallScope = "User"
)

Write-Host "Installing Azure Data Studio..." -ForegroundColor Green

# Azure Data Studio download URLs
$userInstallerUrl = "https://go.microsoft.com/fwlink/?linkid=2282284"  # User installer
$systemInstallerUrl = "https://go.microsoft.com/fwlink/?linkid=2282285"  # System installer

$installerUrl = if ($InstallScope -eq "System") { $systemInstallerUrl } else { $userInstallerUrl }
$installerPath = "$env:TEMP\AzureDataStudioSetup.exe"

try {
    # Download Azure Data Studio installer
    Write-Host "Downloading Azure Data Studio installer..." -ForegroundColor Yellow
    Write-Host "This may take a few minutes..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath -UseBasicParsing
    
    # Install Azure Data Studio
    Write-Host "Installing Azure Data Studio ($InstallScope scope)..." -ForegroundColor Yellow
    Start-Process -FilePath $installerPath -ArgumentList "/VERYSILENT /NORESTART /MERGETASKS=!runcode" -Wait -NoNewWindow
    
    Write-Host "Azure Data Studio installation completed successfully!" -ForegroundColor Green
    
    # Cleanup
    Remove-Item $installerPath -Force -ErrorAction SilentlyContinue
    
}
catch {
    Write-Host "Error installing Azure Data Studio: $_" -ForegroundColor Red
    exit 1
}

Write-Host "`nNext Steps:" -ForegroundColor Cyan
Write-Host "1. Launch Azure Data Studio from Start Menu" -ForegroundColor White
Write-Host "2. Install the Azure SQL Migration extension:" -ForegroundColor White
Write-Host "   - Open Extensions (Ctrl+Shift+X)" -ForegroundColor White
Write-Host "   - Search for 'Azure SQL Migration'" -ForegroundColor White
Write-Host "   - Click Install" -ForegroundColor White
Write-Host "3. Connect to your SQL Server instance" -ForegroundColor White
Write-Host "4. Right-click instance > Manage > Azure SQL Migration" -ForegroundColor White
