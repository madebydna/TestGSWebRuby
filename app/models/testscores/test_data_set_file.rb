class TestDataSetFile < ActiveRecord::Base
  octopus_establish_connection(:adapter => 'mysql2', :database => 'gs_schooldb')
  self.inheritance_column = nil
  self.table_name = 'TestDataSetFile'
  attr_accessible :data_file_id, :data_set_id, :school_type, :state, :type
end
