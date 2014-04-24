class HubCityMapping < ActiveRecord::Base
  db_magic :connection => :gs_schooldb
  self.table_name = 'hub_city_mapping'

  attr_accessible :collection_id, :city, :state, :active

  def has_events_page?
    self.hasEventsPage ? 'y' : nil
  end

  def has_edu_page?
    (self.hasEduPage || self.hasStateEduPage) ? 'y' : nil
  end

  def has_choose_page?
    (self.hasChoosePage || self.hasStateChoosePage) ? 'y' : nil
  end

  def has_enroll_page?
    (self.hasEnrollPage || self.hasStateEnrollPage) ? 'y' : nil
  end

  def has_partner_page?
    (self.hasPartnerPage || hasStatePartnerPage) ? 'y' : nil
  end

  def self.for_collection_id(collection_id)
    Rails.cache.fetch('hub_city_mapping/all', expires_in: 5.minutes) do
      where(collection_id: collection_id, active: true).first
    end
  end
end
