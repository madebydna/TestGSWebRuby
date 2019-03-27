require_relative "../test_processor"
GS::ETL::Logging.disable

class NJTestProcessor2017PARCCASKNJBCT < GS::ETL::TestProcessor

  def initialize(*args)
    super
    @year=2017
  end

  map_prof_band = {
  l1_percent: 13,
  l2_percent: 14,
  l3_percent: 15,
  l4_percent: 16,
  l5_percent: 17,
    prof_and_above: 1,
    total_pp_scie: 2,
    total_p_scie: 3,
    total_ap_scie: 4,
    total_prof_and_above: 1,
    ge_pp_scie: 2,
    ge_p_scie: 3,
    ge_ap_scie: 4,
    ge_prof_and_above: 1,
    se_pp_scie: 2,
    se_p_scie: 3,
    se_ap_scie: 4,
    se_prof_and_above: 1,
    lep_pp_scie: 2,
    lep_p_scie: 3,
    lep_ap_scie: 4,
    lep_prof_and_above: 1,
    f_pp_scie: 2,
    f_p_scie: 3,
    f_ap_scie: 4,
    f_prof_and_above: 1,
    m_pp_scie: 2,
    m_p_scie: 3,
    m_ap_scie: 4,
    m_prof_and_above: 1,
    w_pp_scie: 2,
    w_p_scie: 3,
    w_ap_scie: 4,
    w_prof_and_above: 1,
    b_pp_scie: 2,
    b_p_scie: 3,
    b_ap_scie: 4,
    b_prof_and_above: 1,
    a_pp_scie: 2,
    a_p_scie: 3,
    a_ap_scie: 4,
    a_prof_and_above: 1,
    p_pp_scie: 2,
    p_p_scie: 3,
    p_ap_scie: 4,
    p_prof_and_above: 1,
    h_pp_scie: 2,
    h_p_scie: 3,
    h_ap_scie: 4,
    h_prof_and_above: 1,
    i_pp_scie: 2,
    i_p_scie: 3,
    i_ap_scie: 4,
    i_prof_and_above: 1,
    ecdis_y_pp_scie: 2,
    ecdis_y_p_scie: 3,
    ecdis_y_ap_scie: 4,
    ecdis_y_prof_and_above: 1,
    ecdis_n_pp_scie: 2,
    ecdis_n_p_scie: 3,
    ecdis_n_ap_scie: 4,
    ecdis_n_prof_and_above: 1
  }

  map_breakdown = {
    'ALL STUDENTS' => 1,
    'ASIAN' => 16,
    'AFRICAN AMERICAN' => 17,
    'FEMALE' => 26,
    'ECONOMICALLY DISADVANTAGED' => 23,
    'HISPANIC' => 19,
    'ENGLISH LANGUAGE LEARNERS' => 32,
    'MALE' => 25,
    'AMERICAN INDIAN' => 18,
    'NON-ECON. DISADVANTAGED' => 24,
    'NATIVE HAWAIIAN' => 20,
    'PACIFIC ISLANDER' => 20,
    'STUDENTS WITH DISABILITIES' => 27,
    'WHITE' => 21
  }

 map_prof_to_breakdown_name = {
    total_pp_scie: 'ALL STUDENTS',
    total_p_scie: 'ALL STUDENTS',
    total_ap_scie: 'ALL STUDENTS',
    total_prof_and_above: 'ALL STUDENTS',
    ge_pp_scie: 'GENERAL EDUCATION STUDENTS',
    ge_p_scie: 'GENERAL EDUCATION STUDENTS',
    ge_ap_scie: 'GENERAL EDUCATION STUDENTS',
    ge_prof_and_above: 'GENERAL EDUCATION STUDENTS',
    se_pp_scie: 'STUDENTS WITH DISABILITIES',
    se_p_scie: 'STUDENTS WITH DISABILITIES',
    se_ap_scie: 'STUDENTS WITH DISABILITIES',
    se_prof_and_above: 'STUDENTS WITH DISABILITIES',
    lep_pp_scie: 'ENGLISH LANGUAGE LEARNERS',
    lep_p_scie: 'ENGLISH LANGUAGE LEARNERS',
    lep_ap_scie: 'ENGLISH LANGUAGE LEARNERS',
    lep_prof_and_above: 'ENGLISH LANGUAGE LEARNERS',
    f_pp_scie: 'FEMALE',
    f_p_scie: 'FEMALE',
    f_ap_scie: 'FEMALE',
    f_prof_and_above: 'FEMALE',
    m_pp_scie: 'MALE',
    m_p_scie: 'MALE',
    m_ap_scie: 'MALE',
    m_prof_and_above: 'MALE',
    w_pp_scie: 'WHITE',
    w_p_scie: 'WHITE',
    w_ap_scie: 'WHITE',
    w_prof_and_above: 'WHITE',
    b_pp_scie: 'AFRICAN AMERICAN',
    b_p_scie: 'AFRICAN AMERICAN',
    b_ap_scie: 'AFRICAN AMERICAN',
    b_prof_and_above: 'AFRICAN AMERICAN',
    a_pp_scie: 'ASIAN',
    a_p_scie: 'ASIAN',
    a_ap_scie: 'ASIAN',
    a_prof_and_above: 'ASIAN',
    p_pp_scie: 'NATIVE HAWAIIAN OR PACIFIC ISLANDER',
    p_p_scie: 'NATIVE HAWAIIAN OR PACIFIC ISLANDER',
    p_ap_scie: 'NATIVE HAWAIIAN OR PACIFIC ISLANDER',
    p_prof_and_above: 'NATIVE HAWAIIAN OR PACIFIC ISLANDER',
    h_pp_scie: 'HISPANIC',
    h_p_scie: 'HISPANIC',
    h_ap_scie: 'HISPANIC',
    h_prof_and_above: 'HISPANIC',
    i_pp_scie: 'AMERICAN INDIAN',
    i_p_scie: 'AMERICAN INDIAN',
    i_ap_scie: 'AMERICAN INDIAN',
    i_prof_and_above: 'AMERICAN INDIAN',
    ecdis_y_pp_scie: 'ECONOMICALLY DISADVANTAGED',
    ecdis_y_p_scie: 'ECONOMICALLY DISADVANTAGED',
    ecdis_y_ap_scie: 'ECONOMICALLY DISADVANTAGED',
    ecdis_y_prof_and_above: 'ECONOMICALLY DISADVANTAGED',
    ecdis_n_pp_scie: 'NON-ECON. DISADVANTAGED',
    ecdis_n_p_scie: 'NON-ECON. DISADVANTAGED',
    ecdis_n_ap_scie: 'NON-ECON. DISADVANTAGED',
    ecdis_n_prof_and_above: 'NON-ECON. DISADVANTAGED'
  }

  map_prof_to_breakdown = {
    total_pp_scie: 1,
    total_p_scie: 1,
    total_ap_scie: 1,
    total_prof_and_above: 1,
    ge_pp_scie: 30,
    ge_p_scie: 30,
    ge_ap_scie: 30,
    ge_prof_and_above: 30,
    se_pp_scie: 27,
    se_p_scie: 27,
    se_ap_scie: 27,
    se_prof_and_above: 27,
    lep_pp_scie: 32,
    lep_p_scie: 32,
    lep_ap_scie: 32,
    lep_prof_and_above: 32,
    f_pp_scie: 26,
    f_p_scie: 26,
    f_ap_scie: 26,
    f_prof_and_above: 26,
    m_pp_scie: 25,
    m_p_scie: 25,
    m_ap_scie: 25,
    m_prof_and_above: 25,
    w_pp_scie: 21,
    w_p_scie: 21,
    w_ap_scie: 21,
    w_prof_and_above: 21,
    b_pp_scie: 17,
    b_p_scie: 17,
    b_ap_scie: 17,
    b_prof_and_above: 17,
    a_pp_scie: 16,
    a_p_scie: 16,
    a_ap_scie: 16,
    a_prof_and_above: 16,
    p_pp_scie: 20,
    p_p_scie: 20,
    p_ap_scie: 20,
    p_prof_and_above: 20,
    h_pp_scie: 19,
    h_p_scie: 19,
    h_ap_scie: 19,
    h_prof_and_above: 19,
    i_pp_scie: 18,
    i_p_scie: 18,
    i_ap_scie: 18,
    i_prof_and_above: 18,
    ecdis_y_pp_scie: 23,
    ecdis_y_p_scie: 23,
    ecdis_y_ap_scie: 23,
    ecdis_y_prof_and_above: 23,
    ecdis_n_pp_scie: 24,
    ecdis_n_p_scie: 24,
    ecdis_n_ap_scie: 24,
    ecdis_n_prof_and_above: 24
  }

 source('ask_04.txt',[],col_sep:"\t")  do |s|
   s.transform("setting entity level", WithBlock) do |row|
     if row[:county_code] == "ST"
       row[:entity_level] = 'state'
     elsif row[:school_name].nil?
       row [:entity_level] = 'district'
     elsif row[:entity_level] = 'school'
     end
     row
   end
   .transform("removing DFG rows", WithBlock) do |row|
     if row[:entity_level] == 'district' and row[:district_name].nil?
       row[:district_name] = 'skip'
     else row[:district_name] = row[:district_name]
     end
     row
   end
   .transform("padding ids",WithBlock) do |row|
     row[:district_id] = '%04i' % (row[:district_code].to_i)
     row[:school_id] = '%03i' % (row[:school_code].to_i)
     row[:county_code] = '%02i' % (row[:county_code].to_i)
     row
   end
   .transform("state id", WithBlock) do |row|
     if row[:entity_level] == 'school'
       row[:state_id] = row[:county_code]+row[:district_id]+row[:school_id]
     elsif row[:entity_level] == 'district'
       row[:state_id] = row[:county_code]+row[:district_id]
     else row[:state_id] = 'state'
     end
     row
   end
   .transform("Fill Columns",Fill,
     {
       year: 2017,
       entity_type: 'public_charter',
       level_code: 'e,m,h',
       test_data_type: 'NJ ASK',
       gsdata_test_data_type_id: 286,
       subject: 'Science',
       academic_gsdata_id: 19,
       grade: 4, 
       notes: 'DXT-2557: NJ NJ ASK',
       description: 'In 2016-2017 New Jersey used the New Jersey Assessment of Skills and Knowledge (NJ ASK) to test students in grades 4 and 8 in science.  The NJ ASK is a standards-based test, which means it measures how well students are mastering specific skills defined for each grade by the state of New Jersey.  The goal is for all students to score at or above the proficient level.'
     })
   .transform('prof and above',SumValues,:total_prof_and_above, :total_p_scie,:total_ap_scie)
   .transform('prof and above',SumValues,:ge_prof_and_above, :ge_p_scie,:ge_ap_scie)
   .transform('prof and above',SumValues,:se_prof_and_above, :se_p_scie,:se_ap_scie)
   .transform('prof and above',SumValues,:lep_prof_and_above, :lep_p_scie,:lep_ap_scie)
   .transform('transposing prof bands', Transposer, :proficiency_band, :value_float, :total_prof_and_above, :total_pp_scie, :total_p_scie, :total_ap_scie, :ge_prof_and_above, :ge_pp_scie, :ge_p_scie, :ge_ap_scie, :se_prof_and_above, :se_pp_scie, :se_p_scie, :se_ap_scie, :lep_prof_and_above, :lep_pp_scie, :lep_p_scie, :lep_ap_scie)
   .transform('delete * and blank rows in value_float', DeleteRows, :value_float, '*', nil)
   .transform("fix special cases for prof and above", WithBlock) do |row|
          if row[:value_float].to_i < 0
            row[:value_float] = 0
          elsif row[:value_float].to_i > 100
            row[:value_float] = 100
          end
     row
    end
   .transform("mapping proficiency bands",
     HashLookup, :proficiency_band, map_prof_band, to: :proficiency_band_gsdata_id)
   .transform('mapping prof cols to breakdown names', HashLookup, :proficiency_band, map_prof_to_breakdown_name, to: :breakdown)
   .transform('mapping breakdown', HashLookup, :breakdown, map_breakdown, to: :breakdown_gsdata_id)
   .transform("mapping number tested", WithBlock) do |row|
     if row[:breakdown_gsdata_id] == 1
       row[:number_tested] = row[:total_enroll_scie]
     elsif row[:breakdown_gsdata_id] == 30
       row[:number_tested] = row[:ge_enroll_scie]
     elsif row[:breakdown_gsdata_id] == 27
       row[:number_tested] = row[:se_enroll_scie]
     elsif row[:breakdown_gsdata_id] == 32
       row[:number_tested] = row[:lep_enroll_scie]
     end
     row
   end
   .transform("Delete rows where number tested is less than 10 ",DeleteRows, :number_tested, '0','1','2','3','4','5','6','7','8','9')
   .transform("removing * rows", DeleteRows, :number_tested, '*')
   .transform("removing blanks", WithBlock) do |row|
     if row[:number_tested].nil?
       row[:number_tested] = 'skip'
     else row[:number_tested] = row[:number_tested]
     end
     row
   end
   .transform("removing blanks", DeleteRows, :number_tested, 'skip')
   .transform("removing DFG rows", DeleteRows, :district_name, 'skip')
 end

 source('ask_04_gender.txt',[],col_sep:"\t")  do |s|
   s.transform("setting entity level", WithBlock) do |row|
     if row[:county_code] == "ST"
       row[:entity_level] = 'state'
     elsif row[:school_name].nil?
       row [:entity_level] = 'district'
     elsif row[:entity_level] = 'school'
     end
     row
   end
   .transform("removing DFG rows", WithBlock) do |row|
     if row[:entity_level] == 'district' and row[:district_name].nil?
       row[:district_name] = 'skip'
     else row[:district_name] = row[:district_name]
     end
     row
   end
   .transform("padding ids",WithBlock) do |row|
     row[:district_id] = '%04i' % (row[:district_code].to_i)
     row[:school_id] = '%03i' % (row[:school_code].to_i)
     row[:county_code] = '%02i' % (row[:county_code].to_i)
     row
   end
   .transform("state id", WithBlock) do |row|
     if row[:entity_level] == 'school'
       row[:state_id] = row[:county_code]+row[:district_id]+row[:school_id]
     elsif row[:entity_level] == 'district'
       row[:state_id] = row[:county_code]+row[:district_id]
     else row[:state_id] = 'state'
     end
     row
   end
   .transform("Fill Columns",Fill,
     {
       year: 2017,
       entity_type: 'public_charter',
       level_code: 'e,m,h',
       test_data_type: 'NJ ASK',
       gsdata_test_data_type_id: 286,
       subject: 'Science',
       academic_gsdata_id: 19,
       grade: 4, 
       notes: 'DXT-2557: NJ NJ ASK',
       description: 'In 2016-2017 New Jersey used the New Jersey Assessment of Skills and Knowledge (NJ ASK) to test students in grades 4 and 8 in science.  The NJ ASK is a standards-based test, which means it measures how well students are mastering specific skills defined for each grade by the state of New Jersey.  The goal is for all students to score at or above the proficient level.'
     })
   .transform('prof and above',SumValues,:f_prof_and_above, :f_p_scie,:f_ap_scie)
   .transform('prof and above',SumValues,:m_prof_and_above, :m_p_scie,:m_ap_scie)
   .transform('transposing prof bands', Transposer, :proficiency_band, :value_float, :f_prof_and_above, :f_pp_scie, :f_p_scie, :f_ap_scie, :m_prof_and_above, :m_pp_scie, :m_p_scie, :m_ap_scie)
   .transform('delete * and blank rows in value_float', DeleteRows, :value_float, '*', nil)
   .transform("fix special cases for prof and above", WithBlock) do |row|
          if row[:value_float].to_i < 0
            row[:value_float] = 0
          elsif row[:value_float].to_i > 100
            row[:value_float] = 100
          end
     row
    end  
   .transform("mapping proficiency bands",
     HashLookup, :proficiency_band, map_prof_band, to: :proficiency_band_gsdata_id)
   .transform('mapping prof cols to breakdown names', HashLookup, :proficiency_band, map_prof_to_breakdown_name, to: :breakdown)
   .transform('mapping breakdown', HashLookup, :proficiency_band, map_prof_to_breakdown, to: :breakdown_gsdata_id)
   .transform("mapping number tested", WithBlock) do |row|
     if row[:breakdown_gsdata_id] == 26
       row[:number_tested] = row[:f_enroll_scie]
     elsif row[:breakdown_gsdata_id] == 25
       row[:number_tested] = row[:m_enroll_scie]
     end
     row
   end
   .transform("Delete rows where number tested is less than 10 ",DeleteRows, :number_tested, '0','1','2','3','4','5','6','7','8','9')
   .transform("removing * rows", DeleteRows, :number_tested, '*') 
   .transform("removing blanks", WithBlock) do |row|
     if row[:number_tested].nil?
       row[:number_tested] = 'skip'
     else row[:number_tested] = row[:number_tested]
     end
     row
   end
   .transform("removing blanks", DeleteRows, :number_tested, 'skip')
   .transform("removing DFG rows", DeleteRows, :district_name, 'skip')
   .transform('test',WithBlock) do |row|
       row
       require 'byebug'
       byebug
   end
 end

  def config_hash
    {
      gsdata_source_id: 34,
      state:'nj',
            source_name: 'New Jersey Department of Education',
            date_valid: '2017-01-01 00:00:00',
      url:  'http://www.state.nj.us/education/',
      file: 'nj/2017/nj.2017.1.public.charter.[level].txt',
      level: nil,
      school_type: 'public,charter'
    }
  end
end

NJTestProcessor2017PARCCASKNJBCT.new(ARGV[0],max:nil,offset:nil).run