# frozen_string_literal: true

source "https://rubygems.org"

# WARNING: Before upgrading rails version check the following extension to the
# Rails ActionDispatch::HTTP::URL.url_for
# Full-stack web application framework. (http://rubyonrails.org)
gem 'rails', '4.2.8'

# A simple, fast Mysql library for Ruby, binding to libmysql (https://github.com/brianmario/mysql2)
gem 'mysql2', '0.4.10'

# A pure Ruby implementation of the SFTP client protocol (https://github.com/net-ssh/net-sftp)
gem 'net-sftp', '~> 2.1', '>= 2.1.2'

# CSV Validator
gem 'csvlint'

# rubyzip is a ruby module for reading and writing zip files (http://github.com/rubyzip/rubyzip)
gem 'rubyzip'

# This gem provides jQuery and the jQuery-ujs driver for your Rails 3+ application.
# Used by pages that use JS through rails asset pipeline and not webpack/react
# Such as review moderation pages and reviews landing page
# Use jQuery with Rails 3+ (http://rubygems.org/gems/jquery-rails)
gem 'jquery-rails'

# This gem provides jquery-cookie.js assets for your Rails 3 application.
# This has been deprecated in favor of js-cookie
# USED: many places. Search for $.cookie
# Use jquery-cookie with Rails 3 (http://github.com/RyanScottLewis/jquery-cookie-rails)
gem 'jquery-cookie-rails'

# USED: reviews_moderation_init.js
# jquery datatables for rails (https://github.com/rweng/jquery-datatables-rails)
gem 'jquery-datatables-rails', github: 'rweng/jquery-datatables-rails'

# Used in moderation.html.erb for review moderation
# A pagination engine plugin for Rails 3+ and other modern frameworks (https://github.com/amatsuda/kaminari)
gem 'kaminari', '0.16.1'

# Provide various react builds to your asset bundle
# Transform .jsx in the asset pipeline
# Rails with react server rendering with webpack. (https://github.com/shakacode/react_on_rails)
gem 'react_on_rails', '~> 10.1.4'

# No Rails 4:
# gem 'db-charmer', '1.8.4', :require => 'db_charmer'
# ActiveRecord Connections Magic (slaves, multiple connections, etc) (http://kovyrin.github.io/db-charmer/)
gem 'db-charmer', git: 'git://github.com/kovyrin/db-charmer.git', branch: 'rails4'

# This automatically supplements ActiveRecord::Base and "protects" any columns that conflict with default AR methods
# TODO: to decide if we need this, we would have to examine the column names for all ActiveRecord models
# Useful for legacy database support, adds support for reserved word column names with ActiveRecord (http://github.com/bjones/safe_attributes)
gem 'safe_attributes'

# USED: primarily Hashie::Mash all over the place.
# Your friendly neighborhood hash library. (https://github.com/intridea/hashie)
gem 'hashie'

# HMAC is a kind of "Message Authentication Code" (MAC) algorithm whose standard is documented in RFC2104.
# USED: By Google static maps api. See GoogleSignedImages::sign_url
# TODO: Switch to OpenSSL::HMAC (See http://blog.nathanielbibler.com/post/63031273/opensslhmac-vs-ruby-hmac-benchmarks)
# This module provides common interface to HMAC functionality (http://ruby-hmac.rubyforge.org)
gem 'ruby-hmac', '~> 0.4.0', :require => 'hmac-sha1'

# Adds lodash JS to the project. Version of lodash added depends on environment
# Can be removed after all pages no longer use deprecated_application js
# or wordpress-modals.js
# This gem makes Lo-Dash available for the Rails asset pipeline (http://github.com/rh/lodash-rails)
gem 'lodash-rails'

# for passing vars from ruby rails to javascript
# Get your Rails variables in your JS (https://github.com/gazay/gon)
gem 'gon'

# USED: In FB authentication. See SigninController or related
# Tiny facebook library. By http://www.appoxy.com (http://github.com/appoxy/mini_fb/)
gem 'mini_fb'

# SEO plugin for Ruby on Rails applications.
# USED: all over the place. Search for set_meta_tags
# Collection of SEO helpers for Ruby on Rails. (http://github.com/kpumuk/meta-tags)
gem 'meta-tags', :require => 'meta_tags'

# Searching using solr
# USED: See solr.rb
# A Ruby client for Apache Solr (https://github.com/rsolr/rsolr)
gem 'rsolr'

# Maps controller filters to your model scopes
# USED: controllers/admin/reviews_controller and schools_controller
# Maps controller filters to your resource scopes. (http://github.com/plataformatec/has_scope)
gem 'has_scope'

# USED: lib/school_profiles/AdsSwitch
# TODO: Can we do this a different way and remove this gem?
# RequestStore gives you per-request global storage. (http://github.com/steveklabnik/request_store)
gem 'request_store', '~> 1.0.3'

