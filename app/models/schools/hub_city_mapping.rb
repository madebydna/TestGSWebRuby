class HubCityMapping < ActiveRecord::Base
  db_magic :connection => :gs_schooldb
  self.table_name = 'hub_city_mapping'

  attr_accessible :collection_id, :city, :state, :active

  alias_attribute :has_edu_page?, :hasEduPage
  alias_attribute :has_choose_page?, :hasChoosePage
  alias_attribute :has_events_page?, :hasEventsPage
  alias_attribute :has_enroll_page?, :hasEnrollPage
  alias_attribute :has_partner_page?, :hasPartnerPage

end