#!/usr/bin/env pwsh
<#
.SYNOPSIS
    GitHub Secrets Setup for CI/CD Ansible Pipeline
.DESCRIPTION
    Retrieves values from Terraform and displays them for GitHub Secrets configuration
#>

Write-Host @"

╔══════════════════════════════════════════════════════════════════╗
║                                                                  ║
║         GitHub Actions Secrets Setup Helper                     ║
║         (For ci-cd.yml Ansible workflow)                        ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝

"@ -ForegroundColor Cyan

$originalDir = Get-Location
Set-Location "d:\SMS_devOps\terraform"

Write-Host "`n📋 Getting values from Terraform..." -ForegroundColor Yellow
$vmIp = terraform output -raw app_vm_public_ip 2>$null
$monitorIp = terraform output -raw monitor_vm_public_ip 2>$null
$dbHost = terraform output -raw postgresql_server_fqdn 2>$null

if (-not $vmIp) {
    Write-Host "❌ Could not get Terraform outputs. Run 'terraform apply' first!" -ForegroundColor Red
    Set-Location $originalDir
    exit 1
}

Set-Location $originalDir

Write-Host "🔑 Looking for SSH key..." -ForegroundColor Yellow
$sshKeyPath = "C:\Users\HP\.ssh\azure_sms_rsa"

if (Test-Path $sshKeyPath) {
    $sshKey = Get-Content $sshKeyPath -Raw
} else {
    Write-Host "❌ SSH key not found at $sshKeyPath" -ForegroundColor Red
    Write-Host "   Generate one with: ssh-keygen -t rsa -b 4096 -f ~/.ssh/azure_sms_rsa -N ''" -ForegroundColor White
    exit 1
}

Write-Host "✅ All values collected!`n" -ForegroundColor Green

# Display the secrets
Write-Host @"
╔══════════════════════════════════════════════════════════════════╗
║                                                                  ║
║         Copy these secrets to GitHub                            ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝

Go to: https://github.com/sourabh-18k/SMS_usingDevOps/settings/secrets/actions

Click "New repository secret" and add EACH of these 7 secrets:

"@ -ForegroundColor Cyan

Write-Host "`n════════════════════════════════════════════════════════════════════" -ForegroundColor DarkGray
Write-Host "1️⃣  Secret Name: AZURE_APP_VM_IP" -ForegroundColor Green
Write-Host "    Value:" -ForegroundColor Yellow
Write-Host "    $vmIp" -ForegroundColor White

Write-Host "`n════════════════════════════════════════════════════════════════════" -ForegroundColor DarkGray
Write-Host "2️⃣  Secret Name: AZURE_MONITOR_VM_IP" -ForegroundColor Green
Write-Host "    Value:" -ForegroundColor Yellow
Write-Host "    $monitorIp" -ForegroundColor White

Write-Host "`n════════════════════════════════════════════════════════════════════" -ForegroundColor DarkGray
Write-Host "3️⃣  Secret Name: AZURE_DB_HOST" -ForegroundColor Green
Write-Host "    Value:" -ForegroundColor Yellow
Write-Host "    $dbHost" -ForegroundColor White

Write-Host "`n════════════════════════════════════════════════════════════════════" -ForegroundColor DarkGray
Write-Host "4️⃣  Secret Name: AZURE_DB_USER" -ForegroundColor Green
Write-Host "    Value:" -ForegroundColor Yellow
Write-Host "    smsadmin" -ForegroundColor White

Write-Host "`n════════════════════════════════════════════════════════════════════" -ForegroundColor DarkGray
Write-Host "5️⃣  Secret Name: AZURE_DB_PASSWORD" -ForegroundColor Green
Write-Host "    Value:" -ForegroundColor Yellow
Write-Host "    SMS_DevOps_2025!SecurePassword" -ForegroundColor White

Write-Host "`n════════════════════════════════════════════════════════════════════" -ForegroundColor DarkGray
Write-Host "6️⃣  Secret Name: JWT_SECRET" -ForegroundColor Green
Write-Host "    Value:" -ForegroundColor Yellow
Write-Host "    super-secret-change-me-please-1234567890abcdef" -ForegroundColor White

Write-Host "`n════════════════════════════════════════════════════════════════════" -ForegroundColor DarkGray
Write-Host "7️⃣  Secret Name: AZURE_SSH_PRIVATE_KEY" -ForegroundColor Green
Write-Host "    Value: (Complete SSH private key, copy from below including BEGIN/END lines)" -ForegroundColor Yellow
Write-Host ""
Write-Host $sshKey -ForegroundColor DarkGray

Write-Host "`n════════════════════════════════════════════════════════════════════" -ForegroundColor DarkGray

Write-Host @"

📝 NEXT STEPS:

1. Open: https://github.com/sourabh-18k/SMS_usingDevOps/settings/secrets/actions
2. Click "New repository secret" for EACH of the 7 secrets above
3. After adding all secrets, trigger the workflow:
   
   git commit --allow-empty -m "Trigger CI/CD with secrets configured"
   git push origin main

4. Monitor: https://github.com/sourabh-18k/SMS_usingDevOps/actions

"@ -ForegroundColor Cyan

# Offer to copy SSH key
$copyChoice = Read-Host "Copy SSH private key to clipboard? (y/n)"
if ($copyChoice -eq 'y') {
    $sshKey | Set-Clipboard
    Write-Host "`n✅ SSH key copied! Paste it as AZURE_SSH_PRIVATE_KEY secret value" -ForegroundColor Green
}

Write-Host "`n💡 TIP: Keep this window open while adding secrets to GitHub" -ForegroundColor Yellow
Write-Host "💡 NOTE: Your workflow uses ci-cd.yml (Ansible deployment)" -ForegroundColor Yellow
