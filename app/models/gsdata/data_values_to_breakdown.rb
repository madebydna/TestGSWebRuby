# frozen_string_literal: true

class DataValuesToBreakdown < ActiveRecord::Base
  self.table_name = 'data_values_to_breakdowns'
  database_config = Rails.configuration.database_configuration[Rails.env]["gsdata"]
  self.establish_connection(database_config)

  attr_accessible :data_value_id, :breakdown_id
end
