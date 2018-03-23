# frozen_string_literal: true

class DataTypeTag < ActiveRecord::Base
  self.table_name = 'data_type_tags'
  db_magic connection: :gsdata

  belongs_to :data_type, class_name: 'DataType', foreign_key: :data_type_id

  def self.data_type_ids_for(tag_names)
    where(tag: tag_names).pluck(:data_type_id)
  end

end