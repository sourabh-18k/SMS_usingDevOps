# Quick Start Guide - SMS DevOps Project

**For instructors and students who want to get started immediately.**

---

## ⚡ 5-Minute Setup (Prerequisites)

1. **Install Required Tools:**
   ```powershell
   # Azure CLI
   winget install Microsoft.AzureCLI
   
   # Terraform
   winget install Hashicorp.Terraform
   
   # Git (if not installed)
   winget install Git.Git
   ```

2. **Clone Repository:**
   ```powershell
   git clone https://github.com/sourabh-18k/SMS_usingDevOps
   cd SMS_usingDevOps
   ```

3. **Login to Azure:**
   ```powershell
   az login
   az account set --subscription "Azure for Students"
   ```

---

## 🚀 Deploy Everything (30 Minutes)

### Step 1: Generate SSH Key (2 min)
```powershell
cd D:\SMS_devOps
.\scripts\generate-ssh-key.ps1
```
**Copy the public key output!**

### Step 2: Configure Terraform (2 min)
```powershell
cd terraform
copy terraform.tfvars.example terraform.tfvars
notepad terraform.tfvars
```

**Edit these lines:**
```hcl
ssh_public_key_path  = "C:/Users/YourName/.ssh/azure_sms_rsa.pub"
db_admin_password    = "YourStrongPassword123!"
```

### Step 3: Deploy to Azure (15 min)
```powershell
.\scripts\deploy-azure.ps1
```
☕ **Wait for completion...**

**Save these outputs:**
- App VM IP: `______________________`
- Monitor VM IP: `______________________`
- Database Host: `______________________`

### Step 4: Configure Servers (10 min)

**For Windows users (use WSL):**
```powershell
wsl --install
# Restart if prompted, then:
wsl
sudo apt update && sudo apt install -y ansible jq
cd /mnt/d/SMS_devOps

# Copy SSH key
cp /mnt/c/Users/YourName/.ssh/azure_sms_rsa ~/.ssh/
chmod 600 ~/.ssh/azure_sms_rsa

# Set environment variables
export APP_VM_IP="YOUR_APP_VM_IP"
export MONITOR_VM_IP="YOUR_MONITOR_VM_IP"
export DB_HOST="YOUR_DB_HOST"
export DB_USER="smsadmin"
export DB_PASSWORD="YourStrongPassword123!"

# Run playbooks
cd ansible
ansible-playbook -i inventory/hosts.yml playbooks/setup-app-server.yml
ansible-playbook -i inventory/hosts.yml playbooks/setup-nagios.yml
ansible-playbook -i inventory/hosts.yml playbooks/deploy-app.yml
```

---

## ✅ Verify Deployment (2 min)

Open these URLs in your browser:

1. **Backend API:**
   ```
   http://YOUR_APP_VM_IP:8080
   ```

2. **Swagger UI:**
   ```
   http://YOUR_APP_VM_IP:8080/swagger-ui/index.html
   ```

3. **Frontend:**
   ```
   http://YOUR_APP_VM_IP:5173
   ```

4. **Nagios:**
   ```
   http://YOUR_MONITOR_VM_IP/nagios
   Username: nagiosadmin
   Password: Admin123!
   ```

**All should be accessible and showing green status!**

---

## 🔧 GitHub Actions Setup (5 min)

1. **Go to:** Repository → Settings → Secrets → Actions

2. **Add these secrets:**

| Secret Name | Value |
|-------------|-------|
| `AZURE_SSH_PRIVATE_KEY` | Content of `~/.ssh/azure_sms_rsa` |
| `AZURE_APP_VM_IP` | Your App VM IP |
| `AZURE_MONITOR_VM_IP` | Your Monitor VM IP |
| `AZURE_DB_HOST` | Your DB Host |
| `AZURE_DB_USER` | `smsadmin` |
| `AZURE_DB_PASSWORD` | Your DB password |
| `JWT_SECRET` | `super-secret-change-me-please-1234567890abcdef` |

3. **Test the Pipeline:**
   ```bash
   echo "<!-- Test -->" >> frontend/index.html
   git add .
   git commit -m "Test CI/CD"
   git push
   ```

4. **Watch:** Go to Actions tab, see pipeline run!

---

## 🧪 Quick Tests

```bash
# Test backend
curl http://YOUR_APP_VM_IP:8080/

# Test login API
curl -X POST http://YOUR_APP_VM_IP:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@sms.dev","password":"ChangeMe123!"}'

# SSH to app VM
ssh azureuser@YOUR_APP_VM_IP
docker ps  # Should see 2 containers running

# Check logs
cd /opt/sms
docker-compose logs backend
```

---

## 🎓 For Classroom Demo

**Before class:**
1. Deploy everything (steps above)
2. Verify all URLs work
3. Take screenshots as backup
4. Review PRESENTATION-GUIDE.md

**During class:**
1. Show running application
2. Show Nagios monitoring
3. Make code change, push, show auto-deploy
4. Show GitHub Actions pipeline

**After class:**
```powershell
# Stop VMs (save costs)
az vm deallocate --resource-group sms-devops-rg --name sms-app-vm
az vm deallocate --resource-group sms-devops-rg --name sms-monitor-vm

# Or destroy everything
cd terraform
terraform destroy
```

---

## 🚨 Troubleshooting

**Can't SSH to VMs?**
```powershell
# Check VMs are running
az vm list -d --resource-group sms-devops-rg -o table

# Start if stopped
az vm start --resource-group sms-devops-rg --name sms-app-vm
```

**Application not responding?**
```bash
ssh azureuser@YOUR_APP_VM_IP
cd /opt/sms
docker-compose restart
```

**Terraform fails?**
```powershell
# Check Azure login
az account show

# Check quotas
az vm list-usage --location "East US"
```

---

## 📚 Full Documentation

- **Complete Guide:** README-DEVOPS.md
- **Presentation Tips:** PRESENTATION-GUIDE.md
- **Original App Docs:** README.md

---

## 💰 Costs

- **Daily:** ~$0.50
- **Weekly:** ~$3-5
- **Monthly:** ~$15-20

**All covered by Azure Student $100 credits!**

**Stop VMs when not using to save costs.**

---

## 🎯 Success Checklist

- [ ] Azure resources deployed
- [ ] Application accessible via browser
- [ ] Nagios showing green status
- [ ] GitHub Actions pipeline successful
- [ ] Can make code change and see auto-deploy
- [ ] Ready for presentation

---

**Need Help?** Check README-DEVOPS.md for detailed troubleshooting.

**Time from zero to running:** ~30-40 minutes  
**Time for presentation prep:** ~1 hour total  
**Difficulty:** Intermediate (following commands)

🚀 **You're ready to impress!**
