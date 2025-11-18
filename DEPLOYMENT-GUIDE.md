# SMS DevOps Project - Deployment Guide

## 📋 Table of Contents
1. [Quick Start (Local Development)](#quick-start-local)
2. [Full Azure Deployment](#azure-deployment)
3. [Manual Step-by-Step Guide](#manual-steps)
4. [Troubleshooting](#troubleshooting)

---

## 🚀 Quick Start (Local Development)

### Prerequisites
- Java 17+
- Node.js 18+
- Maven 3.8+
- Git

### One-Command Start
```powershell
.\START-LOCAL.ps1
```

This will:
- ✅ Check all prerequisites
- ✅ Start backend on http://localhost:8080
- ✅ Start frontend on http://localhost:5173
- ✅ Use H2 in-memory database (no setup needed)

### Manual Local Start

#### Terminal 1 - Backend
```powershell
cd backend
mvn spring-boot:run -Dspring-boot.run.profiles=dev
```

#### Terminal 2 - Frontend
```powershell
cd frontend
npm install
npm run dev -- --host 0.0.0.0
```

#### Access
- **Frontend**: http://localhost:5173
- **Backend API**: http://localhost:8080
- **H2 Console**: http://localhost:8080/h2-console

---

## ☁️ Full Azure Deployment

### Prerequisites
- Azure CLI installed and logged in (`az login`)
- Terraform installed
- Azure subscription with permissions to create resources

### One-Command Deployment
```powershell
.\DEPLOY-FROM-SCRATCH.ps1
```

### What It Does
1. ✅ Validates prerequisites (Azure CLI, Terraform)
2. ✅ Generates SSH key (if not exists)
3. ✅ Creates Azure infrastructure:
   - Resource Group
   - Virtual Network & Subnet
   - Network Security Group
   - Public IP
   - Virtual Machine (Ubuntu 22.04)
   - PostgreSQL Flexible Server
4. ✅ Configures VM with Docker
5. ✅ Deploys backend container
6. ✅ Deploys frontend container
7. ✅ Installs Nagios monitoring

### Custom Parameters
```powershell
# Use specific subscription
.\DEPLOY-FROM-SCRATCH.ps1 -SubscriptionId "your-subscription-id"

# Use different location
.\DEPLOY-FROM-SCRATCH.ps1 -Location "westus2"

# Skip specific steps
.\DEPLOY-FROM-SCRATCH.ps1 -SkipMonitoring
.\DEPLOY-FROM-SCRATCH.ps1 -SkipInfrastructure -SkipApplication
```

### Expected Output
```
╔══════════════════════════════════════════════════════════════════╗
║              🎉 DEPLOYMENT COMPLETED SUCCESSFULLY! 🎉            ║
╚══════════════════════════════════════════════════════════════════╝

📊 DEPLOYMENT SUMMARY
======================================================================
Resource Group    : sms-devops-rg
Location          : eastus
VM IP Address     : X.X.X.X
Database Host     : sms-psql-server.postgres.database.azure.com
Deployment Time   : 08:45
======================================================================

🌐 ACCESS URLS
======================================================================
Frontend          : http://X.X.X.X:5173
Backend API       : http://X.X.X.X:8080
Nagios Monitoring : http://X.X.X.X/nagios
======================================================================
```

---

## 📝 Manual Step-by-Step Guide

### Step 1: Prepare Environment
```powershell
# Clone repository
git clone https://github.com/sourabh-18k/SMS_usingDevOps.git
cd SMS_usingDevOps

# Generate SSH key
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa
```

### Step 2: Deploy Infrastructure
```powershell
cd terraform

# Initialize Terraform
terraform init

# Create terraform.tfvars
@"
resource_group_name     = "sms-devops-rg"
location               = "eastus"
admin_username         = "azureuser"
ssh_public_key         = "$(cat ~/.ssh/id_rsa.pub)"
db_admin_username      = "smsadmin"
db_admin_password      = "SMS_DevOps_2025!SecurePassword"
allowed_ip_address     = "0.0.0.0/0"
"@ | Out-File terraform.tfvars

# Deploy
terraform plan -out=tfplan
terraform apply tfplan

# Get outputs
$vmIp = terraform output -raw vm_public_ip
$dbHost = terraform output -raw postgresql_fqdn
```

### Step 3: Configure VM
```powershell
# SSH into VM
ssh azureuser@$vmIp

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Install Docker Compose
sudo apt-get install -y docker-compose

# Create network
docker network create sms-network

# Clone repository
git clone https://github.com/sourabh-18k/SMS_usingDevOps.git
cd SMS_usingDevOps
```

### Step 4: Deploy Backend
```bash
cd backend

# Update application-prod.yml with DB credentials
# Build and run
docker build -t sms-backend:latest .
docker run -d \
  --name sms-backend-1 \
  --network sms-network \
  -p 8080:8080 \
  -e SPRING_PROFILES_ACTIVE=prod \
  --restart unless-stopped \
  sms-backend:latest
```

### Step 5: Deploy Frontend
```bash
cd ../frontend

# Build and run
docker build -t sms-frontend:latest .
docker run -d \
  --name sms-frontend-1 \
  --network sms-network \
  -p 5173:80 \
  --restart unless-stopped \
  sms-frontend:latest
```

### Step 6: Install Nagios (Optional)
```bash
# See detailed instructions in scripts/install-nagios.sh
sudo bash scripts/install-nagios.sh
```

### Step 7: Verify Deployment
```bash
# Check containers
docker ps

# Test backend
curl http://localhost:8080/

# Test frontend
curl http://localhost:5173/
```

---

## 🔧 Troubleshooting

### Backend Issues

#### Container won't start
```bash
# Check logs
docker logs sms-backend-1

# Common issues:
# - Database connection: Verify DB credentials in application-prod.yml
# - Port already in use: docker ps | grep 8080
```

#### Database connection errors
```bash
# Test PostgreSQL connectivity
psql -h your-db-host.postgres.database.azure.com -U smsadmin -d sms_db

# Check firewall rules in Azure Portal
# Ensure VM IP is whitelisted
```

### Frontend Issues

#### Blank page or 404 errors
```bash
# Check container logs
docker logs sms-frontend-1

# Verify Nginx config
docker exec sms-frontend-1 cat /etc/nginx/conf.d/default.conf

# Check if assets exist
docker exec sms-frontend-1 ls -la /usr/share/nginx/html/
```

#### API calls failing
```bash
# Check Nginx proxy configuration
docker exec sms-frontend-1 cat /etc/nginx/conf.d/default.conf

# Test backend connectivity from frontend container
docker exec sms-frontend-1 curl http://sms-backend-1:8080/
```

### Nagios Issues

#### Can't access Nagios web interface
```bash
# Check Apache status
sudo systemctl status apache2

# Restart services
sudo systemctl restart apache2
sudo systemctl restart nagios

# Check logs
sudo tail -f /usr/local/nagios/var/nagios.log
```

#### Docker monitoring not working
```bash
# Add nagios to docker group
sudo usermod -aG docker nagios
sudo systemctl restart nagios

# Test plugin manually
sudo -u nagios /usr/local/nagios/libexec/custom/check_docker.sh sms-backend-1
```

### General Docker Issues

#### Container networking
```bash
# Check network
docker network inspect sms-network

# Verify containers are on same network
docker inspect sms-backend-1 | grep NetworkMode
docker inspect sms-frontend-1 | grep NetworkMode
```

#### Rebuild and redeploy
```bash
# Stop and remove containers
docker stop sms-backend-1 sms-frontend-1
docker rm sms-backend-1 sms-frontend-1

# Remove images
docker rmi sms-backend:latest sms-frontend:latest

# Rebuild
cd ~/SMS_usingDevOps
git pull origin main
# Then repeat deployment steps
```

---

## 📞 Support & Resources

### Useful Commands
```powershell
# Check Azure resources
az resource list --resource-group sms-devops-rg --output table

# SSH into VM
ssh azureuser@$(terraform output -raw vm_public_ip)

# View container logs
docker logs -f sms-backend-1
docker logs -f sms-frontend-1

# Restart containers
docker restart sms-backend-1 sms-frontend-1

# Clean up everything
terraform destroy
```

### Default Credentials
- **Application Admin**: admin@sms.dev / ChangeMe123!
- **Nagios**: nagiosadmin / nagios123
- **PostgreSQL**: smsadmin / SMS_DevOps_2025!SecurePassword

### Key Files
- `terraform/main.tf` - Infrastructure definition
- `backend/Dockerfile` - Backend container
- `frontend/Dockerfile` - Frontend container
- `docker-compose.yml` - Local development compose
- `ansible/playbooks/` - Ansible automation

---

## 🎯 Quick Reference

### Local Development
```powershell
.\START-LOCAL.ps1
# Access: http://localhost:5173
```

### Azure Deployment
```powershell
.\DEPLOY-FROM-SCRATCH.ps1
# Access: http://YOUR-VM-IP:5173
```

### Check Status
```powershell
# Azure
az vm run-command invoke --resource-group sms-devops-rg --name sms-app-vm --command-id RunShellScript --scripts "docker ps"

# Local
docker ps
```

### Update Code
```bash
# On Azure VM
cd ~/SMS_usingDevOps
git pull origin main
cd frontend
docker build -t sms-frontend:latest .
docker restart sms-frontend-1
```

---

**📌 Note**: The application is configured to bypass authentication - it goes directly to the dashboard without requiring login.
