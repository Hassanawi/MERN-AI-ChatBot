# 🚀 AWS EC2 Setup Guide for Jenkins CI/CD Pipeline

Complete guide to set up Jenkins on AWS EC2 for running Selenium tests and CI/CD pipeline.

---

## 📋 Part 1: Launch EC2 Instance

### Step 1: Login to AWS Console

1. Go to: https://aws.amazon.com/console/
2. Sign in with your AWS account
3. Navigate to **EC2 Dashboard**

### Step 2: Launch Instance

1. Click **Launch Instance** button

2. **Name and tags:**
   - Name: `MERN-ChatBot-Jenkins-Server`

3. **Application and OS Images (AMI):**
   - Select: **Ubuntu Server 22.04 LTS (HVM), SSD Volume Type**
   - Architecture: **64-bit (x86)**

4. **Instance type:**
   - Select: **t2.medium** (minimum recommended)
   - Or **t2.large** (better performance)
   - Why? Jenkins + Docker + Tests need at least 4GB RAM

5. **Key pair (login):**
   - Click **Create new key pair**
   - Key pair name: `jenkins-server-key`
   - Key pair type: **RSA**
   - Private key file format: **.pem** (for Mac/Linux) or **.ppk** (for Windows/PuTTY)
   - Click **Create key pair**
   - **Download and save the key file** - you'll need it to connect via SSH

6. **Network settings:**
   - Click **Edit**
   - Auto-assign public IP: **Enable**
   - Firewall (security groups): **Create security group**
   - Security group name: `jenkins-docker-security-group`
   - Description: `Security group for Jenkins and Docker`
   
   **Add these rules:**
   
   | Type | Protocol | Port Range | Source | Description |
   |------|----------|------------|--------|-------------|
   | SSH | TCP | 22 | My IP | SSH access |
   | Custom TCP | TCP | 8080 | 0.0.0.0/0 | Jenkins Web UI |
   | HTTP | TCP | 80 | 0.0.0.0/0 | HTTP |
   | HTTPS | TCP | 443 | 0.0.0.0/0 | HTTPS |
   | Custom TCP | TCP | 5000 | 0.0.0.0/0 | Backend API |
   | Custom TCP | TCP | 5001 | 0.0.0.0/0 | Backend CI |
   | Custom TCP | TCP | 5173 | 0.0.0.0/0 | Frontend Dev |
   | Custom TCP | TCP | 5174 | 0.0.0.0/0 | Frontend CI |

7. **Configure storage:**
   - Size: **30 GiB** (minimum)
   - Volume Type: **gp3** (general purpose SSD)

8. **Advanced details:**
   - Keep defaults

9. Click **Launch instance**

10. **Wait for instance to start** (Status: Running)

### Step 3: Note Important Information

Once instance is running, note:
- **Public IPv4 address**: (e.g., 3.85.123.45)
- **Public IPv4 DNS**: (e.g., ec2-3-85-123-45.compute-1.amazonaws.com)

---

## 🔐 Part 2: Connect to EC2 Instance

### For Windows (Using PowerShell):

```powershell
# Navigate to where you saved the key file
cd Downloads

# Set proper permissions (if needed)
icacls jenkins-server-key.pem /inheritance:r
icacls jenkins-server-key.pem /grant:r "$($env:USERNAME):(R)"

# Connect via SSH
ssh -i jenkins-server-key.pem ubuntu@YOUR_EC2_PUBLIC_IP
```

### For Mac/Linux:

```bash
# Navigate to where you saved the key file
cd ~/Downloads

# Set proper permissions
chmod 400 jenkins-server-key.pem

# Connect via SSH
ssh -i jenkins-server-key.pem ubuntu@YOUR_EC2_PUBLIC_IP
```

**Replace `YOUR_EC2_PUBLIC_IP` with your actual EC2 public IP address**

---

## 📦 Part 3: Install Required Software on EC2

Once connected to EC2, run these commands:

### 3.1 Update System

```bash
sudo apt update
sudo apt upgrade -y
```

### 3.2 Install Docker

