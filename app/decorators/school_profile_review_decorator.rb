class SchoolProfileReviewDecorator < Draper::Decorator

  include ActionView::Helpers

  decorates :review
  delegate_all

  def five_star_rating?
    review.question.review_topic.id == 1
  end

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

  def numeric_answer_value
    v = answer_value
    return v if v.nil? || v.to_i > 0
    # This assumes the comma-separated list of reviews answers
    # are ordered from strongly disagree to strongly agree, which is currently
    # true
    index = question.responses.split(',').map(&:downcase).index(v.downcase)
    return nil if index.nil?
    return index + 1
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

  def topic_markup_with_overall
    return h.content_tag(:span, "#{t(topic_label)}:", class: 'pbs') unless review.question.overall?
    return h.content_tag(:span, "#{t('decorators.school_profile_review_decorator.overall')}:", class: 'pbs')
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

  def user_type_label
    "A #{user_type}"
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
      number_of_votes = review.try(:number_of_votes) || 0
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

  def answer_label
    question_answer_text = 
      review.question.question[0].downcase + 
      review.question.question[1..-2]

    prefix = answer.downcase == "neutral" ? "#{answer} about" : "#{answer} that"
    "#{prefix} #{question_answer_text}"
  end

  def created
    I18n.l(review.created, format: "%B %d, %Y")
  end
  alias_method :posted, :created

end
