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

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}
Dir[Rails.root.join("spec/controllers/concerns/**/*.rb")].each {|f| require f}

RSpec.configure do |config|

  config.include Rails.application.routes.url_helpers
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

  # Use color in STDOUT
  config.color_enabled = true

  # Use color not only in STDOUT but also in pagers and files
  config.tty = true

  # remove support for "should" syntax, since it is deprecated. Use expect syntax instead
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.mock_with :rspec

    # use capybara-webkit
  Capybara.javascript_driver = :webkit

  Capybara.default_host = 'http://localhost:3000'

  DatabaseCleaner.strategy = :truncation
  # This needs to be done after we've loaded an ActiveRecord strategy above
  monkey_patch_database_cleaner
end
