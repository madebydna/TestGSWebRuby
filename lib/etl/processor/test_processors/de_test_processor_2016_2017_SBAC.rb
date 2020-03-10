require_relative "../test_processor"

class DETestProcessor20162017SBAC < GS::ETL::TestProcessor

  def initialize(*args)
    super
    @year = 2017
  end

  breakdown_id_map = {
    'All Students' => 1,
    'Female' => 26,
    'Male' => 25,
    'Hispanic' => 19,
    'American Indian' => 18,
    'African American' => 17,
    'White' => 21,
    'Asian American' => 16,
    'Hawaiian/Pacific Islander' => 20,
    'Multiracial' => 22,
    'Students with Disability' => 27,
    'Low-Income' => 23,
    'ELL' => 32

  }

  subject_id_map = {
    'MATH' => 5,
    'ELA' => 4
  }
  
  proficiency_band_id_map = {
    :"percent_level_1" => 5,
    :"percent_level_2" => 6,
    :"percent_level_3" => 7,
    :"percent_level_4" => 8,
    :"proficient_above" => 1
  }

  source("2016_2017_Delaware_Assessment_Results.txt",[], col_sep: "\t")

  shared do |s|
    s.transform("Renaming fields",
      MultiFieldRenamer,
      {
        lea_code: :district_id,
        lea_name: :district_name,
        school_code: :school_id,
        tested_grade: :grade,
        subgroup_value: :breakdown
      })
    .transform('Fill missing default fields', Fill, {
      test_data_type: 'SBAC',
      test_data_type_id: 234,
      notes: 'DXT-2438: DE SBAC'
    })
    .transform('skip suppressed value',DeleteRows,:number_tested, 'n<15')      
    .transform("Calculate proficient above", WithBlock) do |row|
      row[:proficient_above] = (row[:percent_level_3].to_f + row[:percent_level_4].to_f).round(2)
      row[:proficient_above]=100 if row[:proficient_above] > 100
      row
    end 
    .transform('Transpose value columns', Transposer,
       :proficiency_band,
       :value,
       :"percent_level_1",
       :"percent_level_2",
       :"percent_level_3",
       :"percent_level_4",
       :"proficient_above"
    )
    .transform('Map subject_id',HashLookup, :subject, subject_id_map, to: :subject_id)               
    .transform('Map breakdown_id',HashLookup, :breakdown, breakdown_id_map, to: :breakdown_id) 
    .transform('Map proficiency_band_id',HashLookup, :proficiency_band, proficiency_band_id_map, to: :proficiency_band_id) 
    .transform("Assign description", WithBlock) do |row|
      if row[:year] == '2016'
        row[:date_valid] = '2016-01-01 00:00:00'
        row[:description] = 'The Smarter Balanced assessments are designed to measure the progress of Delaware students in ELA/Literacy and Mathematics standards in grades 3-8. The administration of the Smarter assessments in grades 3-8, and 11 occurred during spring 2016'
      else
        row[:date_valid] = '2017-01-01 00:00:00'
        row[:description] = 'The Smarter Balanced assessments are designed to measure the progress of Delaware students in ELA/Literacy and Mathematics standards in grades 3-8. The administration of the Smarter assessments in grades 3-8, and 11 occurred during spring 2017'        
      end
      row
    end 
    .transform("Creating StateID", WithBlock) do |row|
      if row[:district_id]=="95"
        row[:entity_type] = 'state'
        row[:state_id] = 'state'
      elsif row[:school_id] == "0"
        row[:entity_type] = 'district'
        row[:state_id] = row[:district_id]
      else
        row[:entity_type] = 'school'
        row[:state_id] = row[:school_id]
      end
      row
    end
  end


  def config_hash
    {
        source_id: 11,
        state: 'de'
    }
  end
end

DETestProcessor20162017SBAC.new(ARGV[0], max: nil).run
