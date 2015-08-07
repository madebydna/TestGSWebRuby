class SchoolProfileReviewDecorator < Draper::Decorator

  include ActionView::Helpers

  decorates :review
  delegate_all

  def answer_markup
    default_text = t('decorators.school_profile_review_decorator.no_rating') # non five-star ratings must have answer specified, no always use 'no rating'
    if review.question.overall?
      star_rating.present? ? h.draw_stars_16(star_rating.to_i) : default_text
    else
      answer_value || default_text
    end
  end

  def answer_value
    unless review.answers.empty?
      h.db_t(review.answers.first.answer_value)
    end
  end

  def topic
    review.question.review_topic
  end

  def topic_label
    review.question.review_topic.label
  end

  def topic_markup
    h.content_tag(:span, "#{t(topic_label)}:", class: 'pbs') unless review.question.overall?
  end

  def topic_name
    h.db_t(review.question.review_topic.name)
  end

  def star_rating
    if review.question.overall?
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
    if review.school_user_or_default.unknown?
      t('decorators.school_profile_review_decorator.community_member')
    elsif review.school_user_or_default.principal?
      t('decorators.school_profile_review_decorator.school_leader')
    else
      h.db_t(review.school_user_or_default.user_type)
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

  def helpful_reviews_text
    @helpful_reviews_text ||= (
      number_of_votes = review.votes.active.size
      text = ''
      if number_of_votes > 0
        text << t('decorators.school_profile_review_decorator.persons', count: number_of_votes)
        text << t('decorators.school_profile_review_decorator.found_helpful', count: number_of_votes)
      end
      text
    )
  end

  def submitted_values_text
    submitted_value = answer_value
    submitted_value = t('decorators.school_profile_review_decorator.stars', count: answer_value) if topic.overall?
    text = t('decorators.school_profile_review_decorator.you_selected_html')
    text << h.content_tag('span', submitted_value, class: 'open-sans_cb')
    text.html_safe
  end

  def created
    review.created.strftime "%B %d, %Y"
  end
  alias_method :posted, :created

end
