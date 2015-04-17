class ReviewAnswer < ActiveRecord::Base
  self.table_name = 'review_answers'

  db_magic :connection => :gs_schooldb

  belongs_to :review, foreign_key: 'review_id'

  alias_attribute :value, :answer_value

end