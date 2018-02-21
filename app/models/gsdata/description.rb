# frozen_string_literal: true

module Gsdata
  class Description < ActiveRecord::Base
    self.table_name = 'descriptions'
    database_config = Rails.configuration.database_configuration[Rails.env]["gsdata"]
    self.establish_connection(database_config)
    belongs_to :source
  end
end
