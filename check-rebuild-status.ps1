#!/usr/bin/env pwsh

$VM_NAME = "sms-app-vm"
$RESOURCE_GROUP = "sms-devops-rg"

Write-Host "Checking build progress..."

$script = 'tail -30 /tmp/frontend-rebuild.log 2>/dev/null || echo "Log not ready"; docker ps | grep sms-frontend'

az vm run-command invoke `
  --resource-group $RESOURCE_GROUP `
  --name $VM_NAME `
  --command-id RunShellScript `
  --scripts $script `
  --query 'value[0].message' `
  --output tsv
