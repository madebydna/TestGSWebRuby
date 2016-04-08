require_relative '../step'
require_relative '../source'

class SumProficiencyBands < GS::ETL::Step
  include GS::ETL::Source
  attr_accessor :group_by_fields, :join_fields

  def initialize(group_by_fields)
    self.group_by_fields = group_by_fields
    @rows = []
    @hash = {}
  end

  def process(row)
    column_values_to_select = [
      'level_3',
      'level_4'
    ]
    field_to_use = :proficiency_band
    column_to_aggregate = :value_float

    key = row.select { |r| group_by_fields.include?(r) }
    @hash[key] ||= {}
    @hash[key][field_to_use] = row[column_to_aggregate]

    all_values_are_collected = column_values_to_select.all? do |fv|
      @hash[key].has_key?(fv)
    end

    if all_values_are_collected
      new_row = row.clone
      new_row[field_to_use] = 'test'
      new_row[column_to_aggregate] = @hash[key].values.inject(:+)
      [row, new_row]
    else
      row
    end
  end
end
