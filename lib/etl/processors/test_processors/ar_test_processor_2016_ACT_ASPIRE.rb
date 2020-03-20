require_relative "../test_processor"

class ARTestProcessor2016ACTASPIRE < GS::ETL::TestProcessor

  def initialize(*args)
    super
    @year = 2016
  end

  map_breakdown = {
    'All Students' => 1,
    'Black/African American' => 3,
    'Hispanic' => 6,
    'Asian' => 2,
    'White' => 8,
    'Native American/Alaskan Native' => 4,
    'Native Hawaiian/Pacific Islander' => 112,
    '2 or More Races' => 21,
    'Economically Disadvantaged' => 9,
    'Non-Economically Disadvantaged' => 10,
    'LEP' => 15,
    'Special Education' => 13,
    'Female' => 11,
    'Male' => 12
  }
  map_gsdata_breakdown = {
    'All Students' => 1,
    'Black/African American' => 17,
    'Hispanic' => 19,
    'Asian' => 16,
    'White' => 21,
    'Native American/Alaskan Native' => 18,
    'Native Hawaiian/Pacific Islander' => 20,
    '2 or More Races' => 22,
    'Economically Disadvantaged' => 23,
    'Non-Economically Disadvantaged' => 24,
    'LEP' => 32,
    'Special Education' => 27,
    'Female' => 26,
    'Male' => 25
  }

  map_subject = {
    'English' => 19,
    'Math' => 5,
    'Reading' => 2,
    'Science' => 25,
    'Writing' => 3
  }
  map_gsdata_academic = {
    'English' => 17,
    'Math' => 5,
    'Reading' => 2,
    'Science' => 19,
    'Writing' => 3
  }

  map_prof_band_id = {
    :"in_need_of_support" => 106,
    :"close" => 107,
    :"ready" => 108,
    :"exceeding" => 109,
    :"met_readiness_benchmark" => 'null'
  }
  map_gsdata_prof_band_id = {
    :"in_need_of_support" => 99,
    :"close" => 100,
    :"ready" => 101,
    :"exceeding" => 102,
    :"met_readiness_benchmark" => 1
  }

  source("state_2016.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      entity_level: 'state'
    })
  end
  source("district_2016.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      entity_level: 'district'
    })
  end
  source("school_2016.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      entity_level: 'school'
    })
  end

  shared do |s|
    s.transform("Rename columns", MultiFieldRenamer,
      {
        subgroup: :breakdown,
        grade_level: :grade,
        n: :number_tested,
        district_lea: :district_id,
        school_lea: :school_id
      })
    .transform('Fill missing default fields', Fill, {
      year: 2016,
      entity_type: 'public_charter',
      level_code: 'e,m,h',
      test_data_type: 'ACT Aspire',
      test_data_type_id: 330,
      gsdata_test_data_type_id: 319,
      notes: 'DXT-2837: AR ACT Aspire 2016',
      description: 'In 2015-2016, students in Arkansas took the ACT Aspire. The ACT Aspire is an end-of-year summative assessment that gauges student progression from grades 3 through 10 in English, reading, writing, math, and science. The ACT Aspire is administered to students in grades 3-10 in Arkansas public schools.'
    })
    .transform("Skip number_tested < 10", DeleteRows, :number_tested, 'N<10')
    .transform("Skip subject 3", DeleteRows, :subject, '3')
    .transform('transposing prof bands', Transposer, 
      :proficiency_band, :value_float, :"in_need_of_support",:"close",:"ready",:"exceeding",:"met_readiness_benchmark")
    .transform("Remove white space from subject and leading zero from grade", WithBlock) do |row|
      row[:subject] = row[:subject].strip
      row[:grade] = row[:grade].gsub(/^0/, '')
      row
    end
    .transform("Adding column breakdown_id from breadown", HashLookup, :breakdown, map_breakdown, to: :breakdown_id)
    .transform("Adding column gsdata breakdown_id from breadown", HashLookup, :breakdown, map_gsdata_breakdown, to: :breakdown_gsdata_id)
    .transform("Adding column subject_id from subject", HashLookup, :subject, map_subject, to: :subject_id)
    .transform("Adding column gsdata academics_id from subject", HashLookup, :subject, map_gsdata_academic, to: :academic_gsdata_id)
    .transform("Adding column proficiency_band_id from proficiency band", HashLookup, :proficiency_band, map_prof_band_id, to: :proficiency_band_id)
    .transform("Adding column gsdataproficiency_band_id from proficiency band", HashLookup, :proficiency_band, map_gsdata_prof_band_id, to: :proficiency_band_gsdata_id)
    .transform('Set up state_id',WithBlock) do |row|
      if row[:entity_level] == 'school'
        row[:state_id] = row[:school_id]
      elsif row[:entity_level] == 'district'
        row[:state_id] = row[:district_id]
      else
        row[:state_id] = 'state'
      end
      row
    end
  end

  def config_hash
    {
        source_id: 70,
        gsdata_source_id: 7,
        state: 'ar',
        source_name: 'Arkansas Department of Education',
        date_valid: '2016-01-01 00:00:00',
        url: 'http://www.arkansased.gov/divisions/learning-services/student-assessment/test-scores/year?y=2016',
        file: 'ar/2016/ar.2016.1.public.charter.[level].txt',
        level: nil,
        school_type: 'public,charter'
    }
  end
end

ARTestProcessor2016ACTASPIRE.new(ARGV[0], max: nil).run
