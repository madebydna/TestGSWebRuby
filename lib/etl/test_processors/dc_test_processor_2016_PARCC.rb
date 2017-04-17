require_relative "../test_processor"

class DCTestProcessor2016PARCC < GS::ETL::TestProcessor

  def initialize(*args)
    super
    @year = 2016
  end

  key_map_bd = {
    'All' => 1,
    'Male' => 12,
    'Female' => 11, 
    'American Indian/Alaskan Native' => 4,
    'Asian' => 2,
    'Black/African American' => 3,
    'Hispanic/Latino' => 6,
    'Multiracial' => 21,
    'Pacific Islander/Native Hawaiian' => 112,
    'White/Caucasian' => 8,
    'Economically Disadvantaged' => 9,
    'English Language Learner' => 15,
    'Special Education' => 13
  }

  key_map_sub = {
    'ELA' => 4,
    'Math' => 5,
    'ELA I' => 19,
    'ELA II' => 27,
    'Algebra I' => 7,
    'Algebra II' => 11,
    'Geometry' => 9,
    'Integrated Math II' => 10 
  }

  key_map_pro = {
    :"level_1" => 115,
    :"level_2" => 116,
    :"level_3" => 117,
    :"level_4" => 118,
    :"level_5" => 119,
    :"level_4_and_5" => 'null',
  }

  source("state.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      entity_level: 'state',
      })
  end
  source("district.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      entity_level: 'district',
      })
  end
  source("school.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      entity_level: 'school',
      })
  end

  shared do |s|
    s.transform("Renaming fields",
      MultiFieldRenamer,
      {
        subgroup_value: :breakdown,
        total_valid_test_takers: :number_tested,
        total_valid_tests: :number_tested,
        lea_code: :district_id,
        lea_name: :district_name,
        school_code: :school_id
      })
    .transform("delete old year data",DeleteRows, :school_year, '2014-15')
    .transform("delete rows for sectors",DeleteRows, :sector, 'Charter', 'DCPS', 'DYRS')
    .transform("delete rows for subject all",DeleteRows, :tested_grade_subject, 'All')
    .transform("delete rows for repeating grade",DeleteRows, :grade_of_enrollment, 'Grade 7','Grade 8','Grade 9','Grade 10','Grade 11','Grade 12')
    .transform("delete rows for breakdown group",DeleteRows, :subgroup, 'Grade','Race by Gender')
    .transform("delete rows for at risk breakdown",DeleteRows, :breakdown, 'At Risk')
    .transform("delete rows where number tested is less than 25",DeleteRows, :number_tested, 'n<25')
    .transform("filter out repeating rows", WithBlock) do |row|
      if row[:tested_grade_subject] =~ /Grade/
        row[:grade] = row[:tested_grade_subject].gsub!("Grade ", "")
      else
        row[:subject] = row[:tested_grade_subject]
        row[:grade] = 'All'       
      end
      row
    end
    .transform('Fill missing default fields', Fill, {
      test_data_type: 'parcc',
      test_data_type_id: 248, 
      entity_type: 'public_charter',
      level_code: 'e,m,h',
      year: 2016
    })
    .transform('Transpose value columns', Transposer,
       :proficiency_band,
       :value_float,
       :"level_1",
       :"level_2",
       :"level_3",
       :"level_4",
       :"level_5",
       :"level_4_and_5"
       )
    .transform("Adding column breakdown_id from breadown",
      HashLookup, :breakdown, key_map_bd, to: :breakdown_id)
    .transform("Adding column subject_id from subject",
      HashLookup, :subject, key_map_sub, to: :subject_id)
    .transform("Adding column _id from proficiency band",
      HashLookup, :proficiency_band, key_map_pro, to: :proficiency_band_id)
    .transform("Remove special character in value_float", WithBlock) do |row|
      row[:value_float] = row[:value_float].gsub('%', '')
      row
    end
    .transform("Creating StateID", WithBlock) do |row|
      if row[:entity_level]=='school' 
          row[:state_id] = row[:school_id]
      elsif row[:entity_level]=='district'
          row[:state_id] = row[:district_id].rjust(3,'0')
      end
      row
    end
    .transform('Fill missing ids and names with entity_level', WithBlock) do |row|
      [:state_id, :school_id, :district_id, :school_name, :district_name].each do |col|
        row[col] ||= row[:entity_level]
      end
      row
    end
  end

  def config_hash
    {
        source_id: 76,
        state: 'dc',
        notes: 'DXT-1869: DC, PARCC',
        url: 'http://osse.dc.gov/page/2015-16-parcc-results-and-resources',
        file: 'dc/2016/output/dc.2016.1.public.charter.[level].txt',
        level: nil,
        school_type: 'public,charter'
    }
  end
end

DCTestProcessor2016PARCC.new(ARGV[0], max: nil).run