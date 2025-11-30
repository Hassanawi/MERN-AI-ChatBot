# 🔗 GitHub Webhook Troubleshooting Guide

Complete guide to fix GitHub webhook integration with Jenkins.

---

## 🔍 Problem Diagnosis

Common reasons webhooks don't work:

1. ❌ Jenkins URL is localhost (not accessible from GitHub)
2. ❌ GitHub plugin not installed
3. ❌ Security settings blocking GitHub
4. ❌ Wrong webhook URL format
5. ❌ Firewall blocking port 8080
6. ❌ Webhook secret mismatch

---

## ✅ Step-by-Step Fix

### Step 1: Verify Jenkins URL

**Your Jenkins must be accessible from the internet!**

❌ **These URLs won't work:**
- `http://localhost:8080`
- `http://127.0.0.1:8080`
- `http://192.168.x.x:8080` (internal network)

✅ **These URLs will work:**
- `http://YOUR_EC2_PUBLIC_IP:8080` (e.g., `http://3.85.123.45:8080`)
- `http://your-domain.com:8080`

**To check your EC2 public IP:**
```bash
# On EC2 instance
curl ifconfig.me
```

---

### Step 2: Configure Jenkins URL

1. In Jenkins, go to: **Manage Jenkins** → **System**
2. Scroll to **Jenkins Location**
3. Set **Jenkins URL** to: `http://YOUR_EC2_PUBLIC_IP:8080/`
4. Click **Save**

**Example:**
```
Jenkins URL: http://3.85.123.45:8080/
```

---

### Step 3: Install Required Plugins

1. Go to: **Manage Jenkins** → **Plugins** → **Available plugins**

2. Search and install:
   - ✅ **GitHub Plugin**
   - ✅ **GitHub Integration Plugin**
   - ✅ **Git Plugin**
   - ✅ **Credentials Plugin**

3. Check **Restart Jenkins when installation is complete**

---

### Step 4: Configure GitHub Server in Jenkins

1. **Manage Jenkins** → **System**

2. Scroll to **GitHub** section

3. Click **Add GitHub Server** → **GitHub Server**

4. Configure:
   - Name: `GitHub`
   - API URL: `https://api.github.com` (default)
   - Credentials: (leave blank for public repos)
   - ✅ Check **Manage hooks**

5. Click **Test connection** (should show rate limit info)

6. Click **Save**

---

### Step 5: Create Jenkins Pipeline Job (Correctly)

1. Click **New Item**

2. Enter name: `MERN-ChatBot-Selenium-Tests`

3. Select: **Pipeline**

4. Click **OK**

5. Configure:

   **General:**
   - Description: `MERN AI ChatBot CI/CD Pipeline`
   - ✅ Check **GitHub project**
   - Project url: `https://github.com/Hassanawi/MERN-AI-ChatBot/`

   **Build Triggers:**
   - ✅ Check **GitHub hook trigger for GITScm polling**

   **Pipeline:**
   - Definition: **Pipeline script from SCM**
   - SCM: **Git**
   - Repository URL: `https://github.com/Hassanawi/MERN-AI-ChatBot.git`
   - Credentials: (Add if private repo)
   - Branch Specifier: `*/final` (or `*/main`)
   - Script Path: `Jenkinsfile`

6. Click **Save**

---

### Step 6: Add GitHub Webhook

**IMPORTANT:** Use the exact format below!

1. Go to GitHub: https://github.com/Hassanawi/MERN-AI-ChatBot

2. Click **Settings** → **Webhooks** → **Add webhook**

3. Configure:
   - **Payload URL:** `http://YOUR_EC2_PUBLIC_IP:8080/github-webhook/`
     - ⚠️ Must end with `/github-webhook/`
     - ⚠️ Must include trailing slash `/`
     - Example: `http://3.85.123.45:8080/github-webhook/`
   
   - **Content type:** `application/json`
   
   - **Secret:** (leave blank for now)
   
   - **Which events would you like to trigger this webhook?**
     - ✅ Select **Just the push event**
   
   - ✅ Check **Active**

4. Click **Add webhook**

5. **Verify delivery:**
   - GitHub will send a test ping
   - Refresh the page
   - You should see a green ✅ checkmark
   - If red ❌, click on it to see error details

---

## 🧪 Step 7: Test the Webhook

### Test 1: Manual Build

1. In Jenkins, open your pipeline job
2. Click **Build Now**
3. Watch the build execute
4. Check **Console Output**
5. Verify all stages complete

