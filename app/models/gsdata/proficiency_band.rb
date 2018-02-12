# frozen_string_literal: true

class ProficiencyBand < ActiveRecord::Base
  self.table_name = 'proficiency_bands'
  database_config = Rails.configuration.database_configuration[Rails.env]["gsdata"]
  self.establish_connection(database_config)

  attr_accessible :id, :name
end