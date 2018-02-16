# frozen_string_literal: true

class DataTypeTag < ActiveRecord::Base
  self.table_name = 'data_type_tags'
  database_config = Rails.configuration.database_configuration[Rails.env]["gsdata"]
  self.establish_connection(database_config)

  belongs_to :data_type, class_name: 'DataType', foreign_key: :data_type_id

  def self.data_type_ids_for(tag_name)
    where(tag: tag_name).pluck(:data_type_id)
  end
end