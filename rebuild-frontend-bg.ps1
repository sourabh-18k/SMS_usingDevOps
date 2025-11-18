#!/usr/bin/env pwsh

$VM_NAME = "sms-app-vm"
$RESOURCE_GROUP = "sms-devops-rg"

Write-Host "Starting frontend rebuild (background process)..."

$script = @'
#!/bin/bash
(
  cd /home/azureuser/SMS_usingDevOps
  git fetch origin
  git reset --hard origin/main
  cd frontend
  docker build -t sms-frontend-local:latest .
  docker stop sms-frontend-1
  docker rm sms-frontend-1
  docker run -d --name sms-frontend-1 \
    --network sms-network \
    -p 5173:80 \
    --restart unless-stopped \
    sms-frontend-local:latest
) > /tmp/frontend-rebuild.log 2>&1 &

echo "Rebuild started in background. Check /tmp/frontend-rebuild.log for progress."
echo "Process ID: $!"
'@

az vm run-command invoke `
  --resource-group $RESOURCE_GROUP `
  --name $VM_NAME `
  --command-id RunShellScript `
  --scripts $script

Write-Host "`n⏳ Build running in background on VM..."
Write-Host "   This will take 1-2 minutes to complete."
Write-Host "`n   Access: http://4.218.12.135:5173"
Write-Host "`n   Wait a moment, then refresh your browser."
