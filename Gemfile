source "https://rubygems.org"

gem 'rails', '4.1.1'

gem 'mysql2', '0.3.13'

gem 'jquery-rails'
gem 'jquery-cookie-rails'

group :assets do
  gem 'jquery-datatables-rails', github: 'rweng/jquery-datatables-rails'
end

gem 'rails_admin'

# We added this to rails-admin, as a way to edit json inline
gem 'codemirror-rails'

# Authentication, used for rails-admin
gem 'devise'

# Add database sharding support to Active Record
# gem 'ar-octopus', '0.6.0' <-- evil

# No Rails 4:
# gem 'db-charmer', '1.8.4', :require => 'db_charmer'
gem 'db-charmer', git: 'git://github.com/kovyrin/db-charmer.git', branch: 'rails4'

# Adds support for reserved-word column names as model attributes. Useful when writing models for legacy schemas
gem 'safe_attributes'

# paper_trail allows implementing versioning to models
gem 'paper_trail'
gem 'haml', '4.0.3'

# Hashie is a simple collection of useful Hash extensions
gem 'hashie'

# safe way to convert strings to regexps
gem 'to_regexp'

# This module provides common interface to HMAC functionality. HMAC is a kind of "Message Authentication Code" (MAC) algorithm whose standard is documented in RFC2104.
gem 'ruby-hmac', '~> 0.4.0', :require => 'hmac-sha1'

# Adds composite primary key support to ActiveRecord. Use minimally
# No Rail 4:
# gem 'composite_primary_keys'

# Adds lodash JS to the project. Version of lodash added depends on environment
gem 'lodash-rails'

# for passing vars from ruby rails to javascript
gem 'gon'

# Wiselinks gives us History.js for changing browser URLs
gem 'wiselinks'

gem 'mini_fb'

# Uses the materialized path pattern to implement a tree on a model
gem 'ancestry'

# gem to extend railsadmin with a view for working with models that are trees
gem 'rails_admin_nestable', git: 'https://github.com/gs-samson/rails_admin_nestable.git'

# Gives syntax highlighting functionality for code displayed on page
gem 'coderay'

gem 'meta-tags', :require => 'meta_tags'

# Searching using solr
gem 'rsolr'

gem 'simple_form'

# Maps controller filters to your model scopes
gem 'has_scope'

# supports decorator for models
gem 'request_store', '~> 1.0.3'
# Rails 4
gem 'draper', '~> 1.3.1'

gem 'addressable'

gem 'rack-mini-profiler', require: false
gem 'rubocop', '= 0.20.1', require: false
gem 'rubocop-checkstyle_formatter', require: false

gem 'rack_after_reply'

gem 'protected_attributes'

gem 'nokogiri', '= 1.6.1'

# SOAP client
gem 'savon', '~> 2.6.0'
# Ruby/NTLM provides message creator and parser for the NTLM authentication.
# Required by savon gem
gem 'rubyntlm', '~> 0.4.0'

gem 'prawn'
gem 'prawn-table', '~> 0.1.2'

gem 'rest_client', '1.8.1'

group :development do
  # better_errors and binding_of_caller work together as in-browser debugging tools
  # these cannot be in the test group, or a segmentation fault will occur when running tests
  gem 'better_errors', '~> 0.9.0'
  gem 'binding_of_caller', '~> 0.7.2'

  # Use the Thin server in development for speed and other improvements
  gem 'thin'

  # Guard automatically watches files for changes and re-runs bundler, rspec, etc
  gem 'guard'
  gem 'guard-bundler'
  gem 'guard-rspec', '= 4.2.9'
  gem 'guard-livereload'
  gem 'spring-commands-rspec'

  gem 'pry-debugger'
end

group :development, :test do
  # dev tool - print nicely formatted / colorful output of an object's structure. e.g. "ap my_obj"
  #gem 'awesome_print', :require => 'ap'

  # Supporting Gem for Rails Panel for Chrome
  # gem 'meta_request'

  # execute  "rails_best_practices -f html ."  on the command line to generate an html report
  # beware of false positives for things like unused methods
  gem 'rails_best_practices'

  # gem for setting up ruby objects as test data
  # gem 'factory_girl_rails', '~> 4.2.1'
  # Rails 4
  gem 'factory_girl_rails', '~> 4.4.0'

  # testing frameworks
  gem 'rspec', '~> 3.0.0.beta2'
  gem 'rspec-rails', '~> 3.0.0.beta2'
  gem 'cucumber', '~> 1.3.8'
  gem 'cucumber-rails', '~> 1.4.0', :require => false

  # Use haml for template engine. Also specified in application.rb
  gem 'haml-rails'

  # DSL for page object pattern, used for cucumber testing
  gem 'site_prism'

  gem 'database_cleaner'
  gem 'selenium-webdriver'
  gem 'mechanize'
  gem 'capybara'
  gem 'capybara-webkit'
  gem 'capybara-mechanize'
  gem 'machinist', '>= 2.0.0.beta2'
  gem 'timecop'

  gem 'konacha'

  # JS testing framework add-on for stubbing
  gem 'sinon-rails'

  # JS testing runner
  gem 'teaspoon'

  # Test coverage tool
  gem 'simplecov', '~> 0.8.0'
  gem 'simplecov-html', '~> 0.8.0'
  gem 'simplecov-rcov'

  gem 'childprocess'

  # Allows Ruby to communicate with growl, for system messaging. e.g. you can pop up an alert when your tests fail
  gem 'ruby_gntp'

  # Turn off assets logging in development
  gem 'quiet_assets'
  gem 'debugger'

  gem 'yard'

  gem 'launchy'

  gem 'pdf-reader'

  gem 'sourcify'
end

# gem 'sass-rails',   '~> 3.2.3'
# Rails 4
gem 'sass-rails',   '~> 4.0.1'

# gem 'coffee-rails', '~> 3.2.1'
# Rails 4
gem 'coffee-rails', '~> 4.0.1'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', :platforms => :ruby

#gem 'compass-rails', '~> 2.0.alpha.0'
gem 'uglifier', '>= 1.0.3'
gem 'bootstrap-wysihtml5-rails'

# gem 'css_splitter', '~> 0.1.1'
# Rails 4
gem 'css_splitter'

gem "yui-compressor", "~> 0.12.0"

group :profile do
  gem 'ruby-prof'
end


