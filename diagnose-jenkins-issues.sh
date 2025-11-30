#!/bin/bash
# Complete Diagnosis and Fix Script for Jenkins Issues
# Run this on EC2 to check everything

echo "=========================================="
echo "Jenkins Build Issues Diagnosis"
echo "=========================================="
echo ""

# Check Jenkins workspace
echo "=== Jenkins Workspace Check ==="
WORKSPACE="/var/lib/jenkins/workspace/MERN-ChatBot-Pipeline"

if [ -d "$WORKSPACE" ]; then
    echo "✅ Workspace exists"
    echo ""
    echo "Workspace contents:"
    sudo ls -la "$WORKSPACE"
    echo ""
    
    if [ -d "$WORKSPACE/tests" ]; then
        echo "✅ Tests directory exists"
        echo ""
        echo "Tests directory contents:"
        sudo ls -la "$WORKSPACE/tests"
    else
        echo "❌ Tests directory NOT found in workspace"
        echo ""
        echo "This means Jenkins checkout is not complete!"
    fi
else
    echo "❌ Workspace directory doesn't exist"
    echo "Jenkins job hasn't run successfully yet"
fi

echo ""
echo "=== Git Repository Check ==="
cd ~/MERN-AI-ChatBot 2>/dev/null || {
    echo "❌ Repository not found in home directory"
    echo "Clone it with: git clone https://github.com/Hassanawi/MERN-AI-ChatBot.git"
    exit 1
}

echo "✅ Repository exists in ~/MERN-AI-ChatBot"
echo ""
echo "Repository contents:"
ls -la
echo ""

if [ -d "tests" ]; then
    echo "✅ Tests directory exists in repository"
    echo ""
    echo "Tests directory contents:"
    ls -la tests/
else
    echo "❌ Tests directory NOT found in repository"
fi

echo ""
echo "=== Docker Check ==="
echo "Can Jenkins user access Docker?"
if sudo -u jenkins docker ps >/dev/null 2>&1; then
    echo "✅ Jenkins can access Docker"
else
    echo "❌ Jenkins CANNOT access Docker"
    echo "Fix with:"
    echo "  sudo usermod -aG docker jenkins"
    echo "  sudo systemctl restart jenkins"
fi

echo ""
echo "=== Email Configuration Check ==="
echo "Checking Jenkins email credentials..."

if sudo grep -q "gmail" /var/lib/jenkins/jenkins.model.JenkinsLocationConfiguration.xml 2>/dev/null; then
    echo "✅ Jenkins location config exists"
else
    echo "⚠️  Jenkins location config not found or doesn't contain Gmail"
fi

if [ -d /var/lib/jenkins/credentials.xml ]; then
    echo "✅ Credentials file exists"
else
    echo "⚠️  No credentials configured yet"
fi

echo ""
echo "=========================================="
echo "Recommended Fixes"
echo "=========================================="
echo ""

echo "1. Ensure Git repository is properly checked out in Jenkins:"
echo "   - In Jenkins job → Configure → SCM"
echo "   - Verify Repository URL: https://github.com/Hassanawi/MERN-AI-ChatBot.git"
echo "   - Verify Branch: */final"
echo "   - Save and run 'Build Now'"
echo ""

echo "2. Configure Gmail SMTP in Jenkins:"
echo "   - Manage Jenkins → System"
echo "   - Extended E-mail Notification:"
echo "     SMTP: smtp.gmail.com, Port: 465, SSL: ✅"
echo "     Add credentials with Gmail app password"
echo "   - E-mail Notification:"
echo "     Same settings, test with 'Test configuration'"
echo ""

echo "3. Verify Jenkins has Docker access:"
echo "   sudo -u jenkins docker ps"
echo ""

echo "4. Check Jenkins logs for detailed errors:"
echo "   sudo journalctl -u jenkins -n 100 --no-pager"
echo ""

echo "=========================================="
echo "Quick Test Commands"
echo "=========================================="
echo ""
echo "# Test if tests directory is in the repo:"
echo "cd ~/MERN-AI-ChatBot && ls -la tests/"
echo ""
echo "# Copy tests to Jenkins workspace manually (temporary fix):"
echo "sudo cp -r ~/MERN-AI-ChatBot/tests /var/lib/jenkins/workspace/MERN-ChatBot-Pipeline/"
echo "sudo chown -R jenkins:jenkins /var/lib/jenkins/workspace/MERN-ChatBot-Pipeline/tests"
echo ""
echo "# Then trigger new build in Jenkins"
echo ""
