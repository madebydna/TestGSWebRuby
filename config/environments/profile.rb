LocalizedProfiles::Application.configure do
  require 'socket'
  hostname = "#{Socket.gethostname}"
  hostname_and_port = "#{hostname}:3000"

  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = true
  config.cache_template_loading = true

  config.assets.precompile << /\.(?:svg|eot|woff|ttf)$/

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # set host that rails should use when building absolute urls
  config.action_controller.default_url_options[:host] = ENV_GLOBAL['app_host'] if ENV_GLOBAL['app_host'].present?
  config.action_controller.default_url_options[:port] = ENV_GLOBAL['app_port'] if ENV_GLOBAL['app_port'].present?

  # For setting up Devise.
  config.action_mailer.default_url_options = {
    host: ENV_GLOBAL['app_host'] || hostname,
    port: ENV_GLOBAL['app_port'] || 3000
  }
  config.action_mailer.perform_deliveries = true

  config.action_mailer.delivery_method = :smtp

  config.action_mailer.smtp_settings = {
    :address => 'mail.greatschools.org',
    :domain => 'greatschools.org',
  }

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Raise exception on mass assignment protection for Active Record models
  config.active_record.mass_assignment_sanitizer = :strict

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = false

  # If you want to temporarily turn assets logging back on in development, just set quet_assets to false below
  config.quiet_assets = true

  # Don't cache in dev environment
  config.cache_store = :null_store

  def local_ip
    orig, Socket.do_not_reverse_lookup = Socket.do_not_reverse_lookup, true  # turn off reverse DNS resolution temporarily

    UDPSocket.open do |s|
      s.connect 'greatschools.org', 1
      s.addr.last
    end
  ensure
    Socket.do_not_reverse_lookup = orig
  end

  config.action_controller.asset_host = 'http://' + local_ip + ':3000'

  # For dev environments, use domain: all which will makes session cookies have a domain of localhost
  # or a domain of blah.greatschools.org
  config.session_store :cookie_store, key: '_gsweb_session', :domain => :all, :httponly => false

  # If you don't need localhost:3000 to work with session cookies, but you DO want to test session cookies to have
  # a domain of .greatschools.org (so that they're shared across subdomains) then uncomment out the below line
  # config.session_store :cookie_store, key: '_LocalizedProfiles_session', :domain => :all, :tld_length => 2


  # Move sql logging into separate file in development
  sql_logger = Logger.new Rails.root.join('log', 'development_sql.log')
  # sql_logger.formatter = Logger::Formatter.new
  config.active_record.logger = sql_logger
  
  config.hub_mapping_cache_time = 60 * 24
  config.hub_config_cache_time = 10
end
