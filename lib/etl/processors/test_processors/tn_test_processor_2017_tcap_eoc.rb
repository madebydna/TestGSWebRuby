require_relative "../test_processor"

class TNTestProcessor2017TCAPEOC < GS::ETL::TestProcessor

  def initialize(*args)
    super
    @year = 2017
  end

  map_breakdown = {
    'All Students' => 1,
    'Black or African American' => 3,
    'American Indian or Alaska Native' => 4,
    'Asian' => 2,
    'White' => 8,
    'Economically Disadvantaged' => 9,
    'Non-Economically Disadvantaged' => 10,
    'English Learners' => 15,
    'Non-English Learners' => 16,
    'Hispanic' => 6,
    'Students with Disabilities' => 13,
    'Non-Students with Disabilities' => 14,
    'Native Hawaiian or Other Pacific Islander' => 112
  }
  map_gsdata_breakdown = {
    'All Students' => 1,
    'Black or African American' => 17,
    'American Indian or Alaska Native' => 18,
    'Asian' => 16,
    'White' => 21,
    'Economically Disadvantaged' => 23,
    'Non-Economically Disadvantaged' => 24,
    'English Learners' => 32,
    'Non-English Learners' => 33,
    'Hispanic' => 19,
    'Students with Disabilities' => 27,
    'Non-Students with Disabilities' => 30,
    'Native Hawaiian or Other Pacific Islander' => 20
  }

  map_subject = {
    'ELA' => 4,
    'Math' => 5,
    'Science' => 25,
    'Algebra I' => 7,
    'Algebra II' => 11,
    'Geometry' => 9,
    'Biology I' => 29,
    'Chemistry' => 42,
    'English I' => 19,
    'English II' => 27,
    'English III' => 63,
    'Integrated Math I' => 8,
    'Integrated Math II' => 10,
    'Integrated Math III' => 12,
    'US History' => 30
   }
  map_gsdata_academic = {
    'ELA' => 4,
    'Math' => 5,
    'Science' => 19,
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

  # map_prof_band_id = {
  #   :"pct_below" => 78,
  #   :"pct_approaching" => 79,
  #   :"pct_on_track" => 80,
  #   :"pct_mastered" => 81,
  #   :"pct_on_mastered" => 'null'
  # }
  # map_gsdata_prof_band_id = {
  #   :"pct_below" => 79,
  #   :"pct_approaching" => 80,
  #   :"pct_on_track" => 81,
  #   :"pct_mastered" => 82,
  #   :"pct_on_mastered" => 1
  # }

  source("state_tn.txt",[], col_sep: "\t") do |s|
   s.transform('Fill missing default fields', Fill, {
     entity_level: 'state'
   })
  end
  # source("district_tn.txt",[], col_sep: "\t") do |s|
  #   s.transform('Fill missing default fields', Fill, {
  #     entity_level: 'district'
  #   })
  # end
  # source("school_tn.txt",[], col_sep: "\t") do |s|
  #   s.transform('Fill missing default fields', Fill, {
  #     entity_level: 'school'
  #   })
  # end

  shared do |s|
    s.transform("Rename columns", MultiFieldRenamer,
      {
        system: :district_id,
        school: :school_id,
        testadministration: :test_data_type,
        gradelevel: :grade,
        subgroup: :breakdown,
        valid_tests: :number_tested,
        pct_on_mastered: :value_float
      })
      .transform('Fill missing default fields', Fill, {
        entity_type: 'public_charter',
        level_code: 'e,m,h',
        year: 2017,
        proficiency_band: 'null',
        proficiency_band_id: 'null',
        proficiency_band_gsdata_id: 1
      })
      .transform("delete breadkowns",DeleteRows, :breakdown, 'Non-Black/Hispanic/Native American','Black/Hispanic/Native American','English Learners with T1/T2','Non-English Learners/T1 or T2','Super Subgroup')
      .transform("Removing * and ** values", DeleteRows,:value_float,'*','**')
      .transform("Removing 0 school_id", DeleteRows,:school_id,'0')      
      .transform("source", WithBlock) do |row|
        if row[:subject] == 'ELA' or row[:subject] == 'Math' or row[:subject] == 'Science'
          row[:test_data_type] = 'tcap'
          row[:test_data_type_id] = 84
          row[:gsdata_test_data_type_id] = 257
          row[:notes] = 'DXT-2687: TN TCAP'
          row[:description] = 'In 2016-2017 Tennessee used the Tennessee Comprehensive Assessment Program (TCAP) Achievement Test to test students in grades 3 through 8 in reading/language arts, math, science and social studies. The TCAP is a standards-based test that measures specific skills defined for each grade by the state of Tennessee. The goal is for all students to score at or above the proficient level.'        
          row[:grade] = 'All' if row[:grade] == 'All Grades'
        elsif row[:grade] != 'All Grades'
          row[:grade] = 'skip'
        else
          row[:test_data_type] = 'eoc'
          row[:test_data_type_id] = 103
          row[:gsdata_test_data_type_id] = 258
          row[:notes] = 'DXT-2687: TN GATEWAY'
          row[:description] = 'In 2016-2017 Tennessee used the Gateway/End-of-Course (EOC) exams to test high school students in language arts, math, science, and social studies upon completion of relevant courses. Students must pass the algebra I, English II, and biology I tests, called the Gateway exams, in order to graduate. The Gateway/EOC exams are standards-based tests that measure how well students are mastering specific skills defined by the state of Tennessee. The goal is for all students to score at or above the proficient level.'
          row[:grade] = 'All'
        end
        row
      end 
      .transform("Removing non all grade for eoc", DeleteRows,:grade,'skip')
      .transform("map subject ids", HashLookup, :subject, map_subject, to: :subject_id)
      .transform("map breakdown id",HashLookup, :breakdown, map_breakdown, to: :breakdown_id)
      .transform('map breakdowns', HashLookup, :breakdown, map_gsdata_breakdown, to: :breakdown_gsdata_id)
      .transform('map subjects', HashLookup, :subject, map_gsdata_academic, to: :academic_gsdata_id) 
      .transform("state_id", WithBlock) do |row|
        grade = gsub((/^0/, ''))
        row
      end
   end
end
  def config_hash
    {
        gsdata_source_id: 34,
        state: 'tn',
        source_name: 'Tennessee Department of Education',
        date_valid: '2017-01-01 00:00:00',
        url: 'http://www.tn.gov/education/topic/data-downloads',
        file: 'tn/2017/tn.2017.1.public.charter.[level].txt',
        level: nil,
        school_type: 'public,charter'
    }
  end
end

TNTestProcessor2017TCAPEOC.new(ARGV[0], max: nil).run