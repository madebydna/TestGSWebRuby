# frozen_string_literal: true

class DataTypeTag < ActiveRecord::Base

  db_magic connection: :omni

  belongs_to :data_type

  def self.data_type_ids_for(tag_names)
    where(tag: tag_names).pluck(:data_type_id)
  end

end