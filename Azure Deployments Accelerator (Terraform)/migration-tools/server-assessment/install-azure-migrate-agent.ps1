# Install Azure Migrate Agent for Physical Server Discovery
# This script installs the Azure Migrate agent on a physical or virtual server

param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectKey,
    
    [Parameter(Mandatory = $false)]
    [string]$DownloadUrl = "https://aka.ms/migrate/col/upgrade"
)

Write-Host "Installing Azure Migrate Agent..." -ForegroundColor Green
Write-Host "Note: This script must be run on the server you want to assess" -ForegroundColor Yellow

# Verify running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "Error: This script must be run as Administrator" -ForegroundColor Red
    Write-Host "Please right-click PowerShell and select 'Run as Administrator'" -ForegroundColor Yellow
    exit 1
}

try {
    Write-Host "`nIMPORTANT: Get your Project Key from Azure Portal:" -ForegroundColor Yellow
    Write-Host "1. Navigate to your Azure Migrate project" -ForegroundColor White
    Write-Host "2. Go to 'Discover' > 'Physical or other (AWS, GCP, Xen, etc.)'" -ForegroundColor White
    Write-Host "3. Click 'Generate key' or copy existing key" -ForegroundColor White
    Write-Host "`nProvided Project Key: $ProjectKey" -ForegroundColor Cyan
    
    # Download agent installer
    Write-Host "`nDownloading Azure Migrate agent installer..." -ForegroundColor Yellow
    Write-Host "Note: The actual download URL is provided in Azure Portal" -ForegroundColor White
    Write-Host "This script template shows the installation process" -ForegroundColor White
    
    # NOTE: The actual installer URL is specific to each Azure Migrate project
    # Users must download from Azure Portal: Migrate > Discover > Physical servers
    
    Write-Host "`nTo complete installation:" -ForegroundColor Cyan
    Write-Host "1. In Azure Portal, go to Azure Migrate > Servers, databases and web apps" -ForegroundColor White
    Write-Host "2. Click 'Discover' under 'Migration and modernization'" -ForegroundColor White
    Write-Host "3. Select 'Physical or other'" -ForegroundColor White
    Write-Host "4. Download the installer from the portal" -ForegroundColor White
    Write-Host "5. Run the installer on this server" -ForegroundColor White
    Write-Host "6. During setup, provide the Project Key: $ProjectKey" -ForegroundColor White
    
    Write-Host "`nAgent will collect:" -ForegroundColor Yellow
    Write-Host "  - Server configuration (CPU, memory, disks)" -ForegroundColor White
    Write-Host "  - Operating system details" -ForegroundColor White
    Write-Host "  - Installed applications" -ForegroundColor White
    Write-Host "  - Performance metrics (ongoing)" -ForegroundColor White
    Write-Host "  - Dependencies (if enabled)" -ForegroundColor White
    
}
catch {
    Write-Host "Error: $_" -ForegroundColor Red
    exit 1
}

Write-Host "`nNext Steps:" -ForegroundColor Cyan
Write-Host "1. Download installer from Azure Portal (link above)" -ForegroundColor White
Write-Host "2. Install and register with project key" -ForegroundColor White
Write-Host "3. Wait 24-48 hours for full discovery" -ForegroundColor White
Write-Host "4. Create assessment in Azure Portal" -ForegroundColor White
Write-Host "5. Review migration recommendations" -ForegroundColor White

Write-Host "`nAlternative - Agentless Discovery (Recommended if applicable):" -ForegroundColor Yellow
Write-Host "For VMware or Hyper-V environments, use agentless appliance-based discovery" -ForegroundColor White
Write-Host "This eliminates need to install agents on individual servers" -ForegroundColor White

Write-Host "`nDocumentation:" -ForegroundColor Cyan
Write-Host "  Physical Server Discovery: https://learn.microsoft.com/azure/migrate/tutorial-discover-physical" -ForegroundColor White
Write-Host "  Dependency Analysis: https://learn.microsoft.com/azure/migrate/concepts-dependency-visualization" -ForegroundColor White
