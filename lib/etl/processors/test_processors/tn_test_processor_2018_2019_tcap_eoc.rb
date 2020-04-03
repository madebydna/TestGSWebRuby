require_relative "../../test_processor"

class TNTestProcessor20182019TCAPEOC < GS::ETL::TestProcessor

  def initialize(*args)
    super
    @year = 2019
    @ticket_n = 'DXT-3433'
  end

  map_breakdown = {
    'All Students' => 1,
    'Black or African American' => 17,
    'American Indian or Alaska Native' => 18,
    'Asian' => 16,
    'White' => 21,
    'Economically Disadvantaged' => 23,
    'Non-Economically Disadvantaged' => 24,
    'English Learners' => 32,
    'Female' => 26,
    'Male' => 25,
    #'Non-English Learners' => 33,
    'Hispanic' => 19,
    'Students with Disabilities' => 27,
    'Non-Students with Disabilities' => 30,
    'Native Hawaiian or Other Pacific Islander' => 20
  }

  map_subject = {
    'ELA' => 4,
    'Math' => 5,
    'Science' => 19,
    'Social Studies' => 18,
    'Algebra I' => 6,
    'Algebra II' => 10,
    'Geometry' => 8,
    'Biology I' => 22,
    'Chemistry' => 35,
    'English I' => 17,
    'English II' => 21,
    'English III' => 49,
    'Integrated Math I' => 7,
    'Integrated Math II' => 9,
    'Integrated Math III' => 11,
    'US History' => 23
   }

  map_prof_band = {
    'pct_below' => 79,
    'pct_approaching' => 80,
    'pct_on_track' => 81,
    'pct_mastered' => 82,
    'pct_on_mastered' => 1
  }

  source("tn_2018_2019.txt",[], col_sep: "\t")


  shared do |s|
    s.transform("Removing 0 school_id", DeleteRows,:school_id,'0')      
      .transform("source", WithBlock) do |row|
        if row[:data_type] == 'TCAP'
          row[:data_type_id] = 257
          row[:notes] = 'DXT-3433: TN TCAP'
            if row[:year] == '2018'
              row[:date_valid] ='2018-01-01 00:00:00'
              row[:description] = 'In 2017-2018, Tennessee used the Tennessee Comprehensive Assessment Program (TCAP) Achievement Test to test students in grades 3 through 8 in reading/language arts, math, and social studies, and grades 5 through 8 in science. The TCAP is a standards-based test that measures specific skills defined for each grade by the state of Tennessee. The goal is for all students to score at or above the proficient level.'   
            elsif row[:year] == '2019'
              row[:date_valid] ='2019-01-01 00:00:00'
              row[:description] = 'In 2018-2019, Tennessee used the Tennessee Comprehensive Assessment Program (TCAP) Achievement Test to test students in grades 3 through 8 in reading/language arts and math, and grades 6 through 8 in social studies. The TCAP is a standards-based test that measures specific skills defined for each grade by the state of Tennessee. The goal is for all students to score at or above the proficient level.'
            end       
        elsif row[:data_type] == 'GATEWAY'
          row[:data_type_id] = 258
          row[:notes] = 'DXT-3433: TN GATEWAY'
            if row[:year] == '2018'
              row[:date_valid] ='2018-01-01 00:00:00'
              row[:description] = 'In 2017-2018, Tennessee used the Gateway/EOC (EOC) exams to test high school students in language arts, math, science, and social studies upon completion of relevant courses. The Gateway/EOC exams are standards-based tests that measure how well students are mastering specific skills defined by the state of Tennessee. The goal is for all students to score at or above the proficient level.'    
            elsif row[:year] == '2019'
              row[:date_valid] ='2019-01-01 00:00:00'
              row[:description] = 'In 2018-2019, Tennessee used the Gateway/End-of-Course (EOC) exams to test high school students in language arts, math, science, and social studies upon completion of relevant courses. The Gateway/EOC exams are standards-based tests that measure how well students are mastering specific skills defined by the state of Tennessee. The goal is for all students to score at or above the proficient level.'
            end
        end
        row
      end 
      .transform("map subject ids", HashLookup, :subject, map_subject, to: :subject_id)
      .transform("map breakdown id",HashLookup, :breakdown, map_breakdown, to: :breakdown_id)
      .transform("map prof band id",HashLookup, :proficiency_band, map_prof_band, to: :proficiency_band_id)
   end


  def config_hash
    {
        source_id: 47,
        state: 'tn'
    }
  end
end

TNTestProcessor20182019TCAPEOC.new(ARGV[0], max: nil).run