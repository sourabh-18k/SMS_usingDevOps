# ✅ Complete Deployment Checklist

Use this checklist to ensure everything is set up correctly for your demo.

---

## 📋 Phase 1: Prerequisites (15 minutes)

### Local Machine Setup
- [ ] Windows 10/11 with PowerShell 5.1+
- [ ] Azure CLI installed (`az --version`)
- [ ] Terraform installed (`terraform --version`)
- [ ] Git installed (`git --version`)
- [ ] WSL2 installed (for Ansible)
- [ ] SSH client available (`ssh -V`)

### Azure Account
- [ ] Azure Student subscription activated
- [ ] Logged in via Azure CLI (`az login`)
- [ ] Correct subscription selected (`az account show`)
- [ ] At least $15 in remaining credits

### Repository
- [ ] Repository cloned locally
- [ ] On main branch (`git branch`)
- [ ] Latest changes pulled (`git pull`)
- [ ] GitHub account has admin access

---

## 🔑 Phase 2: SSH Key Setup (5 minutes)

- [ ] Run: `.\scripts\generate-ssh-key.ps1`
- [ ] SSH key pair generated successfully
- [ ] Public key displayed on screen
- [ ] Public key saved: `C:\Users\YourName\.ssh\azure_sms_rsa.pub`
- [ ] Private key saved: `C:\Users\YourName\.ssh\azure_sms_rsa`
- [ ] Public key copied to clipboard (for next steps)

**Checkpoint:** Can you view both files?
```powershell
Get-Content ~/.ssh/azure_sms_rsa.pub
Get-Content ~/.ssh/azure_sms_rsa
```

---

## ⚙️ Phase 3: Terraform Configuration (5 minutes)

- [ ] Navigate to: `cd terraform`
- [ ] Copy example: `copy terraform.tfvars.example terraform.tfvars`
- [ ] Edit: `notepad terraform.tfvars`
- [ ] Update `ssh_public_key_path` with your path
- [ ] Update `db_admin_password` (strong password!)
- [ ] Save and close file
- [ ] Verify syntax: `terraform validate` (after `terraform init`)

**Checkpoint:** Does terraform.tfvars exist and contain your values?
```powershell
Test-Path terraform.tfvars
Get-Content terraform.tfvars
```

---

## 🚀 Phase 4: Deploy to Azure (15 minutes)

- [ ] Run: `.\scripts\deploy-azure.ps1`
- [ ] Terraform initializes successfully
- [ ] Plan shows resources to be created
- [ ] Confirm deployment (type 'y')
- [ ] Wait for completion (~10-15 minutes)
- [ ] Deployment successful (green text)
- [ ] Outputs displayed on screen
- [ ] Outputs saved to `outputs.json` and `outputs.txt`

### Record These Values:
```
App VM IP: _____________________
Monitor VM IP: _____________________
Database Host: _____________________
```

**Checkpoint:** Can you access Azure Portal?
- [ ] Go to: portal.azure.com
- [ ] Find resource group: `sms-devops-rg`
- [ ] See 2 VMs, 1 Database, networking resources

**Checkpoint:** Can you SSH to VMs?
```powershell
ssh azureuser@YOUR_APP_VM_IP
# Should connect without password
exit

ssh azureuser@YOUR_MONITOR_VM_IP
# Should connect without password
exit
```

---

## 🔧 Phase 5: Configure Servers with Ansible (15 minutes)

### Setup WSL (first time only)
- [ ] Run: `wsl --install`
- [ ] Restart computer if prompted
- [ ] Open Ubuntu (WSL)
- [ ] Update packages: `sudo apt update`
- [ ] Install Ansible: `sudo apt install -y ansible jq`
- [ ] Verify: `ansible --version`

### Copy SSH Key to WSL
```bash
# In WSL terminal
cp /mnt/c/Users/YourName/.ssh/azure_sms_rsa ~/.ssh/
chmod 600 ~/.ssh/azure_sms_rsa
ls -la ~/.ssh/azure_sms_rsa  # Verify it exists
```
- [ ] SSH key copied to WSL
- [ ] Permissions set to 600

