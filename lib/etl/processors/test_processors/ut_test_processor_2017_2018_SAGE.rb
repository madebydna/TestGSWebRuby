require_relative "../test_processor"

class UTTestProcessor2018SAGE < GS::ETL::TestProcessor

  def initialize(*args)
    super
    @year = 2018
  end

  breakdown_id_map = {
      "All Students" => 1,
      "African American" => 17,
      "American Indian" => 18,
      "Asian" => 16,
      "Caucasian" => 21,
      "Hispanic" => 19,
      "Multiple Races" => 22,
      "Pacific Islander" => 37,
      "Female" => 26,
      "Male" => 25,
      "Limited English Proficiency" => 32,
      "Economically Disadvantaged" => 23,
      "Students with Disabilities" => 27    
  }

  subject_id_map = {
    science_proficiency: 19,
    language_arts_proficient: 4,
    mathematics_proficiency: 5
  }

  source("ut_sage_2016_17_proficiency_041519.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      year: 2017,
      date_valid: '2017-01-01 00:00:00',
      description: 'In 2016-2017, students in UT took the SAGE assessment.SAGE is a system of assessments designed to measure student success and growth over the years. SAGE tests are based on the Utah Core Standards, a set of academic standards that raise our expectations for students and teachers.'

  })
  end
  source("ut_sage_2017_18_proficiency_041519.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      year: 2018,
      date_valid: '2018-01-01 00:00:00',
      description: 'In 2017-2018, students in UT took the SAGE assessment.SAGE is a system of assessments designed to measure student success and growth over the years. SAGE tests are based on the Utah Core Standards, a set of academic standards that raise our expectations for students and teachers.'
    })
  end

  shared do |s|
    s.transform('Rename column headers', MultiFieldRenamer,{
      school_number: :school_name,
      subgroup: :breakdown
    })
    .transform('Fill missing default fields', Fill, {
      test_data_type: 'SAGE',
      test_data_type_id: 196,
      proficiency_band_id: 1,
      proficiency_band: 'proficient and above',
      notes: 'DXT-3090: UT SAGE'
    })
    .transform('skip Mobile and All Demographic Values breakdowns',DeleteRows,:breakdown, 'Mobile', 'All Demographic Values')  
    .transform('Transpose value columns', Transposer,
       :subject,
       :value,
       :language_arts_proficient,
       :mathematics_proficiency,
       :science_proficiency
      )
    .transform("Skip invalid values", DeleteRows, :value, 'N<10', 'NA')
    .transform("Process range and inequalities", WithBlock) do |row|
      row[:value] = row[:value].gsub(' ','')
      unless row[:value] == "#{row[:value].to_f}" or row[:value] == '<=1' or row[:value] == '>=98'
        row[:value] = 'SKIP'
      end
      row
    end 
    .transform("Skip invalid values", DeleteRows, :value, 'SKIP')   
    .transform("Assign entity type", WithBlock) do |row|
      if row[:district_id] == 'State' && row[:school_id] == 'All Schools'
        row[:entity_type] = 'state'
      elsif row[:school_id] == 'All Schools'
        row[:entity_type] = 'district'
      else
        row[:entity_type] = 'school'
      end
      row
    end
    .transform('Map subject_id',HashLookup, :subject, subject_id_map, to: :subject_id)               
    .transform('Map breakdown_id',HashLookup, :breakdown, breakdown_id_map, to: :breakdown_id) 
    .transform('Set up state_id',WithBlock) do |row|
      if row[:entity_type] == 'school'
        row[:state_id] = row[:district_id] + row[:school_id]  
      elsif row[:entity_type] == 'district'
        row[:state_id] = row[:district_id]
      else
        row[:state_id] = 'state'
      end
      row
    end
  end

  def config_hash
    {
        source_id: 48,
        state: 'ut'
    }
  end
end

UTTestProcessor2018SAGE.new(ARGV[0], max: nil).run