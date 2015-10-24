LocalizedProfiles::Application.configure do
  require 'socket'
  hostname = "#{Socket.gethostname}"
  hostname_and_port = "#{hostname}:3000"

  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  config.assets.precompile << /\.(?:svg|eot|woff|ttf)$/
  config.assets.precompile += ["cycle/jquery.cycle2.js", "cycle/jquery.cycle2.carousel.js", "cycle/carousel_init.js"]

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # set host that rails should use when building absolute urls
  # Both config.action_controller and Rails.application.routes must be assigned
  config.action_controller.default_url_options[:host] = ENV_GLOBAL['app_host'] if ENV_GLOBAL['app_host'].present?
  config.action_controller.default_url_options[:port] = ENV_GLOBAL['app_port'] if ENV_GLOBAL['app_port'].present?
  # Setting Rails.application.routes is needed so that URLs created
  # within models use the correct host
  Rails.application.routes.default_url_options[:host] = ENV_GLOBAL['app_host'] if ENV_GLOBAL['app_host'].present?
  Rails.application.routes.default_url_options[:port] = ENV_GLOBAL['app_port'] if ENV_GLOBAL['app_port'].present?

  # For setting up Devise.
  config.action_mailer.default_url_options = {
    host: ENV_GLOBAL['app_host'] || hostname,
    port: ENV_GLOBAL['app_port'] || 3000
  }
  config.action_mailer.perform_deliveries = ENV_GLOBAL['mail_enabled']

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

  # Expands the lines which load the assets
  config.assets.debug = false

  # If you want to temporarily turn assets logging back on in development, just set quet_assets to false below
  config.quiet_assets = true

  # Don't cache in dev environment
  config.cache_store = :null_store

  if ENV_GLOBAL['cdn_prefix'].present?
    config.action_controller.asset_host = ENV_GLOBAL['cdn_prefix']
  else
    config.action_controller.asset_host = 'http://localhost:3000'
  end

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

  # Raise error when an I18n translation is missing
  # config.action_view.raise_on_missing_translations = true
end
