#!/bin/bash
# Jenkins and Webhook Verification Script
# Run this on EC2 to verify Jenkins and webhook setup

echo "=========================================="
echo "Jenkins & Webhook Verification"
echo "=========================================="
echo ""

# Get public IP
PUBLIC_IP=$(curl -s ifconfig.me)
echo "Your EC2 Public IP: $PUBLIC_IP"
echo ""

# Check Jenkins status
echo "=== Jenkins Status ==="
if systemctl is-active --quiet jenkins; then
    echo "✅ Jenkins is running"
    sudo systemctl status jenkins --no-pager | head -n 10
else
    echo "❌ Jenkins is NOT running"
    echo "Start it with: sudo systemctl start jenkins"
fi
echo ""

# Check Jenkins port
echo "=== Jenkins Port Check ==="
if netstat -tulpn 2>/dev/null | grep -q ":8080"; then
    echo "✅ Port 8080 is listening"
    netstat -tulpn 2>/dev/null | grep ":8080" | head -n 1
else
    echo "❌ Port 8080 is NOT listening"
fi
echo ""

# Test Jenkins accessibility
echo "=== Jenkins Accessibility Test ==="
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080 2>/dev/null)
if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "403" ]; then
    echo "✅ Jenkins is accessible locally (HTTP $HTTP_CODE)"
else
    echo "❌ Jenkins is NOT accessible (HTTP $HTTP_CODE)"
fi
echo ""

# Check if Docker is accessible to Jenkins
echo "=== Jenkins Docker Access ==="
if sudo -u jenkins docker ps >/dev/null 2>&1; then
    echo "✅ Jenkins can access Docker"
else
    echo "❌ Jenkins CANNOT access Docker"
    echo "Fix with:"
    echo "  sudo usermod -aG docker jenkins"
    echo "  sudo systemctl restart jenkins"
fi
echo ""

# Display webhook URL
echo "=========================================="
echo "Your GitHub Webhook Configuration"
echo "=========================================="
echo ""
echo "Use this URL in GitHub webhook settings:"
echo "  http://$PUBLIC_IP:8080/github-webhook/"
echo ""
echo "Content type:"
echo "  application/json"
echo ""
echo "Events:"
echo "  Just the push event"
echo ""

# Test webhook endpoint
echo "=== Testing Webhook Endpoint ==="
WEBHOOK_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -X POST http://localhost:8080/github-webhook/ 2>/dev/null)
if [ "$WEBHOOK_RESPONSE" = "200" ] || [ "$WEBHOOK_RESPONSE" = "302" ]; then
    echo "✅ Webhook endpoint is responding (HTTP $WEBHOOK_RESPONSE)"
else
    echo "⚠️  Webhook endpoint returned HTTP $WEBHOOK_RESPONSE"
    echo "This might be normal - webhook needs proper GitHub payload"
fi
echo ""

# Check Jenkins logs
echo "=== Recent Jenkins Logs (last 20 lines) ==="
sudo journalctl -u jenkins -n 20 --no-pager
echo ""

# Display URLs
echo "=========================================="
echo "Your Application URLs"
echo "=========================================="
echo ""
echo "Jenkins:       http://$PUBLIC_IP:8080"
echo "Frontend (CI): http://$PUBLIC_IP:5174"
echo "Backend (CI):  http://$PUBLIC_IP:5001"
echo "Frontend (Dev):http://$PUBLIC_IP:5173"
echo "Backend (Dev): http://$PUBLIC_IP:5000"
echo ""

# Test application accessibility from outside
echo "=== Testing Application Ports ==="
for PORT in 8080 5174 5001 5173 5000; do
    if netstat -tulpn 2>/dev/null | grep -q ":$PORT"; then
        echo "✅ Port $PORT is listening"
    else
        echo "❌ Port $PORT is NOT listening"
    fi
done
echo ""

echo "=========================================="
echo "Next Steps"
echo "=========================================="
echo ""
echo "1. Access Jenkins:"
echo "   Open: http://$PUBLIC_IP:8080"
echo ""
echo "2. Configure Jenkins webhook URL:"
echo "   Manage Jenkins → System → Jenkins Location"
echo "   Set to: http://$PUBLIC_IP:8080/"
echo ""
echo "3. Add GitHub webhook:"
echo "   GitHub → Settings → Webhooks → Add webhook"
echo "   URL: http://$PUBLIC_IP:8080/github-webhook/"
echo ""
echo "4. Test webhook:"
echo "   git commit --allow-empty -m 'Test webhook'"
echo "   git push origin final"
echo ""
