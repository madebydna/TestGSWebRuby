require_relative '../../metrics_processor'

class NJMetricsProcessor20182019Growth < GS::ETL::MetricsProcessor

  def initialize(*args)
    super
    @year = 2019
    @ticket_n = 'DXT-3351'
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
      "Students with Disabilities" => 27,
      "Two or More Races" => 22

  }

  subject_id_map = {
    
    "ELA" => 4,
    "Math" => 5
  }

  source("nj_district_state_growth_2018_2019.txt",[], col_sep: "\t") 
  source("nj_school_growth_2018_2019.txt",[], col_sep: "\t") 

  shared do |s| 
    s.transform('fill defaults',Fill,{
      data_type: 'growth',
      data_type_id: 447,
      notes: 'DXT-3351: NJ Growth',
      grade: 'All'
    })
    .transform('Map breakdown_id',HashLookup, :breakdown, breakdown_id_map, to: :breakdown_id) 
    .transform('Map subject_id',HashLookup, :subject, subject_id_map, to: :subject_id) 
  end

  def config_hash
    {
      source_id: 34,
      state: 'nj'
    }
  end
end

NJMetricsProcessor20182019Growth.new(ARGV[0], max: nil).run