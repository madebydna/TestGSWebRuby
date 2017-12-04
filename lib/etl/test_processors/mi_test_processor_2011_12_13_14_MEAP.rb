require_relative "../test_processor"

class MITestProcessor20112014MEAP < GS::ETL::TestProcessor

  def initialize(*args)
    super
    @year = 2014
  end

  key_map_bd = {
    'All Students' => 1,
    'Asian' => 2,
    'Black, not of Hispanic origin' => 3,
    'American Indian or Alaska Native' => 4,
    'Hispanic' => 6,
    'White, not of Hispanic origin' => 8, 
    'Native Hawaiian or Other Pacific Islander' => 112,
    'Two or More Races' => 21,
    'Male' => 12,
    'Female' => 11, 
    'Economically Disadvantaged' => 9,
    'Not Economically Disadvantaged' => 10,
    'English Language Learners' => 15,
    'Not English Language Learners' => 16,
    'Students with Disabilities' => 13
}

  key_map_sub = {
    'Reading' => 2,
    'Writing' => 3, 
    'Mathematics' => 5,
    'Science' => 25,
    'Social Studies' => 24
  }

  key_map_pro = {
    :"level_1_proficient" => 222,
    :"level_2_proficient" => 221,
    :"level_3_proficient" => 220,
    :"level_4_proficient" => 219,
    :"null" => 'null' 
  }

  source("MEAP 2010-2011.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      year: 2011
  })
  end
  source("MEAP 2011-2012.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      year: 2012
  })
  end
  source("MEAP 2012-2013.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      year: 2013
  })
  end
  source("MEAP 2013-2014.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      year: 2014
  })
  end

  shared do |s|
    s.transform("Renaming fields",
      MultiFieldRenamer,
      {
        districtcode: :district_id,
        districtname: :district_name,
        buildingcode: :school_id,
        buildingname: :school_name,
        subject_name: :subject,
        subgroup: :breakdown,
        percent_proficient: :null,
        entitytype: :entity_level
      })
    .transform("Skip empty value", DeleteRows, :entity_level, 'ISD')
    .transform("Skip empty value", DeleteRows, :number_tested, '< 10')
    .transform('Transpose value columns', Transposer,
       :proficiency_band,
       :value_float,
       :"level_1_proficient",
       :"level_2_proficient",
       :"level_3_proficient",
       :"level_4_proficient",
       :"null"
       )
    .transform('Fill missing default fields', Fill, {
      entity_type: 'public_charter',
      level_code: 'e,m,h',
      test_data_type: 'meap',
      test_data_type_id: 195   
    })
    .transform("Remove quotation mark",WithBlock) do |row|
       row[:breakdown] = row[:breakdown].gsub('"','')
       row
    end  
    .transform("Adding column breakdown_id from breadown",
      HashLookup, :breakdown, key_map_bd, to: :breakdown_id)
    .transform("Adding column subject_id from subject",
      HashLookup, :subject, key_map_sub, to: :subject_id)
    .transform("Adding column _id from proficiency band",
      HashLookup, :proficiency_band, key_map_pro, to: :proficiency_band_id)
    .transform("Lowercase/capitalize column",WithBlock) do |row|
       row[:subject].downcase!
       row[:breakdown].downcase!
       row[:entity_level].downcase!
       row
    end      
    .transform("Creating StateID", WithBlock) do |row|
      if row[:district_id] =~ /^[0-9]/
        if row[:school_id] =~ /^[0-9]/
          row[:entity_level] = 'school'
          row[:state_id] = row[:school_id].rjust(5,'0')
        else
          row[:entity_level] = 'district'
          row[:state_id] = row[:district_id].rjust(5,'0')
        end
      else
        row[:entity] = 'state'
        row[:state_id] = 'state'
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
        source_id: 9,
        state: 'mi',
        notes: 'DXT-1539: MI MEAP 2011-2014 test load.',
        url: 'https://www.mischooldata.org/DistrictSchoolProfiles/AssessmentResults/AssessmentResultsNew/AssessmentGradesMeap.aspx',
        file: 'mi/DXT-1539/output/mi.2014.1.public.charter.[level].txt',
        level: nil,
        school_type: 'public,charter'
    }
  end
end

MITestProcessor20112014MEAP.new(ARGV[0], max: nil).run
