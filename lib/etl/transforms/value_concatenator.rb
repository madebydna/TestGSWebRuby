require_relative '../step'

class ValueConcatenator < GS::ETL::Step

  def initialize(destination_column, *source_columns)
    @destination_column = destination_column
    @source_columns = source_columns
  end

  def process(row)
    row[@destination_column] = @source_columns.reduce('') do |sum, c|
      unless row.has_key?(c)
        raise ArgumentError.new "Column #{c} (#{c.class}) doesn't exist in row"
      end
      sum << row[c]
    end
    record(row, :concatenate_column)
    row
  end

  def event_key
    "#Concatenate #{@source_columns} to #{@destination_column}"
  end
end
