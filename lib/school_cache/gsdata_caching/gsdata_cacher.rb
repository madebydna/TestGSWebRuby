# cache data for schools from the gsdata database
class GsdataCaching::GsdataCacher < Cacher
  CACHE_KEY = 'gsdata'.freeze
  DATA_TYPE_IDS = [51, 91, 35, 95, 119, 149].freeze

  def build_hash_for_cache
    cache_hash = {}
    school_results.each do |result|
      result_hash = result_to_hash(result)
      result_hash[:state_value] = state_results_hash[result.datatype_breakdown_year]
      result_hash[:district_value] = district_results_hash[result.datatype_breakdown_year]
      display_range = display_range(result)
      result_hash[:display_range] = display_range if display_range
      if cache_hash[result.name]
        cache_hash[result.name] << result_hash
      else
        cache_hash[result.name] = [result_hash]
      end
    end
    cache_hash
  end

  def school_results
    @_school_results ||=
      DataValue
      .value_for_school_and_data_type_by_breakdown(
        school,
        DATA_TYPE_IDS
      )
  end

  def state_results_hash
    @_state_results_hash ||= (
      DataValue.value_for_state_by_breakdown(school.state, DATA_TYPE_IDS)
      .each_with_object({}) do |r, h|
        state_key = r.datatype_breakdown_year
        h[state_key] = r.value
      end
    )
  end

  def district_results_hash
    @_district_results_hash ||= (
      DataValue
      .value_for_district_by_breakdown(
        school.state,
        school.district_id,
        DATA_TYPE_IDS
      )
      .each_with_object({}) do |r, h|
        district_key = r.datatype_breakdown_year
        h[district_key] = r.value
      end
    )
  end

  # after display range strategy is chosen will need to update method below
  def display_range(_result)
    nil
    # DisplayRange.for({
    #   data_type:    'gsdata',
    #   data_type_id: result.data_type_id,
    #   state:        result.state,
    #   year:         year,
    #   value:        result.value
    # })
  end

  def result_to_hash(result)
    {
      school_value: result.value,
      breakdowns: result.breakdowns,
      source_name: result.source_name,
      source_year: result.date_valid.year
    }
  end

  def self.listens_to?(data_type)
    :gsdata == data_type
  end
end
