require 'csv'
require_relative '../source'


class CsvSource < GS::ETL::Source
  attr_reader :columns

  DEFAULT_OPTIONS = {
    headers: true,
    header_converters: :symbol,
    col_sep:',',
    quote_char: '`'
  }

  def initialize(input_files, columns, options = {})
    self.input_files = input_files
    self.columns = columns
    @options = DEFAULT_OPTIONS.merge(options)
  end

  def filename_with_dir(name_or_regex, dir)
    if name_or_regex.is_a? Regexp
      Dir.entries(dir).map { |entry| File.join(dir, entry) }
        .select { |abs_path| File.file?(abs_path) && (name_or_regex =~ abs_path) }
    else
      File.join(dir, name_or_regex)
    end
  end

  def max
    @_max ||= @options.delete(:max)
  end

  def offset
    @_offset ||= @options.delete(:offset)
  end

  def input_files(dir = nil)
    if dir
      @input_files.map { |f| filename_with_dir(f, dir) }.flatten
    else
      @input_files
    end
  end

  def each(context={})
    max = self.max || context[:max]
    offset = self.offset || context[:offset] || 0
    input_files(context[:dir]).each do |file|
      CSV.open(file, 'r:ISO-8859-1', @options) do |csv|
        enum = csv.drop(offset)
        enum = enum.first(max) if max
        enum.each_with_index do |csv_row, row_num|
          row = GS::ETL::Row.new(csv_row.to_hash, row_num)
          if row_num == 1
            record(row, "Opened #{file} and got #{csv_row.headers.size} headers: #{csv_row.headers}")
          end
          record(row, 'Row read', file)
          begin
            yield row
          rescue => e
            logger.error("Error in file #{file} at line #{row_num+1}: #{e}")
            raise
          end
        end
      end
    end
  end

  def input_files=(input_files)
    raise ArgumentError, 'input_files must not be nil' unless input_files
    input_files = [*input_files]
    if input_files.length < 1
      raise ArgumentError, 'Must provide at least one input file'
    end
    @input_files = input_files
  end

  private

  def columns=(columns)
    @columns = columns
  end
end
