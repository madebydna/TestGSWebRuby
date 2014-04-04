if Rails.env == 'development' || ENV_GLOBAL['profiling'] == 'true'
  require 'rack-mini-profiler'

  # initialization is skipped so trigger it
  Rack::MiniProfilerRails.initialize!(Rails.application)
end