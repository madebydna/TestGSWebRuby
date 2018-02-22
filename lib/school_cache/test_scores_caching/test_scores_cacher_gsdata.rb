# frozen_string_literal: true

class TestScoresCaching::TestScoresCacherGsdata < Cacher
  CACHE_KEY = 'test_scores_gsdata'

  DATA_TYPE_TAGS = ['rating']

  def data_type_tags
    self.class::DATA_TYPE_TAGS
  end

  def data_type_ids
    @_data_type_ids ||= DataTypeTag.data_type_ids_for(data_type_tags).uniq
  end

  def build_hash_for_cache
    school_cache_hash = Hash.new { |h, k| h[k] = [] }
    school_results.each_with_object(school_cache_hash) do |result, cache_hash|
      result_hash = result_to_hash(result)
      if valid_result_hash?(result_hash, result.data_type_id)
        cache_hash[result.name] << result_hash
      end
    end
  end

  def school_results
    @_school_results ||=
      begin
        results = query_results.extend(TestScoreCalculations).select_items_with_max_year!
        # inject_grade_all(results)
      end
  end

  def query_results
    @query_results ||=
      begin
        DataValue
          .find_by_school_and_data_type_tags(school, data_type_tags)
          .reject {|result| result.district_id.blank?}
      end
  end

  def state_results_hash
    @_state_results_hash ||= begin
      state_values = DataValue.find_by_state_and_data_types(school.state,
                                                            data_type_ids)
      state_values.each_with_object({}) do |result, hash|
        state_key = result.datatype_breakdown_year
        hash[state_key] = result.value
      end
    end
  end

  def district_results_hash
    @_district_results_hash ||= begin
      district_values = DataValue.find_by_district_and_data_types(school.state,
                                                                  school.district_id,
                                                                  data_type_ids)
      district_values.each_with_object({}) do |result, hash|
        district_key = result.datatype_breakdown_year
        hash[district_key] = result.value
      end
    end
  end

  def inject_grade_all(data_sets_and_values)
    # Stub for TestScoresCaching::GradeAllCalculatorGsdata, which should reference the new gsdata schema columns
    # Old GradeAllCalculator: TestScoresCaching::GradeAllCalculator.new(data_sets_and_values).inject_grade_all
  end

  def self.listens_to?(data_type)
    data_type == :test_scores
  end

  private

  def result_to_hash(result)
    breakdowns = result.breakdowns
    breakdown_tags = result.breakdown_tags
    state_value = state_value(result)
    district_value = district_value(result)
    {}.tap do |h|
      h[:breakdowns] = breakdowns if breakdowns
      h[:breakdown_tags] = breakdown_tags if breakdown_tags
      h[:school_value] = result.value
      h[:source_date_valid] = result.date_valid.strftime('%Y%m%d %T')
      h[:state_value] = state_value.value if state_value
      h[:district_value] = district_value.value if district_value
      h[:source_name] = result.source_name
      h[:description] = result.source.description if result.source
      h[:number_students_tests] = result.cohort_count if result.cohort_count
      h[:academics] = result.academics if result.academics
      h[:academic_tags] = result.academics.tags
      h[:grades] = result.grades if result.grades
      h[:state_number_tested] = state_value.cohort_count if state_value
      # h[:flags] = result.flags
      h[:test_label] = result.data_type.name
    end
  end

  def valid_result_hash?(result_hash, data_type_id)
    result_hash = result_hash.reject { |_,v| v.blank? }
    required_keys = %i(school_value source_date_valid source_name)
    missing_keys = required_keys - result_hash.keys
    if missing_keys.count.positive?
      GSLogger.error(
        :school_cache,
        message: "#{self.class.name} cache missing required keys",
        vars: { school: school.id,
                state: school.state,
                data_type_id: data_type_id,
                breakdowns: result_hash['breakdowns'],
        }
      )
    end
    missing_keys.count.zero?
  end


  def district_value(result)
    #   will not have district values if school is private
    return nil unless school.district_id.positive?
    district_results_hash[result.datatype_breakdown_year]
  end

  def state_value(result)
    state_results_hash[result.datatype_breakdown_year]
  end


end
