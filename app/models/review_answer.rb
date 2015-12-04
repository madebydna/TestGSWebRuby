class ReviewAnswer < ActiveRecord::Base

  self.table_name = 'review_answers'

  db_magic :connection => :gs_schooldb

  belongs_to :review, inverse_of: :answers

  
  alias_attribute :value, :answer_value

  def label
    if review.topic.overall?
      I18n.t('models.review_answer.stars_label', count: value.to_i)
    else
      value
    end
  end

end
