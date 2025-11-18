#!/usr/bin/env pwsh

$VM_NAME = "sms-app-vm"
$RESOURCE_GROUP = "sms-devops-rg"

Write-Host "Rebuilding and redeploying frontend on Azure VM..."

$script = @'
#!/bin/bash
set -e

echo "Pulling latest code..."
cd /home/azureuser/SMS_usingDevOps
git pull origin main || true

echo "Rebuilding frontend Docker image..."
cd frontend
docker build -t sms-frontend:latest .

echo "Stopping old frontend container..."
docker stop sms-frontend-1 || true
docker rm sms-frontend-1 || true

echo "Starting new frontend container..."
docker run -d --name sms-frontend-1 \
  --network sms-network \
  -p 5173:80 \
  --restart unless-stopped \
  sms-frontend:latest

echo "Frontend redeployed successfully!"
docker ps | grep sms-frontend
'@

Write-Host "Executing deployment script on VM..."
az vm run-command invoke `
  --resource-group $RESOURCE_GROUP `
  --name $VM_NAME `
  --command-id RunShellScript `
  --scripts $script

Write-Host "`n✅ Frontend redeployed! Access at: http://4.218.12.135:5173"
