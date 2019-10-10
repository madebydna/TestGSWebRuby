# frozen_string_literal: true

class TestScoresCaching::TestScoresCacherGsdata < Cacher
  CACHE_KEY = 'test_scores_gsdata'

  DATA_TYPE_TAGS = %w(state_test)

  CACHE_EXCEPTIONS = :data_type, :percentage, :narrative, :label, :methodology

  ALT_NULL_STATE_FILTER = %w(ct il mt)

  def data_type_tags
    self.class::DATA_TYPE_TAGS
  end

  def build_hash_for_cache
    hashes = school_results.map { |r| result_to_hash(r) }
    hashes = inject_grade_all(hashes)
    school_cache_hash = Hash.new { |h, k| h[k] = [] }
    hashes.each_with_object(school_cache_hash) do |result_hash, cache_hash|
      result_hash = result_hash.to_hash
      if valid_result_hash?(result_hash)
        hash_name_changer!(result_hash)
        cache_hash[result_hash[:data_type]] << result_hash.except(*cache_exceptions)
      end
    end
  end

  def hash_name_changer!(hash)
    hash
  end

  def cache_exceptions
    %i(data_type percentage narrative label methodology)
  end

  def school_results
    @_school_results ||= begin
      qr = query_results.extend(TestScoreCalculations).select_items_with_max_year!
      school_results_filter(qr)
    end
  end

  def query_result_max_year
    query_results.extend(TestScoreCalculations).max_year
  end

  # This code is in support of JT-7249 - hopefully this will answer any questions
  def school_results_filter(qr)
    data_value = qr&.first
    state = data_value&.state&.downcase
    data_type_id = data_value&.data_type_id
    return qr unless data_type_id.present?

    if in_alt_whitelist?(state)
      if query_result_max_year < state_latest_year(data_type_id)
        return [] if school.high_school?
      end
    end
    qr
  end

  def in_alt_whitelist?(state)
    ALT_NULL_STATE_FILTER.include?(state)
  end

  def state_latest_year(data_type_id)
    @_state_latest_year ||= Omni::DataSet.max_year_for_data_type_id(data_type_id)
  end

  def query_results
    @query_results ||= Omni::TestDataValue.all_by_school(school.state, school.id)
  end

  def state_results_hash
    @_state_results_hash ||= begin
      state_values = Omni::TestDataValue.all_by_state(school.state)
      state_values.each_with_object({}) do |result, hash|
        state_key = Omni::TestDataValue.datatype_breakdown_year(result)
        hash[state_key] = result
      end
    end
  end

  def district_results_hash
    @_district_results_hash ||= begin
      district_values = Omni::TestDataValue.all_by_district(school.state, school.district_id)
      district_values.each_with_object({}) do |result, hash|
        district_key = Omni::TestDataValue.datatype_breakdown_year(result)
        hash[district_key] = result.value
      end
    end
  end

  def inject_grade_all(hashes)
    # Stub for TestScoresCaching::GradeAllCalculatorGsdata, which should reference the new gsdata schema columns
    SchoolGradeAllCalculator.new(
      GsdataCaching::GsDataValue.from_array_of_hashes(hashes)
    ).inject_grade_all
  end

  def self.listens_to?(data_type)
    data_type == :test_scores
  end

  # private
  def result_to_hash(result)
    breakdowns = result.breakdown_names
    breakdown_tags = result.breakdown_tags
    academics = result.academic_names
    academic_tags = result.academic_tags
    # academic_types = result.academic_types
    # display_range = display_range(result)
    state_result = state_result(result)
    district_value = district_value(result)
    {}.tap do |h|
      h[:data_type] = result.name  #data_type.short_name
      h[:breakdowns] = breakdowns # if breakdowns
      h[:breakdown_tags] = breakdown_tags # if breakdown_tags
      h[:school_value] = result.value  #data_value.value
# rubocop:disable Style/FormatStringToken
      h[:source_date_valid] = result.date_valid  #source.data_valid
# rubocop:enable Style/FormatStringToken
# rubocop:disable Style/SafeNavigation
      h[:state_value] = state_result.value if state_result && state_result.value #data_type.value

      h[:district_value] = district_value if district_value   #data_type.value
      h[:source_name] = result.source    #source.name
      h[:description] = result.description if result.description    #source.description
      h[:school_cohort_count] = result.cohort_count if result.cohort_count #data_value.cohort_count
      h[:academics] = academics # if academics   #data_value.academics.pluck(:name).join(',')
      h[:academic_tags] = academic_tags # if academic_tags  #academic_tags.tag...comma separated string for all records associated with data value
      h[:grade] = result.grade if result.grade  #data_value.grade
      h[:state_cohort_count] = state_result.cohort_count if state_result && state_result.cohort_count  #data_value.cohort_count
# rubocop:enable Style/SafeNavigation
    end
  end

  def valid_result_hash?(result_hash)
    result_hash = result_hash.reject { |_,v| v.blank? }
    required_keys = %i(school_value source_date_valid source_name)
    missing_keys = required_keys - result_hash.keys
    if missing_keys.count.positive?
      GSLogger.error(
        :school_cache,
        nil,
        message: "#{self.class.name} cache missing required keys",

        vars: { school: school.id,
                state: school.state,
                data_type: result_hash[:data_type],
                breakdowns: result_hash[:breakdowns],
        }
      )
    end
    missing_keys.count.zero?
  end

  def district_value(result)
    #   will not have district values if school is private
    return nil unless school.district_id.positive?
    district_results_hash[Omni::TestDataValue.datatype_breakdown_year(result)]
  end

  def state_result(result)
    state_results_hash[Omni::TestDataValue.datatype_breakdown_year(result)]
  end

end
