#!/bin/bash
# EC2 Container Health Check and Fix Script
# Run this on your EC2 instance to diagnose and fix unhealthy containers

echo "=========================================="
echo "Container Health Diagnostics"
echo "=========================================="
echo ""

# Check container logs for errors
echo "=== Checking Backend CI Logs ==="
docker logs --tail 50 mern-chatbot-backend-ci
echo ""

echo "=== Checking Frontend CI Logs ==="
docker logs --tail 50 mern-chatbot-frontend-ci
echo ""

echo "=== Checking Backend (Dev) Logs ==="
docker logs --tail 50 mern-chatbot-backend
echo ""

echo "=== Checking Frontend (Dev) Logs ==="
docker logs --tail 50 mern-chatbot-frontend
echo ""

# Test services accessibility
echo "=========================================="
echo "Testing Service Accessibility"
echo "=========================================="
echo ""

echo "Testing Backend CI (port 5001)..."
if curl -s http://localhost:5001/api/v1 > /dev/null 2>&1; then
    echo "✅ Backend CI is responding"
else
    echo "❌ Backend CI not responding"
fi

echo "Testing Frontend CI (port 5174)..."
if curl -s http://localhost:5174 > /dev/null 2>&1; then
    echo "✅ Frontend CI is responding"
else
    echo "❌ Frontend CI not responding"
fi

echo "Testing Backend Dev (port 5000)..."
if curl -s http://localhost:5000/api/v1 > /dev/null 2>&1; then
    echo "✅ Backend Dev is responding"
else
    echo "❌ Backend Dev not responding"
fi

echo "Testing Frontend Dev (port 5173)..."
if curl -s http://localhost:5173 > /dev/null 2>&1; then
    echo "✅ Frontend Dev is responding"
else
    echo "❌ Frontend Dev not responding"
fi

echo ""
echo "=========================================="
echo "Recommendations"
echo "=========================================="
echo ""
echo "If containers are unhealthy but responding:"
echo "  - The healthcheck command might be incorrect"
echo "  - This won't affect functionality"
echo ""
echo "If containers are unhealthy and NOT responding:"
echo "  1. Check logs above for errors"
echo "  2. Verify environment variables in .env files"
echo "  3. Restart containers:"
echo "     cd ~/MERN-AI-ChatBot"
echo "     docker-compose -f docker-compose-ci.yml restart"
echo ""
echo "To restart all services:"
echo "  cd ~/MERN-AI-ChatBot"
echo "  docker-compose -f docker-compose-ci.yml down"
echo "  docker-compose -f docker-compose-ci.yml up -d"
echo ""
