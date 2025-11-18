# Ansible Configuration and Deployment Script (PowerShell)

$ErrorActionPreference = "Stop"

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Ansible Server Configuration" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# Check prerequisites
if (!(Get-Command ansible -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Ansible is not installed." -ForegroundColor Red
    Write-Host "For Windows, you can:" -ForegroundColor Yellow
    Write-Host "  1. Use WSL: wsl --install" -ForegroundColor Yellow
    Write-Host "  2. Then install Ansible in WSL: sudo apt-get install ansible" -ForegroundColor Yellow
    Write-Host "  3. Or use a Linux VM for running Ansible" -ForegroundColor Yellow
    exit 1
}

# Navigate to ansible directory
$scriptDir = Split-Path -Parent $PSCommandPath
$ansibleDir = Join-Path $scriptDir "..\ansible"
Set-Location $ansibleDir

# Check if outputs.json exists
if (!(Test-Path "..\outputs.json")) {
    Write-Host "❌ outputs.json not found. Please run deploy-azure.ps1 first." -ForegroundColor Red
    exit 1
}

# Extract IPs from Terraform outputs
Write-Host "📋 Reading Terraform outputs..." -ForegroundColor Yellow
$outputs = Get-Content "..\outputs.json" | ConvertFrom-Json
$APP_VM_IP = $outputs.app_vm_public_ip.value
$MONITOR_VM_IP = $outputs.monitor_vm_public_ip.value
$DB_HOST = $outputs.postgresql_server_fqdn.value

Write-Host "App VM IP: $APP_VM_IP" -ForegroundColor Cyan
Write-Host "Monitor VM IP: $MONITOR_VM_IP" -ForegroundColor Cyan
Write-Host "Database Host: $DB_HOST" -ForegroundColor Cyan
Write-Host ""

# Set environment variables for Ansible
$env:APP_VM_IP = $APP_VM_IP
$env:MONITOR_VM_IP = $MONITOR_VM_IP
$env:DB_HOST = $DB_HOST
$env:DB_USER = if ($env:DB_USER) { $env:DB_USER } else { "smsadmin" }
$env:DB_PASSWORD = if ($env:DB_PASSWORD) { $env:DB_PASSWORD } else { "ChangeMe123!Strong" }
$env:JWT_SECRET = if ($env:JWT_SECRET) { $env:JWT_SECRET } else { "super-secret-change-me-please-1234567890abcdef" }

Write-Host "⚠️  Note: Ansible requires SSH access. Make sure:" -ForegroundColor Yellow
Write-Host "  1. Your SSH key is in the correct location" -ForegroundColor Yellow
Write-Host "  2. VMs are running and accessible" -ForegroundColor Yellow
Write-Host "  3. Network security rules allow SSH (port 22)" -ForegroundColor Yellow
Write-Host ""

$continue = Read-Host "Continue with Ansible configuration? (y/N)"
if ($continue -ne 'y' -and $continue -ne 'Y') {
    Write-Host "Configuration cancelled." -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Step 1: Setup Application Server" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""
ansible-playbook -i inventory/hosts.yml playbooks/setup-app-server.yml

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Step 2: Setup Monitoring Server" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""
$installNagios = Read-Host "Do you want to install Nagios now? (y/N)"
if ($installNagios -eq 'y' -or $installNagios -eq 'Y') {
    ansible-playbook -i inventory/hosts.yml playbooks/setup-nagios.yml
} else {
    Write-Host "⏭️  Skipping Nagios installation (you can run it later)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Step 3: Deploy Application" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""
$deployApp = Read-Host "Do you want to deploy the application now? (y/N)"
if ($deployApp -eq 'y' -or $deployApp -eq 'Y') {
    $env:GIT_REPO = if ($env:GIT_REPO) { $env:GIT_REPO } else { "" }
    $env:GIT_BRANCH = if ($env:GIT_BRANCH) { $env:GIT_BRANCH } else { "main" }
    ansible-playbook -i inventory/hosts.yml playbooks/deploy-app.yml
} else {
    Write-Host "⏭️  Skipping application deployment" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "✅ Configuration Complete!" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "📊 Access Points:" -ForegroundColor Yellow
Write-Host "  Backend: http://$APP_VM_IP`:8080"
Write-Host "  Frontend: http://$APP_VM_IP`:5173"
Write-Host "  Swagger: http://$APP_VM_IP`:8080/swagger-ui/index.html"
Write-Host "  Nagios: http://$MONITOR_VM_IP/nagios"
Write-Host ""
Write-Host "🔐 Default Credentials:" -ForegroundColor Yellow
Write-Host "  Nagios: nagiosadmin / Admin123!"
Write-Host ""
