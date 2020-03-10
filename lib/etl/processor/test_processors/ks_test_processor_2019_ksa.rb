require_relative "../test_processor"

class KSTestProcessor2019Ksa < GS::ETL::TestProcessor
  #GS::ETL::Logging.disable

  def initialize(*args)
    super
    @year = 2019
  end


  breakdown_id_map={
    'Females' => 26,
    'Males' => 25,
    'American Indian or Alaska Native' => 18,
    'Asian' => 16,
    'African-American Students' => 17,
    'Hispanic' => 19,
    'Multi-Racial' => 22,
    'White' => 21,
    'English Learner Students' => 32,
    'Non-English Learner Students' => 33,
    'Free and Reduced Lunch' => 23,
    'Self-Paid Lunch only' => 24,
    'All Students' => 1,
    'Native Hawaiian or Pacific Islander' => 20, 
    'Not Disabled' => 30,
    'Students with  Disabilities' => 27
  }

  subject_id_map={
    'Math' => 5,
    'ELA' => 4,
    'Science' => 19
  }

  proficiency_band_id_map={
    'PCLevel_One' => 5,
    'PCLevel_Two' => 6,
    'PCLevel_Three' => 7,
    'PCLevel_Four' => 8,
    'prof_and_above' => 1
  }


  source("ks_2019.txt",[], col_sep: "\t")


  shared do |s|
     s.transform("Fill", Fill, {
      test_data_type: 'KSA',
      test_data_type_id: 243,
      notes: 'DXT-3393: KS KSA',
      date_valid: '2019-01-01 00:00:00',
      description: 'In 2018-19, Kansas used the Kansas State Assessments (KSA) to test students in grades 3 though 8, and 10 in English Language Arts and Math. Students were also tested in grades 5,8,11 in science. The tests are standards-based, which means they measure how well students are mastering specific skills defined for each grade by the state of Kansas. The goal is for all students to score at or above the state standard.'
      })
     .transform("map breakdown to id", HashLookup, :breakdown, breakdown_id_map, to: :breakdown_id)
     .transform('map subject to ids', HashLookup, :subject, subject_id_map, to: :subject_id)
     .transform('map proficiency band to ids', HashLookup, :proficiency_band, proficiency_band_id_map, to: :proficiency_band_id)
  end

  def config_hash
    {
        source_id: 20,
        state: 'ks'
    }
  end
end

KSTestProcessor2019Ksa.new(ARGV[0], max: nil).run