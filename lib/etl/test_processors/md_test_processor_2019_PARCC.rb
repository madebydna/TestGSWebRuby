require_relative "../test_processor"

class MDTestProcessor2019PARCC < GS::ETL::TestProcessor

  def initialize(*args)
    super
    @year = 2019
  end


  key_map_bd = {
    'All Students' => 1,
    'Hispanic/Latino of any race' => 19,
    'American Indian or Alaska Native' => 18,
    'Black or African American' => 17,
    'Asian' => 16,    
    'Native Hawaiian or Other Pacific Islander' => 20,
    'White' => 21,    
    'Two or more races' => 22,
    'Male' => 25,
    'Female' => 26, 
    'Limited English Proficient' => 32,
    'Special Education' => 27
  }

  key_map_sub = {
    'English/Language Arts' => 4,
    'Mathematics' => 5,
    'Algebra 1' => 6,
    'Algebra 2' => 10,
    'Geometry' => 8,
  }

  key_map_prof = {
    'prof_and_above' => 1
  }
  
  source("md_2017_2018_2019.txt",[], col_sep: "\t")

  shared do |s|
    s.transform("Fill missing default fields", Fill, {
      test_data_type_id: 216,
      notes: 'DXT-3133: MD PARCC'
    })
    .transform("Adding column breakdown_id from breadown",
      HashLookup, :breakdown, key_map_bd, to: :breakdown_id)
    .transform("Adding column subject_id from subject",
      HashLookup, :subject, key_map_sub, to: :subject_id)
    .transform("Adding column prof_band_id from proficiency_band",
      HashLookup, :proficiency_band, key_map_prof, to: :proficiency_band_id)
    .transform('create date_valid and description',WithBlock,) do |row|
        if row[:year] == '2017' 
            row[:date_valid] = '2017-01-01 00:00:00'
            row[:description] = "In school year 2016-17, the PARCC assessments in mathematics and English Arts(ELA)/Literacy were administered to students in Maryland. The PARCC assessments will measure the content and skills contained in the new standards. The English Language Arts and Literacy and Mathematics assessments are end-of-course exams. For students in grades 3 through 8, they are given toward the end of the school year. For students in high school, they are normally given after they complete most of their grade 9, grade 10 or grade 11 English course. Assessments in Algebra 1, Geometry, and Algebra 2 are also administered after a student has completed most of the required course."
        elsif row[:year] == '2018'
            row[:date_valid] = '2018-01-01 00:00:00'
            row[:description] = "In school year 2017-18, the PARCC assessments in mathematics and English Arts(ELA)/Literacy were administered to students in Maryland. The PARCC assessments will measure the content and skills contained in the new standards. The English Language Arts and Literacy and Mathematics assessments are end-of-course exams. For students in grades 3 through 8, they are given toward the end of the school year. For students in high school, they are normally given after they complete most of their grade 9, grade 10 or grade 11 English course. Assessments in Algebra 1, Geometry, and Algebra 2 are also administered after a student has completed most of the required course."
        elsif row[:year] == '2019'
            row[:date_valid] = '2019-01-01 00:00:00'
            row[:description] = "In school year 2018-19, the PARCC assessments in mathematics and English Arts(ELA)/Literacy were administered to students in Maryland. The PARCC assessments will measure the content and skills contained in the new standards. The English Language Arts and Literacy and Mathematics assessments are end-of-course exams. For students in grades 3 through 8, they are given toward the end of the school year. For students in high school, they are normally given after they complete most of their grade 9, grade 10 or grade 11 English course. Assessments in Algebra 1, Geometry, and Algebra 2 are also administered after a student has completed most of the required course."
        end
        row
    end
  end

  def config_hash
    {
        source_id: 24,
        state: 'md'
    }
  end
end

MDTestProcessor2019PARCC.new(ARGV[0], max: nil).run
