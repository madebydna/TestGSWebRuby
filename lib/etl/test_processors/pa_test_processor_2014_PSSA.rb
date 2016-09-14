require_relative "../test_processor"

class PATestProcessor2014PSSA < GS::ETL::TestProcessor

  def initialize(*args)
    super
    @year = 2014
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
    'ELL Enrolled on or Before 5-3-13' => 15
  }

  key_map_sub = {
    'Math' => 5,
    'Reading' => 2,
    'Writing' =>3,
    'Science' => 25
  }

  key_map_pro = {
    :"below_basic" => 78,
    :"basic" => 79,
    :"proficient" => 80,
    :"advanced" => 81,
    :"null" => 'null' 
  }
  
  source("2014 PSSA School level grades 3 through 8  8-16-2014.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      entity_level: 'school'
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
    .transform("Skip empty value",DeleteRows, :below_basic, nil)
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
      entity_type: 'public_charter_private',
      level_code: 'e,m,h',
      test_data_type: 'pssa',
      test_data_type_id: 29,

    })
    .transform("Adding column breakdown_id from breadown",
      HashLookup, :breakdown, key_map_bd, to: :breakdown_id)
    .transform("Adding column subject_id from subject",
      HashLookup, :subject, key_map_sub, to: :subject_id)
    .transform("Adding column _id from proficiency band",
      HashLookup, :proficiency_band, key_map_pro, to: :proficiency_band_id)
    .transform("Creating StateID", WithBlock) do |row|
      if row[:school_id].length > 4
        row[:state_id] = row[:school_id]
      else
        row[:state_id] = row[:school_id].rjust(4,'0')
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
        notes: 'DXT-1644: PA PSSA 2014 test load.',
        url: 'http://www.pde.state.pa.us/',
        file: 'pa/2014/output/pa.2014.1.public.charter.private.[level].txt',
        level: nil,
        school_type: 'public,charter,private'
    }
  end
end

PATestProcessor2014PSSA.new(ARGV[0], max: nil).run
