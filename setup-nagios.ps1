#!/usr/bin/env pwsh
# Quick Nagios Setup Script

Write-Host "`n🔍 Setting up Nagios Monitoring..." -ForegroundColor Cyan

$MONITOR_VM = "20.41.80.191"
$APP_VM = "4.218.14.65"

Write-Host "📦 Installing Nagios on Monitor VM ($MONITOR_VM)..." -ForegroundColor Yellow

# Run Ansible playbook
wsl -- bash -c "cd /mnt/d/SMS_devOps/ansible && ansible-playbook -i inventory/hosts.yml playbooks/setup-nagios.yml"

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n✅ Nagios installed successfully!" -ForegroundColor Green
    Write-Host "`n📊 Access Nagios:" -ForegroundColor Cyan
    Write-Host "   URL: http://$MONITOR_VM/nagios" -ForegroundColor White
    Write-Host "   Username: nagiosadmin" -ForegroundColor White
    Write-Host "   Password: Admin123!" -ForegroundColor White
} else {
    Write-Host "`n❌ Nagios installation failed" -ForegroundColor Red
    Write-Host "Check the Ansible output above for errors" -ForegroundColor Yellow
}

Write-Host ""
