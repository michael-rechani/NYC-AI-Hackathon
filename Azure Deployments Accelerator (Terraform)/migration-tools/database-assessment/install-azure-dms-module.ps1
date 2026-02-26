# Install Azure PowerShell Modules for Database Migration
# This script installs the required Azure modules for DMS automation

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("CurrentUser", "AllUsers")]
    [string]$Scope = "CurrentUser"
)

Write-Host "Installing Azure PowerShell modules for Database Migration..." -ForegroundColor Green

# Check if running as Administrator (needed for AllUsers scope)
if ($Scope -eq "AllUsers") {
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $isAdmin) {
        Write-Host "Error: AllUsers scope requires running as Administrator" -ForegroundColor Red
        Write-Host "Please run PowerShell as Administrator or use -Scope CurrentUser" -ForegroundColor Yellow
        exit 1
    }
}

try {
    # Set PSGallery as trusted repository
    Write-Host "Configuring PowerShell Gallery..." -ForegroundColor Yellow
    if ((Get-PSRepository -Name PSGallery).InstallationPolicy -ne 'Trusted') {
        Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
    }
    
    # Install Azure PowerShell modules
    Write-Host "Installing Az.Accounts module..." -ForegroundColor Yellow
    Install-Module -Name Az.Accounts -Scope $Scope -AllowClobber -Force
    
    Write-Host "Installing Az.DataMigration module..." -ForegroundColor Yellow
    Install-Module -Name Az.DataMigration -Scope $Scope -AllowClobber -Force
    
    Write-Host "Installing Az.Sql module..." -ForegroundColor Yellow
    Install-Module -Name Az.Sql -Scope $Scope -AllowClobber -Force
    
    Write-Host "Installing Az.Network module..." -ForegroundColor Yellow
    Install-Module -Name Az.Network -Scope $Scope -AllowClobber -Force
    
    Write-Host "`nAzure PowerShell modules installed successfully!" -ForegroundColor Green
    
    # Display installed versions
    Write-Host "`nInstalled Modules:" -ForegroundColor Cyan
    $modules = @('Az.Accounts', 'Az.DataMigration', 'Az.Sql', 'Az.Network')
    foreach ($module in $modules) {
        $version = (Get-Module -ListAvailable -Name $module | Select-Object -First 1).Version
        Write-Host "  $module : $version" -ForegroundColor White
    }
    
} catch {
    Write-Host "Error installing Azure PowerShell modules: $_" -ForegroundColor Red
    exit 1
}

Write-Host "`nNext Steps:" -ForegroundColor Cyan
Write-Host "1. Connect to Azure: Connect-AzAccount" -ForegroundColor White
Write-Host "2. Use run-dms-assessment.ps1 to assess databases" -ForegroundColor White
Write-Host "3. Use setup-azure-dms.ps1 to create migration service" -ForegroundColor White

Write-Host "`nDocumentation:" -ForegroundColor Yellow
Write-Host "  PowerShell: https://learn.microsoft.com/powershell/module/az.datamigration/" -ForegroundColor White
Write-Host "  CLI: https://learn.microsoft.com/cli/azure/datamigration" -ForegroundColor White
