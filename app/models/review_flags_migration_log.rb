class ReviewFlagsMigrationLog < ActiveRecord::Base
  self.table_name = 'review_flags_migration_logs'

  db_magic :connection => :gs_schooldb


end