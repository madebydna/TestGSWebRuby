# frozen_string_literal: true

require_relative '../step'

# Example
# .validate('check value is of a data type',TypeCheck,:math_45, Float)

# Possible types to use
# TrueClass
# FalseClass
# String
# Integer
# Float
# Bignum
# Symbol
# Array
# Hash

class TypeCheck < GS::ETL::Step
  def initialize(value_column, type)
    @value_column = value_column
    @type = type
  end

  def process(row)
    v = row[@value_column]
    unless v.is_a?(@type)
      row[:error] = '' if row[:error].nil?
      row[:error] += "Error: Type mismatch #{v}:#{@type}\n"
    end
    row
  end

  def event_key
    "Error checking column: #{@value_column} against type:#{@type}"
  end
end