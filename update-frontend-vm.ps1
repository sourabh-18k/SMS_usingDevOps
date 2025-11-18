#!/usr/bin/env pwsh

$VM_NAME = "sms-app-vm"
$RESOURCE_GROUP = "sms-devops-rg"

Write-Host "Updating frontend on Azure VM using Run Command..."

# Create the update script
$updateScript = @'
#!/bin/bash
cd /home/azureuser
docker exec sms-frontend-1 sh -c 'cat > /usr/share/nginx/html/index.html << "EOF"
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <link rel="icon" type="image/svg+xml" href="/assets/logo-p2AoECBb.svg" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>SMS DevOps</title>
    <script src="/config.js"></script>
    <script type="module" crossorigin src="/assets/index-BIgbwR2D.js"></script>
    <link rel="stylesheet" crossorigin href="/assets/index-CoJyNNAh.css">
  </head>
  <body class="bg-white">
    <div id="root"></div>
  </body>
</html>
EOF
'

# Copy new JS and CSS files
docker cp /home/azureuser/SMS_usingDevOps/frontend/dist/assets/index-BIgbwR2D.js sms-frontend-1:/usr/share/nginx/html/assets/
docker cp /home/azureuser/SMS_usingDevOps/frontend/dist/assets/index-CoJyNNAh.css sms-frontend-1:/usr/share/nginx/html/assets/

# Reload nginx
docker exec sms-frontend-1 nginx -s reload

echo "Frontend updated successfully!"
'@

# Save the script to a temp file
$tempScript = [System.IO.Path]::GetTempFileName() + ".sh"
$updateScript | Out-File -FilePath $tempScript -Encoding utf8

Write-Host "Running update script on VM..."
az vm run-command invoke `
  --resource-group $RESOURCE_GROUP `
  --name $VM_NAME `
  --command-id RunShellScript `
  --scripts "@$tempScript"

Remove-Item $tempScript

Write-Host "`nFrontend updated! Access at: http://4.218.12.135:5173"
