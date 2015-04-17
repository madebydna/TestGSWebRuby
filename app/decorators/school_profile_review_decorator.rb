class SchoolProfileReviewDecorator < Draper::Decorator

  include ActionView::Helpers

  decorates :review
  delegate_all

  def star_rating
    value = review.answer
    value = nil if value < 1 || value > 5
    value
  end

  def user_type
    if review.user_type.blank? || review.user_type == 'unknown'
      'community member'
    else
      review.user_type
    end
  end

  def has_comment?
    review.comment.present?
  end

  def comment
    if review.comment.blank?
      h.content_tag(:div, 'This review submitted without content.', class: 'well mbn' )
    else
      review.comment
    end
  end

  def truncated_comment(length = 45)
    if review.comment.present?
      h.truncate(comment, length: length, separator: ' ')
    end
  end

  def created
    review.created.strftime "%B %d, %Y"
  end
  alias_method :posted, :created

end
