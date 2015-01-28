class TestDataSubject < ActiveRecord::Base
  self.table_name = 'TestDataSubject'
  db_magic :connection => :gs_schooldb
end