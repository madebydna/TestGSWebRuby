require 'step'

class  KeepRows < GS::ETL::Step
  def initialize(values_to_match, field)
    @values_to_match = values_to_match
    @field = field
    @values_transformed = []
  end

  def process(row)
    value = row[@field]
    if value_match?(value)
      record(:filter_for_value_match)
      @values_transformed << value
      return row 
    else
      record(:removed_non_match)
      @values_transformed << value
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

  def  value_already_transformed?(value)
    @values_transformed.include?(value)
  end
end
