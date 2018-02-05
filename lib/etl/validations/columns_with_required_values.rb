# frozen_string_literal: true

require_relative '../step'

# Example
# .validate('check column has a value',ColumnsWithRequiredValues,:math_45, :state_id, :school_id)
# add all required columns - can be run at the end of the transforms.

class ColumnsWithRequiredValues < GS::ETL::Step
  def initialize(*input_columns)
    @input_columns = input_columns
  end

  def process(row)
<<<<<<< HEAD
    failed_columns = @input_columns.select{ |column| row[column].to_s.empty? }
=======
    failed_columns = @input_columns.select{ |column| row[column].nil? || row[column].blank? }
>>>>>>> merge
    if failed_columns.present?
      row[:error] = '' if row[:error].nil?
      row[:error] += "These columns do not have values: #{failed_columns.join(',')}\n"
    end
    row
  end

  def event_key
    "Error required content was not found, columns looked for #{@input_columns.join(',')}"
  end
end