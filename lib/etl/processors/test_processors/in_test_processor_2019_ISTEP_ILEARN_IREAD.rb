require_relative "../../test_processor"

class INTestProcessor2019ISTEPILEARNIREAD < GS::ETL::TestProcessor

  def initialize(*args)
    super
    @year = 2019
    @ticket_n ='DXT-3550'
  end

  breakdown_id_map={
    'All Students' => 1,
    'American Indian' => 18,
    'american_indian' => 18,
    'Asian' => 16,
    'asian' => 16,
    'Black' => 17,
    'black' => 17,
    'Hispanic' => 19,
    'hispanic' => 19,
    'Multiracial' => 22,
    'multiracial' => 22,
    'Native Hawaiian or Other Pacific Islander' => 20,
    'native_hawaiian_or_other_pacific_islander' => 20,
    'White' => 21,
    'white' => 21,
    'Female' => 26,
    'female' => 26,
    'Male' => 25, 
    'male' => 25,    
    'Paid meals' => 24,
    'Paid Meals' => 24,
    'paid_meals' => 24,
    'Free/Reduced price meals' => 23,
    'free_reduced_price_meals' => 23,
    'Free/Reduced Price Meals' => 23,
    'General Education' => 30,
    'general_education' => 30,
    'Special Education' => 27,
    'special_education' => 27,
    'Non-English Language Learners' => 33,
    'Non-English Language Learner' => 33,
    'non_english_language_learner' => 33,
    'English Language Learners' => 32,
    'English Language Learner' => 32,
    'english_language_learner' => 32,
  }

  subject_id_map={
    'ELA' => 4,
    'Math' => 5,
    'Reading' => 2,
    'Science' => 19,
    'Social Studies' => 18,
    'US Government' => 56,
    'Biology' => 22
  }

  source("ilearn_2019.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      data_type_id: 499,
      date_valid: '2019-01-01 00:00:00',
      description: 'In 2018-2019, students in Indiana took the Indiana Learning Evaluation Assessment Readiness Network (ILEARN). The ILEARN measures student achievement and growth according to Indiana Academic Standards. ILEARN is the summative accountability assessment for Indiana students and assesses students in English Language Arts and Mathematics in grades 3 through 8, in science in grades 4 and 6, and social studies in grade 5. Students in high school are also administered the Biology and US Government exams.',
      notes: 'DXT-3550: IN ILEARN'
    })
  end

   source("in_istep_2018_2019.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      data_type_id: 221,
      notes: 'DXT-3550: IN ISTEP'
    })
    .transform("Filling in description", WithBlock) do |row|
      if row[:year] == '2018'
            row[:date_valid] = '2018-01-01 00:00:00'
            row[:description] = 'In 2017-2018, Indiana used the Indiana Statewide Testing for Educational Progress-Plus (ISTEP+) assessment to test students in grades 3 through 8, and grade 10 in English language arts and math. The test was also administered to students in grades 4, 6, and 10 in science, and grade 5 and 7 in social studies. The ISTEP+ is a standards-based test, which means it measures specific skills defined for each grade by the state of Indiana. The goal is for all students to score at the passing level on the test.'
      elsif row[:year] == '2019'
            row[:date_valid] = '2019-01-01 00:00:00'
            row[:description] = 'In 2018-2019, Indiana used the Indiana Statewide Testing for Educational Progress-Plus (ISTEP+) assessment to test students in grade 10 in English language arts and math. The ISTEP+ is a standards-based test, which means it measures specific skills defined for each grade by the state of Indiana. The goal is for all students to score at the passing level on the test.'
      end
     row
    end
  end

    source("iread_2018_2019.txt",[], col_sep: "\t") do |s|
      data_type_id: 223,
      notes: 'DXT-3550: IN IREAD'
    })
    .transform("Filling in description", WithBlock) do |row|
      if row[:year] == '2018'
            row[:date_valid] = '2018-01-01 00:00:00'
            row[:description] = 'The Indiana Reading Evaluation and Determination (IREAD-3) assessment measures foundational reading standards to grade 3 students each spring. Students in Indiana took this assessment in 2017-2018.'
      elsif row[:year] == '2019'
            row[:date_valid] = '2019-01-01 00:00:00'
            row[:description] = 'The Indiana Reading Evaluation and Determination (IREAD-3) assessment measures foundational reading standards to grade 3 students each spring. Students in Indiana took this assessment in 2018-2019.'
      end
     row
    end
  end


  shared do |s|
    s.transform('Fill missing default fields', Fill, {
      proficiency_band_id: 1
    })
    .transform('Map subject_id',HashLookup, :subject, subject_id_map, to: :subject_id)               
    .transform('Map breakdown_id',HashLookup, :breakdown, breakdown_id_map, to: :breakdown_id) 
  end

  def config_hash
    {
      source_id: 18,
      state: 'in'
    }
  end
end

INTestProcessor2019ISTEPILEARNIREAD.new(ARGV[0], max: nil, offset: nil).run
