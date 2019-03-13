equire_relative "../test_processor"

class ORTestProcessor2017SBACOAKS < GS::ETL::TestProcessor

  def initialize(*args)
    super
    @year = 2017
  end

  key_map_bd = {
    'American Indian/Alaskan Native' => 4,
    'Asian' => 2,
    'Black/African American' => 3,
    'Econo. Disadvantaged' => 9,
    'Female' => 11,
    'Hispanic/Latino' => 6,
    'English Learners' => 15,
    'Male' => 12,
    'Multi-Racial' => 21,
    'Pacific Islander'=> 7,
    'Students with Disabilities (SWD)' => 13,
    'Total Population (All Students)' => 1,
    'White' => 8,
    'Asian/Pacific Islander' => 22
  }

  key_map_sub = {
    'English Language Arts' => 4,
    'Mathematics' => 5,
    'Science' => 25
  }

  sbac_key_map_pro = {
    :"percent_level_1" => 5,
    :"percent_level_2" => 6,
    :"percent_level_3" => 7,
    :"percent_level_4" => 8,
    :"percent_proficient_(level_3_or_4)" => 1,
  }

  oaks_key_map_pro = {
    :"percent_level_1" => 13,
    :"percent_level_2" => 14,
    :"percent_level_3" => 15,
    :"percent_level_4" => 16,
    :"percent_level_5" => 17,
    :"percent_proficient_(level_4_or_5)" => 1,
  }

  source("pagr_schools_.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      test_data_type_id: 251,
      test_data_type: 'OR SBAC',
      entity_level: :school
      description: 'Oregon now has K-12 learning standards aligned with the expectations of colleges and employers. These standards are designed to provide students with the knowledge and skills they need at each step along their educational journey so they can graduate high school prepared for future success. These tests move beyond the rote memorization and fill in the bubble format of past multiple choice tests. Students were asked to write, reason, think critically, and solve multi-step problems that better reflect classroom learning and the real world. Students who receive a 3 or 4 on the test (on a 4-point scale) are considered on track to graduate high school college- and career-ready. Those who receive a 1 or a 2 will receive additional support to help them reach this new higher standard.'
  })
  end
  source("pagr_State_SCIENCE_1617.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
        test_data_type: 'OAKS',
        test_data_type_id: 250,
        entity_level: :state
    })
    .transform('Transpose value columns', Transposer,
       :proficiency_band,
       :value_float,
       :"percent_level_1",
       :"percent_level_2",
       :"percent_level_3",
       :"percent_level_4",
       :"percent_level_5"
       :"percent_proficient_(level_4_or_5)"
      )
    .transform("Adding column_id from proficiency band", HashLookup, :proficiency_band, oaks_key_map_pro, to: :proficiency_band_id)
  end
  source("pagr_Districts_SCIENCE_1617.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
        test_data_type: 'OAKS',
        test_data_type_id: 250,
        entity_level: :district,
        percent_proficient_(level_3_or_4): :percent_proficient_(level_4_or_5)
    })
    .transform('Calculate Prof and Above', WithBlock,) do |row|
      row[:percent_proficient_(level_4_or_5)]=row[:percent_level_5]+row[:percent_level_4]
    .transform('Transpose value columns', Transposer,
       :proficiency_band,
       :value_float,
       :"percent_level_1",
       :"percent_level_2",
       :"percent_level_3",
       :"percent_level_4",
       :"percent_level_5"
       :"percent_proficient_(level_4_or_5)"
      )
    .transform("Adding column_id from proficiency band", HashLookup, :proficiency_band, oaks_key_map_pro, to: :proficiency_band_id)
  end
  source("pagr_school_science_raceethnicity_1617.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
        test_data_type: 'OAKS',
        test_data_type_id: 250,
        entity_level: :school
    })
    .transform('Transpose value columns', Transposer,
       :proficiency_band,
       :value_float,
       :"percent_level_1",
       :"percent_level_2",
       :"percent_level_3",
       :"percent_level_4",
       :"percent_level_5"
       :"percent_proficient_(level_4_or_5)"
      )
    .transform("Adding column_id from proficiency band", HashLookup, :proficiency_band, oaks_key_map_pro, to: :proficiency_band_id)
  end
  source("pagr_school_science_tot_othergroups_1617.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
        test_data_type: 'OAKS',
        test_data_type_id: 250,
        entity_level: :school
    })
    .transform('Transpose value columns', Transposer,
       :proficiency_band,
       :value_float,
       :"percent_level_1",
       :"percent_level_2",
       :"percent_level_3",
       :"percent_level_4",
       :"percent_level_5"
       :"percent_proficient_(level_4_or_5)"
      )
    .transform("Adding column_id from proficiency band", HashLookup, :proficiency_band, oaks_key_map_pro, to: :proficiency_band_id)
  end
  shared do |s|
    s.transform("Renaming fields",
      MultiFieldRenamer,
      {
        district: :district_name,
        school: :school_name,
        student_group: :breakdown,
        grade_level: :grade,
        number_of_participants: :number_tested
      })
    .transform('Transpose value columns', Transposer,
       :proficiency_band,
       :value_float,
       :"percent_level_1",
       :"percent_level_2",
       :"percent_level_3",
       :"percent_level_4",
       :"percent_proficient_(level_3_or_4)"
      )
    .transform("Adding column_id from proficiency band", HashLookup, :proficiency_band, key_map_pro, to: :proficiency_band_id)
    .transform("Remove suppressed bands", DeleteRows, :value_float, '-', '--', '*')
    .transform("Remove weird breakdowns", DeleteRows, :breakdown, 'Extended Assessment', 'Indian Education', 'Migrant Education', 'SWD with Accommodations','Talented and Gifted (TAG)')
    .transform("Delete rows where number tested is less than 10 ",DeleteRows, :number_tested, '0','1','2','3','4','5','6','7','8','9')
    .transform('Fill missing default fields', Fill, {
      year: 2017,
      entity_type: 'public_charter',
      level_code: 'e,m,h',
      notes: 'DXT-2651: OR SBAC and OAKS Science 2017 test load.',
    })
    .transform("Prof special cases", WithBlock,) do |row|
      if row[:value_float] == '> 95.0%'
        row[:value_float] = '95'
        row[:number_tested] = ''
      elsif row[:value_float] == '< 5.0%'
        row[:value_float] = '5'
        row[:number_tested] = ''
      end
      row
    end
    .transform("Adding column breakdown_id from breadown", HashLookup, :breakdown, key_map_bd, to: :breakdown_id)
    .transform("Adding column subject_id from subject",
      HashLookup, :subject, key_map_sub, to: :subject_id)
    .transform("Edit grade", WithBlock,) do |row|
      if row[:grade] == 'All Grades'
        row[:grade] = 'All'
      else
        row[:grade] = row[:grade].gsub(/[^\d]/, '')
      end
      row
    end
    .transform("Creating StateID", WithBlock) do |row|
      if row[:school_id] == 'district'
        row[:entity_level] ='district'
        row[:state_id] = row[:district_id].rjust(14,'0')
      elsif row[:school_id] == 'state'
        row[:entity_level] ='state'
      else
        row[:entity_level] ='school'
        row[:district_id] = row[:district_id].rjust(14,'0')
        row[:state_id] = row[:school_id].rjust(20,'0')
      end
      row
    end
    .transform('Fill missing ids and names with entity_level', WithBlock) do |row|
      [:state_id, :school_id, :district_id, :school_name, :district_name].each do |col|
        row[col] ||= row[:entity_level]
      end
      row
    end
  end

  def config_hash
    {
        source_id: 42,
        state: 'or',
        source_name: 'Oregon Department of Education',
        date_valid: '2017-01-01 00:00:00',
        url: 'http://www.ode.state.or.us',
        file: 'or/2017/output/or.2017.1.public.charter.[level].txt',
        level: nil,
        school_type: 'public,charter'
    }
  end
end

ORTestProcessor2017SBACOAKS.new(ARGV[0], max: nil).run