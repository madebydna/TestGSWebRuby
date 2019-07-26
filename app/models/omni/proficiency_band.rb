# frozen_string_literal: true

class ProficiencyBand < ActiveRecord::Base
  self.table_name = 'proficiency_bands'
  db_magic connection: :omni

  has_many :test_data_values

end
