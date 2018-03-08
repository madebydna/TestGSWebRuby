# frozen_string_literal: true

class DataType < ActiveRecord::Base
  self.table_name = 'data_types'
  db_magic connection: :gsdata

  attr_accessible :id, :name

  has_many :data_type_tags, class_name: 'DataTypeTag', foreign_key: :data_type_id
  has_many :data_values

  def self.to_hash
    all.index_by(&:id)
  end
end
