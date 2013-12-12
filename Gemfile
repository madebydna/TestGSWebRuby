source "https://rubygems.org"

gem 'rails', '3.2.11'

gem 'mysql2', '0.3.13'

# Use jquery as the JavaScript library
gem 'jquery-rails'

gem 'rails_admin'

# We added this to rails-admin, as a way to edit json inline
gem 'codemirror-rails'

# REVIEW: are we still using this? remove if not
gem 'ckeditor'

# Authentication, used for rails-admin
gem 'devise'

# Add database sharding support to Active Record
# gem 'ar-octopus', '0.6.0' <-- evil
gem 'db-charmer', '1.8.4', :require => 'db_charmer'

# Adds support for reserved-word column names as model attributes. Useful when writing models for legacy schemas
gem 'safe_attributes'

# paper_trail allows implementing versioning to models
gem 'paper_trail'
gem 'haml', '4.0.3'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# DSL or building JSON objects. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'

# Hashie is a simple collection of useful Hash extensions
gem 'hashie'

# safe way to convert strings to regexps
gem 'to_regexp'

# This module provides common interface to HMAC functionality. HMAC is a kind of "Message Authentication Code" (MAC) algorithm whose standard is documented in RFC2104.
gem 'ruby-hmac', '~> 0.4.0', :require => 'hmac-sha1'

# Adds composite primary key support to ActiveRecord. Use minimally
gem 'composite_primary_keys'

# Adds lodash JS to the project. Version of lodash added depends on environment
gem 'lodash-rails'

# for passing vars from ruby rails to javascript
gem 'gon'
gem 'rabl-rails'

gem 'mini_fb'

#gem 'parsley-rails', '~> 1.2.2.0'

group :development do
  # better_errors and binding_of_caller work together as in-browser debugging tools
  # these cannot be in the test group, or a segmentation fault will occur when running tests
  gem 'better_errors', '~> 0.9.0'
  gem 'binding_of_caller', '~> 0.7.2'
end

group :development, :test do
  # dev tool - print nicely formatted / colorful output of an object's structure. e.g. "ap my_obj"
  gem 'awesome_print', :require => 'ap'

  # Supporting Gem for Rails Panel for Chrome
  # gem 'meta_request'

  # execute  "rails_best_practices -f html ."  on the command line to generate an html report
  # beware of false positives for things like unused methods
  gem 'rails_best_practices'

  # gem for setting up ruby objects as test data
  gem 'factory_girl_rails', '~> 4.2.1'

  # testing frameworks
  gem 'rspec'
  gem 'rspec-rails'
  gem 'cucumber', '~> 1.3.8'
  gem 'cucumber-rails', '~> 1.4.0', :require => false
  gem 'capybara'

  # Use haml for template engine. Also specified in application.rb
  gem 'haml-rails'

  # DSL for page object pattern, used for cucumber testing
  gem 'site_prism'

  gem 'database_cleaner'
  gem 'selenium-webdriver'
  gem 'mechanize'
  gem 'capybara'
  gem 'capybara-mechanize'
  gem 'machinist', '>= 2.0.0.beta2'

  # JS testing framework
  gem 'mocha_rails'
  # JS testing framework add-on for stubbing
  gem 'sinon-rails'

  # Test coverage tool
  gem 'simplecov', '~> 0.8.2'
  gem 'simplecov-html', '~> 0.8.0'


  # Guard and Spork for faster rspec testing
  gem 'spork-rails', '~> 4.0.0'
  gem 'guard'
  gem 'guard-bundler'
  gem 'guard-rspec'
  gem 'guard-spork'
  gem 'guard-livereload'
  gem 'childprocess'

  gem 'ruby_gntp'
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  #gem 'compass-rails', '~> 2.0.alpha.0'
  gem 'uglifier', '>= 1.0.3'
  gem 'bootstrap-wysihtml5-rails'
  gem 'css_splitter', '~> 0.1.1'
  gem "yui-compressor", "~> 0.12.0"
end

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'debugger'

