class TestDataType < ActiveRecord::Base
  self.table_name = 'TestDataType'
  db_magic :connection => :gs_schooldb
  attr_accessible :description, :display_name, :display_type, :name, :type
  has_many :test_data_sets, class_name: 'TestDataSet', foreign_key: 'data_type_id'
  #bad_attribute_names :type
  #self.inheritance_column = nil
  self.inheritance_column = :_type_disabled
  def self.by_id(data_type_ids)
     TestDataType.find(data_type_ids)
  end
end
