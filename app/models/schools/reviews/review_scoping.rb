# To be mixed in to an array of Reviews
# Requires methods from Enumerable
module ReviewScoping
  FIVE_STAR_RATING_TOPIC_NAME = 'Five star rating'

  def empty_extended_array
    value = []
    value.extend ReviewScoping
    value.extend ReviewCalculations
    value
  end

  def by_user_type
    @by_user_type ||= (
      hash = Hash.new { empty_extended_array }.merge(
        group_by(&:user_type)
      )
      hash.values.each do |array|
        array.extend ReviewScoping
        array.extend ReviewCalculations
      end
      hash.freeze
    )
  end

  def by_topic
    @by_topic ||= (
      hash = Hash.new { empty_extended_array }.merge(
        group_by { |review| review.question.review_topic.name }
      )
      hash.values.each do |array|
        array.extend ReviewScoping
        array.extend ReviewCalculations
      end
      hash.freeze
    )
  end

  def five_star_rating_reviews
    by_topic[FIVE_STAR_RATING_TOPIC_NAME]
  end

  %w[parent student principal].each do |user_type|
    define_method("#{user_type}_reviews") do
      by_user_type[user_type] || empty_extended_array
    end
  end

  def has_principal_review?
    principal_reviews.present?
  end

  def principal_review
    principal_reviews.first
  end

  def having_comments
    @having_comments ||= (
      array = select(&:has_comment?)
      array.extend ReviewScoping
      array.extend ReviewCalculations
      # if you set it to an array and add back the other modules and then freeze it to prevent others from modifying the array
      array.freeze
    )
  end

  def number_with_comments
    having_comments.size
  end
end
