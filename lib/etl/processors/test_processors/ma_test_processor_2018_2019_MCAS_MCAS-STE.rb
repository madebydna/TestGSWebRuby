require_relative "../../test_processor"

class MATestProcessor20182019MCASMCASSTE < GS::ETL::TestProcessor

  def initialize(*args)
    super
    @year = 2019
    @ticket_n = 'DXT-3432'
  end

  breakdown_id_map = {
      "All Students" => 1,
      "African American" => 17,
      "African American/Black" => 17,
      "American Indian or Alaska Native" => 18,
      "Native American" => 18,
      "Asian" => 16,
      "White" => 21,
      "Hispanic/Latino" => 19,
      "Female" => 26,
      "Male" => 25,
      "English Language Learner (EL)" => 32,
      "Hawaiian/Pacific Islander" => 20,
      "Native Hawaiian or Pacific Islander" => 20,
      "Economically Disadvantaged" => 23,
      "Non-Economically Disadvantaged" => 24,
      "Students with Disabilities" => 27,
      "Multi-Race (non-Hispanic/Latino)" => 22

  }

  subject_id_map = {
    "ELA" => 4,
    "MAT" => 5,
    "TEC" => 47,
    "Math" => 5,
    "G10_SCI" => 19,
    "ALL_STE" => 19,
    "STE" => 19,
    "BIO" => 22,
    "PHY" => 34,
    "CHE" => 35
  }

  proficiency_band_id_map = {
    "adv_per" => 1,
    "advpro_per" => 94,
    "ni_per" => 93,
    "pro_per" => 92,
    "wf_per" => 91,
    "meet_exceed_per" => 1,       
    "e_per" => 50,       
    "ee_per" => 50,              
    "nm_per" => 47,        
    "nme_per" => 47,       
    "pm_per" => 48,        
    "pme_per" => 48,
    "m_per" => 49,       
    "me_per" => 49

  }

  source("legacy.txt",[], col_sep: "\t") do |s|
    s.transform('Set up year and description',WithBlock) do |row|
      if row[:year] == '2018'
        row[:date_valid] = '2018-01-01 00:00:00'
        if row[:subject] == 'ELA' || row[:subject] == 'MAT' || row[:subject] == 'STE' || row[:subject] == 'ALL_STE' || row[:subject] == 'G10_SCI'
          row[:description] = 'In 2017-2018, Massachusetts used the Massachusetts Comprehensive Assessment System (MCAS) to test students in grades 3-8, and 10 in English Language Arts and Math, and grades 5, 8 and 10 in science. The MCAS is a standards-based test, it measures specific skills defined for each grade by the state of Massachusetts. The goal is for all students to score at or above proficient on the test.'
          row[:data_type] = 'MA MCAS'
          row[:data_type_id] = 290
          row[:notes] = 'DXT-3432: MA MCAS'
        else
          row[:description] = 'In 2017-2018 Massachusetts used the Massachusetts Comprehensive Assessment System Science and Technology/Engineering Tests (MCAS STE) to test students in high school in biology, chemistry, introductory physics and technology/engineering. The MCAS STE is a standards-based test, which means it measures specific skills defined for each grade by the state of Massachusetts. The goal is for all students to score at or above proficient on the test.'
          row[:data_type] = 'MA MCAS STE'
          row[:data_type_id] = 291
          row[:notes] = 'DXT-3432: MA MCAS STE'
        end
      elsif row[:year] == '2019'
        row[:date_valid] = '2019-01-01 00:00:00'
        if row[:subject] == 'ELA' || row[:subject] == 'MAT' || row[:subject] == 'STE' || row[:subject] == 'ALL_STE' || row[:subject] == 'G10_SCI'
          row[:description] = 'In 2018-2019, Massachusetts used the Massachusetts Comprehensive Assessment System (MCAS) to test students in grades 3-8, and 10 in English Language Arts and Math, and grades 5, 8 and 10 in science. The MCAS is a standards-based test, it measures specific skills defined for each grade by the state of Massachusetts. The goal is for all students to score at or above proficient on the test.'
          row[:data_type] = 'MA MCAS'
          row[:data_type_id] = 290
          row[:notes] = 'DXT-3432: MA MCAS'
        else
          row[:description] = 'In 2018-2019 Massachusetts used the Massachusetts Comprehensive Assessment System Science and Technology/Engineering Tests (MCAS STE) to test students in high school in biology, chemistry, introductory physics and technology/engineering. The MCAS STE is a standards-based test, which means it measures specific skills defined for each grade by the state of Massachusetts. The goal is for all students to score at or above proficient on the test.'
          row[:data_type] = 'MA MCAS STE'
          row[:data_type_id] = 291
          row[:notes] = 'DXT-3432: MA MCAS STE'
        end
      end
      row
    end
  end

  source("nextgen.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      data_type: 'MA MCAS',
      data_type_id: 290,
      notes: 'DXT-3432: MA MCAS'
    })
    .transform('Set up year and description', WithBlock) do |row|
      if row[:year] == '2018'
        row[:date_valid] = '2018-01-01 00:00:00'
        row[:description] = 'In 2017-2018, Massachusetts used the Massachusetts Comprehensive Assessment System (MCAS) to test students in grades 3-8, and 10 in English Language Arts and Math, and grades 5, 8 and 10 in science. The MCAS is a standards-based test, it measures specific skills defined for each grade by the state of Massachusetts. The goal is for all students to score at or above proficient on the test.'
      elsif row[:year] == '2019'
        row[:date_valid] = '2019-01-01 00:00:00'
        row[:description] = 'In 2018-2019, Massachusetts used the Massachusetts Comprehensive Assessment System (MCAS) to test students in grades 3-8, and 10 in English Language Arts and Math, and grades 5, 8 and 10 in science. The MCAS is a standards-based test, it measures specific skills defined for each grade by the state of Massachusetts. The goal is for all students to score at or above proficient on the test.'

      end
      row
    end
  end




  shared do |s| 
    s.transform('Rename column headers', MultiFieldRenamer,{
      tested_total: :number_tested,
      subgroup: :breakdown
    })    
    .transform('Map breakdown_id',HashLookup, :breakdown, breakdown_id_map, to: :breakdown_id) 
    .transform('Map proficiency_band_id',HashLookup, :proficiency_band, proficiency_band_id_map, to: :proficiency_band_id) 
    .transform('Map subject_id',HashLookup, :subject, subject_id_map, to: :subject_id) 
  end

  def config_hash
    {
      source_id: 25,
      state: 'ma'
    }
  end
end

MATestProcessor20182019MCASMCASSTE.new(ARGV[0], max: nil).run
