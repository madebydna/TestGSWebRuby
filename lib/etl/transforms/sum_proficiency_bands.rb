# create row "percent proficient and above" summed by ROW, use sum_values.rb to sum by COLUMN
# this transform requires the following row keys to exist:
# :district_name,:school_name,:state_id,:subject,:grade,:breakdown,:proficiency_band,:value_float
# accepts an array of :proficiency_band values that need to be summed to get prof null
# ex: ['Proficient','Advanced']

require_relative '../source'

class SumProficiencyBands < GS::ETL::Source
  attr_accessor :column_values_to_select

  def initialize(column_values_to_select)
    self.column_values_to_select = column_values_to_select
    @hash = {}
  end

  def process(row)
    group_by_fields=[:district_name,:school_name,:state_id,:subject,:grade,:breakdown]
    field_to_use = :proficiency_band
    column_to_aggregate = :value_float

    key = row.select { |r| group_by_fields.include?(r) }

    @hash[key] ||= {}
    if column_values_to_select.include? row[field_to_use]
      @hash[key][row[field_to_use]] = row[column_to_aggregate]
    end

    all_values_are_collected = column_values_to_select.all? do |fv|
      @hash[key].has_key?(fv)
    end

    if all_values_are_collected and column_values_to_select.include? row[field_to_use]
      new_row = row.clone
      new_row[field_to_use] = 'null'
      new_row[:proficiency_band_id] = 'null'
      new_row[column_to_aggregate] = @hash[key].values.map(&:to_f).inject(:+).round(2)
      [row, new_row]
    else
      row
    end
  end
end
