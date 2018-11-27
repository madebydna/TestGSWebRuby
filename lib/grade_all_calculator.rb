# frozen_string_literal: true

class GradeAllCalculator
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
        accum << Array.wrap(grade_all_dv) if grade_all_dv&.send(entity_value)
      end
    end

    data_values + Array.wrap(new_data_values).flatten
  end

  private

  def group_data_values
    # TODO: need to add proficiency_band ?
    key = proc { |dv| [dv.data_type, dv.year, dv.breakdowns, dv.academics] }
    data_values.having_most_recent_date.group_by(&key)
  end

  def calculate_grade_all(data_values)
    raise NotImplementedError.new("#calculate_grade_all not implemented in #{self.class.name}")
  end

  def entity_value
    raise NotImplementedError.new("#entity_value not implemented in #{self.class.name}")
  end

end


