require_relative "../../test_processor"

class ORTestProcessor20182019SBACOAKS < GS::ETL::TestProcessor

  def initialize(*args)
    super
    @year = 2019
    @ticket_n = 'DXT-3438'
  end

  map_bd = {
    'American Indian/Alaskan Native' => 18,
    'Asian' => 16,
    'Black/African American' => 17,
    'Econo. Disadvantaged' => 23,
    'Female' => 26,
    'Hispanic/Latino' => 19,
    'English Learners' => 32,
    'LEP' => 32,
    'Male' => 25,
    'Multi-Racial' => 22,
    'Pacific Islander'=> 37,
    'Non-Binary' => 72,
    'Students with Disabilities (SWD)' => 27,
    'Total Population (All Students)' => 1,
    'White' => 21,
     # 'Asian/Pacific Islander' => 15
  }

  map_sub = {
    'English Language Arts' => 4,
    'Mathematics' => 5,
    'Science' => 19
  }

  map_prof = {
    "percent_level_1" => 5,
    "percent_level_2" => 6,
    "percent_level_3" => 7,
    "percent_level_4" => 8,
    "percent_proficient_level_3_or_4" => 1,
    "science_percent_level_1" => 13,
    "science_percent_level_2" => 14,
    "science_percent_level_3" => 15,
    "science_percent_level_4" => 16,
    "science_percent_level_5" => 17,
    "science_percent_proficient_level_4_or_5" => 1,
  }


  source("or_2018_2019.txt",[], col_sep: "\t")
  
  
  shared do |s|
    s.transform("set data type date valid notes and description", WithBlock) do |row|
        if row[:data_type] == 'OAKS'
          row[:data_type_id] = 250
          row[:notes] = 'DXT-3438: OR OAKS'
          row[:year] == '2018'
          row[:date_valid] ='2018-01-01 00:00:00'
          row[:description] = 'In 2017-2018 Oregon used the Oregon Assessment of Knowledge and Skills (OAKS) to test students in grades 5, 8 and 11 in science.  The OAKS is a standards-based test, which means it measures how well students are mastering specific skills defined for each grade by the state of Oregon.  The goal is for all students to score at or above the state standard.'         
        elsif row[:data_type] == 'OR SBAC'
          row[:data_type_id] = 251
          row[:notes] = 'DXT-3438: OR SBAC'
            if row[:year] == '2018'
              row[:date_valid] ='2018-01-01 00:00:00'
              row[:description] = 'In 2017-18, Oregon administered state assessments to students. Oregon\'s Statewide Assessment System (OSAS) currently includes summative assessments administered annually by subject matter and grade. Pursuant to federal and state accountability requirements, Oregon public schools test students in English language arts and math in grades 3 through 8 & 11.'    
            elsif row[:year] == '2019'
              row[:date_valid] ='2019-01-01 00:00:00'
              row[:description] = 'In 2018-2019, Tennessee used the Gateway/End-of-Course (EOC) exams to test high school students in language arts, math, science, and social studies upon completion of relevant courses. The Gateway/EOC exams are standards-based tests that measure how well students are mastering specific skills defined by the state of Tennessee. The goal is for all students to score at or above the proficient level.'
            end
        end
        row
      end 
    .transform("Adding column breakdown_id from breadown", HashLookup, :breakdown, map_bd, to: :breakdown_id)
    .transform("Adding column subject_id from subject", HashLookup, :subject, map_sub, to: :subject_id)
    .transform("Adding column_id from proficiency band", HashLookup, :proficiency_band, map_prof, to: :proficiency_band_id)
  end

  def config_hash
    {
        gsdata_source_id: 42,
        state: 'or'
    }
  end
end

ORTestProcessor20182019SBACOAKS.new(ARGV[0], max: nil).run