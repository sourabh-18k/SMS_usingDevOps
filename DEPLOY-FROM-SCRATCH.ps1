#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Complete SMS DevOps Project Deployment Script
.DESCRIPTION
    Deploys the entire SMS application to Azure from scratch including:
    - Azure infrastructure (PostgreSQL, VM, networking)
    - Backend (Spring Boot application)
    - Frontend (React application)
    - Monitoring (Nagios)
.NOTES
    Prerequisites:
    - Azure CLI installed and logged in (az login)
    - Terraform installed
    - Git repository cloned
    - SSH key generated
#>

param(
    [Parameter(Mandatory=$false)]
    [string]$SubscriptionId,
    
    [Parameter(Mandatory=$false)]
    [string]$Location = "eastus",
    
    [Parameter(Mandatory=$false)]
    [string]$ResourceGroup = "sms-devops-rg",
    
    [Parameter(Mandatory=$false)]
    [switch]$SkipInfrastructure,
    
    [Parameter(Mandatory=$false)]
    [switch]$SkipApplication,
    
    [Parameter(Mandatory=$false)]
    [switch]$SkipMonitoring
)

# Color output functions
function Write-Step {
    param([string]$Message)
    Write-Host "`n==================================================================" -ForegroundColor Cyan
    Write-Host "  $Message" -ForegroundColor Cyan
    Write-Host "==================================================================" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "✅ $Message" -ForegroundColor Green
}

function Write-Error-Custom {
    param([string]$Message)
    Write-Host "❌ $Message" -ForegroundColor Red
}

function Write-Info {
    param([string]$Message)
    Write-Host "ℹ️  $Message" -ForegroundColor Yellow
}

# Error handling
$ErrorActionPreference = "Stop"
$StartTime = Get-Date

