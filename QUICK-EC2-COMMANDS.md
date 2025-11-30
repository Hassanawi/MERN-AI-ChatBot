# ⚡ Quick EC2 Commands Reference

Your EC2 IP: **13.53.174.119**  
Webhook URL: **http://13.53.174.119:8080/github-webhook/**

---

## 🔍 Diagnostic Commands

```bash
# Check all container status
docker ps

# Check container health
docker inspect mern-chatbot-backend-ci | grep -A 20 Health
docker inspect mern-chatbot-frontend-ci | grep -A 20 Health

# View container logs
docker logs mern-chatbot-backend-ci --tail 50
docker logs mern-chatbot-frontend-ci --tail 50
docker logs mern-chatbot-backend --tail 50
docker logs mern-chatbot-frontend --tail 50

# Test services
curl http://localhost:5001/api/v1   # Backend CI
curl http://localhost:5174          # Frontend CI
curl http://localhost:5000/api/v1   # Backend Dev
curl http://localhost:5173          # Frontend Dev

# Check Jenkins status
sudo systemctl status jenkins

# Check Jenkins logs
sudo journalctl -u jenkins -f
```

---

## 🔧 Fix Unhealthy Containers

```bash
cd ~/MERN-AI-ChatBot

# Option 1: Restart containers
docker-compose -f docker-compose-ci.yml restart

# Option 2: Full restart (if above doesn't work)
docker-compose -f docker-compose-ci.yml down
docker-compose -f docker-compose-ci.yml up -d

# Option 3: Restart dev containers
docker-compose restart

# Wait 30 seconds and check status
sleep 30
docker ps

# View logs to check for errors
docker-compose -f docker-compose-ci.yml logs -f
```

---

## 🌐 Jenkins Commands

```bash
# Restart Jenkins
sudo systemctl restart jenkins

# Stop Jenkins
sudo systemctl stop jenkins

# Start Jenkins
sudo systemctl start jenkins

# Check Jenkins status
sudo systemctl status jenkins

# View Jenkins logs (real-time)
sudo journalctl -u jenkins -f

# View Jenkins logs (last 50 lines)
sudo journalctl -u jenkins -n 50

# Get initial admin password (if needed)
sudo cat /var/lib/jenkins/secrets/initialAdminPassword

# Give Jenkins Docker access (if needed)
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins

# Logout and login to apply group changes
exit
# Then SSH back in
```

---

## 🐳 Docker Management

```bash
# Stop all containers
docker stop $(docker ps -q)

# Remove all stopped containers
docker container prune -f

# Remove unused images
docker image prune -a -f

# Remove unused volumes
docker volume prune -f

# Full cleanup (careful!)
docker system prune -a --volumes -f

# Check disk usage
docker system df

# View all images
docker images

# Remove specific image
docker rmi <image-id>

# View all volumes
docker volume ls

# Remove specific volume
docker volume rm <volume-name>
```

---

## 📁 Application Management

```bash
cd ~/MERN-AI-ChatBot

# Pull latest code
git pull origin final

# Rebuild and restart
docker-compose -f docker-compose-ci.yml down
docker-compose -f docker-compose-ci.yml build --no-cache
docker-compose -f docker-compose-ci.yml up -d

# View logs
docker-compose -f docker-compose-ci.yml logs -f

# Stop services
docker-compose -f docker-compose-ci.yml down

# Start services
docker-compose -f docker-compose-ci.yml up -d
```

---

## 🧪 Test Commands

```bash
# Test backend health
curl http://localhost:5001/api/v1

# Test frontend
curl -I http://localhost:5174

# Test MongoDB
docker exec mern-chatbot-mongo-ci mongosh --eval "db.adminCommand('ping')"

# Test Jenkins
curl -I http://localhost:8080

# Test from outside (from your Windows machine)
# Open browser: http://13.53.174.119:5174
# Open browser: http://13.53.174.119:8080
```

---

## 🔐 Environment Variables

```bash
# Check backend .env
cat ~/MERN-AI-ChatBot/backend/.env

# Edit backend .env
nano ~/MERN-AI-ChatBot/backend/.env

# Check root .env
cat ~/MERN-AI-ChatBot/.env

# Edit root .env
nano ~/MERN-AI-ChatBot/.env
```

---

## 📊 Monitoring Commands

