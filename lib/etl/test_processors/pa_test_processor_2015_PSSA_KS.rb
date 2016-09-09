require_relative "../test_processor"

class PATestProcessor2014PSSA < GS::ETL::TestProcessor

  def initialize(*args)
    super
    @year = 2015
  end


  key_map_bd = {
    'All Students' => 1,
    'Male' => 12,
    'Female' => 11, 
    'Asian (not Hispanic)' => 2,
    'Black or African American (not Hispanic)' => 3,
    'American Indian / Alaskan Native (not Hispanic)' => 4,
    'Hispanic (any race)' => 6,
    'White (not Hispanic)' => 8,
    'Multi-Racial (not Hispanic)' => 21,
    'Native Hawaiian or other Pacific Islander (not Hispanic)' => 112,
    'Economically Disadvantaged' => 9,
    'IEP' => 13,
    'ELL Enrolled on or Before 4-11-14' => 15,
    'ELL' => 15
  }

  key_map_sub = {
    'English Language Arts' => 4,
    'Math' => 5,
    'Science' => 25,
    'Algebra I' => 7,
    'Biology' => 29,
    'Literature' => 19,
    'E' => 19,
    'M' => 7,
    'S' => 29,
  }

  key_map_pro = {
    :"below_basic" => 78,
    :"basic" => 79,
    :"proficient" => 80,
    :"advanced" => 81,
    :"null" => 'null' 
  }
  
  source("2015 School PSSA 3 through 8 8-19-2015.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      entity_level: 'school',
      test_data_type: 'pssa',
      test_data_type_id: 29
  })
  end
  source("2015 PSSA State Level Data.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      entity_level: 'state',
      test_data_type: 'pssa',
      test_data_type_id: 29
  })
  end
  source("2015 School Keystone 11 based on 8-10-2015.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      entity_level: 'school',
      test_data_type: 'keystone',
      test_data_type_id: 237,
      year: 2015
  })
  end
  source("2015 Keystone Exam State Level Data.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      entity_level: 'state',
      test_data_type: 'keystone',
      test_data_type_id: 237,
      year: 2015
  })
  end


  shared do |s|
    s.transform("Renaming fields",
      MultiFieldRenamer,
      {
        schoolyear: :year,
        entitytype: :entity_level,
        aun: :district_id,
        district: :district_name,
        school_id: :school_id,
        school: :school_name,
        group: :breakdown,
        number_scored: :number_tested,
        percent_advanced: :advanced,
        percent_proficient: :proficient,
        percent_basic: :basic,
        percent_below_basic: :below_basic
      })
    .transform("Skip empty value", DeleteRows, :below_basic, nil)
    .transform("Skip empty value", DeleteRows, :breakdown, 'Historically Underperforming', 'HU')
    .transform('Calculate the null proficiency band', SumValues, :null, :proficient, :advanced)
    .transform('Transpose value columns', Transposer,
       :proficiency_band,
       :value_float,
       :"advanced",
       :"proficient",
       :"basic",
       :"below_basic",
       :"null"
       )
    .transform('Fill missing default fields', Fill, {
      entity_type: 'public_charter',
      level_code: 'e,m,h',
    })
    .transform("Adding column breakdown_id from breadown",
      HashLookup, :breakdown, key_map_bd, to: :breakdown_id)
    .transform("Adding column subject_id from subject",
      HashLookup, :subject, key_map_sub, to: :subject_id)
    .transform("Adding column _id from proficiency band",
      HashLookup, :proficiency_band, key_map_pro, to: :proficiency_band_id)
    .transform("Creating StateID", WithBlock) do |row|
      if row[:entity_level] == 'school'
        if row[:school_id].length > 4
         row[:state_id] = row[:school_id]
        else
          row[:state_id] = row[:school_id].rjust(4,'0')
        end
      end
      row
    end
    .transform("Lowercase column",WithBlock) do |row|
       row[:subject].downcase!
       row[:breakdown].downcase!
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
        source_id: 11,
        state: 'pa',
        notes: 'DXT-1644: PA PSSA 2015 test load.',
        url: 'http://www.pde.state.pa.us/',
        file: 'pa/2015/output/pa.2015.1.public.charter.[level].txt',
        level: nil,
        school_type: 'public,charter'
    }
  end
end

PATestProcessor2014PSSA.new(ARGV[0], max: nil).run
