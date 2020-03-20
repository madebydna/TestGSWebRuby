require_relative "../test_processor"

class INTestProcessor2017ISTEPIREAD < GS::ETL::TestProcessor

  def initialize(*args)
    super
    @year = 2017
  end

  breakdown_id_map={
    'All Student' => 1,
    'American Indian' => 18,
    'Asian' => 16,
    'Black' => 17,
    'Hispanic' => 19,
    'Multiracial' => 22,
    'Native Hawaiian or Other Pacific Islander' => 20,
    'White' => 21,
    'Female' => 26,
    'Male' => 25,    
    'Paid meals' => 24,
    'Free/Reduced price meals' => 23,
    'General Education' => 30,
    'Special Education' => 27,
    'Non-English Language Learner' => 33,
    'English Language Learner' => 32,
    'Total' => 1
  }

  subject_id_map={
    'ELA' => 4,
    'Math' => 5,
    'reading' => 2
  }

  source("grade3-8-10-final-statewide-summary-disaggregated.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      entity_type: 'state',
      test_data_type: 'ISTEP',
      test_data_type_id: 221,
      description: 'In 2016-2017, Indiana used the Indiana Statewide Testing for Educational Progress-Plus (ISTEP+) assessment to test students in grades 3 through 8, and grade 10 in English language arts and math. The ISTEP+ is a standards-based test, which means it measures specific skills defined for each grade by the state of Indiana. The goal is for all students to score at the passing level on the test.',
      notes: 'DXT-2508: IN ISTEP'
    })
  end

  source("grade3-8-final-corporation.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      entity_type: 'district',
      test_data_type: 'ISTEP',
      test_data_type_id: 221,
      description: 'In 2016-2017, Indiana used the Indiana Statewide Testing for Educational Progress-Plus (ISTEP+) assessment to test students in grades 3 through 8, and grade 10 in English language arts and math. The ISTEP+ is a standards-based test, which means it measures specific skills defined for each grade by the state of Indiana. The goal is for all students to score at the passing level on the test.',
      notes: 'DXT-2508: IN ISTEP',
      breakdown: 'All Student'
    })
  end
  source("grade10_final_corporation.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      entity_type: 'district',
      test_data_type: 'ISTEP',
      test_data_type_id: 221,
      description: 'In 2016-2017, Indiana used the Indiana Statewide Testing for Educational Progress-Plus (ISTEP+) assessment to test students in grades 3 through 8, and grade 10 in English language arts and math. The ISTEP+ is a standards-based test, which means it measures specific skills defined for each grade by the state of Indiana. The goal is for all students to score at the passing level on the test.',
      notes: 'DXT-2508: IN ISTEP',
      breakdown: 'All Student'
    })
  end
  source("frl_2017_ISTEP_Corp.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      entity_type: 'district',
      test_data_type: 'ISTEP',
      test_data_type_id: 221,
      description: 'In 2016-2017, Indiana used the Indiana Statewide Testing for Educational Progress-Plus (ISTEP+) assessment to test students in grades 3 through 8, and grade 10 in English language arts and math. The ISTEP+ is a standards-based test, which means it measures specific skills defined for each grade by the state of Indiana. The goal is for all students to score at the passing level on the test.',
      notes: 'DXT-2508: IN ISTEP'
    })
  end
  source("ethnicity_2017_ISTEP_Corp.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      entity_type: 'district',
      test_data_type: 'ISTEP',
      test_data_type_id: 221,
      description: 'In 2016-2017, Indiana used the Indiana Statewide Testing for Educational Progress-Plus (ISTEP+) assessment to test students in grades 3 through 8, and grade 10 in English language arts and math. The ISTEP+ is a standards-based test, which means it measures specific skills defined for each grade by the state of Indiana. The goal is for all students to score at the passing level on the test.',
      notes: 'DXT-2508: IN ISTEP'
    })
  end
  source("ell_2017_ISTEP_Corp.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      entity_type: 'district',
      test_data_type: 'ISTEP',
      test_data_type_id: 221,
      description: 'In 2016-2017, Indiana used the Indiana Statewide Testing for Educational Progress-Plus (ISTEP+) assessment to test students in grades 3 through 8, and grade 10 in English language arts and math. The ISTEP+ is a standards-based test, which means it measures specific skills defined for each grade by the state of Indiana. The goal is for all students to score at the passing level on the test.',
      notes: 'DXT-2508: IN ISTEP'
    })
  end
  source("spe_2017_ISTEP_Corp.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      entity_type: 'district',
      test_data_type: 'ISTEP',
      test_data_type_id: 221,
      description: 'In 2016-2017, Indiana used the Indiana Statewide Testing for Educational Progress-Plus (ISTEP+) assessment to test students in grades 3 through 8, and grade 10 in English language arts and math. The ISTEP+ is a standards-based test, which means it measures specific skills defined for each grade by the state of Indiana. The goal is for all students to score at the passing level on the test.',
      notes: 'DXT-2508: IN ISTEP'
    })
  end

  source("grade3-8-final-school.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      entity_type: 'school',
      test_data_type: 'ISTEP',
      test_data_type_id: 221,
      description: 'In 2016-2017, Indiana used the Indiana Statewide Testing for Educational Progress-Plus (ISTEP+) assessment to test students in grades 3 through 8, and grade 10 in English language arts and math. The ISTEP+ is a standards-based test, which means it measures specific skills defined for each grade by the state of Indiana. The goal is for all students to score at the passing level on the test.',
      notes: 'DXT-2508: IN ISTEP',
      breakdown: 'All Student'
    })
  end
  source("grade10_final_school.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      entity_type: 'school',
      test_data_type: 'ISTEP',
      test_data_type_id: 221,
      description: 'In 2016-2017, Indiana used the Indiana Statewide Testing for Educational Progress-Plus (ISTEP+) assessment to test students in grades 3 through 8, and grade 10 in English language arts and math. The ISTEP+ is a standards-based test, which means it measures specific skills defined for each grade by the state of Indiana. The goal is for all students to score at the passing level on the test.',
      notes: 'DXT-2508: IN ISTEP',
      breakdown: 'All Student'
    })
  end
  source("frl_2017_ISTEP_Schl.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      entity_type: 'school',
      test_data_type: 'ISTEP',
      test_data_type_id: 221,
      description: 'In 2016-2017, Indiana used the Indiana Statewide Testing for Educational Progress-Plus (ISTEP+) assessment to test students in grades 3 through 8, and grade 10 in English language arts and math. The ISTEP+ is a standards-based test, which means it measures specific skills defined for each grade by the state of Indiana. The goal is for all students to score at the passing level on the test.',
      notes: 'DXT-2508: IN ISTEP'
    })
  end
  source("ethnicity_2017_ISTEP_Schl.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      entity_type: 'school',
      test_data_type: 'ISTEP',
      test_data_type_id: 221,
      description: 'In 2016-2017, Indiana used the Indiana Statewide Testing for Educational Progress-Plus (ISTEP+) assessment to test students in grades 3 through 8, and grade 10 in English language arts and math. The ISTEP+ is a standards-based test, which means it measures specific skills defined for each grade by the state of Indiana. The goal is for all students to score at the passing level on the test.',
      notes: 'DXT-2508: IN ISTEP'
    })
  end
  source("ell_2017_ISTEP_Schl.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      entity_type: 'school',
      test_data_type: 'ISTEP',
      test_data_type_id: 221,
      description: 'In 2016-2017, Indiana used the Indiana Statewide Testing for Educational Progress-Plus (ISTEP+) assessment to test students in grades 3 through 8, and grade 10 in English language arts and math. The ISTEP+ is a standards-based test, which means it measures specific skills defined for each grade by the state of Indiana. The goal is for all students to score at the passing level on the test.',
      notes: 'DXT-2508: IN ISTEP'
    })
  end
  source("spe_2017_ISTEP_Schl.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      entity_type: 'school',
      test_data_type: 'ISTEP',
      test_data_type_id: 221,
      description: 'In 2016-2017, Indiana used the Indiana Statewide Testing for Educational Progress-Plus (ISTEP+) assessment to test students in grades 3 through 8, and grade 10 in English language arts and math. The ISTEP+ is a standards-based test, which means it measures specific skills defined for each grade by the state of Indiana. The goal is for all students to score at the passing level on the test.',
      notes: 'DXT-2508: IN ISTEP'
    })
  end


  source("IREAD-final-2017-statewide-student-performance-spring-and-summer.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      entity_type: 'state',
      test_data_type: 'IREAD',
      test_data_type_id: 223,
      description: 'The IREAD-3 assesses the 2017 Indiana Academic Standards, specifically those standards which align to foundational skills in reading.',
      notes: 'DXT-2508: IN IREAD',
      subject: 'reading'
    })
  end

  source("district_IREAD-final-2017-public-corporation-and-school-results.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      entity_type: 'district',
      test_data_type: 'IREAD',
      test_data_type_id: 223,
      description: 'The IREAD-3 assesses the 2017 Indiana Academic Standards, specifically those standards which align to foundational skills in reading.',
      notes: 'DXT-2508: IN IREAD',
      subject: 'reading',
      breakdown: 'All Student'
    })
  end
  source("district_IREAD_diagg.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      entity_type: 'district',
      test_data_type: 'IREAD',
      test_data_type_id: 223,
      description: 'The IREAD-3 assesses the 2017 Indiana Academic Standards, specifically those standards which align to foundational skills in reading.',
      notes: 'DXT-2508: IN IREAD',
      subject: 'reading'
    })
  end

  source("school_IREAD-final-2017-public-corporation-and-school-results.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      entity_type: 'school',
      test_data_type: 'IREAD',
      test_data_type_id: 223,
      description: 'The IREAD-3 assesses the 2017 Indiana Academic Standards, specifically those standards which align to foundational skills in reading.',
      notes: 'DXT-2508: IN IREAD',
      subject: 'reading',
      breakdown: 'All Student'
    })
  end
  source("IREAD-final-2017-nonpublic-school-results.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      entity_type: 'school',
      test_data_type: 'IREAD',
      test_data_type_id: 223,
      description: 'The IREAD-3 assesses the 2017 Indiana Academic Standards, specifically those standards which align to foundational skills in reading.',
      notes: 'DXT-2508: IN IREAD',
      subject: 'reading',
      breakdown: 'All Student'
    })
  end
  source("school_IREAD_diagg.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      entity_type: 'school',
      test_data_type: 'IREAD',
      test_data_type_id: 223,
      description: 'The IREAD-3 assesses the 2017 Indiana Academic Standards, specifically those standards which align to foundational skills in reading.',
      notes: 'DXT-2508: IN IREAD',
      subject: 'reading'
    })
  end

  shared do |s|
    s.transform('Rename column headers', MultiFieldRenamer,{
      student_demographic: :breakdown,
      pass: :value,
      grade_demographic: :grade,
      test_n: :number_tested,
      corp_id: :district_id,
      corp_name: :district_name,
      percent_pass: :value,
      corporation_id: :district_id,
      corporation_name: :district_name,
      iread_test_n: :number_tested,
      iread_pass: :value,
      sch_id: :school_id,
      sch_name: :school_name
    })
    .transform('Fill missing default fields', Fill, {
      year: 2017,
      date_valid: '2017-01-01 00:00:00',
      proficiency_band_id: 1,
      proficiency_band: 'proficient and above',
    })
    .transform('skip * value',DeleteRows,:value, '***','****')
    .transform('skip n_tested less than 10',DeleteRows,:number_tested, '1','2','3','4','5','6','7','8','9')    
    .transform("Assign skip value", WithBlock) do |row|
      if (row[:entity_type] == 'district' and row[:district_name] == 'Independent Non-Public Schools') or (row[:grade] == 'Corporation Total') or (row[:grade] == 'School Total')
          row[:value] = 'skip'
      end
      row
    end
    .transform('skip non-public independent',DeleteRows,:value, 'skip')  
    .transform("Assign grade", WithBlock) do |row|
      if row[:grade] =~ /\d/
          row[:grade].gsub!('Grade ','')
      elsif row[:grade] == 'GRAND TOTAL'
          row[:grade] = 'All'
      elsif row[:test_data_type] == 'IREAD'
          row[:grade] = '3'
      end
      row
    end
    .transform('Map subject_id',HashLookup, :subject, subject_id_map, to: :subject_id)               
    .transform('Map breakdown_id',HashLookup, :breakdown, breakdown_id_map, to: :breakdown_id) 
    .transform('Set up state_id',WithBlock) do |row|
      if row[:entity_type] == 'school'
        row[:state_id] = row[:school_id].rjust(4,'0')  
      elsif row[:entity_type] == 'district'
        row[:district_id] = row[:district_id].to_i().to_s()
        row[:state_id] = row[:district_id].rjust(4,'0')
      else
        row[:state_id] = 'state'
      end
      row
    end
  end

  def config_hash
    {
      source_id: 18,
      state: 'in'
    }
  end
end

INTestProcessor2017ISTEPIREAD.new(ARGV[0], max: nil, offset: nil).run
