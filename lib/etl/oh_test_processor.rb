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
require 'transforms/delete_rows'
require 'transforms/field_renamer'


class OHTestProcessor < GS::ETL::TestProcessor
  attr_reader :runnable_steps, :attachable_input_step, :attachable_output_step, :grade_subject_column_headers

  def build_graph

    return if @graph_built

    @runnable_steps = [
      # district_files,
      # school_files
     state_files
    ]

    combined_sources_steps = union_steps(
      # districts_pre_union_steps,
      # schools_pre_union_steps
      state_pre_union_steps
    )

#  Test output for schools and districts
    # s1 = combined_sources_steps.destination 'output test for districts and schools', CsvDestination, '/tmp/school_district_ohio_test.txt',
    #   *[ :entity_level, :grade, :subject, :student_group, :state_id, :district_id, :district_name,
    #      :school_id, :school_name, :value_float ]

#  Test output for state files
    s1 = combined_sources_steps.destination 'output test for state files', CsvDestination, '/tmp/state_ohio_test.txt',
      :value_float, :grade, :subject, :district_id, :state_id,
      :entity_level, :student_group, :district_name, :school_id, :school_name, :grade_breakdown

    s1
    @graph_built = true
    self
  end

  def run
    build_graph
    runnable_steps.each(&:run)
  end

  def district_files
    @_districts ||=(
      tab_delimited_source(
        [
          '1415_district_ethnicity_tabs.txt',
          '1415_district_gender_tabs.txt',
          '1415_district_lep_tabs.txt',
          '1415_district_all_tabs.txt'
        ].map { |file| input_filename(file) }
      )
    )
  end

  def tab_delimited_source(file)
    source = CsvSource.new(file, col_sep: "\t", max: @options[:max])
    file_name = file.first.split('/').last
    source.description = "Read #{file_name}"
    source.event_log = self.event_log
    source
  end

  def csv_source(file)
    source = CsvSource.new(file, max: @options[:max])
    file_name = file.first.split('/').last
    source.description = "Read #{file_name}"
    source.event_log = self.event_log
    source
  end

  def districts_pre_union_steps

    s = district_files

    s = s.transform 'remove all invalid rows', DeleteRows, :watermark, /Achievement/, /K-3 Literacy data/

    s = s.transform 'get value for combined subject and grade', Transposer,
       :subject_grade,
       :value_float,
       /15.*proficient/i

    s = s.transform 'remove empty values', DeleteRows, :value_float, 'NC'

    s = s.transform 'convert values with < to negative', WithBlock do |row|
      row[:value_float] = row[:value_float].gsub(/[<>]/,'-') unless row[:value_float].nil?
      row
    end

    s = s.transform 'delete nil values', DeleteRows, :value_float, nil

    s = s.transform 'split out subject and grade into 2 columns', WithBlock do |row|
      value = row[:subject_grade]
      value = value.to_s.split('_201415').first
       subject_grade_match = /(\D+)(\d+)?/.match(value)
       subject = subject_grade_match[1].gsub('_end_of_course','')
       grade = subject_grade_match[2] || 'All'
       row[:subject] = subject
       row[:grade] = grade
       row
    end

    s = s.transform 'fill \'district\' for entity level, school id and name', Fill, {
      entity_level: 'district',
      school_id: 'district',
      school_name: 'district'
    }

    s = s.transform 'set district_irn value to state_id', ValueConcatenator, :state_id, :district_irn

    s = s.transform 'rename district_irn to district_id', FieldRenamer, :district_irn, :district_id

    s = s.transform 'add student group All for files w/o student group', WithBlock do |row|
      row[:student_group] = 'All' unless row.has_key?(:student_group)
      row
    end

    s.transform 'select columns', ColumnSelector,
      :value_float, :grade, :subject, :district_id, :state_id,
      :entity_level, :student_group, :district_name, :school_id, :school_name
  end

  def school_files
    @_school_files ||=(
      tab_delimited_source(
        [
          '1415_school_ethnic_tabs.txt',
          '1415_school_gender_tabs.txt',
          '1415_school_lep_tabs.txt',
          '1415_school_all_tabs.txt'
          ].map { |file| input_filename(file) }
      )
    )
  end

  def schools_pre_union_steps

    s = school_files

    s = s.transform 'remove all invalid rows for schools', DeleteRows, :watermark, /Achievement/, /K-3 Literacy data/

    s = s.transform 'get value for combined subject and grade for schools', Transposer,
      :subject_grade,
      :value_float,
      /15.*proficient/i

    s = s.transform 'remove empty values for schools', DeleteRows, :value_float, 'NC'

    s = s.transform 'delete nil values for schools', DeleteRows, :value_float, nil

    s = s.transform 'convert values with < to negative for schools', WithBlock do |row|
      row[:value_float] = row[:value_float].gsub(/[<>]/,'-') unless row[:value_float].nil?
      row
    end

    s = s.transform 'split out subject and grade into 2 columns for schools', WithBlock do |row|
      value = row[:subject_grade]
      value = value.to_s.split('_201415').first
      subject_grade_match = /(\D+)(\d+)?/.match(value)
      subject = subject_grade_match[1].gsub('_end_of_course','')
      grade = subject_grade_match[2] || 'All'
      row[:subject] = subject
      row[:grade] = grade
      row
    end

    s = s.transform 'set entity level to school', Fill,
      entity_level: 'school'

    s = s.transform 'set building_irn to state_id for schools', ValueConcatenator, :state_id, :building_irn

    s = s.transform 'add student group All for files w/o student group for schools', WithBlock do |row|
      row[:student_group] = 'All' unless row.has_key?(:student_group)
      row
    end

    s = s.transform 'rename district irn, building_name and building irn for schools', MultiFieldRenamer, {
      district_irn: :district_id,
      building_name: :school_name,
      building_irn: :school_id
    }

    s.transform 'select columns before union for schools', ColumnSelector,
      :value_float, :grade, :subject, :district_id, :state_id, :entity_level, 
      :student_group, :district_name, :school_id, :school_name
  end

  def state_files
    @_state_files ||=(
      csv_source(
        [
          '1415_state_gender_proficiency_values.csv',
          '1415_state_lep_proficiency_values.csv',
          '1415_state_frl_proficiency_values.csv',
          '1415_state_race_proficiency_values.csv'
        ].map { |file| input_filename(file) }
      )
    )
  end

  def state_pre_union_steps
    s = state_files

    s = s.transform 'get value for combined grade and breakdown for all proficiency columns', Transposer,
      :grade_breakdown,
      :value_float,
      /proficiency_level_pct_of_total/

    s = s.transform 'remove empty values', DeleteRows, :value_float, nil, '--'

    s = s.transform 'remove test values for students not matching grade of test', WithBlock do |row|
      grade_match = row[:test_grade].downcase.gsub(' ','_')
      if ! row[:grade_breakdown].to_s.include?(grade_match)
        row = nil
      end
      row
    end

    s = s.transform 'get student group from grade breakdown', WithBlock do |row|
      grade_breakdown = row[:grade_breakdown].to_s
      row[:student_group] = /grade(.*)(?=proficiency)/.match(grade_breakdown)[1]
      row
    end

    s = s.transform 'rename grade and subject column', MultiFieldRenamer, {
      :test_grade => :grade,
      :test_subject => :subject,
    }

    s = s.transform 'get numeric grade', WithBlock do |row|
      row[:grade] = /(\d+)/.match(row[:grade])[1]
      row
    end

    s = s.transform 'fill \'state\' into district, entity level, and school id', Fill,
    {
      district_id: 'state', state_id: 'state',
      entity_level: 'state', district_name: 'state',
      school_id: 'state', school_name: 'state'
    }

    s = s.transform 'select columns', ColumnSelector, :grade_breakdown, :value_float, :grade, :subject, :district_id, :state_id,
      :entity_level, :student_group, :district_name, :school_id, :school_name

  end

  def draw
    require 'graph'
    g = Graph.new
    steps = [
      # state_files,
      district_files,
      school_files
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


raise ArgumentError.new('****Requires directory holding prepped files as command line argument****')  unless ARGV[0]

OHTestProcessor.new(ARGV[0], max: (ARGV[1] && ARGV[1].to_i) ).build_graph.draw
OHTestProcessor.new(ARGV[0], max: (ARGV[1] && ARGV[1].to_i) ).run