### Set Environment Variables
```bash
export APP_VM_IP="YOUR_APP_VM_IP"
export MONITOR_VM_IP="YOUR_MONITOR_VM_IP"
export DB_HOST="YOUR_DB_HOST"
export DB_USER="smsadmin"
export DB_PASSWORD="YOUR_DB_PASSWORD"
export JWT_SECRET="super-secret-change-me-please-1234567890abcdef"
```
- [ ] All environment variables set
- [ ] Verify: `echo $APP_VM_IP` (should show your IP)

### Navigate to Project
```bash
cd /mnt/d/SMS_devOps  # Adjust to your path
```
- [ ] In correct directory
- [ ] Verify: `ls -la` (should see ansible/, terraform/, etc.)

### Test Connectivity
```bash
cd ansible
ansible all -i inventory/hosts.yml -m ping
```
- [ ] App VM responds with SUCCESS
- [ ] Monitor VM responds with SUCCESS

### Run Playbooks
```bash
# Setup application server (~8 minutes)
ansible-playbook -i inventory/hosts.yml playbooks/setup-app-server.yml
```
- [ ] Playbook completes successfully
- [ ] All tasks show 'ok' or 'changed'
- [ ] No failed tasks

```bash
# Setup monitoring server (~10 minutes)
ansible-playbook -i inventory/hosts.yml playbooks/setup-nagios.yml
```
- [ ] Playbook completes successfully
- [ ] Nagios installed and running
- [ ] Apache started

```bash
# Deploy application (~5 minutes)
ansible-playbook -i inventory/hosts.yml playbooks/deploy-app.yml
```
- [ ] Application deployed
- [ ] Containers started
- [ ] Health check passed

**Checkpoint:** Can you access the application?
- [ ] Backend: `http://APP_VM_IP:8080` (returns response)
- [ ] Frontend: `http://APP_VM_IP:5173` (shows UI)
- [ ] Swagger: `http://APP_VM_IP:8080/swagger-ui/index.html` (loads)
- [ ] Nagios: `http://MONITOR_VM_IP/nagios` (login works)

---

## 🔐 Phase 6: GitHub Actions Setup (10 minutes)

### Navigate to GitHub Repository
- [ ] Open: `https://github.com/YOUR_USERNAME/YOUR_REPO`
- [ ] Go to: Settings → Secrets and variables → Actions

### Add Secrets (one by one)

**1. AZURE_SSH_PRIVATE_KEY**
```powershell
Get-Content C:\Users\YourName\.ssh\azure_sms_rsa
```
- [ ] Copy entire output (including headers)
- [ ] Paste into secret value
- [ ] Secret added

**2. AZURE_APP_VM_IP**
- [ ] Value: Your App VM IP
- [ ] Secret added

**3. AZURE_MONITOR_VM_IP**
- [ ] Value: Your Monitor VM IP
- [ ] Secret added

**4. AZURE_DB_HOST**
- [ ] Value: Your PostgreSQL FQDN
- [ ] Secret added

**5. AZURE_DB_USER**
- [ ] Value: `smsadmin`
- [ ] Secret added

**6. AZURE_DB_PASSWORD**
- [ ] Value: Your DB password (from terraform.tfvars)
- [ ] Secret added

**7. JWT_SECRET**
- [ ] Value: `super-secret-change-me-please-1234567890abcdef`
- [ ] Secret added

### Verify Secrets
- [ ] All 7 secrets visible in list
- [ ] No typos in secret names
- [ ] Secret names are UPPERCASE with underscores

**Checkpoint:** Test the pipeline
```bash
# Make a small change
echo "<!-- Test pipeline -->" >> README.md
git add .
git commit -m "Test: CI/CD pipeline"
git push origin main
```
- [ ] Go to: Actions tab
- [ ] See workflow running
- [ ] All jobs succeed (green checkmarks)
- [ ] Deployment completes
- [ ] Smoke tests pass

---

## ✅ Phase 7: Final Verification (10 minutes)

