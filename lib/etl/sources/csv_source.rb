require 'csv'
require_relative '../source'


class CsvSource < GS::ETL::Source
  attr_reader :columns

  DEFAULT_OPTIONS = {
    headers: true,
    header_converters: :symbol,
    col_sep:','
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

  def each(context={})
    max = @options.delete(:max) || context[:max]
    if context[:dir]
      @input_files.map { |f| filename_with_dir(f, context[:dir]) }.flatten
    else
      @input_files
    end.each do |file|
      CSV.open(file, 'r:ISO-8859-1', @options) do |csv|
        enum = max ? csv.first(max) : csv
        enum.each do |row|
          record('Row read', file)
          yield row.to_hash
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
