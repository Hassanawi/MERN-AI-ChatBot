# Quick Setup Guide for Assignment 3

## 🚀 Quick Start (5 Minutes)

### Step 1: Prepare Application
```bash
# Ensure application is running
docker-compose -f docker-compose-ci.yml up -d

# Wait for services to start (30 seconds)
sleep 30

# Verify services are running
docker-compose -f docker-compose-ci.yml ps
```

### Step 2: Run Tests Locally
```bash
# Navigate to test directory
cd tests

# Install dependencies
pip install -r requirements.txt

# Create .env file (already created)
# Edit if needed: nano .env

# Run tests
pytest test_chatbot.py -v --html=reports/test_report.html --self-contained-html

# View report
# Open: tests/reports/test_report.html
```

### Step 3: Run Tests in Docker (Recommended for CI)
```bash
cd tests

# Build test image
docker build -t mern-chatbot-tests .

# Run tests
docker run --rm \
  --network="host" \
  -e BASE_URL=http://localhost:5174 \
  -e BACKEND_URL=http://localhost:5001 \
  -e HEADLESS=true \
  -v $(pwd)/reports:/app/reports \
  mern-chatbot-tests

# On Windows PowerShell:
docker run --rm --network="host" -e BASE_URL=http://localhost:5174 -e BACKEND_URL=http://localhost:5001 -e HEADLESS=true -v ${PWD}/reports:/app/reports mern-chatbot-tests
```

## 📧 Jenkins Email Configuration

### Gmail Setup for Jenkins

1. **Enable 2-Step Verification** on Gmail
2. **Generate App Password:**
   - Go to: https://myaccount.google.com/apppasswords
   - Select App: Mail
   - Select Device: Other (Jenkins)
   - Copy the 16-character password

3. **Configure Jenkins:**
   - Manage Jenkins → Configure System
   - Extended E-mail Notification:
     - SMTP server: `smtp.gmail.com`
     - SMTP Port: `465`
     - Use SSL: ✅
     - Credentials: Username (email) + App Password
   - Email Notification: Same settings
   - Save and test

### Alternative SMTP Services

**SendGrid:**
- SMTP: smtp.sendgrid.net
- Port: 587 (TLS)

**Outlook:**
- SMTP: smtp-mail.outlook.com
- Port: 587 (TLS)

**AWS SES:**
- SMTP: email-smtp.us-east-1.amazonaws.com
- Port: 587 (TLS)

## 🔧 Jenkins Pipeline Setup

### Create Pipeline Job

```bash
# 1. New Item → Pipeline
# 2. Configure:
#    - Build Triggers: GitHub hook trigger
#    - Pipeline: Pipeline script from SCM
#    - SCM: Git
#    - Repository URL: https://github.com/Hassanawi/MERN-AI-ChatBot.git
#    - Branch: */main or */final
#    - Script Path: Jenkinsfile
# 3. Save
```

### Add GitHub Webhook

```bash
# 1. GitHub Repo → Settings → Webhooks → Add webhook
# 2. Payload URL: http://YOUR_JENKINS_IP:8080/github-webhook/
# 3. Content type: application/json
# 4. Events: Just the push event
# 5. Active: ✅
# 6. Add webhook
```

## 🧪 Test Execution Commands

### Run All Tests
```bash
pytest test_chatbot.py -v
```

### Run Specific Test Class
```bash
pytest test_chatbot.py::TestHomePage -v
pytest test_chatbot.py::TestLoginPage -v
pytest test_chatbot.py::TestSignupPage -v
pytest test_chatbot.py::TestChatPage -v
```

### Run Specific Test
```bash
pytest test_chatbot.py::TestHomePage::test_01_home_page_loads_successfully -v
```

### Generate HTML Report
```bash
pytest test_chatbot.py -v --html=reports/test_report.html --self-contained-html
```

### Run in Headless Mode
```bash
export HEADLESS=true  # Linux/Mac
set HEADLESS=true     # Windows CMD
$env:HEADLESS="true"  # Windows PowerShell

pytest test_chatbot.py -v
```

## 📊 Viewing Test Reports

### HTML Report (Local)
```bash
# After test execution
cd tests/reports
# Open test_report.html in browser
```

### Jenkins HTML Report
```bash
# After Jenkins build
# Jenkins Job → Build History → Select Build → Selenium Test Report
# Or click the "Selenium Test Report" link on the build page
```

## 🐛 Troubleshooting

### Issue: ChromeDriver not found
```bash
# Solution: Reinstall webdriver-manager
pip uninstall webdriver-manager
pip install webdriver-manager
```

### Issue: Connection refused to application
```bash
# Solution: Check if application is running
docker-compose -f docker-compose-ci.yml ps

# Restart if needed
docker-compose -f docker-compose-ci.yml down
docker-compose -f docker-compose-ci.yml up -d
```

### Issue: Tests timeout
```bash
# Solution: Increase timeout in .env
IMPLICIT_WAIT=20
PAGE_LOAD_TIMEOUT=60
```

### Issue: Email not sending from Jenkins
```bash
# Check Jenkins logs
tail -f /var/log/jenkins/jenkins.log

# Test email configuration
# Jenkins → Manage Jenkins → Configure System → Test Configuration
```

## 📝 Before Submission Checklist

- [ ] All 15 tests pass locally
- [ ] Tests pass in Docker
- [ ] Jenkins pipeline configured
- [ ] GitHub webhook working
- [ ] Email notifications working
- [ ] Test reports generated
- [ ] Screenshots taken:
  - [ ] Jenkins pipeline success
  - [ ] Test report HTML
  - [ ] Docker containers running
  - [ ] Email notification received
  - [ ] Application screenshots
- [ ] Documentation complete
- [ ] Instructor added as collaborator
- [ ] Google form submitted

## 📧 Contact

For issues or questions:
- GitHub: @Hassanawi
- Repository: https://github.com/Hassanawi/MERN-AI-ChatBot

---

**Good luck with your assignment! 🚀**
