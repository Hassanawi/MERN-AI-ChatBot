# Quick test runner for local development (Windows)

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "MERN ChatBot - Test Runner" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan

# Check if application is running
Write-Host ""
Write-Host "Checking if application is running..." -ForegroundColor Yellow
$containers = docker ps --format "{{.Names}}" | Select-String "mern-chatbot"
if (-not $containers) {
    Write-Host "⚠️  Application containers not found!" -ForegroundColor Red
    Write-Host "Starting application with docker-compose-ci.yml..." -ForegroundColor Yellow
    docker-compose -f docker-compose-ci.yml up -d
    Write-Host "Waiting for services to start (30 seconds)..." -ForegroundColor Yellow
    Start-Sleep -Seconds 30
} else {
    Write-Host "✅ Application containers are running" -ForegroundColor Green
}

# Navigate to tests directory
Set-Location tests

# Check if virtual environment exists
if (-not (Test-Path "venv")) {
    Write-Host ""
    Write-Host "Creating virtual environment..." -ForegroundColor Yellow
    python -m venv venv
}

# Activate virtual environment
Write-Host ""
Write-Host "Activating virtual environment..." -ForegroundColor Yellow
.\venv\Scripts\Activate.ps1

# Install dependencies
Write-Host ""
Write-Host "Installing dependencies..." -ForegroundColor Yellow
pip install -q -r requirements.txt

# Run tests
Write-Host ""
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Running Selenium Tests" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
pytest test_chatbot.py -v --html=reports/test_report.html --self-contained-html

# Check test result
if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "==================================" -ForegroundColor Green
    Write-Host "✅ All tests passed!" -ForegroundColor Green
    Write-Host "==================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "📊 Test report: tests/reports/test_report.html" -ForegroundColor Cyan
    Write-Host "📸 Screenshots: tests/reports/screenshots/" -ForegroundColor Cyan
} else {
    Write-Host ""
    Write-Host "==================================" -ForegroundColor Red
    Write-Host "❌ Some tests failed!" -ForegroundColor Red
    Write-Host "==================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "📊 Check test report: tests/reports/test_report.html" -ForegroundColor Yellow
    Write-Host "📸 Check screenshots: tests/reports/screenshots/" -ForegroundColor Yellow
}

# Deactivate virtual environment
deactivate

Write-Host ""
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Test execution completed!" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan

# Return to root directory
Set-Location ..
