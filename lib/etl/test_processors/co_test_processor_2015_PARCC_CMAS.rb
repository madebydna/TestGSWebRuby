require_relative "../test_processor"

class COTestProcessor2015PARCCCMAS < GS::ETL::TestProcessor

  def initialize(*args)
    super
    @year = 2015
  end

  key_map_bd = {
    'Hispanic' => 6,  
    'White' => 8,   
    'Asian' => 2,    
    'Multiracial' => 21,  
    'American Indian' => 4,
    'Black' => 3,
    'Pacific Islander' => 7,
    'Male' => 12,
    'Female' => 11, 
    'Free/Reduced Lunch Eligible' => 9,
    'Non-Free/Reduced Lunch Eligible' => 10,
    'English Learner (Not English Proficient/Limited English Proficient)**' => 15,
    'Non-English Learner***' => 16
  }

  key_map_sub = {
    'ELA' => 4,
    'Math' => 5,
    'Algebra I     ' => 7,   
    'Algebra II    ' => 11,    
    'Geometry      ' => 9,
    'Integrated I  '  => 8,  
    'Integrated II ' => 10,
    'Integrated III' => 12,
  }
  
  source("ELA_Ethnicity.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      subject: 'ELA'
  })
  end
  source("ELA_FRL.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      subject: 'ELA'
  })
  end
  source("ELA_Gender.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      subject: 'ELA'
  })
  end
  source("ELA_LEP.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      subject: 'ELA'
  })
  end
  source("Math_Ethnicity.txt",[], col_sep: "\t") do |s|
    s.transform("Renaming fields",
      MultiFieldRenamer,
      {
        subject_area: :subject
    })
  end
  source("Math_FRL.txt",[], col_sep: "\t") do |s|
    s.transform("Renaming fields",
      MultiFieldRenamer,
      {
        subject_area: :subject
    })
  end
  source("Math_Gender.txt",[], col_sep: "\t") do |s|
    s.transform("Renaming fields",
      MultiFieldRenamer,
      {
        subject_area: :subject
    })
  end
  source("Math_LEP.txt",[], col_sep: "\t") do |s|
    s.transform("Renaming fields",
      MultiFieldRenamer,
      {
        subject_area: :subject
    })
  end
  shared do |s|
    s.transform("Renaming fields",
      MultiFieldRenamer,
      {
        district_number: :district_id,
        school_number: :school_id,
        group: :breakdown,
        valid_scores: :number_tested,
        level45_pct: :value_float,
        met_or_exceeded_expectations: :value_float
      })
    .transform('Fill missing default fields', Fill, {
      test_data_type: 'cmas',
      test_data_type_id: 287, 
      year: 2015,
      entity_type: 'public_charter',
      proficiency_band: 'null',
      proficiency_band_id: 'null',
      level_code: 'e,m,h'
    })
    .transform("Adding column breakdown_id from breadown",
      HashLookup, :breakdown, key_map_bd, to: :breakdown_id)
    .transform("Adding column subject_id from subject",
      HashLookup, :subject, key_map_sub, to: :subject_id)
    .transform("Creating StateID", WithBlock) do |row|
      if row[:school_id] == '0' 
        row[:entity_level]='district'
        row[:state_id] = row[:district_id].rjust(4,'0')
      else 
        row[:entity_level]='school'
        row[:state_id] = row[:school_id].rjust(4,'0')
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
        source_id: 5,
        state: 'co',
        notes: 'DXT-1780: CO, PARCC, CMAS Science and Social Studies, with subgroups',
        url: 'http://www.cde.state.co.us/',
        file: 'co/2015/output/co.2015.2.public.charter.[level].txt',
        level: nil,
        school_type: 'public,charter'
    }
  end
end

COTestProcessor2015PARCCCMAS.new(ARGV[0], max: nil).run