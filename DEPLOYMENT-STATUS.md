# SMS DevOps Deployment Status

**Date:** November 16, 2024  
**Region:** Korea Central  
**Status:** In Progress - App Server Configuration

---

## ✅ Completed

### Infrastructure Deployment
- ✅ Azure CLI v2.79.0 installed
- ✅ Terraform v1.13.5 installed  
- ✅ Azure login successful (Azure for Students subscription)
- ✅ SSH keys generated (4096-bit RSA at `C:\Users\HP\.ssh\azure_sms_rsa`)
- ✅ Terraform infrastructure deployed (12 resources)
- ✅ Resource Group: `sms-devops-rg`
- ✅ Region: Korea Central (after testing East US, Central India, South India)

### Azure Resources Created
| Resource Type | Name | Status | Details |
|---------------|------|--------|---------|
| Virtual Network | sms-vnet | ✅ Running | 10.0.0.0/16 |
| Subnet | sms-subnet | ✅ Running | 10.0.1.0/24 |
| Network Security Group | sms-nsg | ✅ Running | Ports 22, 80, 443, 8080, 5173 |
| Public IP (App) | sms-app-pip | ✅ Running | 4.218.12.135 (Standard SKU) |
| Public IP (Monitor) | sms-monitor-pip | ⚠️ **Not Accessible** | 4.217.199.101 (Standard SKU) |
| Network Interface (App) | sms-app-nic | ✅ Running | Connected to NSG |
| Network Interface (Monitor) | sms-monitor-nic | ⚠️ Issue | Associated with NSG but SSH blocked |
| VM (App Server) | sms-app-vm | ✅ Running | Standard_B1s, Ubuntu 22.04, SSH working |
| VM (Monitor Server) | sms-monitor-vm | ⚠️ **SSH Blocked** | Standard_B1s, Ubuntu 22.04, **Port 22 timeout** |
| OS Disk (App) | sms-app-disk | ✅ Running | 30GB Standard LRS |
| OS Disk (Monitor) | sms-monitor-disk | ✅ Running | 30GB Standard LRS |
| PostgreSQL Server | sms-psql-server | ✅ Running | Flexible Server, PostgreSQL 15 |

### Environment Setup
- ✅ WSL2 with Ubuntu 22.04 installed
- ✅ Ansible 2.10.8 installed in WSL
- ✅ SSH key copied to WSL (`~/.ssh/azure_sms_rsa`)
- ✅ Ansible inventory configured with environment variables
- ✅ Connectivity test passed for App VM (4.218.12.135)

---

## 🔄 In Progress

### Current Task: App Server Configuration
**Status:** Ansible playbook `setup-app-server.yml` is running  
**Started:** Just now  
**Expected Duration:** 5-8 minutes  
**Terminal ID:** fa38e319-f5b8-4a8e-adc7-d155b01d5d67

**What's Installing:**
- Docker CE
- Docker Compose
- UFW firewall configuration
- Required system packages

---

## ⚠️ Known Issues

### Issue #1: Monitor VM SSH Port 22 Blocked
**Severity:** HIGH - Prevents Nagios installation  
**VM:** sms-monitor-vm (4.217.199.101)

**Symptoms:**
```bash
# Ansible ping test
monitor_vm | UNREACHABLE! => {
    "msg": "Failed to connect to the host via ssh: ssh: connect to host 4.217.199.101 port 22: Connection timed out"
}

# PowerShell test
Test-NetConnection -ComputerName 4.217.199.101 -Port 22
TcpTestSucceeded : False
```

**Investigation:**
- ✅ Terraform configuration correct - NSG association exists:
  ```hcl
  resource "azurerm_network_interface_security_group_association" "monitor_vm_nsg_assoc" {
    network_interface_id      = azurerm_network_interface.monitor_vm_nic.id
    network_security_group_id = azurerm_network_security_group.sms_nsg.id
  }
  ```
- ✅ NSG rules include SSH (port 22) with priority 100
- ✅ Public IP assigned correctly
- ✅ VM is running in Azure (status: Succeeded)
- ❌ Network connectivity fails from external sources
- ❌ Both ping and SSH timeout

**Possible Causes:**
1. Azure Student subscription may have additional network restrictions
2. Korea Central region might have specific egress/ingress policies
3. NSG rule might not be properly applied despite Terraform state showing success
4. Azure firewall at subscription or tenant level
5. VM internal firewall (unlikely on fresh Ubuntu install)

**Workaround Options:**
1. ✅ **[Current]** Deploy app and frontend first, defer Nagios setup
2. Try recreating monitor VM with `terraform taint` and re-apply
3. Contact Azure support about Student subscription network policies
4. Use Azure Bastion for SSH access (requires additional resources)
5. Deploy monitor VM in same subnet as app VM and use private IP

**Next Steps:**
1. Complete app server setup and application deployment
2. Test application accessibility
3. Return to troubleshoot monitor VM
4. Consider Azure Bastion or alternative monitoring solution

---

## 📋 Pending Tasks

### High Priority
1. ⏳ **Running:** Complete app server Docker installation (5-8 min)
2. ⏳ Deploy application with `deploy-app.yml` playbook (~5 min)
3. ⏳ Verify application accessibility:
   - http://4.218.12.135:8080 (Backend API)
   - http://4.218.12.135:5173 (Frontend App)
4. ⏳ Test database connectivity from app server

### Medium Priority (After App Works)
5. ⚠️ Troubleshoot monitor VM SSH access
6. ⚠️ Install Nagios monitoring (if monitor VM accessible)
7. ⚠️ Configure Nagios to monitor app VM

