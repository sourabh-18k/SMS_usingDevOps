#!/usr/bin/env bash
# Ansible Configuration and Deployment Script

set -e

echo "======================================"
echo "Ansible Server Configuration"
echo "======================================"
echo ""

# Check prerequisites
command -v ansible >/dev/null 2>&1 || { 
    echo "⚠️  Ansible is not installed. Installing..."
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo apt-get update
        sudo apt-get install -y ansible
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew install ansible
    else
        echo "❌ Please install Ansible manually"
        exit 1
    fi
}

# Navigate to ansible directory
cd "$(dirname "$0")/../ansible"

# Check if outputs.json exists
if [ ! -f "../outputs.json" ]; then
    echo "❌ outputs.json not found. Please run deploy-azure.sh first."
    exit 1
fi

# Extract IPs from Terraform outputs
echo "📋 Reading Terraform outputs..."
APP_VM_IP=$(jq -r '.app_vm_public_ip.value' ../outputs.json)
MONITOR_VM_IP=$(jq -r '.monitor_vm_public_ip.value' ../outputs.json)
DB_HOST=$(jq -r '.postgresql_server_fqdn.value' ../outputs.json)

echo "App VM IP: $APP_VM_IP"
echo "Monitor VM IP: $MONITOR_VM_IP"
echo "Database Host: $DB_HOST"
echo ""

# Export environment variables for Ansible
export APP_VM_IP
export MONITOR_VM_IP
export DB_HOST
export DB_USER=${DB_USER:-smsadmin}
export DB_PASSWORD=${DB_PASSWORD:-ChangeMe123!Strong}
export JWT_SECRET=${JWT_SECRET:-super-secret-change-me-please-1234567890abcdef}

# Test SSH connectivity
echo "🔐 Testing SSH connectivity..."
echo "Testing App VM..."
ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 azureuser@$APP_VM_IP "echo '✅ App VM is reachable'" || {
    echo "❌ Cannot connect to App VM. Please check:"
    echo "   1. VM is running"
    echo "   2. SSH key is correct"
    echo "   3. Network security rules allow SSH"
    exit 1
}

echo "Testing Monitor VM..."
ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 azureuser@$MONITOR_VM_IP "echo '✅ Monitor VM is reachable'" || {
    echo "❌ Cannot connect to Monitor VM"
    exit 1
}

echo ""
echo "======================================"
echo "Step 1: Setup Application Server"
echo "======================================"
echo ""
ansible-playbook -i inventory/hosts.yml playbooks/setup-app-server.yml

echo ""
echo "======================================"
echo "Step 2: Setup Monitoring Server"
echo "======================================"
echo ""
read -p "Do you want to install Nagios now? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    ansible-playbook -i inventory/hosts.yml playbooks/setup-nagios.yml
else
    echo "⏭️  Skipping Nagios installation (you can run it later)"
fi

echo ""
echo "======================================"
echo "Step 3: Deploy Application"
echo "======================================"
echo ""
read -p "Do you want to deploy the application now? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    export GIT_REPO=${GIT_REPO:-}
    export GIT_BRANCH=${GIT_BRANCH:-main}
    ansible-playbook -i inventory/hosts.yml playbooks/deploy-app.yml
else
    echo "⏭️  Skipping application deployment"
fi

echo ""
echo "======================================"
echo "✅ Configuration Complete!"
echo "======================================"
echo ""
echo "📊 Access Points:"
echo "  Backend: http://$APP_VM_IP:8080"
echo "  Frontend: http://$APP_VM_IP:5173"
echo "  Swagger: http://$APP_VM_IP:8080/swagger-ui/index.html"
echo "  Nagios: http://$MONITOR_VM_IP/nagios"
echo ""
echo "🔐 Default Credentials:"
echo "  Nagios: nagiosadmin / Admin123!"
echo ""
