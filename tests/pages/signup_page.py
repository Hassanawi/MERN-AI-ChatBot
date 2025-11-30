"""
Signup Page Object Model
"""
from selenium.webdriver.common.by import By
from pages.base_page import BasePage
import config
import time


class SignupPage(BasePage):
    """Signup page object"""
    
    # Locators
    NAME_INPUT = (By.NAME, "name")
    EMAIL_INPUT = (By.NAME, "email")
    PASSWORD_INPUT = (By.NAME, "password")
    SIGNUP_BUTTON = (By.XPATH, "//button[contains(text(), 'Signup') or @type='submit']")
    SIGNUP_HEADING = (By.XPATH, "//h4[contains(text(), 'Signup')] | //h1[contains(text(), 'Signup')]")
    ERROR_MESSAGE = (By.XPATH, "//*[contains(@class, 'error') or contains(@class, 'alert')]")
    SUCCESS_MESSAGE = (By.XPATH, "//*[contains(@class, 'success')]")
    
    def __init__(self, driver):
        super().__init__(driver)
    
    def navigate_to_signup(self):
        """Navigate to signup page"""
        self.navigate_to(f"{config.BASE_URL}/signup")
    
    def enter_name(self, name):
        """Enter name"""
        self.send_keys(self.NAME_INPUT, name)
    
    def enter_email(self, email):
        """Enter email"""
        self.send_keys(self.EMAIL_INPUT, email)
    
    def enter_password(self, password):
        """Enter password"""
        self.send_keys(self.PASSWORD_INPUT, password)
    
    def click_signup_button(self):
        """Click signup button"""
        self.click(self.SIGNUP_BUTTON)
    
    def signup(self, name, email, password):
        """Perform signup"""
        self.enter_name(name)
        time.sleep(0.5)
        self.enter_email(email)
        time.sleep(0.5)
        self.enter_password(password)
        time.sleep(0.5)
        self.click_signup_button()
        time.sleep(2)
    
    def is_signup_page(self):
        """Check if on signup page"""
        return self.is_element_visible(self.SIGNUP_HEADING) or "/signup" in self.get_current_url()
    
    def get_error_message(self):
        """Get error message if present"""
        try:
            return self.get_text(self.ERROR_MESSAGE, timeout=3)
        except:
            return None
    
    def is_error_displayed(self):
        """Check if error is displayed"""
        return self.is_element_visible(self.ERROR_MESSAGE, timeout=3)
