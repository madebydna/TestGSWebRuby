require_relative "../test_processor"

class NDTestProcessor2018NDSA < GS::ETL::TestProcessor

  def initialize(*args)
    super
    @year = 2018
  end


  map_nd_breakdown = {
    'All' => 1,
    'Black' => 17,
    'Native American' => 18,
    'Asian American' => 16,
    'White' => 21,
    'Low Income' => 23,
    'English Learner' => 32,
    'Female' => 26,
    'Hispanic' => 19,
    'Male' => 25,
    'IEP (student with disabilities)' => 27,
    'Native Hawaiian or Pacific Islander' => 20
    #'Non-English Learner' => 33,
    #'Non-IEP' => 30,
    #'Non-Low Income' => 24,
  }

  map_nd_subject = {
    'Reading' => 2,
    'Math' => 5,
    'Science' => 19
  }

  source("nd_2018_2019.txt",[], col_sep: "\t")

 shared do |s|
    s.transform('Fill missing default fields', Fill, {
      proficiency_band_id: 1,
      test_data_type: 'NDSA',
      test_data_type_id: 206,
      description: 'In 2016-17, North Dakota used the North Dakota State Assessment (NDSA) to test students in grades 3 through 8 and 11 in reading and math, and in science in grades 4, 8 and 11. Results represent students enrolled in the school for the entire academic year. The NDSA is a standards-based test, which means it measures how well students are mastering the specific skills defined for each grade by the state of North Dakota. The goal is for all students to score at or above the proficient level.',
      notes: 'DXT-3379: ND NDSA',
      date_valid: '2018-01-01 00:00:00',
    })
    .transform("Map breakdown id", HashLookup, :breakdown, map_nd_breakdown, to: :breakdown_id)
    .transform("Map subject id", HashLookup, :subject, map_nd_subject, to: :subject_id)
  end



  def config_hash
    {
        source_id: 38,
        state: 'nd'
    }
  end
end

NDTestProcessor2018NDSA.new(ARGV[0], max: nil).run