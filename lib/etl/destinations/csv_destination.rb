# simple destination assuming all rows have the same fields
class CsvDestination
  def initialize(output_file)
    @csv = CSV.open(output_file, 'w')
  end

  def write(row)
    unless @headers_written
      @headers_written = true
      @csv << row.keys
    end
    @csv << row.values
    row
  end

  alias_method :process, :write

  def close
    @csv.close
  end
end

