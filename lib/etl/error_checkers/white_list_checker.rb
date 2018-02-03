# frozen_string_literal: true

require_relative '../step'

class WhiteListChecker < GS::ETL::Step
  def initialize(value_column, white_list_array)
    @value_column = value_column
    @white_list_array = white_list_array.is_a?(Array) ? white_list_array : []
  end

  def process(row)
    v = row[@value_column]
    unless @white_list_array.include?(v)
      row[:error] = '' if row[:error].nil?
      row[:error] += "Error checking value: #{v} is not in the white list: #{@white_list_array.join(',')}"
    end
    row
  end

  def event_key
    "Error checking column: #{@value_column} is in the white list: #{@white_list_array.join(',')}"
  end
end