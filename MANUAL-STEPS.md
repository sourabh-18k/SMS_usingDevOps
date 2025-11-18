# 📋 Manual Steps Required - What YOU Need to Do

This document lists **ONLY** the actions that require your manual input or credentials. Everything else has been automated.

---

## ✋ Step 1: Install Prerequisites (One-Time Setup)

**You must install these tools on your Windows machine:**

### Install Azure CLI
```powershell
winget install Microsoft.AzureCLI
# OR download from: https://aka.ms/installazurecliwindows
```

### Install Terraform
```powershell
winget install Hashicorp.Terraform
# OR download from: https://www.terraform.io/downloads
```

### Install WSL2 (for Ansible)
```powershell
wsl --install
# Restart computer when prompted
```

**Why:** These tools cannot be installed automatically and are required for deployment.

---

## ✋ Step 2: Login to Azure

**Run this command and follow browser prompts:**
```powershell
az login
```

**Then verify subscription:**
```powershell
az account show
```

**If wrong subscription, select correct one:**
```powershell
az account set --subscription "Azure for Students"
```

**Why:** Azure needs to authenticate you before creating resources.

---

## ✋ Step 3: Generate SSH Keys

**Run the script:**
```powershell
cd D:\SMS_devOps
.\scripts\generate-ssh-key.ps1
```

**Follow prompts:**
- Press Enter when asked (uses default location)
- Keys saved to: `C:\Users\YourName\.ssh\azure_sms_rsa`

**IMPORTANT: Copy the public key displayed on screen!**

**Why:** Azure VMs require SSH keys for secure access.

---

## ✋ Step 4: Edit Terraform Configuration

**Open and edit this file:**
```powershell
cd terraform
copy terraform.tfvars.example terraform.tfvars
notepad terraform.tfvars
```

**Change ONLY these two lines:**
```hcl
ssh_public_key_path  = "C:/Users/YourName/.ssh/azure_sms_rsa.pub"  # ← YOUR path
db_admin_password    = "ChangeThisPassword123!"                     # ← YOUR password
```

**Replace:**
- `YourName` with your Windows username
- `ChangeThisPassword123!` with a strong password (min 8 chars, use letters, numbers, symbols)

**Save and close the file.**

**Why:** Terraform needs your SSH key path and you must set a secure database password.

---

## ✋ Step 5: Confirm Terraform Deployment

**Run the deployment script:**
```powershell
cd D:\SMS_devOps
.\scripts\deploy-azure.ps1
```

**You'll see a plan of resources to be created.**

**When prompted:**
```
Do you want to apply this plan? (y/N):
```

**Type:** `y` and press Enter

**Then wait 10-15 minutes for deployment.**

**IMPORTANT: Save these outputs shown at the end:**
```
App VM IP: ______________________ (write it down!)
Monitor VM IP: __________________ (write it down!)
Database Host: __________________ (write it down!)
```

**Why:** You must confirm resource creation to proceed, and you'll need these IPs later.

---

## ✋ Step 6: Setup WSL and Ansible (First Time Only)

**Open WSL terminal:**
```powershell
wsl
```

**Install Ansible (inside WSL):**
```bash
sudo apt update
sudo apt install -y ansible jq
```

**Copy your SSH key to WSL:**
```bash
# Replace YourName with your Windows username
cp /mnt/c/Users/YourName/.ssh/azure_sms_rsa ~/.ssh/
chmod 600 ~/.ssh/azure_sms_rsa
```

**Why:** Ansible runs on Linux, so we use WSL. SSH key must be accessible from WSL.

---

## ✋ Step 7: Set Environment Variables (in WSL)

**In WSL terminal, set these variables:**
```bash
export APP_VM_IP="20.XXX.XXX.XXX"        # ← YOUR App VM IP from Step 5
export MONITOR_VM_IP="20.YYY.YYY.YYY"    # ← YOUR Monitor VM IP from Step 5
export DB_HOST="sms-psql-server.postgres.database.azure.com"  # ← YOUR DB Host from Step 5
export DB_USER="smsadmin"
export DB_PASSWORD="ChangeThisPassword123!"  # ← YOUR password from Step 4
export JWT_SECRET="super-secret-change-me-please-1234567890abcdef"
```

**Replace the placeholder IPs and password with your actual values!**

**Verify they're set:**
```bash
echo $APP_VM_IP
echo $MONITOR_VM_IP
echo $DB_HOST
```

