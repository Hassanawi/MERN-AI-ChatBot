# 📧 Email Not Sending - Quick Fix

## Problem
Email shows: "Not sent to the following valid addresses: qasimalik@gmail.com hassansarfraz030@gmail.com"

This means Gmail SMTP credentials are not properly configured in Jenkins.

---

## ✅ Solution: Configure Gmail in Jenkins

### Step 1: Get Gmail App Password (If not done yet)

1. Go to: https://myaccount.google.com/apppasswords
2. Create app password for "Mail" → "Jenkins"
3. Copy the 16-character password (e.g., `abcd efgh ijkl mnop`)

---

### Step 2: Configure Jenkins Extended E-mail Plugin

1. **Open Jenkins:** http://13.53.174.119:8080

2. **Go to:** Manage Jenkins → System

3. **Scroll to:** "Extended E-mail Notification" section

4. **Configure:**
   - SMTP server: `smtp.gmail.com`
   - SMTP Port: `465`
   - Click **"Advanced..."** button
   - ✅ Check **"Use SSL"**
   
5. **Add Credentials:**
   - Click **"Add"** next to Credentials dropdown → Select **"Jenkins"**
   - In the popup:
     - Kind: **Username with password**
     - Scope: **Global**
     - Username: `qasimalik@gmail.com` (or your Gmail)
     - Password: `[paste 16-char app password]`
     - ID: `gmail-smtp-credentials`
     - Description: `Gmail SMTP for Jenkins`
   - Click **"Add"**
   
6. **Select the credential** you just created from the dropdown

7. **Set Default Content Type:** `HTML (text/html)`

8. **Click "Save"** at the bottom

---

### Step 3: Test Email Configuration

1. **Still in Jenkins System config**

2. **Scroll to:** "E-mail Notification" section (different from Extended E-mail)

3. **Configure:**
   - SMTP server: `smtp.gmail.com`
   - Click **"Advanced..."**
   - ✅ Check **"Use SMTP Authentication"**
   - User Name: `qasimalik@gmail.com`
   - Password: `[paste 16-char app password]`
   - ✅ Check **"Use SSL"**
   - SMTP Port: `465`

4. **Test it:**
   - Test e-mail recipient: `qasimalik@gmail.com`
   - Click **"Test configuration by sending test e-mail"**
   - Should say: **"Email was successfully sent"**
   - Check your inbox!

5. **Click "Save"**

---

### Step 4: Trigger New Build

After saving, trigger a new build:

```bash
# From your local machine
cd "E:\university\devops\assigment 02\MERN-AI-ChatBot"
git commit --allow-empty -m "Test email after Gmail config"
git push origin final
```

Or click **"Build Now"** in Jenkins.

---

## 🎯 Expected Result

After build completes, both emails should receive:
- ✅ **qasimalik@gmail.com**
- ✅ **hassansarfraz030@gmail.com**

Subject: "Jenkins Build SUCCESS: MERN-ChatBot-Pipeline #26"

---

## 🐛 If Email Still Doesn't Send

### Check 1: Gmail App Password is Correct
- Make sure you copied the entire 16-character password
- No spaces or extra characters
- Try generating a new app password

### Check 2: Gmail Account Settings
- Go to: https://myaccount.google.com/security
- Ensure "2-Step Verification" is ON
- Ensure "Less secure app access" is OFF (we use app passwords instead)

### Check 3: Jenkins Console Output
- Look for detailed error message in build console
- Common errors:
  - "Authentication failed" → Wrong password
  - "Connection refused" → Wrong port or server
  - "SSL handshake failed" → SSL checkbox not checked

### Check 4: Use Alternative Port
If port 465 doesn't work, try port 587 with TLS:
- SMTP Port: `587`
- ✅ Check **"Use TLS"** instead of "Use SSL"

---

## 📝 Quick Settings Reference

**Extended E-mail Notification:**
```
SMTP server: smtp.gmail.com
SMTP Port: 465
Use SSL: ✅
Credentials: [Add with your Gmail and app password]
Default Content Type: HTML (text/html)
```

**E-mail Notification:**
```
SMTP server: smtp.gmail.com
Use SMTP Authentication: ✅
User Name: qasimalik@gmail.com
Password: [16-char app password]
Use SSL: ✅
SMTP Port: 465
```

---

## ⚠️ Important Notes

1. **Use App Password, NOT your regular Gmail password**
2. **Remove spaces from the app password when pasting**
3. **Make sure to click "Save" after configuration**
4. **Test the configuration before triggering a build**
5. **Check spam/junk folder for test emails**

---

**Once configured, every build will automatically send emails to both recipients!** 📬
