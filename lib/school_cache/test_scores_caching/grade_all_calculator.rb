class TestScoresCaching::GradeAllCalculator
  attr_reader :data_sets_and_values
  PRECISION = 2

  DATA_TYPE_ID = 'data_type_id'
  SUBJECT_ID = 'subject_id'
  BREAKDOWN_ID = 'breakdown_id'
  SCHOOL_VALUE = 'school_value_float'
  STATE_VALUE = 'state_value_float'
  SCHOOL_VALUE_TEXT = 'school_value_text'
  STATE_VALUE_TEXT = 'state_value_text'
  SCHOOL_NUM_TESTED = 'number_students_tested'
  STATE_NUM_TESTED = 'state_number_tested'
  YEAR = 'year'
  GRADE = 'grade'

  GRADE_ALL = 'All'

  def initialize(data_sets_and_values = [])
    @data_sets_and_values = data_sets_and_values 
  end

  def inject_grade_all
    # group by data type and year and subject and breakdown
    # for each group, noop and abort if existing grade all
    # if no grade all, calculate grade all and add to group
    # re-flatten groups and return array
    new_data_sets = group_data_sets.each_with_object([]) do |(_, test_data_sets), accum|
      unless has_any_grade_all_data?(test_data_sets)
        grade_all_tds = calculate_grade_all(test_data_sets)
        accum << Array.wrap(grade_all_tds) if grade_all_tds
      end
    end

    data_sets_and_values + Array.wrap(new_data_sets).flatten
  end

  private

  def group_data_sets
    key = proc { |tds| [tds[DATA_TYPE_ID], tds[YEAR], tds[SUBJECT_ID], tds[BREAKDOWN_ID]] }
    data_sets_and_values.select { |tds| tds[YEAR] == max_year }.group_by(&key)
  end

  def calculate_grade_all(test_data_sets)
    raise ArgumentError.new('test data already contains grade All') if has_any_grade_all_data?(test_data_sets)
    return nil if test_data_sets.blank?

    data_sets_for_school_value = data_sets_with_school_value(test_data_sets)
    data_sets_for_state_value = data_sets_with_state_value(test_data_sets)

    return nil if data_sets_for_school_value.blank? && data_sets_for_state_value.blank?

    grade_all_tds = test_data_sets.first.dup
    grade_all_tds[SCHOOL_VALUE_TEXT] = nil
    grade_all_tds[STATE_VALUE_TEXT] = nil
    grade_all_tds[SCHOOL_VALUE] = nil
    grade_all_tds[STATE_VALUE] = nil
    grade_all_tds[SCHOOL_NUM_TESTED] = nil
    grade_all_tds[STATE_NUM_TESTED] = nil

    grade_all_tds[GRADE] = GRADE_ALL

    if all_school_values_are_numeric?(test_data_sets) && all_school_text_values_are_nil_or_match_float?(test_data_sets)
      if all_have_number_tested?(data_sets_for_school_value)
        grade_all_tds[SCHOOL_VALUE] = weighted_school_value_float(data_sets_for_school_value)
        grade_all_tds[SCHOOL_NUM_TESTED] = sum_number_students_tested(data_sets_for_school_value)
      else
        grade_all_tds[SCHOOL_VALUE] = average_school_value_float(data_sets_for_school_value)
      end
    end

    if all_state_values_are_numeric?(test_data_sets)
      if all_have_state_number_tested?(data_sets_for_state_value)
        grade_all_tds[STATE_VALUE] = weighted_state_value_float(data_sets_for_state_value)
        grade_all_tds[STATE_NUM_TESTED] = sum_state_number_tested(data_sets_for_state_value)
      else
        grade_all_tds[STATE_VALUE] = average_state_value_float(data_sets_for_state_value)
      end
    end

    # Make sure to only return a new data set if we've actually computed something
    return nil unless grade_all_tds[SCHOOL_VALUE] || grade_all_tds[STATE_VALUE]

    grade_all_tds
  end

  def all_have_number_tested?(test_data_sets)
    test_data_sets.all?(&numeric_and_nonzero(SCHOOL_NUM_TESTED))
  end

  def all_school_values_are_numeric?(test_data_sets)
    test_data_sets.all?(&numeric(SCHOOL_VALUE))
  end
  
  def all_school_text_values_are_nil_or_match_float?(test_data_sets)
    test_data_sets.all? { |tds| tds[SCHOOL_VALUE_TEXT].nil? || tds[SCHOOL_VALUE_TEXT] == tds[SCHOOL_VALUE] }
  end

  def all_state_values_are_numeric?(test_data_sets)
    test_data_sets.all?(&numeric(STATE_VALUE))
  end

  def all_have_state_number_tested?(test_data_sets)
    test_data_sets.all?(&numeric_and_nonzero(STATE_NUM_TESTED))
  end

  def numeric_and_nonzero(field_name)
    ->(tds) { tds[field_name].to_s.to_f == tds[field_name] && tds[field_name].to_f > 0 }
  end

  def numeric(field_name)
    ->(tds) { tds[field_name].to_s.to_f == tds[field_name] }
  end

  def data_sets_with_school_value(test_data_sets)
    test_data_sets.select { |tds| tds[SCHOOL_VALUE] }
  end

  def data_sets_with_state_value(test_data_sets)
    test_data_sets.select { |tds| tds[STATE_VALUE] }
  end

  def sum_state_number_tested(test_data_sets)
    test_data_sets.sum { |tds| tds[STATE_NUM_TESTED] }
  end

  def sum_number_students_tested(test_data_sets)
    test_data_sets.sum { |tds| tds[SCHOOL_NUM_TESTED] }
  end

  def average_school_value_float(test_data_sets)
    sum = test_data_sets.sum { |tds| tds[SCHOOL_VALUE] }
    avg = sum.to_f / test_data_sets.size unless test_data_sets.empty?
    avg.round(PRECISION) if avg
  end

  def weighted_school_value_float(test_data_sets)
    count = sum_number_students_tested(test_data_sets)
    weighted_sum = test_data_sets.sum { |tds| tds[SCHOOL_VALUE] * tds[SCHOOL_NUM_TESTED] }
    avg = weighted_sum.to_f / count unless count.zero?
    avg.round(PRECISION) if avg
  end

  def average_state_value_float(test_data_sets)
    sum = test_data_sets.sum { |tds| tds[STATE_VALUE]}
    avg = sum.to_f / test_data_sets.size unless test_data_sets.empty?
    avg.round(PRECISION) if avg
  end

  def weighted_state_value_float(test_data_sets)
    count = sum_state_number_tested(test_data_sets)
    weighted_sum = test_data_sets.sum { |tds| tds[STATE_VALUE] * tds[STATE_NUM_TESTED] }
    avg = weighted_sum.to_f / count unless count.zero?
    avg.round(PRECISION) if avg
  end

  def max_year
    @_max_year ||= data_sets_and_values.map { |tds| tds[YEAR] }.max
  end

  def has_any_grade_all_data?(test_data_sets)
    test_data_sets.any? { |tds| tds[GRADE] == GRADE_ALL }
  end
end
