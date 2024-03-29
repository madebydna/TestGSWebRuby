LocalizedProfiles::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # The test environment is used exclusively to run your application's
  # test suite. You never need to work with it otherwise. Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs. Don't rely on the data there!
  config.cache_classes = false

  # to upgrade to rails 4.2 required to comment out precompile of these fonts
  # TODO: find better solution
  # config.assets.precompile << /\.(?:svg|eot|woff|ttf)$/

  # Configure static asset server for tests with Cache-Control for performance
  config.serve_static_files = true
  config.static_cache_control = "public, max-age=3600"

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Raise exceptions instead of rendering exception templates
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment
  config.action_controller.allow_forgery_protection    = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  # Print deprecation notices to the stderr
  config.active_support.deprecation = :log

  # Don't cache when running tests
  config.cache_store = :memory_store, { size: 128.megabytes }

  # set host that rails should use when building absolute urls
  Rails.application.routes.default_url_options = {
    # host: 'test.host',
    host: 'localhost',
    trailing_slash: true
  }

  config.action_controller.default_url_options = {
    host: 'localhost',
    trailing_slash: true
  }

  # For setting up Devise.
  config.action_mailer.default_url_options = {
    # host: 'test.host'
    host: 'localhost'
  }

  config.hub_mapping_cache_time = 60 * 24
  config.hub_config_cache_time = 10

  if ENV_GLOBAL['log_file']
    log_dir = File.dirname(ENV_GLOBAL['log_file'])
    FileUtils.mkdir_p(log_dir)
    config.logger = ActiveSupport::Logger.new(ENV_GLOBAL['log_file'])
  end

end
