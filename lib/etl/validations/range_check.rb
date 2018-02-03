# frozen_string_literal: true

require_relative '../step'

# Example
# .validate('check value in range',Range,:math_45, {bottom: 1, top: 50, exceptions_array: %w(<2 >95)})
# will be valid inclusive of the bottom and top and not return an error
# exceptions is optional
# exceptions will always be true if found and not return an error


class RangeCheck < GS::ETL::Step
  def initialize(value_column, hash)
    @value_column = value_column
    @bottom = hash[:bottom]
    @top = hash[:top]
    @exceptions = hash[:exceptions_array].is_a?(Array) ? hash[:exceptions_array] : []
  end

  def process(row)
    v = row[@value_column]
    if !@exceptions.include?(v) && !v.to_f.between?(@bottom, @top)
      row[:error] = '' if row[:error].nil?
      row[:error] += "Error out of range value: #{v} against range #{@bottom}-#{@top} and exceptions #{@exceptions.join(',')}\n"
    end
    row
  end

  def event_key
    "Range error checking column: #{@value_column} against range #{@bottom}-#{@top} and exceptions #{@exceptions.join(',')}"
  end
end