require_relative "../test_processor"

class COTestProcessor2018CMASEOC < GS::ETL::TestProcessor

  def initialize(*args)
    super
    @year = 2018
  end

  map_gsdata_breakdown = {
    'All Students' => 1,
    # 'Black/African American' => 17,
    # 'Hispanic' => 19,
    # 'Asian' => 16,
    # 'White' => 21,
    # 'Native American/Alaskan Native' => 18,
    # 'Native Hawaiian/Pacific Islander' => 20,
    # '2 or More Races' => 22,
    # 'Economically Disadvantaged' => 23,
    # 'Non-Economically Disadvantaged' => 24,
    # 'LEP' => 32,
    # 'Special Education' => 27,
    # 'Female' => 26,
    # 'Male' => 25
  }

  map_gsdata_academic = {
    'English Language Arts' => 4,
    'Mathematics' => 5,
    'Algebra I' => 6,
    'Geometry' => 8,
    'Integrated I' => 7,
    'Integrated II' => 9,
    'Science' => 19
  }

  map_gsdata_prof_band_id = {
    'p_met_or_exceeded_expectations' => 1
  }

  source("all_math_ela.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      breakdown: 'All Students'
    })
  end
  source("all_science.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      breakdown: 'All Students',
      subject: 'Science'
    })
  end

  shared do |s|
    s.transform("Rename columns", MultiFieldRenamer,
      {
        test_grade: :grade,
        content: :subject,
        n_of_valid_scores: :number_tested,
        district_code: :district_id,
        school_code: :school_id,
        level: :entity_level,
        p_met_or_exceeded_expectations: :value_float
      })
    .transform('Fill missing default fields', Fill, {
      year: 2018,
      entity_type: 'public_charter',
      level_code: 'e,m,h',
      proficiency_band: 'p_met_or_exceeded_expectations',
      test_data_type: 'CMAS',
      gsdata_test_data_type_id: 210,
      notes: 'DXT-2853: CO CMAS',
      description: 'In 2017-2018, students in Colorado took the CMAS assessment for English Language Arts, Math, and Science.'
    })
    .transform("Skip number_tested < 16", DeleteRows, :number_tested, '< 16')
    .transform("Assign grade and sbueject", WithBlock) do |row|
      if row[:grade].include?('Mathematics') or row[:grade].include?('English Language Arts') 
        row[:grade] = row[:grade][-1]
      elsif row[:grade] == 'All Grades'
        row[:grade] = 'All'
      elsif row[:grade].include?('Science') 
        if row[:grade] == 'Science HS'
          row[:grade] = '11'
        else
          row[:grade] = row[:grade][-1]
        end
      else
        row[:subject] = row[:grade]
        row[:grade] = 'All'
      end
      row
    end
    .transform("Adding column gsdata breakdown_id from breadown", HashLookup, :breakdown, map_gsdata_breakdown, to: :breakdown_gsdata_id)
    .transform("Adding column gsdata academics_id from subject", HashLookup, :subject, map_gsdata_academic, to: :academic_gsdata_id)
    .transform("Adding column gsdataproficiency_band_id from proficiency band", HashLookup, :proficiency_band, map_gsdata_prof_band_id, to: :proficiency_band_gsdata_id)
    .transform('Set up state_id',WithBlock) do |row|
      row[:entity_level] = row[:entity_level].downcase()
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
        gsdata_source_id: 9,
        state: 'co',
        source_name: 'Colorado Department of Education',
        date_valid: '2018-01-01 00:00:00',
        url: 'http://www.cde.state.co.us/',
        file: 'co/2018/ar.2018.1.public.charter.[level].txt',
        level: nil,
        school_type: 'public,charter'
    }
  end
end

COTestProcessor2018CMASEOC.new(ARGV[0], max: nil).run
