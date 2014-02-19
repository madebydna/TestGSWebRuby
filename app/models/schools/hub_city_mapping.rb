class HubCityMapping < ActiveRecord::Base
  db_magic :connection => :gs_schooldb
  self.table_name = 'hub_city_mapping'

  attr_accessible :collection_id, :city, :state, :active

  alias_attribute :has_edu_page?, :hasEduPage
  alias_attribute :has_choose_page?, :hasChoosePage
  alias_attribute :has_events_page?, :hasEventsPage
  alias_attribute :has_enroll_page?, :hasEnrollPage
  alias_attribute :has_partner_page?, :hasPartnerPage

  def self.for_collection_id(collection_id)
    all_mappings = Rails.cache.fetch('hub_city_mapping/all', expires_in: 5.minutes) do
      self.all
    end
    all_mappings.select { |hub_city_mapping| hub_city_mapping.collection_id.to_i == collection_id.to_i }
  end

end