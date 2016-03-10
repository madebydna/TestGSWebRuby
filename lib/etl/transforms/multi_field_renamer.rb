require 'step'
require_relative 'field_renamer'

class MultiFieldRenamer < GS::ETL::Step
  def initialize(hash)
    @renamers = hash.map { |key, value| build_field_renamer(key, value) }
  end

  def process(row)
    @renamers.inject(row) do |r, renamer|
      renamer.process(r)
    end
  end

  private

  def build_field_renamer(key, value)
    renamer = FieldRenamer.new(key,value)
    renamer
  end
end
