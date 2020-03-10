require_relative "../test_processor"

class PATestProcessor2016 < GS::ETL::TestProcessor

  def initialize(*args)
    super
    @year = 2016
  end


  breakdown_id_map = {
    'All Students' => 1,
    'Male' => 12,
    'Female' => 11,
    'Asian (not Hispanic)' => 2,
    'Black or African American (not Hispanic)' => 3,
    'American Indian / Alaskan Native (not Hispanic)' => 4,
    'Hispanic (any race)' => 6,
    'White (not Hispanic)' => 8,
    'Multi-Racial (not Hispanic)' => 21,
    'Native Hawaiian or other Pacific Islander (not Hispanic)' => 112,
    'Economically Disadvantaged' => 9,
    'IEP' => 13,
    'ELL' => 15
  }

  subject_id_map = {
    'English Language Arts' => 4,
    'Math' => 5,
    'Science' => 25,
    'Algebra I' => 7,
    'Biology' => 29,
    'Literature' => 19,
  }

  proficiency_band_id_map = {
    percent_advanced: 81,
    percent_proficient: 80,
    percent_basic: 79,
    percent_below_basic: 78,
    null: 'null'
  }

  source("2016_Keystone_State_cleaned.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      entity_level: 'state',
      test_data_type: 'keystone',
      test_data_type_id: 237,
  })
  end

  source("2016_Keystone_School.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      entity_level: 'school',
      test_data_type: 'keystone',
      test_data_type_id: 237,
  })
  end

  source("2016_Keystone_District_cleaned.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      entity_level: 'district',
      test_data_type: 'keystone',
      test_data_type_id: 237,
  })
  end
  source("2016_PSSA_State.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      entity_level: 'state',
      test_data_type: 'pssa',
      test_data_type_id: 29,
    })
  end

  source("2016_PSSA_School.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      entity_level: 'school',
      test_data_type: 'pssa',
      test_data_type_id: 29
  })
  end

  source("2016_PSSA_District.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      entity_level: 'district',
      test_data_type: 'pssa',
      test_data_type_id: 29
  })
  end



  shared do |s|
    s.transform('Rename column headers', MultiFieldRenamer,{
      group: :breakdown,
      number_scored: :number_tested,
      })
    .transform('Calculate prof null', SumValues, :null, :percent_advanced, :percent_proficient)
    .transform('Fill default fields', Fill, {
      entity_type: 'public_charter',
      level_code: 'e,m,h',
    })
    .transform('Map breakdown_id',HashLookup, :breakdown, breakdown_id_map, to: :breakdown_id)
    .transform('Map subject_id',HashLookup, :subject, subject_id_map, to: :subject_id)
    .transform('Transpose proficiency bands', Transposer,
           :proficiency_band,
           :value_float,
           :percent_advanced,
           :percent_proficient,
           :percent_basic,
           :percent_below_basic,
           :null
           )
    .transform('Map proficiency_band_id',HashLookup, :proficiency_band, proficiency_band_id_map, to: :proficiency_band_id)
    .transform('Set up state_id',WithBlock) do |row|
      if row[:entity_level] == 'school'
        row[:state_id] = row[:school_number][5..-1]
        row[:district_id] = row[:aun]
      elsif row[:entity_level] == 'district'
        row[:state_id] = row[:aun]
      else
        row[:state_id] = 'state'
      end

      row
    end
    .transform('Set grade 11 to grade All and remove 0 padding',WithBlock) do |row|
      row[:grade] = 'All' if row[:grade] == '11'
      row[:grade] = row[:grade].gsub('0','')
      row
    end
    # .transform('test',WithBlock) do |row|
    #   require 'byebug'
    #   byebug
    # end
  end

  def config_hash
    {
        source_id: 11,
        state: 'pa',
        notes: 'DXT-1979: PA PSSA Keystone 2016 test load.',
        url: 'http://www.pde.state.pa.us/',
        file: 'pa/2016/output/pa.2016.1.public.charter.[level].txt',
        level: nil,
        school_type: 'public,charter'
    }
  end
end

PATestProcessor2016.new(ARGV[0], max: nil).run
