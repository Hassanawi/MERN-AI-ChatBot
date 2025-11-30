#!/bin/bash
# EC2 Setup Script - Run this after connecting to EC2
# This automates the installation of all required software

echo "=========================================="
echo "EC2 Setup Script for Jenkins & Docker"
echo "=========================================="
echo ""

# Update system
echo "Step 1: Updating system packages..."
sudo apt update
sudo apt upgrade -y

# Install Docker
echo ""
echo "Step 2: Installing Docker..."
sudo apt install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ubuntu

# Install Docker Compose
echo ""
echo "Step 3: Installing Docker Compose..."
sudo apt install -y docker-compose

# Install Java
echo ""
echo "Step 4: Installing Java 17..."
sudo apt install -y openjdk-17-jdk

# Install Jenkins
echo ""
echo "Step 5: Installing Jenkins..."
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt update
sudo apt install -y jenkins
sudo systemctl start jenkins
sudo systemctl enable jenkins

# Add Jenkins to Docker group
echo ""
echo "Step 6: Configuring Jenkins permissions..."
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins

# Install Git
echo ""
echo "Step 7: Installing Git..."
sudo apt install -y git

# Install additional utilities
echo ""
echo "Step 8: Installing additional tools..."
sudo apt install -y curl wget net-tools htop

# Wait for Jenkins to start
echo ""
echo "Step 9: Waiting for Jenkins to start..."
sleep 30

# Get Jenkins initial password
echo ""
echo "=========================================="
echo "Installation Complete!"
echo "=========================================="
echo ""
echo "=== Installed Versions ==="
echo "Docker: $(docker --version)"
echo "Docker Compose: $(docker-compose --version)"
echo "Java: $(java -version 2>&1 | head -n 1)"
echo "Jenkins: $(sudo systemctl is-active jenkins)"
echo "Git: $(git --version)"
echo ""
echo "=== Jenkins Initial Admin Password ==="
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
echo ""
echo "=== Next Steps ==="
echo "1. Open browser: http://$(curl -s ifconfig.me):8080"
echo "2. Copy the password above"
echo "3. Follow the setup wizard"
echo ""
echo "=== Important ==="
echo "Logout and login again for Docker group changes to take effect:"
echo "  logout"
echo ""
echo "=========================================="
