# frozen_string_literal: true

class TestScoresCaching::GradeAllCalculator
  attr_reader :data_values
  PRECISION = 2

  def initialize(data_values = [])
    @data_values = data_values 
  end

  def inject_grade_all
    # group by data type and year and subject and breakdown
    # for each group, noop and abort if existing grade all
    # if no grade all, calculate grade all and add to group
    # re-flatten groups and return array
    new_data_values = group_data_values.each_with_object([]) do |(_, data_values), accum|
      unless data_values.any_grade_all?
        grade_all_dv = calculate_grade_all(data_values)
        accum << Array.wrap(grade_all_dv) if grade_all_dv
      end
    end

    data_values + Array.wrap(new_data_values).flatten
  end

  private

  def group_data_values
    # TODO: need to add proficiency_band ?
    key = proc { |dv| [dv.data_type, dv.year, dv.breakdowns] }
    data_values.having_most_recent_date.group_by(&key)
  end

  def calculate_grade_all(data_values)
    if data_values.any_grade_all?
      raise ArgumentError.new('test data already contains grade All')
    end
    return nil if data_values.blank?

    school_data_values = data_values.having_school_value
    state_data_values = data_values.having_state_value

    return nil if school_data_values.blank? && state_data_values.blank?

    grade_all_dv = data_values.first.dup
    grade_all_dv.school_value = nil
    grade_all_dv.state_value = nil
    grade_all_dv.school_cohort_count = nil
    grade_all_dv.state_cohort_count = nil
    grade_all_dv.grade = GsdataCaching::GsDataValue::GRADE_ALL
    flags = []

    if data_values.all_school_values_are_numeric?
      if school_data_values.all_have_school_cohort_count?
        grade_all_dv.school_value = school_data_values.weighted_average_school_value(precision: PRECISION)
        grade_all_dv.school_cohort_count = school_data_values.total_school_cohort_count
        flags << 'n_tested'
      else
        grade_all_dv.school_value = school_data_values.average_school_value
        flags << 'straight_avg'
      end
    end

    if data_values.all_state_values_are_numeric?
      if state_data_values.all_have_state_cohort_count?
        grade_all_dv.state_value = state_data_values.weighted_average_state_value(precision: PRECISION)
        grade_all_dv.state_cohort_count = state_data_values.total_state_cohort_count
      else
        grade_all_dv.state_value = state_data_values.average_state_value
      end
    end

    return nil unless grade_all_dv.school_value || grade_all_dv.state_value
    grade_all_dv.flags = flags
    grade_all_dv
  end

end
