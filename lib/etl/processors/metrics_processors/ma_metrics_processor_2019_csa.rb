require_relative '../../metrics_processor'

class MAMetricsProcessor2019CSA < GS::ETL::MetricsProcessor

  def initialize(*args)
    super
    @year = 2019
    @ticket_n = 'DXT-3409'
  end

  breakdown_id_map = {
      "All Students" => 1,
      "All" => 1,
      "African American/Black" => 17,
      "AfAm" => 17,
      "American Indian or Alaskan Native" => 18,
      "Asian" => 16,
      "Native Hawaiian or Pacific Islander" => 20,
      "White" => 21,
      "WH" => 21,
      "Hispanic" => 19,
      "Hisp" => 19,
      "Female" => 26,
      "Male" => 25,
      "English Learner" => 32,
      "ELL" => 32,
      "Low Income" => 23,
      "LowInc" => 23,
      "Ecodis" => 23,
      "Students with Disabilities" => 27,
      "SPED" => 27,
      "Multi-race non-Hispanic or Latino" => 22
  }

  subject_id_map = {
    "composite" => 1,
    "reading_writing" => 2,
    "math" => 5
  }

  source("ma_grad_2019.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      data_type_id: 443,
      notes: 'DXT-3409 MA 4-year high school graduation rate',
      subject_id: 0,
      grade: 'NA'
    })
  end 

  source("ma_sat_2019.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      data_type_id: 446,
      notes: 'DXT-3409 MA Average SAT score',
      grade: 'All'
    })
    .transform('Map subject_id',HashLookup, :subject, subject_id_map, to: :subject_id) 
  end

  source("ma_college_2018.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      subject_id: 0,      
      grade: 'NA'
    })
  end

  source("ma_remediation_2018.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      data_type_id: 413,
      notes: 'DXT-3409 MA College remediation',
      subject_id: 89,
      grade: 'NA'
    })

  end

  shared do |s| 
    s.transform('Map breakdown_id',HashLookup, :breakdown, breakdown_id_map, to: :breakdown_id) 
  end

  def config_hash
    {
      source_id: 25,
      state: 'ma'
    }
  end
end

MAMetricsProcessor2019CSA.new(ARGV[0], max: nil).run