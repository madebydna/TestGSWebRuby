# frozen_string_literal: true

class FavoriteSchoolLog < ActiveRecord::Base
  self.table_name = 'list_msl_log'
  db_magic :connection => :gs_schooldb
  # This table is intended to track user interactions with the saved school feature irrespective of whether the user is signed-in (using a UUID)
  # Its sister table is list_msl, which is the canonical source of saved school data for signed in users. 
  validates :uuid, :location, :state, :school_id, presence: true
end
