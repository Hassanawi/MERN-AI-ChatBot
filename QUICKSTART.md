# 🚀 Quick Start Guide - MERN AI ChatBot

## Prerequisites
✅ Docker Desktop installed and running
✅ Docker Hub account: `hsk09`
✅ Git repository cloned

---

## Step 1: Build Docker Images (5-10 minutes)

```powershell
# Navigate to project directory
cd E:\university\devops\project\MERN-AI-ChatBot

# Make sure Docker Desktop is running
docker version

# Build all images
docker-compose build

# This will create:
# - mern-ai-chatbot-backend
# - mern-ai-chatbot-frontend
# - mongo:7.0
```

**Expected Output:**
```
✓ mongo uses an image, skipping
✓ backend: Building...
✓ frontend: Building...
Successfully built [image-ids]
Successfully tagged mern-ai-chatbot-backend:latest
Successfully tagged mern-ai-chatbot-frontend:latest
```

---

## Step 2: Push to Docker Hub (Automated Script)

### Option A: Use PowerShell Script (Recommended)
```powershell
# Run the automated build and push script
.\docker-push.ps1

# Enter your Docker Hub password when prompted
```

### Option B: Manual Commands
```powershell
# Login to Docker Hub
docker login -u hsk09
# Enter your password

# Tag images
docker tag mern-ai-chatbot-backend:latest hsk09/mern-chatbot-backend:latest
docker tag mern-ai-chatbot-backend:latest hsk09/mern-chatbot-backend:1.0.0
docker tag mern-ai-chatbot-frontend:latest hsk09/mern-chatbot-frontend:latest
docker tag mern-ai-chatbot-frontend:latest hsk09/mern-chatbot-frontend:1.0.0

# Push to Docker Hub
docker push hsk09/mern-chatbot-backend:latest
docker push hsk09/mern-chatbot-backend:1.0.0
docker push hsk09/mern-chatbot-frontend:latest
docker push hsk09/mern-chatbot-frontend:1.0.0
```

---

## Step 3: Test Locally with Docker Compose

```powershell
# Start all services
docker-compose up -d

# Check if containers are running
docker ps

# View logs
docker-compose logs -f backend
docker-compose logs -f frontend

# Access the application
# Frontend: http://localhost:5173
# Backend: http://localhost:5000
# MongoDB: localhost:27017

# Stop services
docker-compose down
```

---

## Step 4: Verify Images on Docker Hub

Visit your Docker Hub repositories:
- https://hub.docker.com/r/hsk09/mern-chatbot-backend
- https://hub.docker.com/r/hsk09/mern-chatbot-frontend

---

## Step 5: Test CI/CD Setup

```powershell
# Test with CI docker-compose
docker-compose -f docker-compose-ci.yml pull
docker-compose -f docker-compose-ci.yml up -d

# Services will run on different ports:
# Frontend: http://localhost:5174
# Backend: http://localhost:5001
# MongoDB: localhost:27018

# Stop CI services
docker-compose -f docker-compose-ci.yml down
```

---

## Common Commands Reference

### Docker Images
```powershell
# List all images
docker images

# Remove an image
docker rmi <image-id>

# Remove all unused images
docker image prune -a
```

### Docker Containers
```powershell
# List running containers
docker ps

# List all containers (including stopped)
docker ps -a

# Stop a container
docker stop <container-id>

# Remove a container
docker rm <container-id>

# View container logs
docker logs <container-id>
docker logs -f <container-id>  # Follow mode
```

### Docker Compose
```powershell
# Build images
docker-compose build

# Start services
docker-compose up -d

# Stop services
docker-compose down

# Rebuild and restart
docker-compose up -d --build

# View logs
docker-compose logs -f

# Check service status
docker-compose ps
```

---

## Troubleshooting

### Issue: Docker daemon not running
**Solution:** Start Docker Desktop and wait for it to fully initialize

### Issue: Port already in use
**Solution:** 
```powershell
# Stop existing services
docker-compose down

# Kill node processes
Get-Process -Name node | Stop-Process -Force

# Try again
docker-compose up -d
```

### Issue: Build fails
**Solution:**
```powershell
# Clean Docker cache
docker system prune -a

# Rebuild without cache
docker-compose build --no-cache
```

### Issue: Cannot push to Docker Hub
**Solution:**
```powershell
# Make sure you're logged in
docker login -u hsk09

# Check image tags
docker images | grep hsk09

# Retry push
docker push hsk09/mern-chatbot-backend:latest
```

---

## Screenshots Checklist for Assignment

### Required Screenshots:
1. ✅ **Docker Build Success**
   - Run: `docker-compose build`
   - Screenshot showing successful build output

2. ✅ **Docker Containers Running**
   - Run: `docker ps`
   - Screenshot showing all 3 containers running

3. ✅ **Docker Hub Images**
   - Visit: https://hub.docker.com/u/hsk09
   - Screenshot showing both repositories

4. ✅ **Application Working**
   - Open: http://localhost:5173
   - Screenshot of signup/login page
   - Screenshot of chat interface
   - Screenshot of successful AI response

5. ✅ **Backend Logs**
   - Run: `docker-compose logs backend`
   - Screenshot showing OpenRouter API responses

6. ✅ **Jenkins Pipeline** (if required)
   - Screenshot of successful Jenkins build
   - Screenshot of pipeline stages

---

## Next Steps

1. ✅ Build Docker images
2. ✅ Push to Docker Hub (hsk09)
3. ✅ Test locally with docker-compose
4. ✅ Take screenshots
5. ✅ Set up Jenkins (if required)
6. ✅ Write assignment report

---

## Your Docker Hub Repositories

- Backend: `hsk09/mern-chatbot-backend:latest`
- Frontend: `hsk09/mern-chatbot-frontend:latest`

To pull and run on any machine:
```powershell
git clone https://github.com/Hassanawi/MERN-AI-ChatBot.git
cd MERN-AI-ChatBot
docker-compose pull
docker-compose up -d
```

---

Good luck with your assignment! 🎉
