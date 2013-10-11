class TestDataSchoolValue < ActiveRecord::Base
  self.table_name = 'TestDataSchoolValue'
  include StateSharding
  attr_accessible :active, :data_set_id, :number_tested, :school_id, :value_float, :value_text
  belongs_to :test_data_set, :class_name => 'TestDataSet', foreign_key: 'data_set_id'
end
