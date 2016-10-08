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
      counter: count_having_numeric_answer
    }
  end

  def score_distribution
    @score_distribution ||= (
      reviews_by_answer = group_by(&:answer)
      reviews_by_answer.delete(nil)
      reviews_by_answer.each_with_object({}) { |(score, answers), hash| hash[score] = answers.size }.compact
    )
  end

  def number_of_distinct_users
    group_by(&:member_id).keys.size
  end

  # only sum with integer
  def total_score
    @total_score ||= having_numeric_answer.sum(&:answer_as_int)
  end

  def average_score
    @average_score ||= count_having_numeric_answer > 0 ? total_score / count_having_numeric_answer.to_f : 0
  end

  def having_numeric_answer
    @having_numeric_answer ||= select { |review| review.answer.present? && review.answer.to_i.to_s == review.answer.to_s }
  end

  def count_having_numeric_answer
    @count_having_rating ||= having_numeric_answer.count
  end

  def score_distribution_with_percentage
    # score distribution is only for reviews from the same topic question
    return nil if map(&:topic).map(&:name).uniq.count > 1

    response_hash = first.question.chart_response_label_array.each_with_object({}) do |(response_label), hash|
      hash[response_label] = {count: 0, percentage: '0', label: response_label } 
    end
    group_by_labels = group_by(&:answer_label)
    group_by_labels.delete(nil)
    score_distribution = ( 
     group_by_labels.each_with_object(response_hash) do |(answer_label, answers), hash|
        answers_count = answers.size
        percentage = (answers_count / count.to_f * 100).round(0).to_s
        hash[answer_label] =  {count: answers_count, percentage: percentage, label: answer_label }
      end
    )
    score_distribution.values.reverse
  end

  def count_by_topic
    by_topic.map{ |k, v| [k, v.length] }.to_h.except('Overall')
  end

  def topic_answers_to_numeric
    {
        'Strongly disagree' => 1,
        'Disagree' => 2,
        'Neutral' => 3,
        'Agree' => 4,
        'Strongly agree' => 5
    }
  end

  def numeric_topic_answer_grouping
    {
        1 => 'Disagree',
        2 => 'Disagree',
        3 => 'Neutral',
        4 => 'Agree',
        5 => 'Agree'
    }
  end

  def average_score_by_topic
    hash = {}
    by_topic.each do |topic, reviews|
      next if topic == 'Overall'
      topic_answer_values = []
      reviews.each do |review|
        topic_answer_values << topic_answers_to_numeric[review.answer] unless topic_answers_to_numeric[review.answer].nil?
      end
      hash[topic] = (topic_answer_values.sum.to_f / topic_answer_values.length)
      end
    hash
  end

  def topical_review_summary
    topical_hash = Hash.new { |hash, key| hash[key] = Hash.new(&hash.default_proc) }
    count_by_topic.each do |topic, topic_count|
      topical_hash[topic][:count] = topic_count
    end
    average_score_by_topic.each do |topic, average_score|
      topical_hash[topic][:average] = numeric_topic_answer_grouping[average_score.round.to_i]
    end
    topical_hash
  end
end
