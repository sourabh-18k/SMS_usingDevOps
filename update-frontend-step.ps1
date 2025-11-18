#!/usr/bin/env pwsh

$VM_NAME = "sms-app-vm"
$RESOURCE_GROUP = "sms-devops-rg"

Write-Host "Updating code and rebuilding (in background)..."

# First command: pull code
$pullScript = @'
cd /home/azureuser/SMS_usingDevOps && git fetch origin && git reset --hard origin/main && echo "Code updated"
'@

Write-Host "Step 1: Pulling latest code..."
az vm run-command invoke `
  --resource-group $RESOURCE_GROUP `
  --name $VM_NAME `
  --command-id RunShellScript `
  --scripts $pullScript | Out-Null

Start-Sleep -Seconds 2

# Second command: rebuild
$rebuildScript = @'
cd /home/azureuser/SMS_usingDevOps/frontend && docker build -t sms-frontend-local:latest . && echo "Build complete"
'@

Write-Host "Step 2: Building Docker image (this may take a minute)..."
az vm run-command invoke `
  --resource-group $RESOURCE_GROUP `
  --name $VM_NAME `
  --command-id RunShellScript `
  --scripts $rebuildScript | Out-Null

Start-Sleep -Seconds 2

# Third command: restart container
$restartScript = @'
docker stop sms-frontend-1 && docker rm sms-frontend-1 && docker run -d --name sms-frontend-1 --network sms-network -p 5173:80 --restart unless-stopped sms-frontend-local:latest && docker ps | grep sms-frontend
'@

Write-Host "Step 3: Restarting container..."
$result = az vm run-command invoke `
  --resource-group $RESOURCE_GROUP `
  --name $VM_NAME `
  --command-id RunShellScript `
  --scripts $restartScript

Write-Host "`n$result"
Write-Host "`n✅ Frontend updated! Visit: http://4.218.12.135:5173"
