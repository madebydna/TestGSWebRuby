# frozen_string_literal: true

class AcademicTag < ActiveRecord::Base
  self.table_name = 'academic_tags'
  database_config = Rails.configuration.database_configuration[Rails.env]["gsdata"]
  self.establish_connection(database_config)

  belongs_to :academic
end