**Why:** Ansible needs these values to configure your servers correctly.

---

## ✋ Step 8: Run Ansible Playbooks

**Navigate to project (in WSL):**
```bash
cd /mnt/d/SMS_devOps/ansible
# Adjust path if your project is in a different location
```

**Test connectivity:**
```bash
ansible all -i inventory/hosts.yml -m ping
```

**If successful (says "pong"), run playbooks one by one:**

### Setup Application Server (~8 min)
```bash
ansible-playbook -i inventory/hosts.yml playbooks/setup-app-server.yml
```

**Wait for completion. Should see all "ok" or "changed" status.**

### Setup Monitoring Server (~10 min)
```bash
ansible-playbook -i inventory/hosts.yml playbooks/setup-nagios.yml
```

**Wait for completion.**

### Deploy Application (~5 min)
```bash
ansible-playbook -i inventory/hosts.yml playbooks/deploy-app.yml
```

**Wait for completion.**

**Why:** These playbooks automate server configuration, but you must run them manually.

---

## ✋ Step 9: Verify Deployment

**Open these URLs in your browser:**

1. **Backend API:**
   ```
   http://YOUR_APP_VM_IP:8080
   ```
   Should return: JSON response or HTML page

2. **Frontend:**
   ```
   http://YOUR_APP_VM_IP:5173
   ```
   Should show: Login page

3. **Swagger UI:**
   ```
   http://YOUR_APP_VM_IP:8080/swagger-ui/index.html
   ```
   Should show: API documentation

4. **Nagios:**
   ```
   http://YOUR_MONITOR_VM_IP/nagios
   ```
   Username: `nagiosadmin`
   Password: `Admin123!`

**All should be accessible! ✅**

**Why:** Manual verification ensures everything deployed correctly.

---

## ✋ Step 10: Setup GitHub Secrets

**Go to your GitHub repository:**
```
https://github.com/YOUR_USERNAME/SMS_usingDevOps
```

**Navigate to:**
```
Settings → Secrets and variables → Actions → New repository secret
```

**Add these 7 secrets one by one:**

### 1. AZURE_SSH_PRIVATE_KEY
**Get value:**
```powershell
Get-Content C:\Users\YourName\.ssh\azure_sms_rsa
```
**Copy entire output** (including `-----BEGIN` and `-----END` lines)

### 2. AZURE_APP_VM_IP
**Value:** Your App VM IP (from Step 5)

### 3. AZURE_MONITOR_VM_IP
**Value:** Your Monitor VM IP (from Step 5)

### 4. AZURE_DB_HOST
**Value:** Your Database Host (from Step 5)

### 5. AZURE_DB_USER
**Value:** `smsadmin`

### 6. AZURE_DB_PASSWORD
**Value:** Your database password (from Step 4)

### 7. JWT_SECRET
**Value:** `super-secret-change-me-please-1234567890abcdef`

**Click "Add secret" for each one.**

**Why:** GitHub Actions needs these to deploy your application automatically.

---

## ✋ Step 11: Test CI/CD Pipeline

**Make a small code change:**
```bash
echo "<!-- Test CI/CD -->" >> README.md
git add .
git commit -m "Test: Automated deployment"
git push origin main
```

**Then go to:**
```
https://github.com/YOUR_USERNAME/SMS_usingDevOps/actions
```

**Watch the pipeline run. Should see:**
- ✅ Backend Build & Test
- ✅ Frontend Build & Test
- ✅ Docker Build
- ✅ Security Scan
- ✅ Deploy to Azure
- ✅ Smoke Tests

**All should be green checkmarks after ~6-10 minutes.**

**Why:** Verifies that automated deployment works when you push code.

---

## ✋ Step 12: Stop VMs to Save Costs (After Demo)

**When you're done for the day:**
```powershell
az vm deallocate --resource-group sms-devops-rg --name sms-app-vm
az vm deallocate --resource-group sms-devops-rg --name sms-monitor-vm
```

**To restart later:**
```powershell
az vm start --resource-group sms-devops-rg --name sms-app-vm
az vm start --resource-group sms-devops-rg --name sms-monitor-vm
```

**Why:** Saves Azure credits. Stopped VMs don't incur compute charges.

---

## ✋ Step 13: Complete Cleanup (After Presentation)

**To delete everything:**
```powershell
cd D:\SMS_devOps\terraform
terraform destroy
```

**Type:** `yes` when prompted

