"""
Pytest fixtures for Selenium tests
"""
import pytest
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from webdriver_manager.chrome import ChromeDriverManager
import config
import os
import time


@pytest.fixture(scope="function")
def driver():
    """
    Setup Chrome WebDriver with headless option for CI/CD environments
    Works with Chrome, Chromium, and Brave browsers
    """
    chrome_options = Options()
    
    # Try to find Brave browser first (common on Windows), then Chrome
    brave_paths = [
        os.path.expandvars(r"%LOCALAPPDATA%\BraveSoftware\Brave-Browser\Application\brave.exe"),
        r"C:\Program Files\BraveSoftware\Brave-Browser\Application\brave.exe",
        r"C:\Program Files (x86)\BraveSoftware\Brave-Browser\Application\brave.exe",
    ]
    
    chrome_paths = [
        r"C:\Program Files\Google\Chrome\Application\chrome.exe",
        r"C:\Program Files (x86)\Google\Chrome\Application\chrome.exe",
        os.path.expandvars(r"%LOCALAPPDATA%\Google\Chrome\Application\chrome.exe"),
    ]
    
    # Check for browser binary
    browser_binary = None
    for path in brave_paths + chrome_paths:
        if os.path.exists(path):
            browser_binary = path
            print(f"Found browser: {path}")
            break
    
    if browser_binary:
        chrome_options.binary_location = browser_binary
    
    # Configure Chrome for headless mode (required for Jenkins/CI)
    if config.HEADLESS:
        chrome_options.add_argument('--headless=new')  # New headless mode
        chrome_options.add_argument('--disable-gpu')
    
    # Additional options for stability
    chrome_options.add_argument('--no-sandbox')
    chrome_options.add_argument('--disable-dev-shm-usage')
    chrome_options.add_argument('--window-size=1920,1080')
    chrome_options.add_argument('--disable-extensions')
    chrome_options.add_argument('--disable-blink-features=AutomationControlled')
    chrome_options.add_argument('--remote-debugging-port=9222')  # Help with debugging
    chrome_options.add_experimental_option("excludeSwitches", ["enable-automation"])
    chrome_options.add_experimental_option('useAutomationExtension', False)
    
    # Initialize WebDriver
    try:
        if config.CHROME_DRIVER_PATH:
            service = Service(config.CHROME_DRIVER_PATH)
            driver = webdriver.Chrome(service=service, options=chrome_options)
        else:
            # Try without ChromeDriverManager first (use system ChromeDriver)
            try:
                print("Attempting to use system ChromeDriver...")
                driver = webdriver.Chrome(options=chrome_options)
            except Exception as e1:
                print(f"System ChromeDriver failed: {e1}")
                print("Trying ChromeDriverManager...")
                # Fallback to ChromeDriverManager
                try:
                    service = Service(ChromeDriverManager().install())
                    driver = webdriver.Chrome(service=service, options=chrome_options)
                except Exception as e2:
                    print(f"ChromeDriverManager also failed: {e2}")
                    raise Exception("Could not initialize ChromeDriver. Please install ChromeDriver manually.")
    except Exception as e:
        print(f"Error initializing Chrome WebDriver: {e}")
        raise
    
    # Set timeouts
    driver.implicitly_wait(config.IMPLICIT_WAIT)
    driver.set_page_load_timeout(config.PAGE_LOAD_TIMEOUT)
    
    yield driver
    
    # Cleanup
    try:
        driver.quit()
    except:
        pass


@pytest.fixture(scope="function")
def authenticated_driver(driver):
    """
    Fixture that provides a driver with authenticated session
    """
    from pages.login_page import LoginPage
    
    # Navigate to login page
    driver.get(f"{config.BASE_URL}/login")
    time.sleep(2)
    
    # Login
    login_page = LoginPage(driver)
    login_page.login(config.TEST_USER_EMAIL, config.TEST_USER_PASSWORD)
    time.sleep(3)
    
    # Verify login was successful by checking URL
    assert "/chat" in driver.current_url or "/login" not in driver.current_url
    
    yield driver


@pytest.hookimpl(tryfirst=True, hookwrapper=True)
def pytest_runtest_makereport(item, call):
    """
    Hook to take screenshot on test failure
    """
    outcome = yield
    rep = outcome.get_result()
    
    if rep.when == 'call' and rep.failed:
        driver = item.funcargs.get('driver') or item.funcargs.get('authenticated_driver')
        if driver:
            screenshot_name = f"{item.name}_{int(time.time())}.png"
            screenshot_path = os.path.join(config.SCREENSHOT_DIR, screenshot_name)
            driver.save_screenshot(screenshot_path)
            print(f"\nScreenshot saved: {screenshot_path}")
