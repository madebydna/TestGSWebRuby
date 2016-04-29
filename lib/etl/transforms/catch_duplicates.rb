require 'set'
require_relative '../step'

class CatchDuplicates < GS::ETL::Step

  def initialize(*columns_selected)
    @columns_selected = columns_selected
    @values = []
  end

  def columns_selected=(columns_selected)
    columns_selected
  end

  def key_for_row(row)
    row.select { |key| @columns_selected.include? key }.values
  end

  def process(row)
    key = key_for_row(row)
    if @values.include? key
      dup_message = row.select { |k, _| @columns_selected.include? k}.inspect
      raise StandardError, "Duplicate data: #{ dup_message }"
    else
      @values << key
    end
    row
  end
end