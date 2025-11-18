# GitHub Secrets Setup - Step 5

## 🔐 Add These Secrets to Your GitHub Repository

Go to your GitHub repository → Settings → Secrets and variables → Actions → New repository secret

### Required Secrets (7-8 total):

#### 1. AZURE_SSH_PRIVATE_KEY
**Value:** Copy the ENTIRE content of your private key:
```powershell
Get-Content C:\Users\HP\.ssh\azure_sms_rsa | Out-String
```
**Important:** Include the full key with `-----BEGIN OPENSSH PRIVATE KEY-----` and `-----END OPENSSH PRIVATE KEY-----`

#### 2. AZURE_APP_VM_IP
**Value:** 
```
4.218.12.135
```

#### 3. AZURE_MONITOR_VM_IP
**Value:** 
```
4.217.199.101
```

#### 4. AZURE_DB_HOST
**Value:** 
```
sms-psql-server.postgres.database.azure.com
```

#### 5. AZURE_DB_USER
**Value:** 
```
smsadmin
```

#### 6. AZURE_DB_PASSWORD
**Value:** 
```
SMS_DevOps_2025!SecurePassword
```

#### 7. JWT_SECRET
**Value:** 
```
super-secret-change-me-please-1234567890abcdef
```

#### 8. AZURE_DB_NAME (Optional - if needed by workflows)
**Value:** 
```
sms
```

---

## 🚀 Quick Setup Command

Run this PowerShell command to display your private key for copying:

```powershell
notepad C:\Users\HP\.ssh\azure_sms_rsa
```

Copy the entire content and paste as `AZURE_SSH_PRIVATE_KEY` secret.

---

## ✅ After Adding Secrets

Your GitHub Actions workflows will be able to:
- SSH into both VMs
- Deploy applications automatically
- Configure the database connection
- Set up JWT authentication

---

## 🔗 Your Deployed Resources

- **Frontend:** http://4.218.12.135:5173
- **Backend API:** http://4.218.12.135:8080
- **Nagios Monitor:** http://4.217.199.101/nagios
- **Database:** sms-psql-server.postgres.database.azure.com:5432

---

## 📝 Next Steps After Secrets Setup

1. Push code to trigger GitHub Actions workflow
2. Workflow will automatically deploy to Azure VMs
3. Applications will be accessible at the URLs above

