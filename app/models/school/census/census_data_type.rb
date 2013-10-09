class CensusDataType < ActiveRecord::Base
  self.table_name = 'census_data_type'
  self.inheritance_column = nil

  octopus_establish_connection(:adapter => "mysql2", :database => "gs_schooldb")
end