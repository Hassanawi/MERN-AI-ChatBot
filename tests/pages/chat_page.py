"""
Chat Page Object Model
"""
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from pages.base_page import BasePage
import config
import time


class ChatPage(BasePage):
    """Chat page object"""
    
    # Locators
    MESSAGE_INPUT = (By.XPATH, "//input[@type='text'] | //textarea")
    SEND_BUTTON = (By.XPATH, "//button[contains(@class, 'send') or .//svg]")
    CHAT_MESSAGES = (By.XPATH, "//*[contains(@class, 'chat') or contains(@class, 'message')]")
    USER_AVATAR = (By.XPATH, "//div[contains(@class, 'MuiAvatar')]")
    CLEAR_CHAT_BUTTON = (By.XPATH, "//button[contains(text(), 'Clear')]")
    USER_MESSAGE = (By.XPATH, "//*[contains(@class, 'user')]")
    ASSISTANT_MESSAGE = (By.XPATH, "//*[contains(@class, 'assistant')]")
    
    def __init__(self, driver):
        super().__init__(driver)
    
    def navigate_to_chat(self):
        """Navigate to chat page"""
        self.navigate_to(f"{config.BASE_URL}/chat")
    
    def enter_message(self, message):
        """Enter message in input field"""
        self.send_keys(self.MESSAGE_INPUT, message)
    
    def click_send_button(self):
        """Click send button"""
        self.click(self.SEND_BUTTON)
    
    def send_message(self, message):
        """Send a chat message"""
        self.enter_message(message)
        time.sleep(0.5)
        self.click_send_button()
        time.sleep(2)
    
    def get_all_messages(self):
        """Get all chat messages"""
        try:
            messages = self.find_elements(self.CHAT_MESSAGES, timeout=5)
            return [msg.text for msg in messages if msg.text.strip()]
        except:
            return []
    
    def get_message_count(self):
        """Get count of chat messages"""
        return len(self.get_all_messages())
    
    def is_chat_page(self):
        """Check if on chat page"""
        return "/chat" in self.get_current_url()
    
    def is_message_input_visible(self):
        """Check if message input is visible"""
        return self.is_element_visible(self.MESSAGE_INPUT)
    
    def is_send_button_visible(self):
        """Check if send button is visible"""
        return self.is_element_visible(self.SEND_BUTTON)
    
    def click_clear_chat(self):
        """Click clear chat button"""
        self.click(self.CLEAR_CHAT_BUTTON)
        time.sleep(2)
    
    def is_user_avatar_visible(self):
        """Check if user avatar is visible"""
        return self.is_element_visible(self.USER_AVATAR, timeout=3)
    
    def wait_for_response(self, timeout=15):
        """Wait for assistant response"""
        time.sleep(timeout)
        return True
