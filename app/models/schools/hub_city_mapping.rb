class HubCityMapping < ActiveRecord::Base
  db_magic :connection => :gs_schooldb
  self.table_name = 'hub_city_mapping'

  attr_accessible :collection_id, :city, :state, :active, :hasGuidedSearch

  belongs_to :collection

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

  def has_guided_search?
    self.hasGuidedSearch ? 'y' : nil
  end

  def self.for_collection_id(collection_id)
    Rails.cache.fetch("hub_city_mapping/for_collection_id-#{collection_id}", expires_in: CollectionConfig.hub_mapping_cache_time, race_condition_ttl: CollectionConfig.hub_mapping_cache_time) do
      where(collection_id: collection_id, active: true).first
    end
  end

  def self.for_city_and_state(city, state)
    mappings_matching_state = HubCityMapping.where(state: state, active:true)
    match = mappings_matching_state.find do |mapping|
      (mapping.city || '').to_s.downcase == (city || '').to_s.downcase
    end
    match ||= mappings_matching_state.find { |mapping| mapping.city.nil? }
  end
end
