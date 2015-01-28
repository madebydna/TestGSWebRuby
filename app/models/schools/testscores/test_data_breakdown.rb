class TestDataBreakdown < ActiveRecord::Base
  self.table_name = 'TestDataBreakdown'
  db_magic :connection => :gs_schooldb
end