$LOAD_PATH.unshift File.dirname(__FILE__)
require 'etl'
require 'sources/csv_source'
require 'sources/row_exploder_source'
require 'transforms/row_exploder'
require 'transforms/joiner'
require 'transforms/hash_lookup_transformer'
require 'transforms/field_renamer'
require 'destinations/csv_destination'


class Foo
  include GS::ETL::DataStepsMachine

  def initialize(source_file, output_file)
    @source_file = source_file
    @output_file = output_file
  end

  def run
    s1 = source CsvSource, @source_file

    s1.transform RowExploder,
      :proficiency_band_name,
      :proficiency_band_value,
      :percentage_standard_exceeded,
      :percentage_standard_met,
      :percentage_standard_met_and_above,
      :percentage_standard_nearly_met,
      :percentage_standard_not_met

    # Map proficiency band IDs
    s1.transform(
      HashLookupTransformer,
      :proficiency_band_name,
      {
        percentage_standard_exceeded: 25,
        percentage_standard_met: 24,
        percentage_standard_nearly_met: 23,
        percentage_standard_not_met: 22
      },
      :proficiency_band_id
    )

    s1.transform FieldRenamer, :proficiency_band_value, :school_value_float


    s2 = source CsvSource, '/Users/samson/Development/data/test_join.csv'

    s1.join(s2, :proficiency_band_id, :foo)
    
    s1.destination CsvDestination, @output_file

    s1.run

  end
end

file = '/Users/samson/Development/data/ca2015_sample.txt'
output_file = '/tmp/output.csv'
Foo.new(file, output_file).run



