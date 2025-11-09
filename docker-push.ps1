# Docker Build and Push Script for hsk09
# This script builds, tags, and pushes images to Docker Hub

Write-Host "=== MERN AI ChatBot - Docker Build & Push ===" -ForegroundColor Cyan
Write-Host ""

# Configuration
$DOCKER_USERNAME = "hsk09"
$BACKEND_IMAGE = "${DOCKER_USERNAME}/mern-chatbot-backend"
$FRONTEND_IMAGE = "${DOCKER_USERNAME}/mern-chatbot-frontend"
$VERSION = "1.0.0"

# Check if Docker is running
Write-Host "Checking Docker status..." -ForegroundColor Yellow
docker version | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Docker is not running. Please start Docker Desktop first." -ForegroundColor Red
    exit 1
}
Write-Host "✓ Docker is running" -ForegroundColor Green
Write-Host ""

# Step 1: Build images with docker-compose
Write-Host "Step 1: Building images with docker-compose..." -ForegroundColor Yellow
docker-compose build
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Docker build failed!" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Images built successfully" -ForegroundColor Green
Write-Host ""

# Step 2: Tag images for Docker Hub
Write-Host "Step 2: Tagging images for Docker Hub..." -ForegroundColor Yellow

# Get the image names that were just built
$BACKEND_LOCAL = "mern-ai-chatbot-backend"
$FRONTEND_LOCAL = "mern-ai-chatbot-frontend"

# Tag backend
docker tag "${BACKEND_LOCAL}:latest" "${BACKEND_IMAGE}:latest"
docker tag "${BACKEND_LOCAL}:latest" "${BACKEND_IMAGE}:${VERSION}"
Write-Host "✓ Tagged backend image: ${BACKEND_IMAGE}:latest and ${BACKEND_IMAGE}:${VERSION}" -ForegroundColor Green

# Tag frontend
docker tag "${FRONTEND_LOCAL}:latest" "${FRONTEND_IMAGE}:latest"
docker tag "${FRONTEND_LOCAL}:latest" "${FRONTEND_IMAGE}:${VERSION}"
Write-Host "✓ Tagged frontend image: ${FRONTEND_IMAGE}:latest and ${FRONTEND_IMAGE}:${VERSION}" -ForegroundColor Green
Write-Host ""

# Step 3: Login to Docker Hub
Write-Host "Step 3: Logging in to Docker Hub..." -ForegroundColor Yellow
Write-Host "Please enter your Docker Hub credentials:" -ForegroundColor Cyan
docker login -u $DOCKER_USERNAME
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Docker Hub login failed!" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Logged in to Docker Hub" -ForegroundColor Green
Write-Host ""

# Step 4: Push images to Docker Hub
Write-Host "Step 4: Pushing images to Docker Hub..." -ForegroundColor Yellow

Write-Host "Pushing backend image..." -ForegroundColor Cyan
docker push "${BACKEND_IMAGE}:latest"
docker push "${BACKEND_IMAGE}:${VERSION}"
Write-Host "✓ Backend image pushed successfully" -ForegroundColor Green

Write-Host "Pushing frontend image..." -ForegroundColor Cyan
docker push "${FRONTEND_IMAGE}:latest"
docker push "${FRONTEND_IMAGE}:${VERSION}"
Write-Host "✓ Frontend image pushed successfully" -ForegroundColor Green
Write-Host ""

# Step 5: Summary
Write-Host "=== Build and Push Complete! ===" -ForegroundColor Green
Write-Host ""
Write-Host "Images available at:" -ForegroundColor Cyan
Write-Host "  - https://hub.docker.com/r/${DOCKER_USERNAME}/mern-chatbot-backend" -ForegroundColor White
Write-Host "  - https://hub.docker.com/r/${DOCKER_USERNAME}/mern-chatbot-frontend" -ForegroundColor White
Write-Host ""
Write-Host "To pull these images:" -ForegroundColor Yellow
Write-Host "  docker pull ${BACKEND_IMAGE}:latest" -ForegroundColor White
Write-Host "  docker pull ${FRONTEND_IMAGE}:latest" -ForegroundColor White
Write-Host ""
Write-Host "To run with docker-compose:" -ForegroundColor Yellow
Write-Host "  docker-compose pull" -ForegroundColor White
Write-Host "  docker-compose up -d" -ForegroundColor White
