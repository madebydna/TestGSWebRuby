$LOAD_PATH.unshift File.dirname(__FILE__)
require 'etl'
require 'event_log'
require 'sources/csv_source'
require 'transforms/row_exploder'
require 'transforms/hash_lookup'
require 'transforms/multi_field_renamer'
require 'destinations/csv_destination'
require 'destinations/event_report_stdout'
require 'destinations/load_config_file'
require 'sources/buffered_group_by'
require 'transforms/fill'
require 'nc_entity_level_parser'
require 'nc_subroutines'
require 'transforms/with_block'
require 'nc_breakdown_definitions'
require 'transforms/column_selector'
require 'transforms/filter_out_matching_values'


class NCTestProcessor < GS::ETL::TestProcessor

  def initialize(source_file, output_file)
    @source_file = source_file
    @output_file = output_file
  end

  def run
    source_step = CsvSource.new(@source_file, col_sep: "\t")

    s1 = GS::ETL::StepsBuilder.new(source_step)

    s1.transform ColumnSelector, :school_code, :name,	:subject,	:grade, :subgroup,	:num_tested,
      :pct_l1,	:pct_l2,	:pct_l3, :pct_l4,	:pct_l5

    s1.transform Fill,
      year: '2015',
      entity_type: 'public_charter_private',
      district_name: 'district_name'

    s1.transform MultiFieldRenamer, {
        school_code: :school_id,
        name: :school_name,
        subgroup: :breakdown,
        num_tested: :number_tested,
        pct_l1: :level_1,
        pct_l2: :level_2,
        pct_l3: :level_3,
        pct_l4: :level_4,
        pct_l5: :level_5
    }

    s1.transform FilterOutMatchingValues, :breakdown, /^male_*/i,/^fem_*/i

    s1.transform FilterOutMatchingValues, :type, 'MC','EXT2','EXT1','RG','X1','X2'

    s1.transform FilterOutMatchingValues, :grade, 'gs'

    s1.transform FilterOutMatchingValues, :subject, 'EOG','EOC','ALL'



    s1.transform RowExploder,
      :proficiency_band,
      :proficiency_band_value,
      :level_1,
      :level_2,
      :level_3,
      :level_4,
      :level_5

    # Map proficiency band IDs
    s1.transform(
      HashLookup,
      :proficiency_band,
      {
        level_1: 115,
        level_2: 116,
        level_3: 117,
        level_4: 118,
        level_5: 119,
        '' => 'null'
      },
      to: :proficiency_band_id
    )

    s1.transform(
      HashLookup,
      :subject,
      {
        'MA' => 5, #mathematics
        'RD' => 2, #reading
        'SC' => 25, #science
        'A1' => 7, #algebra_i
        'BI' => 29, #biology
        'E2' => 27 #english_ii
      },
      to: :subject_id
    )
    #
    s1.transform(
      HashLookup,
      :breakdown,
       NcBreakdownDefinitions.breakdown_lookup,
      to: :breakdown_id,
      ignore: ['aig_math','aig_read']
    )

    s1.transform FieldRenamer, :proficiency_band_value, :value_float

    s1.transform WithBlock do |row|
      NcEntityLevelParser.new(row).parse
    end

    s1.transform WithBlock do |row|
      NcSubroutines.new(row).parse
    end

    column_order = [ :year, :entity_type, :entity_level, :state_id, :school_id, :school_name,
      :district_id, :district_name, :test_data_type, :test_data_type_id, :grade,
      :subject, :subject_id, :breakdown, :breakdown_id, :proficiency_band,
      :proficiency_band_id, :level_code, :number_tested, :value_float]

    s1.destination CsvDestination, @output_file, *column_order

    source_step.run

  end
end

file = '/Users/rhunter/CodeGS/etl_data_files/Disag_2014-15_Data.txt'

output_file = '/Users/rhunter/CodeGS/etl_data_files/nc_transformed_output.txt'

NCTestProcessor.new(file, output_file).run



