require_relative "../../test_processor"

class NJTestProcessor20182019PARCCNJSLA < GS::ETL::TestProcessor

  def initialize(*args)
    super
    @year = 2019
    @ticket_n = 'DXT-3426'
  end

  breakdown_id_map = {
      "All Students" => 1,
      "African American" => 17,
      "American Indian" => 18,
      "Asian" => 16,
      "White" => 21,
      "Hispanic" => 19,
      "Female" => 26,
      "Male" => 25,
      "English Language Learners" => 32,
      "Native Hawaiian" => 41,
      "Economically Disadvantaged" => 23,
      "Non-Econ. Disadvantaged" => 24,
      "Students With Disabilities" => 27,

  }

  subject_id_map = {
    
    "Algebra I" => 6,
    "ELA" => 4,
    "Geometry" => 8,
    "Math" => 5,
    "Algebra II" => 10
  }

  proficiency_band_id_map = {
    
    "prof_above" => 1,
    "l1_percent" => 13,
    "l2_percent" => 14,
    "l3_percent" => 15,
    "l4_percent" => 16,
    "l5_percent" => 17
  }

  source("df_1718.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      data_type: 'NJ PARCC',
      data_type_id: 289,
      notes: 'DXT-3426: NJ PARCC',
      description: 'Statewide assessments have been used for decades in New Jersey and are designed to measure student progress toward achieving our academic standards. PARCC is a multi-state consortium that allows states, including New Jersey, to pool resources and expertise to develop a meaningful, comparable high-quality assessment - one that can be used to guide our efforts to continually improve our educational system by supporting teaching and learning, identifying struggling schools, informing teacher development, and providing parents with feedback on their own child\'s strengths and challenges. In 2016-17, the PARCC exam was administered to students.',
      year: 2018,
      date_valid: '2018-01-01 00:00:00'
    })
  end

  source("df_1819.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      data_type: 'NJSLA',
      data_type_id: 495,
      notes: 'DXT-3426: NJ NJSLA',
      description: 'The primary purpose of the Student Learning Assessments (NJSLA) is to provide high-quality assessments to measure students\' progress toward college and career readiness. The Spring 2019 NJSLA assessments were administered to students in grade 3 through high school. English Language Arts (ELA) assessments focused on reading and comprehending a range of sufficiently complex texts independently and writing effectively when analyzing text. Mathematics assessments focused on applying skills and concepts, understanding multi-step problems that require abstract reasoning, and modeling real-world problems with precision, perseverance, and strategic use of tools. In both content areas, students also demonstrated their acquired skills and knowledge by answering selected-response items and constructed response items.',
      year: 2019,
      date_valid: '2019-01-01 00:00:00'    
    })
  end




  shared do |s| 
    s.transform('Rename column headers', MultiFieldRenamer,{
      subgroup_type: :breakdown,
      valid_scores: :number_tested
    })
    .transform('Map breakdown_id',HashLookup, :breakdown, breakdown_id_map, to: :breakdown_id) 
    .transform('Map subject_id',HashLookup, :subject, subject_id_map, to: :subject_id) 
    .transform('Map proficiency_band_id',HashLookup, :proficiency_band, proficiency_band_id_map, to: :proficiency_band_id) 
  end

  def config_hash
    {
      source_id: 34,
      state: 'nj'
    }
  end
end

NJTestProcessor20182019PARCCNJSLA.new(ARGV[0], max: nil).run