### Test 2: Push Trigger

1. Make a small change to `README.md`:
   ```bash
   cd "E:\university\devops\assigment 02\MERN-AI-ChatBot"
   echo "" >> README.md
   git add README.md
   git commit -m "Test webhook trigger"
   git push origin final
   ```

2. In GitHub:
   - Go to **Settings** → **Webhooks**
   - Click on your webhook
   - Check **Recent Deliveries**
   - Should show green checkmark ✅

3. In Jenkins:
   - Build should start automatically
   - Check job dashboard
   - New build should appear

### Test 3: Check Webhook Response

In GitHub webhook page, click on a delivery to see:

✅ **Good response:**
```json
Status: 200 OK
Response: {"status": "ok"}
```

❌ **Bad responses:**

**Connection refused (Jenkins not accessible):**
```
We couldn't deliver this payload: failed to connect to host
```
**Fix:** Check EC2 security group allows port 8080

**404 Not Found:**
```
Status: 404 Not Found
```
**Fix:** Wrong URL format. Must be `/github-webhook/` not `/github-webhook`

---

## 🔧 Common Issues & Fixes

### Issue 1: Webhook Shows "Failed to connect"

**Symptoms:**
- GitHub shows "We couldn't deliver this payload"
- Red ❌ in Recent Deliveries

**Causes:**
1. Jenkins is on localhost (not accessible)
2. Firewall blocking port 8080
3. EC2 security group not configured

**Fix:**
```bash
# On EC2, verify Jenkins is running
sudo systemctl status jenkins

# Check if port 8080 is open
sudo netstat -tulpn | grep 8080

# Test from outside EC2
# From your Windows machine:
Invoke-WebRequest -Uri http://YOUR_EC2_PUBLIC_IP:8080
```

**EC2 Security Group:**
- Go to AWS Console → EC2 → Security Groups
- Find your Jenkins security group
- Verify inbound rule exists:
  - Type: Custom TCP
  - Port: 8080
  - Source: 0.0.0.0/0 (or GitHub IP ranges)

---

### Issue 2: Webhook Delivers but Build Doesn't Start

**Symptoms:**
- Webhook shows 200 OK
- But no build starts in Jenkins

**Causes:**
1. Wrong trigger setting in Jenkins job
2. Branch mismatch
3. Repository URL mismatch

**Fix:**

1. **Check job configuration:**
   - Build Triggers: **GitHub hook trigger for GITScm polling** must be checked
   - Not "Poll SCM" or other options

2. **Check branch:**
   - If you push to `final` branch
   - Jenkins job must monitor `*/final`
   - Not `*/main` or `*/master`

3. **Check repository URL:**
   - GitHub webhook repository must match Jenkins job repository
   - Both should be: `https://github.com/Hassanawi/MERN-AI-ChatBot.git`

---

### Issue 3: Build Starts but Fails Immediately

**Symptoms:**
- Webhook triggers build
- Build starts but fails at checkout

**Causes:**
1. Git not configured in Jenkins
2. Wrong credentials
3. Branch doesn't exist

**Fix:**
```bash
# On EC2, verify git is installed
git --version

# Check Jenkins can access git
sudo -u jenkins git --version

# Test clone manually
git clone https://github.com/Hassanawi/MERN-AI-ChatBot.git /tmp/test-clone
```

---

### Issue 4: Multiple Builds Starting

**Symptoms:**
- One push triggers multiple builds

**Causes:**
1. Multiple webhooks configured
2. Poll SCM also enabled

**Fix:**
1. Go to GitHub → Settings → Webhooks
2. Delete duplicate webhooks
3. Keep only one webhook
4. In Jenkins job, ensure only "GitHub hook trigger" is checked, not "Poll SCM"

---

## 🎯 Verification Checklist

Run through this checklist:

### Jenkins Configuration
- [ ] Jenkins URL is set to public IP (not localhost)
- [ ] GitHub plugin installed
- [ ] GitHub server configured
- [ ] Job has "GitHub hook trigger" enabled
- [ ] Repository URL is correct
- [ ] Branch specifier matches your branch

### GitHub Configuration
- [ ] Webhook URL ends with `/github-webhook/`
- [ ] Webhook URL uses public IP (not localhost)
- [ ] Content type is `application/json`
- [ ] "Push events" is selected
- [ ] Webhook is Active (checked)

