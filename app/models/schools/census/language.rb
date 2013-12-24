class Language < ActiveRecord::Base
  self.table_name = 'language'
  self.inheritance_column = nil

  db_magic :connection => :gs_schooldb
end