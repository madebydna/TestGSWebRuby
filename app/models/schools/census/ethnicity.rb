class Ethnicity < ActiveRecord::Base
  self.table_name = 'ethnicity'
  self.inheritance_column = nil

  db_magic :connection => :gs_schooldb
end