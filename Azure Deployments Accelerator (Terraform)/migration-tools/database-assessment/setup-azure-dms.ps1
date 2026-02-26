# Setup Azure Database Migration Service
# This script creates an Azure DMS instance for database migration

param(
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,
    
    [Parameter(Mandatory = $true)]
    [string]$Location,
    
    [Parameter(Mandatory = $false)]
    [string]$ServiceName = "dms-$(Get-Random -Maximum 9999)",
    
    [Parameter(Mandatory = $false)]
    [string]$VNetName = "dms-vnet",
    
    [Parameter(Mandatory = $false)]
    [string]$SubnetName = "dms-subnet",
    
    [Parameter(Mandatory = $false)]
    [ValidateSet("Standard_1vCore", "Standard_2vCores", "Standard_4vCores", "Premium_4vCores")]
    [string]$Sku = "Standard_1vCore",
    
    [Parameter(Mandatory = $false)]
    [switch]$CreateVNet = $false
)

Write-Host "Setting up Azure Database Migration Service..." -ForegroundColor Green

# Check if Azure CLI is installed
try {
    $azVersion = az version --output json 2>&1 | ConvertFrom-Json
    Write-Host "Using Azure CLI version: $($azVersion.'azure-cli')" -ForegroundColor Cyan
}
catch {
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

# Create resource group if it doesn't exist
Write-Host "Ensuring resource group exists..." -ForegroundColor Yellow
az group create --name $ResourceGroupName --location $Location --output none
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error creating resource group" -ForegroundColor Red
    exit 1
}

# Create VNet if requested
if ($CreateVNet) {
    Write-Host "Creating Virtual Network..." -ForegroundColor Yellow
    
    az network vnet create `
        --resource-group $ResourceGroupName `
        --name $VNetName `
        --location $Location `
        --address-prefix "10.0.0.0/16" `
        --subnet-name $SubnetName `
        --subnet-prefix "10.0.1.0/24" `
        --output none
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error creating VNet" -ForegroundColor Red
        exit 1
    }
}
else {
    Write-Host "Note: Using existing VNet: $VNetName" -ForegroundColor Cyan
    Write-Host "If VNet doesn't exist, use -CreateVNet flag" -ForegroundColor Yellow
}

# Get subnet ID
Write-Host "Getting subnet information..." -ForegroundColor Yellow
$subnetId = az network vnet subnet show `
    --resource-group $ResourceGroupName `
    --vnet-name $VNetName `
    --name $SubnetName `
    --query id `
    --output tsv

if ([string]::IsNullOrEmpty($subnetId)) {
    Write-Host "Error: Could not find subnet. Please verify VNet and Subnet exist" -ForegroundColor Red
    exit 1
}

# Create DMS instance
Write-Host "Creating Azure Database Migration Service instance..." -ForegroundColor Yellow
Write-Host "Service Name: $ServiceName" -ForegroundColor Cyan
Write-Host "SKU: $Sku" -ForegroundColor Cyan

az dms create `
    --resource-group $ResourceGroupName `
    --name $ServiceName `
    --location $Location `
    --sku-name $Sku `
    --subnet $subnetId `
    --output none

if ($LASTEXITCODE -eq 0) {
    Write-Host "`nAzure Database Migration Service created successfully!" -ForegroundColor Green
    
    # Get service details
    $dmsInfo = az dms show `
        --resource-group $ResourceGroupName `
        --name $ServiceName `
        --output json | ConvertFrom-Json
    
    Write-Host "`nService Details:" -ForegroundColor Green
    Write-Host "================" -ForegroundColor Green
    Write-Host "Name: $($dmsInfo.name)" -ForegroundColor White
    Write-Host "Location: $($dmsInfo.location)" -ForegroundColor White
    Write-Host "State: $($dmsInfo.provisioningState)" -ForegroundColor White
    Write-Host "SKU: $($dmsInfo.sku.name)" -ForegroundColor White
    
}
else {
    Write-Host "Error creating DMS instance" -ForegroundColor Red
    exit 1
}

Write-Host "`nNext Steps:" -ForegroundColor Cyan
Write-Host "1. Use create-migration-project.ps1 to create a migration project" -ForegroundColor White
Write-Host "2. Configure source and target database connections" -ForegroundColor White
Write-Host "3. Run migration with monitoring" -ForegroundColor White

# Output connection info for use in other scripts
Write-Host "`nConnection Info (save for migration):" -ForegroundColor Yellow
Write-Host "Resource Group: $ResourceGroupName" -ForegroundColor White
Write-Host "DMS Service: $ServiceName" -ForegroundColor White
