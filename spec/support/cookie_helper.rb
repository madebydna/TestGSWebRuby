module CookieHelper
  def set_cookie(name, value)
    host = Capybara.app_host ? URI(Capybara.app_host).host : '127.0.0.1'
    if page.driver.class.name == 'Capybara::Webkit::Driver'
      cookie_settable = page.driver
    else
      cookie_settable = page.driver.browser
    end
    cookie_settable.set_cookie("#{name}=#{value}; domain=#{host}")
  end

  def clear_cookies
    if page.driver.class.name == 'Capybara::Webkit::Driver'
      cookie_settable = page.driver
    else
      cookie_settable = page.driver.browser
    end
    cookie_settable.clear_cookies
  end
end
