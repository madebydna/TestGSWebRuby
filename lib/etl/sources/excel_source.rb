require 'csv'
require_relative '../source'
require 'roo'
require 'roo-xls'

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

  def each(context={})
    max = self.max || context[:max]
    input_files.each do |file|
      xlsx = ::Roo::Excelx.new(file)
      xlsx.each_with_index(header_search: [/./], pad_cell: true) do |row_as_hash, row_num|
        break if row_num == max
        row_as_hash = downcase_and_symbolize_hash_keys(row_as_hash)
        row = GS::ETL::Row.new(row_as_hash, row_num)
        record(row, 'Row read', file)
        yield row
      end
    end
  end

  def downcase_and_symbolize_hash_keys(hash)
    Hash[
      hash.map do |k, v|
        k = k.gsub(' ', '_').downcase.to_sym
        [k, v]
      end
    ]
  end

end
