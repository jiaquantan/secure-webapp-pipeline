# Quick Start Script for Windows PowerShell
# Run this script to quickly test the application locally

Write-Host "🚀 Secure Web App Pipeline - Quick Start" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host ""

# Check if Docker is running
Write-Host "Checking Docker..." -ForegroundColor Yellow
try {
    docker info | Out-Null
    Write-Host "✓ Docker is running" -ForegroundColor Green
} catch {
    Write-Host "✗ Docker is not running. Please start Docker Desktop first." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Building Docker image..." -ForegroundColor Yellow
Set-Location app
docker build -t secure-webapp:local .

if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ Docker build failed" -ForegroundColor Red
    exit 1
}

Write-Host "✓ Docker image built successfully" -ForegroundColor Green
Write-Host ""

Write-Host "Starting application..." -ForegroundColor Yellow
docker run -d --name secure-webapp-test -p 5000:5000 secure-webapp:local

if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ Failed to start container" -ForegroundColor Red
    exit 1
}

Write-Host "✓ Application started" -ForegroundColor Green
Write-Host ""

# Wait for app to be ready
Write-Host "Waiting for application to be ready..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

# Test the application
Write-Host ""
Write-Host "Testing application..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:5000/health" -UseBasicParsing
    Write-Host "✓ Application is healthy!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Application is running at: http://localhost:5000" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Available endpoints:" -ForegroundColor White
    Write-Host "  - http://localhost:5000/          (Home)" -ForegroundColor Gray
    Write-Host "  - http://localhost:5000/health    (Health Check)" -ForegroundColor Gray
    Write-Host "  - http://localhost:5000/api/tasks (API)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "To stop the application, run:" -ForegroundColor White
    Write-Host "  docker stop secure-webapp-test" -ForegroundColor Gray
    Write-Host "  docker rm secure-webapp-test" -ForegroundColor Gray
} catch {
    Write-Host "✗ Application is not responding" -ForegroundColor Red
    Write-Host "Check logs with: docker logs secure-webapp-test" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "1. Review SETUP.md for full deployment guide" -ForegroundColor White
Write-Host "2. Configure AWS credentials" -ForegroundColor White
Write-Host "3. Deploy to AWS with Terraform" -ForegroundColor White
Write-Host "4. Set up GitHub Actions for CI/CD" -ForegroundColor White
