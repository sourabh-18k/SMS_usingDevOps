# GitHub Actions Secrets Setup Guide

This guide explains how to set up the required GitHub Secrets for the CI/CD pipeline.

---

## 📋 Required Secrets

Go to: **Your Repository → Settings → Secrets and variables → Actions → New repository secret**

### 1. AZURE_SSH_PRIVATE_KEY

**Description:** Private SSH key for accessing Azure VMs

**How to get the value:**

**On Windows (PowerShell):**
```powershell
Get-Content C:\Users\YourName\.ssh\azure_sms_rsa
```

**On Linux/WSL:**
```bash
cat ~/.ssh/azure_sms_rsa
```

**Value format:**
```
-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAABlwAAAAdzc2gtcn
NhAAAAAwEAAQAAAYEAw... (many lines)
...
-----END OPENSSH PRIVATE KEY-----
```

⚠️ **Important:** 
- Copy the ENTIRE content including header/footer
- Do NOT add extra spaces or newlines
- Keep this secret safe!

---

### 2. AZURE_APP_VM_IP

**Description:** Public IP address of your application VM

**How to get the value:**

```powershell
# From Terraform outputs
cd terraform
terraform output app_vm_public_ip

# Or from outputs.json
Get-Content ..\outputs.json | ConvertFrom-Json | Select -ExpandProperty app_vm_public_ip | Select -ExpandProperty value

# Or from Azure CLI
az network public-ip show --resource-group sms-devops-rg --name sms-app-pip --query ipAddress -o tsv
```

**Value format:**
```
20.XXX.XXX.XXX
```

---

### 3. AZURE_MONITOR_VM_IP

**Description:** Public IP address of your monitoring VM

**How to get the value:**

```powershell
# From Terraform outputs
cd terraform
terraform output monitor_vm_public_ip

# Or from Azure CLI
az network public-ip show --resource-group sms-devops-rg --name sms-monitor-pip --query ipAddress -o tsv
```

**Value format:**
```
20.YYY.YYY.YYY
```

---

### 4. AZURE_DB_HOST

**Description:** Fully qualified domain name of PostgreSQL server

**How to get the value:**

```powershell
# From Terraform outputs
cd terraform
terraform output postgresql_server_fqdn

# Or from Azure CLI
az postgres flexible-server show --resource-group sms-devops-rg --name sms-psql-server --query fullyQualifiedDomainName -o tsv
```

**Value format:**
```
sms-psql-server.postgres.database.azure.com
```

---

### 5. AZURE_DB_USER

**Description:** PostgreSQL admin username

**Value:**
```
smsadmin
```

(Or whatever you set in `terraform.tfvars` as `db_admin_username`)

---

### 6. AZURE_DB_PASSWORD

**Description:** PostgreSQL admin password

**Value:**
```
YourStrongPassword123!
```

(Whatever you set in `terraform.tfvars` as `db_admin_password`)

⚠️ **Important:** This should be a strong password!

---

### 7. JWT_SECRET

**Description:** Secret key for JWT token signing

**Value:**
```
super-secret-change-me-please-1234567890abcdef
```

**Recommended:** Generate a random 64-character string:

```powershell
# Generate random JWT secret
$bytes = New-Object Byte[] 32
[Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($bytes)
[Convert]::ToBase64String($bytes)
```

⚠️ **Important:** Must be at least 32 characters!

---

## ✅ Verification Checklist

After adding all secrets, verify:

- [ ] All 7 secrets are added
- [ ] Secret names match exactly (case-sensitive)
- [ ] No extra spaces in values
- [ ] Private key includes header/footer lines
- [ ] IP addresses are correct and VMs are accessible
- [ ] Database password matches Terraform config
- [ ] JWT secret is at least 32 characters

---

## 🧪 Test the Secrets

After adding secrets, test the pipeline:

```bash
# Make a small change
echo "<!-- Test secrets -->" >> README.md
git add .
git commit -m "Test: Verify GitHub Actions secrets"
git push origin main
```

**Expected Result:**
1. Go to: **Actions** tab
2. See workflow running
3. All jobs should succeed (green checkmarks)
4. "Deploy to Azure" job should complete successfully