# Rails 4
# Decorators/View-Models for Rails Applications
# USED: everywhere. See app/decorators for many examples
# View Models for Rails (http://github.com/drapergem/draper)
gem 'draper', '~> 2.1.0'

# Addressable is a replacement for the URI implementation that is part of Ruby's standard library.
# It more closely conforms to RFC 3986, RFC 3987, and RFC 6570 (level 4)
# USED: in application_controller, url_helper, user_mailer
# URI Implementation (https://github.com/sporkmonger/addressable)
gem 'addressable'

# USED: All over. Search for attr_accessible
# Protect attributes from mass assignment in Active Record models (https://github.com/rails/protected_attributes)
gem 'protected_attributes'

# USED: Only by script/feeds/feed_scripts/validate_feed_files as far as I can tell
# This was added back in the early days though
# TODO: Verify not used outside of development environment and move there
# Nokogiri (鋸) is an HTML, XML, SAX, and Reader parser
gem 'nokogiri', '= 1.8.1'

# USED: To communicate with ExactTarget. See exact_target.rb
# Heavy metal SOAP client (http://savonrb.com)
gem 'savon', '~> 2.6.0'

# Ruby/NTLM provides message creator and parser for the NTLM authentication.
# Required by savon gem
# Ruby/NTLM library. (https://github.com/winrb/rubyntlm)
gem 'rubyntlm', '~> 0.4.0'

# USED: By GsLogger. See AT-873
# Retrieve the binding of a method's caller. Can also retrieve bindings even further up the stack. (http://github.com/banister/binding_of_caller)
gem 'binding_of_caller', '~> 0.7.2'

# USED: Multiple places. Search for *.jbuilder for example
# Create JSON structures via a Builder-style DSL (https://github.com/rails/jbuilder)
gem 'jbuilder'

# Ruby JSON Schema Validator (http://github.com/ruby-json-schema/json-schema/tree/master)
gem 'json-schema'

# A fast JSON parser and serializer. (http://www.ohler.com/oj)
gem 'oj'

# sampling callstack-profiler for ruby 2.1+ (http://github.com/tmm1/stackprof)
gem 'stackprof'

# A fast XML parser and object serializer. (http://www.ohler.com/ox)
gem 'ox'

# Simple, efficient background processing for Ruby. (https://github.com/mperham/sidekiq)
gem 'sidekiq'

group :development do
  # A debugging tool for your Ruby on Rails applications. (https://github.com/rails/web-console)
  gem 'web-console' # Add repl to error pages on localhost, replaces better_errors

  # Use the Thin server in development for speed and other improvements
  # A thin and fast web server (http://code.macournoyer.com/thin/)
  gem 'thin'

  # Guard keeps an eye on your file modifications (http://guardgem.org)
  gem 'guard'
  # Guard gem for Bundler (https://rubygems.org/gems/guard-bundler)
  gem 'guard-bundler'
  # Guard gem for RSpec (https://rubygems.org/gems/guard-rspec)
  gem 'guard-rspec', '= 4.2.9'
  # Guard plugin for livereload (https://rubygems.org/gems/guard-livereload)
  gem 'guard-livereload'
  # rspec command for spring (https://github.com/jonleighton/spring-commands-rspec)
  gem 'spring-commands-rspec'

  # Tool used to manage and configure webhooks including firing off rubocop on commits
  # Git hook manager (https://github.com/causes/overcommit)
  gem 'overcommit'

  # Profiling toolkit for Rack applications with Rails integration.
  # USED: in development env. See config/initializers/rack_profiler.rb
  # Profiles loading speed for rack applications. (http://miniprofiler.com)
  gem 'rack-mini-profiler', require: false

end

group :test do
  # RSpec JUnit XML formatter (http://github.com/sj26/rspec_junit_formatter)
  gem 'rspec_junit_formatter', '~> 0.2.3'
  # Automatically create snapshots when Cucumber steps fail with Capybara and Rails (http://github.com/mattheworiordan/capybara-screenshot)
  gem 'capybara-screenshot', '~> 1.0.23'

  # Mock external http requests for tests
  # Library for stubbing HTTP requests in Ruby. (http://github.com/bblimke/webmock)
  gem 'webmock'

  # testing frameworks
  # rspec-3.5.0 (http://github.com/rspec)
  gem 'rspec', '~> 3.5.0'
  # RSpec for Rails (https://github.com/rspec/rspec-rails)
  gem 'rspec-rails', '~> 3.5.0'
  # cucumber-3.1.2 (https://cucumber.io/)
  gem 'cucumber', '~> 3'
  # cucumber-rails-1.7.0 (http://cukes.info)
  gem 'cucumber-rails', '~> 1.7.0', :require => false

  # DSL for page object pattern, used for cucumber testing
  # A Page Object Model DSL for Capybara (https://github.com/natritmeyer/site_prism)
  gem 'site_prism'

  # The Mechanize library is used for automating interaction with websites (http://docs.seattlerb.org/mechanize/)
  gem 'mechanize'
  # Capybara aims to simplify the process of integration testing Rack applications, such as Rails, Sinatra or Merb (https://github.com/teamcapybara/capybara)
  gem 'capybara', '~> 3.18.0'
  # Easy download and use of browser drivers. (https://github.com/titusfortner/webdrivers)
  gem 'webdrivers'
  # RackTest driver for Capybara with remote request support (https://github.com/jeroenvandijk/capybara-mechanize)
  gem 'capybara-mechanize', '~> 1.11.0'
  # Fixtures aren't fun. Machinist is. (http://github.com/notahat/machinist)
  gem 'machinist', '>= 2.0.0.beta2'
  # A gem providing "time travel" and "time freezing" capabilities, making it dead simple to test time-dependent code.  It provides a unified method to mock Time.now, Date.today, and DateTime.now in a single call. (https://github.com/travisjeffery/timecop)
  gem 'timecop'

  # JS testing runner
  # Teaspoon: A Javascript test runner built on top of Rails (https://github.com/modeset/teaspoon)
  gem 'teaspoon'

  # safe way to convert strings to regexps
  # USED: Only by feature specs. See gs_page.rb
  # Provides String#to_regexp (https://github.com/seamusabshere/to_regexp)
  gem 'to_regexp'
