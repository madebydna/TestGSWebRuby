require_relative '../step'

class SumValues < GS::ETL::Step
  def initialize(output_column, *input_columns)
    @input_columns = input_columns
    @output_column = output_column
  end

  def process(row)
    if row.values.all? { |value| value.nil? }
      row[@output_column] = nil
    else
      sum = @input_columns.inject(0) { |sum, column_value| sum + row[column_value].to_f }
      row[@output_column] = sum
    end
    row
  end

  def event_key
    "Summing values from #{@input_columns} to #{@output_column}"
  end
end
