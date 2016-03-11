require 'step'

class ValueConcatonator < GS::ETL::Step

  def initialize(destination_column, *source_columns)
    @destination_column = destination_column
    @source_columns = source_columns
  end

  def process(row)
      row[@destination_column]  = @source_columns.reduce('') { |sum, c| sum + row[c] }
      record(:concatonate_column)
      row
  end

  def event_key
    "#Concanate #{@source_columns} to #{@destination_column}"
  end
end
