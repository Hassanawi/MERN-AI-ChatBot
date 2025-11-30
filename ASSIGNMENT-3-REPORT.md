# Assignment 3 - DevOps Pipeline Automation with Selenium Tests

**Course:** CSC483 – Topics in Computer Science II (DevOps)  
**Student:** Hassan Awi  
**Instructor:** Qasim Malik

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Part I: Selenium Test Cases](#part-i-selenium-test-cases)
3. [Part II: Jenkins Pipeline with Test Stage](#part-ii-jenkins-pipeline-with-test-stage)
4. [Setup Instructions](#setup-instructions)
5. [Test Execution](#test-execution)
6. [Jenkins Configuration](#jenkins-configuration)
7. [Screenshots & Results](#screenshots--results)

---

## 🎯 Overview

This assignment implements automated testing and CI/CD pipeline for a MERN Stack AI ChatBot application:

- **Application:** Full-stack MERN (MongoDB, Express, React, Node.js) AI ChatBot
- **Database:** MongoDB for user data and chat history
- **Testing Framework:** Selenium WebDriver with Python and Pytest
- **CI/CD:** Jenkins pipeline running on AWS EC2
- **Containerization:** Docker for application and tests

---

## 📝 Part I: Selenium Test Cases

### Application Description

The MERN AI ChatBot is a full-stack web application with:
- **Frontend:** React + Vite (TypeScript)
- **Backend:** Node.js + Express (TypeScript)
- **Database:** MongoDB (stores users and chat history)
- **AI Integration:** OpenRouter API for chat responses

**Key Features:**
- User authentication (signup/login)
- Real-time AI chat functionality
- Chat history persistence
- Responsive UI with Material-UI

### Test Suite Overview

Created **15 comprehensive Selenium test cases** covering:

#### 1. Home Page Tests (4 tests)
- ✅ `test_01_home_page_loads_successfully` - Verifies home page loads
- ✅ `test_02_navigation_links_visible` - Checks navigation elements
- ✅ `test_03_navigate_to_login_page` - Tests login navigation
- ✅ `test_04_navigate_to_signup_page` - Tests signup navigation

#### 2. Login Page Tests (4 tests)
- ✅ `test_05_login_page_elements_present` - Validates form elements
- ✅ `test_06_login_with_empty_credentials` - Tests validation
- ✅ `test_07_login_with_invalid_email` - Tests email validation
- ✅ `test_08_login_with_short_password` - Tests password validation

#### 3. Signup Page Tests (3 tests)
- ✅ `test_09_signup_page_elements_present` - Validates form elements
- ✅ `test_10_signup_with_empty_fields` - Tests empty field validation
- ✅ `test_11_signup_with_invalid_data` - Tests data validation

#### 4. General & Security Tests (4 tests)
- ✅ `test_12_chat_page_redirect_when_not_logged_in` - Authentication test
- ✅ `test_13_404_page_for_invalid_route` - 404 handling test
- ✅ `test_14_browser_back_navigation` - Navigation test
- ✅ `test_15_page_responsiveness` - Performance test

### Technology Stack

**Testing Framework:**
- Python 3.11
- Selenium WebDriver 4.15.2
- Pytest 7.4.3
- Pytest-HTML for reporting
- WebDriver Manager (automatic ChromeDriver management)

**Browser:**
- Google Chrome (Headless mode for CI/CD)
- ChromeDriver (automatically managed)

### Test Architecture

**Page Object Model (POM):**
```
tests/
├── pages/
│   ├── base_page.py      # Base page with common methods
│   ├── home_page.py      # Home page objects
│   ├── login_page.py     # Login page objects
│   ├── signup_page.py    # Signup page objects
│   └── chat_page.py      # Chat page objects
├── test_chatbot.py       # Main test suite (15 tests)
├── conftest.py           # Pytest fixtures
└── config.py             # Configuration
```

### Running Tests Locally

```bash
# Navigate to tests directory
cd tests

# Install dependencies
pip install -r requirements.txt

# Copy environment configuration
cp .env.example .env

# Run all tests
pytest test_chatbot.py -v

# Generate HTML report
pytest test_chatbot.py -v --html=reports/test_report.html --self-contained-html
```

---

## 🚀 Part II: Jenkins Pipeline with Test Stage

### Jenkins Pipeline Overview

The enhanced Jenkins pipeline includes:

1. **Checkout Code** - Fetch code from GitHub
2. **Build Application** - Start services with Docker Compose
3. **Health Check Tests** - Verify all services are running
4. **Run Selenium Tests** - Execute automated tests in Docker
5. **Archive Test Results** - Save and publish test reports
6. **Application Ready** - Display deployment info
7. **Email Notifications** - Send results to collaborator

### Test Stage Implementation

The test stage:
1. Builds a Docker image with Chrome and ChromeDriver
2. Runs Selenium tests in headless mode
3. Generates HTML test reports
4. Archives test results and screenshots
5. Publishes reports in Jenkins UI

### Docker Image for Tests

**Dockerfile for Test Environment:**
```dockerfile
FROM python:3.11-slim

# Install Chrome and ChromeDriver
RUN apt-get update && apt-get install -y \
    wget gnupg unzip curl google-chrome-stable

# Install ChromeDriver
RUN CHROMEDRIVER_VERSION=$(curl -sS chromedriver.storage.googleapis.com/LATEST_RELEASE) \
    && wget "https://chromedriver.storage.googleapis.com/${CHROMEDRIVER_VERSION}/chromedriver_linux64.zip" \
    && unzip chromedriver_linux64.zip \
    && mv chromedriver /usr/local/bin/

# Copy and install Python dependencies
COPY requirements.txt .
RUN pip install -r requirements.txt

# Copy test files
COPY . .

# Run tests
CMD ["pytest", "test_chatbot.py", "-v", "--html=reports/test_report.html"]
```

### Email Notification Configuration

The pipeline sends email notifications with:
- Build status (SUCCESS/FAILURE/UNSTABLE)
- Test results summary
- Link to detailed test report
- Build logs
- Triggered by Git committer email

**Email Features:**
- HTML formatted email body
- Attached build logs
- Attached test report
- Direct links to Jenkins build and test reports
- Sent to the collaborator who pushed code

---

## 🛠️ Setup Instructions

### Prerequisites

1. **AWS EC2 Instance**
   - Ubuntu 22.04 LTS
   - t2.medium or higher
   - Ports: 22, 80, 8080, 5000, 5173

2. **Installed Software**
   - Jenkins
   - Docker & Docker Compose
   - Git
   - Java 11+

### Step 1: Jenkins Setup

```bash
# Install Jenkins
wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt update
sudo apt install jenkins

# Install Docker
sudo apt install docker.io docker-compose
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```

### Step 2: Jenkins Plugins

Install these plugins in Jenkins:
- Git Plugin
- GitHub Plugin
- Docker Plugin
- Docker Pipeline
- Email Extension Plugin
- HTML Publisher Plugin

### Step 3: Configure Email Notifications

**In Jenkins → Manage Jenkins → Configure System:**

1. **Extended E-mail Notification:**
   - SMTP Server: `smtp.gmail.com`
   - SMTP Port: `465`
   - Use SSL: ✅
   - Credentials: Add Gmail App Password
   - Default Recipients: (leave empty for dynamic)

2. **E-mail Notification:**
   - Same SMTP configuration
   - Test email configuration

### Step 4: Create Jenkins Pipeline Job

1. New Item → Pipeline
2. Configure:
   - Name: `MERN-ChatBot-Tests`
   - Pipeline script from SCM
   - SCM: Git
   - Repository URL: `https://github.com/Hassanawi/MERN-AI-ChatBot.git`
   - Branch: `*/main` or `*/final`
   - Script Path: `Jenkinsfile`

3. Build Triggers:
   - ✅ GitHub hook trigger for GITScm polling

### Step 5: Configure GitHub Webhook

1. Go to GitHub repository → Settings → Webhooks
2. Add webhook:
   - Payload URL: `http://your-jenkins-url:8080/github-webhook/`
   - Content type: `application/json`
   - Events: `Just the push event`
   - Active: ✅

### Step 6: Environment Variables

Set in Jenkins job or system:
```bash
DOCKER_HUB_USERNAME=your-dockerhub-username
OPEN_AI_SECRET=your-openrouter-api-key
JWT_SECRET=your-jwt-secret
COOKIE_SECRET=your-cookie-secret
```

---

## 🧪 Test Execution

### Local Test Execution

**Option 1: Python Direct**
```bash
cd tests
pip install -r requirements.txt
pytest test_chatbot.py -v --html=reports/test_report.html
```

**Option 2: Docker**
```bash
cd tests
docker build -t mern-chatbot-tests .
docker run --rm \
  --network="host" \
  -e BASE_URL=http://localhost:5173 \
  -v $(pwd)/reports:/app/reports \
  mern-chatbot-tests
```

**Option 3: PowerShell Script (Windows)**
```powershell
cd tests
.\run_tests.ps1
```

### CI/CD Test Execution

Tests run automatically when:
1. Code is pushed to GitHub
2. GitHub webhook triggers Jenkins
3. Jenkins pulls latest code
4. Jenkins builds and starts application containers
5. Jenkins runs Selenium tests in Docker
6. Jenkins generates and publishes test reports
7. Jenkins sends email with results

---

## ⚙️ Jenkins Configuration

### Jenkinsfile Key Stages

```groovy
stage('Run Selenium Tests') {
    steps {
        script {
            sh """
                cd tests
                docker build -t mern-chatbot-selenium-tests .
                docker run --rm \
                    --network="host" \
                    -e BASE_URL=http://localhost:5174 \
                    -e HEADLESS=true \
                    -v \$(pwd)/reports:/app/reports \
                    mern-chatbot-selenium-tests
            """
        }
    }
}
```

### Email Notification Template

```groovy
emailext(
    subject: "Jenkins Build ${buildStatus}: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
    body: """
        <html>
        <body>
            <h2>Jenkins Build Notification</h2>
            <p><strong>Build Status:</strong> ${buildStatus}</p>
            <p><strong>Triggered by:</strong> ${GIT_COMMITTER_NAME}</p>
            <p><strong>Test Report:</strong> <a href="${buildUrl}">View Report</a></p>
        </body>
        </html>
    """,
    mimeType: 'text/html',
    to: "${GIT_COMMITTER_EMAIL}",
    attachLog: true
)
```

---

## 📊 Screenshots & Results

### Expected Screenshots for Report

1. **Jenkins Pipeline Success**
   - Full pipeline execution
   - All stages green
   - Test stage completion

2. **Selenium Test Results**
   - HTML test report
   - All 15 tests passed
   - Test execution time

3. **Docker Containers Running**
   - `docker ps` showing all containers
   - Application containers (mongo, backend, frontend)
   - Test container

4. **Application Screenshots**
   - Home page
   - Login page
   - Signup page
   - Chat interface

5. **Email Notification**
   - Email received by collaborator
   - Test results summary
   - Build status

6. **Jenkins Test Report**
   - Published HTML report in Jenkins
   - Test summary
   - Pass/fail statistics

7. **GitHub Integration**
   - Webhook configuration
   - Push event triggering build

---

## 📦 Deliverables

### Repository Structure
```
MERN-AI-ChatBot/
├── backend/                 # Backend application
├── frontend/                # Frontend application
├── tests/                   # Selenium test suite
│   ├── pages/              # Page Object Models
│   ├── test_chatbot.py     # 15 test cases
│   ├── Dockerfile          # Test environment
│   ├── requirements.txt    # Python dependencies
│   └── README.md           # Test documentation
├── Jenkinsfile             # Enhanced pipeline with tests
├── docker-compose.yml      # Development compose
├── docker-compose-ci.yml   # CI/CD compose
└── ASSIGNMENT-3-REPORT.md  # This file
```

### Submission Checklist

- ✅ 15 Selenium test cases implemented
- ✅ Tests run in headless Chrome
- ✅ Docker image for test environment
- ✅ Jenkins pipeline with test stage
- ✅ GitHub webhook integration
- ✅ Email notifications configured
- ✅ Test reports generated and published
- ✅ Comprehensive documentation
- ✅ Screenshots of all stages

---

## 🔗 Important Links

- **GitHub Repository:** https://github.com/Hassanawi/MERN-AI-ChatBot
- **Google Form Submission:** https://forms.gle/4fnuUPhXptQnDPUK6
- **Response Sheet:** https://docs.google.com/spreadsheets/d/1ApEzenqAEc-dKEmFZSd4bUfSknAA3100JpLKWcl4Ks0

---

## 🎓 Learning Outcomes Achieved

### CLO4: Apply DevOps pipeline automation techniques

✅ **Automated Test Cases using Selenium**
- Implemented 15 comprehensive test cases
- Used Selenium WebDriver with Python
- Configured headless Chrome for CI/CD
- Implemented Page Object Model pattern
- Generated HTML test reports

✅ **Automation Pipeline with Test Stage**
- Created Jenkins pipeline with test stage
- Integrated GitHub webhook for auto-trigger
- Configured Docker for test environment
- Implemented email notifications
- Published test reports in Jenkins

✅ **Containerized Test Execution**
- Built Docker image with Chrome and ChromeDriver
- Executed tests in containerized environment
- Integrated with existing CI/CD pipeline
- Automated test result archiving

---

## 🤝 Collaboration

To trigger the pipeline:
1. Add instructor as collaborator on GitHub
2. Instructor makes code push
3. GitHub webhook triggers Jenkins
4. Pipeline executes all stages including tests
5. Email sent to instructor with results

---

## 📝 Notes

- All tests run in headless Chrome for CI/CD compatibility
- Test reports are automatically generated and archived
- Email notifications include detailed build and test information
- Pipeline can be manually triggered from Jenkins UI
- Test failures are captured with screenshots

---

**End of Report**
