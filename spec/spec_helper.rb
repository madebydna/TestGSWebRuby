require 'spork'
require 'rubygems'

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
    add_filter '/config/'
    add_filter 'lib/test_connection_management.rb'
  end
  # This file is copied to spec/ when you run 'rails generate rspec:install'
  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'
  require 'rspec/autorun'
  require 'database_cleaner'
  require 'spec_for_model_with_custom_connection'
  require 'capybara/rspec'

  # use capybara-webkit
  Capybara.javascript_driver = :webkit

  Capybara.default_host = 'http://localhost:3000'

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

    # Use the specified formatter
    config.formatter = :documentation # :progress, :html, :textmate

    # remove support for "should" syntax, since it is deprecated. Use expect syntax instead
    config.expect_with :rspec do |c|
      c.syntax = :expect
    end

    config.mock_with :rspec

    DatabaseCleaner.strategy = :truncation

    config.before(:suite) do
      DatabaseCleaner.clean_with(:truncation)
    end

    config.before(:each) do
      DatabaseCleaner.start
    end

    config.after :each do
      DatabaseCleaner.clean
    end

    config.after(:suite) do
      DatabaseCleaner.clean_with(:truncation)
    end

  end
end

# This code will be run each time you run your specs.
Spork.each_run do
  puts 'RELOADING'
  load "#{Rails.root}/config/routes.rb"
  Dir["#{Rails.root}/app/**/*.rb"].each {|f| load f}
  Dir["#{Rails.root}/lib/**/*.rb"].each {|f| load f}

  FactoryGirl.reload
end
