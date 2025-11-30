# Selenium Test Suite for MERN AI ChatBot

This directory contains automated test cases using Selenium WebDriver with Python for testing the MERN AI ChatBot application.

## 📋 Test Coverage

The test suite includes 15 comprehensive test cases covering:

### Home Page Tests (4 tests)
1. **test_01_home_page_loads_successfully** - Verifies home page loads correctly
2. **test_02_navigation_links_visible** - Checks navigation links are visible
3. **test_03_navigate_to_login_page** - Tests navigation to login page
4. **test_04_navigate_to_signup_page** - Tests navigation to signup page

### Login Page Tests (4 tests)
5. **test_05_login_page_elements_present** - Validates login form elements
6. **test_06_login_with_empty_credentials** - Tests empty credential validation
7. **test_07_login_with_invalid_email** - Tests invalid email format validation
8. **test_08_login_with_short_password** - Tests password length validation

### Signup Page Tests (3 tests)
9. **test_09_signup_page_elements_present** - Validates signup form elements
10. **test_10_signup_with_empty_fields** - Tests empty field validation
11. **test_11_signup_with_invalid_data** - Tests invalid data validation

### Chat & General Tests (4 tests)
12. **test_12_chat_page_redirect_when_not_logged_in** - Tests authentication requirement
13. **test_13_404_page_for_invalid_route** - Tests 404 handling
14. **test_14_browser_back_navigation** - Tests browser navigation
15. **test_15_page_responsiveness** - Tests page load performance

## 🚀 Prerequisites

- Python 3.8+
- Google Chrome browser
- ChromeDriver (automatically managed by webdriver-manager)

## 📦 Installation

1. **Navigate to tests directory:**
   ```bash
   cd tests
   ```

2. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

3. **Configure environment:**
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

## ⚙️ Configuration

Edit `.env` file to configure:

```env
# Application URLs
BASE_URL=http://localhost:5173
BACKEND_URL=http://localhost:5000

# Test User Credentials
TEST_USER_EMAIL=testuser@example.com
TEST_USER_PASSWORD=test123456
TEST_USER_NAME=Test User

# Test Settings
IMPLICIT_WAIT=10
PAGE_LOAD_TIMEOUT=30
HEADLESS=true  # Set to true for CI/CD environments
```

## 🧪 Running Tests

### Run all tests:
```bash
pytest test_chatbot.py -v
```

### Run with HTML report:
```bash
pytest test_chatbot.py -v --html=reports/test_report.html --self-contained-html
```

### Run specific test:
```bash
pytest test_chatbot.py::TestHomePage::test_01_home_page_loads_successfully -v
```

### Run in headless mode (for CI/CD):
```bash
export HEADLESS=true  # On Windows: set HEADLESS=true
pytest test_chatbot.py -v
```

### Run with specific markers:
```bash
pytest test_chatbot.py -v -m "home"
```

## 📊 Test Reports

Test reports are generated in the `reports/` directory:
- **HTML Report**: `reports/test_report.html` - Detailed test execution report
- **Screenshots**: `reports/screenshots/` - Screenshots of failed tests

## 🐳 Docker Support

### Build Docker image:
```bash
docker build -t mern-chatbot-tests .
```

### Run tests in Docker:
```bash
docker run --rm \
  -e BASE_URL=http://host.docker.internal:5173 \
  -e HEADLESS=true \
  -v $(pwd)/reports:/app/reports \
  mern-chatbot-tests
```

## 🔧 Project Structure

```
tests/
├── conftest.py              # Pytest fixtures and configuration
├── config.py                # Test configuration
├── requirements.txt         # Python dependencies
├── .env.example            # Environment variables template
├── README.md               # This file
├── Dockerfile              # Docker image for tests
├── pages/                  # Page Object Model
│   ├── base_page.py       # Base page class
│   ├── home_page.py       # Home page object
│   ├── login_page.py      # Login page object
│   ├── signup_page.py     # Signup page object
│   └── chat_page.py       # Chat page object
├── test_chatbot.py        # Main test suite
└── reports/               # Test reports and screenshots
    ├── test_report.html   # HTML test report
    └── screenshots/       # Failure screenshots
```

## 📝 Writing New Tests

Follow the Page Object Model pattern:

```python
def test_new_feature(self, driver):
    """Test description"""
    page = PageObject(driver)
    page.perform_action()
    assert page.verify_result()
    print("✓ Test Passed: Description")
```

## 🐛 Troubleshooting

### ChromeDriver issues:
```bash
# Update ChromeDriver
pip install --upgrade webdriver-manager
```

### Connection refused errors:
- Ensure the application is running on the configured BASE_URL
- Check if ports 5173 (frontend) and 5000 (backend) are accessible

### Headless mode issues:
```bash
# Try running without headless mode
export HEADLESS=false
pytest test_chatbot.py -v
```

### Element not found errors:
- Increase IMPLICIT_WAIT in .env
- Check if selectors in page objects are correct
- View screenshots in reports/screenshots/

## 🎯 Best Practices

1. **Always run tests in headless mode in CI/CD**
2. **Review HTML reports after test execution**
3. **Check screenshots for failed tests**
4. **Keep page objects updated with UI changes**
5. **Use meaningful test names and descriptions**
6. **Add waits for dynamic content**
7. **Clean up test data after execution**

## 📧 CI/CD Integration

These tests are designed to run in Jenkins pipeline with Docker. See the main Jenkinsfile for integration details.

The tests automatically:
- Run in headless Chrome mode
- Generate HTML reports
- Capture screenshots on failures
- Exit with proper status codes for CI/CD

## 📄 License

Part of MERN AI ChatBot DevOps Assignment.
