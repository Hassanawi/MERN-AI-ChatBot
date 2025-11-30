"""
Home Page Object Model
"""
from selenium.webdriver.common.by import By
from pages.base_page import BasePage
import config


class HomePage(BasePage):
    """Home page object"""
    
    # Locators
    LOGO = (By.XPATH, "//img[contains(@alt, 'logo') or contains(@src, 'logo')]")
    LOGIN_LINK = (By.XPATH, "//a[@href='/login' or contains(text(), 'Login')]")
    SIGNUP_LINK = (By.XPATH, "//a[@href='/signup' or contains(text(), 'Signup')]")
    CHAT_LINK = (By.XPATH, "//a[@href='/chat' or contains(text(), 'Chat')]")
    HEADER = (By.TAG_NAME, "header")
    MAIN_CONTENT = (By.TAG_NAME, "main")
    
    def __init__(self, driver):
        super().__init__(driver)
        self.navigate_to(config.BASE_URL)
    
    def click_login(self):
        """Click on login link"""
        self.click(self.LOGIN_LINK)
    
    def click_signup(self):
        """Click on signup link"""
        self.click(self.SIGNUP_LINK)
    
    def click_chat(self):
        """Click on chat link"""
        self.click(self.CHAT_LINK)
    
    def is_logo_visible(self):
        """Check if logo is visible"""
        return self.is_element_visible(self.LOGO)
    
    def is_login_link_visible(self):
        """Check if login link is visible"""
        return self.is_element_visible(self.LOGIN_LINK, timeout=3)
    
    def is_signup_link_visible(self):
        """Check if signup link is visible"""
        return self.is_element_visible(self.SIGNUP_LINK, timeout=3)
    
    def is_chat_link_visible(self):
        """Check if chat link is visible"""
        return self.is_element_visible(self.CHAT_LINK, timeout=3)
    
    def get_header_text(self):
        """Get header text"""
        try:
            return self.get_text(self.HEADER)
        except:
            return ""
