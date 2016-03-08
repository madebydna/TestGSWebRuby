require 'step'
require 'csv'

# simple destination assuming all rows have the same fields
class CsvDestination < GS::ETL::Step

  def initialize(output_file)
    @output_file = output_file
    @csv = CSV.open(output_file, 'w')
  end

  def write(row)
    unless @headers_written
      @headers_written = true
      @csv << row.keys
    end
    record('Wrote row')
    @csv << row.values
    row
  end

  alias_method :process, :write

  def close
    @csv.close
  end

  def event_key
    @output_file
  end
end

