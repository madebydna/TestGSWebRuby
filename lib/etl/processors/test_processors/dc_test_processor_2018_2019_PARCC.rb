require_relative "../../test_processor"

class DCTestProcessor20182019PARCC < GS::ETL::TestProcessor

  def initialize(*args)
    super
    @year = 2019
    @ticket_n = 'DXT-3448'
  end

  breakdown_id_map = {
      "All" => 1,
      "Asian" => 16,
      "American Indian/Alaskan Native" => 18,
      "Black/African American" => 17,
      "White/Caucasian" => 21,
      "Hispanic/Latino" => 19,
      "Female" => 26,
      "Male" => 25,
      "Active or Monitored English Learner" => 32,
      "Students with Disabilities" => 27,
      "Two or More Races" => 22

  }

  subject_id_map = {
    "ELA" => 4,
    "Math" => 5,
    "Integrated Math II" => 9,
    "Algebra I" => 6,
    "Algebra II" => 10,
    "English II" => 21,
    "Geometry" => 8

  }

  proficiency_band_id_map = {
    
    "percent_meeting_or_exceeding_expectations" => 1,
    "percent_level_1" => 13,
    "percent_level_2" => 14,
    "percent_level_3_2" => 15,
    "percent_level_4" => 16,
    "percent_level_5" => 17
  }

  source("dc.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      data_type: 'DC PARCC',
      data_type_id: 213,
      notes: 'DXT-3448 DC PARCC'
    })
    .transform('Rename column headers', MultiFieldRenamer,{
      subgroup_value: :breakdown
    })
    .transform('Set up year and description', WithBlock) do |row|
      if row[:year] == '2018'
        row[:date_valid] = '2018-01-01 00:00:00'
        row[:description] = 'In 2017-18, students in Washington, D.C. took the PARCC assessment. The PARCC assessment is computer-based and matches the high expectations of the Common Core State Standards, requiring students to think critically and solve real-world problems. Students in grades 3–8 and students enrolled in Algebra I, Algebra II, Geometry, Integrated Math II, and English II took the PARCC test. The PARCC test assesses what students are learning in school and helps teachers and parents know if students are on track for success in college and careers.'
      elsif row[:year] == '2019'
        row[:date_valid] = '2019-01-01 00:00:00'
        row[:description] = 'In 2018-19, students in Washington, D.C. took the PARCC assessment. The PARCC assessment is computer-based and matches the high expectations of the Common Core State Standards, requiring students to think critically and solve real-world problems. Students in grades 3–8 and students enrolled in Algebra I, Algebra II, Geometry, Integrated Math II, and English II took the PARCC test. The PARCC test assesses what students are learning in school and helps teachers and parents know if students are on track for success in college and careers.'
      end
      row
    end    
    .transform('Map breakdown_id',HashLookup, :breakdown, breakdown_id_map, to: :breakdown_id) 
    .transform('Map subject_id',HashLookup, :subject, subject_id_map, to: :subject_id) 
    .transform('Map proficiency_band_id',HashLookup, :proficiency_band, proficiency_band_id_map, to: :proficiency_band_id) 
  end


  def config_hash
    {
      source_id: 39,
      state: 'dc'
    }
  end
end

DCTestProcessor20182019PARCC.new(ARGV[0], max: nil).run