### Network Configuration
- [ ] EC2 security group allows port 8080
- [ ] Jenkins is running: `sudo systemctl status jenkins`
- [ ] Port 8080 is open: `sudo netstat -tulpn | grep 8080`
- [ ] Can access Jenkins from browser: `http://YOUR_EC2_PUBLIC_IP:8080`

### Testing
- [ ] Manual build works (Build Now)
- [ ] Webhook shows green checkmark
- [ ] Git push triggers automatic build
- [ ] Recent Deliveries show 200 OK

---

## 🚀 Quick Commands

### Restart Jenkins
```bash
sudo systemctl restart jenkins
```

### Check Jenkins Logs
```bash
sudo journalctl -u jenkins -f
```

### Test Webhook Manually
```bash
# From your local machine
curl -X POST http://YOUR_EC2_PUBLIC_IP:8080/github-webhook/
```

### View Jenkins System Log
In Jenkins web UI:
- **Manage Jenkins** → **System Log**
- Look for webhook-related messages

---

## 📝 Example Working Configuration

### GitHub Webhook:
```
URL: http://3.85.123.45:8080/github-webhook/
Content type: application/json
Events: Just the push event
Active: ✅
```

### Jenkins Job:
```
GitHub project: ✅
Project url: https://github.com/Hassanawi/MERN-AI-ChatBot/

Build Triggers:
GitHub hook trigger for GITScm polling: ✅

Pipeline:
Definition: Pipeline script from SCM
SCM: Git
Repository URL: https://github.com/Hassanawi/MERN-AI-ChatBot.git
Branch: */final
Script Path: Jenkinsfile
```

### Jenkins System:
```
Jenkins Location:
Jenkins URL: http://3.85.123.45:8080/

GitHub:
Name: GitHub
API URL: https://api.github.com
Manage hooks: ✅
```

---

## 🐛 Debug Mode

If still not working, enable debug logging:

1. **Manage Jenkins** → **System Log** → **Add new log recorder**

2. Name: `GitHub Webhooks`

3. Add loggers:
   - `org.jenkinsci.plugins.github` → **ALL**
   - `com.cloudbees.jenkins.GitHubPushTrigger` → **ALL**
   - `com.cloudbees.jenkins.GitHubWebHook` → **ALL**

4. Click **Save**

5. Make a test push

6. Check the log recorder for detailed messages

---

## 💡 Pro Tips

1. **Use ngrok for local testing:**
   ```bash
   # If testing on local Jenkins (not EC2)
   ngrok http 8080
   # Use the ngrok URL as webhook URL
   ```

2. **Test webhook delivery manually:**
   ```powershell
   # From Windows PowerShell
   $headers = @{"Content-Type"="application/json"}
   $body = '{"ref":"refs/heads/final"}'
   Invoke-WebRequest -Uri "http://YOUR_EC2_PUBLIC_IP:8080/github-webhook/" -Method POST -Headers $headers -Body $body
   ```

3. **Monitor Jenkins in real-time:**
   ```bash
   # On EC2
   tail -f /var/log/jenkins/jenkins.log
   ```

4. **Use GitHub CLI to test:**
   ```bash
   # Test webhook delivery
   gh api repos/Hassanawi/MERN-AI-ChatBot/hooks
   ```

---

## ✅ Success Indicators

You know it's working when:

1. ✅ Webhook shows green checkmark in GitHub
2. ✅ Recent Deliveries show "200 OK"
3. ✅ Git push automatically starts Jenkins build
4. ✅ Jenkins console log shows "Started by GitHub push by Hassanawi"
5. ✅ Email notification received after build

---

## 📞 Still Not Working?

If webhook still doesn't work after following this guide:

1. **Check Jenkins logs:**
   ```bash
   sudo journalctl -u jenkins -n 100
   ```

2. **Verify GitHub can reach your server:**
   ```bash
   # On EC2
   sudo tail -f /var/log/syslog | grep 8080
   ```

3. **Test manually:**
   ```bash
   curl -X POST \
     -H "Content-Type: application/json" \
     -d '{"ref":"refs/heads/final","repository":{"url":"https://github.com/Hassanawi/MERN-AI-ChatBot"}}' \
     http://YOUR_EC2_PUBLIC_IP:8080/github-webhook/
   ```

4. **Verify Java version (Jenkins requires Java 11+):**
   ```bash
   java -version
   ```

---

**Good luck! Your webhook should now work correctly! 🎉**

If you follow all steps, especially ensuring Jenkins URL uses public IP and webhook URL ends with `/github-webhook/`, it will work.
