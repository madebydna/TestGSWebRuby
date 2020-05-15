# frozen_string_literal: true

class CRPEData < ActiveRecord::Base
  db_magic :connection => :omni
  self.table_name = 'covid_responses'

  scope :by_district, ->(district) { where(entity_type: 'district', state: district.state, gs_id: district.id) }
  scope :active, -> { where(active: true) }
end
