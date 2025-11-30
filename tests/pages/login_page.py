"""
Login Page Object Model
"""
from selenium.webdriver.common.by import By
from pages.base_page import BasePage
import config
import time


class LoginPage(BasePage):
    """Login page object"""
    
    # Locators
    EMAIL_INPUT = (By.NAME, "email")
    PASSWORD_INPUT = (By.NAME, "password")
    LOGIN_BUTTON = (By.XPATH, "//button[contains(text(), 'Login') or @type='submit']")
    LOGIN_HEADING = (By.XPATH, "//h4[contains(text(), 'Login')] | //h1[contains(text(), 'Login')]")
    ERROR_MESSAGE = (By.XPATH, "//*[contains(@class, 'error') or contains(@class, 'alert')]")
    
    def __init__(self, driver):
        super().__init__(driver)
    
    def navigate_to_login(self):
        """Navigate to login page"""
        self.navigate_to(f"{config.BASE_URL}/login")
    
    def enter_email(self, email):
        """Enter email"""
        self.send_keys(self.EMAIL_INPUT, email)
    
    def enter_password(self, password):
        """Enter password"""
        self.send_keys(self.PASSWORD_INPUT, password)
    
    def click_login_button(self):
        """Click login button"""
        self.click(self.LOGIN_BUTTON)
    
    def login(self, email, password):
        """Perform login"""
        self.enter_email(email)
        time.sleep(0.5)
        self.enter_password(password)
        time.sleep(0.5)
        self.click_login_button()
        time.sleep(2)
    
    def is_login_page(self):
        """Check if on login page"""
        return self.is_element_visible(self.LOGIN_HEADING) or "/login" in self.get_current_url()
    
    def get_error_message(self):
        """Get error message if present"""
        try:
            return self.get_text(self.ERROR_MESSAGE, timeout=3)
        except:
            return None
    
    def is_error_displayed(self):
        """Check if error is displayed"""
        return self.is_element_visible(self.ERROR_MESSAGE, timeout=3)
