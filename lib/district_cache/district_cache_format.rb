module DistrictCacheFormat
  include CacheValidation

  def build_hash_for_cache
    hash = {}
    query_results.each do |result|
      hash[result.label] = [] unless hash.key? result.label
      additional_data = build_hash_for_data_set(result)
      hash[result.label] << additional_data if additional_data
    end
    validate!(hash)
  end

  def build_hash_for_data_set(result)
    return nil unless result.school_value || result.state_average
    hash = {}
    data_keys.each do |key|
      value = result.try(key)
      if value
        hash[key] = value
        if key == :breakdown
          if (config = result.data_set_with_values.try(:census_data_config_entry))
            hash[key] = config.label
          end
          hash[:original_breakdown] = value
        end
      end
    end
    build_historical_data!(result, hash)
    hash
  end

  def build_historical_data!(data, hash)
    subject_id = data.send(:subject_id)
    breakdown_id = data.send(:breakdown_id)
    data_type_id = data.send(:data_type_id)

    historical_data = @all_results.select do | data_set |
      data_set.data_type_id == data_type_id &&
      data_set.subject_id == subject_id &&
      data_set.breakdown_id == breakdown_id
    end

    set_hash_values!(historical_data, hash)
  rescue => e
    GSLogger.error(
      :school_cache,
      e,
      message: 'failed in building historical data for school',
      vars: {school:school.id, state: school.state}
    )
  end

  def data_keys
    [
      :breakdown,
      :created,
      :district_average,
      :grade,
      :performance_level,
      :school_value,
      :source,
      :state_average,
      :subject,
      :year
    ]
  end

  def set_hash_values!(data_sets, hash)
    data_sets.each do | data |
      next unless (year = data.year).present?
      hash["school_value_#{year}".to_sym] = data.school_value if data.school_value.present?
      hash["state_average_#{year}".to_sym] = data.state_average if data.state_average.present?
      hash["performance_level_#{year}".to_sym] = data.performance_level if data.performance_level.present?
    end
  end
end
