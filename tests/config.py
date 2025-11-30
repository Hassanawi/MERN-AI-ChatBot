"""
Configuration file for Selenium tests
"""
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Base URLs
BASE_URL = os.getenv('BASE_URL', 'http://localhost:5173')
BACKEND_URL = os.getenv('BACKEND_URL', 'http://localhost:5000')

# Test User Credentials
TEST_USER_EMAIL = os.getenv('TEST_USER_EMAIL', 'testuser@example.com')
TEST_USER_PASSWORD = os.getenv('TEST_USER_PASSWORD', 'test123456')
TEST_USER_NAME = os.getenv('TEST_USER_NAME', 'Test User')

# Timeouts
IMPLICIT_WAIT = int(os.getenv('IMPLICIT_WAIT', '10'))
PAGE_LOAD_TIMEOUT = int(os.getenv('PAGE_LOAD_TIMEOUT', '30'))

# Browser Configuration
HEADLESS = os.getenv('HEADLESS', 'true').lower() == 'true'
CHROME_DRIVER_PATH = os.getenv('CHROME_DRIVER_PATH', None)

# Test Reports
REPORT_DIR = os.path.join(os.path.dirname(__file__), 'reports')
SCREENSHOT_DIR = os.path.join(REPORT_DIR, 'screenshots')

# Create directories if they don't exist
os.makedirs(REPORT_DIR, exist_ok=True)
os.makedirs(SCREENSHOT_DIR, exist_ok=True)
