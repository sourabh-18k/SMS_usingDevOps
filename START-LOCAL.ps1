#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Quick start script for local development
.DESCRIPTION
    Runs the SMS application locally for development and testing
#>

param(
    [Parameter(Mandatory=$false)]
    [switch]$SkipBackend,
    
    [Parameter(Mandatory=$false)]
    [switch]$SkipFrontend
)

# Color output
function Write-Step {
    param([string]$Message)
    Write-Host "`n=== $Message ===" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "[OK] $Message" -ForegroundColor Green
}

function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Yellow
}

$ProjectRoot = "d:\SMS_devOps"
Set-Location $ProjectRoot

Write-Host @"

╔═══════════════════════════════════════════════════╗
║                                                   ║
║     SMS DevOps - Local Development Startup       ║
║                                                   ║
╚═══════════════════════════════════════════════════╝

"@ -ForegroundColor Magenta

# ============================================================
# Check Prerequisites
# ============================================================
Write-Step "Checking Prerequisites"

$javaVersion = java -version 2>&1 | Select-String "version" | Select-Object -First 1
if ($javaVersion) {
    Write-Success "Java installed: $javaVersion"
} else {
    Write-Host "❌ Java not found. Install Java 17 or higher" -ForegroundColor Red
    exit 1
}

$nodeVersion = node --version 2>$null
if ($nodeVersion) {
    Write-Success "Node.js installed: $nodeVersion"
} else {
    Write-Host "❌ Node.js not found. Install from https://nodejs.org/" -ForegroundColor Red
    exit 1
}

$mavenVersion = mvn --version 2>&1 | Select-String "Apache Maven" | Select-Object -First 1
if ($mavenVersion) {
    Write-Success "Maven installed: $mavenVersion"
} else {
    Write-Host "❌ Maven not found. Install from https://maven.apache.org/" -ForegroundColor Red
    exit 1
}

# ============================================================
# Start Backend
# ============================================================
if (-not $SkipBackend) {
    Write-Step "Starting Backend (Spring Boot)"
    
    Set-Location "$ProjectRoot\backend"
    
    Write-Info "Starting backend on port 8080..."
    Write-Info "Profile: dev (using H2 in-memory database)"
    
    Start-Process powershell -ArgumentList "-NoExit", "-Command", `
        "cd '$ProjectRoot\backend'; `
         Write-Host 'Starting Spring Boot Backend...' -ForegroundColor Green; `
         mvn spring-boot:run -Dspring-boot.run.profiles=dev"
    
    Write-Success "Backend starting in separate window"
    Write-Info "Waiting 15 seconds for backend to initialize..."
    Start-Sleep -Seconds 15
}

# ============================================================
# Start Frontend
# ============================================================
if (-not $SkipFrontend) {
    Write-Step "Starting Frontend (React + Vite)"
    
    Set-Location "$ProjectRoot\frontend"
    
    # Install dependencies if needed
    if (-not (Test-Path "node_modules")) {
        Write-Info "Installing npm dependencies (first time only)..."
        npm install
    }
    
    Write-Info "Starting frontend on http://localhost:5173"
    
    Start-Process powershell -ArgumentList "-NoExit", "-Command", `
        "`$env:Path='C:\Program Files\nodejs;'+`$env:Path; `
         cd '$ProjectRoot\frontend'; `
         Write-Host 'Starting Vite Development Server...' -ForegroundColor Green; `
         npm run dev -- --host 0.0.0.0"
    
    Write-Success "Frontend starting in separate window"
    Write-Info "Waiting 10 seconds for frontend to start..."
    Start-Sleep -Seconds 10
}

Set-Location $ProjectRoot

# ============================================================
# Display Access Information
# ============================================================
Write-Host @"

╔═══════════════════════════════════════════════════╗
║                                                   ║
║          APPLICATION STARTED!                     ║
║                                                   ║
╚═══════════════════════════════════════════════════╝

"@ -ForegroundColor Green

Write-Host "ACCESS URLS" -ForegroundColor Cyan
Write-Host "=" * 60
Write-Host "Frontend (Application) : http://localhost:5173" -ForegroundColor Green
Write-Host "Backend (API)          : http://localhost:8080" -ForegroundColor Green
Write-Host "H2 Database Console    : http://localhost:8080/h2-console" -ForegroundColor Green
Write-Host "=" * 60

Write-Host "`nDEFAULT CREDENTIALS" -ForegroundColor Cyan
Write-Host "=" * 60
Write-Host "Application Admin : admin@sms.dev / ChangeMe123!" -ForegroundColor Yellow
Write-Host "H2 Database       : jdbc:h2:mem:smsdb / sa / (no password)" -ForegroundColor Yellow
Write-Host "=" * 60

Write-Host "`nQUICK COMMANDS" -ForegroundColor Cyan
Write-Host "=" * 60
Write-Host "Test backend health : curl http://localhost:8080/" -ForegroundColor White
Write-Host "Test login API      : curl -X POST http://localhost:8080/api/auth/login ``
                       -H 'Content-Type: application/json' ``
                       -d '{\"email\":\"admin@sms.dev\",\"password\":\"ChangeMe123!\"}'" -ForegroundColor White
Write-Host "Stop all            : Close the PowerShell windows or Ctrl+C" -ForegroundColor White
Write-Host "=" * 60

Write-Host "`nThe application is now running!" -ForegroundColor Green
Write-Host "   Open http://localhost:5173 in your browser" -ForegroundColor White
Write-Host "   No login required - goes directly to dashboard" -ForegroundColor White

Write-Host "`nPress Ctrl+C to stop this script (services will keep running in separate windows)`n" -ForegroundColor Yellow

# Keep this window open
while ($true) {
    Start-Sleep -Seconds 60
}
