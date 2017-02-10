class TestScoresCaching::GradeAllCalculator
  attr_reader :data_sets_and_values

  def initialize(data_sets_and_values = [])
    @data_sets_and_values = data_sets_and_values 
  end

  def group_data_sets
    key = proc { |tds| [tds['data_type_id'], tds['year'], tds['subject_id']] }
    data_sets_and_values.group_by(&key)
  end

  def calculate_grade_all(test_data_sets)
    raise ArgumentError.new('test data already contains grade All') if test_data_sets.any? { |tds| tds['grade'] == 'All'}
    return nil if test_data_sets.blank?
    
    grade_all_tds = test_data_sets.first.dup
    grade_all_tds['grade'] = 'All'
    grade_all_tds['school_value_float'] = 0.0
    grade_all_tds['state_value_float'] = 0.0
    grade_all_tds['number_students_tested'] = 0

    grade_all_tds = test_data_sets.each_with_object(grade_all_tds) do |tds, accum|
      next unless tds['number_students_tested'] && tds['number_students_tested'] > 0
      next unless tds['school_value_float'] && tds['state_value_float']
      next unless tds['school_value_float'].to_s.to_f == tds['school_value_float']
      next unless tds['state_value_float'].to_s.to_f == tds['state_value_float']
      accum['school_value_float'] += tds['school_value_float'] * tds['number_students_tested']
      accum['state_value_float'] += tds['state_value_float'] * tds['number_students_tested']
      accum['number_students_tested'] += tds['number_students_tested']
    end

    return nil if grade_all_tds['number_students_tested'].zero?

    grade_all_tds['school_value_float'] /= grade_all_tds['number_students_tested']
    grade_all_tds['state_value_float'] /= grade_all_tds['number_students_tested']

    grade_all_tds
  end

  def inject_grade_all
    # group by data type and year and subject
    # for each data type group, noop and abort if existing grade all
    # if no grade all, calculate grade all and add to data type group
    # re-flatten groups and return array
    grouped_test_data = group_data_sets.each_pair do |key, test_data_sets|
      next if test_data_sets.any? { |tds| tds['grade'] == 'All' }
      grade_all_tds = calculate_grade_all(test_data_sets.select { |tds| tds['breakdown_id'] == 1 } )
      test_data_sets << grade_all_tds if grade_all_tds
    end

    grouped_test_data.values.flatten
  end

end