```bash
# Install Docker
sudo apt install -y docker.io

# Start Docker service
sudo systemctl start docker
sudo systemctl enable docker

# Add ubuntu user to docker group
sudo usermod -aG docker ubuntu

# Verify Docker installation
docker --version
```

### 3.3 Install Docker Compose

```bash
# Install Docker Compose
sudo apt install -y docker-compose

# Verify installation
docker-compose --version
```

### 3.4 Install Java (Required for Jenkins)

```bash
# Install Java 17
sudo apt install -y openjdk-17-jdk

# Verify installation
java -version
```

### 3.5 Install Jenkins

```bash
# Add Jenkins repository key
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null

# Add Jenkins repository
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

# Update package list
sudo apt update

# Install Jenkins
sudo apt install -y jenkins

# Start Jenkins service
sudo systemctl start jenkins
sudo systemctl enable jenkins

# Check Jenkins status
sudo systemctl status jenkins
```

### 3.6 Add Jenkins User to Docker Group

```bash
# Add jenkins user to docker group
sudo usermod -aG docker jenkins

# Restart Jenkins
sudo systemctl restart jenkins
```

### 3.7 Install Git

```bash
sudo apt install -y git
git --version
```

### 3.8 Verify All Installations

```bash
echo "=== Installation Verification ==="
echo "Docker: $(docker --version)"
echo "Docker Compose: $(docker-compose --version)"
echo "Java: $(java -version 2>&1 | head -n 1)"
echo "Jenkins: $(sudo systemctl is-active jenkins)"
echo "Git: $(git --version)"
```

---

## 🔓 Part 4: Access Jenkins

### Step 1: Get Initial Admin Password

```bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

**Copy this password** - you'll need it in the next step.

### Step 2: Open Jenkins in Browser

1. Open your browser
2. Navigate to: `http://YOUR_EC2_PUBLIC_IP:8080`
3. Paste the initial admin password
4. Click **Continue**

### Step 3: Install Plugins

1. Select **Install suggested plugins**
2. Wait for plugins to install (5-10 minutes)

### Step 4: Create Admin User

1. Username: `admin` (or your choice)
2. Password: (create a strong password)
3. Full name: Your name
4. Email: Your email
5. Click **Save and Continue**

### Step 5: Jenkins URL

1. Keep the default URL: `http://YOUR_EC2_PUBLIC_IP:8080/`
2. Click **Save and Finish**
3. Click **Start using Jenkins**

---

## 🔌 Part 5: Install Required Jenkins Plugins

1. Go to: **Manage Jenkins** → **Plugins** → **Available plugins**

2. Search and install these plugins:
   - ✅ **Git Plugin**
   - ✅ **GitHub Plugin**
   - ✅ **Docker Plugin**
   - ✅ **Docker Pipeline**
   - ✅ **Email Extension Plugin**
   - ✅ **HTML Publisher Plugin**
   - ✅ **Pipeline**
   - ✅ **Credentials Plugin**
   - ✅ **Credentials Binding Plugin**

3. Check **Restart Jenkins when installation is complete**

4. Wait for Jenkins to restart (2-3 minutes)

5. Log back in with your admin credentials

---

## 📧 Part 6: Configure Email Notifications

### Step 1: Get Gmail App Password

1. Go to: https://myaccount.google.com/security
2. Enable **2-Step Verification** (if not already)
3. Go to: https://myaccount.google.com/apppasswords
4. Select:
   - App: **Mail**
   - Device: **Other** (type "Jenkins")
5. Click **Generate**
6. **Copy the 16-character password**

### Step 2: Configure Jenkins Email

1. **Manage Jenkins** → **System**

2. Scroll to **Extended E-mail Notification**:
   - SMTP server: `smtp.gmail.com`
   - SMTP Port: `465`
   - Click **Advanced**
   - ✅ Check **Use SSL**
   - Click **Add** → **Jenkins** (Credentials)
     - Kind: **Username with password**
     - Username: `your-email@gmail.com`
     - Password: `[Paste 16-char app password]`
     - ID: `gmail-credentials`
     - Description: `Gmail SMTP`
   - Click **Add**
   - Select the credentials you just created
   - Default Content Type: **HTML (text/html)**

