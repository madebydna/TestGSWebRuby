class BannedIp < ActiveRecord::Base
  db_magic :connection => :community
  self.table_name = 'banned_ip'

  EXPIRED_TIME = 1.year

  scope :active, where("updated >= ?", EXPIRED_TIME.ago)
  scope :expired, where("updated < ?", EXPIRED_TIME.ago)

  def self.banned_ips
    Rails.cache.fetch("banned_ip/active_ips", expires_in: 5.minutes) do
      active.map(&:ip)
    end
  end

end