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
require 'gs_breakdown_definitions'
require 'transforms/column_selector'
require 'transforms/keep_rows'
require 'transforms/value_concatonator'
require 'transforms/filter_out_matching_values'

class CATestProcessor < GS::ETL::DataProcessor

  def initialize(source_file)
    @source_file = source_file
    @year = '2015'
  end

  def config_hash
    {
      source_id: 7,
      state: 'ca',
      notes: 'Year 2015 CA TEST',
      url: 'http://caaspp.cde.ca.gov/sb2015/ResearchFileList',
      file: 'ca/2015/output/ca.2015.1.public.charter.[level].txt',
      level: nil,
      school_type: 'public,charter'
    }
  end

  def run
    s1 = source CsvSource, @source_file

    s1.transform ColumnSelector, :test_year, :state_id, :county_code, :district_code,
      :school_code, :subgroup_id, :test_type, :test_id, :grade, :students_tested,
      :percentage_standard_exceeded, :percentage_standard_met, 
      :percentage_standard_nearly_met, :percentage_standard_not_met

    s1.transform Fill,
      test_data_type: 'caasp',
      entity_type: 'public_charter',
      school_name: 'school_name',
      district_name: 'district_name',
      level_code: 'e,m,h'

    s1.transform ValueConcatonator, :state_id, :county_code,
      :district_code, :school_code

    s1.transform RowExploder,
      :proficiency_band,
      :proficiency_band_value,
      :percentage_standard_exceeded,
      :percentage_standard_met,
      :percentage_standard_nearly_met,
      :percentage_standard_not_met

    s1.transform FilterOutMatchingValues, ['*'], :proficiency_band_value

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

    s1.transform(
      HashLookup,
      :test_data_type,
      {
        'caasp' => 236
      },
      to: :data_type_id
    )

    s1.transform MultiFieldRenamer, {
      district_code: :district_id,
      school_code: :school_id,
      test_year: :year,
      test_id: :subject,
      subgroup_id: :breakdown,
      students_tested: :number_tested
    }

    s1.transform TrimLeadingZeros, :grade

    s1.transform WithBlock do |row|
      row[:grade] = 'All' if row[:grade] == '13'
      row
    end

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
        GsBreakdownDefinitions.breakdown_lookup,
      to: :breakdown_id,
      ignore: ['6','7','8','90','91','92','93','94','121''202','200','203',
               '205','206', '207','220','221','222','223','204','201','224',
               '225','226','227','180', '120','142']
    )

    s1.transform FieldRenamer, :proficiency_band_value, :value_float

    s1.transform WithBlock do |row|
      CaEntityLevelParser.new(row).parse
    end

    s1.transform KeepRows, ['district','school','state'], :entity_level

    s1.add(output_files_step_tree)

    config_node = s1.destination LoadConfigFile, config_output_file, config_hash

    # event_log.destination EventReportStdout
    # system('clear')
    # s1.transform RunOtherStep, event_log

    s1.root.run
    config_node.run

  end
end

# file = '/Users/jwrobel/dev/data/ca2015_all_csv_v1.txt'

# file = '/Users/samson/Development/data/ca2015_RM_csv_v1_all.txt'

CATestProcessor.new(file).run
