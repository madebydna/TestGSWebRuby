# frozen_string_literal: true

require_relative '../step'

# Example
# .validate('check value is a string of length',StringLength,:math_45, 5)
# returns an error if string length is not equal to value string length

class StringLength < GS::ETL::Step
  def initialize(value_column, str_len)
    @value_column = value_column
    @str_len = str_len.to_i
  end

  def process(row)
    v = row[@value_column].to_s
    if v.length != @str_len
      row[:error] = '' if row[:error].nil?
      row[:error] += "String length for value #{v} does not equal #{@str_len}\n"
    end
    row
  end

  def event_key
    "Error string length for column: #{@value_column} does not equal #{@str_len}"
  end
end