#!/bin/bash
# Webhook Troubleshooting and Fix Script
# Run this on EC2 to diagnose and fix webhook issues

echo "=========================================="
echo "Jenkins Webhook Troubleshooting"
echo "=========================================="
echo ""

PUBLIC_IP=$(curl -s ifconfig.me)
echo "Your EC2 Public IP: $PUBLIC_IP"
echo "Your Webhook URL: http://$PUBLIC_IP:8080/github-webhook/"
echo ""

# Check Jenkins is running
echo "=== Jenkins Status ==="
if systemctl is-active --quiet jenkins; then
    echo "✅ Jenkins is running"
else
    echo "❌ Jenkins is NOT running - Starting it..."
    sudo systemctl start jenkins
    sleep 10
fi
echo ""

# Check webhook endpoint
echo "=== Testing Webhook Endpoint ==="
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -X POST http://localhost:8080/github-webhook/)
echo "Webhook endpoint response: HTTP $RESPONSE"
if [ "$RESPONSE" = "200" ] || [ "$RESPONSE" = "302" ] || [ "$RESPONSE" = "403" ]; then
    echo "✅ Webhook endpoint is accessible"
else
    echo "❌ Webhook endpoint issue detected"
fi
echo ""

# Check if GitHub plugin is installed
echo "=== Checking Jenkins Plugins ==="
if sudo test -d /var/lib/jenkins/plugins/github; then
    echo "✅ GitHub plugin is installed"
else
    echo "❌ GitHub plugin is NOT installed"
    echo "Install it from: Manage Jenkins → Plugins → Available plugins"
fi

if sudo test -d /var/lib/jenkins/plugins/git; then
    echo "✅ Git plugin is installed"
else
    echo "❌ Git plugin is NOT installed"
fi
echo ""

# Check Jenkins logs for webhook activity
echo "=== Recent Jenkins Logs (looking for webhook activity) ==="
sudo journalctl -u jenkins -n 50 --no-pager | grep -i "github\|webhook\|hook" || echo "No webhook-related logs found"
echo ""

# Check if job exists
echo "=== Checking Jenkins Jobs ==="
if sudo test -d /var/lib/jenkins/jobs; then
    echo "Jenkins jobs:"
    sudo ls -la /var/lib/jenkins/jobs/ | grep "^d" | awk '{print $9}' | grep -v "^\.$" | grep -v "^\.\.$"
else
    echo "No jobs directory found"
fi
echo ""

# Test GitHub connectivity
echo "=== Testing GitHub Connectivity ==="
if curl -s https://api.github.com/rate_limit > /dev/null; then
    echo "✅ Can reach GitHub API"
else
    echo "❌ Cannot reach GitHub API"
fi
echo ""

echo "=========================================="
echo "Common Issues and Fixes"
echo "=========================================="
echo ""

echo "Issue 1: Jenkins URL not set correctly"
echo "Fix: In Jenkins → Manage Jenkins → System → Jenkins Location"
echo "     Set Jenkins URL to: http://$PUBLIC_IP:8080/"
echo ""

echo "Issue 2: Job trigger not enabled"
echo "Fix: In job configuration → Build Triggers"
echo "     ✅ Check 'GitHub hook trigger for GITScm polling'"
echo ""

echo "Issue 3: GitHub webhook not configured"
echo "Fix: In GitHub → Settings → Webhooks → Add webhook"
echo "     Payload URL: http://$PUBLIC_IP:8080/github-webhook/"
echo "     Content type: application/json"
echo ""

echo "Issue 4: GitHub can't reach Jenkins (firewall)"
echo "Fix: Check EC2 security group allows inbound on port 8080 from 0.0.0.0/0"
echo ""

echo "=========================================="
echo "Manual Test Commands"
echo "=========================================="
echo ""
echo "Test webhook manually (run from EC2):"
echo "curl -X POST http://localhost:8080/github-webhook/"
echo ""
echo "Test from GitHub webhook page:"
echo "Go to: https://github.com/Hassanawi/MERN-AI-ChatBot/settings/hooks"
echo "Click on your webhook → Recent Deliveries → Redeliver"
echo ""
echo "Trigger Jenkins job manually (to verify job works):"
echo "curl -X POST http://localhost:8080/job/MERN-ChatBot-Selenium-Tests/build"
echo ""

echo "=========================================="
echo "Next Steps"
echo "=========================================="
echo ""
echo "1. Verify Jenkins URL is set to: http://$PUBLIC_IP:8080/"
echo "2. Verify job has 'GitHub hook trigger' enabled"
echo "3. Verify GitHub webhook URL: http://$PUBLIC_IP:8080/github-webhook/"
echo "4. Test webhook from GitHub: Settings → Webhooks → Recent Deliveries → Redeliver"
echo "5. Check Jenkins logs: sudo journalctl -u jenkins -f"
echo ""
