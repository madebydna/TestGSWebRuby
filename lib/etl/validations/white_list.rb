# frozen_string_literal: true

require_relative '../step'

# Example:
# .validate('check value is part of list',WhiteList,:column_name, value_to_match, value_to_match, value_to_match)
# if it doesn't match one of the values it errors

class WhiteList < GS::ETL::Step
  def initialize(value_column, *white_list)
    @value_column = value_column
    @white_list = white_list.is_a?(Array) ? white_list : []
  end

  def process(row)
    v = row[@value_column]
    unless @white_list.include?(v)
      row[:error] = '' if row[:error].nil?
      row[:error] += "Error checking value: #{v} is not in the white list: #{@white_list.join(',')}"
    end
    row
  end

  def event_key
    "Error checking column: #{@value_column} is in the white list: #{@white_list.join(',')}"
  end
end