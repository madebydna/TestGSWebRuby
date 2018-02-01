require_relative '../step'
require 'csv'

# simple destination assuming all rows have the same fields
class CsvDestination < GS::ETL::Step

  def initialize(output_file, *fields)
    @output_file = output_file
    @error_log = CSV.open(error_output_file(output_file), 'w', col_sep: "\t")
    @csv = CSV.open(output_file, 'w', col_sep: "\t")
    @fields = fields.empty? ? nil : fields
  end

  def write(row)
    if has_error?(row)
      write_error(row)
    else
      write_file(row)
    end
  end

  def has_error?(row)
    row.has_key? :error
  end

  def error_output_file(output_file)
    output_file.split('.').insert(-2,'error').join('.')
  end

  def write_error(row)
    fields = row.keys
    if fields
      row = row.select { |k| fields.include?(k) }
    end
    unless @headers_written_error
      @headers_written_error = true
      @error_log << fields
    end
    record(row, 'Wrote row')
    @error_log << fields.map { |f| row[f] }
    row
  end

  def write_file(row)
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

