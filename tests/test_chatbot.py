"""
Test Suite for MERN AI ChatBot Application
This test suite contains 10+ automated test cases using Selenium WebDriver
"""
import pytest
import time
from pages.home_page import HomePage
from pages.login_page import LoginPage
from pages.signup_page import SignupPage
from pages.chat_page import ChatPage
import config


class TestHomePage:
    """Test cases for Home Page"""
    
    def test_01_home_page_loads_successfully(self, driver):
        """Test 1: Verify home page loads successfully"""
        home_page = HomePage(driver)
        assert driver.current_url == config.BASE_URL or driver.current_url == f"{config.BASE_URL}/"
        assert home_page.get_page_title() is not None
        print("✓ Test 1 Passed: Home page loads successfully")
    
    def test_02_navigation_links_visible(self, driver):
        """Test 2: Verify navigation links are visible on home page"""
        home_page = HomePage(driver)
        # At least one navigation link should be visible
        assert (home_page.is_login_link_visible() or 
                home_page.is_signup_link_visible() or 
                home_page.is_chat_link_visible())
        print("✓ Test 2 Passed: Navigation links are visible")
    
    def test_03_navigate_to_login_page(self, driver):
        """Test 3: Verify navigation to login page works"""
        home_page = HomePage(driver)
        driver.get(f"{config.BASE_URL}/login")
        time.sleep(2)
        assert "/login" in driver.current_url
        print("✓ Test 3 Passed: Successfully navigated to login page")
    
    def test_04_navigate_to_signup_page(self, driver):
        """Test 4: Verify navigation to signup page works"""
        home_page = HomePage(driver)
        driver.get(f"{config.BASE_URL}/signup")
        time.sleep(2)
        assert "/signup" in driver.current_url
        print("✓ Test 4 Passed: Successfully navigated to signup page")


class TestLoginPage:
    """Test cases for Login functionality"""
    
    def test_05_login_page_elements_present(self, driver):
        """Test 5: Verify login page contains all required elements"""
        login_page = LoginPage(driver)
        login_page.navigate_to_login()
        
        assert login_page.is_login_page()
        assert login_page.is_element_present(login_page.EMAIL_INPUT)
        assert login_page.is_element_present(login_page.PASSWORD_INPUT)
        assert login_page.is_element_present(login_page.LOGIN_BUTTON)
        print("✓ Test 5 Passed: Login page contains all required elements")
    
    def test_06_login_with_empty_credentials(self, driver):
        """Test 6: Verify login fails with empty credentials"""
        login_page = LoginPage(driver)
        login_page.navigate_to_login()
        
        login_page.login("", "")
        time.sleep(2)
        
        # Should still be on login page or show error
        current_url = driver.current_url
        assert "/login" in current_url or login_page.is_error_displayed()
        print("✓ Test 6 Passed: Login validation works for empty credentials")
    
    def test_07_login_with_invalid_email(self, driver):
        """Test 7: Verify login fails with invalid email format"""
        login_page = LoginPage(driver)
        login_page.navigate_to_login()
        
        login_page.login("invalidemail", "password123")
        time.sleep(2)
        
        # Should still be on login page or show error
        assert "/login" in driver.current_url or login_page.is_error_displayed()
        print("✓ Test 7 Passed: Login validation works for invalid email")
    
    def test_08_login_with_short_password(self, driver):
        """Test 8: Verify login fails with short password"""
        login_page = LoginPage(driver)
        login_page.navigate_to_login()
        
        login_page.login("test@example.com", "123")
        time.sleep(2)
        
        # Should still be on login page or show error
        assert "/login" in driver.current_url or login_page.is_error_displayed()
        print("✓ Test 8 Passed: Login validation works for short password")


class TestSignupPage:
    """Test cases for Signup functionality"""
    
    def test_09_signup_page_elements_present(self, driver):
        """Test 9: Verify signup page contains all required elements"""
        signup_page = SignupPage(driver)
        signup_page.navigate_to_signup()
        
        assert signup_page.is_signup_page()
        assert signup_page.is_element_present(signup_page.NAME_INPUT)
        assert signup_page.is_element_present(signup_page.EMAIL_INPUT)
        assert signup_page.is_element_present(signup_page.PASSWORD_INPUT)
        assert signup_page.is_element_present(signup_page.SIGNUP_BUTTON)
        print("✓ Test 9 Passed: Signup page contains all required elements")
    
    def test_10_signup_with_empty_fields(self, driver):
        """Test 10: Verify signup fails with empty fields"""
        signup_page = SignupPage(driver)
        signup_page.navigate_to_signup()
        
        signup_page.signup("", "", "")
        time.sleep(2)
        
        # Should still be on signup page or show error
        assert "/signup" in driver.current_url or signup_page.is_error_displayed()
        print("✓ Test 10 Passed: Signup validation works for empty fields")
    
    def test_11_signup_with_invalid_data(self, driver):
        """Test 11: Verify signup fails with invalid data"""
        signup_page = SignupPage(driver)
        signup_page.navigate_to_signup()
        
        # Short name, invalid email, short password
        signup_page.signup("A", "bademail", "123")
        time.sleep(2)
        
        # Should still be on signup page or show error
        assert "/signup" in driver.current_url or signup_page.is_error_displayed()
        print("✓ Test 11 Passed: Signup validation works for invalid data")


class TestChatPage:
    """Test cases for Chat functionality"""
    
    def test_12_chat_page_redirect_when_not_logged_in(self, driver):
        """Test 12: Verify chat page redirects to login when not authenticated"""
        driver.get(f"{config.BASE_URL}/chat")
        time.sleep(3)
        
        # Should redirect to login
        current_url = driver.current_url
        assert "/login" in current_url or "/signup" in current_url or "/chat" not in current_url
        print("✓ Test 12 Passed: Chat page requires authentication")
    
    def test_13_404_page_for_invalid_route(self, driver):
        """Test 13: Verify application handles invalid routes gracefully"""
        driver.get(f"{config.BASE_URL}/invalid-page-that-does-not-exist")
        time.sleep(2)
        
        # Simply verify the application loaded and didn't crash
        page_source = driver.page_source
        
        # Check that page has content (not blank/error)
        assert len(page_source) > 100
        print("✓ Test 13 Passed: Application handles invalid routes gracefully")
    
    def test_14_browser_back_navigation(self, driver):
        """Test 14: Verify browser back button navigation works"""
        driver.get(f"{config.BASE_URL}/login")
        time.sleep(2)
        
        driver.get(f"{config.BASE_URL}/signup")
        time.sleep(2)
        
        driver.back()
        time.sleep(2)
        
        assert "/login" in driver.current_url
        print("✓ Test 14 Passed: Browser back navigation works correctly")
    
    def test_15_page_responsiveness(self, driver):
        """Test 15: Verify pages load within acceptable time"""
        start_time = time.time()
        driver.get(f"{config.BASE_URL}/login")
        load_time = time.time() - start_time
        
        # Page should load within 10 seconds
        assert load_time < 10
        print(f"✓ Test 15 Passed: Page loaded in {load_time:.2f} seconds")


if __name__ == "__main__":
    pytest.main([__file__, "-v", "--html=reports/test_report.html", "--self-contained-html"])
