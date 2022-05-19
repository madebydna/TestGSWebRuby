source "https://rubygems.org"

# WARNING: Before upgrading rails version check the following extension to the
# Rails ActionDispatch::HTTP::URL.url_for 
gem 'rails', '4.2.8'

gem 'mysql2', '0.4.10'

# This gem provides jQuery and the jQuery-ujs driver for your Rails 3+ application.
# Used by pages that use JS through rails asset pipeline and not webpack/react
# Such as review moderation pages and reviews landing page 
gem 'jquery-rails'

# This gem provides jquery-cookie.js assets for your Rails 3 application.
# This has been deprecated in favor of js-cookie
# USED: many places. Search for $.cookie
gem 'jquery-cookie-rails'

# This gem packages the jQuery DataTables plugin for easy use with the Rails 3.1+ asset pipleine.
# It provides all the basic DataTables files, and a few of the extras.
# USED: reviews_moderation_init.js
gem 'jquery-datatables-rails', github: 'rweng/jquery-datatables-rails'

# Used in moderation.html.erb for review moderation
gem 'kaminari', '0.16.1'

# Provide various react builds to your asset bundle
# Transform .jsx in the asset pipeline
gem 'react_on_rails', '~> 10.1.4'

# Add database sharding support to Active Record
# gem 'ar-octopus', '0.6.0' <-- evil

# No Rails 4:
# gem 'db-charmer', '1.8.4', :require => 'db_charmer'
gem 'db-charmer', git: 'git://github.com/kovyrin/db-charmer.git', branch: 'rails4'

# Adds support for reserved-word column names as model attributes. Useful when writing models for legacy schemas
# This automatically supplements ActiveRecord::Base and "protects" any columns that conflict with default AR methods
# TODO: to decide if we need this, we would have to examine the column names for all ActiveRecord models
gem 'safe_attributes'

# Hashie is a simple collection of useful Hash extensions
# USED: primarily Hashie::Mash all over the place.
gem 'hashie'

# This module provides common interface to HMAC functionality. HMAC is a kind of "Message Authentication Code" (MAC) algorithm whose standard is documented in RFC2104.
# USED: By Google static maps api. See GoogleSignedImages::sign_url
# TODO: Switch to OpenSSL::HMAC (See http://blog.nathanielbibler.com/post/63031273/opensslhmac-vs-ruby-hmac-benchmarks)
gem 'ruby-hmac', '~> 0.4.0', :require => 'hmac-sha1'

# Adds lodash JS to the project. Version of lodash added depends on environment
# Can be removed after all pages no longer use deprecated_application js
# or wordpress-modals.js
gem 'lodash-rails'

# for passing vars from ruby rails to javascript
gem 'gon'

# USED: In FB authentication. See SigninController or related
gem 'mini_fb'

# SEO plugin for Ruby on Rails applications.
# USED: all over the place. Search for set_meta_tags
gem 'meta-tags', :require => 'meta_tags'

# Searching using solr
# USED: See solr.rb
gem 'rsolr'

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
gem 'draper', '~> 2.1.0'

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
gem 'nokogiri', '1.13.6'

# SOAP client
# USED: To communicate with ExactTarget. See exact_target.rb
gem 'savon', '~> 2.6.0'

# Ruby/NTLM provides message creator and parser for the NTLM authentication.
# Required by savon gem
gem 'rubyntlm', '~> 0.4.0'

# Retrieve the binding of a method's caller.
# USED: By GsLogger. See AT-873
gem 'binding_of_caller', '~> 0.7.2'

# Create JSON structures via a Builder-style DSL
# USED: Multiple places. Search for *.jbuilder for example
gem 'jbuilder'

gem 'json-schema'

# Used for parsing JSON, such as from school cache
gem 'oj'

gem 'stackprof'

# fast xml parsing library
gem 'ox'

group :development do
  gem 'web-console' # Add repl to error pages on localhost, replaces better_errors

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
  gem 'rubocop', '= 0.52.0', require: false
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

gem 'rgeo'
gem 'rgeo-activerecord', '= 4.0.5'
gem 'geokit-rails'

group :profile do
  gem 'ruby-prof'
end

