# GitHub Secrets Setup Script
Write-Host ""
Write-Host "GITHUB SECRETS TO ADD" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Open: https://github.com/sourabh-18k/SMS_usingDevOps/settings/secrets/actions/new" -ForegroundColor Yellow
Write-Host ""
Write-Host "Add these 7 secrets:" -ForegroundColor Yellow
Write-Host ""

Write-Host "1. AZURE_APP_VM_IP" -ForegroundColor Green
Write-Host "   4.218.12.135" -ForegroundColor White
Write-Host ""

Write-Host "2. AZURE_MONITOR_VM_IP" -ForegroundColor Green
Write-Host "   4.217.199.101" -ForegroundColor White
Write-Host ""

Write-Host "3. AZURE_DB_HOST" -ForegroundColor Green
Write-Host "   sms-psql-server.postgres.database.azure.com" -ForegroundColor White
Write-Host ""

Write-Host "4. AZURE_DB_USER" -ForegroundColor Green
Write-Host "   smsadmin" -ForegroundColor White
Write-Host ""

Write-Host "5. AZURE_DB_PASSWORD" -ForegroundColor Green
Write-Host "   SMS_DevOps_2025!SecurePassword" -ForegroundColor White
Write-Host ""

Write-Host "6. JWT_SECRET" -ForegroundColor Green
Write-Host "   super-secret-change-me-please-1234567890abcdef" -ForegroundColor White
Write-Host ""

Write-Host "7. AZURE_SSH_PRIVATE_KEY" -ForegroundColor Green
Write-Host "   Copying to clipboard..." -ForegroundColor Yellow
Get-Content C:\Users\HP\.ssh\azure_sms_rsa -Raw | Set-Clipboard
Write-Host "   SSH key copied! Paste as the secret value." -ForegroundColor Green
Write-Host ""

Write-Host "After adding all 7 secrets, push your code to trigger the CI/CD pipeline!" -ForegroundColor Green
Write-Host ""
