ENV["RAILS_ENV"] = 'test'

require 'rubygems'

require 'simplecov'
if ENV['JENKINS_URL'] # on ci server
  require 'simplecov-rcov'
  SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
elsif ENV['coverage']
  require 'simplecov-html'
  SimpleCov.formatter = SimpleCov::Formatter::HTMLFormatter
end

if ENV['JENKINS_URL'] || ENV['coverage']
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
require 'capybara/rspec'
require 'factory_girl'


def monkey_patch_database_cleaner
  DatabaseCleaner::ActiveRecord::Base.module_eval do
    # For some reason, by default database_cleaner will re-load the database.yml file, but we modify
    # Rails' db configuration after database.yml is loaded by the Rails environment.
    #
    # Instead of letting database_cleaner reload database.yml, just tell it to use the config that is already loaded
    def load_config
      if self.db != :default && self.db.is_a?(Symbol)
        @connection_hash = ::ActiveRecord::Base.configurations['test'][self.db.to_s]
      end
    end
  end
end

# Takes as arguments as list of db names as symbols
def clean_dbs(*args)
  args.each do |db|
    DatabaseCleaner[:active_record, connection: "#{db}_rw".to_sym].strategy = :truncation
    DatabaseCleaner[:active_record, connection: "#{db}_rw".to_sym].clean
  end
end

def clean_models(db, *models)
  unless db.is_a? Symbol
    models = [ db ] + models
    db = nil
  end

  models.each do |model|
    if db
      model.on_db(db).destroy_all
    else
      model.destroy_all
    end
  end
end


Capybara::RSpecMatchers::HaveText.class_eval do
  alias_method :failure_message, :failure_message_for_should
  alias_method :failure_message_when_negated, :failure_message_for_should_not
end

# If you change this you'll also need to change the value in test.rb
Rails.application.routes.default_url_options[:host] = 'test.host'
Rails.application.routes.default_url_options[:trailing_slash] = true

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}
Dir[Rails.root.join("spec/controllers/concerns/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  config.include Capybara::DSL

  config.include Rails.application.routes.url_helpers
  config.include UrlHelper
  config.include FactoryGirl::Syntax::Methods

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

  config.mock_with :rspec

  config.around(:each, :caching) do |example|
    # caching = ActionController::Base.perform_caching
    # ActionController::Base.perform_caching = example.metadata[:caching]
    example.run
    Rails.cache.clear
    # ActionController::Base.perform_caching = caching
  end

  config.before(:each) { Rails.cache.clear }
  config.after(:each) { Rails.cache.clear }

  config.raise_errors_for_deprecations!

    # use capybara-webkit
  Capybara.javascript_driver = :webkit

  require 'socket'
  ip_address = IPSocket.getaddress(Socket.gethostname)
  Capybara.default_host = "http://#{ip_address}:3000"

  DatabaseCleaner.strategy = :truncation
  # This needs to be done after we've loaded an ActiveRecord strategy above
  monkey_patch_database_cleaner
end
