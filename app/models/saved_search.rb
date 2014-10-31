class SavedSearch < ActiveRecord::Base
  self.table_name = 'saved_searches'

  db_magic :connection => :gs_schooldb

  belongs_to :user, foreign_key: 'member_id'

  validates_length_of :name, maximum: 255
  validates_presence_of :name, :member_id, :search_string, :num_results
  validates_numericality_of :member_id, :num_results

  scope :searches_named, ->(name) { where("name REGEXP ?" , "^#{name}$|^#{name}[(][0-9]+[)]$") }

end