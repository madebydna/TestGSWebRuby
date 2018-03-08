# frozen_string_literal: true

class TestScoresCaching::TestScoresCacherGsdata < Cacher
  CACHE_KEY = 'test_scores_gsdata'

  DATA_TYPE_TAGS = ['state_test']

  def data_type_tags
    self.class::DATA_TYPE_TAGS
  end

  def data_type_ids
    @_data_type_ids ||= DataTypeTag.data_type_ids_for(data_type_tags).uniq
  end

  def build_hash_for_cache
    hashes = school_results.map { |r| result_to_hash(r) }
    hashes = inject_grade_all(hashes)
    school_cache_hash = Hash.new { |h, k| h[k] = [] }
    hashes.each_with_object(school_cache_hash) do |result_hash, cache_hash|
      result_hash = result_hash.to_hash
      if valid_result_hash?(result_hash)
        cache_hash[result_hash[:data_type]] << result_hash.except(:data_type, :percentage, :narrative, :label, :methodology)
      end
    end
  end

  def school_results
    @_school_results ||= query_results.extend(TestScoreCalculations).select_items_with_max_year!
  end

  def query_results
    @query_results ||=
      begin
        DataValue
          .find_by_school_and_data_type_tags(school, data_type_tags)
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

  def inject_grade_all(hashes)
    # Stub for TestScoresCaching::GradeAllCalculatorGsdata, which should reference the new gsdata schema columns
    TestScoresCaching::GradeAllCalculator.new(
      GsdataCaching::GsDataValue.from_array_of_hashes(hashes)
    ).inject_grade_all
  end

  def self.listens_to?(data_type)
    data_type == :test_scores
  end

  # private
  def result_to_hash(result)
    breakdowns = result.breakdown_names
    breakdown_tags = result.breakdown_tag_names
    academics = result.academic_names
    academic_tags = result.academic_tags
    # academic_types = result.academic_types
    # display_range = display_range(result)
    b_and_a = [breakdowns, academics].reject { |item| item.blank? }.join(',')
    b_and_a_tags = [breakdown_tags, academic_tags].reject { |item| item.blank? }.join(',')
    state_value = state_value(result)
    district_value = district_value(result)
    {}.tap do |h|
      h[:data_type] = result.name  #data_type.short_name
      h[:breakdowns] = b_and_a if b_and_a
      h[:breakdown_tags] = b_and_a_tags if b_and_a_tags
      h[:school_value] = result.value  #data_value.value
      h[:source_date_valid] = result.date_valid.strftime('%Y%m%d %T')  #source.data_valid
      h[:state_value] = state_value if state_value  #data_type.value
      h[:district_value] = district_value if district_value   #data_type.value
      h[:source_name] = result.source_name    #source.name
      h[:description] = result.description if result.description    #source.description#################
      h[:school_cohort_count] = result.cohort_count if result.cohort_count #data_value.cohort_count
      h[:academics] = academics if academics   #data_value.academics.pluck(:name).join(',')
      h[:academic_tags] = result.academic_tags  #academic_tags.tag...comma separated string for all records associated with data value
      h[:grade] = result.grade if result.grade  #data_value.grade
      h[:state_cohort_count] = result.cohort_count if state_value && result.cohort_count  #data_value.cohort_count
      # h[:flags] = result.flags TODO
    end
  end

  def valid_result_hash?(result_hash)
    result_hash = result_hash.reject { |_,v| v.blank? }
    required_keys = %i(school_value source_date_valid source_name)
    missing_keys = required_keys - result_hash.keys
    if missing_keys.count.positive?
      GSLogger.error(
        :school_cache,
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
    district_results_hash[result.datatype_breakdown_year]
  end

  def state_value(result)
    state_results_hash[result.datatype_breakdown_year]
  end


end
