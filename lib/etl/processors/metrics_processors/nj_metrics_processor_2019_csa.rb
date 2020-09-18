require_relative '../../metrics_processor'

class NJMetricsProcessor2019CSA < GS::ETL::MetricsProcessor

  def initialize(*args)
    super
    @year = 2019
    @ticket_n = 'DXT-3617'
  end

  breakdown_id_map = {
      "Districtwide" => 1,
      "Statewide" => 1,
      "Schoolwide" => 1,
      "Black or African American" => 17,
      "American Indian or Alaska Native" => 18,
      "American Indian or Alaskan Native" => 18,
      "Asian, Native Hawaiian, or Pacific Islander" => 15,
      "White" => 21,
      "Hispanic" => 19,
      "Female" => 26,
      "Male" => 25,
      "English Learners" => 32,
      "Economically Disadvantaged" => 23,
      "Economically Disadvantaged Students" => 23,
      "Students With Disabilities" => 27,
      "Students with Disabilities" => 27,
      "Two or More Races" => 22,
      "schoolwide_persistence_rate" => 1,
      "economically_disadvantaged_students_persistence_rate" => 23  

  }

  subject_id_map = {
      "composite" => 1,       
      "english" => 17,
      "reading" => 2,
      "math" => 5,          
      "science" => 19
  }

  source("nj_sat_act_2019.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      grade: 'All',
      breakdown_id: 1,
      year: 2019,
      date_valid: "2019-01-01 00:00:00"
    })
      .transform('Map subject_id',HashLookup, :subject, subject_id_map, to: :subject_id) 
  end
  
  source("nj_sat_act_participation_2019.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      grade: 'All',
      breakdown_id: 1,
      subject_id: 1,
      year: 2019,
      date_valid: "2019-01-01 00:00:00"
    })
  end

  source("nj_grad_2019.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      data_type_id: 443,
      subject_id: 0,
      grade: 'NA',
      year: 2019,
      date_valid: "2019-01-01 00:00:00"
    })
    .transform('Map breakdown_id',HashLookup, :breakdown, breakdown_id_map, to: :breakdown_id) 
  end 

  source("nj_college_enrollment_2019.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      subject_id: 0,
      grade: 'NA',
      year: 2019,
      date_valid: "2019-01-01 00:00:00"
    })    
    .transform('Map breakdown_id',HashLookup, :breakdown, breakdown_id_map, to: :breakdown_id) 
  end

  source("nj_college_persistence_2019.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      data_type_id: 409,
      subject_id: 0,
      grade: 'NA',
      year: 2019,
      date_valid: "2019-01-01 00:00:00"
    })
    .transform('Map breakdown_id',HashLookup, :breakdown, breakdown_id_map, to: :breakdown_id) 
  end

  shared do |s| 
    s.transform('fill defaults',Fill,{
      notes: 'DXT-3617: NJ CSA'
    })
  end

  def config_hash
    {
      source_id: 34,
      state: 'nj'
    }
  end
end

NJMetricsProcessor2019CSA.new(ARGV[0], max: nil).run