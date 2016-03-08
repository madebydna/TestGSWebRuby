require 'csv'
require 'step'

class CsvSource < GS::ETL::Step
  include GS::ETL::Source

  def initialize(input_file)
    @input_file = input_file
    @csv = CSV.open(input_file, headers: true, header_converters: :symbol)
  end

  def each
    @csv.each do |row|
      record('Row read')
      yield(row.to_hash)
    end
    @csv.close
  end

  def event_key
    @input_file
  end
end


