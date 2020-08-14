redis_url = "#{ENV_GLOBAL['redis_url']}/#{ENV_GLOBAL['redis_db']}"

Sidekiq.configure_server do |config|
  config.redis = { url: redis_url }
end

Sidekiq.configure_client do |config|
  config.redis = { url: redis_url }
end