end

group :development, :test do
  # Pure-Ruby Readline Implementation (http://github.com/ConnorAtherton/rb-readline)
  gem 'rb-readline'

  # Ruby 2.0 fast debugger - base + CLI (http://github.com/deivid-rodriguez/byebug)
  gem 'byebug'

  # execute  "rails_best_practices -f html ."  on the command line to generate an html report
  # beware of false positives for things like unused methods
  # a code metric tool for rails codes. (http://rails-bestpractices.com)
  gem 'rails_best_practices'

  # Code coverage for Ruby 1.9+ with a powerful configuration library and automatic merging of coverage across test suites (http://github.com/colszowka/simplecov)
  gem 'simplecov', '~> 0.8.0'
  # Default HTML formatter for SimpleCov code coverage tool for ruby 1.9+ (https://github.com/colszowka/simplecov-html)
  gem 'simplecov-html', '~> 0.8.0'
  # Rcov style formatter for SimpleCov (http://github.com/fguillen/simplecov-rcov)
  gem 'simplecov-rcov'

  # Turn off rails assets log. (http://github.com/evrone/quiet_assets)
  gem 'quiet_assets'

  # Documentation tool for consistent and usable documentation in Ruby. (http://yardoc.org)
  gem 'yard'

  # Sourcify was written in the days of ruby 1.9.x, it should be buggy for anything beyond that.
  # Workarounds before ruby-core officially supports Proc#to_source (& friends) (http://github.com/ngty/sourcify)
  gem 'sourcify'

  # Manage localization and translation with the awesome power of static analysis (https://github.com/glebm/i18n-tasks)
  gem 'i18n-tasks', '~> 0.8.3'

  # USED: Manually and by Jenkins
  # Automatic Ruby code style checking tool. (https://github.com/bbatsov/rubocop)
  gem 'rubocop', '= 0.52.0', require: false
  # A formatter for rubocop that outputs in checkstyle format (https://github.com/eitoball/rubocop-checkstyle_formatter)
  gem 'rubocop-checkstyle_formatter', require: false

  # Use Pry as your rails console (https://github.com/rweng/pry-rails)
  gem 'pry-rails'

  # factory_bot_rails provides integration between factory_bot and rails 4.2 or newer (https://github.com/thoughtbot/factory_bot_rails)
  gem "factory_bot_rails", '~> 4.11.0'
end

# Sass adapter for the Rails asset pipeline.
# Rails 4
# USED: Rails automatically adds the sass-rails gem to your Gemfile, which is used by Sprockets for asset compression
# Sass adapter for the Rails asset pipeline. (https://github.com/rails/sass-rails)
gem 'sass-rails',   '~> 4.0.1'

# CoffeeScript adapter for the Rails asset pipeline.
# Rails 4
# USED: Rails automatically adds the coffee-rails gem to your Gemfile, which is used by Sprockets for asset compression
# CoffeeScript adapter for the Rails asset pipeline. (https://github.com/rails/coffee-rails)
gem 'coffee-rails', '~> 4.0.1'

# USED: Rails automatically adds the uglifier gem to your Gemfile, which is used by Sprockets for asset compression
# Ruby wrapper for UglifyJS JavaScript compressor (http://github.com/lautis/uglifier)
gem 'uglifier', '>= 1.0.3'

# Seems to be only used by the API
# RGeo is a geospatial data library for Ruby. (https://github.com/rgeo/rgeo)
gem 'rgeo'
# An RGeo module providing spatial extensions to ActiveRecord. (https://github.com/rgeo/rgeo-activerecord)
gem 'rgeo-activerecord', '= 4.0.5'

group :profile do
  # Fast Ruby profiler (https://github.com/ruby-prof/ruby-prof)
  gem 'ruby-prof'
end

