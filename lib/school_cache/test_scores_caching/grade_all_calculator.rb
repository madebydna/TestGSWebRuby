class TestScoresCaching::GradeAllCalculator
  attr_reader :data_sets_and_values
  PRECISION = 2

  def initialize(data_sets_and_values = [])
    @data_sets_and_values = data_sets_and_values 
  end

  def group_data_sets
    key = proc { |tds| [tds['data_type_id'], tds['year'], tds['subject_id'], tds['breakdown_id']] }
    data_sets_and_values.select { |tds| tds['year'] == max_year }.group_by(&key)
  end

  def calculate_grade_all(test_data_sets)
    raise ArgumentError.new('test data already contains grade All') if has_any_grade_all_data?(test_data_sets)
    return nil if test_data_sets.blank?

    data_sets_for_school_value = data_sets_valid_for_weighted_school_value(test_data_sets)
    data_sets_for_state_value = data_sets_valid_for_weighted_state_value(test_data_sets)
    
    grade_all_tds = test_data_sets.first.dup
    grade_all_tds['grade'] = 'All'
    grade_all_tds['school_value_float'] = weighted_school_value_float(data_sets_for_school_value)
    grade_all_tds['number_students_tested'] = sum_number_students_tested(data_sets_for_school_value)
    grade_all_tds['state_value_float'] = weighted_state_value_float(data_sets_for_state_value)
    grade_all_tds['state_number_tested'] = sum_state_number_tested(data_sets_for_state_value)
    grade_all_tds
  end

  def data_sets_valid_for_weighted_school_value(test_data_sets)
    test_data_sets.select do |tds|
      tds['school_value_float'] &&
      tds['number_students_tested'] &&
      tds['number_students_tested'].to_s.to_f == tds['number_students_tested']
    end
  end

  def data_sets_valid_for_weighted_state_value(test_data_sets)
    test_data_sets.select do |tds|
      tds['state_value_float'] &&
      tds['state_number_tested'] &&
      tds['state_number_tested'].to_s.to_f == tds['state_number_tested']
    end
  end

  def sum_state_number_tested(test_data_sets)
    test_data_sets.sum { |tds| tds['state_number_tested'] }
  end

  def sum_number_students_tested(test_data_sets)
    test_data_sets.sum { |tds| tds['number_students_tested'] }
  end

  def weighted_school_value_float(test_data_sets)
    sum = sum_number_students_tested(test_data_sets)
    percent = test_data_sets.sum do |tds|
      tds['school_value_float'].to_s.scan(/[0-9.]+/).first.to_f * tds['number_students_tested']
    end / sum unless sum.zero?
    percent.round(PRECISION) if percent
  end

  def weighted_state_value_float(test_data_sets)
    sum = sum_state_number_tested(test_data_sets)
    percent = test_data_sets.sum do |tds|
      tds['state_value_float'].to_s.scan(/[0-9.]+/).first.to_f * tds['state_number_tested']
    end / sum unless sum.zero?
    percent.round(PRECISION) if percent
  end

  def max_year
    @_max_year ||= data_sets_and_values.map { |tds| tds['year'] }.max
  end

  def inject_grade_all
    # group by data type and year and subject and breakdown
    # for each group, noop and abort if existing grade all
    # if no grade all, calculate grade all and add to group
    # re-flatten groups and return array
    new_data_sets = group_data_sets.reduce([]) do |accum, (key, test_data_sets)|
      unless has_any_grade_all_data?(test_data_sets)
        grade_all_tds = calculate_grade_all(test_data_sets)
        accum << Array.wrap(grade_all_tds) if grade_all_tds
      end
      accum
    end

    data_sets_and_values + Array.wrap(new_data_sets).flatten
  end

  def has_any_grade_all_data?(test_data_sets)
    test_data_sets.any? { |tds| tds['grade'] == 'All' }
  end

end
