class ReviewMapping < ActiveRecord::Base
  self.table_name = 'review_mappings'

  db_magic :connection => :gs_schooldb


end