### Application Access
- [ ] Backend API responds: `curl http://APP_VM_IP:8080/`
- [ ] Frontend loads in browser: `http://APP_VM_IP:5173`
- [ ] Can login with: `admin@sms.dev` / `ChangeMe123!`
- [ ] Swagger UI accessible: `http://APP_VM_IP:8080/swagger-ui/index.html`
- [ ] Can execute API calls in Swagger

### Monitoring Access
- [ ] Nagios loads: `http://MONITOR_VM_IP/nagios`
- [ ] Can login: `nagiosadmin` / `Admin123!`
- [ ] All hosts are UP (green)
- [ ] All services are OK (green)
- [ ] Can view service details

### GitHub Actions
- [ ] Latest workflow run succeeded
- [ ] All 6 jobs completed
- [ ] No red X's in Actions tab
- [ ] Deployment time < 10 minutes

### SSH Access
```bash
# Test SSH to App VM
ssh azureuser@APP_VM_IP
docker ps  # Should see 2 containers
docker-compose logs backend  # Should see Spring Boot logs
exit

# Test SSH to Monitor VM
ssh azureuser@MONITOR_VM_IP
sudo systemctl status nagios  # Should be active (running)
exit
```
- [ ] Can SSH to both VMs
- [ ] Containers running on App VM
- [ ] Nagios running on Monitor VM

---

## 🎬 Phase 8: Presentation Preparation (30 minutes)

### Documentation Review
- [ ] Read: PRESENTATION-GUIDE.md
- [ ] Read: QUICKSTART.md
- [ ] Review: ARCHITECTURE.md
- [ ] Understand: README-DEVOPS.md

### Browser Tabs Setup
Open and bookmark these tabs (in order):
1. [ ] Frontend: `http://APP_VM_IP:5173`
2. [ ] Backend: `http://APP_VM_IP:8080`
3. [ ] Swagger: `http://APP_VM_IP:8080/swagger-ui/index.html`
4. [ ] Nagios: `http://MONITOR_VM_IP/nagios`
5. [ ] GitHub Actions: `https://github.com/YOUR_REPO/actions`
6. [ ] Azure Portal: `https://portal.azure.com`

### Screenshots (backup plan)
- [ ] Screenshot: Frontend homepage
- [ ] Screenshot: Backend API response
- [ ] Screenshot: Swagger UI
- [ ] Screenshot: Nagios dashboard (all green)
- [ ] Screenshot: GitHub Actions (successful run)
- [ ] Screenshot: Azure Portal resources

### Practice Demo
- [ ] Run through presentation flow (15 min)
- [ ] Practice explaining each component
- [ ] Test live code change → push → auto-deploy
- [ ] Verify all transitions work smoothly
- [ ] Time yourself (should be 15-20 min)

### Prepare Backup Plan
- [ ] Screen recording of full demo (in case live fails)
- [ ] Slides with key points
- [ ] Printed architecture diagram
- [ ] List of commands to copy-paste

---

## 🎯 Phase 9: Day Before Presentation

### System Health Check
- [ ] All VMs are running in Azure Portal
- [ ] Application is accessible
- [ ] Nagios shows all green
- [ ] GitHub Actions last run succeeded
- [ ] No pending Azure updates

### Verify Credentials
- [ ] Application login works
- [ ] Nagios login works
- [ ] GitHub access works
- [ ] SSH keys work

### Cost Check
- [ ] Check Azure cost analysis
- [ ] Should be within free tier
- [ ] No unexpected charges

### Backup Everything
```powershell
# Save all outputs again
cd terraform
terraform output > ..\outputs-backup.txt
terraform output -json > ..\outputs-backup.json

# Save SSH keys backup
copy ~/.ssh/azure_sms_rsa ~/ssh-backup/
copy ~/.ssh/azure_sms_rsa.pub ~/ssh-backup/
```
- [ ] Outputs saved
- [ ] SSH keys backed up
- [ ] Repository pushed to GitHub

---

## 🎓 Phase 10: Presentation Day

