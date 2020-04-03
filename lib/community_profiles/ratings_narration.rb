# frozen_string_literal: true

module CommunityProfiles
  class RatingsNarration
    BELOW_AVERAGE_KEY = 'below_average'
    AVERAGE_KEY = 'average'
    ABOVE_AVERAGE_KEY = 'above_average'

    RATING_RUBRIC_HASH = {
      '1' => BELOW_AVERAGE_KEY,
      '2' => BELOW_AVERAGE_KEY,
      '3' => BELOW_AVERAGE_KEY,
      '4' => BELOW_AVERAGE_KEY,
      '5' => AVERAGE_KEY,
      '6' => AVERAGE_KEY,
      '7' => ABOVE_AVERAGE_KEY,
      '8' => ABOVE_AVERAGE_KEY,
      '9' => ABOVE_AVERAGE_KEY,
      '10' => ABOVE_AVERAGE_KEY
    }

    attr_reader :result_set

    # flat_result_set is a flat array mapping key to value like shown:
    # ['1', 45, '2', 13, '3', 4]
    def initialize(flat_result_set)
      @result_set = ratings_hash(flat_result_set)
    end

    def ratings_hash(flat_result_set)
      @_ratings_hash ||=begin
        rating_hash = Hash.new(0)

        flat_result_set.each_slice(2) { |score, count| rating_hash[RATING_RUBRIC_HASH[score]] += count }
        GSLogger.error(:community_profiles, nil, message:"flat array has unknown keys", vars: flat_result_set) if rating_hash.has_key?(nil)

        rating_hash
      end
    end

    def total_counts
      result_set.values.reduce(:+) || 0
    end

    def ratings_percentage_hash
      @_ratings_percentage_hash ||=begin
        return {} if total_counts.zero?

        RATING_RUBRIC_HASH.values.uniq.each_with_object({}) {|key, hash| hash[key] = ((result_set[key].to_f / total_counts) * 100).round }
      end
    end

    # logic dictating what should be displayed for the ratings narration
    # It is as follows:
    # 1) If there is only one max value, return that rating
    # 2) If the largest value and second largest value is equal, return equal distribution
    # 3) if the range between the max value and min value is less than 4, return equal distribution
    def narration_logic
      sorted_flat_arrays =
        ratings_percentage_hash.sort_by(&:last)
                               .reverse
                               .first(2)

      largest = sorted_flat_arrays.first
      second_largest = sorted_flat_arrays.last

      return 'even_distribution' if range < 4 || largest.last == second_largest.last
      largest.first
    end

    private

    def range
      ratings_percentage_hash.values.max - ratings_percentage_hash.values.min
    end
  end
end