3. Scroll to **E-mail Notification**:
   - SMTP server: `smtp.gmail.com`
   - Click **Advanced**
   - ✅ Check **Use SMTP Authentication**
   - User Name: `your-email@gmail.com`
   - Password: `[16-char app password]`
   - ✅ Check **Use SSL**
   - SMTP Port: `465`
   - Click **Test configuration by sending test e-mail**
   - Enter your email
   - Click **Test configuration**
   - ✅ Verify you receive the test email

4. Click **Save**

---

## 📂 Part 7: Deploy Your Application to EC2

### Step 1: Clone Repository

```bash
# Clone your repository
cd ~
git clone https://github.com/Hassanawi/MERN-AI-ChatBot.git
cd MERN-AI-ChatBot
```

### Step 2: Create Environment File

```bash
# Create .env file for backend
cat > backend/.env << 'EOF'
MONGODB_URL=mongodb://mongo-ci:27017/mernai_chatbot
JWT_SECRET=your-jwt-secret-key-change-this
COOKIE_SECRET=your-cookie-secret-key-change-this
OPEN_AI_SECRET=your-openrouter-api-key
OPENROUTER_BASE=https://openrouter.ai/api/v1
OPENROUTER_MODEL=google/gemini-2.0-flash-exp:free
PORT=5001
EOF

# Create .env file for root
cat > .env << 'EOF'
DOCKER_HUB_USERNAME=your-dockerhub-username
EOF
```

**Update the values:**
```bash
nano backend/.env  # Edit JWT_SECRET, COOKIE_SECRET, OPEN_AI_SECRET
nano .env          # Edit DOCKER_HUB_USERNAME
```

### Step 3: Start Application

```bash
# Build and start services
docker-compose -f docker-compose-ci.yml up -d

# Wait for services to start
sleep 30

# Check status
docker-compose -f docker-compose-ci.yml ps

# Check logs
docker-compose -f docker-compose-ci.yml logs
```

### Step 4: Verify Application

```bash
# Test backend
curl http://localhost:5001/api/v1

# Test frontend (should return HTML)
curl http://localhost:5174

# Or open in browser:
# http://YOUR_EC2_PUBLIC_IP:5174
```

---

## 🔧 Part 8: Create Jenkins Pipeline Job

### Step 1: Create New Job

1. Click **New Item**
2. Name: `MERN-ChatBot-Selenium-Tests`
3. Type: **Pipeline**
4. Click **OK**

### Step 2: Configure Job

**General:**
- Description: `MERN AI ChatBot with Selenium automated tests`

**Build Triggers:**
- ✅ Check **GitHub hook trigger for GITScm polling**

**Pipeline:**
- Definition: **Pipeline script from SCM**
- SCM: **Git**
- Repository URL: `https://github.com/Hassanawi/MERN-AI-ChatBot.git`
- Credentials: (Add if private repo)
- Branch Specifier: `*/final` or `*/main`
- Script Path: `Jenkinsfile`

Click **Save**

### Step 3: Test Manual Build

1. Click **Build Now**
2. Watch the build execute
3. Check Console Output
4. Verify all stages complete

---

## 🔗 Part 9: Configure GitHub Webhook

### Step 1: Get Jenkins URL

Your Jenkins webhook URL will be:
```
http://YOUR_EC2_PUBLIC_IP:8080/github-webhook/
```

### Step 2: Add Webhook in GitHub

1. Go to: https://github.com/Hassanawi/MERN-AI-ChatBot
2. Click **Settings** → **Webhooks** → **Add webhook**
3. Payload URL: `http://YOUR_EC2_PUBLIC_IP:8080/github-webhook/`
4. Content type: **application/json**
5. Which events: **Just the push event**
6. ✅ Active
7. Click **Add webhook**

### Step 3: Test Webhook

1. Make a small change to README.md
2. Commit and push
3. Check webhook deliveries (should show green checkmark)
4. Check Jenkins - build should trigger automatically

