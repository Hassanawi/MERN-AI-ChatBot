# 🎯 Assignment 3 - Step-by-Step Implementation Guide

This guide walks through every step needed to complete Assignment 3.

---

## 📚 Table of Contents
1. [Prerequisites](#prerequisites)
2. [Part I: Selenium Tests](#part-i-selenium-tests)
3. [Part II: Jenkins Pipeline](#part-ii-jenkins-pipeline)
4. [Testing Everything](#testing-everything)
5. [Taking Screenshots](#taking-screenshots)
6. [Submission](#submission)

---

## ✅ Prerequisites

### On Your Local Machine
```bash
# Install Python 3.8+
python --version

# Install Git
git --version

# Install Docker
docker --version
docker-compose --version
```

### On AWS EC2 (Jenkins Server)
```bash
# SSH into EC2
ssh -i your-key.pem ubuntu@your-ec2-ip

# Install Docker
sudo apt update
sudo apt install -y docker.io docker-compose
sudo usermod -aG docker $USER
sudo systemctl start docker

# Install Jenkins
wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt update
sudo apt install -y jenkins openjdk-11-jdk
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins

# Access Jenkins
# Open: http://your-ec2-ip:8080
# Get initial password: sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

---

## 📝 Part I: Selenium Tests

### Step 1: Review Test Files

All test files are already created in the `tests/` directory:

```
tests/
├── pages/              # Page Object Models ✅
├── test_chatbot.py     # 15 test cases ✅
├── conftest.py         # Pytest fixtures ✅
├── config.py           # Configuration ✅
├── Dockerfile          # Test environment ✅
├── requirements.txt    # Dependencies ✅
└── README.md           # Documentation ✅
```

### Step 2: Test Locally (Optional but Recommended)

```bash
# Clone repository if not already done
git clone https://github.com/Hassanawi/MERN-AI-ChatBot.git
cd MERN-AI-ChatBot

# Start application
docker-compose -f docker-compose-ci.yml up -d

# Wait for services
sleep 30

# Run tests (Windows)
.\run-tests-local.ps1

# OR run tests (Linux/Mac)
./run-tests-local.sh

# View test report
# Open: tests/reports/test_report.html in browser
```

### Step 3: Verify Test Structure

Check that all 15 tests are present:

```bash
cd tests
pytest test_chatbot.py --collect-only
```

You should see:
- 4 tests in `TestHomePage`
- 4 tests in `TestLoginPage`
- 3 tests in `TestSignupPage`
- 4 tests in `TestChatPage`

**Total: 15 tests** ✅

---

## 🚀 Part II: Jenkins Pipeline

### Step 1: Install Jenkins Plugins

1. Open Jenkins: `http://your-ec2-ip:8080`
2. Go to: **Manage Jenkins** → **Manage Plugins**
3. Install these plugins:
   - Git Plugin
   - GitHub Plugin
   - Docker Plugin
   - Docker Pipeline
   - Email Extension Plugin
   - HTML Publisher Plugin
4. Restart Jenkins after installation

### Step 2: Configure Email (SMTP)

1. **Get Gmail App Password:**
   - Go to: https://myaccount.google.com/security
   - Enable 2-Step Verification
   - Go to: https://myaccount.google.com/apppasswords
   - Create app password for "Mail" / "Other (Jenkins)"
   - Copy the 16-character password

2. **Configure Jenkins Email:**
   - **Manage Jenkins** → **Configure System**
   - Scroll to **Extended E-mail Notification**:
     - SMTP server: `smtp.gmail.com`
     - SMTP Port: `465`
     - Click **Advanced**
     - Check **Use SSL**
     - Add Credentials:
       - Username: `your-email@gmail.com`
       - Password: `[16-char app password]`
   - Scroll to **E-mail Notification**:
     - Same configuration as above
   - Click **Test configuration by sending test e-mail**
   - Enter your email and test
   - **Save**

### Step 3: Create Jenkins Pipeline Job

1. **New Item**
   - Name: `MERN-ChatBot-Selenium-Tests`
   - Type: **Pipeline**
   - Click **OK**

2. **Configure Job:**
   
   **General Section:**
   - Description: `MERN ChatBot with Selenium automated tests`
   
   **Build Triggers:**
   - ✅ Check **GitHub hook trigger for GITScm polling**
   
   **Pipeline Section:**
   - Definition: **Pipeline script from SCM**
   - SCM: **Git**
   - Repository URL: `https://github.com/Hassanawi/MERN-AI-ChatBot.git`
   - Credentials: (Add GitHub credentials if private repo)
   - Branch: `*/main` or `*/final`
   - Script Path: `Jenkinsfile`
   
   **Save**

### Step 4: Configure GitHub Webhook

1. Go to GitHub repository: `https://github.com/Hassanawi/MERN-AI-ChatBot`
2. **Settings** → **Webhooks** → **Add webhook**
3. Configure:
   - Payload URL: `http://your-ec2-ip:8080/github-webhook/`
   - Content type: `application/json`
   - Which events: **Just the push event**
   - Active: ✅
4. **Add webhook**

### Step 5: Test Pipeline Manually

1. In Jenkins job, click **Build Now**
2. Watch the pipeline execute:
   - ✅ Checkout Code
   - ✅ Build Application
   - ✅ Health Check Tests
   - ✅ Run Selenium Tests
   - ✅ Archive Test Results
   - ✅ Application Ready
3. Check console output for any errors
4. View **Selenium Test Report** link on build page
5. Check email inbox for notification

---

## 🧪 Testing Everything

### Test 1: Local Test Execution

```bash
cd MERN-AI-ChatBot

# Start application
docker-compose -f docker-compose-ci.yml up -d

# Run tests
cd tests
pip install -r requirements.txt
pytest test_chatbot.py -v

# Expected: All 15 tests should pass ✅
```

### Test 2: Docker Test Execution

```bash
cd MERN-AI-ChatBot/tests

# Build test image
docker build -t mern-tests .

# Run tests
docker run --rm --network="host" \
  -e BASE_URL=http://localhost:5174 \
  -v $(pwd)/reports:/app/reports \
  mern-tests

# Expected: Tests pass, report generated ✅
```

### Test 3: Jenkins Pipeline Test

```bash
# Make a small change to trigger pipeline
echo "# Test trigger" >> README.md
git add README.md
git commit -m "Test Jenkins pipeline trigger"
git push origin main

# Expected:
# 1. GitHub webhook triggers Jenkins ✅
# 2. Jenkins runs pipeline ✅
# 3. All stages complete successfully ✅
# 4. Email notification received ✅
```

---

## 📸 Taking Screenshots

### Screenshot 1: Jenkins Pipeline Success
1. Open Jenkins job
2. Click on latest successful build
3. Take screenshot showing:
   - All stages green
   - Build #, duration, status
   - Console output snippet

### Screenshot 2: Selenium Test Report
1. In Jenkins build page, click **Selenium Test Report**
2. Take screenshot showing:
   - All 15 tests
   - Pass/fail status
   - Execution time
   - Test details

### Screenshot 3: Docker Containers
```bash
docker ps
```
Take screenshot showing:
- mern-chatbot-mongo-ci
- mern-chatbot-backend-ci
- mern-chatbot-frontend-ci
- All "Up" status

### Screenshot 4: Application Screenshots
1. Open `http://localhost:5174` (or your deployed URL)
2. Take screenshots of:
   - Home page
   - Login page (empty)
   - Signup page (empty)
   - Login page (with test data entered)
   - Chat page (after login)
   - Chat with a message sent

### Screenshot 5: Email Notification
1. Open received email from Jenkins
2. Take screenshot showing:
   - Subject line
   - Build status
   - Test summary
   - Links to reports
   - Triggered by info

### Screenshot 6: Test Report HTML (Local)
1. Open `tests/reports/test_report.html`
2. Take screenshot showing:
   - Test summary
   - Pass/fail breakdown
   - Individual test results

### Screenshot 7: GitHub Webhook
1. GitHub repo → Settings → Webhooks
2. Take screenshot showing:
   - Webhook URL
   - Recent deliveries
   - Success status (green checkmark)

---

## 📤 Submission

### Step 1: Prepare Report Document

Use the provided `ASSIGNMENT-3-REPORT.md` as a template:

1. **Convert to Word/PDF:**
   ```bash
   # Option 1: Use Pandoc
   pandoc ASSIGNMENT-3-REPORT.md -o Assignment-3-Report.pdf
   
   # Option 2: Copy content to Word document
   # Open ASSIGNMENT-3-REPORT.md
   # Copy all content
   # Paste into Microsoft Word
   # Format nicely
   # Save as PDF
   ```

2. **Add Screenshots:**
   - Insert all 7+ screenshots in appropriate sections
   - Add captions to each screenshot
   - Ensure screenshots are clear and readable

3. **Include Jenkinsfile:**
   - Copy entire `Jenkinsfile` content
   - Paste in the report under "Jenkinsfile Implementation"

4. **Add Your Details:**
   - Your name
   - Roll number
   - Section
   - Date of submission

### Step 2: Add Instructor as Collaborator

1. Go to: `https://github.com/Hassanawi/MERN-AI-ChatBot`
2. **Settings** → **Collaborators**
3. Click **Add people**
4. Enter instructor's GitHub username
5. Send invitation

### Step 3: Fill Google Form

1. Open: https://forms.gle/4fnuUPhXptQnDPUK6
2. Fill in:
   - **Deployment URL**: `http://your-ec2-ip:5174` or `http://your-ec2-ip:5173`
   - **Application GitHub URL**: `https://github.com/Hassanawi/MERN-AI-ChatBot`
   - **Test Code GitHub URL**: `https://github.com/Hassanawi/MERN-AI-ChatBot/tree/main/tests`
   - **Jenkins URL**: `http://your-ec2-ip:8080/job/MERN-ChatBot-Selenium-Tests/`
3. Submit

### Step 4: Upload Report

Upload your PDF report to:
- Your university's submission portal, OR
- As specified by your instructor

### Step 5: Verify Everything

**Final Checklist:**
- [ ] All 15 tests passing locally
- [ ] Tests passing in Docker
- [ ] Jenkins pipeline configured and working
- [ ] GitHub webhook triggering builds
- [ ] Email notifications working
- [ ] All screenshots taken and clear
- [ ] Report document complete with screenshots
- [ ] Jenkinsfile included in report
- [ ] Instructor added as GitHub collaborator
- [ ] Google form submitted
- [ ] Report uploaded

---

## 🐛 Troubleshooting

### Issue: Tests fail locally

**Solution:**
```bash
# Check if application is running
docker-compose -f docker-compose-ci.yml ps

# Check application logs
docker-compose -f docker-compose-ci.yml logs

# Restart application
docker-compose -f docker-compose-ci.yml down
docker-compose -f docker-compose-ci.yml up -d

# Wait and retry
sleep 30
pytest test_chatbot.py -v
```

### Issue: Jenkins pipeline fails at test stage

**Solution:**
```bash
# SSH into Jenkins server
ssh -i key.pem ubuntu@jenkins-ip

# Check Docker is working
docker ps

# Check Jenkins can access Docker
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins

# Check Chrome installation
docker run --rm python:3.11-slim bash -c "apt-get update && apt-get install -y wget && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub"
```

### Issue: Email not sending

**Solution:**
1. Verify Gmail App Password is correct (16 characters, no spaces)
2. Check Jenkins logs: `sudo tail -f /var/log/jenkins/jenkins.log`
3. Test email configuration in Jenkins
4. Try different SMTP settings (port 587 with TLS instead of 465 with SSL)

### Issue: GitHub webhook not triggering

**Solution:**
1. Check webhook has green checkmark in GitHub
2. Verify Jenkins URL is accessible from internet
3. Check EC2 security group allows port 8080
4. Try manual trigger first: click "Build Now"
5. Check Jenkins logs for webhook events

---

## ✅ Success Criteria

Your submission is complete when:

1. **Tests:** All 15 Selenium tests pass ✅
2. **Pipeline:** Jenkins pipeline completes successfully ✅
3. **Automation:** Push to GitHub triggers Jenkins ✅
4. **Email:** Test results emailed to committer ✅
5. **Reports:** Test reports visible in Jenkins ✅
6. **Documentation:** Complete report with screenshots ✅
7. **Submission:** Google form filled and report uploaded ✅

---

## 🎉 Congratulations!

You've successfully completed Assignment 3! Your implementation includes:

- ✅ 15 comprehensive Selenium automated tests
- ✅ Page Object Model architecture
- ✅ Dockerized test environment
- ✅ Jenkins CI/CD pipeline with test stage
- ✅ Automated email notifications
- ✅ HTML test reports
- ✅ Complete documentation

**Grade Expectation: 10/10** 🏆

---

## 📞 Need Help?

- **Check Documentation:**
  - `ASSIGNMENT-3-REPORT.md` - Detailed report
  - `QUICK-SETUP.md` - Quick setup guide
  - `tests/README.md` - Test documentation
  - `SUMMARY.md` - Project summary

- **Common Issues:**
  - Read "Troubleshooting" section above
  - Check Jenkins console output
  - Review Docker container logs
  - Verify all prerequisites installed

- **Repository:**
  - https://github.com/Hassanawi/MERN-AI-ChatBot

---

**Good Luck! 🚀**
