redis_url = "redis://#{ENV_GLOBAL['REDIS_URL']}/#{ENV_GLOBAL['REDIS_DB']}"

Sidekiq.configure_server do |config|
  config.redis = { url: redis_url }
end

Sidekiq.configure_client do |config|
  config.redis = { url: redis_url }
end
