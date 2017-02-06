ENV["RAILS_ENV"] = 'test'
ENV['coverage'] = 'false'

require 'rubygems'

require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'capybara/rspec'
require 'support/rspec_custom_masters'
require 'support/rspec_its'
require 'support/rspec_extensions'

Capybara::RSpecMatchers::HaveText.class_eval do
  alias_method :failure_message, :failure_message_for_should
  alias_method :failure_message_when_negated, :failure_message_for_should_not
end

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
  config.include WaitForAjax, type: :feature
  WebMock.allow_net_connect!

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explictly tag your specs with their type, e.g.:
  #
  #     describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/v/3-0/docs
  config.infer_spec_type_from_file_location!

  # Use color not only in STDOUT but also in pagers and files
  config.tty = true

  # remove support for "should" syntax, since it is deprecated. Use expect syntax instead
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.alias_it_should_behave_like_to :test_group, ''

  config.mock_with :rspec

  Capybara.default_driver = :webkit

  require 'socket'
  Capybara.default_host = "http://qa.greatschools.org"
  Capybara.app_host = "http://qa.greatschools.org"
  Capybara.server_port = 80
  Capybara.run_server = false
end

Capybara::Webkit.configure do |config|
  config.block_unknown_urls # doesnt seem to block urls in all cases
  config.block_url "http://www.google-analytics.com"
  config.block_url "https://stats.g.doubleclick.net"
  config.block_url "http://pixel.quantserve.com"
  config.block_url "http://bs.serving-sys.com"
  config.block_url "http://partner.googleadservices.com"
  config.block_url "https://www.dsply.com"
  config.block_url "http://gateway.answerscloud.com"
  config.block_url "https://www.google.com"
  config.block_url "http://staticxx.facebook.com"
  config.block_url "https://www.facebook.com"
  config.block_url "http://www.googletagmanager.com"
  config.block_url "http://csi.gstatic.com"
  config.block_url "https://securepubads.g.doubleclick.net"
  config.block_url "connect.facebook.net"
  config.block_url "maps.googleapis.com"
  config.block_url "www.googletagservices.com"
  config.block_url "tpc.googlesyndication.com"

  # Enable debug mode. Prints a log of everything the driver is doing.
  # config.debug = true

  # By default, requests to outside domains (anything besides localhost) will
  # result in a warning. Several methods allow you to change this behavior.

  # Silently return an empty 200 response for any requests to unknown URLs.
  # config.block_unknown_urls

  # Allow pages to make requests to any URL without issuing a warning.
  # config.allow_unknown_urls

  # Allow a specific domain without issuing a warning.
  # config.allow_url("example.com")

  # Allow a specific URL and path without issuing a warning.
  # config.allow_url("example.com/some/path")

  # Wildcards are allowed in URL expressions.
  config.allow_url("*.greatschools.org")

  # Silently return an empty 200 response for any requests to the given URL.
  # config.block_url("example.com")

  # Timeout if requests take longer than 5 seconds
  # config.timeout = 5

  # Don't raise errors when SSL certificates can't be validated
  # config.ignore_ssl_errors

  # Don't load images
  config.skip_image_loading

  # Use a proxy
  # config.use_proxy(
  #   host: "example.com",
  #   port: 1234,
  #   user: "proxy",
  #   pass: "secret"
  # )
end
