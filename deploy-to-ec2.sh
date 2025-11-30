#!/bin/bash
# Quick deployment script for MERN ChatBot on EC2
# Run this after ec2-setup.sh completes

echo "=========================================="
echo "Deploying MERN AI ChatBot Application"
echo "=========================================="
echo ""

# Navigate to home directory
cd ~

# Check if repository exists
if [ -d "MERN-AI-ChatBot" ]; then
    echo "Repository exists. Pulling latest changes..."
    cd MERN-AI-ChatBot
    git pull origin final
else
    echo "Cloning repository..."
    git clone https://github.com/Hassanawi/MERN-AI-ChatBot.git
    cd MERN-AI-ChatBot
fi

echo ""
echo "=========================================="
echo "Configuration"
echo "=========================================="
echo ""

# Create backend .env if it doesn't exist
if [ ! -f "backend/.env" ]; then
    echo "Creating backend/.env file..."
    cat > backend/.env << 'EOF'
MONGODB_URL=mongodb://mongo-ci:27017/mernai_chatbot
JWT_SECRET=your-jwt-secret-key-please-change-this
COOKIE_SECRET=your-cookie-secret-key-please-change-this
OPEN_AI_SECRET=your-openrouter-api-key-here
OPENROUTER_BASE=https://openrouter.ai/api/v1
OPENROUTER_MODEL=google/gemini-2.0-flash-exp:free
PORT=5001
EOF
    echo "⚠️  IMPORTANT: Edit backend/.env and update secrets!"
    echo "   nano backend/.env"
fi

# Create root .env if it doesn't exist
if [ ! -f ".env" ]; then
    echo "Creating .env file..."
    cat > .env << 'EOF'
DOCKER_HUB_USERNAME=your-dockerhub-username
EOF
    echo "⚠️  IMPORTANT: Edit .env and update Docker Hub username!"
    echo "   nano .env"
fi

echo ""
echo "=========================================="
echo "Starting Application"
echo "=========================================="
echo ""

# Stop any existing containers
echo "Stopping existing containers..."
docker-compose -f docker-compose-ci.yml down

# Start containers
echo "Starting new containers..."
docker-compose -f docker-compose-ci.yml up -d

# Wait for services
echo "Waiting for services to start..."
sleep 30

# Check status
echo ""
echo "=========================================="
echo "Container Status"
echo "=========================================="
docker-compose -f docker-compose-ci.yml ps

# Test services
echo ""
echo "=========================================="
echo "Testing Services"
echo "=========================================="
echo ""

echo "Testing Backend..."
if curl -s http://localhost:5001/api/v1 > /dev/null; then
    echo "✅ Backend is responding"
else
    echo "❌ Backend not responding"
fi

echo "Testing Frontend..."
if curl -s http://localhost:5174 > /dev/null; then
    echo "✅ Frontend is responding"
else
    echo "❌ Frontend not responding"
fi

# Get public IP
PUBLIC_IP=$(curl -s ifconfig.me)

echo ""
echo "=========================================="
echo "Deployment Complete!"
echo "=========================================="
echo ""
echo "=== Application URLs ==="
echo "Frontend (CI): http://$PUBLIC_IP:5174"
echo "Backend (CI):  http://$PUBLIC_IP:5001"
echo "Jenkins:       http://$PUBLIC_IP:8080"
echo ""
echo "=== View Logs ==="
echo "docker-compose -f docker-compose-ci.yml logs -f"
echo ""
echo "=== Stop Application ==="
echo "docker-compose -f docker-compose-ci.yml down"
echo ""
echo "=========================================="
