# Azure Infrastructure Deployment Script (PowerShell)

$ErrorActionPreference = "Stop"

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Azure Infrastructure Deployment" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# Check prerequisites
Write-Host "🔍 Checking prerequisites..." -ForegroundColor Yellow

if (!(Get-Command terraform -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Terraform is not installed. Please install it first." -ForegroundColor Red
    Write-Host "Download from: https://www.terraform.io/downloads" -ForegroundColor Yellow
    exit 1
}

if (!(Get-Command az -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Azure CLI is not installed. Please install it first." -ForegroundColor Red
    Write-Host "Download from: https://aka.ms/installazurecliwindows" -ForegroundColor Yellow
    exit 1
}

# Check Azure login
Write-Host "🔐 Checking Azure login status..." -ForegroundColor Yellow
try {
    $account = az account show 2>$null | ConvertFrom-Json
    Write-Host "✅ Logged in to Azure" -ForegroundColor Green
    Write-Host ""
    Write-Host "Current Subscription:" -ForegroundColor Cyan
    Write-Host "  Name: $($account.name)"
    Write-Host "  ID: $($account.id)"
    Write-Host "  Tenant: $($account.tenantId)"
    Write-Host ""
} catch {
    Write-Host "❌ Not logged in to Azure. Please run: az login" -ForegroundColor Red
    exit 1
}

$confirm = Read-Host "Is this the correct subscription? (y/N)"
if ($confirm -ne 'y' -and $confirm -ne 'Y') {
    Write-Host "Available subscriptions:" -ForegroundColor Yellow
    az account list --query "[].{Name:name, SubscriptionId:id}" -o table
    Write-Host ""
    $subId = Read-Host "Enter subscription ID"
    az account set --subscription $subId
}

# Navigate to terraform directory
$scriptDir = Split-Path -Parent $PSCommandPath
$terraformDir = Join-Path $scriptDir "..\terraform"
Set-Location $terraformDir

# Check if terraform.tfvars exists
if (!(Test-Path "terraform.tfvars")) {
    Write-Host "⚠️  terraform.tfvars not found. Creating from example..." -ForegroundColor Yellow
    Copy-Item "terraform.tfvars.example" "terraform.tfvars"
    Write-Host ""
    Write-Host "📝 Please edit terraform/terraform.tfvars with your values:" -ForegroundColor Yellow
    Write-Host "   - ssh_public_key_path"
    Write-Host "   - db_admin_password"
    Write-Host ""
    Read-Host "Press Enter after editing terraform.tfvars..."
}

# Initialize Terraform
Write-Host ""
Write-Host "🔧 Initializing Terraform..." -ForegroundColor Yellow
terraform init

# Validate configuration
Write-Host ""
Write-Host "✅ Validating Terraform configuration..." -ForegroundColor Yellow
terraform validate

# Plan deployment
Write-Host ""
Write-Host "📋 Planning deployment..." -ForegroundColor Yellow
terraform plan -out=tfplan

Write-Host ""
$apply = Read-Host "Do you want to apply this plan? (y/N)"
if ($apply -ne 'y' -and $apply -ne 'Y') {
    Write-Host "Deployment cancelled." -ForegroundColor Yellow
    exit 0
}

# Apply deployment
Write-Host ""
Write-Host "🚀 Deploying infrastructure to Azure..." -ForegroundColor Green
terraform apply tfplan

# Save outputs
Write-Host ""
Write-Host "💾 Saving outputs..." -ForegroundColor Yellow
terraform output -json | Out-File -FilePath "..\outputs.json" -Encoding UTF8
terraform output | Out-File -FilePath "..\outputs.txt" -Encoding UTF8

Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "✅ Deployment Complete!" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# Display important outputs
Write-Host "📊 Important Information:" -ForegroundColor Yellow
Write-Host ""
terraform output

Write-Host ""
Write-Host "📋 Next Steps:" -ForegroundColor Yellow
Write-Host "1. Update ansible/inventory/hosts.yml with the VM IPs"
Write-Host "2. Run Ansible playbooks to configure servers"
Write-Host "3. Set up GitHub Actions secrets"
Write-Host ""
Write-Host "All outputs saved to:" -ForegroundColor Cyan
Write-Host "  - outputs.json (JSON format)"
Write-Host "  - outputs.txt (text format)"
Write-Host ""
