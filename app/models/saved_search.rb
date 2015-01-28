class SavedSearch < ActiveRecord::Base
  self.table_name = 'saved_searches'

  db_magic :connection => :gs_schooldb

  belongs_to :user, foreign_key: 'member_id'

  validates_length_of :name, maximum: 255
  validates_presence_of :name, :member_id, :search_string, :num_results
  validates_numericality_of :member_id, :num_results

  before_save :process_name!

  scope :searches_named, ->(name) { where("name = '#{name}' or name like '#{name}%(%)'") }

  def process_name!
    searches_with_same_name = user.saved_searches.searches_named(self.name)

    if searches_with_same_name.count > 0
      last_searches_number = /\((\d*)\)$/.match(searches_with_same_name.last.name)
      number_to_append = last_searches_number.present? ? last_searches_number[1].to_i + 1 : 1
      self.name = "#{self.name}(#{number_to_append})"
    end
  end
end