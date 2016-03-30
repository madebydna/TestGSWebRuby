require 'step'

class  KeepRows < GS::ETL::Step
  def initialize(field, *values_to_match)
    @values_to_match = values_to_match
    @field = field
  end

  def process(row)
    value = row[@field]
    if value_match?(value)
      record(:filter_for_value_match)
      return row
    else
      record(:removed_non_match)
      return nil
    end
  end

  def event_key
    "#{@field}"
  end

  private
  def value_match?(value)
    @values_to_match.include?(value)
  end
end
