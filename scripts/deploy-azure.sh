#!/usr/bin/env bash
# Azure Infrastructure Deployment Script

set -e

echo "======================================"
echo "Azure Infrastructure Deployment"
echo "======================================"
echo ""

# Check prerequisites
command -v terraform >/dev/null 2>&1 || { echo "❌ Terraform is not installed. Please install it first."; exit 1; }
command -v az >/dev/null 2>&1 || { echo "❌ Azure CLI is not installed. Please install it first."; exit 1; }

# Check Azure login
echo "🔐 Checking Azure login status..."
if ! az account show >/dev/null 2>&1; then
    echo "❌ Not logged in to Azure. Please run: az login"
    exit 1
fi

# Display current subscription
echo "✅ Logged in to Azure"
echo ""
az account show --query "{Name:name, SubscriptionId:id, TenantId:tenantId}" -o table
echo ""

read -p "Is this the correct subscription? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Please select the correct subscription:"
    az account list --query "[].{Name:name, SubscriptionId:id}" -o table
    echo ""
    read -p "Enter subscription ID: " SUB_ID
    az account set --subscription "$SUB_ID"
fi

# Navigate to terraform directory
cd "$(dirname "$0")/../terraform"

# Check if terraform.tfvars exists
if [ ! -f "terraform.tfvars" ]; then
    echo "⚠️  terraform.tfvars not found. Creating from example..."
    cp terraform.tfvars.example terraform.tfvars
    echo ""
    echo "📝 Please edit terraform/terraform.tfvars with your values:"
    echo "   - ssh_public_key_path"
    echo "   - db_admin_password"
    echo ""
    read -p "Press Enter after editing terraform.tfvars..." 
fi

# Initialize Terraform
echo ""
echo "🔧 Initializing Terraform..."
terraform init

# Validate configuration
echo ""
echo "✅ Validating Terraform configuration..."
terraform validate

# Plan deployment
echo ""
echo "📋 Planning deployment..."
terraform plan -out=tfplan

echo ""
read -p "Do you want to apply this plan? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Deployment cancelled."
    exit 0
fi

# Apply deployment
echo ""
echo "🚀 Deploying infrastructure to Azure..."
terraform apply tfplan

# Save outputs
echo ""
echo "💾 Saving outputs..."
terraform output -json > ../outputs.json
terraform output > ../outputs.txt

echo ""
echo "======================================"
echo "✅ Deployment Complete!"
echo "======================================"
echo ""

# Display important outputs
echo "📊 Important Information:"
echo ""
terraform output -json | jq -r '
  "App VM IP: \(.app_vm_public_ip.value)",
  "Monitor VM IP: \(.monitor_vm_public_ip.value)",
  "Database Host: \(.postgresql_server_fqdn.value)",
  "",
  "SSH Commands:",
  "  App VM: \(.app_vm_ssh_command.value)",
  "  Monitor VM: \(.monitor_vm_ssh_command.value)",
  "",
  "Application URLs:",
  "  Backend: \(.backend_url.value)",
  "  Frontend: \(.frontend_url.value)",
  "  Swagger: \(.backend_url.value)/swagger-ui/index.html",
  "",
  "Monitoring:",
  "  Nagios: \(.nagios_url.value)"
'

echo ""
echo "📋 Next Steps:"
echo "1. Update ansible/inventory/hosts.yml with the VM IPs"
echo "2. Run Ansible playbooks to configure servers"
echo "3. Set up GitHub Actions secrets"
echo ""
echo "All outputs saved to:"
echo "  - outputs.json (JSON format)"
echo "  - outputs.txt (text format)"
echo ""
