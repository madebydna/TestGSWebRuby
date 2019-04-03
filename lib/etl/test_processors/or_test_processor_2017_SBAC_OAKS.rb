require_relative "../test_processor"
GS::ETL::Logging.disable

class ORTestProcessor2017SBACOAKS < GS::ETL::TestProcessor

  def initialize(*args)
    super
    @year = 2017
  end

  key_map_bd = {
    'American Indian/Alaskan Native' => 18,
    'Asian' => 16,
    'Black/African American' => 17,
    'Econo. Disadvantaged' => 23,
    'Female' => 26,
    'Hispanic/Latino' => 19,
    'English Learners' => 32,
    'Male' => 25,
    'Multi-Racial' => 22,
    'Pacific Islander'=> 37,
    'Students with Disabilities (SWD)' => 27,
    'Total Population (All Students)' => 1,
    'White' => 21,
    # 'Asian/Pacific Islander' => 15
  }

  key_map_sub = {
    'English Language Arts' => 4,
    'Mathematics' => 5,
    'Science' => 19
  }

  sbac_key_map_pro = {
    :"percent_level_1" => 5,
    :"percent_level_2" => 6,
    :"percent_level_3" => 7,
    :"percent_level_4" => 8,
    :"percent_proficient_level_3_or_4" => 1,
  }

  oaks_key_map_pro = {
    :"percent_level_1" => 13,
    :"percent_level_2" => 14,
    :"percent_level_3" => 15,
    :"percent_level_4" => 16,
    :"percent_level_5" => 17,
    :"percent_proficient_level_4_or_5" => 1,
  }

  source("pagr_schools_ela_all_1617.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      gsdata_test_data_type_id: 251,
      test_data_type: 'OR SBAC',
      entity_level: 'school', 
      notes: 'DXT-2651: OR SBAC',
      description: 'Oregon now has K-12 learning standards aligned with the expectations of colleges and employers. These standards are designed to provide students with the knowledge and skills they need at each step along their educational journey so they can graduate high school prepared for future success. These tests move beyond the rote memorization and fill in the bubble format of past multiple choice tests. Students were asked to write, reason, think critically, and solve multi-step problems that better reflect classroom learning and the real world. Students who receive a 3 or 4 on the test (on a 4-point scale) are considered on track to graduate high school college- and career-ready. Those who receive a 1 or a 2 will receive additional support to help them reach this new higher standard.'
    })
    .transform('Transpose value columns', Transposer,
       :proficiency_band,
       :value_float,
       :"percent_level_1",
       :"percent_level_2",
       :"percent_level_3",
       :"percent_level_4",
       :"percent_proficient_level_3_or_4"
      )
    .transform("Adding column_id from proficiency band", HashLookup, :proficiency_band, sbac_key_map_pro, to: :proficiency_band_gsdata_id)
    # .transform('test',WithBlock) do |row|
    #    row
    #    require 'byebug'
    #    byebug
    #  end   
  end

  source("pagr_schools_ela_raceethnicity_1617.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      gsdata_test_data_type_id: 251,
      test_data_type: 'OR SBAC',
      entity_level: 'school', 
      notes: 'DXT-2651: OR SBAC',
      description: 'Oregon now has K-12 learning standards aligned with the expectations of colleges and employers. These standards are designed to provide students with the knowledge and skills they need at each step along their educational journey so they can graduate high school prepared for future success. These tests move beyond the rote memorization and fill in the bubble format of past multiple choice tests. Students were asked to write, reason, think critically, and solve multi-step problems that better reflect classroom learning and the real world. Students who receive a 3 or 4 on the test (on a 4-point scale) are considered on track to graduate high school college- and career-ready. Those who receive a 1 or a 2 will receive additional support to help them reach this new higher standard.'
    })
    .transform('Transpose value columns', Transposer,
       :proficiency_band,
       :value_float,
       :"percent_level_1",
       :"percent_level_2",
       :"percent_level_3",
       :"percent_level_4",
       :"percent_proficient_level_3_or_4"
      )
    .transform("Adding column_id from proficiency band", HashLookup, :proficiency_band, sbac_key_map_pro, to: :proficiency_band_gsdata_id)
  end
  
  source("pagr_schools_ela_tot_ecd_ext_gnd_lep_1617.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      gsdata_test_data_type_id: 251,
      test_data_type: 'OR SBAC',
      entity_level: 'school', 
      notes: 'DXT-2651: OR SBAC',
      description: 'Oregon now has K-12 learning standards aligned with the expectations of colleges and employers. These standards are designed to provide students with the knowledge and skills they need at each step along their educational journey so they can graduate high school prepared for future success. These tests move beyond the rote memorization and fill in the bubble format of past multiple choice tests. Students were asked to write, reason, think critically, and solve multi-step problems that better reflect classroom learning and the real world. Students who receive a 3 or 4 on the test (on a 4-point scale) are considered on track to graduate high school college- and career-ready. Those who receive a 1 or a 2 will receive additional support to help them reach this new higher standard.'
    })
    .transform('Transpose value columns', Transposer,
       :proficiency_band,
       :value_float,
       :"percent_level_1",
       :"percent_level_2",
       :"percent_level_3",
       :"percent_level_4",
       :"percent_proficient_level_3_or_4"
      )
   .transform("Adding column_id from proficiency band", HashLookup, :proficiency_band, sbac_key_map_pro, to: :proficiency_band_gsdata_id)
  end

  source("pagr_schools_ela_ine_mig_swa_swd_tag_1617.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      gsdata_test_data_type_id: 251,
      test_data_type: 'OR SBAC',
      entity_level: 'school', 
      notes: 'DXT-2651: OR SBAC',
      description: 'Oregon now has K-12 learning standards aligned with the expectations of colleges and employers. These standards are designed to provide students with the knowledge and skills they need at each step along their educational journey so they can graduate high school prepared for future success. These tests move beyond the rote memorization and fill in the bubble format of past multiple choice tests. Students were asked to write, reason, think critically, and solve multi-step problems that better reflect classroom learning and the real world. Students who receive a 3 or 4 on the test (on a 4-point scale) are considered on track to graduate high school college- and career-ready. Those who receive a 1 or a 2 will receive additional support to help them reach this new higher standard.'
    })
    .transform('Transpose value columns', Transposer,
       :proficiency_band,
       :value_float,
       :"percent_level_1",
       :"percent_level_2",
       :"percent_level_3",
       :"percent_level_4",
       :"percent_proficient_level_3_or_4"
      )
    .transform("Adding column_id from proficiency band", HashLookup, :proficiency_band, sbac_key_map_pro, to: :proficiency_band_gsdata_id)
  end

  source("pagr_Districts_ELA_1617.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      gsdata_test_data_type_id: 251,
      test_data_type: 'OR SBAC',
      entity_level: 'district', 
      notes: 'DXT-2651: OR SBAC',
      description: 'Oregon now has K-12 learning standards aligned with the expectations of colleges and employers. These standards are designed to provide students with the knowledge and skills they need at each step along their educational journey so they can graduate high school prepared for future success. These tests move beyond the rote memorization and fill in the bubble format of past multiple choice tests. Students were asked to write, reason, think critically, and solve multi-step problems that better reflect classroom learning and the real world. Students who receive a 3 or 4 on the test (on a 4-point scale) are considered on track to graduate high school college- and career-ready. Those who receive a 1 or a 2 will receive additional support to help them reach this new higher standard.'
    })
    .transform('Transpose value columns', Transposer,
       :proficiency_band,
       :value_float,
       :"percent_level_1",
       :"percent_level_2",
       :"percent_level_3",
       :"percent_level_4",
       :"percent_proficient_level_3_or_4"
      )
    .transform("Adding column_id from proficiency band", HashLookup, :proficiency_band, sbac_key_map_pro, to: :proficiency_band_gsdata_id)
  end

  source("pagr_State_ELA_1617.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      gsdata_test_data_type_id: 251,
      test_data_type: 'OR SBAC',
      entity_level: 'state', 
      notes: 'DXT-2651: OR SBAC',
      description: 'Oregon now has K-12 learning standards aligned with the expectations of colleges and employers. These standards are designed to provide students with the knowledge and skills they need at each step along their educational journey so they can graduate high school prepared for future success. These tests move beyond the rote memorization and fill in the bubble format of past multiple choice tests. Students were asked to write, reason, think critically, and solve multi-step problems that better reflect classroom learning and the real world. Students who receive a 3 or 4 on the test (on a 4-point scale) are considered on track to graduate high school college- and career-ready. Those who receive a 1 or a 2 will receive additional support to help them reach this new higher standard.'
    })
    .transform('Transpose value columns', Transposer,
       :proficiency_band,
       :value_float,
       :"percent_level_1",
       :"percent_level_2",
       :"percent_level_3",
       :"percent_level_4",
       :"percent_proficient_level_3_or_4"
      )
    .transform("Adding column_id from proficiency band", HashLookup, :proficiency_band, sbac_key_map_pro, to: :proficiency_band_gsdata_id)
  end

  source("pagr_schools_MATH_all_1617.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      gsdata_test_data_type_id: 251,
      test_data_type: 'OR SBAC',
      entity_level: 'school', 
      notes: 'DXT-2651: OR SBAC',
      description: 'Oregon now has K-12 learning standards aligned with the expectations of colleges and employers. These standards are designed to provide students with the knowledge and skills they need at each step along their educational journey so they can graduate high school prepared for future success. These tests move beyond the rote memorization and fill in the bubble format of past multiple choice tests. Students were asked to write, reason, think critically, and solve multi-step problems that better reflect classroom learning and the real world. Students who receive a 3 or 4 on the test (on a 4-point scale) are considered on track to graduate high school college- and career-ready. Those who receive a 1 or a 2 will receive additional support to help them reach this new higher standard.'
    })
    .transform('Transpose value columns', Transposer,
       :proficiency_band,
       :value_float,
       :"percent_level_1",
       :"percent_level_2",
       :"percent_level_3",
       :"percent_level_4",
       :"percent_proficient_level_3_or_4"
      )
    .transform("Adding column_id from proficiency band", HashLookup, :proficiency_band, sbac_key_map_pro, to: :proficiency_band_gsdata_id)
  end

  source("pagr_schools_MATH_raceethnicity_1617.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      gsdata_test_data_type_id: 251,
      test_data_type: 'OR SBAC',
      entity_level: 'school', 
      notes: 'DXT-2651: OR SBAC',
      description: 'Oregon now has K-12 learning standards aligned with the expectations of colleges and employers. These standards are designed to provide students with the knowledge and skills they need at each step along their educational journey so they can graduate high school prepared for future success. These tests move beyond the rote memorization and fill in the bubble format of past multiple choice tests. Students were asked to write, reason, think critically, and solve multi-step problems that better reflect classroom learning and the real world. Students who receive a 3 or 4 on the test (on a 4-point scale) are considered on track to graduate high school college- and career-ready. Those who receive a 1 or a 2 will receive additional support to help them reach this new higher standard.'
    })
    .transform('Transpose value columns', Transposer,
       :proficiency_band,
       :value_float,
       :"percent_level_1",
       :"percent_level_2",
       :"percent_level_3",
       :"percent_level_4",
       :"percent_proficient_level_3_or_4"
      )
    .transform("Adding column_id from proficiency band", HashLookup, :proficiency_band, sbac_key_map_pro, to: :proficiency_band_gsdata_id)
  end

  source("pagr_schools_MATH_tot_ecd_ext_gnd_lep_1617.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      gsdata_test_data_type_id: 251,
      test_data_type: 'OR SBAC',
      entity_level: 'school', 
      notes: 'DXT-2651: OR SBAC',
      description: 'Oregon now has K-12 learning standards aligned with the expectations of colleges and employers. These standards are designed to provide students with the knowledge and skills they need at each step along their educational journey so they can graduate high school prepared for future success. These tests move beyond the rote memorization and fill in the bubble format of past multiple choice tests. Students were asked to write, reason, think critically, and solve multi-step problems that better reflect classroom learning and the real world. Students who receive a 3 or 4 on the test (on a 4-point scale) are considered on track to graduate high school college- and career-ready. Those who receive a 1 or a 2 will receive additional support to help them reach this new higher standard.'
    })
    .transform('Transpose value columns', Transposer,
       :proficiency_band,
       :value_float,
       :"percent_level_1",
       :"percent_level_2",
       :"percent_level_3",
       :"percent_level_4",
       :"percent_proficient_level_3_or_4"
      )
    .transform("Adding column_id from proficiency band", HashLookup, :proficiency_band, sbac_key_map_pro, to: :proficiency_band_gsdata_id)
  end

  source("pagr_schools_MATH_ine_mig_swa_swd_tag_1617.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      gsdata_test_data_type_id: 251,
      test_data_type: 'OR SBAC',
      entity_level: 'school', 
      notes: 'DXT-2651: OR SBAC',
      description: 'Oregon now has K-12 learning standards aligned with the expectations of colleges and employers. These standards are designed to provide students with the knowledge and skills they need at each step along their educational journey so they can graduate high school prepared for future success. These tests move beyond the rote memorization and fill in the bubble format of past multiple choice tests. Students were asked to write, reason, think critically, and solve multi-step problems that better reflect classroom learning and the real world. Students who receive a 3 or 4 on the test (on a 4-point scale) are considered on track to graduate high school college- and career-ready. Those who receive a 1 or a 2 will receive additional support to help them reach this new higher standard.'
    })
    .transform('Transpose value columns', Transposer,
       :proficiency_band,
       :value_float,
       :"percent_level_1",
       :"percent_level_2",
       :"percent_level_3",
       :"percent_level_4",
       :"percent_proficient_level_3_or_4"
      )
    .transform("Adding column_id from proficiency band", HashLookup, :proficiency_band, sbac_key_map_pro, to: :proficiency_band_gsdata_id)
  end

  source("pagr_Districts_MATH_1617.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      gsdata_test_data_type_id: 251,
      test_data_type: 'OR SBAC',
      entity_level: 'district', 
      notes: 'DXT-2651: OR SBAC',
      description: 'Oregon now has K-12 learning standards aligned with the expectations of colleges and employers. These standards are designed to provide students with the knowledge and skills they need at each step along their educational journey so they can graduate high school prepared for future success. These tests move beyond the rote memorization and fill in the bubble format of past multiple choice tests. Students were asked to write, reason, think critically, and solve multi-step problems that better reflect classroom learning and the real world. Students who receive a 3 or 4 on the test (on a 4-point scale) are considered on track to graduate high school college- and career-ready. Those who receive a 1 or a 2 will receive additional support to help them reach this new higher standard.'
     })
    .transform('Transpose value columns', Transposer,
       :proficiency_band,
       :value_float,
       :"percent_level_1",
       :"percent_level_2",
       :"percent_level_3",
       :"percent_level_4",
       :"percent_proficient_level_3_or_4"
      )
    .transform("Adding column_id from proficiency band", HashLookup, :proficiency_band, sbac_key_map_pro, to: :proficiency_band_gsdata_id)
  end

  source("pagr_State_MATH_1617.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      gsdata_test_data_type_id: 251,
      test_data_type: 'OR SBAC',
      entity_level: 'state', 
      notes: 'DXT-2651: OR SBAC',
      description: 'Oregon now has K-12 learning standards aligned with the expectations of colleges and employers. These standards are designed to provide students with the knowledge and skills they need at each step along their educational journey so they can graduate high school prepared for future success. These tests move beyond the rote memorization and fill in the bubble format of past multiple choice tests. Students were asked to write, reason, think critically, and solve multi-step problems that better reflect classroom learning and the real world. Students who receive a 3 or 4 on the test (on a 4-point scale) are considered on track to graduate high school college- and career-ready. Those who receive a 1 or a 2 will receive additional support to help them reach this new higher standard.'
    })
    .transform('Transpose value columns', Transposer,
       :proficiency_band,
       :value_float,
       :"percent_level_1",
       :"percent_level_2",
       :"percent_level_3",
       :"percent_level_4",
       :"percent_proficient_level_3_or_4"
      )
    .transform("Adding column_id from proficiency band", HashLookup, :proficiency_band, sbac_key_map_pro, to: :proficiency_band_gsdata_id)
  end

  source("pagr_State_SCIENCE_1617.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
        test_data_type: 'OAKS',
        gsdata_test_data_type_id: 250,
        entity_level: 'state', 
        academic_gsdata_id: 19,
        notes: 'DXT-2651: OR OAKS',
        description: 'In 2016-2017 Oregon used the Oregon Assessment of Knowledge and Skills (OAKS) to test students in grades 5, 8 and 11 in science.  The OAKS is a standards-based test, which means it measures how well students are mastering specific skills defined for each grade by the state of Oregon.  The goal is for all students to score at or above the state standard.'
    })
    .transform('Transpose value columns', Transposer,
       :proficiency_band,
       :value_float,
       :"percent_level_1",
       :"percent_level_2",
       :"percent_level_3",
       :"percent_level_4",
       :"percent_level_5",
       :"percent_proficient_level_4_or_5"
      )
    .transform("Adding column_id from proficiency band", HashLookup, :proficiency_band, oaks_key_map_pro, to: :proficiency_band_gsdata_id)
  end
  
  source("pagr_Districts_SCIENCE_1617.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
        test_data_type: 'OAKS',
        gsdata_test_data_type_id: 250,
        entity_level: 'district',
        academic_gsdata_id: 19, 
        notes: 'DXT-2651: OR OAKS',
        description: 'In 2016-2017 Oregon used the Oregon Assessment of Knowledge and Skills (OAKS) to test students in grades 5, 8 and 11 in science.  The OAKS is a standards-based test, which means it measures how well students are mastering specific skills defined for each grade by the state of Oregon.  The goal is for all students to score at or above the state standard.'
    })
    .transform('Transpose value columns', Transposer,
       :proficiency_band,
       :value_float,
       :"percent_level_1",
       :"percent_level_2",
       :"percent_level_3",
       :"percent_level_4",
       :"percent_level_5",
       :"percent_proficient_level_4_or_5"
      )
    .transform("Adding column_id from proficiency band", HashLookup, :proficiency_band, oaks_key_map_pro, to: :proficiency_band_gsdata_id)
  end
  
  source("pagr_schools_science_raceethnicity_1617.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
        test_data_type: 'OAKS',
        gsdata_test_data_type_id: 250,
        entity_level: 'school', 
        academic_gsdata_id: 19,
        notes: 'DXT-2651: OR OAKS',
        description: 'In 2016-2017 Oregon used the Oregon Assessment of Knowledge and Skills (OAKS) to test students in grades 5, 8 and 11 in science.  The OAKS is a standards-based test, which means it measures how well students are mastering specific skills defined for each grade by the state of Oregon.  The goal is for all students to score at or above the state standard.'
    })
    .transform('Transpose value columns', Transposer,
       :proficiency_band,
       :value_float,
       :"percent_level_1",
       :"percent_level_2",
       :"percent_level_3",
       :"percent_level_4",
       :"percent_level_5",
       :"percent_proficient_level_4_or_5"
      )
    .transform("Adding column_id from proficiency band", HashLookup, :proficiency_band, oaks_key_map_pro, to: :proficiency_band_gsdata_id)
  end
  
  source("pagr_schools_science_tot_othergroups_1617.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
        test_data_type: 'OAKS',
        gsdata_test_data_type_id: 250,
        entity_level: 'school', 
        academic_gsdata_id: 19,
        notes: 'DXT-2651: OR OAKS',
        description: 'In 2016-2017 Oregon used the Oregon Assessment of Knowledge and Skills (OAKS) to test students in grades 5, 8 and 11 in science.  The OAKS is a standards-based test, which means it measures how well students are mastering specific skills defined for each grade by the state of Oregon.  The goal is for all students to score at or above the state standard.'
    })
    .transform('Transpose value columns', Transposer,
       :proficiency_band,
       :value_float,
       :"percent_level_1",
       :"percent_level_2",
       :"percent_level_3",
       :"percent_level_4",
       :"percent_level_5",
       :"percent_proficient_level_4_or_5"
      )
    .transform("Adding column_id from proficiency band", HashLookup, :proficiency_band, oaks_key_map_pro, to: :proficiency_band_gsdata_id)
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
    .transform("Remove suppressed bands", DeleteRows, :value_float, '-', '--', '*')
    .transform("Remove weird breakdowns", DeleteRows, :breakdown, 'Extended Assessment', 'Indian Education', 'Migrant Education', 'SWD with Accommodations','Talented and Gifted (TAG)')
    .transform("Delete rows where number tested is less than 10 ",DeleteRows, :number_tested, '0','1','2','3','4','5','6','7','8','9')
    .transform('Fill missing default fields', Fill, {
      year: 2017,
      entity_type: 'public_charter',
      level_code: 'e,m,h',
    })
    .transform("Prof special cases", WithBlock,) do |row|
      if row[:value_float] == '> 95.0%'
        row[:value_float] = '95'
        row[:number_tested] = nil
      elsif row[:value_float] == '< 5.0%'
        row[:value_float] = '5'
        row[:number_tested] = nil
      elsif row[:value_float].to_f < 0
        row[:value_float] = 0
      elsif row[:value_float].to_f > 100
        row[:value_float] = 100
      end
      row
    end
    .transform("Adding column breakdown_id from breadown", HashLookup, :breakdown, key_map_bd, to: :breakdown_gsdata_id)
    .transform("Adding column subject_id from subject",
      HashLookup, :subject, key_map_sub, to: :academic_gsdata_id)
    .transform("Edit grade", WithBlock,) do |row|
      if row[:grade] == 'All Grades'
        row[:grade] = 'All'
      else
        row[:grade] = row[:grade].gsub(/[^\d]/, '')
      end
      row
    end
    .transform("Creating StateID", WithBlock) do |row|
      if row[:entity_level] == 'district'
        row[:state_id] = row[:district_id].rjust(14,'0')
      elsif row[:entity_level] == 'state'
        row[:state_id] ='state'
      elsif row[:entity_level] == 'school'
        row[:state_id] = row[:school_id].rjust(20,'0')
      end
      row
    end
    # .transform('Fill missing ids and names with entity_level', WithBlock) do |row|
    #   [:state_id, :school_id, :district_id, :school_name, :district_name].each do |col|
    #     row[col] ||= row[:entity_level]
    #   end
    #   row
    # end
  end

  def config_hash
    {
        gsdata_source_id: 42,
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