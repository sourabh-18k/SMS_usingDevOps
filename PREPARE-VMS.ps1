#!/usr/bin/env pwsh
# Prepare Azure VMs for deployment by installing Docker

Write-Host "`n🚀 Preparing Azure VMs for Deployment" -ForegroundColor Cyan
Write-Host ("=" * 70) -ForegroundColor Cyan

$APP_VM_IP = "4.218.14.65"
$MONITOR_VM_IP = "20.41.80.191"
$SSH_KEY = "C:\Users\HP\.ssh\azure_sms_rsa"
$SSH_USER = "azureuser"

Write-Host "`n📦 Installing Docker on App VM ($APP_VM_IP)..." -ForegroundColor Yellow

# Install Docker on App VM
$result = ssh -i $SSH_KEY -o StrictHostKeyChecking=no ${SSH_USER}@${APP_VM_IP} @'
sudo apt-get update -qq && \
sudo apt-get install -y -qq apt-transport-https ca-certificates curl gnupg lsb-release && \
sudo install -m 0755 -d /etc/apt/keyrings && \
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
sudo chmod a+r /etc/apt/keyrings/docker.gpg && \
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null && \
sudo apt-get update -qq && \
sudo apt-get install -y -qq docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin && \
sudo usermod -aG docker $USER && \
sudo systemctl start docker && \
sudo systemctl enable docker && \
sudo docker --version
'@

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Docker installed successfully on App VM" -ForegroundColor Green
} else {
    Write-Host "❌ Failed to install Docker on App VM" -ForegroundColor Red
}

Write-Host "`n📦 Installing Docker on Monitor VM ($MONITOR_VM_IP)..." -ForegroundColor Yellow

# Install Docker on Monitor VM
$result = ssh -i $SSH_KEY -o StrictHostKeyChecking=no ${SSH_USER}@${MONITOR_VM_IP} @'
sudo apt-get update -qq && \
sudo apt-get install -y -qq apt-transport-https ca-certificates curl gnupg lsb-release && \
sudo install -m 0755 -d /etc/apt/keyrings && \
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
sudo chmod a+r /etc/apt/keyrings/docker.gpg && \
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null && \
sudo apt-get update -qq && \
sudo apt-get install -y -qq docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin && \
sudo usermod -aG docker $USER && \
sudo systemctl start docker && \
sudo systemctl enable docker && \
sudo docker --version
'@

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Docker installed successfully on Monitor VM" -ForegroundColor Green
} else {
    Write-Host "❌ Failed to install Docker on Monitor VM" -ForegroundColor Red
}

Write-Host "`n" -NoNewline
Write-Host ("=" * 70) -ForegroundColor Cyan
Write-Host "📊 INSTALLATION COMPLETE" -ForegroundColor Cyan
Write-Host ("=" * 70) -ForegroundColor Cyan

Write-Host "`n📝 NEXT STEPS:" -ForegroundColor Cyan
Write-Host "1. Add GitHub Secrets (see GITHUB-SECRETS-VALUES.txt)" -ForegroundColor White
Write-Host "2. Trigger CI/CD pipeline:" -ForegroundColor White
Write-Host "   git commit --allow-empty -m 'Trigger deployment'" -ForegroundColor Gray
Write-Host "   git push origin main" -ForegroundColor Gray
Write-Host "3. Monitor: https://github.com/sourabh-18k/SMS_usingDevOps/actions" -ForegroundColor White
Write-Host ""
