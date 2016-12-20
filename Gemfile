source "https://rubygems.org"

gem 'rails', '4.2.7'

gem 'mysql2', '0.3.13'

# This gem provides jQuery and the jQuery-ujs driver for your Rails 3+ application.
gem 'jquery-rails'
# This gem provides jquery-cookie.js assets for your Rails 3 application.
# This has been deprecated in favor of js-cookie
# USED: many places. Search for $.cookie
gem 'jquery-cookie-rails'
# This gem packages the jQuery DataTables plugin for easy use with the Rails 3.1+ asset pipleine.
# It provides all the basic DataTables files, and a few of the extras.
# USED: reviews_moderation_init.js
gem 'jquery-datatables-rails', github: 'rweng/jquery-datatables-rails'

# RailsAdmin is a Rails engine that provides an easy-to-use interface for managing your data.
# USED: in profile admin. See config in config/initializers/rails_admin.rb
gem 'rails_admin'

# We added this to rails-admin, as a way to edit json inline
gem 'codemirror-rails'

# Authentication, used for rails-admin
gem 'devise', '4.2.0'

# Provide various react builds to your asset bundle
# Transform .jsx in the asset pipeline
gem 'react_on_rails', '~> 6'

# Add database sharding support to Active Record
# gem 'ar-octopus', '0.6.0' <-- evil

# No Rails 4:
# gem 'db-charmer', '1.8.4', :require => 'db_charmer'
gem 'db-charmer', git: 'git://github.com/kovyrin/db-charmer.git', branch: 'rails4'

# Adds support for reserved-word column names as model attributes. Useful when writing models for legacy schemas
# This automatically supplements ActiveRecord::Base and "protects" any columns that conflict with default AR methods
# TODO: to decide if we need this, we would have to examine the column names for all ActiveRecord models
gem 'safe_attributes'

# allows use of .haml (see _form.html.haml)
# USED: rails admin
gem 'haml', '4.0.3'

# Hashie is a simple collection of useful Hash extensions
# USED: primarily Hashie::Mash all over the place.
gem 'hashie'

# This module provides common interface to HMAC functionality. HMAC is a kind of "Message Authentication Code" (MAC) algorithm whose standard is documented in RFC2104.
# USED: By Google static maps api. See GoogleSignedImages::sign_url
# TODO: Switch to OpenSSL::HMAC (See http://blog.nathanielbibler.com/post/63031273/opensslhmac-vs-ruby-hmac-benchmarks)
gem 'ruby-hmac', '~> 0.4.0', :require => 'hmac-sha1'

# Adds composite primary key support to ActiveRecord. Use minimally
# No Rail 4:
# gem 'composite_primary_keys'

# Adds lodash JS to the project. Version of lodash added depends on environment
gem 'lodash-rails'

# for passing vars from ruby rails to javascript
gem 'gon'

# Wiselinks gives us History.js for changing browser URLs
# USED: In deprecated_post_load.js
# TODO: If this is just for History.js, let's just use that library and drop the gem
gem 'wiselinks'

# USED: In FB authentication. See SigninController or related
gem 'mini_fb'

# Uses the materialized path pattern to implement a tree on a model
# USED: CategoryPlacement model in profile admin
gem 'ancestry'

# gem to extend railsadmin with a view for working with models that are trees
# USED: for profile admin. See config/initializers/rails_admin.rb
gem 'rails_admin_nestable', git: 'https://github.com/gs-samson/rails_admin_nestable.git'

# Gives syntax highlighting functionality for code displayed on page
# USED: under views/admin/admin
gem 'coderay'

# SEO plugin for Ruby on Rails applications.
# USED: all over the place. Search for set_meta_tags
gem 'meta-tags', :require => 'meta_tags'

# Searching using solr
# USED: See solr.rb
gem 'rsolr'

# Forms made easy for Rails!
# USED: in lib/templates/haml/scaffold/_form.html.haml
# TODO: Is this really used? Can we drop it?
gem 'simple_form'

# Maps controller filters to your model scopes
# USED: controllers/admin/reviews_controller and schools_controller
gem 'has_scope'

# Per-request global storage for Rack.
# USED: lib/school_profiles/AdsSwitch
# TODO: Can we do this a different way and remove this gem?
gem 'request_store', '~> 1.0.3'

# Rails 4
# Decorators/View-Models for Rails Applications
# USED: everywhere. See app/decorators for many examples
gem 'draper', '~> 1.3.1'

# Addressable is a replacement for the URI implementation that is part of Ruby's standard library.
# It more closely conforms to RFC 3986, RFC 3987, and RFC 6570 (level 4)
# USED: in application_controller, url_helper, user_mailer
gem 'addressable'

# Protect attributes from mass-assignment in ActiveRecord models.
# USED: All over. Search for attr_accessible
gem 'protected_attributes'

# Nokogiri is an HTML, XML, SAX, and Reader parser.
# USED: Only by script/feeds/feed_scripts/validate_feed_files as far as I can tell
# This was added back in the early days though
# TODO: Verify not used outside of development environment and move there
gem 'nokogiri', '= 1.6.7'

