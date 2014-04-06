
require 'spork'
require 'rubygems'

def monkey_patch_database_cleaner
  DatabaseCleaner::ActiveRecord::Base.module_eval do
    # For some reason, by default database_cleaner will re-load the database.yml file, but we modify
    # Rails' db configuration after database.yml is loaded by the Rails environment.
    #
    # Instead of letting database_cleaner reload database.yml, just tell it to use the config that is already loaded
    def load_config
      if self.db != :default && self.db.is_a?(Symbol)
        @connection_hash   = ::ActiveRecord::Base.configurations['test'][self.db.to_s]
      end
    end
  end
end

Spork.prefork do
  require 'simplecov'

  if ENV['JENKINS_URL'] # on ci server
    require 'simplecov-rcov'
    SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
  else
    require 'simplecov-html'
    SimpleCov::Formatter::HTMLFormatter
  end

  SimpleCov.start do
    add_filter '/spec/'
    add_filter 'config/initializers/rails_admin.rb'
    add_filter 'lib/test_connection_management.rb'
  end
  # This file is copied to spec/ when you run 'rails generate rspec:install'
  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'
  require 'rspec/autorun'
  require 'database_cleaner'

  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

  Dir[Rails.root.join("spec/controllers/concerns/**/*.rb")].each {|f| require f}

  RSpec.configure do |config|

    config.include Rails.application.routes.url_helpers

    # ## Mock Framework
    #
    # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
    #
    # config.mock_with :mocha
    # config.mock_with :flexmock
    # config.mock_with :rr

    # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
    config.fixture_path = "#{::Rails.root}/spec/fixtures"

    # If you're not using ActiveRecord, or you'd prefer not to run each of your
    # examples within a transaction, remove the following line or assign false
    # instead of true.
    config.use_transactional_fixtures = true

    # If true, the base class of anonymous controllers will be inferred
    # automatically. This will be the default behavior in future versions of
    # rspec-rails.
    config.infer_base_class_for_anonymous_controllers = false

    # Run specs in random order to surface order dependencies. If you find an
    # order dependency and want to debug it, you can fix the order by providing
    # the seed, which is printed after each run.
    #     --seed 1234
    config.order = "random"

    # Use color in STDOUT
    config.color_enabled = true

    # Use color not only in STDOUT but also in pagers and files
    config.tty = true

    # Use the specified formatter
    config.formatter = :documentation # :progress, :html, :textmate

    # remove support for "should" syntax, since it is deprecated. Use expect syntax instead
    config.expect_with :rspec do |c|
      c.syntax = :expect
    end

    DatabaseCleaner.strategy = :truncation
    # This needs to be done after we've loaded an ActiveRecord strategy above
    monkey_patch_database_cleaner

    config.before(:suite) do
      # Before we run our specs, truncate every test db
      DatabaseConfigurationHelper.all_rw_connections_for('test').each do |connection|
        puts "Cleaning #{connection} db"
        DatabaseCleaner[:active_record, connection: connection.to_sym].strategy = :truncation
        DatabaseCleaner[:active_record, connection: connection.to_sym].clean
      end
    end

  end
end

Spork.each_run do
  puts 'RELOADING'
  load "#{Rails.root}/config/routes.rb"
  Dir["#{Rails.root}/app/**/*.rb"].each {|f| load f}
  Dir["#{Rails.root}/lib/**/*.rb"].each {|f| load f}

  # This code will be run each time you run your specs.
  RSpec.configure do |config|
    config.mock_with :rspec

    config.use_transactional_fixtures = true
  end

  FactoryGirl.reload
end

# Takes as arguments as list of db names as symbols
def clean_dbs(*args)
  args.each do |db|
    DatabaseCleaner[:active_record, connection: db].strategy = :truncation
    DatabaseCleaner[:active_record, connection: db].clean
  end
end