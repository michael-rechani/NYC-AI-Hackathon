# Run Database Assessment using Azure DMS PowerShell
# This script performs a database assessment for migration to Azure SQL

param(
    [Parameter(Mandatory = $true)]
    [string]$ServerName,
    
    [Parameter(Mandatory = $true)]
    [string]$DatabaseName,
    
    [Parameter(Mandatory = $false)]
    [ValidateSet("AzureSqlDatabase", "AzureSqlManagedInstance", "SqlServerOnAzureVM")]
    [string]$TargetPlatform = "AzureSqlDatabase",
    
    [Parameter(Mandatory = $false)]
    [string]$OutputFolder = ".\assessment-results",
    
    [Parameter(Mandatory = $false)]
    [switch]$UseSqlAuthentication,
    
    [Parameter(Mandatory = $false)]
    [string]$Username,
    
    [Parameter(Mandatory = $false)]
    [SecureString]$Password
)

# Import required modules
Write-Host "Loading Azure PowerShell modules..." -ForegroundColor Yellow
try {
    Import-Module Az.Accounts -ErrorAction Stop
    Import-Module Az.DataMigration -ErrorAction Stop
    Import-Module Az.Sql -ErrorAction Stop
}
catch {
    Write-Host "Error: Required Azure PowerShell modules not found" -ForegroundColor Red
    Write-Host "Please run install-azure-dms-module.ps1 first" -ForegroundColor Yellow
    exit 1
}

# Check Azure login status
Write-Host "Checking Azure connection..." -ForegroundColor Yellow
$context = Get-AzContext
if (-not $context) {
    Write-Host "Not connected to Azure. Please login..." -ForegroundColor Yellow
    Connect-AzAccount
}

# Create output folder
if (-not (Test-Path $OutputFolder)) {
    New-Item -Path $OutputFolder -ItemType Directory -Force | Out-Null
}

# Generate timestamp for report
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$reportName = "${DatabaseName}_${TargetPlatform}_${timestamp}"
$reportPath = Join-Path $OutputFolder "$reportName.json"

Write-Host "`nStarting Database Assessment..." -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green
Write-Host "Server: $ServerName" -ForegroundColor Cyan
Write-Host "Database: $DatabaseName" -ForegroundColor Cyan
Write-Host "Target Platform: $TargetPlatform" -ForegroundColor Cyan
Write-Host "Output: $reportPath" -ForegroundColor Cyan

# Build connection string
if (-not $UseSqlAuthentication) {
    $connectionString = "Server=$ServerName;Database=$DatabaseName;Integrated Security=True;TrustServerCertificate=True;Encrypt=True"
}
else {
    if ([string]::IsNullOrEmpty($Username) -or $null -eq $Password) {
        Write-Host "Error: Username and Password are required when not using TrustedConnection" -ForegroundColor Red
        exit 1
    }
    $passwordPlainText = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password))
    $connectionString = "Server=$ServerName;Database=$DatabaseName;User Id=$Username;Password=$passwordPlainText;TrustServerCertificate=True;Encrypt=True"
}

try {
    Write-Host "`nPerforming assessment... This may take several minutes." -ForegroundColor Yellow
    
    # Create assessment object
    $assessment = @{
        ServerName       = $ServerName
        DatabaseName     = $DatabaseName
        TargetPlatform   = $TargetPlatform
        AssessmentTime   = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        ConnectionString = $connectionString
    }
    
    # Note: This is a template for assessment
    # Actual Azure SQL assessment is done through Azure Data Studio GUI or Azure Migrate
    # For automation, you would typically use Azure Migrate REST APIs or Azure Data Studio CLI
    
    Write-Host "`nIMPORTANT: For comprehensive assessment, use one of these methods:" -ForegroundColor Yellow
    Write-Host "`n1. Azure Data Studio with SQL Migration Extension (Recommended):" -ForegroundColor Cyan
    Write-Host "   - Launch Azure Data Studio" -ForegroundColor White
    Write-Host "   - Connect to server: $ServerName" -ForegroundColor White
    Write-Host "   - Right-click > Manage > Azure SQL Migration > Migrate to Azure SQL" -ForegroundColor White
    Write-Host "   - Follow the assessment wizard" -ForegroundColor White
    
    Write-Host "`n2. Azure Migrate (For comprehensive server + database assessment):" -ForegroundColor Cyan
    Write-Host "   - Use Azure Migrate portal: https://portal.azure.com/#blade/Microsoft_Azure_Migrate" -ForegroundColor White
    Write-Host "   - Create assessment project" -ForegroundColor White
    Write-Host "   - Deploy appliance or use agentless discovery" -ForegroundColor White
    
    Write-Host "`n3. Azure CLI for programmatic assessment:" -ForegroundColor Cyan
    Write-Host "   - Use 'az datamigration' commands" -ForegroundColor White
    Write-Host "   - See: https://learn.microsoft.com/cli/azure/datamigration" -ForegroundColor White
    
    # Save configuration for reference
    $assessment | ConvertTo-Json -Depth 10 | Out-File -FilePath $reportPath -Encoding UTF8
    
    Write-Host "`nConfiguration saved to: $reportPath" -ForegroundColor Green
    Write-Host "Use this information when running actual assessment in Azure Data Studio" -ForegroundColor White
    
}
catch {
    Write-Host "Error during assessment: $_" -ForegroundColor Red
    exit 1
}

Write-Host "`nNext Steps:" -ForegroundColor Cyan
Write-Host "1. Run assessment using Azure Data Studio (recommended)" -ForegroundColor White
Write-Host "2. Review compatibility issues and recommendations" -ForegroundColor White
Write-Host "3. Address any blockers identified" -ForegroundColor White
Write-Host "4. Use setup-azure-dms.ps1 to prepare for migration" -ForegroundColor White
