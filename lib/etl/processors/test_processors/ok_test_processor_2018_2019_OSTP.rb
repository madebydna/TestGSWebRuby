require_relative "../../test_processor"

class OKTestProcessor20182019OSTP < GS::ETL::TestProcessor

  def initialize(*args)
    super
    @year = 2019
    @ticket_n ='DXT-3458'
  end

    map_breakdown = {
     'All' => 1,
     'Black' => 17,
     'American Indian' => 18,
     'Asian' => 16,
     'White' => 21,
     'Economically Disadvantaged' => 23,
     'English Language Learners' => 32, 
     'Female' => 26,
     'Hispanic' => 19,
     'Male' => 25,
     'Students with Disabilities' => 27, 
     'Two or More Races' => 22
   }

   map_subject = {
     'ELA' => 2,
     'Mathematics' => 5,
     'Science' => 19
   }


    map_prof_band_id = {
      "prof and above" => 1
  }

  source("ok_2018_2019.txt",[],col_sep: "\t") 

  shared do |s|
    s.transform('Fill missing default fields', Fill, {
      data_type_id: '363',
      notes: 'DXT-3458: OK OSTP'
    })
    .transform("Adding column breakdown_id from group",
      HashLookup, :breakdown, map_breakdown, to: :breakdown_id)
    .transform("Filling in subject ids",
    HashLookup, :subject, map_subject, to: :subject_id)
    .transform("Filling in prof band ids",
    HashLookup, :proficiency_band, map_prof_band_id, to: :proficiency_band_id)
    .transform("Filling in description", WithBlock) do |row|
      if row[:year] == '2018'
            row[:date_valid] = '2018-01-01 00:00:00'
            row[:description] = 'In 2017-18, the Oklahoma State Department of Education administered assessments through the Oklahoma School Testing Program (OSTP) to provide evidence of student proficiency of grade-level standards to inform progress toward career- and college-readiness (CCR) and support student and school accountability. State assessment scores provide a reliable measure that can be compared across schools and districts by serving as a point-in-time snapshot of what students know and can do relative to the Oklahoma Academic Standards. The OSTP was administered to students in English Language Arts and Mathematics in grades 3-8, and grade 11. The test was also administered to students in Science in grades 5, 8, and 11.'
      elsif row[:year] == '2019'
            row[:date_valid] = '2019-01-01 00:00:00'
            row[:description] = 'In 2018-19, the Oklahoma State Department of Education administered assessments through the Oklahoma School Testing Program (OSTP) to provide evidence of student proficiency of grade-level standards to inform progress toward career- and college-readiness (CCR) and support student and school accountability. State assessment scores provide a reliable measure that can be compared across schools and districts by serving as a point-in-time snapshot of what students know and can do relative to the Oklahoma Academic Standards. The OSTP was administered to students in English Language Arts and Mathematics in grades 3-8, and grade 11. The test was also administered to students in Science in grades 5, 8, and 11.'
      end
     row
    end
  end

  def config_hash
    {
      source_id: 41,
      state: 'ok'
    }
  end
end

OKTestProcessor20182019OSTP.new(ARGV[0], max: nil).run