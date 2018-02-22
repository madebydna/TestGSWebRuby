# frozen_string_literal: true

class Academic < ActiveRecord::Base
  self.table_name = 'academics'
  database_config = Rails.configuration.database_configuration[Rails.env]["gsdata"]
  self.establish_connection(database_config)

  has_many :data_values_to_academics
  has_many :academics_tags
end
