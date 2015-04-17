# To be mixed in to an array of Reviews
# Requires methods from Enumerable
module ReviewScoping
  def by_user_type
    @by_user_type ||= (
      hash = group_by(&:user_type)
      hash.values.each do |array|
        array.extend ReviewScoping
        array.extend ReviewCalculations
      end
      hash.freeze
    )
  end

  %w[parent student principal].each do |user_type|
    define_method("#{user_type}_reviews") do
      by_user_type[user_type] || []
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
      array.freeze
    )
  end
end
