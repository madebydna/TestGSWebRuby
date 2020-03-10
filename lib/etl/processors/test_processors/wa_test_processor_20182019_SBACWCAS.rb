require_relative "../test_processor"

class WATestProcessor20182019SBACWCAS < GS::ETL::TestProcessor

  def initialize(*args)
    super
    @year = 2019
  end


  map_breakdown = {
     'All Students' => 1,
     'Black/ African American' => 17,
     'Hispanic/ Latino of any race(s)' => 19,
     'Asian' => 16,
     'White' => 21,
     'American Indian/ Alaskan Native' => 18,
     'Native Hawaiian/ Other Pacific Islander' => 20,
     'Two or More Races' => 22,
     'Low-Income' => 23,
     'Non-Low Income' => 24,
     'English Language Learners' => 32,
     'Non-English Language Learners' => 33,
     'Students with Disabilities' => 27,
     'Female' => 26,
     'Male' => 25,
      'Students without Disabilities' => 30
  }

  map_subject = {
    'Math' => 5,
    'English Language Arts' => 4,
    'Science' => 19
  }

  
  source("tidy_1819.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      proficiency_band_id: 1
    })
    .transform('Rename column headers', MultiFieldRenamer,{
      prof_above: :value,
      test_subject: :subject,
      student_group: :breakdown
    })
    .transform('Add test details', WithBlock) do |row|
      if row[:subject] == 'Science'
        if row[:year] == '2018'
          row[:date_valid] = '2018-01-01 00:00:00'
          row[:description] = 'In 2017-18, the state of Washington introduced the Washington Comprehensive Assessment of Science (WCAS) that measures the level of proficiency that Washington students have achieved based on the Washington State 2013 K-12 Science Learning Standards, which are the Next Generation Science Standards (NGSS). All students are assessed on their knowledge of the standards through the WCAS in grades 5, 8, and 11. The tests fulfill the federal Every Student Succeeds Act (ESSA) requirement that students be tested in science once at each level: elementary, middle, and high school.'
        elsif row[:year] == '2019'
          row[:date_valid] = '2019-01-01 00:00:00'
          row[:description] = 'In 2018-19, the state of Washington administered the Washington Comprehensive Assessment of Science (WCAS) that measures the level of proficiency that Washington students have achieved based on the Washington State 2013 K-12 Science Learning Standards, which are the Next Generation Science Standards (NGSS). All students are assessed on their knowledge of the standards through the WCAS in grades 5, 8, and 11. The tests fulfill the federal Every Student Succeeds Act (ESSA) requirement that students be tested in science once at each level: elementary, middle, and high school.'
        end
      elsif row[:subject] == 'English Language Arts' || row[:subject] == 'Math'
        if row[:year] == '2018'
          row[:date_valid] = '2018-01-01 00:00:00'
          row[:description] = 'In 2017-18, WA tested students in English and Math with the Smarter Balanced Assessment. Smarter Balanced tests align to the new K-12 learning standards in English language arts and math (Common Core), which are more difficult than previous standards.'
        elsif row[:year] == '2019'
          row[:date_valid] = '2019-01-01 00:00:00'
          row[:description] = 'In 2018-19, WA tested students in English and Math with the Smarter Balanced Assessment. Smarter Balanced tests align to the new K-12 learning standards in English language arts and math (Common Core), which are more difficult than previous standards.'
        end
      end
      row
    end 
    .transform('Add test subject and data_type', WithBlock) do |row|
      if row[:subject] == 'Science'
        row[:test_data_type] = 'WCAS'
        row[:test_data_type_id] = 492
        row[:notes] = 'DXT-3412: WA WCAS'
      elsif row[:subject] == 'English Language Arts' || row[:subject] == 'Math'
        row[:test_data_type] = 'SBAC'
        row[:test_data_type_id] = 311     
        row[:notes] = 'DXT-3412: WA SBAC'
      end
      row
    end 
    .transform("Adding column breakdown_id from breakdown", HashLookup, :breakdown, map_breakdown, to: :breakdown_id)
    .transform("Adding column subject_id from subject", HashLookup, :subject, map_subject, to: :subject_id)
  end


  def config_hash
    {
        source_id: 52,
        state: 'wa'
    }
  end
end

WATestProcessor20182019SBACWCAS.new(ARGV[0], max: nil).run
