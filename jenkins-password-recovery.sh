#!/bin/bash
# Jenkins Password Recovery Script
# Run this on your EC2 instance to get Jenkins credentials

echo "=========================================="
echo "Jenkins Password Recovery"
echo "=========================================="
echo ""

# Check if Jenkins is installed and running
if ! systemctl is-active --quiet jenkins; then
    echo "❌ Jenkins is not running!"
    echo "Start it with: sudo systemctl start jenkins"
    exit 1
fi

echo "✅ Jenkins is running"
echo ""

# Get initial admin password
echo "=== Jenkins Initial Admin Password ==="
if [ -f /var/lib/jenkins/secrets/initialAdminPassword ]; then
    echo "Initial admin password:"
    sudo cat /var/lib/jenkins/secrets/initialAdminPassword
    echo ""
    echo "Use this password for the first login."
else
    echo "⚠️  Initial password file not found (already logged in before)"
fi
echo ""

# Check if admin user exists
echo "=== Checking Admin User ==="
if [ -d /var/lib/jenkins/users/admin* ]; then
    echo "✅ Admin user exists"
    echo ""
    echo "If you forgot your password, you can reset it:"
    echo ""
    echo "Option 1: Disable security temporarily"
    echo "  1. sudo systemctl stop jenkins"
    echo "  2. sudo nano /var/lib/jenkins/config.xml"
    echo "  3. Change <useSecurity>true</useSecurity> to <useSecurity>false</useSecurity>"
    echo "  4. sudo systemctl start jenkins"
    echo "  5. Access Jenkins (no password needed)"
    echo "  6. Go to Manage Jenkins → Security → Configure Global Security"
    echo "  7. Re-enable security and set new password"
    echo "  8. Change config.xml back to <useSecurity>true</useSecurity>"
    echo ""
    echo "Option 2: Reset password via console"
    echo "  1. Access Jenkins: Manage Jenkins → Script Console"
    echo "  2. Run this script:"
    echo '     import jenkins.model.*'
    echo '     def instance = Jenkins.getInstance()'
    echo '     def user = instance.getUser("admin")'
    echo '     def password = hudson.security.HudsonPrivateSecurityRealm.Details.fromPlainPassword("newpassword")'
    echo '     user.addProperty(password)'
    echo '     user.save()'
    echo "  3. Login with username: admin, password: newpassword"
else
    echo "⚠️  No admin user found yet"
    echo "You may need to complete the initial setup wizard"
fi
echo ""

# Alternative: Check for other users
echo "=== Jenkins Users ==="
if [ -d /var/lib/jenkins/users ]; then
    echo "Found users:"
    sudo ls -la /var/lib/jenkins/users/ | grep "^d" | awk '{print $9}' | grep -v "^\.$" | grep -v "^\.\.$"
else
    echo "No users directory found"
fi
echo ""

echo "=========================================="
echo "Quick Password Reset (Easiest Method)"
echo "=========================================="
echo ""
echo "Run these commands to reset password:"
echo ""
echo "sudo systemctl stop jenkins"
echo "sudo sed -i 's/<useSecurity>true<\/useSecurity>/<useSecurity>false<\/useSecurity>/g' /var/lib/jenkins/config.xml"
echo "sudo systemctl start jenkins"
echo ""
echo "Then access Jenkins without password and set a new one."
echo ""
