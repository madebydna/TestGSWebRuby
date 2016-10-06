require_relative "../test_processor"

class MDTestProcessor2015PARCC_MSA_HSA < GS::ETL::TestProcessor

  def initialize(*args)
    super
    @year = 2015
  end


  key_map_bd = {
    'All Students' => 1,
    'All Races' => 1,
    'Hispanic/Latino' => 6,
    'Hispanic/Latino of any race' => 6,
    'American Ind/Alaskan' => 4,
    'American Indian or Alaska Native' => 4,
    'Black or African American' => 3,
    'African American' => 3,
    'Asian' => 2,    
    'Nat Hawaiian/Other PI' => 112,
    'Native Hawaiian or Other Pacific Islander' => 112,
    'White' => 8,    
    'Two or more races' => 21,
    'Migrant' => 19,
    'Title1' => 83,  
    'Title I' => 83,
    'FARMS' => 9,
    'Male' => 12,
    'Female' => 11, 
    'LEP' => 15,
    'Limited English Proficient' => 15,
    'Special Ed' => 13,
    'Special Ed.' => 13,
    'Special Education' => 13
  }

  key_map_sub = {
    'ela' => 4,
    'math' => 5,
    'Science' => 25,
    'Algebra 1' => 7,
    'Algebra 2' => 11,
    'Biology' => 29,
  }
  
  source("PARCC2015_cal.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      test_data_type: 'parcc',
      test_data_type_id: 309,      
      level_code: 'e,m,h',
      year: 2015
  })
  end
  source("MSA2015_cal.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      test_data_type: 'msa',
      level_code: 'e,m,h',
      test_data_type_id: 53
  })
  end
  source("HSA2015_cal.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      test_data_type: 'hsa',
      test_data_type_id: 54,
      level_code: 'h',
      grade: 'All'
  })
  end

  shared do |s|
    s.transform("Renaming fields",
      MultiFieldRenamer,
      {
        subgroup: :breakdown,
        number_scored: :number_tested,
        level45_pct: :value_float,
        null_pct: :value_float
      })
    .transform("Skip empty value", DeleteRows, :breakdown, 'ADA/504', 'Special Education - Exited','Redesignated Limited English Proficient', 'ADA')
    .transform('Fill missing default fields', Fill, {
      entity_type: 'public_charter',
      proficiency_band: 'null',
      proficiency_band_id: 'null'
    })
    .transform("Adding column breakdown_id from breadown",
      HashLookup, :breakdown, key_map_bd, to: :breakdown_id)
    .transform("Adding column subject_id from subject",
      HashLookup, :subject, key_map_sub, to: :subject_id)
    .transform("Creating StateID", WithBlock) do |row|
      if row[:school_id] == 'A' 
        if row[:district_id] == 'A' 
          row[:entity_level]='state'
        else
          row[:entity_level]='district'
          row[:state_id] = row[:district_id].rjust(2,'0')
        end
      else 
        row[:entity_level]='school'
        row[:state_id] = row[:district_id].rjust(2,'0')+row[:school_id].rjust(4,'0')
      end
      row
    end
    .transform("Lowercase/capitalize column",WithBlock) do |row|
       row[:subject].downcase!
       row[:breakdown].downcase!
       row[:grade].capitalize! 
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
        source_id: 26,
        state: 'md',
        notes: 'DXT-1688: MD PARCC, MSA and HSA 2015 test load.',
        url: 'http://reportcard.msde.maryland.gov',
        file: 'md/2015/output/md.2015.1.public.charter.[level].txt',
        level: nil,
        school_type: 'public,charter'
    }
  end
end

MDTestProcessor2015PARCC_MSA_HSA.new(ARGV[0], max: nil).run
