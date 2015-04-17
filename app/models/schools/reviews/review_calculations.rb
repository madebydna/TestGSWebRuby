# To be mixed in to an array of Reviews
# Requires methods from Enumerable
module ReviewCalculations
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

  def total_score
    @total_score ||= sum(&:answer)
  end

  def average_score
    @average_score ||= count_having_rating > 0 ? sum(&:answer) / count_having_rating.to_f : 0
  end

  def count_having_rating
    @count_having_rating ||= count { |review| review.answer.present? && review.answer > 0 }
  end
end
