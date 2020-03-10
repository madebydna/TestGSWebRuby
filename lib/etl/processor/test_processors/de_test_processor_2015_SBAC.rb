require_relative "../test_processor"

class DETestProcessor2015SBAC < GS::ETL::TestProcessor

  def initialize(*args)
    super
    @year = 2015
  end


  key_map_bd = {
    'All' => 1,
    'African American' => 3,
    'ELL' => 15,
    'Female' => 11,
    'Hispanic' => 6,
    'Homeless' => 95,
    'Male' => 12,
    'Students with Disability' => 13,
    'White' => 8
  }

  key_map_sb = {
    'Math' => 5,
    'ELA' => 4
  }

  
  source("2015TargetFilesMathProficientOnly.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      proficiency_band: 'proficient',
      proficiency_band_id: '16',
    })
  end
  source("2015TargetFilesMathAdvancedOnly.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      proficiency_band: 'advanced',
      proficiency_band_id: '17',
    })
  end
  source("2015TargetFilesMathProficiency_clean.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      proficiency_band: 'null',
      proficiency_band_id: 'null',
    })
  end
  source("2015TargetFilesReadingProficientOnly.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      proficiency_band: 'proficient',
      proficiency_band_id: '16',
    })
  end
  source("2015TargetFilesReadingAdvancedOnly.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      proficiency_band: 'advanced',
      proficiency_band_id: '17',
    })
  end
  source("2015TargetFilesReadingProficiency_clean.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      proficiency_band: 'null',
      proficiency_band_id: 'null',
    })
  end
  source("2015TargetFilesReadingProficientOnlyBySubGroup.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      proficiency_band: 'proficient',
      proficiency_band_id: '16',
    })
  end
  source("2015TargetFilesMathProficientOnlyBySubGroup.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      proficiency_band: 'proficient',
      proficiency_band_id: '16',
    })
  end
  source("2015TargetFilesMathAdvancedBySubGroup.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      proficiency_band: 'advanced',
      proficiency_band_id: '17',
    })
  end
  source("2015TargetFilesReadingAdvancedBySubGroup.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      proficiency_band: 'advanced',
      proficiency_band_id: '17',
    })
  end
  source("2015TargetFilesMathProficiencyBySubGroup_clean.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      proficiency_band: 'null',
      proficiency_band_id: 'null',
    })
  end
  source("2015TargetFilesReadingProficiencyBySubGroup_clean.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      proficiency_band: 'null',
      proficiency_band_id: 'null',
    })
  end


  shared do |s|
    s.transform("Renaming fields",
      MultiFieldRenamer,
      {
        schoolyear: :year,
        entitytype: :entity_level,
        districtstateid: :district_id,
        districtname: :district_name,
        schoolstateid: :school_id,
        schoolname: :school_name,
        gradelevel: :grade,
        totalstudents: :number_tested,
        metricvalue: :value_float
      })
    .transform('Fill missing default fields', Fill, {
      entity_type: 'public_charter',
      level_code: 'e,m,h',
      test_data_type: 'sbac',
      test_data_type_id: 306,
    })
    .transform("Skip data for Other Minorities breakdown",
      DeleteRows, :breakdown, 'Other Minorities')
    .transform("Adding column breakdown_id from breadown",
      HashLookup, :breakdown, key_map_bd, to: :breakdown_id)
    .transform("Adding column subject_id from subject",
      HashLookup, :subject, key_map_sb, to: :subject_id)
    .transform("Lowercase column",WithBlock) do |row|
       row[:entity_level].downcase!
       row[:subject].downcase!
       row[:breakdown].downcase!
       row
    end
    .transform("Creating StateID", WithBlock) do |row|
      if row[:entity_level] == 'state'
        row[:state_id] = 'state'
      elsif row[:entity_level] == 'school'
        row[:state_id] = row[:school_id]
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
        source_id: 53,
        state: 'de',
        notes: 'DXT-1613: DE SBAC 2015 test load.',
        url: 'http://www.doe.k12.de.us/',
        file: 'de/2015/output/de.2015.1.public.charter.[level].txt',
        level: nil,
        school_type: 'public,charter'
    }
  end
end

DETestProcessor2015SBAC.new(ARGV[0], max: nil).run
