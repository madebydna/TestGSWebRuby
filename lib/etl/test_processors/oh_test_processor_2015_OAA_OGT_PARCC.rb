$LOAD_PATH.unshift File.expand_path('../..', __FILE__)
require 'etl'
require 'test_processor'
require 'sources/csv_source'
require 'destinations/csv_destination'
require 'destinations/load_config_file'
require 'sources/buffered_group_by'
require 'ca_entity_level_parser'
require 'gs_breakdown_definitions'
require 'gs_breakdowns_from_db'


GS::ETL::Logging.logger = GS::ETL::Logging::AggregatingLogger.build_stdout_logger
class OhTestProcessor2015OAAOGTPARCC < GS::ETL::TestProcessor
  attr_reader :runnable_steps, :attachable_input_step, :attachable_output_step, :grade_subject_column_headers

  def config_hash
    {
     file: 'foo'
    }
  end

  source(
    ExcelSource,
    [
      '1415_DIST_ETHNIC.xlsx',
      '1415_district_gender.xlsx',
      '1415_district_lep_tabs.xlsx',
      '1415_district_all_tabs.xlsx'
    ],
    'district_files'
  ) do |s|
    s = s.transform 'remove all invalid rows', DeleteRows, :watermark, /Achievement/, /K-3 Literacy data/

    s = s.transform 'get value for combined subject and grade', Transposer,
       :subject_grade,
       :value_float,
       /15.*proficient/i

    s = s.transform 'fill \'district\' for entity level, school id and name', Fill, {
      entity_level: 'district',
      school_id: 'district',
      school_name: 'district'
    }

    s = s.transform 'copy district_irn value to state_id', WithBlock do |row|
      row[:state_id] = row[:district_irn]
      row
    end

    s = s.transform 'rename district_irn to district_id', FieldRenamer, :district_irn, :district_id

    s = s.transform 'split out subject and grade into 2 columns', WithBlock do |row|
      value = row[:subject_grade]
      value = value.to_s.split('_201415').first
      subject_grade_match = /(\D+)(\d+)?/.match(value)
      subject = subject_grade_match[1].gsub('_end_of_course','')
      grade = subject_grade_match[2] || 'All'
      subject = subject.chomp('_')
      row[:subject] = subject
      row[:grade] = grade
      row
    end
  end

  source(
    CsvSource,
    [
      '1415_school_ethnic_tabs.txt',
      '1415_school_gender_tabs.txt',
      '1415_school_lep_tabs.txt',
      '1415_school_all_tabs.txt'
    ],
    'school_files',
    col_sep: "\t"
  ) do |s|

    s = s.transform 'remove all invalid rows for schools', DeleteRows, :watermark, /Achievement/, /K-3 Literacy data/

    s = s.transform 'get value for combined subject and grade for schools', Transposer,
      :subject_grade,
      :value_float,
      /15.*proficient/i

    s = s.transform 'split out subject and grade into 2 columns for schools', WithBlock do |row|
      value = row[:subject_grade]
      value = value.to_s.split('_201415').first
      subject_grade_match = /(\D+)(\d+)?/.match(value)
      subject = subject_grade_match[1].gsub('_end_of_course','')
      grade = subject_grade_match[2] || 'All'
      subject = subject.chomp('_')
      row[:subject] = subject
      row[:grade] = grade
      row
    end

    s = s.transform 'set entity level to school', Fill,
      entity_level: 'school'

    s = s.transform 'set building_irn to state_id for schools', ValueConcatenator, :state_id, :building_irn

    s = s.transform 'rename district irn, building_name and building irn for schools', MultiFieldRenamer, {
      district_irn: :district_id,
      building_name: :school_name,
      building_irn: :school_id
    }
  end

  source(
    CsvSource,
    [
      '1415_state_gender_proficiency_values.csv',
      '1415_state_lep_proficiency_values.csv',
      '1415_state_frl_proficiency_values.csv',
      '1415_state_race_proficiency_values.csv'
    ],
    'school_files',
    col_sep: ",",
    quote_char: '"'
  ) do |s|

    s = s.transform 'fill \'state\' into entity type, entity level, and district, and school fields', Fill,
    {
      district_id: 'state',
      state_id: 'state',
      entity_level: 'state',
      district_name: 'state',
      school_id: 'state',
      school_name: 'state'
    }
    
    s = s.transform 'get value for combined grade and breakdown for all proficiency columns', Transposer,
      :grade_breakdown,
      :value_float,
      /proficiency_level_pct_of_total/

    s = s.transform 'get value for combined grade and breakdown for all number_tested columns', Transposer,
      :grade_breakdown_2,
      :number_tested,
      /students_tested/

    s = s.transform 'Remove some transposed rows', WithBlock do |row|
       row[:grade_breakdown][0..30] == row[:grade_breakdown_2][0..30] ? row : nil
    end 

    s = s.transform 'remove test values for students not matching grade of test', WithBlock do |row|
      if row[:test_grade]
        grade_match = row[:test_grade].downcase.gsub(' ','_')
        if ! row[:grade_breakdown].to_s.include?(grade_match)
          row = nil
        end
      end
      row
    end

    s = s.transform 'get student group from grade breakdown', WithBlock do |row|
      grade_breakdown = row[:grade_breakdown].to_s
      matches = /grade(.*)(?=proficiency)/.match(grade_breakdown)
      if matches
        row[:student_group] = /grade(.*)(?=proficiency)/.match(grade_breakdown)[1]
      end
      row
    end

    s = s.transform 'Calculate total number tested per group and update rows in group', 
      ExecuteBlockWhenRowGroupChanges, [
        :district_id,
        :state_id,
        :test_grade,
        :test_subject
      ], 
      pass_rows_through_on_key_same: true,
      pass_rows_through_on_key_change: true do |rows|
        rows_by_student_group = rows.group_by { |r| r[:student_group] }
        rows_by_student_group.each_pair do |_, row_group|
          total = row_group.inject(0.0) { |sum, r| sum += r[:number_tested].to_f }
          row_group.each { |r| r[:number_tested] = total }
        end
        nil
        # rows
      end
  end

  shared do |s|
    s = s.transform 'Select only interesting columns', ColumnSelector,
      :year,
      :entity_type,
      :entity_level,
      :state_id,
      :school_id,
      :school_name,
      :district_id,
      :district_name,
      :test_data_type,
      :test_data_type_id,
      :test_grade,
      :test_subject,
      :subject_id,
      :student_group,
      :proficiency_level,
      :level_code,
      :number_tested,
      :value_float

    s = s.transform 'Set year, level code, and test data type', Fill,
      entity_type: 'public_charter',
      year: 2015,
      level_code: 'e,m,h',
      test_data_type: 'oaa',
      test_data_type_id: 20

    s = s.transform 'add student group All for files w/o student group', WithBlock do |row|
      row[:student_group] = 'All' unless row.has_key?(:student_group)
      row
    end

    s = s.transform 'Rename proficiency band',
      FieldRenamer, :proficiency_level, :proficiency_band

    s = s.transform 'Rename student group',
      FieldRenamer, :student_group, :breakdown

    s = s.transform 'rename grade and subject column', MultiFieldRenamer, {
      :test_grade => :grade,
      :test_subject => :subject
    }

    s = s.transform 'Look up GS subject ID for each subject', HashLookup,
      :subject,
      {
        'mathematics' => 5,
        'math' => 5,
        'reading' => 2,
        'Reading' => 2,
        'science' => 25,
        'social_studies' => 24,
        'writing' => 3,
        '' => 'null',
        nil => 'null'
      },
      to: :subject_id

      s = s.transform 'Normalize breakdown before ID lookup', WithBlock do |row|
        if row[:breakdown]
          row[:breakdown] = row[:breakdown].gsub(/\s+/, '_').downcase
        end
        row
      end

    # HashLookup: breakdown:yeslimited_english_proficiency_flag_state_tests                                * Not Mapped *       Sum: 2      Avg: 100.0%
    # HashLookup: breakdown:nolimited_english_proficiency_flag_state_tests                                 * Not Mapped *       Sum: 2      Avg: 100.0%
    s = s.transform 'Look up breakdown IDs', HashLookup,
    :breakdown,
    {
      'all' => 1,
      'disabled' => 13,
      'not_disabled' => 14,
      'nondisabled' => 14,
      'disadvantaged' => 9,
      'nondisadvantaged' => 10,
      'frl' => 9,
      'nonfrl' => 10,
      'economically_disadvantaged' => 9,
      'yeconomic_disadvantage_flag' => 9,
      'non_economically_disadvantaged' => 10,
      'american_indian_or_alaskan_native' => 4,
      'asian_or_pacific_islander' => 22,
      'pacific_islander' => 7,
      'asian' => 2,
      'black' => 3,
      'black_non_hispanic' => 3,
      'black_nonhispanic' => 3,
      'hispanic' => 6,
      'multiracial' => 21,
      'white' => 8,
      'white_nonhispanic' => 8,
      'white_non_hispanic' => 8,
      'female' => 11,
      'male' => 12,
      'lep' => 15,
      'nonlep' => 16,
      'migrant' => 19,
      'notmigrant' => 28,
      'gifted' => 66,
      'nongifted' => 120
    },
    to: :breakdown_id

    s = s.transform 'look up proficiency bands', HashLookup,
      :proficiency_band,
      {
        nil => 'null',
        'Limited' => 208,
        'Basic' => 209,
        'Proficient' => 210,
        'Accelerated' => 211,
        'Advanced' => 212,
        'Advanced Plus' => 213
      },
      to: :proficiency_band_id

    s = s.transform 'get numeric grade', WithBlock do |row|
      matches = /(\d+)/.match(row[:grade])
      row[:grade] = matches[1] if matches
      row
    end

    s = s.transform 'remove empty values', DeleteRows, :value_float, nil, '--', 'NC'

    s = s.transform 'convert values with < to negative', WithBlock do |row|
      row[:value_float] = row[:value_float].gsub(/[<>]/,'-') unless row[:value_float].nil?
      row
    end
  end

  def draw
    require 'graph'
    g = Graph.new
    @sources.each do |source|
      g.node(source.descriptor)
      source.each_edge do |node1, node2|
        g.edge(node1.descriptor, (node2.descriptor))
      end
    end
    g.save "etl_graph", "png"
  end

end


raise ArgumentError.new('****Requires directory holding prepped files as command line argument****')  unless ARGV[0]

processor = OhTestProcessor2015OAAOGTPARCC.new(ARGV[0], max: (ARGV[1] && ARGV[1].to_i) )
processor.build_graph
processor.draw
OhTestProcessor2015OAAOGTPARCC.new(ARGV[0], max: (ARGV[1] && ARGV[1].to_i), offset: 0).run
