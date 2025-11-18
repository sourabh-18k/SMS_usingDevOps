#!/usr/bin/env pwsh

$VM_NAME = "sms-app-vm"
$RESOURCE_GROUP = "sms-devops-rg"

Write-Host "Checking frontend status..."

$script = 'docker ps | grep sms-frontend && docker logs --tail 20 sms-frontend-1'

az vm run-command invoke `
  --resource-group $RESOURCE_GROUP `
  --name $VM_NAME `
  --command-id RunShellScript `
  --scripts $script
