# Quick Docker Hub Push Script
# Run this after logging in to Docker Hub

Write-Host "=== Docker Hub Push for hsk09 ===" -ForegroundColor Cyan
Write-Host ""

# Configuration
$USERNAME = "hsk09"
$BACKEND_IMAGE = "mern-ai-chatbot-backend"
$FRONTEND_IMAGE = "mern-ai-chatbot-frontend"

# Step 1: Tag images
Write-Host "Step 1: Tagging images..." -ForegroundColor Yellow

docker tag ${BACKEND_IMAGE}:latest ${USERNAME}/mern-chatbot-backend:latest
docker tag ${FRONTEND_IMAGE}:latest ${USERNAME}/mern-chatbot-frontend:latest

Write-Host "✓ Images tagged successfully" -ForegroundColor Green
Write-Host ""

# Step 2: Push images
Write-Host "Step 2: Pushing to Docker Hub (this may take a few minutes)..." -ForegroundColor Yellow
Write-Host ""

Write-Host "Pushing backend..." -ForegroundColor Cyan
docker push ${USERNAME}/mern-chatbot-backend:latest

Write-Host ""
Write-Host "Pushing frontend..." -ForegroundColor Cyan
docker push ${USERNAME}/mern-chatbot-frontend:latest

Write-Host ""
Write-Host "=== Push Complete! ===" -ForegroundColor Green
Write-Host ""
Write-Host "Your images are now available at:" -ForegroundColor Cyan
Write-Host "  - https://hub.docker.com/r/${USERNAME}/mern-chatbot-backend" -ForegroundColor White
Write-Host "  - https://hub.docker.com/r/${USERNAME}/mern-chatbot-frontend" -ForegroundColor White
Write-Host ""
Write-Host "To deploy on EC2, run:" -ForegroundColor Yellow
Write-Host "  docker-compose pull" -ForegroundColor White
Write-Host "  docker-compose up -d" -ForegroundColor White
