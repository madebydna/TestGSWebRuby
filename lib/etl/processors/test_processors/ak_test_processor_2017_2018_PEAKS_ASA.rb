require_relative "../test_processor"

class AKTestProcessor20172018PEAKSASA < GS::ETL::TestProcessor

  def initialize(*args)
    super
    @year = 2018
  end

  breakdown_id_map = {
      "All Students" => 1,
      "African American" => 17,
      "Alaska Native/American Indian" => 18,
      "Asian/Pacific Islander" => 15,
      "Caucasian" => 21,
      "Hispanic" => 19,
      "Two or More Races" => 22,
      "Female" => 26,
      "Male" => 25,
      "English Learners" => 32,
      "Not English Learners" => 33,
      "Limited English Proficient" => 32,
      "Not Limited English Proficient" => 33,
      "Economically Disadvantaged" => 23,
      "Not Economically Disadvantaged" => 24,
      "Students With Disabilities" => 27,
      "Students Without Disabilities" => 30    
  }

  subject_id_map = {
    'Science' => 19,
    'ELA' => 4,
    'Math' => 5
  }

  source("ak_test_2016_17_proficiency_PEAKS_ASA.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      year: 2017,
      date_valid: '2017-01-01 00:00:00'
    })
  end

  source("ak_test_2017_18_proficiency_PEAKS_ASA.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      year: 2018,
      date_valid: '2018-01-01 00:00:00'
    })
  end

  shared do |s|
    s.transform('Add test info', WithBlock) do |row|
      if row[:subject] == "Math" || row[:subject] == "ELA"
        row[:test_data_type] = 'PEAKS',
        row[:test_data_type_id] = 340,
        row[:notes] = 'DXT-2719: AK PEAKS'

      elsif row[:subject] == "Science"
        row[:test_data_type] = 'ASA',
        row[:test_data_type_id] = 341,
        row[:notes] = 'DXT-2719: AK ASA'
      end
      row
    end    
    .transform('Fill missing default fields', Fill, {
      proficiency_band_id: 1,
      proficiency_band: 'proficient and above'
    })
    .transform('Rename column headers', MultiFieldRenamer,{
      entity_level: :entity_type,
      subgroup: :breakdown,
      percent_advanced_or_proficient: :value 
    })
    .transform('skip subgroups', DeleteRows, :breakdown, 'Disabled With Accommodations', 'Migrant Students', 'Not Migrant Students', 'Active Duty Parent/Guardian', 'Not Active Duty Parent/Guardian', 'Homeless', 'Not Homeless', 'Foster Care', 'Not Foster Care')  
    .transform('Set up n-tested',WithBlock) do |row|
      row[:count_advanced_or_proficient] = row[:count_advanced_or_proficient].gsub(',','')
      row[:count_below_proficient_or_far_below_proficient] = row[:count_below_proficient_or_far_below_proficient].gsub(',','')

      row[:number_tested] = row[:count_advanced_or_proficient].to_f + row[:count_below_proficient_or_far_below_proficient].to_f
      row
    end
    .transform("Process range and inequalities", WithBlock) do |row|
      if row[:number_tested].to_f < 10
        row[:value] = 'SKIP'
      end
      row
    end       
    .transform('Remove percent sign',WithBlock) do |row|
      row[:value] = row[:value].gsub('%','')
      row
    end
    .transform("Skip invalid values", DeleteRows, :value, 'SKIP')   
    .transform('Map subject_id',HashLookup, :subject, subject_id_map, to: :subject_id)               
    .transform('Map breakdown_id',HashLookup, :breakdown, breakdown_id_map, to: :breakdown_id) 
    .transform('Set up state_id',WithBlock) do |row|
      if row[:entity_type] == 'school'
        row[:state_id] = row[:school_id].to_s.rjust(6, "0")  
      elsif row[:entity_type] == 'district'
        row[:state_id] = row[:district_id].to_s.rjust(2, "0")
      else
        row[:state_id] = 'state'
      end
      row
    end
    .transform('Change all grades to all', WithBlock) do |row|
      if row[:grade] == 'All Grades'
        row[:grade] = 'All'
      end
      row
    end
    .transform('Add test details', WithBlock) do |row|
      if row[:year] == 2017
        if row[:test_data_type] == "PEAKS"
          row[:description] = 'The Performance Evaluation for Alaska\'s Schools (PEAKS) is designed to measure a student\'s understanding of the skills and concepts outlined in the Alaska English Language Arts (ELA) and Mathematics Standards. The Alaska English Language Arts and Mathematics Standards are specific rigorous expectations for growth in students\' skills across grades.The Alaska English language arts (ELA) standards demonstrate the expectation that students\' skills will build across grades in reading and analyzing a variety of complex texts, writing with clarity for different purposes, and presenting and evaluating ideas and evidence. The ELA standards are designed to help students develop a logical progression of fluency, analysis, and application, moving toward college and career readiness. The Alaska mathematics standards have the expectation that students\' skills will grow across grades in mathematics content as well as mathematical practices. The mathematics standards are designed to help students develop a logical progression of mathematical fluency, conceptual understanding, and real world application. In 2016-17, the PEAKS assessments are administered to students in grades 3-10.'
        else
          row[:description] = 'The Alaska Science Assessment are designed to measure a student\'s understanding of the skills and concepts outlined in the Alaska Science Grade Level Expectations (GLEs). In 2016-17, the science assessment is administered to students in grades 4, 8, and 10.'
        end
      elsif row[:year] == 2018
        if row[:test_data_type] == "PEAKS"
          row[:description] = 'The Performance Evaluation for Alaska\'s Schools (PEAKS) is designed to measure a student\'s understanding of the skills and concepts outlined in the Alaska English Language Arts (ELA) and Mathematics Standards. The Alaska English Language Arts and Mathematics Standards are specific rigorous expectations for growth in students\' skills across grades.The Alaska English language arts (ELA) standards demonstrate the expectation that students\' skills will build across grades in reading and analyzing a variety of complex texts, writing with clarity for different purposes, and presenting and evaluating ideas and evidence. The ELA standards are designed to help students develop a logical progression of fluency, analysis, and application, moving toward college and career readiness. The Alaska mathematics standards have the expectation that students\' skills will grow across grades in mathematics content as well as mathematical practices. The mathematics standards are designed to help students develop a logical progression of mathematical fluency, conceptual understanding, and real world application. In 2017-18, the PEAKS assessments are administered to students in grades 3-9.'
        else
          row[:description] = 'The Alaska Science Assessment are designed to measure a student\'s understanding of the skills and concepts outlined in the Alaska Science Grade Level Expectations (GLEs). In 2017-18, the science assessment is administered to students in grades 4, 8, and 10.'
        end
      end
      row
    end 
  end

  def config_hash
    {
        source_id: 5,
        state: 'ak'
    }
  end
end

AKTestProcessor20172018PEAKSASA.new(ARGV[0], max: nil).run