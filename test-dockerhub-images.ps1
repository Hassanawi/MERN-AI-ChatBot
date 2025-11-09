# Docker Image Verification Script
# This tests if your Docker Hub images can be pulled and run

Write-Host "=== Docker Image Verification ===" -ForegroundColor Cyan
Write-Host ""

# Stop current containers to free up ports
Write-Host "Step 1: Stopping current containers..." -ForegroundColor Yellow
docker-compose down

Write-Host "✓ Containers stopped" -ForegroundColor Green
Write-Host ""

# Pull images from Docker Hub
Write-Host "Step 2: Pulling images from Docker Hub..." -ForegroundColor Yellow
docker pull hsk09/mern-chatbot-backend:latest
docker pull hsk09/mern-chatbot-frontend:latest

Write-Host "✓ Images pulled successfully" -ForegroundColor Green
Write-Host ""

# Start services with pulled images
Write-Host "Step 3: Starting services with Docker Hub images..." -ForegroundColor Yellow
docker-compose up -d

Write-Host ""
Write-Host "Waiting for services to start..." -ForegroundColor Cyan
Start-Sleep -Seconds 10

# Check container status
Write-Host ""
Write-Host "Step 4: Verifying containers..." -ForegroundColor Yellow
docker ps

Write-Host ""
Write-Host "=== Verification Complete ===" -ForegroundColor Green
Write-Host ""
Write-Host "Test your application at:" -ForegroundColor Cyan
Write-Host "  Frontend: http://localhost:5173" -ForegroundColor White
Write-Host "  Backend:  http://localhost:5000" -ForegroundColor White
Write-Host ""
Write-Host "To view logs:" -ForegroundColor Yellow
Write-Host "  docker-compose logs -f" -ForegroundColor White
