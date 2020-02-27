require_relative "../test_processor"

class AKTestProcessor2019PEAKSASA < GS::ETL::TestProcessor

  def initialize(*args)
    super
    @year = 2019
  end

  breakdown_id_map={
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

  subject_id_map={
    'Science' => 19,
    'English Language Arts' => 4,
    'Mathematics' => 5
  }

  proficiency_band_id_map={
    'prof_and_above' => 1
  }

  source("ak_2019.txt",[], col_sep: "\t")

  shared do |s|
    s.transform('Fill missing default fields', Fill, {
      date_valid: '2019-01-01 00:00:00'
    })
    .transform('Add test info', WithBlock) do |row|
      if row[:test_data_type] == 'PEAKS'
        row[:test_data_type_id] = 340
        row[:notes] = 'DXT-3395: AK PEAKS'
        row[:description] = 'The Performance Evaluation for Alaska\\’s Schools (PEAKS) is designed to measure a student\\’s understanding of the skills and concepts outlined in the Alaska English Language Arts (ELA) and Mathematics Standards. The Alaska English Language Arts and Mathematics Standards are specific rigorous expectations for growth in students\\’ skills across grades.The Alaska English language arts (ELA) standards demonstrate the expectation that students\\’ skills will build across grades in reading and analyzing a variety of complex texts, writing with clarity for different purposes, and presenting and evaluating ideas and evidence. The ELA standards are designed to help students develop a logical progression of fluency, analysis, and application, moving toward college and career readiness. The Alaska mathematics standards have the expectation that students\\’ skills will grow across grades in mathematics content as well as mathematical practices. The mathematics standards are designed to help students develop a logical progression of mathematical fluency, conceptual understanding, and real world application. In 2018-19, the PEAKS assessments are administered to students in grades 3-9.'
      elsif row[:test_data_type] == 'ASA'
        row[:test_data_type_id] = 341
        row[:notes] = 'DXT-3395: AK ASA'
        row[:description] = 'The Alaska Science Assessment are designed to measure a student\\’s understanding of the skills and concepts outlined in the Alaska Science Grade Level Expectations (GLEs). In 2018-19, the science assessment is administered to students in grades 4, 8, and 10.'
      end
      row
    end    
    .transform('Map subject_id',HashLookup, :subject, subject_id_map, to: :subject_id)               
    .transform('Map breakdown_id',HashLookup, :breakdown, breakdown_id_map, to: :breakdown_id) 
    .transform('Map prof_band_id',HashLookup, :proficiency_band, proficiency_band_id_map, to: :proficiency_band_id) 
  end

  def config_hash
    {
        source_id: 5,
        state: 'ak'
    }
  end
end

AKTestProcessor2019PEAKSASA.new(ARGV[0], max: nil).run