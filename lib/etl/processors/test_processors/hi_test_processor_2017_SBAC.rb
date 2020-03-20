require_relative "../test_processor"

class HITestProcessor2017SBAC < GS::ETL::TestProcessor

  def initialize(*args)
    super
    @year = 2017
  end

  map_breakdown = {
    'All Students' => 1
  }

  map_academic = {
    'Math' => 5,
    'ELA' => 4
  }

  map_prof_band_id = {
    'met/exceeded achievement standard' => 1
  }

  source("school.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      entity_level: 'school'
    })
  end

  source("state.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      entity_level: 'state'
    })
    .transform('total grade',WithBlock,) do |row|
      if row[:grade] == 'TOTAL'
        row[:grade] = 'All'
      end
      row 
    end
  end

  shared do |s|
    s.transform('Fill missing default fields', Fill, {
      breakdown: 'All Students',
      year: 2017,
      entity_type: 'public_charter',
      level_code: 'e,m,h',
      proficiency_band: 'met/exceeded achievement standard',
      test_data_type: 'HI SBAC',
      gsdata_test_data_type_id: 189,
      notes: 'DXT-2960: HI HI SBAC',
      description: 'In 2016-2017, students in HI took the Smarter Balanced Assessments (SBA) in mathematics and English Language Arts/Literacy (ELA). The SBA is aligned to the Hawaii Common Core Standards, and designed to measure whether students are on track for readiness in college and/or career. SBA replaced the Hawaii State Assessment in math and reading. These are mandatory assessments given to students in grades 3-8 and 11.'
    })
    .transform("transpose values by subject",Transposer,:subject,:value_float,:metexceeded_achievement_standard_ela,:metexceeded_achievement_standard_math)
    .transform("remove blank rows",WithBlock) do |row|
      if row[:value_float].nil?
        row[:value_float] = 'skip'
      else
        row[:value_float] = row[:value_float]
      end
      row
    end
    .transform("delete bad values",DeleteRows,:value_float,'*','skip')
    .transform('remove %',WithBlock,) do |row|
      row[:value_float] = row[:value_float].tr('%','')
      row
    end
    .transform("Assign subject", WithBlock) do |row|
      if row[:subject].to_s.include?('math')
        row[:subject] = 'Math'
        row[:number_tested] = row[:n_tested_math].tr('""','').tr(',','')
      elsif row[:subject].to_s.include?('ela')
        row[:subject] = 'ELA'
        row[:number_tested] = row[:n_tested_ela].tr('""','').tr(',','')
      end
      row
    end
    .transform("correct grade values",WithBlock) do |row|
      row[:grade] = row[:grade].gsub("Grade ","")
      row
    end
    .transform("Adding column gsdata breakdown_id from breadown", HashLookup, :breakdown, map_breakdown, to: :breakdown_gsdata_id)
    .transform("Adding column gsdata academics_id from subject", HashLookup, :subject, map_academic, to: :academic_gsdata_id)
    .transform("Adding column gsdataproficiency_band_id from proficiency band", HashLookup, :proficiency_band, map_prof_band_id, to: :proficiency_band_gsdata_id)
  end

  def config_hash
    {
        gsdata_source_id: 15,
        state: 'hi',
        source_name: 'Hawaii Department of Education',
        date_valid: '2017-01-01 00:00:00',
        url: 'http://doe.k12.hi.us/',
        file: 'hi/2017/hi.2017.1.public.charter.[level].txt',
        level: nil,
        school_type: 'public,charter'
    }
  end
end

HITestProcessor2017SBAC.new(ARGV[0], max: nil).run
