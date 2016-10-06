require_relative "../test_processor"

class AKTestProcessor2015AMPSBA < GS::ETL::TestProcessor

  def initialize(*args)
    super
    @year = 2015
  end


  key_map_bd = {
    'All Students' => 1,
    'Alaska Native/American Indian' => 4,
    'Economically Disadvantaged' => 9,
    'Not Economically Disadvantaged' => 10,
    'Male' => 12,
    'Female' => 11, 
    'Caucasian' => 8, 
    'Students With Disabilities' => 13,
    'Students Without Disabilities' => 14,
    'Limited English Proficient' => 15,
    'Not Limited English Proficient' => 16,
    'Migrant Students' => 19,
    'Not Migrant Students' => 28,
    'Two or More Races' => 21,
    'Asian/Pacific Islander' => 22,    
    'Hispanic' => 6,
    'African American' => 3,
    'Disabled With Accommodations' => 128
  }

  key_map_sub = {
    'ELA' => 4,
    'Math' => 5,
    'Science' => 25,
  }

  key_map_pro = {
    :"far_below_proficient" => 135,
    :"below_proficient" => 136,
    :"proficient" => 137,
    :"advanced" => 138,
    :"null" => 'null' 
  }

  source("SBA state.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      test_data_type: 'sba',
      test_data_type_id: 101,
      entity_level: 'state'      
  })
  end
  source("SBA district.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      test_data_type: 'sba',
      test_data_type_id: 101,
      entity_level: 'district'      
  })
  end
  source("SBA school.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      test_data_type: 'sba',
      test_data_type_id: 101,
      entity_level: 'school'    
  })
  end
  source("AMP state.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      test_data_type: 'amp',
      test_data_type_id: 310,
      entity_level: 'state'      
  })
  end
  source("AMP district.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      test_data_type: 'amp',
      test_data_type_id: 310,
      entity_level: 'district'      
  })
  end
  source("AMP school.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      test_data_type: 'amp',
      test_data_type_id: 310,
      entity_level: 'school'      
  })
  end

  shared do |s|
    s.transform("Renaming fields",
      MultiFieldRenamer,
      {
        district_n: :district_id,
        district: :district_name,
        school_n: :school_id,
        school: :school_name,
        subgroup: :breakdown,
        total_tested: :number_tested,
        far_below_proficient_level_1_percent: :far_below_proficient,
        below_proficient_level_2_percent: :below_proficient,
        proficient_level_3_percent: :proficient,
        advanced_proficient_level_4_percent: :advanced
      })
    .transform("Skip empty value", DeleteRows, :breakdown, 'Active Duty Parent/Guardian', 'Not Active Duty Parent/Guardian')
    .transform('Calculate the null proficiency band', SumValues, :null, :proficient, :advanced)
    .transform('Transpose value columns', Transposer,
       :proficiency_band,
       :value_float,
       :"advanced",
       :"proficient",
       :"below_proficient",
       :"far_below_proficient",
       :"null"
       )
    .transform('Fill missing default fields', Fill, {
      entity_type: 'public_charter',
      level_code: 'e,m,h',
      year: 2015
    })
    .transform("Adding column breakdown_id from breadown",
      HashLookup, :breakdown, key_map_bd, to: :breakdown_id)
    .transform("Adding column subject_id from subject",
      HashLookup, :subject, key_map_sub, to: :subject_id)
    .transform("Adding column _id from proficiency band",
      HashLookup, :proficiency_band, key_map_pro, to: :proficiency_band_id)
    .transform("Creating StateID", WithBlock) do |row|
      if row[:entity_level] == 'state'
        row[:state_id] = 'state'
      elsif row[:entity_level] =='district'
        row[:state_id] = row[:district_id].rjust(2,'0')
      elsif row[:entity_level] =='school'
        row[:state_id] = row[:school_id].rjust(6,'0')
      end
      row
    end
    .transform("Lowercase/capitalize column",WithBlock) do |row|
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
        source_id: 15,
        state: 'ak',
        notes: 'DXT-1584: AK AMP and SBA 2015 test load.',
        url: 'http://www.eed.state.ak.us/',
        file: 'ak/2015/output/ak.2015.1.public.charter.[level].txt',
        level: nil,
        school_type: 'public,charter'
    }
  end
end

AKTestProcessor2015AMPSBA.new(ARGV[0], max: nil).run