```bash
# Real-time Docker stats
docker stats

# Check disk space
df -h

# Check memory usage
free -h

# Check system load
top

# Or better:
htop

# Check ports in use
sudo netstat -tulpn

# Check specific port
sudo netstat -tulpn | grep 8080
sudo netstat -tulpn | grep 5174
```

---

## 🔄 Jenkins Job Management

```bash
# Trigger Jenkins job via CLI (if configured)
curl -X POST http://localhost:8080/job/MERN-ChatBot-Selenium-Tests/build

# View Jenkins workspace
sudo ls -la /var/lib/jenkins/workspace/

# Clean Jenkins workspace
sudo rm -rf /var/lib/jenkins/workspace/MERN-ChatBot-Selenium-Tests/*
```

---

## 🐛 Troubleshooting

### Backend CI Unhealthy

```bash
# Check logs
docker logs mern-chatbot-backend-ci --tail 100

# Check if it's actually working
curl http://localhost:5001/api/v1

# Restart just backend
docker restart mern-chatbot-backend-ci

# Check environment variables
docker exec mern-chatbot-backend-ci env | grep -E "MONGODB|JWT|COOKIE|OPEN_AI"
```

### Frontend CI Unhealthy

```bash
# Check logs
docker logs mern-chatbot-frontend-ci --tail 100

# Check if it's serving content
curl http://localhost:5174

# Restart just frontend
docker restart mern-chatbot-frontend-ci

# Check Vite process
docker exec mern-chatbot-frontend-ci ps aux
```

### Jenkins Not Starting

```bash
# Check Java version
java -version

# Should be Java 11 or higher
# If not, install:
sudo apt install openjdk-17-jdk -y

# Check Jenkins logs
sudo journalctl -u jenkins -n 100 --no-pager

# Check port conflict
sudo netstat -tulpn | grep 8080

# Kill process on port 8080 if needed
sudo kill -9 $(sudo lsof -t -i:8080)
```

### Webhook Not Triggering

```bash
# Test webhook manually
curl -X POST http://localhost:8080/github-webhook/

# Check Jenkins system log
# In Jenkins UI: Manage Jenkins → System Log

# Enable webhook logging
# Manage Jenkins → System Log → Add new log recorder
# Name: Webhooks
# Logger: org.jenkinsci.plugins.github (ALL)
```

---

## 📸 Screenshots for Assignment

```bash
# 1. Container status
docker ps

# 2. Application running
curl http://localhost:5174

# 3. Jenkins dashboard
# Open: http://13.53.174.119:8080

# 4. Test results
# Open: http://13.53.174.119:8080/job/MERN-ChatBot-Selenium-Tests/lastBuild/

# 5. Docker images
docker images

# 6. System resources
docker stats --no-stream
```

---

## 🎯 Your Specific URLs

```
Jenkins:       http://13.53.174.119:8080
Webhook:       http://13.53.174.119:8080/github-webhook/

Frontend (CI): http://13.53.174.119:5174
Backend (CI):  http://13.53.174.119:5001/api/v1

Frontend (Dev):http://13.53.174.119:5173
Backend (Dev): http://13.53.174.119:5000/api/v1
```

---

## 🚀 Quick Setup Verification

Run this one-liner to check everything:

```bash
echo "=== System Check ===" && \
echo "Jenkins: $(systemctl is-active jenkins)" && \
echo "Containers: $(docker ps --format '{{.Names}} - {{.Status}}' | wc -l) running" && \
echo "Frontend CI: $(curl -s -o /dev/null -w '%{http_code}' http://localhost:5174)" && \
echo "Backend CI: $(curl -s -o /dev/null -w '%{http_code}' http://localhost:5001/api/v1)" && \
echo "Disk: $(df -h / | awk 'NR==2 {print $5}')" && \
echo "Memory: $(free -h | awk 'NR==2 {print $3"/"$2}')"
```

---

## 📝 Save These Commands

Create an alias for quick access:

```bash
# Add to ~/.bashrc
echo 'alias checkapp="docker ps && echo && curl -s http://localhost:5174 > /dev/null && echo Frontend: OK || echo Frontend: FAIL && curl -s http://localhost:5001/api/v1 > /dev/null && echo Backend: OK || echo Backend: FAIL"' >> ~/.bashrc
source ~/.bashrc

# Now just type:
checkapp
```

---

**Keep this file handy for quick reference! 📌**