**If deployment fails:**
- Check logs in GitHub Actions
- Verify secrets are correct
- Ensure VMs are running and accessible
- Test SSH manually: `ssh azureuser@YOUR_APP_VM_IP`

---

## 🔒 Security Best Practices

### ✅ DO:
- Keep secrets in GitHub Secrets (never in code)
- Use strong passwords (16+ characters)
- Rotate secrets periodically
- Use different passwords for different environments

### ❌ DON'T:
- Commit secrets to Git
- Share secrets in Slack/Email
- Use weak passwords
- Reuse passwords across projects

---

## 📸 Screenshot Guide

### Adding a Secret:

1. **Navigate to Settings:**
   ```
   Repository → Settings → Secrets and variables → Actions
   ```

2. **Click "New repository secret"**

3. **Enter Name and Value:**
   - Name: `AZURE_SSH_PRIVATE_KEY` (exact spelling)
   - Value: (paste your private key)

4. **Click "Add secret"**

5. **Repeat for all 7 secrets**

### Viewing Secrets:

- You can see secret **names** but not **values**
- To update: Click secret name → Update
- To delete: Click secret name → Remove

---

## 🚨 Troubleshooting

### "Secret not found" error:
- Check secret name spelling (case-sensitive)
- Verify secret is in correct repository
- Ensure workflow YAML uses correct variable name

### "Permission denied" SSH error:
- Verify private key is complete
- Check key has no extra whitespace
- Ensure key matches the public key in Terraform

### "Database connection refused":
- Verify DB_HOST is FQDN (not IP)
- Check DB_USER and DB_PASSWORD are correct
- Ensure firewall allows GitHub Actions IPs

### "JWT secret too short":
- Ensure JWT_SECRET is at least 32 characters
- No spaces or special characters that might be escaped

---

## 🔄 Updating Secrets

If you need to change a secret:

1. **In Azure:**
   ```powershell
   # Example: Change VM
   cd terraform
   terraform destroy -target=azurerm_linux_virtual_machine.app_vm
   terraform apply
   ```

2. **Get new value:**
   ```powershell
   terraform output app_vm_public_ip
   ```

3. **Update in GitHub:**
   - Go to repository secrets
   - Click the secret name
   - Update value
   - Save

4. **Re-run workflow:**
   - Go to Actions tab
   - Select latest workflow
   - Click "Re-run all jobs"

---

## 📝 Secrets Summary

| Secret | Source | Purpose |
|--------|--------|---------|
| `AZURE_SSH_PRIVATE_KEY` | `~/.ssh/azure_sms_rsa` | SSH to VMs |
| `AZURE_APP_VM_IP` | Terraform output | Backend/Frontend host |
| `AZURE_MONITOR_VM_IP` | Terraform output | Nagios host |
| `AZURE_DB_HOST` | Terraform output | Database connection |
| `AZURE_DB_USER` | `terraform.tfvars` | Database auth |
| `AZURE_DB_PASSWORD` | `terraform.tfvars` | Database auth |
| `JWT_SECRET` | Your choice | JWT signing |

---

## 🎯 Quick Copy-Paste Commands

**Get all values at once:**

```powershell
cd D:\SMS_devOps\terraform

Write-Host "=== GitHub Secrets Values ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. AZURE_SSH_PRIVATE_KEY:" -ForegroundColor Yellow
Get-Content C:\Users\$env:USERNAME\.ssh\azure_sms_rsa
Write-Host ""
Write-Host "2. AZURE_APP_VM_IP:" -ForegroundColor Yellow
terraform output -raw app_vm_public_ip
Write-Host ""
Write-Host "3. AZURE_MONITOR_VM_IP:" -ForegroundColor Yellow
terraform output -raw monitor_vm_public_ip
Write-Host ""
Write-Host "4. AZURE_DB_HOST:" -ForegroundColor Yellow
terraform output -raw postgresql_server_fqdn
Write-Host ""
Write-Host "5. AZURE_DB_USER: smsadmin" -ForegroundColor Yellow
Write-Host "6. AZURE_DB_PASSWORD: (from your terraform.tfvars)" -ForegroundColor Yellow
Write-Host "7. JWT_SECRET: super-secret-change-me-please-1234567890abcdef" -ForegroundColor Yellow
```

---

**Once all secrets are configured, your CI/CD pipeline is ready! 🚀**
