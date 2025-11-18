# GitHub Actions CI/CD Setup Guide

## 🔐 Step 1: Add GitHub Secrets

Go to your GitHub repository:
**Settings → Secrets and variables → Actions → New repository secret**

Add these secrets:

### Required Secrets:
```
AZURE_VM_IP=4.218.14.65
AZURE_VM_USER=azureuser
AZURE_SSH_KEY=<paste your private SSH key from ~/.ssh/id_rsa>
DB_HOST=sms-psql-server.postgres.database.azure.com
DB_USER=smsadmin
DB_PASSWORD=SMS_DevOps_2025!SecurePassword
```

### How to get SSH key:
```powershell
# Windows (WSL)
wsl -- cat ~/.ssh/id_rsa

# Or if generated in Windows
cat $env:USERPROFILE\.ssh\id_rsa
```

---

## 🚀 Step 2: Push to GitHub

```powershell
cd d:\SMS_devOps
git add .github/workflows/deploy.yml
git commit -m "Add CI/CD pipeline"
git push origin main
```

**GitHub Actions will automatically:**
1. ✅ Build Docker images
2. ✅ Push to GitHub Container Registry
3. ✅ Deploy to your Azure VM
4. ✅ Restart containers with new code

---

## 📊 Step 3: Monitor Deployment

1. Go to **GitHub → Actions tab**
2. Watch the workflow run in real-time
3. See deployment status and logs

---

## 🔄 Step 4: Continuous Deployment

**Now every time you push code:**
```powershell
# Make changes to your code
git add .
git commit -m "Update feature X"
git push origin main
```

GitHub Actions automatically:
- Builds new images
- Deploys to Azure
- No manual steps needed!

---

## 🎯 Benefits of GitHub Actions:

### Without GitHub Actions (Manual):
```
1. Make code changes
2. SSH to Azure VM
3. git pull
4. docker build
5. docker stop old container
6. docker run new container
7. Test manually
⏱️ Takes: 10-15 minutes
```

### With GitHub Actions (Automated):
```
1. Make code changes
2. git push
✅ Everything else is automatic!
⏱️ Takes: 2-3 minutes (hands-off)
```

---

## 📝 Additional GitHub Actions Features

You can add more automation:

### 1. Run Tests Before Deploy
```yaml
- name: Run Tests
  run: |
    cd backend
    mvn test
```

### 2. Send Slack/Teams Notifications
```yaml
- name: Notify Deployment
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    text: 'Deployment completed!'
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

### 3. Deploy to Multiple Environments
```yaml
jobs:
  deploy-dev:
    # Deploy to dev server
  
  deploy-prod:
    needs: deploy-dev
    # Deploy to production after dev succeeds
```

### 4. Rollback on Failure
```yaml
- name: Health Check
  run: curl --fail http://${{ secrets.AZURE_VM_IP }}:8080/health || exit 1
  
- name: Rollback on Failure
  if: failure()
  run: # Restore previous version
```

---

## 🏗️ Complete DevOps Pipeline

```
Developer → Git Push → GitHub Actions → Build → Test → Deploy → Monitor
    ↓
Local Dev ──→ GitHub ──→ Docker Images ──→ Azure VM ──→ Production
                              │
                              ├──→ Backend Container
                              └──→ Frontend Container
```

---

## 🎓 Summary

**Before GitHub Actions:**
- Manual SSH
- Manual Docker commands
- Prone to errors
- Time-consuming

**After GitHub Actions:**
- Just `git push`
- Automatic deployment
- Consistent process
- Fast and reliable

---

## 🚦 Current vs Complete Setup

### Current (Manual):
```
Terraform → Manual SSH → Manual Deploy
```

### Complete DevOps:
```
Terraform (Infrastructure) → GitHub Actions (CI/CD) → Monitoring (Nagios)
     ↓                              ↓                        ↓
Create VMs/DB              Auto Build & Deploy        Track Health
```

This is the **full DevOps pipeline**! 🎉
