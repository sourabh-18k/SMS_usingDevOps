# SSH Key Generation Script for Azure VMs (PowerShell)

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "SSH Key Setup for Azure Deployment" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

$sshDir = "$env:USERPROFILE\.ssh"
$keyName = "azure_sms_rsa"
$keyPath = "$sshDir\$keyName"

# Create .ssh directory if it doesn't exist
if (!(Test-Path $sshDir)) {
    New-Item -ItemType Directory -Path $sshDir | Out-Null
}

# Check if key already exists
if (Test-Path $keyPath) {
    Write-Host "⚠️  SSH key already exists at: $keyPath" -ForegroundColor Yellow
    $overwrite = Read-Host "Do you want to overwrite it? (y/N)"
    if ($overwrite -ne 'y' -and $overwrite -ne 'Y') {
        Write-Host "Using existing key: $keyPath.pub" -ForegroundColor Green
        Get-Content "$keyPath.pub"
        exit 0
    }
}

# Generate new SSH key using ssh-keygen
Write-Host "🔑 Generating new SSH key pair..." -ForegroundColor Green
ssh-keygen -t rsa -b 4096 -f $keyPath -N '""' -C "azure-sms-devops"

Write-Host ""
Write-Host "✅ SSH key generated successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Private key: $keyPath" -ForegroundColor Cyan
Write-Host "Public key: $keyPath.pub" -ForegroundColor Cyan
Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Your PUBLIC key (copy this):" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Get-Content "$keyPath.pub"
Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "📋 Next steps:" -ForegroundColor Yellow
Write-Host "1. Copy the public key above"
Write-Host "2. Update terraform/terraform.tfvars:"
Write-Host "   ssh_public_key_path = `"$keyPath.pub`""
Write-Host ""
Write-Host "3. Add private key to GitHub Secrets:"
Write-Host "   - Go to: Settings > Secrets > Actions"
Write-Host "   - Create: AZURE_SSH_PRIVATE_KEY"
Write-Host "   - Paste content from: $keyPath"
Write-Host ""
Write-Host "To view private key content:" -ForegroundColor Yellow
Write-Host "Get-Content $keyPath" -ForegroundColor Cyan
Write-Host ""
