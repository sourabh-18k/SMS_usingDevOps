#!/usr/bin/env pwsh
# Quick start script - runs backend and frontend in one command

Write-Host "Starting SMS Application..." -ForegroundColor Cyan

# Start Backend
Start-Job -ScriptBlock {
    Set-Location "d:\SMS_devOps\backend"
    mvn spring-boot:run -Dspring-boot.run.profiles=dev
} -Name "Backend"

Write-Host "[OK] Backend starting on port 8080" -ForegroundColor Green

# Wait a bit for backend to initialize
Start-Sleep -Seconds 10

# Start Frontend
Start-Job -ScriptBlock {
    Set-Location "d:\SMS_devOps\frontend"
    npm run dev
} -Name "Frontend"

Write-Host "[OK] Frontend starting on port 5173" -ForegroundColor Green
Write-Host ""
Write-Host "Application starting..." -ForegroundColor Yellow
Write-Host "Wait 30 seconds, then open: http://localhost:5173" -ForegroundColor Green
Write-Host ""
Write-Host "To view logs:" -ForegroundColor Cyan
Write-Host "  Get-Job | Receive-Job" -ForegroundColor White
Write-Host ""
Write-Host "To stop all:" -ForegroundColor Cyan
Write-Host "  Get-Job | Stop-Job; Get-Job | Remove-Job" -ForegroundColor White
Write-Host ""

# Show job status
Get-Job | Format-Table -AutoSize