**Wait ~5-10 minutes. All Azure resources will be deleted.**

**Why:** Removes all resources and stops all charges.

---

## 📊 Summary of What You Do vs. What's Automated

### ✋ You Must Do Manually (13 steps):
1. Install tools (Azure CLI, Terraform, WSL)
2. Login to Azure
3. Generate SSH keys
4. Edit terraform.tfvars (2 values)
5. Confirm Terraform deployment
6. Setup WSL and Ansible
7. Set environment variables
8. Run Ansible playbooks (3 commands)
9. Verify deployment (open URLs)
10. Add GitHub secrets (7 secrets)
11. Test CI/CD pipeline (push code)
12. Stop VMs when done (cost management)
13. Cleanup resources (when completely done)

### 🤖 Automated by Scripts:
- Azure resource creation (VMs, database, networking)
- Server configuration (Docker, Java, Node.js, packages)
- Application deployment (Docker containers)
- Nagios installation and configuration
- GitHub Actions pipeline (build, test, deploy)
- Health checks and monitoring
- Security scanning
- Container image building

---

## ⏱️ Time Estimates

| Task | Time | Difficulty |
|------|------|------------|
| Install prerequisites | 10 min | Easy |
| Azure login | 2 min | Easy |
| Generate SSH keys | 2 min | Easy |
| Edit Terraform config | 3 min | Easy |
| Terraform deployment | 15 min | Automated* |
| WSL setup | 5 min | Medium |
| Ansible execution | 25 min | Automated* |
| Verification | 5 min | Easy |
| GitHub secrets | 10 min | Easy |
| Test pipeline | 10 min | Easy |
| **TOTAL** | **~90 min** | **Intermediate** |

*Automated = You run one command and wait

---

## 🎯 What If I Get Stuck?

### Azure Login Issues
**Problem:** `az login` fails  
**Solution:** 
- Check internet connection
- Try: `az login --use-device-code`
- Verify Azure Student subscription is active

### Terraform Fails
**Problem:** Resources can't be created  
**Solution:**
- Check Azure subscription has credits
- Verify quotas: `az vm list-usage --location "East US"`
- Try different region in `terraform.tfvars`

### Can't SSH to VMs
**Problem:** Connection timeout  
**Solution:**
- Verify VMs are running in Azure Portal
- Check NSG allows SSH: `az network nsg rule list --resource-group sms-devops-rg --nsg-name sms-nsg`
- Wait 5 minutes after VM creation
- Try from Azure Cloud Shell

### Ansible Playbook Fails
**Problem:** Tasks fail or timeout  
**Solution:**
- Verify environment variables are set: `echo $APP_VM_IP`
- Test SSH: `ssh azureuser@$APP_VM_IP`
- Check VM has internet access
- Re-run playbook (it's idempotent)

### GitHub Actions Fails
**Problem:** Deployment job fails  
**Solution:**
- Verify all 7 secrets are added correctly
- Check secret names (case-sensitive, no typos)
- Ensure private key includes header/footer lines
- Verify VMs are running
- Check workflow logs for specific error

### Application Not Accessible
**Problem:** URLs don't load  
**Solution:**
- SSH to VM: `ssh azureuser@$APP_VM_IP`
- Check containers: `docker ps`
- View logs: `cd /opt/sms; docker-compose logs`
- Restart: `docker-compose restart`
- Check NSG allows ports 8080 and 5173

---

## 📚 Need More Help?

**Detailed guides available:**
- **DEPLOYMENT-CHECKLIST.md** - Step-by-step checklist
- **README-DEVOPS.md** - Complete technical documentation
- **QUICKSTART.md** - Fast setup guide
- **GITHUB-SECRETS-GUIDE.md** - Secrets setup details

**For troubleshooting:**
- Check Azure Portal for resource status
- Review Terraform/Ansible output logs
- Check GitHub Actions workflow logs
- SSH to VMs and check application logs

---

## ✅ You're Ready When:

- [ ] All 7 secrets added to GitHub
- [ ] Application accessible at all 4 URLs
- [ ] Nagios shows all services green
- [ ] GitHub Actions pipeline succeeded once
- [ ] You understand what each component does

**Then you're ready to present! 🎉**

---

**Total manual effort:** ~1.5 hours  
**Result:** Production-grade DevOps pipeline  
**Maintenance:** Stop VMs when not using  
**Cleanup:** `terraform destroy` when done  

**You've got this! 🚀**
