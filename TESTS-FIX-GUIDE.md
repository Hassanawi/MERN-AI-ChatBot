# 🐛 Test Execution Fix - Application Not Running

## ✅ Good News!
Your Selenium tests are **correctly configured** and working! Brave browser was detected and ChromeDriver is functioning.

The error `net::ERR_CONNECTION_REFUSED` means the tests can't connect to the application because it's **not running** at `http://localhost:5174`.

---

## 🚀 Solution: Start Your Application

### Option 1: Using Docker (Recommended)

**Step 1: Start Docker Desktop**
1. Open **Docker Desktop** application
2. Wait for it to fully start (Docker icon in system tray will stop animating)
3. Verify Docker is running:
   ```powershell
   docker ps
   ```

**Step 2: Start Application**
```powershell
# From project root directory
docker-compose -f docker-compose-ci.yml up -d

# Wait for services to start (30 seconds)
Start-Sleep -Seconds 30

# Verify containers are running
docker-compose -f docker-compose-ci.yml ps
```

**Step 3: Run Tests**
```powershell
cd tests
pytest test_chatbot.py -v --html=reports/test_report.html --self-contained-html
```

---

### Option 2: Using npm (If Docker Issues)

**Start Backend:**
```powershell
cd backend
npm install
npm run dev
```

**Start Frontend (New Terminal):**
```powershell
cd frontend  
npm install
npm run dev
```

**Update Test Configuration:**
```powershell
cd tests
# Edit .env file
# Change BASE_URL to http://localhost:5173
# Change BACKEND_URL to http://localhost:5000
```

**Run Tests:**
```powershell
pytest test_chatbot.py -v
```

---

### Option 3: Quick Test with Mock Server (Just to verify Selenium works)

Run this to create a simple test server:

```powershell
# Start simple test server
python -m http.server 5174
```

Then in **another terminal**, run tests:
```powershell
cd tests
pytest test_chatbot.py::TestHomePage::test_01_home_page_loads_successfully -v
```

This will at least verify Selenium and Brave are working correctly.

---

## 🔍 Verify Application is Running

Before running tests, check:

```powershell
# Test if frontend is accessible
Invoke-WebRequest -Uri http://localhost:5174 -UseBasicParsing

# Or open in browser
Start-Process "http://localhost:5174"
```

---

## ✅ Current Status

| Component | Status |
|-----------|--------|
| Python & Pytest | ✅ Working |
| Selenium | ✅ Working |
| Brave Browser | ✅ Detected |
| ChromeDriver | ✅ Working |
| Test Code | ✅ Ready |
| **Application** | ❌ **Not Running** |

---

## 📝 Next Steps

1. **Start Docker Desktop** OR **Run application with npm**
2. **Verify application is accessible** at http://localhost:5174
3. **Run tests again**
4. Tests should now **PASS** ✅

---

## 🎯 Quick Start Command (After starting app)

```powershell
cd tests
pytest test_chatbot.py -v --html=reports/test_report.html --self-contained-html
```

---

## 💡 Tip

To avoid this in future, always ensure your application is running before running tests. You can add a check in the test script or use the `run-tests-local.ps1` script which automatically starts the application.

The tests are **working correctly** - they just need something to test against! 🎉
