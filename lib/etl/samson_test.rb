$LOAD_PATH.unshift File.dirname(__FILE__)
require 'etl'
require 'sources/csv_source'
require 'sources/row_exploder_source'
require 'transforms/row_exploder'
require 'transforms/joiner'
require 'transforms/hash_lookup'
require 'transforms/field_renamer'
require 'destinations/csv_destination'
require 'transforms/trim_leading_zeros'
require 'destinations/event_report_stdout'


class Foo < GS::ETL::DataProcessor

  def initialize(source_file, output_file)
    @source_file = source_file
    @output_file = output_file
  end

  def run
    s1 = source CsvSource, @source_file

    s1.transform RowExploder,
      :proficiency_band_id,
      :proficiency_band_value,
      :percentage_standard_exceeded,
      :percentage_standard_met,
      :percentage_standard_met_and_above,
      :percentage_standard_nearly_met,
      :percentage_standard_not_met

    # Map proficiency band IDs
    s1.transform(
      HashLookup,
      :proficiency_band_id,
      {
        percentage_standard_exceeded: 25,
        percentage_standard_met: 24,
        percentage_standard_nearly_met: 23,
        percentage_standard_not_met: 22
      }
    )

    s1.transform TrimLeadingZeros, :grade
    s1.transform FieldRenamer, :test_year, :year
    s1.transform FieldRenamer, :test_id, :subject_id

    s1.transform(
      HashLookup,
      :subject_id,
      {
        '2' => 5,
        '1' => 4,
        'science' => 25,
      }
    )


    s1.transform(FieldRenamer, :subgroup_id, :breakdown_id)

    s1.transform(
      HashLookup,
      :breakdown_id,
      {
        '1' => 1,
        '3' => 12,
        '4' => 11,
        '160' => 15,
        '28' => 19,
        '31' => 9,
        '111' => 10,
        '128' => 13,
        '99' => 14,
        '74' => 3,
        '75' => 4,
        '77' => 5,
        '78' => 6,
        '80' => 8,
        '76' => 2,
        '79' => 112,
        '144' => 21,
      },
      ignore: ['6','7','8','90','91','92','93','94','121''202','200','203',
               '205','206', '207','220','221','222','223','204','201','224',
               '225','226','227','180', '120','142']
    )

    s1.transform FieldRenamer, :proficiency_band_value, :school_value_float
    s1.transform FieldRenamer, :students_tested, :number_tested
    s1.transform FieldRenamer, :test_year, :year

    s1.destination CsvDestination, @output_file

    event_log_steps.destination EventReportStdout

    s1.transform RunOtherStepTree, event_log

    s1.run

  end
end

file = '/Users/samson/Development/data/ca2015_sample.txt'
file = '/Users/samson/Development/data/ca2015_RM_csv_v1_all.txt'
output_file = '/tmp/output.csv'
Foo.new(file, output_file).run



