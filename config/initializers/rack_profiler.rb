if Rails.env == 'development' || ENV_GLOBAL['profiling'] == 'true'
  require 'rack-mini-profiler'

  Rack::MiniProfiler.config.skip_paths ||= []
  Rack::MiniProfiler.config.skip_paths << '/admin/gsr/school-profiles/'
  Rack::MiniProfiler.config.skip_paths << '/rails_admin'
  # initialization is skipped so trigger it
  Rack::MiniProfilerRails.initialize!(Rails.application)
end
