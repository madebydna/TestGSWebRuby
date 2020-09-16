require_relative '../../metrics_processor'

class FLMetricsProcessor2019CSA < GS::ETL::MetricsProcessor

  def initialize(*args)
    super
    @year = 2019
    @ticket_n = 'DXT-3466'
  end

  breakdown_id_map = {
      "All Students" => 1,
      "Total" => 1,
      "3-Black" => 17,
      "Black" => 17,
      "6-American Indian" => 18,
      "Native American" => 18,
      "5-Asian" => 16,
      "Asian" => 16,
      "7-Pacific Islander" => 37,
      "Pacific Islander" => 37,
      "1-White" => 21,
      "White" => 21,
      "2-Hispanic" => 19,
      "Hispanic" => 19,
      "Female" => 26,
      "Male" => 25,
      "ELL" => 32,
      "Non-ELL" => 33,
      "Eco. Disadvantaged" => 23,
      "FRL" => 23,
      "Non-Eco. Disadvantaged" => 24,
      "SWD" => 27,
      "Non-SWD" => 30,
      "4-Two or More Races" => 22,
      "Multiracial" => 22
  }

  subject_id_map = {
    "total_score_mean" => 1,
    "all_three_subjects" => 89,
    "all_four" => 1,
    "comp" => 1,
    "reading" => 2,
    "writing" => 3,
    "eng" => 17,
    "erw_mean" => 2,
    "math" => 5,
    "math_mean" => 5,
    "sci" => 19
  }

  source("fl_grad_2019.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      data_type_id: 443,
      subject_id: 0,
      grade: 'NA',
      year: 2019,
      date_valid: "2019-01-01 00:00:00"
    })
  end 

  source("fl_sat_2019.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      data_type_id: 446,
      grade: 'All',
      year: 2019,
      date_valid: "2019-01-01 00:00:00"
    })
      .transform('Map subject_id',HashLookup, :subject, subject_id_map, to: :subject_id) 
  end

  source("fl_act_2018.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      grade: 'All',
      year: 2018,
      date_valid: "2018-01-01 00:00:00"
    })
      .transform('Map subject_id',HashLookup, :subject, subject_id_map, to: :subject_id) 
  end

  source("fl_college_enrollment_2018.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      data_type_id: 414,
      subject_id: 0,      
      grade: 'NA',
      year: 2018,
      date_valid: "2018-01-01 00:00:00"
    })
  end

  source("fl_college_remediation_2017.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      data_type_id: 413,
      grade: 'NA',
      year: 2017,
      date_valid: "2017-01-01 00:00:00"
    })
      .transform('Map subject_id',HashLookup, :subject, subject_id_map, to: :subject_id) 

  end

  shared do |s| 
    s.transform('Map breakdown_id',HashLookup, :breakdown, breakdown_id_map, to: :breakdown_id) 
     .transform('Fill missing default fields', Fill, {
      notes: 'DXT-3466 FL CSA'
    })
  end

  def config_hash
    {
      source_id: 12,
      state: 'fl'
    }
  end
end

FLMetricsProcessor2019CSA.new(ARGV[0], max: nil).run