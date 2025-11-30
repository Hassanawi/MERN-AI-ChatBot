"""
Base Page Object Model class
"""
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException, NoSuchElementException
import config
import os
import time


class BasePage:
    """Base class for all page objects"""
    
    def __init__(self, driver):
        self.driver = driver
        self.wait = WebDriverWait(driver, config.IMPLICIT_WAIT)
    
    def find_element(self, locator, timeout=10):
        """Find a single element with explicit wait"""
        try:
            element = WebDriverWait(self.driver, timeout).until(
                EC.presence_of_element_located(locator)
            )
            return element
        except TimeoutException:
            raise NoSuchElementException(f"Element not found: {locator}")
    
    def find_elements(self, locator, timeout=10):
        """Find multiple elements with explicit wait"""
        try:
            elements = WebDriverWait(self.driver, timeout).until(
                EC.presence_of_all_elements_located(locator)
            )
            return elements
        except TimeoutException:
            return []
    
    def click(self, locator, timeout=10):
        """Click an element"""
        element = WebDriverWait(self.driver, timeout).until(
            EC.element_to_be_clickable(locator)
        )
        element.click()
    
    def send_keys(self, locator, text, timeout=10):
        """Send keys to an element"""
        element = self.find_element(locator, timeout)
        element.clear()
        element.send_keys(text)
    
    def get_text(self, locator, timeout=10):
        """Get text from an element"""
        element = self.find_element(locator, timeout)
        return element.text
    
    def is_element_visible(self, locator, timeout=5):
        """Check if element is visible"""
        try:
            WebDriverWait(self.driver, timeout).until(
                EC.visibility_of_element_located(locator)
            )
            return True
        except TimeoutException:
            return False
    
    def is_element_present(self, locator, timeout=5):
        """Check if element is present in DOM"""
        try:
            WebDriverWait(self.driver, timeout).until(
                EC.presence_of_element_located(locator)
            )
            return True
        except TimeoutException:
            return False
    
    def wait_for_url_contains(self, text, timeout=10):
        """Wait for URL to contain specific text"""
        try:
            WebDriverWait(self.driver, timeout).until(
                EC.url_contains(text)
            )
            return True
        except TimeoutException:
            return False
    
    def get_current_url(self):
        """Get current URL"""
        return self.driver.current_url
    
    def navigate_to(self, url):
        """Navigate to a URL"""
        self.driver.get(url)
        time.sleep(1)
    
    def take_screenshot(self, name):
        """Take a screenshot"""
        screenshot_path = os.path.join(config.SCREENSHOT_DIR, f"{name}_{int(time.time())}.png")
        self.driver.save_screenshot(screenshot_path)
        return screenshot_path
    
    def get_page_title(self):
        """Get page title"""
        return self.driver.title
    
    def scroll_to_element(self, locator, timeout=10):
        """Scroll to an element"""
        element = self.find_element(locator, timeout)
        self.driver.execute_script("arguments[0].scrollIntoView(true);", element)
        time.sleep(0.5)
    
    def wait_for_element_to_disappear(self, locator, timeout=10):
        """Wait for element to disappear"""
        try:
            WebDriverWait(self.driver, timeout).until(
                EC.invisibility_of_element_located(locator)
            )
            return True
        except TimeoutException:
            return False
