module CookieHelper
  def set_cookie(name, value)
    host = Capybara.app_host ? URI(Capybara.app_host).host : '127.0.0.1'
    if page.driver.class.name == 'Capybara::Selenium::Driver'
      cookie_settable = Capybara.current_session.driver.browser
      cookie_settable.manage.add_cookie({name: name, value: value })
    else
      cookie_settable = page.driver.browser
      cookie_settable.set_cookie("#{name}=#{value}; domain=#{host}")
    end
  end

  def clear_cookies
    if page.driver.class.name == 'Capybara::Selenium::Driver'
      cookie_settable = page.driver.browser
      cookie_settable.manage.delete_all_cookies
    else
      cookie_settable = page.driver.browser
      cookie_settable.clear_cookies
    end
  end
end
