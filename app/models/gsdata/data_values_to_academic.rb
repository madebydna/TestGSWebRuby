# frozen_string_literal: true

class DataValuesToAcademic < ActiveRecord::Base
  self.table_name = 'data_values_to_academics'
  database_config = Rails.configuration.database_configuration[Rails.env]["gsdata"]
  self.establish_connection(database_config)

  attr_accessible :data_value_id, :academic_id
end
