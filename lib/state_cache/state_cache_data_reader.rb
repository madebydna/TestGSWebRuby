# frozen_string_literal: true

class StateCacheDataReader
  STATE_CACHE_KEYS = %w(metrics district_largest test_scores_gsdata school_levels state_attributes ratings)

  attr_reader :state, :state_cache_keys

  def initialize(state, state_cache_keys: STATE_CACHE_KEYS)
    self.state = state
    @state_cache_keys = state_cache_keys
  end

  def decorated_state
    @_decorated_state ||= decorate_state(state)
  end

  def ethnicity_data
    decorated_state.ethnicity_data
  end

  def largest_districts
    decorated_state.largest_districts
  end

  def test_scores
    decorated_state.test_scores
  end

  def school_levels
    decorated_state.school_levels
  end

  def state_attributes
    decorated_state.state_attributes
  end

  def state_attribute(cache_key)
    decorated_state.state_attribute(cache_key)
  end

  def ratings
    decorated_state.ratings
  end

  def flat_test_scores_for_latest_year
    @_flat_test_scores_for_latest_year ||= begin
      if test_scores.any? {|test_score| test_score.is_a?(Hash)}
        array_of_hashes = test_scores.map {|hash| hash.stringify_keys}
        GsdataCaching::GsDataValue.from_array_of_hashes(array_of_hashes).having_most_recent_date
      else
        hashes = test_scores.each_with_object([]) do |(data_type, hash_array), array|
          array.concat(
            hash_array.map do |test_scores_hash|
              {
                data_type: data_type,
                description: test_scores_hash['description'],
                source_name: test_scores_hash['source_name'],
                breakdowns: test_scores_hash['breakdowns'],
                breakdown_tags: test_scores_hash['breakdown_tags'],
                source_date_valid: test_scores_hash['source_date_valid'],
                academics: test_scores_hash['academics'],
                grade: test_scores_hash['grade'],
                district_value: test_scores_hash['district_value'],
                district_cohort_count: test_scores_hash['district_cohort_count'],
                state_cohort_count: test_scores_hash['state_cohort_count'],
                state_value: test_scores_hash['state_value'],
              }
            end
          )
        end
        GsdataCaching::GsDataValue.from_array_of_hashes(hashes).having_most_recent_date
      end
    end
  end

  def recent_test_scores
    flat_test_scores_for_latest_year
      .having_state_value
      .sort_by_cohort_count
      .having_academics
  end

  def recent_test_scores_without_subgroups
    recent_test_scores
      .for_all_students
  end

  def decorated_metrics_datas(*keys)
    decorated_state.decorated_metrics.slice(*keys)
  end

  def decorated_metrics_data(key)
    Array.wrap(decorated_state.decorated_metrics.slice(key)[key])
    .extend(MetricsCaching::Value::CollectionMethods)
  end

  def remediation_data
    decorated_state.graduates_remediation
  end

  def state_cache_query
    StateCacheQuery.for_state(state).tap do |query|
      query.include_cache_keys(state_cache_keys)
    end
  end

  def decorate_state(state)
    query_results = state_cache_query.query
    state_cache_results = StateCacheResults.new(state_cache_keys, query_results)
    state_cache_results.decorate_state(state)
  end

  private

  def state=(state)
    raise ArgumentError.new('State must be provided') if state.nil?
    @state = state
  end
end

