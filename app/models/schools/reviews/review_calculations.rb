# To be mixed in to an array of Reviews
# Requires methods from Enumerable
#
# Contains methods that, given a collection of reviews, can perform calculations on the reviews, including creating
# a distribution map of the number of times a given answer occurred. It is the caller's responsibility to make sure
# that calculations are being performed on the correct collection of reviews. For example, calling score_distribution
# on a collection that contains reviews for multiple questions (5 stars question vs 'too much homework' question)
# would give incorrect results
#
# These are things that SQL could do, but there are drawbacks. SQL queries can be complex and less reusable. At times
# we might already have an array of reviews in memory (after getting reviews that need to be displayed on page) and
# so we have everything we need to perform these calculations in Rails rather than from SQL. Regardless, this module
# provides the below methods for operating on collections of reviews that you have
module ReviewCalculations

  include ReviewScoping

  # move the having numeric answer to scoping
  def rating_scores_hash
    {
      avg_score: average_score.round,
      total: total_score,
      counter: count_having_rating
    }
  end

  def score_distribution
    @score_distribution ||= (
      reviews_by_answer = group_by(&:answer)
      reviews_by_answer.delete(nil)
      reviews_by_answer.delete(0)
      reviews_by_answer.each_with_object({}) { |(score, answers), hash| hash[score] = answers.size }.compact
    )
  end
  # only sum with ineteger
  def total_score
    @total_score ||= sum(&:answer)
  end

  def average_score
    @average_score ||= count_having_rating > 0 ? having_numeric_answer.sum(&:answer) / count_having_rating.to_f : 0
  end

  def having_numeric_answer
    @having_numeric_answer ||= select { |review| review.answer.present? && review.answer.to_i.to_s == review.answer.to_s }
  end

  def count_having_rating
    @count_having_rating ||= having_numeric_answer.count
  end
end
