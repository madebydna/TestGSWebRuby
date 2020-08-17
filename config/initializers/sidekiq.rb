redis_url = "redis://#{ENV['REDIS_URL']}/#{ENV['REDIS_DB']}"

Sidekiq.configure_server do |config|
  config.redis = { url: redis_url }
end

Sidekiq.configure_client do |config|
  config.redis = { url: redis_url }
end
