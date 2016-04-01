$LOAD_PATH.unshift File.dirname(__FILE__)
require 'etl'
require 'test_processor'
require 'event_log'
require 'sources/csv_source'
require 'transforms/transposer'
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
require 'transforms/value_concatenator'
require 'transforms/unique_values'
require 'destinations/column_value_report'

class WATestProcessor < GS::ETL::TestProcessor
  attr_reader :runnable_steps, :attachable_input_step, :attachable_output_step

  def initialize(source_file, output_files)
    @source_file = source_file
    @runnable_steps = []
    @attachable_input_step = nil
    @attachable_output_step = nil
  end

  def source_steps
    [
      # school_sbac_by_subgroup,
      # school_sbac,
      district_sbac_by_subgroup,
      district_sbac
    ]
  end

  def build_graph
    return if @graph_built

    @runnable_steps = [
      # school_sbac_by_subgroup_source,
      # school_sbac_source,
      district_sbac_by_subgroup_source,
      district_sbac_source
    ]

    combined_sources_step = union_steps(
      # school_sbac_by_subgroup,
      # school_sbac,
      district_sbac_by_subgroup,
      district_sbac
    )


    s1 = combined_sources_step.transform(ColumnSelector,
                                         :countydistrictnumber,
                                         :schoolyear,
                                         :school,
                                         :entity_level,
                                         :district,
                                         :district_id,
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
      entity_type: 'public_charter',
      level_code: 'e,m,h',
      test_data_type: 'sbac',
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

    s1 = s1.transform WithBlock do |row|
      if row[:breakdown] == 'hispanic_latino_of_any_races'
        row[:breakdown] = 'hispanic_latino_of_any_race_s'
      end
      row
    end

    s1 = s1.transform WithBlock do |row|
      row[:district_id] = '00000' if row[:district_id] == '-'
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

    s1 = s1.transform WithBlock do |row|
      # prof_null => {
      # 	sbac => ['level_basic','level_3','level_4']
      # }
      if row[:elapercentlevelbasic] || row[:elapercentlevel3] || row[:elapercentlevel4]
        row[:elapercentnull] = 
          row[:elapercentlevelbasic].to_f + 
          row[:elapercentlevel3].to_f + 
          row[:elapercentlevel4].to_f
      end
      if row[:mathpercentlevelbasic] || row[:mathpercentlevel3] || row[:mathpercentlevel4]
        row[:mathpercentnull] = 
          row[:mathpercentlevelbasic].to_f + 
          row[:mathpercentlevel3].to_f + 
          row[:mathpercentlevel4].to_f
      end
      row
    end

    s1 = s1.transform Transposer,
      [:subject, :proficiency_band],
      :value_float,
      :elapercentlevel1,
      :elapercentlevel2,
      :elapercentlevel3,
      :elapercentlevel4,
      :elapercentlevelbasic,
      :elapercentnull,
      :mathpercentlevel1,
      :mathpercentlevel2,
      :mathpercentlevel3,
      :mathpercentlevel4,
      :mathpercentlevelbasic,
      :mathpercentnull

    s1 = s1.transform(WithBlock) { |row| row if row[:value_float] != nil }

    s1 = s1.transform HashLookup,
      :subject,
      {
        mathpercentlevel1: :math, 
        mathpercentlevel2: :math, 
        mathpercentlevel3: :math, 
        mathpercentlevel4: :math,
        mathpercentlevelbasic: :math,
        mathpercentnull: :math,
        elapercentlevel1: :reading, 
        elapercentlevel2: :reading, 
        elapercentlevel3: :reading, 
        elapercentlevel4: :reading, 
        elapercentnull: :reading,
        elapercentlevelbasic: :reading
      }

    s1 = s1.transform WithBlock do |row|
      if row[:subject] == :math
        row[:number_tested] = row[:mathtotaltested]
      elsif row[:subject] == :reading
        row[:number_tested] = row[:elatotaltested]
      end
      row
    end

    s1 = s1.transform WithBlock do |row|
      row if row[:number_tested] && row[:number_tested].to_i >= 10
    end

    s1 = s1.transform HashLookup,
      :proficiency_band,
      {
        mathpercentlevel1: :level_1, 
        mathpercentlevel2: :level_2, 
        mathpercentlevel3: :level_3, 
        mathpercentlevel4: :level_4,
        mathpercentlevelbasic: :level_basic,
        mathpercentnull: :null,
        elapercentlevel1: :level_1, 
        elapercentlevel2: :level_2, 
        elapercentlevel3: :level_3, 
        elapercentlevel4: :level_4, 
        elapercentlevelbasic: :level_basic,
        elapercentnull: :null
      }


    s1 = s1.transform HashLookup,
      :subject,
      {
        math: 5,
        reading: 2
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
        null: :null
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

    attach_to_step(column_value_report, s1)

    s1 = s1.transform WithBlock do |row|
      if row[:value_float] && row[:value_float].to_s.include?('.')
        row[:value_float] = "%g" % row[:value_float].to_f.round(1)
      end
      row
    end

    s1 = s1.add(output_files_step_tree)

    @graph_built = true
    self
  end

  def run
    build_graph
    runnable_steps.each(&:run)
  end


  def school_sbac_source
    @_school_sbac_source ||= tab_delimited_source(
      [
        '/Users/samson/Development/data/wa/2_23_SBA Scores by School.txt'
      ]
    )
  end

  def column_value_report
    @_column_value_report ||= (
      ColumnValueReport.new(
        '/Users/samson/Desktop/column_value_report.tsv',
        *(COLUMN_ORDER - [:value_float, :number_tested])
      )
    )
  end

  # def state_sbac_by_subgroup_source
  #   @_school_sbac_by_subgroup_source ||= tab_delimited_source(
  #     [
  #       '/Users/samson/Development/data/wa/State SBA Scores by Subgroup 1.txt',
  #       '/Users/samson/Development/data/wa/State SBA Scores by Subgroup 2.txt'
  #     ]
  #   )
  # end

  # def state_sbac_by_subgroup
  #   @_state_sbac_by_subgroup ||= (
  #     s = state_sbac_by_subgroup_source.transform Fill,


  #   )
  # end

  def school_sbac
    @_school_sbac ||= (
      s = school_sbac_source.transform Fill,
        subgroup: 'all_students',
        entity_level: 'school'
      s = s.transform FieldRenamer, :countydistrictnumber, :district_id
      s
    )
  end

  def school_sbac_by_subgroup_source
    @_school_sbac_by_subgroup_source ||=
      tab_delimited_source(
        [
          '/Users/samson/Development/data/wa/School_SBA_Scores_by_Subgroup_1.txt',
          '/Users/samson/Development/data/wa/School SBA Scores by Subgroup 2.txt'
        ]
      )
  end

  def school_sbac_by_subgroup
    @_school_sbac_by_subgroup ||= (
      s = school_sbac_by_subgroup_source
      s = s.transform Fill,
        ESD: nil,
        entity_level: 'school'
      s
    )
  end

  def district_sbac_by_subgroup_source
    @_district_sbac_by_subgroup_source ||=
      tab_delimited_source([
        '/Users/samson/Development/data/wa/District SBA Scores by Subgroup 1.txt',
        '/Users/samson/Development/data/wa/District SBA Scores by Subgroup 2.txt'
      ])
  end

  def district_sbac_source
    @_district_sbac_by_subgroup_source ||=
      tab_delimited_source([
        '/Users/samson/Development/data/wa/District SBA Scores by Subgroup 1.txt',
        '/Users/samson/Development/data/wa/District SBA Scores by Subgroup 2.txt'
      ])
  end


  def district_sbac
    @_district_sbac ||= (
      s = district_sbac_source
      s = s.transform Fill,
        subgroup: 'all_students',
        schoolid: 'school',
        entity_level: 'district'
      s
    )
  end

  def district_sbac_by_subgroup
    @_district_sbac_by_subgroup ||= (
      s = district_sbac_by_subgroup_source
      s = s.transform Fill,
        schoolid: 'school',
        entity_level: 'district'
      s
    )
  end

  # requires the 'graph' gem
  def draw
    require 'graph'
    g = Graph.new
    steps = [
      district_sbac_by_subgroup_source,
      district_sbac_source
    ]
    steps.each do |source|
      source.to_a.each { |s| g.node(s.descriptor) }
      source.each_edge do |node1, node2|
        g.edge(node1.descriptor, (node2.descriptor))
      end
    end
    g.save "etl_graph", "png"
  end
end


WATestProcessor.new(nil, {}).run



