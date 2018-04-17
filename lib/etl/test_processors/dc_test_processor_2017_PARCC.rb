require_relative "../test_processor"

class DCTestProcessor2017PARCC < GS::ETL::TestProcessor

  def initialize(*args)
    super
    @year = 2017
  end

  key_map_bd = {
    'All' => 1,
    'Male' => 12,
    'Female' => 11, 
    'American Indian/Alaskan Native' => 4,
    'Asian' => 2,
    'Black/African American' => 3,
    'Hispanic/Latino' => 6,
    'Two or More Races' => 21,
    'Pacific Islander/Native Hawaiian' => 112,
    'White/Caucasian' => 8,
    'Economically Disadvantaged' => 9,
    'Active or Monitored English Learner' => 15,
    'Active or Monitored Special Education' => 13
  }

    key_map_gsdata_bd = {
    'All' => 1,
    'Male' => 25,
    'Female' => 26, 
    'American Indian/Alaskan Native' => 18,
    'Asian' => 16,
    'Black/African American' => 17,
    'Hispanic/Latino' => 19,
    'Two or More Races' => 22,
    'Pacific Islander/Native Hawaiian' => 20,
    'White/Caucasian' => 21,
    'Economically Disadvantaged' => 23,
    'Active or Monitored English Learner' => 32,
    'Active or Monitored Special Education' => 27
  }

  key_map_sub = {
    'ELA' => 4,
    'Math' => 5,
    'English II' => 27,
    'Algebra I' => 7,
    'Algebra II' => 11,
    'Geometry' => 9,
    'Integrated Math II' => 10 
  }

    key_map_gsdata_sub = {
    'ELA' => 4,
    'Math' => 5,
    'English II' => 21,
    'Algebra I' => 6,
    'Algebra II' => 10,
    'Geometry' => 8,
    'Integrated Math II' => 9 
  }

  key_map_pro = {
    :percent_meeting_or_exceeding_expectations => 'null'
  }

  key_map_gsdata_pro = {
    :percent_meeting_or_exceeding_expectations => 1
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
        total_number_valid_test_takers: :number_tested,
        total_valid_tests: :number_tested,
        lea_code: :district_id,
        lea_name: :district_name,
        school_code: :school_id
      })
    .transform("delete rows for non PARCC",DeleteRows, :assessment_type, 'All','MSAA')
    .transform("delete rows for subject all",DeleteRows, :tested_grade_subject, 'All')
    .transform("delete rows for repeating grade",DeleteRows, :grade_of_enrollment, '7','8','9-12')
    .transform("delete rows for breakdown group",DeleteRows, :subgroup, 'Race by Gender')
    .transform("delete rows for at risk breakdown",DeleteRows, :breakdown, 'At-Risk','Subclaim 1','Subclaim 2','Subclaim 3','Subclaim 4','Subclaim 5')
    .transform("delete rows where number tested is less than 25",DeleteRows, :number_tested, 'n<25')
    .transform("filter out repeating rows", WithBlock) do |row|
      if row[:tested_grade_subject] !~ /\D/
        row[:grade] = row[:tested_grade_subject]
      else
        row[:subject] = row[:tested_grade_subject]
        row[:grade] = 'All'
      end
      row
    end
    .transform('Fill missing default fields', Fill, {
      test_data_type: 'parcc',
      test_data_type_id: 248,
      gsdata_test_data_type_id: 213, 
      entity_type: 'public_charter',
      level_code: 'e,m,h',
      year: 2017
    })
    .transform('Transpose value columns', Transposer,
       :proficiency_band,
       :value_float,
       :percent_meeting_or_exceeding_expectations
       )
    .transform("Adding column breakdown_id from breadown",
      HashLookup, :breakdown, key_map_bd, to: :breakdown_id)
    .transform("Adding column breakdown_gsdata_id from breadown",
      HashLookup, :breakdown, key_map_gsdata_bd, to: :breakdown_gsdata_id)
    .transform("Adding column subject_id from subject",
      HashLookup, :subject, key_map_sub, to: :subject_id)
    .transform("Adding column academic_gsdata_id from subject",
      HashLookup, :subject, key_map_gsdata_sub, to: :academic_gsdata_id)
    .transform("Adding column _id from proficiency band",
      HashLookup, :proficiency_band, key_map_pro, to: :proficiency_band_id)
    .transform("Adding column _id from proficiency band",
      HashLookup, :proficiency_band, key_map_gsdata_pro, to: :proficiency_band_gsdata_id)
    .transform("Remove special character in value_float", WithBlock) do |row|
      row[:value_float] = row[:value_float].gsub('%', '')
      row
    end
    .transform("Creating StateID", WithBlock) do |row|
      if row[:entity_level]=='school' 
          row[:state_id] = row[:school_id]
      elsif row[:entity_level]=='district'
          row[:district_id] = row[:district_id].rjust(3,'0')
          row[:state_id] = row[:district_id]
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
        source_name: 'Office of the State Superintendent of Education',
        description: 'In spring 2017, District of Columbia students took the Partnership for the Assessment of Readiness for College and Careers, or PARCC, assessments for the first time. The new assessment, which replaced the DC CAS annual assessment, is more rigorous and designed to measure students readiness for college and career.',
        date_valid: '2017-01-01 00:00:00',
        state: 'dc',
        notes: 'DXT-2567: DC PARCC',
        url: 'http://osse.dc.gov/page/2016-17-parcc-results-and-resources',
        file: 'dc/2017/output/dc.2017.1.public.charter.[level].txt',
        level: nil,
        school_type: 'public,charter'
    }
  end
end

DCTestProcessor2017PARCC.new(ARGV[0], max: nil).run