---

## ✅ Part 10: Verification Checklist

Run these commands to verify everything:

```bash
# Check Docker
docker ps

# Check Jenkins
sudo systemctl status jenkins

# Check application
curl http://localhost:5174
curl http://localhost:5001/api/v1

# Check disk space
df -h

# Check memory
free -h

# Test Docker as jenkins user
sudo -u jenkins docker ps
```

---

## 🎯 Part 11: Important URLs

Save these URLs:

- **Jenkins**: `http://YOUR_EC2_PUBLIC_IP:8080`
- **Frontend (Dev)**: `http://YOUR_EC2_PUBLIC_IP:5173`
- **Frontend (CI)**: `http://YOUR_EC2_PUBLIC_IP:5174`
- **Backend (Dev)**: `http://YOUR_EC2_PUBLIC_IP:5000`
- **Backend (CI)**: `http://YOUR_EC2_PUBLIC_IP:5001`

---

## 🐛 Troubleshooting

### Jenkins Won't Start

```bash
sudo systemctl status jenkins
sudo journalctl -u jenkins -n 50
```

### Docker Permission Denied

```bash
sudo usermod -aG docker jenkins
sudo usermod -aG docker ubuntu
sudo systemctl restart jenkins
logout  # Then login again
```

### Port Already in Use

```bash
# Check what's using port 8080
sudo netstat -tulpn | grep 8080

# Kill process if needed
sudo kill -9 <PID>
```

### Can't Access Jenkins from Browser

1. Check security group allows port 8080
2. Check Jenkins is running: `sudo systemctl status jenkins`
3. Check firewall: `sudo ufw status`

### Tests Fail in Jenkins

```bash
# Check ChromeDriver installation in Docker
docker run --rm python:3.11-slim bash -c "apt-get update && apt-get install -y wget"

# Check test container logs
docker logs <container-id>
```

---

## 📝 Quick Reference Commands

```bash
# Restart Jenkins
sudo systemctl restart jenkins

# View Jenkins logs
sudo journalctl -u jenkins -f

# Restart Docker
sudo systemctl restart docker

# Stop application
docker-compose -f docker-compose-ci.yml down

# Start application
docker-compose -f docker-compose-ci.yml up -d

# View application logs
docker-compose -f docker-compose-ci.yml logs -f

# Clean up Docker
docker system prune -a

# Check disk space
df -h

# Monitor resources
htop  # or: top
```

---

## 🎉 Success Criteria

Your EC2 setup is complete when:

1. ✅ EC2 instance is running
2. ✅ Can SSH into instance
3. ✅ Docker is installed and working
4. ✅ Jenkins is accessible at port 8080
5. ✅ All Jenkins plugins installed
6. ✅ Email notifications configured
7. ✅ Application running (ports 5174, 5001)
8. ✅ Jenkins pipeline job created
9. ✅ GitHub webhook configured
10. ✅ Manual build succeeds
11. ✅ Webhook triggers build
12. ✅ Tests execute and pass
13. ✅ Email notification received

---

## 💰 Cost Optimization

**To avoid unnecessary AWS charges:**

1. **Stop instance when not in use:**
   ```
   EC2 Dashboard → Instances → Select instance → Instance State → Stop
   ```

2. **Terminate instance when done with assignment:**
   ```
   EC2 Dashboard → Instances → Select instance → Instance State → Terminate
   ```

3. **Note:** Stopped instances still incur EBS storage charges. Terminate to stop all charges.

4. **Free tier:** t2.micro is free for 750 hours/month (first 12 months)

---

## 📞 Next Steps

1. **Follow this guide step by step**
2. **Take screenshots at each major step** (for your report)
3. **Test the complete pipeline** (push code → webhook → Jenkins → tests → email)
4. **Document any issues** you encounter
5. **Prepare your assignment report** with screenshots

---

**Good luck with your EC2 setup! 🚀**

If you encounter any issues, refer to the Troubleshooting section or check Jenkins/Docker logs for detailed error messages.
