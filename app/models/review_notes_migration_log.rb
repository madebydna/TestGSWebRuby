class ReviewNotesMigrationLog < ActiveRecord::Base
  self.table_name = 'review_notes_migration_logs'

  db_magic :connection => :gs_schooldb


end