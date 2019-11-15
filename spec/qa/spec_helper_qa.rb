ENV["RAILS_ENV"] = 'test' # 'development' -- for local testing

Capybara.configure do |config|
  config.default_driver = :selenium_chrome_headless
  config.run_server = false
  config.app_host = 'https://qa.greatschools.org' # 'http://localhost:3000'
end

WebMock.allow_net_connect!(net_http_connect_on_start: true)