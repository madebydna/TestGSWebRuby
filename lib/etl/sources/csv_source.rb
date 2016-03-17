require 'csv'
require 'step'
require 'etl'

class CsvSource < GS::ETL::Step
  include GS::ETL::Source

  def initialize(input_files)
    if input_files && ! input_files.is_a?(Array)
      input_files = [input_files]
    end
    self.input_files = input_files
  end

  def each
    @input_files.each do |file|
      CSV.foreach(file, headers: true, header_converters: :symbol) do |row|
        record('Row read', file)
        yield(row.to_hash)
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
end


