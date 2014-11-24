class PropertyConfig < ActiveRecord::Base
  db_magic :connection => :gs_schooldb
  self.table_name = 'property'

  def self.sweepstakes?
    pc_sweepstakes = PropertyConfig.where(quay: 'sweepstakes')
    pc_sweepstakes.present? ? pc_sweepstakes.first.value == 'true' : false
  end

  def self.facebook_comments?(state)
    property = PropertyConfig.where(quay: 'facebook_comments')
    fc_arr = property.first.value.split(',') if property.present?
    if fc_arr.present?
      fc_arr.select!{ |item| item.upcase == state.upcase || item.upcase == 'ALL' }
      fc_arr.present?
    else
      false
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
      property.nil? ? true : property.first.value == 'true'
    end
  end
end