require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "active_resource/railtie"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

# Create an ENV_GLOBAL constant with config options that we can use throughout the app
# Look for /usr/local/etc/GSWebRuby-config.yml which can be a machine-specific config to overwrite the defaults
ENV_GLOBAL = YAML.load_file("#{Dir.pwd}/config/env_global.yml")
file = File.join('', 'usr', 'local', 'etc', 'GSWebRuby-config.yml')
ENV_GLOBAL.merge!(YAML.load_file(file)) if File.exist?(file)

module LocalizedProfiles
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)
    config.autoload_paths += Dir[Rails.root.join('config', 'initializers', 'extensions', '**/')]
    config.autoload_paths += Dir[Rails.root.join('app', 'lib', '**/')]
    config.autoload_paths += Dir[Rails.root.join('app', 'models', '**/')]
    config.autoload_paths += Dir[Rails.root.join('app', 'controllers', 'concerns', '**/')]


    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Pacific Time (US & Canada)'
    # Also required: (http://stackoverflow.com/questions/6118779/how-to-change-default-timezone-for-activerecord-in-rails3)
    config.active_record.default_timezone = :local

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    # config.active_record.schema_format = :sql

    # Enforce whitelist mode for mass assignment.
    # This will create an empty whitelist of attributes available for mass-assignment for all models
    # in your app. As such, your models will need to explicitly whitelist or blacklist accessible
    # parameters by using an attr_accessible or attr_protected declaration.

    # TODO: this should be true for added security in production environments
    # Changing to false to make development easier
    config.active_record.whitelist_attributes = false

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    config.assets.paths << Rails.root.join("app", "assets", "fonts")

    # Add trailing slashes to generated URLs
    config.action_controller.default_url_options = { :trailing_slash => true }

    require File.join(config.root, 'lib', 'database_configuration_loader')
    def config.database_configuration
      config = DatabaseConfigurationLoader.config
    end

    # Add in StatusPage as rack middleware
    require File.join(config.root, 'lib', 'status_page')
    config.middleware.insert_before ActiveRecord::ConnectionAdapters::ConnectionManagement, ::StatusPage

    config.active_record.schema_format = :sql
  end
end
