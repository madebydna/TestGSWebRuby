# frozen_string_literal: true

class StateRatingCacher < StateCacher
  CACHE_KEY = 'ratings'.freeze

  # This is not a true State Rating hash as omni currently does not
  # have state entity data loaded. For data type ids 157 and 159, the latest data set from
  # school was used. Need to discuss how to tackle this
  
  # DATA_TYPES INCLUDED
  # 157	Student Progress Rating
  # 159	Academic Progress Rating

  DATA_TYPE_IDS = %w(157 159)

  def state_results
    # no breakdown ids needed for this data type
    # add in 'breakdowns.name to select if separating by breakdown'
    @_state_results ||= Omni::Rating.joins(data_set: [:data_type, :source])
                                    .school_entity
                                    .order('data_sets.date_valid DESC')
                                    .active
                                    .select('data_sets.date_valid, data_sets.description, sources.name as source, data_types.name, data_types.id as data_type_id')
                                    .distinct
  end

  def build_hash_for_cache
    @_build_hash_for_cache ||= (
      state_cache_hash = Hash.new { |h, k| h[k] = [] }

      valid_data = state_results.group_by(&:data_type_id).reduce([]) do |accum, (data_type_id, data_values)|
        most_recent_date = data_values.map(&:date_valid).max
        data_values.select! {|dv| dv.date_valid == most_recent_date}
        accum.concat(data_values)
      end

      valid_data.each_with_object(state_cache_hash) do |result, cache_hash|
        result_hash = result_to_hash(result)
        state_cache_hash[result.name] << result_hash
      end
    )
  end

  # can add breakdowns, state_value, breakdown_tags when available here
  def result_to_hash(result)
    {}.tap do |h|
      h['year'] = result.date_valid.year
      h['source_date_valid'] = result.date_valid
      h['source_name'] = result.source
      h['description'] = result.description if result.description
    end
  end
end