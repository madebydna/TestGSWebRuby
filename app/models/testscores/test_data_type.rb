class TestDataType < ActiveRecord::Base
  attr_accessible :description, :display_name, :display_type, :name, :type
  has_many :test_data_sets, class_name: 'TestDataSet', foreign_key: 'data_type_id'
end
