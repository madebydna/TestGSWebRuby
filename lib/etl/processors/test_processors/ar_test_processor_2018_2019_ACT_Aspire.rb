require_relative "../../test_processor"

class ARTestProcessor20182019ACTAspire < GS::ETL::TestProcessor

  def initialize(*args)
    super
    @year = 2019
    @ticket_n = 'DXT-3440'
  end

  breakdown_id_map = {
      "combined_population" => 1,
      "all_students_percentage_of_students" => 1,
      "african_american" => 17,
      "caucasian" => 21,
      "hispanic" => 19,
      "female" => 26,
      "male" => 25,
      "female_students" => 26,
      "male_students" => 25,
      "english_learners" => 32,
      "current_english_learners_(el)" => 32,
      "non-english_learners_(includes_former_el_monitored_1-4_years)" => 33,
      "economically_disadvantaged" => 23,
      "non-economically_disadvantaged" => 24,
      "students_with_disabilities" => 27,
      "students_without_disabilities" => 30

  }

  subject_id_map = {
    "english_language_arts_(ela)" => 4,
    "literacy" => 4,
    "mathematics" => 5,
    "math" => 5,
    "science" => 19

  }


  source("state.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      entity_type: 'state'
    })
  end

  source("district.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      entity_type: 'district'
    })
  end

  source("school.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      entity_type: 'school'
    })
  end

  shared do |s| 
    s.transform('Fill missing default fields', Fill, {
      data_type: 'AR ACT Aspire',
      data_type_id: 319,
      notes: 'DXT-3440 AR ACT Aspire',
      proficiency_band_id: 1
    })
    .transform('Rename column headers', MultiFieldRenamer,{
      lea: 'state_id'
    })
    .transform('Set up year and description', WithBlock) do |row|
      if row[:year] == '2018'
        row[:date_valid] = '2018-01-01 00:00:00'
        row[:description] = 'In 2017-2018, students in Arkansas took the ACT Aspire. The ACT Aspire is an end-of-year summative assessment that gauges student progression from grades 3 through 10 in English Language Arts, Math, and Science. The ACT Aspire is administered to students in grades 3-10 in Arkansas public schools.'
      elsif row[:year] == '2019'
        row[:date_valid] = '2019-01-01 00:00:00'
        row[:description] = 'In 2018-2019, students in Arkansas took the ACT Aspire. The ACT Aspire is an end-of-year summative assessment that gauges student progression from grades 3 through 10 in English Language Arts, Math, and Science. The ACT Aspire is administered to students in grades 3-10 in Arkansas public schools.'
      end
      row
    end    
    .transform('Map breakdown_id',HashLookup, :breakdown, breakdown_id_map, to: :breakdown_id) 
    .transform('Map subject_id',HashLookup, :subject, subject_id_map, to: :subject_id) 
  end

  def config_hash
    {
      source_id: 7,
      state: 'ar'
    }
  end
end

ARTestProcessor20182019ACTAspire.new(ARGV[0], max: nil).run
