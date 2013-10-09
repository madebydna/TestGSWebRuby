class TestDataStateValue < ActiveRecord::Base
  self.table_name = 'TestDataStateValue'
  octopus_establish_connection(:adapter => 'mysql2', :database => '_ca')
  attr_accessible :active, :data_set_id, :number_tested, :value_float, :value_text
  belongs_to :test_data_set, :class_name => 'TestDataSet', foreign_key: 'data_set_id'
end
