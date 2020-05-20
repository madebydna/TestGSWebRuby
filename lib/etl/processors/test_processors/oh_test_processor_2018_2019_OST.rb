require_relative "../../test_processor"

class OHTestProcessor20182019OST < GS::ETL::TestProcessor

  def initialize(*args)
    super
    @year = 2019
    @ticket_n = 'DXT-3425'
  end

  breakdown_id_map = {
      "All Students" => 1,
      "Black, Non-Hispanic" => 17,
      "Black" => 17,
      "BLACK" => 17,
      "American Indian or Alaskan Native" => 18,
      "INDIAN" => 18,
      "Asian" => 16,
      "ASIAN" => 16,
      "Asian or Pacific Islander" => 16,
      "White, Non-Hispanic" => 21,
      "White" => 21,
      "WHITE" => 21,
      "Hispanic" => 19,
      "HISPANIC" => 19,
      "Multiracial" => 22,
      "MULTIRACIAL" => 22,
      "Female" => 26,
      "FEMALE" => 26,
      "Male" => 25,
      "MALE" => 25,
      "LEP" => 32,
      "ENGLEARN" => 32,
      "English Learner" => 32,
      "NonLEP" => 33,
      "NOTENGLEARN" => 33,
      "Pacific Islander" => 20,
      "ECONDISADV" => 23,
      "Disadvantaged" => 23,
      "NOTECONDISADV" => 24,
      "NonDisadvantaged" => 24,
      "Disabled" => 27,
      "DISABLED" => 27,
      "NOTDISABLED" => 30,
      "NonDisabled" => 30

  }

  subject_id_map = {
    
    "american_us_government" => 56,        
    "american_us_history" => 82,
    "algebra_i" => 6,
    "biology" => 22,
    "english_language_arts" => 4,
    "ela" => 4,
    "english_language_arts_i" => 73,
    "english_language_arts_ii" => 70,
    "geometry" => 8,
    "government" => 56,
    "history" => 82,
    "hs_algebra_i" => 6,
    "hs_biology" => 22,
    "hs_english_i" => 73,
    "hs_english_ii" => 70,
    "hs_geometry" => 8,
    "hs_government" => 56,
    "hs_history" => 82,
    "hs_math_i" => 7,
    "hs_math_ii" => 9,
    "integrated_math_i" => 7,
    "mathematics_i" => 7,
    "integrated_math_ii" => 9,
    "mathematics_ii" => 9,
    "math" => 5,
    "mathematics" => 5,
    "read" => 2,
    "reading" => 2,
    "science" => 19
  }

  source("state.txt",[], col_sep: "\t") do |s|
    s.transform('Rename column headers', MultiFieldRenamer,{
      subgroup: :breakdown
    })
  end

  source("district.txt",[], col_sep: "\t") do |s|
    s.transform('Rename column headers', MultiFieldRenamer,{
      student_group: :breakdown,
      district_irn: :state_id
    })
  end

 source("school.txt",[], col_sep: "\t") do |s|
    s.transform('Rename column headers', MultiFieldRenamer,{
      student_group: :breakdown,
      building_irn: :state_id
    })
  end




  shared do |s| 
    s.transform('Fill missing default fields', Fill, {
      proficiency_band_id: 1,
      proficiency_band: 'proficient and above',
      data_type: 'OST',
      data_type_id: 256,
      notes: 'DXT-3425: OH OST'
    })
    .transform('Set up year and description',WithBlock) do |row|
      if row[:year] == '2018'
        row[:date_valid] = '2018-01-01 00:00:00'
        row[:description] = 'In 2017-2018, students took state tests in math, English language arts, science and social studies to measure how well they are meeting the expectations of their grade levels. The tests match the content and skills that are taught in the classroom every day and measure real-world skills like critical thinking, problem solving and writing.'
      elsif row[:year] == '2019'
        row[:date_valid] = '2019-01-01 00:00:00'
        row[:description] = 'In 2018-2019, students took state tests in math, English language arts, science and social studies to measure how well they are meeting the expectations of their grade levels. The tests match the content and skills that are taught in the classroom every day and measure real-world skills like critical thinking, problem solving and writing.'
      end
      row
    end
    .transform('Rename column headers', MultiFieldRenamer,{
      prof_above: :value
    })
    .transform('Map breakdown_id',HashLookup, :breakdown, breakdown_id_map, to: :breakdown_id) 
    .transform('Map subject_id',HashLookup, :subject, subject_id_map, to: :subject_id) 
  end

  def config_hash
    {
      source_id: 40,
      state: 'oh'
    }
  end
end

OHTestProcessor20182019OST.new(ARGV[0], max: nil).run