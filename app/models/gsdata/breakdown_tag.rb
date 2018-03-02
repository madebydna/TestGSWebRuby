# frozen_string_literal: true

class BreakdownTag < ActiveRecord::Base
  self.table_name = 'breakdown_tags'
  database_config = Rails.configuration.database_configuration[Rails.env]["gsdata"]
  self.establish_connection(database_config)
  belongs_to :breakdown

end