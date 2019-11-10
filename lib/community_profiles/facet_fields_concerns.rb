# frozen_string_literal: true

module CommunityProfiles::FacetFieldsConcerns
  BELOW_AVERAGE = %w(1 2 3 4)
  AVERAGE = %w(5 6)
  ABOVE_AVERAGE = %w(7 8 9 10)
  BELOW_AVERAGE_KEY = 'below_average'
  AVERAGE_KEY = 'average'
  ABOVE_AVERAGE_KEY = 'above_average'
  RATINGS_KEYS_ARRAY = [BELOW_AVERAGE_KEY, AVERAGE_KEY, ABOVE_AVERAGE_KEY]

  def range
    community_results_percentages.values.max - community_results_percentages.values.min
  end

  def narration_logic
    top_two_ratings_by_percentage_array = 
      community_results_percentages.sort_by {|rating, percentage| percentage}
                                    .reverse
                                    .first(2)
    return 'even_distribution' if range < 4 || top_two_ratings_by_percentage_array.first[1] == top_two_ratings_by_percentage_array.last[1]
    
    top_two_ratings_by_percentage_array.first[0]
  end

  def school_counts(facet_results)
    result_set = Hash.new(0)

    facet_results.each_slice(2) do |score, count|
      if BELOW_AVERAGE.include?(score)
        result_set[BELOW_AVERAGE_KEY] += count
      elsif AVERAGE.include?(score)
        result_set[AVERAGE_KEY] += count
      elsif ABOVE_AVERAGE.include?(score)
        result_set[ABOVE_AVERAGE_KEY] += count
      else
        GSLogger.error(:community_profiles, nil, message:"facet fields returned invalid score for #{self.class}", vars: school)
        raise StandardError.new("facet fields returned invalid score for #{self.class}")
      end
    end

    result_set
  end

  def total_schools(result_set)
    result_set.values.reduce(:+) || 0
  end

  def convert_to_percentage_hash(result_set)
    return {} if total_schools(result_set).zero?
    RATINGS_KEYS_ARRAY.each_with_object({}) do |key, hash|
      hash[key] = ((result_set[key].to_f / total_schools(result_set)) * 100).round
    end
  end
end