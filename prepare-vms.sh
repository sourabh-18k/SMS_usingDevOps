#!/bin/bash
# Install Docker on Azure VMs

APP_VM_IP="4.218.14.65"
MONITOR_VM_IP="20.41.80.191"
SSH_KEY="C:\Users\HP\.ssh\azure_sms_rsa"
SSH_USER="azureuser"

echo ""
echo "🚀 Preparing Azure VMs for Deployment"
echo "======================================================================"

# Docker installation commands
INSTALL_CMD='
set -e
echo "Updating packages..."
sudo apt-get update -qq
echo "Installing prerequisites..."
sudo apt-get install -y -qq apt-transport-https ca-certificates curl gnupg lsb-release
sudo install -m 0755 -d /etc/apt/keyrings
echo "Adding Docker GPG key..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo "Adding Docker repository..."
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
echo "Installing Docker..."
sudo apt-get update -qq
sudo apt-get install -y -qq docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
echo "Configuring Docker..."
sudo usermod -aG docker $USER
sudo systemctl start docker
sudo systemctl enable docker
echo "Docker installation complete:"
sudo docker --version
'

echo ""
echo "📦 Installing Docker on App VM ($APP_VM_IP)..."
if ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no ${SSH_USER}@${APP_VM_IP} "$INSTALL_CMD"; then
    echo "✅ Docker installed successfully on App VM"
else
    echo "❌ Failed to install Docker on App VM"
fi

echo ""
echo "📦 Installing Docker on Monitor VM ($MONITOR_VM_IP)..."
if ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no ${SSH_USER}@${MONITOR_VM_IP} "$INSTALL_CMD"; then
    echo "✅ Docker installed successfully on Monitor VM"
else
    echo "❌ Failed to install Docker on Monitor VM"
fi

echo ""
echo "======================================================================"
echo "📊 INSTALLATION COMPLETE"
echo "======================================================================"
echo ""
echo "📝 NEXT STEPS:"
echo "1. Add GitHub Secrets (see GITHUB-SECRETS-VALUES.txt)"
echo "2. Trigger CI/CD pipeline:"
echo "   git commit --allow-empty -m 'Trigger deployment'"
echo "   git push origin main"
echo "3. Monitor: https://github.com/sourabh-18k/SMS_usingDevOps/actions"
echo ""
