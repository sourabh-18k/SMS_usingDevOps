# Student Management System - DevOps Implementation Guide

## 🎯 Project Overview

This is a **Student Management System** transformed into a complete DevOps-enabled classroom project. The application demonstrates the full DevOps lifecycle with automated CI/CD, infrastructure as code, configuration management, and monitoring.

### Tech Stack
- **Backend**: Spring Boot 3.2.5 (Java 17) with Spring Security & JWT
- **Frontend**: React 18 + TypeScript + Vite
- **Database**: PostgreSQL (Azure Flexible Server)
- **Containerization**: Docker + Docker Compose

### DevOps Tools Integrated
- ✅ **Terraform** - Infrastructure as Code (Azure)
- ✅ **Ansible** - Configuration Management
- ✅ **Nagios** - Application & Infrastructure Monitoring
- ✅ **GitHub Actions** - CI/CD Pipeline
- ✅ **Docker** - Containerization

---

## 📁 Project Structure

```
SMS_devOps/
├── .github/
│   └── workflows/
│       └── ci-cd.yml              # GitHub Actions CI/CD pipeline
├── ansible/
│   ├── ansible.cfg                # Ansible configuration
│   ├── inventory/
│   │   └── hosts.yml              # Server inventory
│   └── playbooks/
│       ├── setup-app-server.yml   # Configure app server
│       ├── deploy-app.yml         # Deploy application
│       ├── setup-nagios.yml       # Install Nagios monitoring
│       └── templates/             # Configuration templates
├── backend/                       # Spring Boot application
├── frontend/                      # React application
├── nagios/
│   ├── README.md                  # Nagios setup guide
│   └── config/                    # Nagios configurations
├── scripts/
│   ├── generate-ssh-key.sh/.ps1  # SSH key generation
│   ├── deploy-azure.sh/.ps1      # Terraform deployment
│   └── configure-servers.sh/.ps1 # Ansible execution
├── terraform/
│   ├── main.tf                    # Infrastructure definition
│   ├── variables.tf               # Input variables
│   ├── outputs.tf                 # Output values
│   └── terraform.tfvars.example   # Configuration template
└── README-DEVOPS.md               # This file
```

---

## 🚀 Complete Setup Guide

### Prerequisites

