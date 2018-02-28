# frozen_string_literal: true

class ProficiencyBand < ActiveRecord::Base
  self.table_name = 'proficiency_bands'
  db_magic connection: :gsdata

  has_many :data_values, inverse_of: :proficiency_band

  attr_accessible :id, :name
end
