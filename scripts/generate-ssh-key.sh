#!/usr/bin/env bash
# SSH Key Generation Script for Azure VMs

set -e

echo "======================================"
echo "SSH Key Setup for Azure Deployment"
echo "======================================"
echo ""

SSH_DIR="$HOME/.ssh"
KEY_NAME="azure_sms_rsa"
KEY_PATH="$SSH_DIR/$KEY_NAME"

# Create .ssh directory if it doesn't exist
mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

# Check if key already exists
if [ -f "$KEY_PATH" ]; then
    echo "⚠️  SSH key already exists at: $KEY_PATH"
    read -p "Do you want to overwrite it? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Using existing key: $KEY_PATH.pub"
        cat "$KEY_PATH.pub"
        exit 0
    fi
fi

# Generate new SSH key
echo "🔑 Generating new SSH key pair..."
ssh-keygen -t rsa -b 4096 -f "$KEY_PATH" -N "" -C "azure-sms-devops"

echo ""
echo "✅ SSH key generated successfully!"
echo ""
echo "Private key: $KEY_PATH"
echo "Public key: $KEY_PATH.pub"
echo ""
echo "======================================"
echo "Your PUBLIC key (copy this):"
echo "======================================"
cat "$KEY_PATH.pub"
echo ""
echo "======================================"
echo ""
echo "📋 Next steps:"
echo "1. Copy the public key above"
echo "2. Update terraform/terraform.tfvars:"
echo "   ssh_public_key_path = \"$KEY_PATH.pub\""
echo ""
echo "3. Add private key to GitHub Secrets:"
echo "   - Go to: Settings > Secrets > Actions"
echo "   - Create: AZURE_SSH_PRIVATE_KEY"
echo "   - Paste content from: $KEY_PATH"
echo ""
echo "To view private key content:"
echo "cat $KEY_PATH"
echo ""