#### Required Software:
1. **Azure CLI** - [Download](https://aka.ms/installazurecliwindows)
2. **Terraform** (v1.0+) - [Download](https://www.terraform.io/downloads)
3. **Git** - [Download](https://git-scm.com/downloads)
4. **SSH Client** (built-in on Windows 10+)

#### For Local Testing:
5. **Java 17** - [Download](https://adoptium.net/)
6. **Maven 3.9+** - [Download](https://maven.apache.org/download.cgi)
7. **Node.js 20** - [Download](https://nodejs.org/)
8. **Docker Desktop** - [Download](https://www.docker.com/products/docker-desktop/)

#### For Ansible (Choose One):
- **Option A**: Install WSL (Windows Subsystem for Linux) and run Ansible there
- **Option B**: Use Azure Cloud Shell (has Ansible pre-installed)
- **Option C**: Run Ansible from a Linux VM

---

## 📝 Step-by-Step Deployment

### Phase 1: Initial Setup (Local Machine)

#### Step 1: Generate SSH Keys
```powershell
# Navigate to project directory
cd D:\SMS_devOps

# Generate SSH key pair
.\scripts\generate-ssh-key.ps1

# The script will create:
# - Private key: C:\Users\YourName\.ssh\azure_sms_rsa
# - Public key: C:\Users\YourName\.ssh\azure_sms_rsa.pub
```

**Copy the public key output** - you'll need it next!

#### Step 2: Configure Terraform Variables
```powershell
# Copy example file
cd terraform
copy terraform.tfvars.example terraform.tfvars

# Edit terraform.tfvars with your values:
notepad terraform.tfvars
```

Update these values:
```hcl
resource_group_name  = "sms-devops-rg"
location             = "East US"
admin_username       = "azureuser"
ssh_public_key_path  = "C:/Users/YourName/.ssh/azure_sms_rsa.pub"
db_admin_username    = "smsadmin"
db_admin_password    = "YourStrongPassword123!"  # CHANGE THIS!
```

#### Step 3: Login to Azure
```powershell
# Login to your Azure account
az login

# Verify your subscription
az account show

# If needed, set the correct subscription
az account set --subscription "Azure for Students"
```

### Phase 2: Deploy Infrastructure to Azure

#### Step 4: Deploy with Terraform
```powershell
# Run the deployment script
cd D:\SMS_devOps
.\scripts\deploy-azure.ps1

# The script will:
# 1. Initialize Terraform
# 2. Create execution plan
# 3. Ask for confirmation
# 4. Deploy all Azure resources
# 5. Save outputs to outputs.json

# This takes approximately 10-15 minutes
```

**What gets created:**
- ✅ Resource Group
- ✅ Virtual Network & Subnet
- ✅ 2 Virtual Machines (B1s - Free tier)
  - App VM (runs backend + frontend)
  - Monitor VM (runs Nagios)
- ✅ PostgreSQL Flexible Server (B1ms)
- ✅ Network Security Groups (firewall rules)
- ✅ Public IP addresses

**After completion**, note these outputs:
```
App VM IP: 20.XXX.XXX.XXX
Monitor VM IP: 20.YYY.YYY.YYY
Database Host: sms-psql-server.postgres.database.azure.com
```

### Phase 3: Configure Servers with Ansible

#### Step 5: Setup Ansible (WSL Method)
```powershell
# Install WSL if not already installed
wsl --install

# Once WSL is ready, open Ubuntu terminal and install Ansible
wsl
sudo apt update
sudo apt install -y ansible jq

# Navigate to project (in WSL)
cd /mnt/d/SMS_devOps

# Copy your SSH key to WSL
cp /mnt/c/Users/YourName/.ssh/azure_sms_rsa ~/.ssh/
chmod 600 ~/.ssh/azure_sms_rsa
```

#### Step 6: Update Ansible Inventory
```bash
# Edit the inventory file
nano ansible/inventory/hosts.yml

# Replace placeholders with your actual IPs:
# - REPLACE_WITH_APP_VM_IP → Your App VM IP
# - REPLACE_WITH_MONITOR_VM_IP → Your Monitor VM IP
# - REPLACE_WITH_DB_HOST → Your PostgreSQL FQDN
```

Or set environment variables:
```bash
export APP_VM_IP="20.XXX.XXX.XXX"
export MONITOR_VM_IP="20.YYY.YYY.YYY"
export DB_HOST="sms-psql-server.postgres.database.azure.com"
export DB_USER="smsadmin"
export DB_PASSWORD="YourStrongPassword123!"
export JWT_SECRET="super-secret-change-me-please-1234567890abcdef"
```

#### Step 7: Run Ansible Playbooks
```bash
cd ansible

# Test connectivity
ansible all -i inventory/hosts.yml -m ping

# Configure application server (installs Docker, Java, Node, etc.)
ansible-playbook -i inventory/hosts.yml playbooks/setup-app-server.yml

# Configure monitoring server (installs Nagios)
ansible-playbook -i inventory/hosts.yml playbooks/setup-nagios.yml

# Deploy the application
export GIT_REPO="https://github.com/sourabh-18k/SMS_usingDevOps"
export GIT_BRANCH="main"
ansible-playbook -i inventory/hosts.yml playbooks/deploy-app.yml
```

**Each playbook takes 5-10 minutes to complete.**

### Phase 4: Setup GitHub Actions CI/CD

#### Step 8: Configure GitHub Secrets

Go to your repository: **Settings → Secrets and variables → Actions → New repository secret**

Add these secrets:

| Secret Name | Value | Example |
|-------------|-------|---------|
| `AZURE_SSH_PRIVATE_KEY` | Content of `~/.ssh/azure_sms_rsa` | `-----BEGIN OPENSSH PRIVATE KEY-----...` |
| `AZURE_APP_VM_IP` | App VM Public IP | `20.XXX.XXX.XXX` |
| `AZURE_MONITOR_VM_IP` | Monitor VM Public IP | `20.YYY.YYY.YYY` |
| `AZURE_DB_HOST` | PostgreSQL FQDN | `sms-psql-server.postgres.database.azure.com` |
| `AZURE_DB_USER` | Database username | `smsadmin` |
| `AZURE_DB_PASSWORD` | Database password | `YourStrongPassword123!` |
| `JWT_SECRET` | JWT secret key | `super-secret-change-me-please-1234567890abcdef` |

#### To get private key content:
```powershell
# Windows
Get-Content C:\Users\YourName\.ssh\azure_sms_rsa

# Or in WSL
cat ~/.ssh/azure_sms_rsa
```

#### Step 9: Test CI/CD Pipeline
```bash
# Make a small change and push
git add .
git commit -m "Test CI/CD pipeline"
git push origin main

# Go to GitHub → Actions tab
# Watch the pipeline execute:
# ✅ Backend Build & Test
# ✅ Frontend Build & Test
# ✅ Docker Build & Push
# ✅ Security Scan
# ✅ Deploy to Azure
# ✅ Smoke Tests
```

---

## 🎓 How to Present This in Class

### Presentation Structure (15-20 minutes)

#### 1. Introduction (2 min)
- "I transformed a full-stack Student Management System into a production-ready DevOps project"
- Show the application architecture diagram
- Mention tech stack: Spring Boot, React, PostgreSQL

#### 2. DevOps Tools Overview (3 min)

**Terraform Demo:**
- Show `terraform/main.tf` - "Infrastructure as Code"
- Explain: "One command deploys everything to Azure"
- Show Azure Portal with created resources

**Ansible Demo:**
- Show `ansible/playbooks/` - "Configuration as Code"
- Explain: "Automates server setup without manual SSH"
- Show playbook execution output

**Nagios Demo:**
- Open Nagios web interface: `http://MONITOR_VM_IP/nagios`
- Show: Host status, service checks, graphs
- Explain: "Real-time monitoring of application health"

#### 3. CI/CD Pipeline Demo (5 min)

**Live GitHub Actions Demo:**
1. Open GitHub repository
2. Navigate to Actions tab
3. Show latest workflow run
4. Explain each job:
   - Build & Test (parallel jobs)
   - Docker image creation
   - Security scanning
   - Automated deployment
   - Smoke tests

**Make a Live Change:**
```bash
# Edit a simple file
echo "<!-- DevOps Demo -->" >> frontend/index.html
git add .
git commit -m "Live demo: trigger CI/CD"
git push

# Show pipeline auto-triggering
```

#### 4. Application Access (3 min)

**Show Running Application:**
- Backend: `http://APP_VM_IP:8080`
- Swagger API: `http://APP_VM_IP:8080/swagger-ui/index.html`
- Frontend: `http://APP_VM_IP:5173`
- Demonstrate login, CRUD operations

**Show Monitoring:**
- Nagios dashboard showing green status
- Explain what's being monitored

#### 5. Key Features Highlight (2 min)

**Emphasize:**
- ✅ **Automated Infrastructure**: "No manual Azure portal clicks"
- ✅ **Automated Configuration**: "No manual SSH commands"
- ✅ **Automated Deployment**: "Push code → auto-deploy"
- ✅ **Automated Monitoring**: "Know when something breaks"
- ✅ **Free Tier**: "All within Azure Student credits"

#### 6. Q&A Preparation

**Expected Questions & Answers:**

**Q: "Why Terraform and not Azure Portal?"**
A: "Terraform provides version control, repeatability, and documentation. I can destroy and recreate the entire infrastructure in 15 minutes."

**Q: "Why Ansible and not manual SSH?"**
A: "Ansible ensures consistency. If I need 10 servers, one playbook configures all identically."

**Q: "What happens when you push code?"**
A: "GitHub Actions automatically: builds, tests, scans for vulnerabilities, creates Docker images, and deploys to Azure. All in 5-7 minutes."

**Q: "How does Nagios help?"**
A: "It constantly checks if my application is responding. If it goes down, I know immediately with alerts."

**Q: "Is this production-ready?"**
A: "For learning, yes. For real production, I'd add: HTTPS, proper secrets management, database backups, auto-scaling, and stricter security."

---

## 🧪 Testing the Setup

### Manual Testing Commands

#### Test Backend:
```bash
# Health check
curl http://APP_VM_IP:8080/

# Login API
curl -X POST http://APP_VM_IP:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@sms.dev","password":"ChangeMe123!"}'
```

#### Test Frontend:
```bash
# Check if serving
curl http://APP_VM_IP:5173/
```

#### Test Nagios:
```bash
# Open in browser
http://MONITOR_VM_IP/nagios

# Credentials: nagiosadmin / Admin123!
```

#### Test SSH Access:
```powershell
# App VM
ssh azureuser@APP_VM_IP

# Monitor VM
ssh azureuser@MONITOR_VM_IP
```

### View Logs

#### On App VM:
```bash
ssh azureuser@APP_VM_IP
cd /opt/sms
docker-compose logs -f backend
docker-compose logs -f frontend
```

#### On Monitor VM:
```bash
ssh azureuser@MONITOR_VM_IP
sudo tail -f /usr/local/nagios/var/nagios.log
```

---

## 🔧 Troubleshooting

### Issue: Terraform deployment fails

**Check:**
```powershell
# Verify Azure login
az account show

# Check subscription has available credits
az account show --query "state"

# Verify quotas
az vm list-usage --location "East US" --query "[?name.value=='virtualMachines']"
```

**Solution:**
- Ensure you have Azure Student subscription active
- Check resource quotas (Free tier: 2 B1s VMs)
- Try different region: `location = "Central US"`

### Issue: Cannot SSH to VMs

**Check:**
```powershell
# Test network connectivity
Test-NetConnection -ComputerName APP_VM_IP -Port 22

# Verify NSG rules in Azure Portal
az network nsg show --resource-group sms-devops-rg --name sms-nsg
```

**Solution:**
- Ensure NSG allows SSH (port 22) from your IP
- Verify SSH key permissions: `chmod 600 ~/.ssh/azure_sms_rsa`
- Check VM is running in Azure Portal

### Issue: Ansible playbook fails

**Check:**
```bash
# Test Ansible connectivity
ansible all -i inventory/hosts.yml -m ping

# Check Python on remote host
ansible all -i inventory/hosts.yml -m shell -a "python3 --version"
```

**Solution:**
- Verify IPs in `inventory/hosts.yml`
- Ensure SSH key is accessible
- Check VM has Python 3 installed

### Issue: Application not accessible

**Check:**
```bash
# SSH to app VM
ssh azureuser@APP_VM_IP

# Check containers
docker-compose ps

# View logs
docker-compose logs backend
docker-compose logs frontend

# Check if ports are listening
sudo netstat -tlnp | grep -E '8080|5173'
```

**Solution:**
- Restart containers: `docker-compose restart`
- Check environment variables
- Verify database connection

### Issue: GitHub Actions deployment fails

**Check:**
- Verify all secrets are set correctly
- Check SSH private key format (no extra spaces/newlines)
- Ensure VMs are running and accessible
- Review workflow logs in Actions tab

**Solution:**
```bash
# Test manual deployment
cd ansible
ansible-playbook -i inventory/hosts.yml playbooks/deploy-app.yml
```

### Issue: Nagios shows services as CRITICAL

**Check:**
```bash
# SSH to monitor VM
ssh azureuser@MONITOR_VM_IP

# Test checks manually
/usr/local/nagios/libexec/check_http -H APP_VM_IP -p 8080
/usr/local/nagios/libexec/check_ssh APP_VM_IP

# View Nagios logs
sudo tail -f /usr/local/nagios/var/nagios.log
```

**Solution:**
- Update `hosts.cfg` with correct IP
- Restart Nagios: `sudo systemctl restart nagios`
- Check firewall rules allow monitoring traffic

---

## 💰 Cost Management (Azure Student Free Tier)

### Free Resources Used:
- **B1s VMs**: 750 hours/month free (2 VMs × 750 hours)
- **PostgreSQL B1ms**: ~$12/month (within student credits)
- **Bandwidth**: 15 GB outbound free
- **Public IPs**: 2 static IPs ($0.005/hour each)

### Total Estimated Cost:
- **Monthly**: ~$15-20 (covered by $100 student credits)
- **Daily**: ~$0.50-0.70
- **For 1 week demo**: ~$3.50-5.00

### Cost Optimization Tips:
```powershell
# Stop VMs when not using (keeps data)
az vm deallocate --resource-group sms-devops-rg --name sms-app-vm
az vm deallocate --resource-group sms-devops-rg --name sms-monitor-vm

# Start VMs when needed
az vm start --resource-group sms-devops-rg --name sms-app-vm
az vm start --resource-group sms-devops-rg --name sms-monitor-vm

# Delete everything after demo
cd terraform
terraform destroy
```

---

## 📚 Additional Resources

### Documentation:
- **Terraform Azure Provider**: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs
- **Ansible Documentation**: https://docs.ansible.com/
- **Nagios Core Docs**: https://www.nagios.org/documentation/
- **GitHub Actions**: https://docs.github.com/en/actions

### Learning Paths:
- [Microsoft Learn - Azure Fundamentals](https://learn.microsoft.com/en-us/training/azure/)
- [Terraform Getting Started](https://learn.hashicorp.com/terraform)
- [Ansible for Beginners](https://www.ansible.com/resources/get-started)

### Project Repository:
- **GitHub**: https://github.com/sourabh-18k/SMS_usingDevOps

---

## ✅ Checklist for Presentation

- [ ] Azure resources deployed and running
- [ ] Application accessible via browser
- [ ] Nagios monitoring dashboard working
- [ ] GitHub Actions pipeline has at least 1 successful run
- [ ] Can demonstrate code change → auto-deploy
- [ ] Screenshots/screen recording as backup
- [ ] Architecture diagram ready
- [ ] Cost breakdown prepared
- [ ] Q&A answers prepared
- [ ] Destruction plan ready (terraform destroy)

---

## 🎉 Success Criteria

You have successfully completed the DevOps transformation if:

1. ✅ Infrastructure deploys with one command (`terraform apply`)
2. ✅ Servers configure with one command (`ansible-playbook`)
3. ✅ Application deploys automatically on git push
4. ✅ Monitoring shows real-time status
5. ✅ All costs stay within free tier
6. ✅ Everything is version-controlled and documented

**Congratulations! You now have a production-grade DevOps pipeline!** 🚀

---

## 📞 Support

If you encounter issues:
1. Check the Troubleshooting section above
2. Review logs (Terraform, Ansible, Docker, Nagios)
3. Verify all prerequisites are installed
4. Check Azure Portal for resource status
5. Review GitHub Actions workflow logs

---

## 🔒 Security Notes

**⚠️ This is a classroom demo setup. For production:**

1. **Never commit secrets** to Git
2. Use **Azure Key Vault** for secrets
3. Enable **HTTPS** with SSL certificates
4. Restrict **NSG rules** to specific IPs
5. Use **private endpoints** for database
6. Enable **Azure AD authentication**
7. Implement **proper RBAC**
8. Enable **backup and disaster recovery**
9. Use **managed identities** instead of passwords
10. **Regular security patches** and updates

---

**This guide was created specifically for classroom demonstration of DevOps practices using Azure Student Free Tier resources.**

*Last Updated: November 2025*
