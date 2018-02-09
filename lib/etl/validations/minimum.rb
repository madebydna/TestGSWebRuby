# frozen_string_literal: true

require_relative '../step'

# Example
# .validate('check value is greater than or equal to a minimum',Minimum,:math_45, 32)
# if the minimum is less than the value returns an error

class Minimum < GS::ETL::Step
  def initialize(value_column, minimum)
    @value_column = value_column
    @minimum = minimum
    if minimum.is_a?(String)
      @minimum = minimum.to_f
    end
  end

  def process(row)
    v = row[@value_column]
    if @minimum > v.to_f
      row[:error] = '' if row[:error].nil?
      row[:error] += "Value: #{v} is less than the minimum #{@minimum}\n"
    end
    row
  end

  def event_key
    "Error on minimum check the column: #{@value_column} is less than the minimum #{@minimum}"
  end
end