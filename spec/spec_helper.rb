ENV["RAILS_ENV"] = 'test'
ENV['coverage'] = 'false' unless ENV.has_key?('coverage')

require 'rubygems'

require 'capybara-screenshot/rspec'
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

require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'database_cleaner'
require 'support/database_cleaner_extensions'
require 'capybara/rspec'
require 'factory_girl'
require 'support/factory_girl_extensions'
require 'support/rspec_custom_masters'
require 'support/rspec_its'
require 'support/rspec_extensions'
require 'webmock/rspec'
$LOAD_PATH.unshift File.expand_path('../../script', __FILE__)
# require 'rspec_profiler'

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

Capybara::RSpecMatchers::HaveText.class_eval do
  alias_method :failure_message, :failure_message_for_should
  alias_method :failure_message_when_negated, :failure_message_for_should_not
end

# If you change this you'll also need to change the value in test.rb
# Rails.application.routes.default_url_options[:host] = 'test.host'
Rails.application.routes.default_url_options[:host] = 'localhost'
Rails.application.routes.default_url_options[:trailing_slash] = true

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

Capybara::Webkit.configure do |config|
  # config.debug = true
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
end

RSpec.configure do |config|
  # Ensure that if we are running js tests, we are using latest webpack assets
  # This will use the defaults of :js and :server_rendering meta tags
  # ReactOnRails::TestHelper.configure_rspec_to_compile_assets(config)

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
  config.include FactoryGirl::Syntax::Methods
  config.include WaitForAjax, type: :feature
  config.include CookieHelper
  WebMock.disable_net_connect!(allow_localhost: true)

  # config.reporter.register_listener RSpecProfiler.new, :start, :example_started, :example_passed, :example_failed

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false


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

  config.around(:each, :caching) do |example|
    # caching = ActionController::Base.perform_caching
    # ActionController::Base.perform_caching = example.metadata[:caching]
    example.run
    Rails.cache.clear
    # ActionController::Base.perform_caching = caching
  end

  config.before(:each) { Rails.cache.clear }
  config.after(:each) do
    Rails.cache.clear
    Gon.clear
    disconnect_all_connection_pools
  end

  # config.raise_errors_for_deprecations!


    # use capybara-webkit
  unless ENV['SELENIUM']
    Capybara.javascript_driver = :webkit
  end

  require 'socket'
  ip_address = '127.0.0.1'
  # Capybara.default_host = "http://test.host:3000"
  # Capybara.app_host = "http://test.host:3000"
  Capybara.default_host = "http://localhost:3001"
  Capybara.app_host = "http://localhost:3001"
  Capybara.server_port = 3001
  Capybara.run_server = true
  ENV_GLOBAL['app_host'] = 'localhost'
  ENV_GLOBAL['gsweb_host'] = 'localhost'
  ENV_GLOBAL['app_port'] = '3001'
  ENV_GLOBAL['gsweb_port'] = '3001'

  DatabaseCleaner.strategy = :truncation
  # This needs to be done after we've loaded an ActiveRecord strategy above
  monkey_patch_database_cleaner
  YAML::ENGINE.yamler = 'syck'

end