### 2 Hours Before
- [ ] Start VMs if they were stopped
- [ ] Wait 5 minutes for full startup
- [ ] Test all URLs again
- [ ] Clear browser cache
- [ ] Close unnecessary apps

### 30 Minutes Before
- [ ] Open all required browser tabs
- [ ] Login to Nagios
- [ ] Login to application
- [ ] Open GitHub Actions
- [ ] Open Azure Portal
- [ ] Test screen sharing
- [ ] Increase font size for visibility

### 10 Minutes Before
- [ ] Silence phone notifications
- [ ] Close email/Slack
- [ ] Disable Windows updates
- [ ] Have backup recording ready
- [ ] Water bottle nearby
- [ ] Deep breath! You've got this! 🚀

---

## 🧹 Phase 11: After Presentation

### Immediate (within 24 hours)
- [ ] Share repository link with class
- [ ] Post on LinkedIn
- [ ] Add to resume/portfolio
- [ ] Thank instructor/classmates

### Cost Management (same day)
```powershell
# Stop VMs to save costs
az vm deallocate --resource-group sms-devops-rg --name sms-app-vm
az vm deallocate --resource-group sms-devops-rg --name sms-monitor-vm
```
- [ ] VMs stopped (deallocated)
- [ ] Daily cost reduced to ~$0.30 (database only)

### Optional: Keep Running
If you want to keep it as a portfolio piece:
- [ ] Keep VMs running for 1 week
- [ ] Share link with potential employers
- [ ] Monitor Azure costs
- [ ] Stop VMs when not showing

### Optional: Full Cleanup
When completely done:
```powershell
cd terraform
terraform destroy
# Type 'yes' to confirm
```
- [ ] All resources deleted
- [ ] Resource group removed
- [ ] No ongoing costs

---

## 📊 Success Metrics

### You've succeeded if:
- ✅ Infrastructure deploys in <15 minutes
- ✅ Application is publicly accessible
- ✅ Nagios shows all services green
- ✅ GitHub Actions pipeline is working
- ✅ Can demo code change → auto-deploy
- ✅ Total cost < $5 for demo week
- ✅ Can explain each component clearly
- ✅ Instructor/classmates are impressed!

---

## 🚨 Troubleshooting Quick Reference

### Azure VMs not accessible?
```powershell
az vm list -d --resource-group sms-devops-rg -o table
az vm start --resource-group sms-devops-rg --name sms-app-vm
```

### Application not responding?
```bash
ssh azureuser@APP_VM_IP
cd /opt/sms
docker-compose restart
docker-compose logs -f backend
```

### Nagios shows red?
```bash
ssh azureuser@MONITOR_VM_IP
sudo systemctl restart nagios
sudo systemctl status nagios
```

### GitHub Actions failing?
- Check secrets are correct
- Verify VMs are running
- Test SSH manually
- Review workflow logs

### Can't SSH?
- Check NSG allows SSH (port 22)
- Verify SSH key permissions: `chmod 600 ~/.ssh/azure_sms_rsa`
- Try from Azure Cloud Shell
- Check VMs are running

---

## 📞 Emergency Contacts

**Before Presentation:**
- Test everything 24 hours early
- Have instructor's contact ready
- Know where IT help desk is
- Have backup recording ready

**During Presentation:**
- Stay calm if something breaks
- Use backup screenshots/recording
- Explain what should happen
- Demonstrate knowledge anyway

---

## 🎉 Completion

When you can check all boxes above, you're ready!

**Estimated Total Time:**
- Prerequisites: 15 min
- SSH Setup: 5 min
- Terraform Config: 5 min
- Azure Deploy: 15 min
- Ansible Config: 15 min
- GitHub Setup: 10 min
- Verification: 10 min
- Presentation Prep: 30 min
- **Total: ~2 hours**

**Tips:**
- Don't rush
- Follow checklist in order
- Test after each phase
- Take breaks
- Ask for help if stuck

---

**You've got this! 🚀 Good luck with your presentation!**

*If everything is checked, you're ready to demonstrate professional DevOps skills!*
