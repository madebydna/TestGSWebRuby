class CensusDataType < ActiveRecord::Base
  self.table_name = 'census_data_type'
  self.inheritance_column = nil

  db_magic :connection => :gs_schooldb
end