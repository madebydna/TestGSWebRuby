ENV["RAILS_ENV"] = 'test'
ENV['coverage'] = 'false' unless ENV.has_key?('coverage')


require 'rubygems'
require 'capybara-screenshot/rspec'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'capybara/rspec'
require 'factory_bot' unless ENV['BLACK_BOX']
require 'support/factory_bot_extensions'
require 'support/rspec_custom_masters'
require 'support/rspec_its'
require 'support/rspec_extensions'
require 'webmock/rspec' unless ENV['BLACK_BOX']
require 'pp'
$LOAD_PATH.unshift File.expand_path('../../script', __FILE__)

if ENV['JENKINS_URL'] # on ci server
  require 'simplecov'
  require 'simplecov-rcov'
  SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
elsif ENV['coverage'] == 'true'
  require 'simplecov'
  require 'simplecov-html'
  SimpleCov.formatter = SimpleCov::Formatter::HTMLFormatter
end

if ENV['JENKINS_URL'] || ENV['coverage'] == 'true'
  SimpleCov.start 'rails' do
    add_group 'Changed' do |source_file|
      `git ls-files --exclude-standard --others \
        && git diff --name-only \
        && git diff --name-only --cached`.split("\n").detect do |filename|
        source_file.filename.ends_with?(filename)
      end
    end
    add_filter '/spec/'
    add_filter '/config/'
    add_filter 'lib/test_connection_management.rb'
  end
end

def disconnect_connection_pools(db)
  ActiveRecord::Base.connection_handler.connection_pool_list.each do |pool|
    if pool.connections.present? &&
      ( pool.connections.first.
        current_database == "#{db}_test" )
      pool.disconnect!
    end
  end
end

def disconnect_all_connection_pools
  ActiveRecord::Base.connection_handler.connection_pool_list.each do |pool|
    pool.disconnect!
  end
end

# If you change this you'll also need to change the value in test.rb
# Rails.application.routes.default_url_options[:host] = 'test.host'
Rails.application.routes.default_url_options[:host] = 'localhost' unless ENV['BLACK_BOX']
Rails.application.routes.default_url_options[:trailing_slash] = true unless ENV['BLACK_BOX']

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  config.backtrace_exclusion_patterns = [
    /\/lib\d*\/ruby\//,
    /org\/jruby\//,
    /bin\//,
    /lib\/rspec\/(core|expectations|matchers|mocks)/,
    /gems/
  ]
  config.include Capybara::DSL
  config.include Rails.application.routes.url_helpers
  config.include UrlHelper
  config.include FactoryBot::Syntax::Methods unless ENV['BLACK_BOX']
  config.include WaitForAjax, type: :feature
  config.include CookieHelper
  config.include SigninHelper
  config.include InspectRequests, type: :feature

  config.order = "random" # you can specify order with --seed flag
  config.infer_spec_type_from_file_location!
  config.expect_with(:rspec) { |c| c.syntax = :expect } # use 'expect' instead of 'should'
  config.alias_it_should_behave_like_to :test_group, ''


  if ENV['BLACK_BOX']
    WebMock.allow_net_connect!
  else
    WebMock.disable_net_connect!(
      allow_localhost: true,
      allow: 'chromedriver.storage.googleapis.com')

    config.mock_with :rspec

    config.around(:each, :caching) do |example|
      example.run
      Rails.cache.clear
    end
    config.before(:each) { Rails.cache.clear }
    config.after(:each) do
      Rails.cache.clear
      Gon.clear
    end

    config.append_after(:each) do
      clean_chosen_models
      clean_chosen_dbs
      disconnect_all_connection_pools
    end
  end


  if ENV['BLACK_BOX']
    Capybara.default_driver = :selenium_chrome_headless
    Capybara.run_server = false
  else
    Capybara.default_driver = :rack_test
    Capybara.run_server = true
  end
  Capybara.javascript_driver = :selenium_chrome_headless
  Capybara.server = :webrick
  
  port = ENV['CAPYBARA_PORT'] || 3001
  Capybara.app_host = ENV['CAPYBARA_HOST'] || "http://localhost:#{port}"
  Capybara.server_port = port
  ENV_GLOBAL['app_host'] = 'localhost'
  ENV_GLOBAL['app_port'] = '3001'

  config.filter_run_when_matching focus: true
  config.filter_run_excluding broken: true

  OmniAuth.config.test_mode = true

  OmniAuth.config.add_mock(:google, {
    provider: 'google',
    uid: '123545',
    info: {
      email: 'admin@greatschools.org',
      first_name: 'Joe',
      last_name: 'Mack'
    }
  })

  # Capybara::Webkit.configure do |config|
  #   # config.debug = true
  #   config.block_unknown_urls # doesnt seem to block urls in all cases
  #   config.block_url "http://www.google-analytics.com"
  #   config.block_url "https://stats.g.doubleclick.net"
  #   config.block_url "http://pixel.quantserve.com"
  #   config.block_url "http://bs.serving-sys.com"
  #   config.block_url "http://partner.googleadservices.com"
  #   config.block_url "https://www.dsply.com"
  #   config.block_url "http://gateway.answerscloud.com"
  #   config.block_url "https://www.google.com"
  #   config.block_url "http://staticxx.facebook.com"
  #   config.block_url "https://www.facebook.com"
  #   config.block_url "http://www.googletagmanager.com"
  #   config.block_url "http://csi.gstatic.com"
  #   config.block_url "https://securepubads.g.doubleclick.net"
  #   config.block_url "connect.facebook.net"
  #   config.block_url "maps.googleapis.com"
  #   config.block_url "www.googletagservices.com"
  #   config.block_url "tpc.googlesyndication.com"

  #   config.allow_url "https://www.facebook.com"
  #   config.allow_url("*.greatschools.org")

  #   config.skip_image_loading
  # end
end
