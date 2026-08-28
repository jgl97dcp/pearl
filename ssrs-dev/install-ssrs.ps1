# SSRS Installation Script for Windows 11
# Run this script as Administrator after SQL Server container is running

Write-Host "=== SSRS Installation Helper ===" -ForegroundColor Cyan
Write-Host ""

# Check if running as admin
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "ERROR: Please run this script as Administrator!" -ForegroundColor Red
    exit 1
}

# SSRS Download URL (SQL Server 2022 Reporting Services)
$ssrsUrl = "https://download.microsoft.com/download/8/3/2/832616ff-af64-42b4-a5b8-5a3d8e7de37c/SQLServerReportingServices.exe"
$downloadPath = "$env:TEMP\SQLServerReportingServices.exe"

Write-Host "Step 1: Downloading SSRS installer..." -ForegroundColor Yellow
if (-not (Test-Path $downloadPath)) {
    try {
        Invoke-WebRequest -Uri $ssrsUrl -OutFile $downloadPath -UseBasicParsing
        Write-Host "Download complete!" -ForegroundColor Green
    } catch {
        Write-Host "Download failed. Please download manually from:" -ForegroundColor Red
        Write-Host "https://www.microsoft.com/en-us/download/details.aspx?id=100122" -ForegroundColor Cyan
        Write-Host "Then run the installer and select 'Developer' edition (free)" -ForegroundColor Cyan
        exit 1
    }
} else {
    Write-Host "Installer already downloaded." -ForegroundColor Green
}

Write-Host ""
Write-Host "Step 2: Running SSRS installer..." -ForegroundColor Yellow
Write-Host "Please follow the installation wizard:" -ForegroundColor Cyan
Write-Host "  1. Accept the license terms" -ForegroundColor White
Write-Host "  2. Select 'Install Reporting Services'" -ForegroundColor White
Write-Host "  3. Choose 'Developer' edition (free for development)" -ForegroundColor White
Write-Host "  4. Wait for installation to complete" -ForegroundColor White
Write-Host ""

# Start the installer
Start-Process -FilePath $downloadPath -Wait

Write-Host ""
Write-Host "Step 3: Configure SSRS" -ForegroundColor Yellow
Write-Host "After installation, the Report Server Configuration Manager will open." -ForegroundColor Cyan
Write-Host ""
Write-Host "Configure these settings:" -ForegroundColor White
Write-Host "  1. Service Account: Leave as default (Virtual Service Account)" -ForegroundColor White
Write-Host "  2. Web Service URL: Click 'Apply' to use defaults (http://localhost:80/ReportServer)" -ForegroundColor White
Write-Host "  3. Database:" -ForegroundColor White
Write-Host "     - Click 'Change Database'" -ForegroundColor White
Write-Host "     - Select 'Create a new report server database'" -ForegroundColor White
Write-Host "     - Server Name: localhost,1433" -ForegroundColor White
Write-Host "     - Authentication: SQL Server Authentication" -ForegroundColor White
Write-Host "     - Username: sa" -ForegroundColor White
Write-Host "     - Password: MyStr0ng!Pass#2024" -ForegroundColor White
Write-Host "  4. Web Portal URL: Click 'Apply' to use defaults (http://localhost:80/Reports)" -ForegroundColor White
Write-Host ""
Write-Host "=== Installation Complete ===" -ForegroundColor Green
Write-Host ""
Write-Host "Access SSRS at:" -ForegroundColor Cyan
Write-Host "  Report Manager: http://localhost/Reports" -ForegroundColor White
Write-Host "  Web Service: http://localhost/ReportServer" -ForegroundColor White
