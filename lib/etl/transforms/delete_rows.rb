require_relative '../step'
# example: 
# arguments: column to match, list of string or regex values to delete
# the following will delete rows for column Watermark
# s.transform DeleteRows, :watermark, /Achievement/, /K-3 Literacy data/, 'Buddy'

class  DeleteRows < GS::ETL::Step
  def initialize(field, *values_to_match)
    @values_to_match = values_to_match
    @field = field
  end

  def process(row)
    value = row[@field]
    if value_match?(value)
      record(row, :filtered_match)
      return nil
    else
      record(row, :non_match)
      return row
    end
  end

  def event_key
    "#{@field}"
  end

  private
  def value_match?(value)
    @values_to_match.any? do |match|
      match == value || (match.is_a?(Regexp) && !!(match =~ value))
    end
  end
end
