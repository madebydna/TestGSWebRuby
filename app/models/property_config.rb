class PropertyConfig < ActiveRecord::Base
  db_magic :connection => :gs_schooldb
  self.table_name = 'property'

  def self.sweepstakes?
    pc_sweepstakes = PropertyConfig.where(quay: 'sweepstakes')
    pc_sweepstakes.present? ? pc_sweepstakes.first.value == 'true' : false
  end

  def self.get_property(quay, fail_return_val = '')
    cache_key = 'PropertyConfig/' + quay
    Rails.cache.fetch(cache_key, expires_in: 2.minutes) do
      property = PropertyConfig.where(quay: quay).order("id DESC")
      property.present? ? property.first.value : fail_return_val
    end
  end

  def self.force_review_moderation?
    Rails.cache.fetch('PropertyConfig/force_review_moderation', expires_in: 2.minutes) do
      property = PropertyConfig.where(quay: 'force_review_moderation')
      property.present? ? property.first.value == 'true' : false
    end
  end

  def self.advertising_enabled?
    Rails.cache.fetch('PropertyConfig/advertising_enabled', expires_in: 2.minutes) do
      property = PropertyConfig.where(quay: 'advertisingEnabled')
      property.present? ? property.first.value == 'true' : true
    end
  end
end