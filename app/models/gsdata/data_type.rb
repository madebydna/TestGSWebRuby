class DataType < ActiveRecord::Base
  self.table_name = 'data_types'
  database_config = Rails.configuration.database_configuration[Rails.env]["gsdata"]
  self.establish_connection(database_config)

  attr_accessible :id, :name
end
