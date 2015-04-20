# To be mixed in to an array of Reviews
# Requires methods from Enumerable
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
  @having_numeric_answer ||= select { |review| review.answer.present? && review.answer.to_i.to_s == review.answer }
  end

  def count_having_rating
    @count_having_rating ||= having_numeric_answer.count
  end
end
