class ReviewFlagsMigrationLog < ActiveRecord::Base
  self.table_name = 'review_flags_migration_logs'

  db_magic :connection => :gs_schooldb

  validates_presence_of(:reported_entity_id, :review_flag_id)
end