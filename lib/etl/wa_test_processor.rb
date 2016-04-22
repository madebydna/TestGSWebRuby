$LOAD_PATH.unshift File.dirname(__FILE__)
require 'etl'
require 'test_processor'
require 'sources/csv_source'
require 'destinations/csv_destination'
require 'destinations/load_config_file'
require 'sources/buffered_group_by'
require 'ca_entity_level_parser'
require 'transforms/with_block'
require 'gs_breakdown_definitions'
require 'gs_breakdowns_from_db'
require 'destinations/column_value_report'

class WATestProcessor < GS::ETL::TestProcessor
  attr_reader :runnable_steps, :attachable_input_step, :attachable_output_step

  def initialize(*args)
    super(*args)
    @year = 2015
  end

  def source_steps
    [
      school_sbac_by_subgroup,
      school_sbac,
      district_sbac_by_subgroup,
      district_sbac,
      state_sbac_by_subgroup,
      state_sbac
    ]
  end

  def build_graph
    return if @graph_built

    @runnable_steps = [
      school_sbac_by_subgroup_source,
      school_sbac_source,
      district_sbac_by_subgroup_source,
      district_sbac_source,
      state_sbac_by_subgroup_source,
      state_sbac_source
    ]

    source(file_with_subgroups, foo: :bar) do |node|
      node.transform(Blah).
      node.transform Blah
      node.transform Blah
      node.transform Blah
    end

    combined_sources_step = union_steps(
      school_sbac_by_subgroup,
      school_sbac,
      district_sbac_by_subgroup,
      district_sbac,
      state_sbac_by_subgroup,
      state_sbac
    )


    s1 = combined_sources_step.transform('Select useful columns',
                                         ColumnSelector,
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
    
    s1 = s1.transform 'Fill entity_type, level_code, test_data_type and test_data_type_id',
      Fill,
      entity_type: 'public_charter',
      level_code: 'e,m,h',
      test_data_type: 'sbac',
      data_type_id: 240,
      test_data_type_id: 240

    s1 = s1.transform "Rename subgroup to breakdown, \n" +
                      'Remove special characters, replace spaces with underscores',
      WithBlock do |row|
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

    s1 = s1.transform 'Handle hispanic_latino_of_any_races breakdown',
      WithBlock do |row|
        if row[:breakdown] == 'hispanic_latino_of_any_races'
          row[:breakdown] = 'hispanic_latino_of_any_race_s'
        end
        row
      end

    s1 = s1.transform 'Replace hyphen district_id with five zeros',
      WithBlock do |row|
        row[:district_id] = '00000' if row[:district_id] == '-'
        row
      end

    s1 = s1.transform 'Map state breakdown strings to GS breakdown IDs',
      HashLookup,
      :breakdown,
      {
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

    s1 = s1.transform 'Sum basic, level3, and level4 proficiency levels to get proficiency band null',
      WithBlock do |row|
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

    s1 = s1.transform "Convert subject+proficiency band columns into subject \n" +
                      'and proficiency band columns, with rows for each subject / band',
      Transposer,
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

    s1 = s1.transform 'Remove rows with nil value_float',
      WithBlock do |row|
        row if row[:value_float] != nil
      end

    s1 = s1.transform 'After transposing, Map values in new subject field to correct subject',
      HashLookup,
      :subject,
      {
        mathpercentlevel1: :math, 
        mathpercentlevel2: :math, 
        mathpercentlevel3: :math, 
        mathpercentlevel4: :math,
        mathpercentlevelbasic: :math,
        mathpercentnull: :math,
        elapercentlevel1: :ela, 
        elapercentlevel2: :ela, 
        elapercentlevel3: :ela, 
        elapercentlevel4: :ela, 
        elapercentnull: :ela,
        elapercentlevelbasic: :ela
      }

    s1 = s1.transform "Rename [subject]totaltested to totaltested, \n" +
                      'depending on which subject this row is for',
      WithBlock do |row|
        if row[:subject] == :math
          row[:number_tested] = row[:mathtotaltested]
        elsif row[:subject] == :ela
          row[:number_tested] = row[:elatotaltested]
        end
        row
      end

    s1 = s1.transform 'Remove rows where number tested < 10',
      WithBlock do |row|
        row if row[:number_tested] && row[:number_tested].to_i >= 10
      end

    s1 = s1.transform "After transposing, Map values in new \n" +
                      'proficiency_band field to correct subject',
      HashLookup,
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


    s1 = s1.transform "Map subjects to GS subject IDs",
      HashLookup,
      :subject,
      {
        math: 5,
        ela: 4
      },
      to: :subject_id

    s1 = s1.transform "Map state proficiency bands to GS proficiency band IDs",
      HashLookup,
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

    s1 = s1.transform "Change school year range to single year",
        HashLookup,
        :schoolyear,
        {
            '2014-15' => '2015'
        }, to: :year

    s1 = s1.transform "Rename some columns in input file",
      MultiFieldRenamer,
      {
        buildingnumber: :state_id,
        gradetested: :grade,
        school: :school_name,
        district: :district_name,
        countydistrictnumber: :district_id
      }

    s1 = s1.transform "Copy state_id into school_id column",
      WithBlock do |row|
        row[:school_id] = row[:state_id]
        row
      end

    s1 = s1.transform "Format value_float. \n" +
                      "Round to 1 decimal place, remove trailing zeros",
      WithBlock do |row|
        if row[:value_float] && row[:value_float].to_s.include?('.')
          row[:value_float] = "%g" % row[:value_float].to_f.round(1)
        end
        row
      end

    last_before_split = s1.transform(
      "Get rid of rows without school, district,\n" + 
      "or state entity level",
      KeepRows,
      :entity_level,
      *['district','school','state']
    )

    @runnable_steps << last_before_split.destination(
      '', LoadConfigFile, config_output_file, config_hash)

    s1 = s1.add(output_files_step_tree)

    attach_to_step(column_value_report, s1)

    @graph_built = true
    self
  end

  def run
    build_graph
    runnable_steps.each(&:run)
  end

  def config_hash
    {
      source_id: 8,
      state: 'wa',
      notes: 'DXT-1558: WA 2015 SBAC',
      url: 'http://reportcard.ospi.k12.wa.us/DataDownload.aspx',
      file: 'wa/2015/output/wa.2015.1.public.charter.[level].txt',
      level: nil,
      school_type: 'public,charter'
    }
  end

  def school_sbac_source
    @_school_sbac_source ||= tab_delimited_source(
      [
        '2_23_SBA Scores by School.txt'
      ]
    )
  end

  def column_value_report
    @_column_value_report ||= (
      ColumnValueReport.new(
        '/tmp/column_value_report.tsv',
        *(COLUMN_ORDER - [:value_float, :number_tested])
      )
    )
  end

  def school_sbac
    @_school_sbac ||= (
      s = school_sbac_source.transform 'Fill subgroup and entity_level columns', Fill,
        subgroup: 'all_students',
        entity_level: 'school'
      s = s.transform 'Rename countydistrictnumber to district_id', FieldRenamer, :countydistrictnumber, :district_id
      s
    )
  end

  def school_sbac_by_subgroup_source
    @_school_sbac_by_subgroup_source ||=
      tab_delimited_source(
        [
          'School_SBA_Scores_by_Subgroup_1.txt',
          'School SBA Scores by Subgroup 2.txt'
        ]
      )
  end

  def school_sbac_by_subgroup
    @_school_sbac_by_subgroup ||= (
      s = school_sbac_by_subgroup_source
      s = s.transform 'Fill ESD and entity_level columns', Fill,
        ESD: nil,
        entity_level: 'school'
      s
    )
  end

  def district_sbac_by_subgroup_source
    @_district_sbac_by_subgroup_source ||=
      tab_delimited_source([
        'District SBA Scores by Subgroup 1.txt',
        'District SBA Scores by Subgroup 2.txt'
      ])
  end

  def district_sbac_source
    @_district_sbac_source ||=
      tab_delimited_source([
        '2_22_SBA Scores by District.txt'
      ])
  end

  def state_sbac_by_subgroup_source
    @_state_sbac_by_subgroup_source ||=
      tab_delimited_source([
        'State SBA Scores by Subgroup 1.txt',
        'State SBA Scores by Subgroup 2.txt'
      ])
  end

  def state_sbac_source
    @_state_sbac_source ||=
      tab_delimited_source([
        '2_21_SBA Scores by State.txt'
      ])
  end

  def state_sbac
    @state_sbac ||= (
      s = state_sbac_source
      s = s.transform "Fill missing columns for state file", Fill,
        esd: nil,
        countynumber: nil,
        county: nil,
        countydistrictnumber: nil,
        district: nil,
        entity_level: 'state',
        subgroup: 'all_students'
      s
    )
  end

  def state_sbac_by_subgroup
    @state_sbac_by_subgroup ||= (
      s = state_sbac_by_subgroup_source
      s = s.transform "Fill missing columns for state file", Fill,
        esd: nil,
        countynumber: nil,
        county: nil,
        countydistrictnumber: nil,
        entity_level: 'state',
        district: nil
      s
    )
  end

  def district_sbac
    @_district_sbac ||= (
      s = district_sbac_source
      s = s.transform 'Copy buildingnumber to countydistrictnumber which will eventually become state_id', WithBlock do |row|
        row[:buildingnumber] = row[:countydistrictnumber]
        row
      end
      s = s.transform 'Add subgroup, schoolid, entity_level to District SBAC',
        Fill,
        subgroup: 'all_students',
        schoolid: 'school',
        entity_level: 'district'
      s
    )
  end

  def district_sbac_by_subgroup
    @_district_sbac_by_subgroup ||= (
      s = district_sbac_by_subgroup_source
      s = s.transform 'Copy buildingnumber to countydistrictnumber which will eventually become state_id', WithBlock do |row|
        row[:buildingnumber] = row[:countydistrictnumber]
        row
      end
      s = s.transform 'Add schoolid and entity_level to District SBAC by Subgroup',
        Fill,
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


# WATestProcessor.new('/Users/samson/Development/data/wa', max: 100).build_graph.run
WATestProcessor.new(ARGV[0], max: (ARGV[1] && ARGV[1].to_i) ).run
