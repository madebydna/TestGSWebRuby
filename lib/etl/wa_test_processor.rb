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
require 'gs_breakdowns_from_db'
require 'transforms/column_selector'
require 'transforms/keep_rows'
require 'transforms/value_concatonator'
require 'transforms/unique_values'


class WATestProcessor < GS::ETL::DataProcessor

  def initialize(source_file, output_files)
    @source_file = source_file
    @state_output_file = output_files.fetch(:state)
    @school_output_file = output_files.fetch(:school)
    @district_output_file = output_files.fetch(:district)
    @unique_values_output_file = output_files.fetch(:unique_values)
  end

  def run
    s1 = combined_sources_step.transform(ColumnSelector,
                                         :countydistrictnumber,
                                         :schoolyear,
                                         :school,
                                         :district,
                                         :subgroup,
                                         :buildingnumber,
                                         :gradetested,
                                         :elatotaltested,
                                         :elapercentlevel1,
                                         :elapercentlevel2,
                                         :elapercentlevelbasic,
                                         :elapercentlevel3,
                                         :elapercentlevel4,
                                         :mathtotaltested,
                                         :mathpercentlevel1,
                                         :mathpercentlevel2,
                                         :mathpercentlevelbasic,
                                         :mathpercentlevel3,
                                         :mathpercentlevel4)
    
    s1 = s1.transform Fill,
      entity_level: 'school',
      entity_type: 'public_charter',
      level_code: 'e,m,h',
      test_data_type: 'SBAC',
      test_data_type_id: 240

    s1 = s1.transform WithBlock do |row|
      breakdown_string = row[:subgroup]
      if breakdown_string
        breakdown_string.gsub!(/[^\w ]+/, '')
        breakdown_string.gsub!(/[ ]+/, '_')
        breakdown_string.downcase!
        row[:breakdown] = breakdown_string
        row.delete(:subgroup)
      end
      row
    end

    s1 = s1.transform HashLookup, :breakdown, {
                                    'all_students' => 1,
                                    'american_indian_alaskan_native' => 4,
                                    'asian' => 2,
                                    'asian_pacific_islander' => 22,
                                    'black_african_american' => 3,
                                    'female' => 11,
                                    'hispanic_latino_of_any_race_s' => 6,
                                    'limited_english' => 15,
                                    'low_income' => 9,
                                    'male' => 12,
                                    'migrant' => 19,
                                    'non_low_income' => 10,
                                    'non_special_education' => 14,
                                    'native_hawaiian_other_pacific_islander' => 7,
                                    'special_education' => 13,
                                    'two_or_more_races' => 21,
                                    'white' => 8
                                  },
                                  to: :breakdown_id

    s1 = s1.transform RowExploder,
      [:subject, :proficiency_band],
      :value_float,
      :elapercentlevel1,
      :elapercentlevel2,
      :elapercentlevel3,
      :elapercentlevel4,
      :elapercentlevelbasic,
      :mathpercentlevel1,
      :mathpercentlevel2,
      :mathpercentlevel3,
      :mathpercentlevel4,
      :mathpercentlevelbasic

    s1 = s1.transform(WithBlock) { |row| row if row[:value_float] != nil }

    s1 = s1.transform HashLookup,
      :subject,
      {
        mathpercentlevel1: :math, 
        mathpercentlevel2: :math, 
        mathpercentlevel3: :math, 
        mathpercentlevel4: :math,
        mathpercentlevelbasic: :math,
        elapercentlevel1: :ela, 
        elapercentlevel2: :ela, 
        elapercentlevel3: :ela, 
        elapercentlevel4: :ela, 
        elapercentlevelbasic: :ela
      }

    s1 = s1.transform HashLookup,
      :proficiency_band,
      {
        mathpercentlevel1: :level_1, 
        mathpercentlevel2: :level_2, 
        mathpercentlevel3: :level_3, 
        mathpercentlevel4: :level_4,
        mathpercentlevelbasic: :level_basic,
        elapercentlevel1: :level_1, 
        elapercentlevel2: :level_2, 
        elapercentlevel3: :level_3, 
        elapercentlevel4: :level_4, 
        elapercentlevelbasic: :level_basic
      }

    s1 = s1.transform HashLookup,
      :subject,
      {
        math: 5,
        ela: 2
      },
      to: :subject_id

    s1 = s1.transform HashLookup,
      :proficiency_band,
      {
        level_1: 183,
        level_2: 184,
        level_3: 186,
        level_4: 187,
        level_basic: 185,
        level_1: 183,
        level_2: 184,
        level_3: 186,
        level_4: 187,
        level_basic: 185
      },
      to: :proficiency_band_id

    s1 = s1.transform(
        HashLookup,
        :schoolyear,
        {
            '2014-15' => '2015'
        }, to: :year
    )

    s1 = s1.transform MultiFieldRenamer, {
        buildingnumber: :state_id,
        gradetested: :grade,
        school: :school_name,
        district: :district_name,
        countydistrictnumber: :district_id
    }

    s1 = s1.transform WithBlock do |row|
      row[:school_id] = row[:state_id]
      row
    end

    # column_order = [
    #     :year,
    #     :state_id,
    #     :grade,
    #     :elatotaltested,
    #     :elapercentlevel1,
    #     :elapercentlevel2,
    #     :elapercentlevelbasic,
    #     :elapercentlevel3,
    #     :elapercentlevel4,
    #     :mathtotaltested,
    #     :mathpercentlevel1,
    #     :mathpercentlevel2,
    #     :mathpercentlevelbasic,
    #     :mathpercentlevel3,
    #     :mathpercentlevel4,
    # ]

    s1 = s1.add(output_files_step_tree)

    # s1 = s1.destination CsvDestination, '/Users/samson/Desktop/test_wa.tsv', *column_order

    source_steps.each do |step|
      step.run
    end
  end

  def source_steps
    @_source_steps ||= (
      source_file_2 = '/Users/samson/Development/data/wa/2_23_SBA Scores by School.txt'
      source_file_1 = '/Users/samson/Development/data/wa/School_SBA_Scores_by_Subgroup_1.txt'

      source1 = CsvSource.new(source_file_1, col_sep: "\t")
      source1.event_log = self.event_log

      source2 = CsvSource.new(source_file_2, col_sep: "\t")
      source2.event_log = self.event_log

      [source1, source2]
    )
  end

  def combined_sources_step
    @_combined_sources_step ||= (
      s1 = source_steps[0]
      s1.transform Fill, SubGroup: nil, :'District ID' => nil

      s2 = source_steps[1]
      s2.transform Fill, CountyDistrictNumber: nil, ESD: nil
      s2.transform Fill, ESD: nil

      combined_sources_step = s1.add_step(GS::ETL::Step)
      s2.add(combined_sources_step)

      combined_sources_step
    )
  end

end

file = '/tmp/test_wa.txt'

output_files = {
  state: '/tmp/wa.2015.1.public.charter.state.txt',
  school: '/tmp/wa.2015.1.public.charter.school.txt',
  district: '/tmp/wa.2015.1.public.charter.district.txt',
  unique_values: '/tmp/wa.2015.unique_files.txt'
}

WATestProcessor.new(file, output_files).run



