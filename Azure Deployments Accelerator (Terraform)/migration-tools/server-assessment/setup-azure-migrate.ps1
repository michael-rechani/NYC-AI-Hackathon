# Setup Azure Migrate Project
# This script creates an Azure Migrate project for server and application assessment

param(
    [Parameter(Mandatory=$true)]
    [string]$ResourceGroupName,
    
    [Parameter(Mandatory=$true)]
    [string]$ProjectName,
    
    [Parameter(Mandatory=$true)]
    [string]$Location,
    
    [Parameter(Mandatory=$false)]
    [switch]$CreateResourceGroup = $false
)

Write-Host "Setting up Azure Migrate Project..." -ForegroundColor Green

# Check if Azure CLI is installed
try {
    $azVersion = az version --output json 2>&1 | ConvertFrom-Json
    Write-Host "Using Azure CLI version: $($azVersion.'azure-cli')" -ForegroundColor Cyan
} catch {
    Write-Host "Error: Azure CLI is not installed" -ForegroundColor Red
    Write-Host "Please install from: https://aka.ms/installazurecliwindows" -ForegroundColor Yellow
    exit 1
}

# Check if logged in to Azure
Write-Host "Checking Azure login status..." -ForegroundColor Yellow
$account = az account show 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "Not logged in to Azure. Please login..." -ForegroundColor Yellow
    az login
}

# Get current subscription
$subscription = az account show --query "{name:name, id:id}" --output json | ConvertFrom-Json
Write-Host "`nUsing Subscription:" -ForegroundColor Cyan
Write-Host "  Name: $($subscription.name)" -ForegroundColor White
Write-Host "  ID: $($subscription.id)" -ForegroundColor White

# Create resource group if requested
if ($CreateResourceGroup) {
    Write-Host "`nCreating resource group..." -ForegroundColor Yellow
    az group create --name $ResourceGroupName --location $Location --output none
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error creating resource group" -ForegroundColor Red
        exit 1
    }
    Write-Host "Resource group created: $ResourceGroupName" -ForegroundColor Green
} else {
    # Verify resource group exists
    $rgExists = az group exists --name $ResourceGroupName
    if ($rgExists -eq "false") {
        Write-Host "Error: Resource group '$ResourceGroupName' does not exist" -ForegroundColor Red
        Write-Host "Use -CreateResourceGroup flag to create it" -ForegroundColor Yellow
        exit 1
    }
}

# Check if Azure Migrate resource provider is registered
Write-Host "`nRegistering Azure Migrate resource provider..." -ForegroundColor Yellow
az provider register --namespace Microsoft.Migrate --wait --output none
az provider register --namespace Microsoft.OffAzure --wait --output none

# Create Azure Migrate project using REST API (as there's no direct CLI command)
Write-Host "`nCreating Azure Migrate project..." -ForegroundColor Yellow

$migrateProjectJson = @{
    location = $Location
    properties = @{
        publicNetworkAccess = "Enabled"
    }
} | ConvertTo-Json -Depth 10

# Use Azure REST API to create project
$token = az account get-access-token --query accessToken --output tsv
$subscriptionId = az account show --query id --output tsv

$uri = "https://management.azure.com/subscriptions/$subscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Migrate/migrateProjects/$ProjectName`?api-version=2020-05-01"

try {
    $headers = @{
        "Authorization" = "Bearer $token"
        "Content-Type" = "application/json"
    }
    
    $response = Invoke-RestMethod -Uri $uri -Method Put -Headers $headers -Body $migrateProjectJson
    
    Write-Host "`nAzure Migrate project created successfully!" -ForegroundColor Green
    Write-Host "`nProject Details:" -ForegroundColor Green
    Write-Host "================" -ForegroundColor Green
    Write-Host "Name: $ProjectName" -ForegroundColor White
    Write-Host "Resource Group: $ResourceGroupName" -ForegroundColor White
    Write-Host "Location: $Location" -ForegroundColor White
    
} catch {
    Write-Host "Error creating Azure Migrate project: $_" -ForegroundColor Red
    Write-Host "`nAlternative: Create project via Azure Portal:" -ForegroundColor Yellow
    Write-Host "  https://portal.azure.com/#blade/Microsoft_Azure_Migrate/AmhResourceMenuBlade/overview" -ForegroundColor White
    exit 1
}

Write-Host "`nNext Steps:" -ForegroundColor Cyan
Write-Host "=============" -ForegroundColor Cyan

Write-Host "`n1. Access Azure Migrate in Portal:" -ForegroundColor Yellow
Write-Host "   https://portal.azure.com/#blade/Microsoft_Azure_Migrate/AmhResourceMenuBlade/overview" -ForegroundColor White

Write-Host "`n2. Choose Assessment Method:" -ForegroundColor Yellow
Write-Host "   A) For VMware/Hyper-V (Recommended - Agentless):" -ForegroundColor Cyan
Write-Host "      - Click 'Discover' under 'Servers, databases and web apps'" -ForegroundColor White
Write-Host "      - Download appliance (OVA for VMware / VHD for Hyper-V)" -ForegroundColor White
Write-Host "      - Deploy and configure appliance" -ForegroundColor White
Write-Host "      - Appliance will auto-discover servers" -ForegroundColor White

Write-Host "`n   B) For Physical Servers or Agent-Based:" -ForegroundColor Cyan
Write-Host "      - Use install-azure-migrate-agent.ps1 on each server" -ForegroundColor White
Write-Host "      - Get project key from Azure Portal" -ForegroundColor White

Write-Host "`n   C) For Web Apps:" -ForegroundColor Cyan
Write-Host "      - Use install-app-service-migration-assistant.ps1" -ForegroundColor White
Write-Host "      - Run assessment on web servers" -ForegroundColor White

Write-Host "`n3. Create Assessment:" -ForegroundColor Yellow
Write-Host "   - Wait for discovery to complete (may take 24-48 hours)" -ForegroundColor White
Write-Host "   - Go to 'Assess' > 'Azure VM' or 'Azure App Service'" -ForegroundColor White
Write-Host "   - Review readiness, sizing, and cost estimates" -ForegroundColor White

Write-Host "`n4. Plan Migration:" -ForegroundColor Yellow
Write-Host "   - Review assessment recommendations" -ForegroundColor White
Write-Host "   - Choose migration path (IaaS vs PaaS)" -ForegroundColor White
Write-Host "   - Use Azure Migrate for actual migration" -ForegroundColor White

Write-Host "`nDocumentation:" -ForegroundColor Cyan
Write-Host "  Overview: https://learn.microsoft.com/azure/migrate/migrate-services-overview" -ForegroundColor White
Write-Host "  VMware: https://learn.microsoft.com/azure/migrate/tutorial-discover-vmware" -ForegroundColor White
Write-Host "  Hyper-V: https://learn.microsoft.com/azure/migrate/tutorial-discover-hyper-v" -ForegroundColor White
Write-Host "  Physical: https://learn.microsoft.com/azure/migrate/tutorial-discover-physical" -ForegroundColor White
