# Install Azure App Service Migration Assistant
# This script downloads and installs the App Service Migration Assistant

param(
    [Parameter(Mandatory=$false)]
    [string]$InstallPath = "$env:ProgramFiles\AppServiceMigrationAssistant"
)

Write-Host "Installing Azure App Service Migration Assistant..." -ForegroundColor Green

# App Service Migration Assistant download URL
$assistantUrl = "https://appmigration.microsoft.com/api/download/windows/AppServiceMigrationAssistant.msi"
$installerPath = "$env:TEMP\AppServiceMigrationAssistant.msi"

try {
    # Download installer
    Write-Host "Downloading App Service Migration Assistant installer..." -ForegroundColor Yellow
    Write-Host "This may take a few minutes..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri $assistantUrl -OutFile $installerPath -UseBasicParsing
    
    # Install
    Write-Host "Installing App Service Migration Assistant..." -ForegroundColor Yellow
    Start-Process msiexec.exe -ArgumentList "/i `"$installerPath`" /quiet /qn /norestart" -Wait -NoNewWindow
    
    Write-Host "`nApp Service Migration Assistant installation completed successfully!" -ForegroundColor Green
    
    # Cleanup
    Remove-Item $installerPath -Force -ErrorAction SilentlyContinue
    
} catch {
    Write-Host "Error installing App Service Migration Assistant: $_" -ForegroundColor Red
    Write-Host "`nAlternative: Download manually from https://aka.ms/appservicemigrationassistant" -ForegroundColor Yellow
    exit 1
}

Write-Host "`nNext Steps:" -ForegroundColor Cyan
Write-Host "1. Launch App Service Migration Assistant from Start Menu" -ForegroundColor White
Write-Host "2. For local IIS sites:" -ForegroundColor White
Write-Host "   - Select 'Assess and migrate on-premises IIS web apps'" -ForegroundColor White
Write-Host "   - Choose site to assess" -ForegroundColor White
Write-Host "3. For remote sites:" -ForegroundColor White
Write-Host "   - Select 'Assess website by URL'" -ForegroundColor White
Write-Host "   - Enter website URL" -ForegroundColor White
Write-Host "4. Review compatibility report" -ForegroundColor White
Write-Host "5. Follow migration wizard if site is compatible" -ForegroundColor White

Write-Host "`nDocumentation:" -ForegroundColor Yellow
Write-Host "  Guide: https://learn.microsoft.com/azure/app-service/app-service-migration-assessment" -ForegroundColor White
