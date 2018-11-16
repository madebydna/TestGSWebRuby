# frozen_string_literal: true

class DistrictGradeAllCalculator < GradeAllCalculator
  def initialize(data_values=[])
    super(data_values)
  end

  def calculate_grade_all(data_values)
    if data_values.any_grade_all?
      raise ArgumentError.new('test data already contains grade All')
    end
    return nil if data_values.blank?
    district_data_values = data_values.having_district_value
    state_data_values = data_values.having_state_value

    return nil if district_data_values.blank? && state_data_values.blank?

    grade_all_dv = data_values.first.dup
    grade_all_dv.district_value = nil
    grade_all_dv.state_value = nil
    grade_all_dv.district_cohort_count = nil
    grade_all_dv.state_cohort_count = nil
    grade_all_dv.proficiency_band_name = data_values.first.proficiency_band_name
    grade_all_dv.source_date_valid = data_values.first.source_date_valid
    grade_all_dv.grade = GsdataCaching::GsDataValue::GRADE_ALL
    flags = []

    if data_values.all_district_values_can_be_numeric?
      if district_data_values.all_have_district_cohort_count?
        grade_all_dv.district_value = district_data_values.weighted_average_district_value(precision: PRECISION)
        grade_all_dv.district_cohort_count =  district_data_values.total_district_cohort_count
        flags << 'n_tested'
      else
        grade_all_dv.district_value = district_data_values.average_district_value
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
    return nil unless grade_all_dv.district_value || grade_all_dv.state_value
    grade_all_dv.flags = flags
    grade_all_dv
  end

  def entity_value
    'district_value'
  end
end
