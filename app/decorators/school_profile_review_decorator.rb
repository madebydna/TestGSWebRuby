class SchoolProfileReviewDecorator < Draper::Decorator

  include ActionView::Helpers

  decorates :review
  delegate_all

  def answer_markup
    default_text = 'no rating' # non five-star ratings must have answer specified, no always use 'no rating'
    if review.question.stars_question?
      star_rating.present? ? h.draw_stars_16(star_rating.to_i) : default_text
    else
      answer_value || default_text
    end
  end

  def answer_value
    unless review.answers.empty?
      review.answers.first.answer_value
    end
  end

  def topic_label
    topic_name
  end

  def topic_markup
    h.content_tag(:span, "#{topic_label}:", class: 'pbs') unless review.question.stars_question?
  end

  def topic_name
    review.question.review_topic.name
  end

  def star_rating
    if review.question.stars_question?
      value = review.answer.to_i
      if value
        value = nil if value < 1 || value > 5
      end
      value
    else
      nil
    end
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
