require_relative '../step'
require 'csv'

# simple destination assuming all rows have the same fields
class CsvDestination < GS::ETL::Step

  def initialize(output_file, *fields)
    @output_file = output_file
    @csv = CSV.open(output_file, 'w', col_sep: "\t")
    @fields = fields.empty? ? nil : fields
  end

  def write(row)
    fields = @fields || row.keys
    if @fields
      row = row.select { |k| @fields.include?(k) }
    end
    unless @headers_written
      @headers_written = true
      @csv << fields
    end
    record(row, 'Wrote row')
    @csv << fields.map { |f| row[f] }
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

