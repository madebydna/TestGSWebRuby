$LOAD_PATH.unshift File.dirname(__FILE__)
require 'etl'
require 'event_log'
require 'sources/csv_source'
require 'transforms/row_exploder'
require 'transforms/joiner'
require 'transforms/hash_lookup'
require 'transforms/field_renamer'
require 'transforms/multi_field_renamer'
require 'destinations/csv_destination'
require 'transforms/trim_leading_zeros'
require 'destinations/event_report_stdout'
require 'destinations/load_config_file'
require 'sources/buffered_group_by'
require 'transforms/fill'
require 'ca_entity_level_parser'
require 'transforms/with_block'
require 'gs_breakdown_id_definitions'


class CATestProcessor < GS::ETL::DataProcessor

  def initialize(source_file, output_file)
    @source_file = source_file
    @output_file = output_file
  end

  def run
    s1 = source CsvSource, @source_file

    s1.transform Fill,
      test_data_type: 'caasp',
      entity_type: 'public_charter',
      school_name: 'school_name',
      district_name: 'district_name',
      level_code: 'e,m,h'

    s1.transform RowExploder,
      :proficiency_band,
      :proficiency_band_value,
      :percentage_standard_exceeded,
      :percentage_standard_met,
      :percentage_standard_nearly_met,
      :percentage_standard_not_met

    # Map proficiency band IDs
    s1.transform(
      HashLookup,
      :proficiency_band,
      {
        percentage_standard_exceeded: 25,
        percentage_standard_met: 24,
        percentage_standard_nearly_met: 23,
        percentage_standard_not_met: 22,
        '' => 'null'
      },
      to: :proficiency_band_id
    )

    s1.transform(
      HashLookup,
      :test_data_type,
      {
        'caasp' => 236
      },
      to: :test_data_type_id
    )

    s1.transform MultiFieldRenamer, {
      district_code: :district_id,
      school_code: :school_id,
      test_year: :year,
      test_id: :subject,
      subgroup_id: :breakdown,
      students_tested: :number_tested,
      test_year: :year
    }

    s1.transform TrimLeadingZeros, :grade

    s1.transform(
      HashLookup,
      :subject,
      {
        '2' => 5,
        '1' => 4,
        'science' => 25,
      },
      to: :subject_id
    )


    s1.transform(
      HashLookup,
      :breakdown,
      GsBreakdownIdDefinitions.breakdown_lookup,
      to: :breakdown_id,
      ignore: ['6','7','8','90','91','92','93','94','121''202','200','203',
               '205','206', '207','220','221','222','223','204','201','224',
               '225','226','227','180', '120','142']
    )

    s1.transform FieldRenamer, :proficiency_band_value, :value_float
    s1.transform FieldRenamer, :proficiency_band_value, :school_value_float
    s1.transform FieldRenamer, :students_tested, :number_tested
    s1.transform FieldRenamer, :test_year, :year

    s1.transform WithBlock do |row|
      CaEntityLevelParser.new(row).parse
    end

    s1.destination CsvDestination, @output_file

    event_log.destination EventReportStdout

    system('clear')
    s1.transform RunOtherStep, event_log

    # s2 = s1.transform BufferedGroupBy, [:year, :grade, :level_code, :test_data_type_id, :subject_id], [:breakdown_id, :proficiency_band_id]
    s1.transform FieldRenamer, :test_data_type_id, :data_type_id
    # s2 = s1.destination LoadConfigFile, '/tmp/ca_config_file.txt', {
    #   source_id: 7,
    #   state: 'ca',
    #   notes: 'Year 2015 CA TEST',
    #   url: 'http://caaspp.cde.ca.gov/sb2015/ResearchFileList',
    #   file: 'ca/2015/output/ca.2015.1.public.charter.[level].txt',
    #   level: nil,
    #   school_type: 'public,charter'
    # }

    s1.destination CsvDestination, @output_file, :year, :entity_type,
      :entity_level, :state_id, :school_id, :school_name, :district_id,
      :district_name, :test_data_type, :test_data_type_id, :grade,
      :subject, :subject_id, :breakdown, :breakdown_id, :proficiency_band,
      :proficiency_band_id, :level_code, :number_tested, :value_float

    s1.root.run
    #s2.run
    #


  end
end

file = '/Users/samson/Development/data/ca2015_sample.txt'
# file = '/Users/samson/Development/data/ca2015_RM_csv_v1_all.txt'
output_file = '/tmp/output.csv'
CATestProcessor.new(file, output_file).run



