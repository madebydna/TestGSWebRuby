require 'set'
require_relative '../step'

class CatchDuplicates < GS::ETL::Step

  def initialize(accumulate, *columns_selected)
    if accumulate.is_a? TrueClass
      @should_accumulate = true
    else
      columns_selected.unshift accumulate
    end
    @columns_selected = Set.new columns_selected
    @values = Hash.new { |h, k| h[k] =  [] }
  end

  def key_for_row(row)
    row.select { |key| @columns_selected.include? key }.values.join('').to_sym
  end

  def process(row)
    key = key_for_row(row)
    if @values.include? key
      @values[key] << row.row_num
      dup_data = row.select { |k, _| @columns_selected.include? k}.inspect
      msg = "Duplicate data: #{ dup_data } for rows #{@values[key]}"

      @values[key] << row.row_num
      if @should_accumulate
        puts msg
      else
        raise msg
      end
    end
    row
  end
end
