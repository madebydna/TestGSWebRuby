# This module isn't a Draper decorator, but probably should be
# I was having issues with Draper that I believe were resolved after I already changed this to be a non-draper decorator
#
# This decorator is meant to decorate a SchoolReviews object (hence plural form of Review in the name)
# It might be better if it decorated an enumerable collection of reviews that extends the ReviewCalculations module,
# since that's more generic than the SchoolReviews class

# This decorator knows how to use the (5 star rating) review answer distribution map, and turn it into an array
# that our bar chart code (using google charts) knows how to understand
module SchoolProfileReviewsDecorator

  def self.decorate(school_reviews, view_context)
    school_reviews.extend self
    school_reviews.instance_variable_set(:@view_context, view_context)
    school_reviews
  end

  def h
    @view_context
  end

  def answer_summary_text
    return nil unless score_distribution.present?
    distribution = score_distribution.sort_by { |k, v| v }.reverse
    text =  "Most users (#{distribution.first.last}) say "
    text << h.content_tag('span', distribution.first.first, class:'open-sans_cb')
    text.html_safe
  end

  def see_comments_text
    text = "See ratings"
    number_with_comments = having_comments.count
    if number_with_comments > 0
      text = 'See '
      text << 'all ' if number_with_comments > 1
      text << h.pluralize(number_with_comments, 'comment', 'comments')
    end
    text
  end

  def see_all_reviews_phrase
    phrase = 'See '
    phrase << 'all ' if count > 1
    phrase << h.pluralize(count, 'review', 'reviews')
    phrase
  end

  def reviews_count_text
    h.pluralize(count, 'review', 'reviews')
  end

  def comments_count_text
    h.pluralize(having_comments.count, 'comment', 'comments')
  end

  def question_text
    first_topic.first_question.question
  end

  # Given a hash for review answer distribution, turn it into an array that will be used to render a bar chart
  def to_bar_chart_array
    topic = first_topic
    topic_distribution = score_distribution.gs_rename_keys(&:to_s)
    topic_keys = topic.review_questions.first.response_array
    topic_keys = Hash[topic_keys.reverse.zip(Array.new(topic_keys.count, 0))]
    topic_distribution = topic_keys.merge(topic_distribution)

    chart = [
        [topic.name, 'count']
    ]

    topic_distribution.each_with_object(chart) do |(label, number_of_occurrences), chart_array|
      if topic.overall?
        label = h.pluralize(label, 'star', 'stars')
      end
      chart_array << [label, number_of_occurrences]
    end
  end

end