### Low Priority (After Basic Deployment)
8. Setup GitHub Actions CI/CD pipeline
9. Configure GitHub secrets (7 required - see GITHUB-SECRETS-GUIDE.md)
10. Test CI/CD pipeline with code push

---

## 🔑 Connection Details

### Application Server
- **Public IP:** 4.218.12.135
- **SSH:** `ssh -i C:\Users\HP\.ssh\azure_sms_rsa azureuser@4.218.12.135`
- **Backend API:** http://4.218.12.135:8080 (after deployment)
- **Frontend:** http://4.218.12.135:5173 (after deployment)
- **Status:** ✅ SSH accessible, Docker installing

### Monitor Server
- **Public IP:** 4.217.199.101
- **SSH:** ❌ **NOT ACCESSIBLE** - Connection timeout
- **Nagios URL:** http://4.217.199.101/nagios (cannot install yet)
- **Status:** ⚠️ VM running but SSH blocked

### Database Server
- **Host:** sms-psql-server.postgres.database.azure.com
- **Port:** 5432
- **Database:** sms
- **Username:** smsadmin
- **Password:** SMS_DevOps_2025!SecurePassword
- **SSL:** Required
- **Status:** ✅ Running and accessible

### Environment Variables (Set in WSL for Ansible)
```bash
export APP_VM_IP="4.218.12.135"
export MONITOR_VM_IP="4.217.199.101"  # Not accessible yet
export DB_HOST="sms-psql-server.postgres.database.azure.com"
export DB_USER="smsadmin"
export DB_PASSWORD="SMS_DevOps_2025!SecurePassword"
export JWT_SECRET="super-secret-change-me-please-1234567890abcdef"
```

---

## 📊 Timeline Summary

### Phase 1: Prerequisites (Completed)
- **Duration:** ~30 minutes
- Installed Azure CLI, Terraform
- Generated SSH keys
- Configured Azure authentication

### Phase 2: Infrastructure Deployment (Completed with Issues)
- **Duration:** ~45 minutes (multiple attempts due to region restrictions)
- Attempted regions: East US ❌, Central India ❌, South India ❌, Korea Central ✅
- Fixed Public IP SKU from Basic to Standard
- Registered PostgreSQL resource provider
- Successfully deployed 12 Azure resources

### Phase 3: Configuration Setup (In Progress)
- **Started:** Just now
- Installed WSL Ubuntu 22.04
- Installed Ansible 2.10.8
- Configured SSH and environment
- **Current:** Running app server setup playbook

### Phase 4: Application Deployment (Pending)
- **Estimated Start:** +10 minutes
- Deploy Spring Boot backend
- Deploy React frontend
- Verify database connectivity

### Phase 5: Monitoring Setup (Blocked)
- **Status:** Blocked by monitor VM SSH issue
- Requires troubleshooting or alternative solution

### Phase 6: CI/CD Pipeline (Pending)
- **Status:** Not started
- Depends on successful application deployment
- Requires GitHub secrets configuration

---

## 🎯 Success Criteria

### Minimum Viable Deployment (MVP)
- [x] Azure infrastructure deployed
- [x] App VM accessible via SSH
- [ ] Docker and Docker Compose installed on app VM
- [ ] Spring Boot backend running on port 8080
- [ ] React frontend running on port 5173
- [ ] Database connected and seeded with data
- [ ] Application accessible from internet

### Full Deployment (Desired)
- [ ] All MVP criteria met
- [ ] Nagios monitoring installed and running
- [ ] Monitoring dashboard accessible
- [ ] GitHub Actions CI/CD configured
- [ ] Automated deployment on code push
- [ ] Complete documentation

### Current Progress: ~60% (6/10 major tasks complete)

---

## 🛠️ Troubleshooting Commands

### Check Ansible Playbook Status (WSL)
```bash
cd /mnt/d/SMS_devOps/ansible
export APP_VM_IP="4.218.12.135"
export MONITOR_VM_IP="4.217.199.101"
export DB_HOST="sms-psql-server.postgres.database.azure.com"
export DB_USER="smsadmin"
export DB_PASSWORD="SMS_DevOps_2025!SecurePassword"
export JWT_SECRET="super-secret-change-me-please-1234567890abcdef"

# Test connectivity
ansible all -i inventory/hosts.yml -m ping --limit app_vm

# Check app VM status
ssh -i ~/.ssh/azure_sms_rsa azureuser@4.218.12.135 'docker --version'
```

### Check Azure Resources (PowerShell)
```powershell
# List all resources
az resource list --resource-group sms-devops-rg --output table

# Check VM status
az vm list --resource-group sms-devops-rg --show-details --output table

# Check NSG rules
az network nsg rule list --resource-group sms-devops-rg --nsg-name sms-nsg --output table

# Check NIC details
az network nic show --resource-group sms-devops-rg --name sms-monitor-nic --output json
```

### Terraform Operations
```powershell
cd D:\SMS_devOps\terraform

# Check state
terraform state list

# Taint and recreate monitor VM (if needed)
terraform taint azurerm_linux_virtual_machine.monitor_vm
terraform apply -auto-approve

# Destroy and recreate (nuclear option)
terraform destroy -target=azurerm_linux_virtual_machine.monitor_vm
terraform apply -auto-approve
```

---

## 📝 Notes

- App VM (4.218.12.135) is fully functional and responding to SSH
- Monitor VM (4.217.199.101) has network connectivity issues despite proper configuration
- PostgreSQL database is ready and waiting for application connection
- Ansible is configured and can manage app VM successfully
- WSL Ubuntu environment is fully operational with all required tools

**Last Updated:** November 16, 2024 (During app server Docker installation)
