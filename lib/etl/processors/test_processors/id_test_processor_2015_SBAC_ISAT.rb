require_relative "../test_processor"

class IDTestProcessor2015SBACISAT < GS::ETL::TestProcessor

  def initialize(*args)
    super
    @year = 2015
  end


  key_map_bd = {
    'All Students' => 1,
    'Hispanic or Latino' => 6,
    'White' => 8,    
    'Economically Disadvantaged ' => 9,
    'Not Economically Disadvantaged' => 10,
    'Students without Disabilities' => 14,
    'Students with Disabilities ' => 13,
    'Male' => 12,
    'Female' => 11, 
    'Not LEP' => 16,
    'LEP' => 15,
    'Two Or More Races' => 21,
    'American Indian or Alaskan Native' => 4,
    'Homeless' => 95,
    'Black / African American' => 3,
    'Asian or Pacific Islander' => 22,
    'Migrant' => 19,
    'Native Hawaiian / Other Pacific Islander' => 112
  }

  key_map_sub = {
    'ELA' => 4,
    'Math' => 5,
    'Science' => 25
  }
  
  source("State_cal.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      entity_level: 'state'    
  })
  end
  source("District_cal.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      entity_level: 'district'
  })
  end
  source("School_cal.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      entity_level: 'school'
  })
  end

  shared do |s|
    s.transform("Renaming fields",
      MultiFieldRenamer,
      {
        proficient_and_advanced: :value_float
      })
    .transform("Skip empty value", DeleteRows, :breakdown, 'At-Risk', 'Not At-Risk')
    .transform('Fill missing default fields', Fill, {
      level_code: 'e,m,h',
      year: 2015,
      entity_type: 'public_charter',
      proficiency_band: 'null',
      proficiency_band_id: 'null'
    })
    .transform("Create data type", WithBlock,) do |row|
      if row[:subject] == 'Science'
          row[:test_data_type] = 'isat'
          row[:test_data_type_id] = '76'
      else
          row[:test_data_type] = 'sbac'
          row[:test_data_type_id] = '252'
      end
      row
    end
    .transform("Process grade", WithBlock,) do |row|    
      if  row[:grade] =~ /^all/i
        row[:grade] = "All"
      else
        row[:grade] = row[:grade].gsub!("Grade ", "")
      end
      row
    end
    .transform("Adding column breakdown_id from breadown",
      HashLookup, :breakdown, key_map_bd, to: :breakdown_id)
    .transform("Adding column subject_id from subject",
      HashLookup, :subject, key_map_sub, to: :subject_id)
    .transform("Creating StateID", WithBlock) do |row|
      if row[:entity_level] == 'state'
        row[:state_id] = 'state'
      elsif row[:entity_level] == 'district'
        row[:state_id] = row[:district_id].rjust(3,'0')
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
        source_id: 40,
        state: 'id',
        notes: 'DXT-1797: ID SBAC and ISAT 2015 test load.',
        url: 'keveritt@sde.idaho.gov',
        file: 'id/2015/output/id.2015.1.public.charter.[level].txt',
        level: nil,
        school_type: 'public,charter'
    }
  end
end

IDTestProcessor2015SBACISAT.new(ARGV[0], max: nil).run
