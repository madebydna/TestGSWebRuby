class TestWorker
  include Sidekiq::Worker

  def perform
    Rails.logger.info "(¯`·._.·(¯`·._.· Hello from Sidekiq worker ·._.·´¯)·._.·´¯)"
  end
end