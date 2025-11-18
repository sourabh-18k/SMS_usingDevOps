#!/usr/bin/env pwsh

$VM_NAME = "sms-app-vm"
$RESOURCE_GROUP = "sms-devops-rg"

Write-Host "Pulling latest code and rebuilding frontend..."

$script = @'
#!/bin/bash
set -e

echo "=== Pulling latest code ==="
cd /home/azureuser/SMS_usingDevOps
git fetch origin
git reset --hard origin/main

echo "=== Rebuilding frontend Docker image ==="
cd frontend
docker build -t sms-frontend-local:latest .

echo "=== Stopping old container ==="
docker stop sms-frontend-1 || true
docker rm sms-frontend-1 || true

echo "=== Starting new container ==="
docker run -d --name sms-frontend-1 \
  --network sms-network \
  -p 5173:80 \
  --restart unless-stopped \
  sms-frontend-local:latest

echo "=== Checking container status ==="
sleep 3
docker ps | grep sms-frontend
docker logs --tail 10 sms-frontend-1

echo ""
echo "✅ Frontend redeployed successfully!"
'@

az vm run-command invoke `
  --resource-group $RESOURCE_GROUP `
  --name $VM_NAME `
  --command-id RunShellScript `
  --scripts $script `
  --output table

Write-Host "`n✅ Access the application at: http://4.218.12.135:5173"
Write-Host "It should now go directly to the dashboard without login!"
