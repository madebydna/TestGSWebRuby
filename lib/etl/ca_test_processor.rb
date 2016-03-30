$LOAD_PATH.unshift File.dirname(__FILE__)
require 'etl'
require 'test_processor'
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
require 'ca_gs_breakdown_definitions'
require 'gs_breakdowns_from_db'
require 'transforms/column_selector'
require 'transforms/keep_rows'
require 'transforms/value_concatenator'
require 'transforms/unique_values'
require 'transforms/delete_rows'

class CATestProcessor < GS::ETL::TestProcessor

  attr_reader :runnable_steps, :attachable_input_step, :attachable_output_step
  def initialize(*source_files)
    @reading_math_source_file = source_files.first
    @science_source_file = source_files.last
    @year = '2015'
    @runnable_steps = []
  end

  def config_hash
    {
      source_id: 7,
      state: 'ca',
      notes: 'Year 2016 CA TEST',
      url: 'http://caaspp.cde.ca.gov/sb2015/ResearchFileList',
      file: 'ca/2015/output/ca.2015.1.public.charter.[level].txt',
      level: nil,
      school_type: 'public,charter'
    }
  end

  def source_steps
    [science_source, reading_math_source]
  end

  def science_source
    @_science_source ||= (
      science_csv = CsvSource.new(@science_source_file)
      science_csv.event_log = self.event_log
      science_csv
    )
  end

  def reading_math_source
    @_reading_math_source ||=(
    reading_math_csv = CsvSource.new(@reading_math_source_file)
    reading_math_csv.event_log = self.event_log
    reading_math_csv
    )
  end

  def reading_math_union_prep
    @_reading_math_prep ||=(
    s = reading_math_source
    s = s.transform ColumnSelector, :test_year, :state_id, :county_code, :district_code,
      :school_code, :subgroup_id, :test_type, :test_id, :grade, :students_tested,
      :percentage_standard_exceeded, :percentage_standard_met,
      :percentage_standard_nearly_met, :percentage_standard_not_met, :percentage_standard_met_and_above

    s = s.transform RowExploder,
      :proficiency_band,
      :proficiency_band_value,
      :percentage_standard_exceeded,
      :percentage_standard_met,
      :percentage_standard_nearly_met,
      :percentage_standard_not_met,
      :percentage_standard_met_and_above

    s = s.transform Fill,
      test_data_type: 'caasp',
      entity_type: 'public_charter',
      school_name: 'school_name',
      district_name: 'district_name',
      level_code: 'e,m,h'

    s = s.transform ColumnSelector, :test_year, :state_id, :county_code, :district_code,
      :school_code, :subgroup_id, :test_type, :test_id, :grade, :students_tested, :proficiency_band,
      :proficiency_band_value, :test_data_type, :entity_type, :school_name, :district_name, :level_code
    s
    )
  end

  def science_source_union_prep
    @_science_source_union_prep ||= (
    s = science_source.transform ColumnSelector, :test_year, :state_id, :county_code, :district_code,
      :school_code, :subgroup_id, :test_type, :test_id, :grade, :students_tested,
      :percentage_advanced, :percentage_basic, :percentage_below_basic, :percentage_far_below_basic,
      :percentage_proficient, :percentage_at_or_above_proficient

    s = s.transform KeepRows, :test_id, '32'

    s = s.transform(
      HashLookup,
      :test_id,
      {'32' => 'science' }
    )

    s = s.transform RowExploder,
      :proficiency_band,
      :proficiency_band_value,
      :percentage_advanced,
      :percentage_basic,
      :percentage_below_basic,
      :percentage_far_below_basic,
      :percentage_proficient,
      :percentage_at_or_above_proficient


    s  = s.transform Fill,
      test_data_type: 'cst',
      entity_type: 'public_charter',
      school_name: 'school_name',
      district_name: 'district_name',
      level_code: 'e,m,h'

    s = s.transform ColumnSelector, :test_year, :state_id, :county_code, :district_code,
      :school_code, :subgroup_id, :test_type, :test_id, :grade, :students_tested, :proficiency_band,
      :proficiency_band_value, :test_data_type, :entity_type, :school_name, :district_name, :level_code
    s
    )
  end

  def state_breakdown_to_gs_breakdown_ids
    CaGsBreakdownDefinitions.breakdown_lookup
  end

  def  state_breakdown_ids_to_state_breakdown_labels
    {
      '1' => "All Students: All Students",
      '3' => "Males: Gender",
      '4' => "Females: Gender",
      '6' => "Fluent-English Proficient and English Only: English-Language Fluency",
      '7' => "Initially-Fluent English Proficient (I-FEP): English-Language Fluency",
      '8' => "Reclassified-Fluent English Proficient (R-FEP): English-Language Fluency",
      '28' => "Migrant Education: Migrant",
      '31' => "Economically Disadvantaged: Economic Status",
      '74' => "Black or African American: Ethnicity",
      '75' => "American Indian or Alaska Native: Ethnicity",
      '76' => "Asian: Ethnicity",
      '77' => "Filipino: Ethnicity",
      '78' => "Hispanic or Latino: Ethnicity",
      '79' => "Native Hawaiian or Pacific Islander: Ethnicity",
      '80' => "White: Ethnicity",
      '90' => "Not a High School Graduate: Parent Education",
      '91' => "High School Graduate: Parent Education",
      '92' => "Some College (Includes AA Degree): Parent Education",
      '93' => "College Graduate: Parent Education",
      '94' => "Graduate School/Post Graduate: Parent Education",
      '99' => "Students with No Reported Disability: Disability Status",
      '111' => "Not Economically Disadvantaged: Economic Status",
      '120' => "English Learners Enrolled in School in the U.S. Less Than 12 Months: English-Language Fluency",
      '121' => "Parent Education -- Declined to State: Parent Education",
      '128' => "Students with Disability: Disability Status",
      '142' => "English Learners Enrolled in School in the U.S. 12 Months or More: English-Language Fluency",
      '144' => "Ethnicity -- Two or More Races: Ethnicity",
      '160' => "English Learner: English-Language Fluency",
      '180' => "English Only: English-Language Fluency",
      '200' => "Black or African American: Ethnicity for Economically Disadvantaged",
      '201' => "American Indian or Alaska Native: Ethnicity for Economically Disadvantaged",
      '202' => "Asian: Ethnicity for Economically Disadvantaged",
      '203' => "Filipino: Ethnicity for Economically Disadvantaged",
      '204' => "Hispanic or Latino: Ethnicity for Economically Disadvantaged",
      '205' => "Native Hawaiian or Pacific Islander: Ethnicity for Economically Disadvantaged",
      '206' => "White: Ethnicity for Economically Disadvantaged",
      '207' => "Ethnicity -- Two or More Races: Ethnicity for Economically Disadvantaged",
      '220' => "Black or African American: Ethnicity for Not Economically Disadvantaged",
      '221' => "American Indian or Alaska Native: Ethnicity for Not Economically Disadvantaged",
      '222' => "Asian: Ethnicity for Not Economically Disadvantaged",
      '223' => "Filipino: Ethnicity for Not Economically Disadvantaged",
      '224' => "Hispanic or Latino: Ethnicity for Not Economically Disadvantaged",
      '225' => "Native Hawaiian or Pacific Islander: Ethnicity for Not Economically Disadvantaged",
      '226' => "White: Ethnicity for Not Economically Disadvantaged",
      '227' => "Ethnicity -- Two or More Races: Ethnicity for Not Economically Disadvantaged"
    }
  end

  def build_graph
    return if @graph_built

    @runnable_steps = [
      science_source,
      reading_math_source
    ]

   combined_sources_step = union_steps(
      science_source_union_prep,
      reading_math_union_prep
    )

   s1 = combined_sources_step.transform ValueConcatenator, :state_id, :county_code,
     :district_code, :school_code

   s1 = s1.transform DeleteRows, :proficiency_band_value, '*', ''


    s1 = s1.transform WithBlock do |row|
      return nil if row[:students_tested].to_i < 10
      row
    end

    # Map proficiency band IDs
    s1 = s1.transform(
      HashLookup,
      :proficiency_band,
      {
        percentage_standard_exceeded: 25,
        percentage_standard_met: 24,
        percentage_standard_nearly_met: 23,
        percentage_standard_not_met: 22,
        percentage_standard_met_and_above: 'null',
        percentage_advanced: 77,
        percentage_basic: 75,
        percentage_below_basic: 74,
        percentage_far_below_basic: 73,
        percentage_proficient: 76,
        percentage_at_or_above_proficient: 'null'
      },
      to: :proficiency_band_id
    )

    s1 = s1.transform(
      HashLookup,
      :proficiency_band,
      {
        percentage_standard_exceeded: 'exceeding',
        percentage_standard_met: 'meeting',
        percentage_standard_nearly_met: 'partially_meeting',
        percentage_standard_not_met: 'not_meeting',
        percentage_standard_met_and_above: 'null',
        percentage_advanced: 'advanced',
        percentage_basic: 'basic',
        percentage_below_basic: 'below_basic',
        percentage_far_below_basic: 'far_below_basic',
        percentage_proficient: 'proficient',
        percentage_at_or_above_proficient: 'null' }
    )

    s1 = s1.transform(
      HashLookup,
      :test_data_type,
      {
        'caasp' => 236,
        'cst' => 18
      },
      to: :test_data_type_id
    )

    s1 = s1.transform(
      HashLookup,
      :test_data_type,
      {
        'caasp' => 236,
        'cst' => 18
      },
      to: :data_type_id
    )

    s1 = s1.transform(
      HashLookup,
      :state_id,
      {
        "01100176002000" => "6002000",
        "01611190132878" => "0132142",
        "01612000107839" => "0107839",
        "07100740731380" => "0731380",
        "07616487098304" => "7098304",
        "12768026007868" => "6007868",
        "12768026007876" => "6007876",
        "12768026008130" => "6008130",
        "12768026008148" => "6008148",
        "18641626010763" => "6010763",
        "19101990109926" => "0109926",
        "19645507084353" => "7084353",
        "19647336900278" => "6900278",
        "19647336934152" => "6934152",
        "19647336934715" => "6934715",
        "19647336935084" => "6935084",
        "19647337022510" => "7022510",
        "19650940125393" => "0125393",
        "19753090130898" => "0130898",
        "19753090130914" => "0130914",
        "19753090130922" => "0130922",
        "19753090130955" => "0130955",
        "19768690119016" => "0119016",
        "19768690119636" => "0119636",
        "19768690128728" => "0128728",
        "19768696023808" => "6023808",
        "19768696023816" => "6023816",
        "19768696023832" => "6023832",
        "20756066114862" => "0132936",
        "21102157005101" => "7005101",
        "29768776027171" => "6027171",
        "29768776110746" => "6110746",
        "30768930130765" => "0130765",
        "31668030129080" => "0116574",
        "34674397086846" => "7086846",
        "36679180126847" => "0126847",
        "37681630124271" => "0124271",
        "37681630130815" => "0130815",
        "37683387050925" => "7050925",
        "37768510110122" => "0110122",
        "37768516037543" => "6037543",
        "37768516108567" => "6108567",
        "37768516113468" => "6113468",
        "39685853930377" => "0132837",
        "49104967019268" => "7019268",
        "49708470119750" => "0119750",
        "50710436909774" => "6909774",
        "50711750120212" => "0120212",
        "50712906909774" => "6909774",
        "52105206119671" => "6119671",
        "52714726053599" => "6053599",
        "52715226053474" => "6053474",
        "54767945436258" => "5436258",
        "54767945436282" => "5436282",
        "54767946054761" => "6054761",
        "54767946108286" => "6108286",
        "54768365431598" => "5431598",
        "54768365431614" => "5431614",
        "54768366054043" => "6054043",
        "54768366054050" => "6054050",
        "54768366110290" => "6110290",
        "19768850130799" => "0118158" },
        to: :school_code
    )

    s1 = s1.transform(
    HashLookup,
    :state_id,
    {
      "01100176002000" => "01612596002000",
      "01611190132878" => "01611190132142",
      "01612000107839" => "01763720107839",
      "07100740731380" => "07617540731380",
      "07616487098304" => "07616557098304",
      "12768026007868" => "12628026007868",
      "12768026007876" => "12628026007876",
      "12768026008130" => "12630166008130",
      "12768026008148" => "12630166008148",
      "18641626010763" => "18767296010763",
      "19101990109926" => "19769680109926",
      "19645507084353" => "19757137084353",
      "19647336900278" => "19645686900278",
      "19647336934152" => "19650296934152",
      "19647336934715" => "19644446934715",
      "19647336935084" => "19757136935084",
      "19647337022510" => "19646347022510",
      "19650940125393" => "19253930125393",
      "19753090130898" => "19308980130898",
      "19753090130914" => "19309140130914",
      "19753090130922" => "19309220130922",
      "19753090130955" => "19309550130955",
      "19768690119016" => "19651690119016",
      "19768690119636" => "19651690119636",
      "19768690128728" => "19651690128728",
      "19768696023808" => "19651696023808",
      "19768696023816" => "19651696023816",
      "19768696023832" => "19651696023832",
      "20756066114862" => "20756060132936",
      "21102157005101" => "21653187005101",
      "29768776027171" => "29663816027171",
      "29768776110746" => "29663816110746",
      "30768930130765" => "30307650130765",
      "31668030129080" => "31668030116574",
      "34674397086846" => "34673147086846",
      "36679180126847" => "36679340126847",
      "37681630124271" => "37681710124271",
      "37681630130815" => "37308150130815",
      "37683387050925" => "37683467050925",
      "37768510110122" => "37679750110122",
      "37768516037543" => "37679756037543",
      "37768516108567" => "37679756108567",
      "37768516113468" => "37679756113468",
      "39685853930377" => "39685850132837",
      "49104967019268" => "49709207019268",
      "49708470119750" => "49766040119750",
      "50710436909774" => "50711676909774",
      "50711750120212" => "50766380120212",
      "50712906909774" => "50711676909774",
      "52105206119671" => "52716056119671",
      "52714726053599" => "52715896053599",
      "52715226053474" => "52714806053474",
      "54767945436258" => "54722805436258",
      "54767945436282" => "54722805436282",
      "54767946054761" => "54722726054761",
      "54767946108286" => "54722726108286",
      "54768365431598" => "54719285431598",
      "54768365431614" => "54719285431614",
      "54768366054043" => "54719106054043",
      "54768366054050" => "54719106054050",
      "54768366110290" => "54719106110290",
      "19768850130799" => "19647330118158" }
    )

    s1 = s1.transform MultiFieldRenamer, {
      # district_code: :district_id,
      school_code: :school_id,
      test_year: :year,
      test_id: :subject,
      subgroup_id: :state_breakdown_id,
      students_tested: :number_tested
    }

    s1 = s1.transform ValueConcatenator, :district_id,
      :county_code,
      :district_code

    s1 = s1.transform( 
      HashLookup,
      :state_id,
      {
        "01612596002000" => "0161259",
        "01611190132142" => "0161119",
        "01763720107839" => "0176372",
        "07617540731380" => "0761754",
        "07616557098304" => "0761655",
        "12628026007868" => "1262802",
        "12628026007876" => "1262802",
        "12630166008130" => "1263016",
        "12630166008148" => "1263016",
        "18767296010763" => "1876729",
        "19769680109926" => "1976968",
        "19757137084353" => "1975713",
        "19645686900278" => "1964568",
        "19650296934152" => "1965029",
        "19644446934715" => "1964444",
        "19757136935084" => "1975713",
        "19646347022510" => "1964634",
        "19253930125393" => "1925393",
        "19308980130898" => "1930898",
        "19309140130914" => "1930914",
        "19309220130922" => "1930922",
        "19309550130955" => "1930955",
        "19651690119016" => "1965169",
        "19651690119636" => "1965169",
        "19651690128728" => "1965169",
        "19651696023808" => "1965169",
        "19651696023816" => "1965169",
        "19651696023832" => "1965169",
        "20756060132936" => "2075606",
        "21653187005101" => "2165318",
        "29663816027171" => "2966381",
        "29663816110746" => "2966381",
        "30307650130765" => "3030765",
        "31668030116574" => "3166803",
        "34673147086846" => "3467314",
        "36679340126847" => "3667934",
        "37681710124271" => "3768171",
        "37308150130815" => "3730815",
        "37683467050925" => "3768346",
        "37679750110122" => "3767975",
        "37679756037543" => "3767975",
        "37679756108567" => "3767975",
        "37679756113468" => "3767975",
        "39685850132837" => "3968585",
        "49709207019268" => "4970920",
        "49766040119750" => "4976604",
        "50711676909774" => "5071167",
        "50766380120212" => "5076638",
        "50711676909774" => "5071167",
        "52716056119671" => "5271605",
        "52715896053599" => "5271589",
        "52714806053474" => "5271480",
        "54722805436258" => "5472280",
        "54722805436282" => "5472280",
        "54722726054761" => "5472272",
        "54722726108286" => "5472272",
        "54719285431598" => "5471928",
        "54719285431614" => "5471928",
        "54719106054043" => "5471910",
        "54719106054050" => "5471910",
        "54719106110290" => "5471910",
        "19647330118158" => "1964733"
      },
      to: :district_id
    )

    s1 = s1.transform TrimLeadingZeros, :grade

    s1 = s1.transform WithBlock do |row|
      row[:grade] = 'All' if row[:grade] == '13'
      row
    end

    s1 = s1.transform(
      HashLookup,
      :subject,
      {
        '2' => 5,
        '1' => 4,
        'science' => 25,
      },
      to: :subject_id
    )

    s1 = s1.transform(
      HashLookup,
      :state_breakdown_id,
      state_breakdown_to_gs_breakdown_ids,
      to: :breakdown_id,
      ignore: ['6','7','8','90','91','92','93','94','121','202','200','203',
               '205','206', '207','220','221','222','223','204','201','224',
               '225','226','227','180', '120','142']
    )

     s1 = s1.transform DeleteRows,
       :state_breakdown_id,
      *['6','7','8','90','91','92','93','94','121','202','200','203',
       '205','206', '207','220','221','222','223','204','201','224',
       '225','226','227','180', '120','142']
    
    s1 = s1.transform DeleteRows, :breakdown_id, ''

    s1 = s1.transform MultiFieldRenamer,
      { proficiency_band_value: :value_float,
        state_breakdown_id: :breakdown }

    s1 = s1.transform WithBlock do |row|
      CaEntityLevelParser.new(row).parse
    end

    last_before_split = s1.transform KeepRows, :entity_level, *['district','school','state']

    @config_node = last_before_split.destination LoadConfigFile, config_output_file, config_hash

    s1.add(output_files_step_tree)

    @graph_built = true
    # breakdown_labels_node.run
  end

  def run
    build_graph
    runnable_steps.each(&:run)
    @config_node.run
  end

end

file = '/Users/jwrobel/dev/derek_files/ca2015_all_csv_v2.txt'
file2 = '/Users/jwrobel/dev/derek_files/ca2015_all_csv_v2_SCI.txt'

# file = '/Users/jwrobel/dev/derek_files/ca2015_all_csv_v2_100000.txt'
# file2 = '/Users/jwrobel/dev/derek_files/ca2015_all_csv_v2_100000_sci.txt'
# file = '/Users/jwrobel/dev/derek_files/5838305_school_data_v2.txt'
# file2 = '/Users/jwrobel/dev/derek_files/5838305_school_data_SCI_v2.txt'

# file = '/Users/jwrobel/dev/compare_files_monday/two_schools_raw.txt'
# file2 = '/Users/jwrobel/dev/compare_files_monday/two_schools_raw_sci.txt'

# file2 = '/Users/jwrobel/dev/data/ca2015_all_csv_v2_SCI.txt'

CATestProcessor.new(file, file2).run