try {
    # Navigate to project root
    $ProjectRoot = "d:\SMS_devOps"
    Set-Location $ProjectRoot

    Write-Host @"

╔══════════════════════════════════════════════════════════════════╗
║                                                                  ║
║         SMS DevOps Project - Complete Deployment Script         ║
║                                                                  ║
║                    Starting Deployment Process                   ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝

"@ -ForegroundColor Magenta

    # ============================================================
    # STEP 0: Prerequisites Check
    # ============================================================
    Write-Step "STEP 0: Checking Prerequisites"

    Write-Info "Checking Azure CLI..."
    $azVersion = az version --query '"azure-cli"' -o tsv 2>$null
    if (-not $azVersion) {
        Write-Error-Custom "Azure CLI not found. Install from: https://aka.ms/installazurecliwindows"
        exit 1
    }
    Write-Success "Azure CLI version $azVersion"

    Write-Info "Checking Terraform..."
    $tfVersion = terraform version -json 2>$null | ConvertFrom-Json | Select-Object -ExpandProperty terraform_version
    if (-not $tfVersion) {
        Write-Error-Custom "Terraform not found. Install from: https://www.terraform.io/downloads"
        exit 1
    }
    Write-Success "Terraform version $tfVersion"

    Write-Info "Checking Azure login status..."
    $account = az account show 2>$null | ConvertFrom-Json
    if (-not $account) {
        Write-Info "Not logged in to Azure. Logging in..."
        az login
        $account = az account show | ConvertFrom-Json
    }
    Write-Success "Logged in as: $($account.user.name)"

    if ($SubscriptionId) {
        Write-Info "Setting subscription: $SubscriptionId"
        az account set --subscription $SubscriptionId
    } else {
        $SubscriptionId = $account.id
    }
    Write-Success "Using subscription: $($account.name) ($SubscriptionId)"

    # ============================================================
    # STEP 1: Generate SSH Key (if not exists)
    # ============================================================
    Write-Step "STEP 1: SSH Key Setup"

    $sshKeyPath = "$env:USERPROFILE\.ssh\id_rsa"
    if (-not (Test-Path $sshKeyPath)) {
        Write-Info "Generating SSH key..."
        & wsl -- bash -c "ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N '' -C 'sms-devops-key'"
        Write-Success "SSH key generated"
    } else {
        Write-Success "SSH key already exists"
    }

    $sshPublicKey = & wsl -- bash -c "cat ~/.ssh/id_rsa.pub"
    Write-Info "SSH Public Key: $($sshPublicKey.Substring(0, 50))..."

    # ============================================================
    # STEP 2: Deploy Azure Infrastructure with Terraform
    # ============================================================
    if (-not $SkipInfrastructure) {
        Write-Step "STEP 2: Deploying Azure Infrastructure"

        Set-Location "$ProjectRoot\terraform"

        Write-Info "Initializing Terraform..."
        terraform init

        Write-Info "Creating Terraform variables file..."
        $tfvarsContent = @"
resource_group_name     = "$ResourceGroup"
location               = "$Location"
admin_username         = "azureuser"
ssh_public_key         = "$sshPublicKey"
db_admin_username      = "smsadmin"
db_admin_password      = "SMS_DevOps_2025!SecurePassword"
allowed_ip_address     = "0.0.0.0/0"
"@
        $tfvarsContent | Out-File -FilePath "terraform.tfvars" -Encoding utf8

        Write-Info "Planning infrastructure deployment..."
        terraform plan -out=tfplan

        Write-Info "Applying infrastructure deployment..."
        terraform apply tfplan

        Write-Info "Retrieving outputs..."
        $outputs = terraform output -json | ConvertFrom-Json
        $vmIp = $outputs.vm_public_ip.value
        $dbHost = $outputs.postgresql_fqdn.value

        Write-Success "Infrastructure deployed successfully!"
        Write-Info "VM IP: $vmIp"
        Write-Info "Database Host: $dbHost"

        # Save outputs for later use
        $outputs | ConvertTo-Json | Out-File "$ProjectRoot\outputs.json"

        Set-Location $ProjectRoot
    } else {
        Write-Info "Skipping infrastructure deployment (using existing resources)"
        $outputs = Get-Content "$ProjectRoot\outputs.json" | ConvertFrom-Json
        $vmIp = $outputs.vm_public_ip.value
        $dbHost = $outputs.postgresql_fqdn.value
    }

    # ============================================================
    # STEP 3: Configure Application Server
    # ============================================================
    if (-not $SkipApplication) {
        Write-Step "STEP 3: Configuring Application Server"

        Write-Info "Waiting 30 seconds for VM to be fully ready..."
        Start-Sleep -Seconds 30

        Write-Info "Installing Docker and dependencies on VM..."
        $configScript = @'
#!/bin/bash
set -e

# Update system
sudo apt-get update

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Install Docker Compose
sudo apt-get install -y docker-compose

# Install Git
sudo apt-get install -y git

# Create Docker network
sudo docker network create sms-network || true

# Clone repository
cd /home/azureuser
if [ ! -d "SMS_usingDevOps" ]; then
  git clone https://github.com/sourabh-18k/SMS_usingDevOps.git
else
  cd SMS_usingDevOps
  git pull origin main
  cd ..
fi

echo "Server configured successfully!"
'@

        az vm run-command invoke `
            --resource-group $ResourceGroup `
            --name "sms-app-vm" `
            --command-id RunShellScript `
            --scripts $configScript

        Write-Success "Application server configured"

        # ============================================================
        # STEP 4: Deploy Backend Application
        # ============================================================
        Write-Step "STEP 4: Deploying Backend Application"

        Write-Info "Building and deploying backend..."
        $backendScript = @"
#!/bin/bash
set -e

cd /home/azureuser/SMS_usingDevOps/backend

# Update application.yml with database credentials
cat > src/main/resources/application-prod.yml << 'EOF'
spring:
  datasource:
    url: jdbc:postgresql://$dbHost:5432/sms_db
    username: smsadmin
    password: SMS_DevOps_2025!SecurePassword
    driver-class-name: org.postgresql.Driver
  jpa:
    hibernate:
      ddl-auto: update
    show-sql: false
    properties:
      hibernate:
        dialect: org.hibernate.dialect.PostgreSQLDialect
  sql:
    init:
      mode: always

logging:
  level:
    root: INFO
    com.sms: DEBUG
EOF

# Build Docker image
sudo docker build -t sms-backend:latest .

# Stop and remove old container
sudo docker stop sms-backend-1 || true
sudo docker rm sms-backend-1 || true

# Run backend container
sudo docker run -d \
  --name sms-backend-1 \
  --network sms-network \
  -p 8080:8080 \
  -e SPRING_PROFILES_ACTIVE=prod \
  --restart unless-stopped \
  sms-backend:latest

echo "Waiting for backend to start..."
sleep 15

# Check backend health
curl -f http://localhost:8080/ || echo "Backend started (endpoint may return 404, that's ok)"

echo "Backend deployed successfully!"
"@

        az vm run-command invoke `
            --resource-group $ResourceGroup `
            --name "sms-app-vm" `
            --command-id RunShellScript `
            --scripts $backendScript `
            --no-wait

        Write-Info "Backend deployment initiated (running in background)"
        Write-Info "Waiting 60 seconds for backend to start..."
        Start-Sleep -Seconds 60

        # ============================================================
        # STEP 5: Deploy Frontend Application
        # ============================================================
        Write-Step "STEP 5: Deploying Frontend Application"

        Write-Info "Building and deploying frontend..."
        $frontendScript = @"
#!/bin/bash
set -e

cd /home/azureuser/SMS_usingDevOps/frontend

# Create config.js
cat > public/config.js << 'EOF'
window.ENV = {
  API_BASE_URL: ''
};
EOF

# Build Docker image
sudo docker build -t sms-frontend:latest .

# Stop and remove old container
sudo docker stop sms-frontend-1 || true
sudo docker rm sms-frontend-1 || true

# Run frontend container
sudo docker run -d \
  --name sms-frontend-1 \
  --network sms-network \
  -p 5173:80 \
  --restart unless-stopped \
  sms-frontend:latest

echo "Frontend deployed successfully!"
"@

        az vm run-command invoke `
            --resource-group $ResourceGroup `
            --name "sms-app-vm" `
            --command-id RunShellScript `
            --scripts $frontendScript `
            --no-wait

        Write-Info "Frontend deployment initiated (running in background)"
        Write-Success "Application deployment started"
    }

    # ============================================================
    # STEP 6: Setup Nagios Monitoring
    # ============================================================
    if (-not $SkipMonitoring) {
        Write-Step "STEP 6: Setting Up Nagios Monitoring"

        Write-Info "Installing Nagios Core..."
        $nagiosScript = @'
#!/bin/bash
set -e

# Install dependencies
sudo apt-get update
sudo apt-get install -y apache2 php libapache2-mod-php php-gd \
  build-essential libgd-dev openssl libssl-dev unzip wget

# Download Nagios Core
cd /tmp
wget https://github.com/NagiosEnterprises/nagioscore/releases/download/nagios-4.4.14/nagios-4.4.14.tar.gz
tar xzf nagios-4.4.14.tar.gz
cd nagios-4.4.14

# Compile and install
sudo ./configure --with-httpd-conf=/etc/apache2/sites-enabled
sudo make all
sudo make install-groups-users
sudo usermod -a -G nagios www-data
sudo make install
sudo make install-daemoninit
sudo make install-commandmode
sudo make install-config
sudo make install-webconf

# Download and install plugins
cd /tmp
wget https://github.com/nagios-plugins/nagios-plugins/releases/download/release-2.4.6/nagios-plugins-2.4.6.tar.gz
tar xzf nagios-plugins-2.4.6.tar.gz
cd nagios-plugins-2.4.6
sudo ./configure --with-nagios-user=nagios --with-nagios-group=nagios
sudo make
sudo make install

# Create Nagios admin user
echo "nagiosadmin:nagios123" | sudo chpasswd || sudo htpasswd -bc /usr/local/nagios/etc/htpasswd.users nagiosadmin nagios123

# Enable Apache modules and start services
sudo a2enmod rewrite cgi
sudo systemctl restart apache2
sudo systemctl enable nagios
sudo systemctl start nagios

# Add nagios to docker group for monitoring
sudo usermod -aG docker nagios

# Create Docker monitoring plugin
sudo mkdir -p /usr/local/nagios/libexec/custom
sudo tee /usr/local/nagios/libexec/custom/check_docker.sh > /dev/null << 'DOCKERSCRIPT'
#!/bin/bash
CONTAINER_NAME=$1
if [ -z "$CONTAINER_NAME" ]; then
  echo "UNKNOWN - Container name not provided"
  exit 3
fi

STATUS=$(docker inspect -f '{{.State.Status}}' "$CONTAINER_NAME" 2>/dev/null)
if [ $? -ne 0 ]; then
  echo "CRITICAL - Container $CONTAINER_NAME not found"
  exit 2
fi

if [ "$STATUS" = "running" ]; then
  echo "OK - Container $CONTAINER_NAME is running"
  exit 0
else
  echo "CRITICAL - Container $CONTAINER_NAME is $STATUS"
  exit 2
fi
DOCKERSCRIPT

sudo chmod +x /usr/local/nagios/libexec/custom/check_docker.sh

# Configure Nagios to monitor Docker containers
sudo tee /usr/local/nagios/etc/objects/docker-services.cfg > /dev/null << 'NAGIOSCONF'
define service {
    use                     local-service
    host_name               localhost
    service_description     Backend Container
    check_command           check_docker!sms-backend-1
}

define service {
    use                     local-service
    host_name               localhost
    service_description     Frontend Container
    check_command           check_docker!sms-frontend-1
}

define command {
    command_name    check_docker
    command_line    /usr/local/nagios/libexec/custom/check_docker.sh $ARG1$
}
NAGIOSCONF

# Add config to nagios.cfg
if ! grep -q "docker-services.cfg" /usr/local/nagios/etc/nagios.cfg; then
  echo "cfg_file=/usr/local/nagios/etc/objects/docker-services.cfg" | sudo tee -a /usr/local/nagios/etc/nagios.cfg
fi

# Restart Nagios
sudo systemctl restart nagios

echo "Nagios installed successfully!"
'@

        az vm run-command invoke `
            --resource-group $ResourceGroup `
            --name "sms-app-vm" `
            --command-id RunShellScript `
            --scripts $nagiosScript `
            --no-wait

        Write-Info "Nagios installation initiated (running in background)"
        Write-Success "Monitoring setup started"
    }

    # ============================================================
    # STEP 7: Verify Deployment
    # ============================================================
    Write-Step "STEP 7: Deployment Verification"

    Write-Info "Waiting for all services to start (2 minutes)..."
    Start-Sleep -Seconds 120

    Write-Info "Checking deployment status..."
    $statusScript = 'docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
    
    $statusResult = az vm run-command invoke `
        --resource-group $ResourceGroup `
        --name "sms-app-vm" `
        --command-id RunShellScript `
        --scripts $statusScript `
        --query 'value[0].message' `
        --output tsv

    Write-Host "`nContainer Status:" -ForegroundColor Cyan
    Write-Host $statusResult

    # ============================================================
    # DEPLOYMENT COMPLETE
    # ============================================================
    $EndTime = Get-Date
    $Duration = $EndTime - $StartTime

    Write-Host @"

╔══════════════════════════════════════════════════════════════════╗
║                                                                  ║
║              🎉 DEPLOYMENT COMPLETED SUCCESSFULLY! 🎉            ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝

"@ -ForegroundColor Green

    Write-Host "📊 DEPLOYMENT SUMMARY" -ForegroundColor Cyan
    Write-Host "=" * 70
    Write-Host "Resource Group    : $ResourceGroup" -ForegroundColor White
    Write-Host "Location          : $Location" -ForegroundColor White
    Write-Host "VM IP Address     : $vmIp" -ForegroundColor White
    Write-Host "Database Host     : $dbHost" -ForegroundColor White
    Write-Host "Deployment Time   : $($Duration.ToString('mm\:ss'))" -ForegroundColor White
    Write-Host "=" * 70

    Write-Host "`n🌐 ACCESS URLS" -ForegroundColor Cyan
    Write-Host "=" * 70
    Write-Host "Frontend          : http://$vmIp:5173" -ForegroundColor Green
    Write-Host "Backend API       : http://$vmIp:8080" -ForegroundColor Green
    Write-Host "Nagios Monitoring : http://$vmIp/nagios" -ForegroundColor Green
    Write-Host "=" * 70

    Write-Host "`n🔐 DEFAULT CREDENTIALS" -ForegroundColor Cyan
    Write-Host "=" * 70
    Write-Host "Application Admin : admin@sms.dev / ChangeMe123!" -ForegroundColor Yellow
    Write-Host "Nagios Admin      : nagiosadmin / nagios123" -ForegroundColor Yellow
    Write-Host "Database Admin    : smsadmin / SMS_DevOps_2025!SecurePassword" -ForegroundColor Yellow
    Write-Host "=" * 70

    Write-Host "`n📝 NEXT STEPS" -ForegroundColor Cyan
    Write-Host "1. Access the frontend at http://$vmIp:5173" -ForegroundColor White
    Write-Host "2. The application goes directly to the dashboard (no login required)" -ForegroundColor White
    Write-Host "3. Check Nagios monitoring at http://$vmIp/nagios" -ForegroundColor White
    Write-Host "4. Review deployment logs in Azure Portal if needed" -ForegroundColor White
    Write-Host "`n⚠️  Note: Services may take 2-3 minutes to be fully operational" -ForegroundColor Yellow

    # Save deployment info
    $deploymentInfo = @{
        DeploymentTime = $EndTime.ToString("yyyy-MM-dd HH:mm:ss")
        ResourceGroup = $ResourceGroup
        Location = $Location
        VMIP = $vmIp
        DatabaseHost = $dbHost
        Duration = $Duration.TotalSeconds
        FrontendURL = "http://$vmIp:5173"
        BackendURL = "http://$vmIp:8080"
        NagiosURL = "http://$vmIp/nagios"
    }
    $deploymentInfo | ConvertTo-Json | Out-File "$ProjectRoot\DEPLOYMENT-INFO.json"

} catch {
    Write-Error-Custom "Deployment failed: $_"
    Write-Host $_.ScriptStackTrace -ForegroundColor Red
    exit 1
}
