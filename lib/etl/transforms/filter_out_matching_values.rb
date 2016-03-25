require 'step'

class  FilterOutMatchingValues < GS::ETL::Step
  def initialize(field, *values_to_match)
    @values_to_match = values_to_match
    @field = field
  end

  def process(row)
    value = row[@field]
    if value_match?(value)
      record(:filtered_match)
      return nil
    else
      record(:non_match)
      return row
    end
  end

  def event_key
    "#{@field}"
  end

  private
  def value_match?(value)
    @values_to_match.any? do |match|
      match == value ||
          match.is_a?(Regexp) && !!(match =~ value)
    end
  end

  def  value_already_transformed?(value)
    @values_transformed.include?(value)
  end
end
