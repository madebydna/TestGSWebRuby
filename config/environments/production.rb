LocalizedProfiles::Application.configure do
  require 'socket'
  hostname = "#{Socket.gethostname}"

  # Settings specified here will take precedence over
  # those in config/application.rb

  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

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
    address: 'mail.greatschools.org',
    domain: 'greatschools.org'
  }

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_assets = false

  # Compress JavaScripts and CSS
  config.assets.compress = true

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = false

  # Generate digests for assets URLs
  config.assets.digest = true

  # Defaults to nil and saved in location specified by config.assets.prefix
  # config.assets.manifest = YOUR_PATH

  # Specifies the header that your server uses for sending files
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security,
  # and use secure cookies.
  # config.force_ssl = true

  # See everything in the log (default is :info)
  # config.log_level = :debug

  # Prepend all log lines with the following tags
  # config.log_tags = [ :subdomain, :uuid ]

  # Use a different logger for distributed setups
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store
  # config.cache_store = :memory_store, { size: 128.megabytes }
  # Shomi Arora -Dont Cache so QA can test quickly
   config.cache_store = :null_store

  # Enable serving of images, stylesheets, and JavaScripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"
  config.action_controller.asset_host = ENV_GLOBAL['media_server'] if ENV_GLOBAL['media_server'].present?

  # Precompile additional assets (application.js, application.css, and all
  # non-JS/CSS are already added)
  # config.assets.precompile += %w( search.js )
  config.assets.precompile += [
    'codemirror.js',
    'codemirror.css',
    'codemirror/modes/css.js',
    'codemirror/themes/night.css'
  ]
  config.assets.precompile << /\.(?:svg|eot|woff|ttf)$/
  config.assets.precompile += %w[ *.png *.jpeg *.jpg *.gif ]
  config.assets.precompile += ["cycle/jquery.cycle2.js", "cycle/jquery.cycle2.carousel.js", "cycle/carousel_init.js"]

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  # config.active_record.auto_explain_threshold_in_seconds = 0.5

  config.session_store :cookie_store, key: '_gsweb_session', :domain => :all, :tld_length => 2, :httponly => false

  config.hub_mapping_cache_time = 0
  config.hub_config_cache_time = 10
  config.hub_recent_reviews_cache_time = 10
end