# SOAP client
# USED: To communicate with ExactTarget. See exact_target.rb
gem 'savon', '~> 2.6.0'

# Ruby/NTLM provides message creator and parser for the NTLM authentication.
# Required by savon gem
gem 'rubyntlm', '~> 0.4.0'

# Prawn is a fast, tiny, and nimble PDF generator for Ruby
# USED: By PYOC (see pyoc_controller and pyoc_pdf)
# TODO: Kill PYOC and remove gems
gem 'prawn'
gem 'prawn-table', '~> 0.1.2'

# A simple HTTP and REST client for Ruby
# USED: In PhotoUploadConcerns (OSP)
gem 'rest_client', '1.8.1'

# Retrieve the binding of a method's caller.
# USED: By GsLogger
gem 'binding_of_caller', '~> 0.7.2'

# Create JSON structures via a Builder-style DSL
# USED: Multiple places. Search for *.jbuilder for example
gem 'jbuilder'

group :development do
  # better_errors and binding_of_caller work together as in-browser debugging tools
  # these cannot be in the test group, or a segmentation fault will occur when running tests
  # https://github.com/banister/binding_of_caller/issues/14
  gem 'better_errors', '~> 0.9.0'
  #gem 'binding_of_caller', '~> 0.7.2' #moved up into production. AT-873 GSLogger code

  # Use the Thin server in development for speed and other improvements
  gem 'thin'

  # Guard automatically watches files for changes and re-runs bundler, rspec, etc
  gem 'guard'
  gem 'guard-bundler'
  gem 'guard-rspec', '= 4.2.9'
  gem 'guard-livereload'
  gem 'spring-commands-rspec'
  gem 'byebug'

  # Profiling toolkit for Rack applications with Rails integration.
  # USED: in development env. See config/initializers/rack_profiler.rb
  gem 'rack-mini-profiler', require: false
end

group :test do
  gem 'rspec_junit_formatter', '~> 0.2.3'
  gem 'capybara-screenshot', '~> 1.0.11'

  # Mock external http requests for tests
  gem 'webmock'

  # gem for setting up ruby objects as test data
  # gem 'factory_girl_rails', '~> 4.2.1'
  # Rails 4
  gem 'factory_girl_rails', '~> 4.4.0'

  # testing frameworks
  gem 'rspec', '~> 3.5.0'
  gem 'rspec-rails', '~> 3.5.0'
  gem 'cucumber', '~> 1.3.8'
  gem 'cucumber-rails', '~> 1.4.0', :require => false

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

  # JS testing runner
  gem 'teaspoon'

  # safe way to convert strings to regexps
  # USED: Only by feature specs. See gs_page.rb
  gem 'to_regexp'
end

group :development, :test do
  # dev tool - print nicely formatted / colorful output of an object's structure. e.g. "ap my_obj"
  #gem 'awesome_print', :require => 'ap'

  # Supporting Gem for Rails Panel for Chrome
  # gem 'meta_request'

  # execute  "rails_best_practices -f html ."  on the command line to generate an html report
  # beware of false positives for things like unused methods
  gem 'rails_best_practices'

  # Use haml for template engine. Also specified in application.rb
  gem 'haml-rails'

  # Test coverage tool
  gem 'simplecov', '~> 0.8.0'
  gem 'simplecov-html', '~> 0.8.0'
  gem 'simplecov-rcov'

  gem 'childprocess'

  # Allows Ruby to communicate with growl, for system messaging. e.g. you can pop up an alert when your tests fail
  gem 'ruby_gntp'

  # Turn off assets logging in development
  gem 'quiet_assets'

  gem 'yard'

  gem 'launchy'

  gem 'pdf-reader'

  gem 'sourcify'
  
  #  translation tasks gem
  gem 'i18n-tasks', '~> 0.8.3'

  # Ruby code style checking tool.
  # USED: Manually and by Jenkins
  gem 'rubocop', '= 0.40.0', require: false
  # A formatter for rubocop that outputs in checkstyle format
  gem 'rubocop-checkstyle_formatter', require: false

  # Minimal embedded v8 engine for Ruby
  gem 'mini_racer', platforms: :ruby
end

# Sass adapter for the Rails asset pipeline.
# Rails 4
# USED: Rails automatically adds the sass-rails gem to your Gemfile, which is used by Sprockets for asset compression
gem 'sass-rails',   '~> 4.0.1'

# CoffeeScript adapter for the Rails asset pipeline.
# Rails 4
# USED: Rails automatically adds the coffee-rails gem to your Gemfile, which is used by Sprockets for asset compression
gem 'coffee-rails', '~> 4.0.1'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', :platforms => :ruby

#gem 'compass-rails', '~> 2.0.alpha.0'

# Uglifier minifies JavaScript files by wrapping UglifyJS to be accessible in Ruby
# USED: Rails automatically adds the uglifier gem to your Gemfile, which is used by Sprockets for asset compression
gem 'uglifier', '>= 1.0.3'

group :profile do
  gem 'ruby-prof'
end

