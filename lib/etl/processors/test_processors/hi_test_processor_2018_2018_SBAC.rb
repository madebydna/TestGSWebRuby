require_relative "../../test_processor"

class HITestProcessor20182019SBAC < GS::ETL::TestProcessor

  def initialize(*args)
    super
    @year = 2019
    @ticket_n ='DXT-3447'
  end

  map_breakdown = {
    'All Students' => 1
  }

  map_subject = {
    'Mathematics' => 5,
    'English Language Arts' => 4
  }

  map_prof_band_id = {
    'Met/Exceeded Achievement Standard' => 1
  }

  source("hi_2018_2019.txt",[], col_sep: "\t") 

  shared do |s|
    s.transform('Fill missing default fields', Fill, {
      data_type_id: 189,
      notes: 'DXT-3447: HI HI SBAC'
    })
    .transform("Filling in description and date valid", WithBlock) do |row|
      if row[:year] == '2018'
            row[:date_valid] = '2018-01-01 00:00:00'
            row[:description] = 'In 2017-2018, students in Hawaii took the Smarter Balanced Assessments (SBA) in Mathematics and English Language Arts/Literacy (ELA). The SBA is aligned to the Hawaii Common Core Standards, and designed to measure whether students are on track for readiness in college and/or career. SBA replaced the Hawaii State Assessment in math and reading. These are mandatory assessments given to students in grades 3-8 and 11.'

      elsif row[:year] == '2019'
            row[:date_valid] = '2019-01-01 00:00:00'
            row[:description] = 'In 2018-2019, students in Hawaii took the Smarter Balanced Assessments (SBA) in Mathematics and English Language Arts/Literacy (ELA). The SBA is aligned to the Hawaii Common Core Standards, and designed to measure whether students are on track for readiness in college and/or career. SBA replaced the Hawaii State Assessment in math and reading. These are mandatory assessments given to students in grades 3-8 and 11.'
      end
     row
    end
    .transform("Adding column breakdown_id from breadown", HashLookup, :breakdown, map_breakdown, to: :breakdown_id)
    .transform("Adding column subject_id from subject", HashLookup, :subject, map_subject, to: :subject_id)
    .transform("Adding column proficiency_band_id from proficiency band", HashLookup, :proficiency_band, map_prof_band_id, to: :proficiency_band_id)
  end

  def config_hash
    {
        gsdata_source_id: 15,
        state: 'hi'
    }
  end
end

HITestProcessor20182019SBAC.new(ARGV[0], max: nil).run
