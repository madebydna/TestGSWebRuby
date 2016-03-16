require 'step'
require 'set'
require 'etl'

class UniqueValues < GS::ETL::Step
  include GS::ETL::Source
  attr_accessor :fields

  def initialize(*fields)
   @fields = fields
   @set = Set.new
  end

  def process(row)
    @set << row.keep_if { |key, _value| fields.include? key }
    nil
  end

  def each
    @set.each do |row|
      record(:'Row processed')
      yield(row)
    end
  end

  def fields=(fields)
    raise 'Fields cannot be nil' if fields == nil
    @fields = fields
  end
end