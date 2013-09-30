class TestDataSchoolValue < ActiveRecord::Base
  self.table_name = 'TestDataSchoolValue'
  attr_accessible :active, :data_set_id, :number_tested, :school_id, :value_float, :value_text
end
