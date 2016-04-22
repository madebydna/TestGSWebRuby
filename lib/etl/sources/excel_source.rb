require 'csv'
require_relative '../source'
require 'roo'
require 'roo-xls'
require 'row'


class ExcelSource < GS::ETL::Source
  attr_reader :columns

  DEFAULT_OPTIONS = {
    headers: true,
    header_converters: :symbol,
    col_sep:',',
    quote_char: '`'
  }

  def initialize(input_files, columns, options = {})
    @input_files = input_files.is_a?(Array) ? input_files : [input_files]
    self.columns = columns
    @options = DEFAULT_OPTIONS.merge(options)
  end

  def filename_with_dir(name_or_regex, dir)
    if name_or_regex.is_a? Regexp
      Dir.entries(dir).map { |entry| input_filename(file) }
        .select { |abs_path| File.file? abs_path && name_or_regex =~ file }
    else
      File.join(dir, name_or_regex)
    end
  end

  def each(context={})
    max = @options.delete(:max) || context[:max]
    if context[:dir]
      @input_files.map { |f| filename_with_dir(f, context[:dir]) }.flatten
    else
      @input_files
    end.each do |file|
      xlsx = ::Roo::Excelx.new(file)
      xlsx.each_with_index(header_search: [/./], pad_cell: true, max_rows: max) do |row_as_hash, row_num|
        row_as_hash = Hash[row_as_hash.map do |k, v|
          k = k.gsub(' ', '_').downcase.to_sym
          [k, v]
        end ]
        row = GS::ETL::Row.new(row_as_hash, row_num)
        record(row, 'Row read', file)
        yield row
      end
    end
  end

  def input_files=(input_files)
    raise ArgumentError, 'input_files must not be nil' unless input_files
    unless input_files.is_a?(Array)
      raise ArgumentError, 'input_files must be an array'
    end
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
