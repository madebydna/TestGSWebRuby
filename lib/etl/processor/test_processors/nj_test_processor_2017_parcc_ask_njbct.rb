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
    'WHITE' => 21, 
    'GENERAL EDUCATION STUDENTS' => 30
  }


  map_breakdown_to_name = {
    1 => 'ALL STUDENTS',
    16 => 'ASIAN',
    17 => 'AFRICAN AMERICAN',
    26 => 'FEMALE',
    23 => 'ECONOMICALLY DISADVANTAGED',
    19 => 'HISPANIC',
    32 => 'ENGLISH LANGUAGE LEARNERS',
    25 => 'MALE',
    18 => 'AMERICAN INDIAN',
    24 => 'NON-ECON. DISADVANTAGED',
    20 => 'NATIVE HAWAIIAN OR PACIFIC ISLANDER',
    27 => 'STUDENTS WITH DISABILITIES',
    21 => 'WHITE', 
    30 => 'GENERAL EDUCATION STUDENTS'
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

 source('ELA03.txt',[],col_sep:"\t")  do |s|
   s.transform("setting entity level", WithBlock) do |row|
     if row[:county_code] == 'STATE'
       row[:entity_level] = 'state'
     elsif row[:school_name].nil?
       row [:entity_level] = 'district'
     else row[:entity_level] = 'school'
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
       test_data_type: 'NJ PARCC',
       gsdata_test_data_type_id: '289', 
       subject: 'ELA',
       academic_gsdata_id: 4,
       grade: 3,
       notes: 'DXT-2557: NJ NJ PARCC',
       description: 'Statewide assessments have been used for decades in New Jersey and are designed to measure student progress toward achieving our academic standards. PARCC is a multi-state consortium that allows states, including New Jersey, to pool resources and expertise to develop a meaningful, comparable high-quality assessment - one that can be used to guide our efforts to continually improve our educational system by supporting teaching and learning, identifying struggling schools, informing teacher development, and providing parents with feedback on their own child\'s strengths and challenges.'
     })
   .transform("Rename columns",MultiFieldRenamer,
     {
       subgroup_type: :breakdown,
       valid_scores: :number_tested
     })
   .transform("Delete rows where number tested is less than 10 ",DeleteRows, :number_tested, '0','1','2','3','4','5','6','7','8','9')
   .transform('delete * rows', DeleteRows, :l1_percent, '*')
   .transform('prof and above band',SumValues,:prof_and_above, :l4_percent,:l5_percent)
   .transform('transposing prof bands', Transposer, :proficiency_band, :value_float, :l1_percent, :l2_percent, :l3_percent, :l4_percent, :l5_percent, :prof_and_above)
   .transform("mapping proficiency bands",
     HashLookup, :proficiency_band, map_prof_band, to: :proficiency_band_gsdata_id)
   .transform('delete * and blank rows in value_float', DeleteRows, :value_float, '*', nil)
   .transform("fix special cases for prof and above", WithBlock) do |row|
          if row[:value_float].to_f < 0
            row[:value_float] = 0
          elsif row[:value_float].to_f > 100
            row[:value_float] = 100
          end
     row
    end
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'OTHER')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'SE ACCOMMODATION')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'FORMER - ELL')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'CURRENT - ELL')
   .transform('mapping breakdown', HashLookup, :breakdown, map_breakdown, to: :breakdown_gsdata_id)
   .transform("removing DFG rows", DeleteRows, :district_name, 'skip')
 end

 source('ELA04.txt',[],col_sep:"\t")  do |s|
   s.transform("setting entity level", WithBlock) do |row|
     if row[:county_code] == 'STATE'
       row[:entity_level] = 'state'
     elsif row[:school_name].nil?
       row [:entity_level] = 'district'
     else row[:entity_level] = 'school'
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
       test_data_type: 'NJ PARCC',
       gsdata_test_data_type_id: 289,
       subject: 'ELA',
       academic_gsdata_id: 4,
       grade: 4, 
     notes: 'DXT-2557: NJ NJ PARCC',
       description: 'Statewide assessments have been used for decades in New Jersey and are designed to measure student progress toward achieving our academic standards. PARCC is a multi-state consortium that allows states, including New Jersey, to pool resources and expertise to develop a meaningful, comparable high-quality assessment - one that can be used to guide our efforts to continually improve our educational system by supporting teaching and learning, identifying struggling schools, informing teacher development, and providing parents with feedback on their own child\'s strengths and challenges.'
     })
   .transform("Rename columns",MultiFieldRenamer,
     {
       subgroup_type: :breakdown,
       valid_scores: :number_tested
     })
   .transform("Delete rows where number tested is less than 10 ",DeleteRows, :number_tested, '0','1','2','3','4','5','6','7','8','9')
   .transform('delete * rows', DeleteRows, :l1_percent, '*')
   .transform('prof and above band',SumValues,:prof_and_above, :l4_percent,:l5_percent)
   .transform('transposing prof bands', Transposer, :proficiency_band, :value_float, :l1_percent, :l2_percent, :l3_percent, :l4_percent, :l5_percent, :prof_and_above)
   .transform("mapping proficiency bands",
     HashLookup, :proficiency_band, map_prof_band, to: :proficiency_band_gsdata_id)
   .transform('delete * and blank rows in value_float', DeleteRows, :value_float, '*', nil)
   .transform("fix special cases for prof and above", WithBlock) do |row|
          if row[:value_float].to_f < 0
            row[:value_float] = 0
          elsif row[:value_float].to_f > 100
            row[:value_float] = 100
          end
     row
    end
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'OTHER')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'SE ACCOMMODATION')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'FORMER - ELL')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'CURRENT - ELL')
   .transform('mapping breakdown', HashLookup, :breakdown, map_breakdown, to: :breakdown_gsdata_id)
   .transform("removing DFG rows", DeleteRows, :district_name, 'skip')
 end

 source('ELA05.txt',[],col_sep:"\t")  do |s|
   s.transform("setting entity level", WithBlock) do |row|
     if row[:county_code] == 'STATE'
       row[:entity_level] = 'state'
     elsif row[:school_name].nil?
       row [:entity_level] = 'district'
     else row[:entity_level] = 'school'
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
       test_data_type: 'NJ PARCC',
       gsdata_test_data_type_id: 289,
       subject: 'ELA',
       academic_gsdata_id: 4,
       grade: 5, 
       notes: 'DXT-2557: NJ NJ PARCC',
       description: 'Statewide assessments have been used for decades in New Jersey and are designed to measure student progress toward achieving our academic standards. PARCC is a multi-state consortium that allows states, including New Jersey, to pool resources and expertise to develop a meaningful, comparable high-quality assessment - one that can be used to guide our efforts to continually improve our educational system by supporting teaching and learning, identifying struggling schools, informing teacher development, and providing parents with feedback on their own child\'s strengths and challenges.'
     })
   .transform("Rename columns",MultiFieldRenamer,
     {
       subgroup_type: :breakdown,
       valid_scores: :number_tested
     })
   .transform("Delete rows where number tested is less than 10 ",DeleteRows, :number_tested, '0','1','2','3','4','5','6','7','8','9')
   .transform('delete * rows', DeleteRows, :l1_percent, '*')
   .transform('prof and above',SumValues,:prof_and_above, :l4_percent,:l5_percent)
   .transform('transposing prof bands', Transposer, :proficiency_band, :value_float, :l1_percent, :l2_percent, :l3_percent, :l4_percent, :l5_percent, :prof_and_above)
   .transform("mapping proficiency bands",
     HashLookup, :proficiency_band, map_prof_band, to: :proficiency_band_gsdata_id)
   .transform('delete * and blank rows in value_float', DeleteRows, :value_float, '*', nil)
   .transform("fix special cases for prof and above", WithBlock) do |row|
          if row[:value_float].to_f < 0
            row[:value_float] = 0
          elsif row[:value_float].to_f > 100
            row[:value_float] = 100
          end
     row
    end
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'OTHER')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'SE ACCOMMODATION')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'FORMER - ELL')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'CURRENT - ELL')
   .transform('mapping breakdown', HashLookup, :breakdown, map_breakdown, to: :breakdown_gsdata_id)
   .transform("removing DFG rows", DeleteRows, :district_name, 'skip')
 end

 source('ELA06.txt',[],col_sep:"\t")  do |s|
   s.transform("setting entity level", WithBlock) do |row|
     if row[:county_code] == 'STATE'
       row[:entity_level] = 'state'
     elsif row[:school_name].nil?
       row [:entity_level] = 'district'
     else row[:entity_level] = 'school'
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
       test_data_type: 'NJ PARCC',
       gsdata_test_data_type_id: 289,
       subject: 'ELA',
       academic_gsdata_id: 4,
       grade: 6, 
       notes: 'DXT-2557: NJ NJ PARCC',
       description: 'Statewide assessments have been used for decades in New Jersey and are designed to measure student progress toward achieving our academic standards. PARCC is a multi-state consortium that allows states, including New Jersey, to pool resources and expertise to develop a meaningful, comparable high-quality assessment - one that can be used to guide our efforts to continually improve our educational system by supporting teaching and learning, identifying struggling schools, informing teacher development, and providing parents with feedback on their own child\'s strengths and challenges.'
     })
    .transform("Rename columns",MultiFieldRenamer,
     {
       subgroup_type: :breakdown,
       valid_scores: :number_tested
     })
   .transform("Delete rows where number tested is less than 10 ",DeleteRows, :number_tested, '0','1','2','3','4','5','6','7','8','9')
   .transform('delete * rows', DeleteRows, :l1_percent, '*')
   .transform('prof and above',SumValues,:prof_and_above, :l4_percent,:l5_percent)
   .transform('transposing prof bands', Transposer, :proficiency_band, :value_float, :l1_percent, :l2_percent, :l3_percent, :l4_percent, :l5_percent, :prof_and_above)
   .transform("mapping proficiency bands",
     HashLookup, :proficiency_band, map_prof_band, to: :proficiency_band_gsdata_id)
   .transform('delete * and blank rows in value_float', DeleteRows, :value_float, '*', nil)
   .transform("fix special cases for prof and above", WithBlock) do |row|
          if row[:value_float].to_f < 0
            row[:value_float] = 0
          elsif row[:value_float].to_f > 100
            row[:value_float] = 100
          end
     row
    end
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'OTHER')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'SE ACCOMMODATION')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'FORMER - ELL')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'CURRENT - ELL')
   .transform('mapping breakdown', HashLookup, :breakdown, map_breakdown, to: :breakdown_gsdata_id)
   .transform("removing DFG rows", DeleteRows, :district_name, 'skip')
 end

 source('ELA07.txt',[],col_sep:"\t")  do |s|
   s.transform("setting entity level", WithBlock) do |row|
     if row[:county_code] == 'STATE'
       row[:entity_level] = 'state'
     elsif row[:school_name].nil?
       row [:entity_level] = 'district'
     else row[:entity_level] = 'school'
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
       test_data_type: 'NJ PARCC',
       gsdata_test_data_type_id: 289,
       subject: 'ELA',
       academic_gsdata_id: 4,
       grade: 7, 
       notes: 'DXT-2557: NJ NJ PARCC',
       description: 'Statewide assessments have been used for decades in New Jersey and are designed to measure student progress toward achieving our academic standards. PARCC is a multi-state consortium that allows states, including New Jersey, to pool resources and expertise to develop a meaningful, comparable high-quality assessment - one that can be used to guide our efforts to continually improve our educational system by supporting teaching and learning, identifying struggling schools, informing teacher development, and providing parents with feedback on their own child\'s strengths and challenges.'
     })
   s.transform("Rename columns",MultiFieldRenamer,
     {
       subgroup_type: :breakdown,
       valid_scores: :number_tested
     })
   .transform("Delete rows where number tested is less than 10 ",DeleteRows, :number_tested, '0','1','2','3','4','5','6','7','8','9')
   .transform('delete * rows', DeleteRows, :l1_percent, '*')
   .transform('prof and above',SumValues,:prof_and_above, :l4_percent,:l5_percent)
   .transform('transposing prof bands', Transposer, :proficiency_band, :value_float, :l1_percent, :l2_percent, :l3_percent, :l4_percent, :l5_percent, :prof_and_above)
   .transform("mapping proficiency bands",
     HashLookup, :proficiency_band, map_prof_band, to: :proficiency_band_gsdata_id)
   .transform('delete * and blank rows in value_float', DeleteRows, :value_float, '*', nil)
   .transform("fix special cases for prof and above", WithBlock) do |row|
          if row[:value_float].to_f < 0
            row[:value_float] = 0
          elsif row[:value_float].to_f > 100
            row[:value_float] = 100
          end
     row
    end
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'OTHER')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'SE ACCOMMODATION')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'FORMER - ELL')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'CURRENT - ELL')
   .transform('mapping breakdown', HashLookup, :breakdown, map_breakdown, to: :breakdown_gsdata_id)
   .transform("removing DFG rows", DeleteRows, :district_name, 'skip')
 end

 source('ELA08.txt',[],col_sep:"\t")  do |s|
   s.transform("setting entity level", WithBlock) do |row|
     if row[:county_code] == 'STATE'
       row[:entity_level] = 'state'
     elsif row[:school_name].nil?
       row [:entity_level] = 'district'
     else row[:entity_level] = 'school'
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
       test_data_type: 'NJ PARCC',
       gsdata_test_data_type_id: 289,
       subject: 'ELA',
       academic_gsdata_id: 4,
       grade: 8, 
       notes: 'DXT-2557: NJ NJ PARCC',
       description: 'Statewide assessments have been used for decades in New Jersey and are designed to measure student progress toward achieving our academic standards. PARCC is a multi-state consortium that allows states, including New Jersey, to pool resources and expertise to develop a meaningful, comparable high-quality assessment - one that can be used to guide our efforts to continually improve our educational system by supporting teaching and learning, identifying struggling schools, informing teacher development, and providing parents with feedback on their own child\'s strengths and challenges.'
     })
   .transform("Rename columns",MultiFieldRenamer,
     {
       subgroup_type: :breakdown,
       valid_scores: :number_tested
     })
   .transform("Delete rows where number tested is less than 10 ",DeleteRows, :number_tested, '0','1','2','3','4','5','6','7','8','9')
   .transform('delete * rows', DeleteRows, :l1_percent, '*')
   .transform('prof and above',SumValues,:prof_and_above, :l4_percent,:l5_percent)
   .transform('transposing prof bands', Transposer, :proficiency_band, :value_float, :l1_percent, :l2_percent, :l3_percent, :l4_percent, :l5_percent, :prof_and_above)
   .transform("mapping proficiency bands",
     HashLookup, :proficiency_band, map_prof_band, to: :proficiency_band_gsdata_id)
   .transform('delete * and blank rows in value_float', DeleteRows, :value_float, '*', nil)
   .transform("fix special cases for prof and above", WithBlock) do |row|
          if row[:value_float].to_f < 0
            row[:value_float] = 0
          elsif row[:value_float].to_f > 100
            row[:value_float] = 100
          end
     row
    end
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'OTHER')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'SE ACCOMMODATION')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'FORMER - ELL')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'CURRENT - ELL')
   .transform('mapping breakdown', HashLookup, :breakdown, map_breakdown, to: :breakdown_gsdata_id)
   .transform("removing DFG rows", DeleteRows, :district_name, 'skip')
 end

  source('ELA09.txt',[],col_sep:"\t")  do |s|
   s.transform("setting entity level", WithBlock) do |row|
     if row[:county_code] == 'STATE'
       row[:entity_level] = 'state'
     elsif row[:school_name].nil?
       row [:entity_level] = 'district'
     else row[:entity_level] = 'school'
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
       test_data_type: 'NJ PARCC',
       gsdata_test_data_type_id: 289,
       subject: 'ELA',
       academic_gsdata_id: 4,
       grade: 9, 
       notes: 'DXT-2557: NJ NJ PARCC',
       description: 'Statewide assessments have been used for decades in New Jersey and are designed to measure student progress toward achieving our academic standards. PARCC is a multi-state consortium that allows states, including New Jersey, to pool resources and expertise to develop a meaningful, comparable high-quality assessment - one that can be used to guide our efforts to continually improve our educational system by supporting teaching and learning, identifying struggling schools, informing teacher development, and providing parents with feedback on their own child\'s strengths and challenges.'
     })
   .transform("Rename columns",MultiFieldRenamer,
     {
       subgroup_type: :breakdown,
       valid_scores: :number_tested
     })
   .transform("Delete rows where number tested is less than 10 ",DeleteRows, :number_tested, '0','1','2','3','4','5','6','7','8','9')
   .transform('delete * rows', DeleteRows, :l1_percent, '*')
   .transform('prof and above',SumValues,:prof_and_above, :l4_percent,:l5_percent)
   .transform('transposing prof bands', Transposer, :proficiency_band, :value_float, :l1_percent, :l2_percent, :l3_percent, :l4_percent, :l5_percent, :prof_and_above)
   .transform("mapping proficiency bands",
     HashLookup, :proficiency_band, map_prof_band, to: :proficiency_band_gsdata_id)
   .transform('delete * and blank rows in value_float', DeleteRows, :value_float, '*', nil)
   .transform("fix special cases for prof and above", WithBlock) do |row|
          if row[:value_float].to_f < 0
            row[:value_float] = 0
          elsif row[:value_float].to_f > 100
            row[:value_float] = 100
          end
     row
    end
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'OTHER')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'SE ACCOMMODATION')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'FORMER - ELL')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'CURRENT - ELL')
   .transform('mapping breakdown', HashLookup, :breakdown, map_breakdown, to: :breakdown_gsdata_id)
   .transform("removing DFG rows", DeleteRows, :district_name, 'skip')
 end

 source('ELA010.txt',[],col_sep:"\t")  do |s|
   s.transform("setting entity level", WithBlock) do |row|
     if row[:county_code] == 'STATE'
       row[:entity_level] = 'state'
     elsif row[:school_name].nil?
       row [:entity_level] = 'district'
     else row[:entity_level] = 'school'
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
       test_data_type: 'NJ PARCC',
       gsdata_test_data_type_id: 289,
       subject: 'ELA',
       academic_gsdata_id: 4,
       grade: 10, 
       notes: 'DXT-2557: NJ NJ PARCC',
       description: 'Statewide assessments have been used for decades in New Jersey and are designed to measure student progress toward achieving our academic standards. PARCC is a multi-state consortium that allows states, including New Jersey, to pool resources and expertise to develop a meaningful, comparable high-quality assessment - one that can be used to guide our efforts to continually improve our educational system by supporting teaching and learning, identifying struggling schools, informing teacher development, and providing parents with feedback on their own child\'s strengths and challenges.'
     })
   .transform("Rename columns",MultiFieldRenamer,
     {
       subgroup_type: :breakdown,
       valid_scores: :number_tested
     })
   .transform("Delete rows where number tested is less than 10 ",DeleteRows, :number_tested, '0','1','2','3','4','5','6','7','8','9')
   .transform('delete * rows', DeleteRows, :l1_percent, '*')
   .transform('prof and above',SumValues,:prof_and_above, :l4_percent,:l5_percent)
   .transform('transposing prof bands', Transposer, :proficiency_band, :value_float, :l1_percent, :l2_percent, :l3_percent, :l4_percent, :l5_percent, :prof_and_above)
   .transform("mapping proficiency bands",
     HashLookup, :proficiency_band, map_prof_band, to: :proficiency_band_gsdata_id)
   .transform('delete * and blank rows in value_float', DeleteRows, :value_float, '*', nil)
   .transform("fix special cases for prof and above", WithBlock) do |row|
          if row[:value_float].to_f < 0
            row[:value_float] = 0
          elsif row[:value_float].to_f > 100
            row[:value_float] = 100
          end
     row
    end
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'OTHER')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'SE ACCOMMODATION')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'FORMER - ELL')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'CURRENT - ELL')
   .transform('mapping breakdown', HashLookup, :breakdown, map_breakdown, to: :breakdown_gsdata_id)
   .transform("removing DFG rows", DeleteRows, :district_name, 'skip')
 end

 source('ELA011.txt',[],col_sep:"\t")  do |s|
   s.transform("setting entity level", WithBlock) do |row|
     if row[:county_code] == 'STATE'
       row[:entity_level] = 'state'
     elsif row[:school_name].nil?
       row [:entity_level] = 'district'
     else row[:entity_level] = 'school'
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
       test_data_type: 'NJ PARCC',
       gsdata_test_data_type_id: 289,
       subject: 'ELA',
       academic_gsdata_id: 4,
       grade: 11, 
       notes: 'DXT-2557: NJ NJ PARCC',
       description: 'Statewide assessments have been used for decades in New Jersey and are designed to measure student progress toward achieving our academic standards. PARCC is a multi-state consortium that allows states, including New Jersey, to pool resources and expertise to develop a meaningful, comparable high-quality assessment - one that can be used to guide our efforts to continually improve our educational system by supporting teaching and learning, identifying struggling schools, informing teacher development, and providing parents with feedback on their own child\'s strengths and challenges.'
     })
   .transform("Rename columns",MultiFieldRenamer,
     {
       subgroup_type: :breakdown,
       valid_scores: :number_tested
     })
   .transform("Delete rows where number tested is less than 10 ",DeleteRows, :number_tested, '0','1','2','3','4','5','6','7','8','9')
   .transform('delete * rows', DeleteRows, :l1_percent, '*')
   .transform('prof and above',SumValues,:prof_and_above, :l4_percent,:l5_percent)
   .transform('transposing prof bands', Transposer, :proficiency_band, :value_float, :l1_percent, :l2_percent, :l3_percent, :l4_percent, :l5_percent, :prof_and_above)
   .transform("mapping proficiency bands",
     HashLookup, :proficiency_band, map_prof_band, to: :proficiency_band_gsdata_id)
   .transform('delete * and blank rows in value_float', DeleteRows, :value_float, '*', nil)
   .transform("fix special cases for prof and above", WithBlock) do |row|
          if row[:value_float].to_f < 0
            row[:value_float] = 0
          elsif row[:value_float].to_f > 100
            row[:value_float] = 100
          end
     row
    end
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'OTHER')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'SE ACCOMMODATION')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'FORMER - ELL')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'CURRENT - ELL')
   .transform('mapping breakdown', HashLookup, :breakdown, map_breakdown, to: :breakdown_gsdata_id)
   .transform("removing DFG rows", DeleteRows, :district_name, 'skip')
 end

 source('MAT03.txt',[],col_sep:"\t")  do |s|
   s.transform("setting entity level", WithBlock) do |row|
     if row[:county_code] == 'STATE'
       row[:entity_level] = 'state'
     elsif row[:school_name].nil?
       row [:entity_level] = 'district'
     else row[:entity_level] = 'school'
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
       test_data_type: 'NJ PARCC',
       gsdata_test_data_type_id: 289,
       subject: 'Math',
       academic_gsdata_id: 5,
       grade: 3, 
       notes: 'DXT-2557: NJ NJ PARCC',
       description: 'Statewide assessments have been used for decades in New Jersey and are designed to measure student progress toward achieving our academic standards. PARCC is a multi-state consortium that allows states, including New Jersey, to pool resources and expertise to develop a meaningful, comparable high-quality assessment - one that can be used to guide our efforts to continually improve our educational system by supporting teaching and learning, identifying struggling schools, informing teacher development, and providing parents with feedback on their own child\'s strengths and challenges.'
     })
   .transform("Rename columns",MultiFieldRenamer,
     {
       subgroup_type: :breakdown,
       valid_scores: :number_tested
     })
   .transform("Delete rows where number tested is less than 10 ",DeleteRows, :number_tested, '0','1','2','3','4','5','6','7','8','9')
   .transform('delete * rows', DeleteRows, :l1_percent, '*')
   .transform('prof and above',SumValues,:prof_and_above, :l4_percent,:l5_percent)
   .transform('transposing prof bands', Transposer, :proficiency_band, :value_float, :l1_percent, :l2_percent, :l3_percent, :l4_percent, :l5_percent, :prof_and_above)
   .transform("mapping proficiency bands",
     HashLookup, :proficiency_band, map_prof_band, to: :proficiency_band_gsdata_id)
   .transform('delete * and blank rows in value_float', DeleteRows, :value_float, '*', nil)
   .transform("fix special cases for prof and above", WithBlock) do |row|
          if row[:value_float].to_f < 0
            row[:value_float] = 0
          elsif row[:value_float].to_f > 100
            row[:value_float] = 100
          end
     row
    end
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'OTHER')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'SE ACCOMMODATION')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'FORMER - ELL')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'CURRENT - ELL')
   .transform('mapping breakdown', HashLookup, :breakdown, map_breakdown, to: :breakdown_gsdata_id)
   .transform("removing DFG rows", DeleteRows, :district_name, 'skip')
 end

 source('MAT04.txt',[],col_sep:"\t")  do |s|
   s.transform("setting entity level", WithBlock) do |row|
     if row[:county_code] == 'STATE'
       row[:entity_level] = 'state'
     elsif row[:school_name].nil?
       row [:entity_level] = 'district'
     else row[:entity_level] = 'school'
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
       test_data_type: 'NJ PARCC',
       gsdata_test_data_type_id: 289,
       subject: 'Math',
       academic_gsdata_id: 5,
       grade: 4, 
       notes: 'DXT-2557: NJ NJ PARCC',
       description: 'Statewide assessments have been used for decades in New Jersey and are designed to measure student progress toward achieving our academic standards. PARCC is a multi-state consortium that allows states, including New Jersey, to pool resources and expertise to develop a meaningful, comparable high-quality assessment - one that can be used to guide our efforts to continually improve our educational system by supporting teaching and learning, identifying struggling schools, informing teacher development, and providing parents with feedback on their own child\'s strengths and challenges.'
     })
   .transform("Rename columns",MultiFieldRenamer,
     {
       subgroup_type: :breakdown,
       valid_scores: :number_tested
     })
   .transform("Delete rows where number tested is less than 10 ",DeleteRows, :number_tested, '0','1','2','3','4','5','6','7','8','9')
   .transform('delete * rows', DeleteRows, :l1_percent, '*')
   .transform('prof and above',SumValues,:prof_and_above, :l4_percent,:l5_percent)
   .transform('transposing prof bands', Transposer, :proficiency_band, :value_float, :l1_percent, :l2_percent, :l3_percent, :l4_percent, :l5_percent, :prof_and_above)
   .transform("mapping proficiency bands",
     HashLookup, :proficiency_band, map_prof_band, to: :proficiency_band_gsdata_id)
   .transform('delete * and blank rows in value_float', DeleteRows, :value_float, '*', nil)
   .transform("fix special cases for prof and above", WithBlock) do |row|
          if row[:value_float].to_f < 0
            row[:value_float] = 0
          elsif row[:value_float].to_f > 100
            row[:value_float] = 100
          end
     row
    end
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'OTHER')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'SE ACCOMMODATION')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'FORMER - ELL')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'CURRENT - ELL')
   .transform('mapping breakdown', HashLookup, :breakdown, map_breakdown, to: :breakdown_gsdata_id)
   .transform("removing DFG rows", DeleteRows, :district_name, 'skip')
 end

 source('MAT05.txt',[],col_sep:"\t")  do |s|
   s.transform("setting entity level", WithBlock) do |row|
     if row[:county_code] == 'STATE'
       row[:entity_level] = 'state'
     elsif row[:school_name].nil?
       row [:entity_level] = 'district'
     else row[:entity_level] = 'school'
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
       test_data_type: 'NJ PARCC',
       gsdata_test_data_type_id: 289,
       subject: 'Math',
       academic_gsdata_id: 5,
       grade: 5, 
       notes: 'DXT-2557: NJ NJ PARCC',
       description: 'Statewide assessments have been used for decades in New Jersey and are designed to measure student progress toward achieving our academic standards. PARCC is a multi-state consortium that allows states, including New Jersey, to pool resources and expertise to develop a meaningful, comparable high-quality assessment - one that can be used to guide our efforts to continually improve our educational system by supporting teaching and learning, identifying struggling schools, informing teacher development, and providing parents with feedback on their own child\'s strengths and challenges.'
     })
   .transform("Rename columns",MultiFieldRenamer,
     {
       subgroup_type: :breakdown,
       valid_scores: :number_tested
     })
   .transform("Delete rows where number tested is less than 10 ",DeleteRows, :number_tested, '0','1','2','3','4','5','6','7','8','9')
   .transform('delete * rows', DeleteRows, :l1_percent, '*')
   .transform('prof and above',SumValues,:prof_and_above, :l4_percent,:l5_percent)
   .transform('transposing prof bands', Transposer, :proficiency_band, :value_float, :l1_percent, :l2_percent, :l3_percent, :l4_percent, :l5_percent, :prof_and_above)
   .transform("mapping proficiency bands",
     HashLookup, :proficiency_band, map_prof_band, to: :proficiency_band_gsdata_id)
   .transform('delete * and blank rows in value_float', DeleteRows, :value_float, '*', nil)
   .transform("fix special cases for prof and above", WithBlock) do |row|
          if row[:value_float].to_f < 0
            row[:value_float] = 0
          elsif row[:value_float].to_f > 100
            row[:value_float] = 100
          end
     row
    end
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'OTHER')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'SE ACCOMMODATION')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'FORMER - ELL')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'CURRENT - ELL')
   .transform('mapping breakdown', HashLookup, :breakdown, map_breakdown, to: :breakdown_gsdata_id)
   .transform("removing DFG rows", DeleteRows, :district_name, 'skip')
 end

 source('MAT06.txt',[],col_sep:"\t")  do |s|
   s.transform("setting entity level", WithBlock) do |row|
     if row[:county_code] == 'STATE'
       row[:entity_level] = 'state'
     elsif row[:school_name].nil?
       row [:entity_level] = 'district'
     else row[:entity_level] = 'school'
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
       test_data_type: 'NJ PARCC',
       gsdata_test_data_type_id: 289,
       subject: 'Math',
       academic_gsdata_id: 5,
       grade: 6, 
       notes: 'DXT-2557: NJ NJ PARCC',
       description: 'Statewide assessments have been used for decades in New Jersey and are designed to measure student progress toward achieving our academic standards. PARCC is a multi-state consortium that allows states, including New Jersey, to pool resources and expertise to develop a meaningful, comparable high-quality assessment - one that can be used to guide our efforts to continually improve our educational system by supporting teaching and learning, identifying struggling schools, informing teacher development, and providing parents with feedback on their own child\'s strengths and challenges.'
     })
   .transform("Rename columns",MultiFieldRenamer,
     {
       subgroup_type: :breakdown,
       valid_scores: :number_tested
     })
   .transform("Delete rows where number tested is less than 10 ",DeleteRows, :number_tested, '0','1','2','3','4','5','6','7','8','9')
   .transform('delete * rows', DeleteRows, :l1_percent, '*')
   .transform('prof and above',SumValues,:prof_and_above, :l4_percent,:l5_percent)
   .transform('transposing prof bands', Transposer, :proficiency_band, :value_float, :l1_percent, :l2_percent, :l3_percent, :l4_percent, :l5_percent, :prof_and_above)
   .transform("mapping proficiency bands",
     HashLookup, :proficiency_band, map_prof_band, to: :proficiency_band_gsdata_id)
   .transform('delete * and blank rows in value_float', DeleteRows, :value_float, '*', nil)
   .transform("fix special cases for prof and above", WithBlock) do |row|
          if row[:value_float].to_f < 0
            row[:value_float] = 0
          elsif row[:value_float].to_f > 100
            row[:value_float] = 100
          end
     row
    end
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'OTHER')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'SE ACCOMMODATION')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'FORMER - ELL')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'CURRENT - ELL')
   .transform('mapping breakdown', HashLookup, :breakdown, map_breakdown, to: :breakdown_gsdata_id)
   .transform("removing DFG rows", DeleteRows, :district_name, 'skip')
 end

 source('MAT07.txt',[],col_sep:"\t")  do |s|
   s.transform("setting entity level", WithBlock) do |row|
     if row[:county_code] == 'STATE'
       row[:entity_level] = 'state'
     elsif row[:school_name].nil?
       row [:entity_level] = 'district'
     else row[:entity_level] = 'school'
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
       test_data_type: 'NJ PARCC',
       gsdata_test_data_type_id: 289,
       subject: 'Math',
       academic_gsdata_id: 5,
       grade: 7, 
       notes: 'DXT-2557: NJ NJ PARCC',
       description: 'Statewide assessments have been used for decades in New Jersey and are designed to measure student progress toward achieving our academic standards. PARCC is a multi-state consortium that allows states, including New Jersey, to pool resources and expertise to develop a meaningful, comparable high-quality assessment - one that can be used to guide our efforts to continually improve our educational system by supporting teaching and learning, identifying struggling schools, informing teacher development, and providing parents with feedback on their own child\'s strengths and challenges.'
     })
   .transform("Rename columns",MultiFieldRenamer,
     {
       subgroup_type: :breakdown,
       valid_scores: :number_tested
     })
   .transform("Delete rows where number tested is less than 10 ",DeleteRows, :number_tested, '0','1','2','3','4','5','6','7','8','9')
   .transform('delete * rows', DeleteRows, :l1_percent, '*')
   .transform('prof and above',SumValues,:prof_and_above, :l4_percent,:l5_percent)
   .transform('transposing prof bands', Transposer, :proficiency_band, :value_float, :l1_percent, :l2_percent, :l3_percent, :l4_percent, :l5_percent, :prof_and_above)
   .transform("mapping proficiency bands",
     HashLookup, :proficiency_band, map_prof_band, to: :proficiency_band_gsdata_id)
   .transform('delete * and blank rows in value_float', DeleteRows, :value_float, '*', nil)
   .transform("fix special cases for prof and above", WithBlock) do |row|
          if row[:value_float].to_f < 0
            row[:value_float] = 0
          elsif row[:value_float].to_f > 100
            row[:value_float] = 100
          end
     row
    end
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'OTHER')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'SE ACCOMMODATION')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'FORMER - ELL')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'CURRENT - ELL')
   .transform('mapping breakdown', HashLookup, :breakdown, map_breakdown, to: :breakdown_gsdata_id)
   .transform("removing DFG rows", DeleteRows, :district_name, 'skip')
 end

 source('MAT08.txt',[],col_sep:"\t")  do |s|
   s.transform("setting entity level", WithBlock) do |row|
     if row[:county_code] == 'STATE'
       row[:entity_level] = 'state'
     elsif row[:school_name].nil?
       row [:entity_level] = 'district'
     else row[:entity_level] = 'school'
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
       test_data_type: 'NJ PARCC',
       gsdata_test_data_type_id: 289,
       subject: 'Math',
       academic_gsdata_id: 5,
       grade: 8, 
       notes: 'DXT-2557: NJ NJ PARCC',
       description: 'Statewide assessments have been used for decades in New Jersey and are designed to measure student progress toward achieving our academic standards. PARCC is a multi-state consortium that allows states, including New Jersey, to pool resources and expertise to develop a meaningful, comparable high-quality assessment - one that can be used to guide our efforts to continually improve our educational system by supporting teaching and learning, identifying struggling schools, informing teacher development, and providing parents with feedback on their own child\'s strengths and challenges.'
     })
   .transform("Rename columns",MultiFieldRenamer,
     {
       subgroup_type: :breakdown,
       valid_scores: :number_tested
     })
   .transform("Delete rows where number tested is less than 10 ",DeleteRows, :number_tested, '0','1','2','3','4','5','6','7','8','9')
   .transform('delete * rows', DeleteRows, :l1_percent, '*')
   .transform('prof and above',SumValues,:prof_and_above, :l4_percent,:l5_percent)
   .transform('transposing prof bands', Transposer, :proficiency_band, :value_float, :l1_percent, :l2_percent, :l3_percent, :l4_percent, :l5_percent, :prof_and_above)
   .transform("mapping proficiency bands",
     HashLookup, :proficiency_band, map_prof_band, to: :proficiency_band_gsdata_id)
   .transform('delete * and blank rows in value_float', DeleteRows, :value_float, '*', nil)
   .transform("fix special cases for prof and above", WithBlock) do |row|
          if row[:value_float].to_f < 0
            row[:value_float] = 0
          elsif row[:value_float].to_f > 100
            row[:value_float] = 100
          end
     row
    end
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'OTHER')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'SE ACCOMMODATION')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'FORMER - ELL')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'CURRENT - ELL')
   .transform('mapping breakdown', HashLookup, :breakdown, map_breakdown, to: :breakdown_gsdata_id)
   .transform("removing DFG rows", DeleteRows, :district_name, 'skip')
 end

 source('MATALG1.txt',[],col_sep:"\t")  do |s|
   s.transform("setting entity level", WithBlock) do |row|
     if row[:county_code] == 'STATE'
       row[:entity_level] = 'state'
     elsif row[:school_name].nil?
       row [:entity_level] = 'district'
     else row[:entity_level] = 'school'
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
   .transform("Removing grade rows", WithBlock) do |row|
     if row[:subgroup_type] =~ /GRADE/
       row[:grade] = 'skip'
     else row[:grade] = 'All'
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
       test_data_type: 'NJ PARCC',
       gsdata_test_data_type_id: 289,
       subject: 'Algebra I',
       academic_gsdata_id: 6, 
       notes: 'DXT-2557: NJ NJ PARCC',
       description: 'Statewide assessments have been used for decades in New Jersey and are designed to measure student progress toward achieving our academic standards. PARCC is a multi-state consortium that allows states, including New Jersey, to pool resources and expertise to develop a meaningful, comparable high-quality assessment - one that can be used to guide our efforts to continually improve our educational system by supporting teaching and learning, identifying struggling schools, informing teacher development, and providing parents with feedback on their own child\'s strengths and challenges.'
     })
   .transform("Rename columns",MultiFieldRenamer,
     {
       subgroup_type: :breakdown,
       valid_scores: :number_tested
     })
   .transform("Delete rows where number tested is less than 10 ",DeleteRows, :number_tested, '0','1','2','3','4','5','6','7','8','9')
   .transform('delete * rows', DeleteRows, :l1_percent, '*')
   .transform('prof and above',SumValues,:prof_and_above, :l4_percent,:l5_percent)
   .transform('transposing prof bands', Transposer, :proficiency_band, :value_float, :l1_percent, :l2_percent, :l3_percent, :l4_percent, :l5_percent, :prof_and_above)
   .transform("mapping proficiency bands",
     HashLookup, :proficiency_band, map_prof_band, to: :proficiency_band_gsdata_id)
   .transform('delete * and blank rows in value_float', DeleteRows, :value_float, '*', nil)
   .transform("fix special cases for prof and above", WithBlock) do |row|
          if row[:value_float].to_f < 0
            row[:value_float] = 0
          elsif row[:value_float].to_f > 100
            row[:value_float] = 100
          end
     row
    end
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'OTHER')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'SE ACCOMMODATION')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'FORMER - ELL')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'CURRENT - ELL')
   .transform('mapping breakdown', HashLookup, :breakdown, map_breakdown, to: :breakdown_gsdata_id)
   .transform("removing DFG rows", DeleteRows, :district_name, 'skip')
   .transform("removing grade rows", DeleteRows, :grade, 'skip')
 end

 source('MATALG2.txt',[],col_sep:"\t")  do |s|
   s.transform("setting entity level", WithBlock) do |row|
     if row[:county_code] == 'STATE'
       row[:entity_level] = 'state'
     elsif row[:school_name].nil?
       row [:entity_level] = 'district'
     else row[:entity_level] = 'school'
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
   .transform("Removing grade rows", WithBlock) do |row|
     if row[:subgroup_type] =~ /GRADE/
       row[:grade] = 'skip'
     else row[:grade] = 'All'
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
       test_data_type: 'NJ PARCC',
       gsdata_test_data_type_id: 289,
       subject: 'Algebra II',
       academic_gsdata_id: 10, 
       notes: 'DXT-2557: NJ NJ PARCC',
       description: 'Statewide assessments have been used for decades in New Jersey and are designed to measure student progress toward achieving our academic standards. PARCC is a multi-state consortium that allows states, including New Jersey, to pool resources and expertise to develop a meaningful, comparable high-quality assessment - one that can be used to guide our efforts to continually improve our educational system by supporting teaching and learning, identifying struggling schools, informing teacher development, and providing parents with feedback on their own child\'s strengths and challenges.'
     })
   .transform("Rename columns",MultiFieldRenamer,
     {
       subgroup_type: :breakdown,
       valid_scores: :number_tested
     })
   .transform("Delete rows where number tested is less than 10 ",DeleteRows, :number_tested, '0','1','2','3','4','5','6','7','8','9')
   .transform('delete * rows', DeleteRows, :l1_percent, '*')
   .transform('prof and above',SumValues,:prof_and_above, :l4_percent,:l5_percent)
   .transform('transposing prof bands', Transposer, :proficiency_band, :value_float, :l1_percent, :l2_percent, :l3_percent, :l4_percent, :l5_percent, :prof_and_above)
   .transform("mapping proficiency bands",
     HashLookup, :proficiency_band, map_prof_band, to: :proficiency_band_gsdata_id)
   .transform('delete * and blank rows in value_float', DeleteRows, :value_float, '*', nil)
   .transform("fix special cases for prof and above", WithBlock) do |row|
          if row[:value_float].to_f < 0
            row[:value_float] = 0
          elsif row[:value_float].to_f > 100
            row[:value_float] = 100
          end
     row
    end
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'OTHER')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'SE ACCOMMODATION')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'FORMER - ELL')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'CURRENT - ELL')
   .transform('mapping breakdown', HashLookup, :breakdown, map_breakdown, to: :breakdown_gsdata_id)
   .transform("removing DFG rows", DeleteRows, :district_name, 'skip')
   .transform("removing grade rows", DeleteRows, :grade, 'skip')
 end

 source('MATGEO.txt',[],col_sep:"\t")  do |s|
   s.transform("setting entity level", WithBlock) do |row|
     if row[:county_code] == 'STATE'
       row[:entity_level] = 'state'
     elsif row[:school_name].nil?
       row [:entity_level] = 'district'
     else row[:entity_level] = 'school'
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
   .transform("Removing grade rows", WithBlock) do |row|
     if row[:subgroup_type] =~ /GRADE/
       row[:grade] = 'skip'
     else row[:grade] = 'All'
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
       test_data_type: 'NJ PARCC',
       gsdata_test_data_type_id: 289,
       subject: 'Geometry',
       academic_gsdata_id: 8, 
       notes: 'DXT-2557: NJ NJ PARCC',
       description: 'Statewide assessments have been used for decades in New Jersey and are designed to measure student progress toward achieving our academic standards. PARCC is a multi-state consortium that allows states, including New Jersey, to pool resources and expertise to develop a meaningful, comparable high-quality assessment - one that can be used to guide our efforts to continually improve our educational system by supporting teaching and learning, identifying struggling schools, informing teacher development, and providing parents with feedback on their own child\'s strengths and challenges.'
     })
   .transform("Rename columns",MultiFieldRenamer,
     {
       subgroup_type: :breakdown,
       valid_scores: :number_tested
     })
   .transform("Delete rows where number tested is less than 10 ",DeleteRows, :number_tested, '0','1','2','3','4','5','6','7','8','9')
   .transform('delete * rows', DeleteRows, :l1_percent, '*')
   .transform('prof and above',SumValues,:prof_and_above, :l4_percent,:l5_percent)
   .transform('transposing prof bands', Transposer, :proficiency_band, :value_float, :l1_percent, :l2_percent, :l3_percent, :l4_percent, :l5_percent, :prof_and_above)
   .transform("mapping proficiency bands",
     HashLookup, :proficiency_band, map_prof_band, to: :proficiency_band_gsdata_id)
   .transform('delete * and blank rows in value_float', DeleteRows, :value_float, '*', nil)
   .transform("fix special cases for prof and above", WithBlock) do |row|
          if row[:value_float].to_f < 0
            row[:value_float] = 0
          elsif row[:value_float].to_f > 100
            row[:value_float] = 100
          end
     row
    end
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'OTHER')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'SE ACCOMMODATION')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'FORMER - ELL')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'CURRENT - ELL')
   .transform('mapping breakdown', HashLookup, :breakdown, map_breakdown, to: :breakdown_gsdata_id)
   .transform("removing DFG rows", DeleteRows, :district_name, 'skip')
   .transform("removing grade rows", DeleteRows, :grade, 'skip')
 end

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
          if row[:value_float].to_f < 0
            row[:value_float] = 0
          elsif row[:value_float].to_f > 100
            row[:value_float] = 100
          end
     row
    end
   .transform("mapping proficiency bands",
     HashLookup, :proficiency_band, map_prof_band, to: :proficiency_band_gsdata_id)
   .transform('mapping prof cols to breakdown id', HashLookup, :proficiency_band, map_prof_to_breakdown, to: :breakdown_gsdata_id)
   .transform('mapping breakdown id to breakdown names', HashLookup, :breakdown_gsdata_id, map_breakdown_to_name, to: :breakdown)
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
          if row[:value_float].to_f < 0
            row[:value_float] = 0
          elsif row[:value_float].to_f > 100
            row[:value_float] = 100
          end
     row
    end  
   .transform("mapping proficiency bands",
     HashLookup, :proficiency_band, map_prof_band, to: :proficiency_band_gsdata_id)
   .transform('mapping prof cols to breakdown id', HashLookup, :proficiency_band, map_prof_to_breakdown, to: :breakdown_gsdata_id)
   .transform('mapping breakdown id to breakdown names', HashLookup, :breakdown_gsdata_id, map_breakdown_to_name, to: :breakdown)
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
 end

 source('ask_04_ethnic.txt',[],col_sep:"\t")  do |s|
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
   .transform('prof and above',SumValues,:w_prof_and_above, :w_p_scie,:w_ap_scie)
   .transform('prof and above',SumValues,:b_prof_and_above, :b_p_scie,:b_ap_scie)
   .transform('prof and above',SumValues,:a_prof_and_above, :a_p_scie,:a_ap_scie)
   .transform('prof and above',SumValues,:p_prof_and_above, :p_p_scie,:p_ap_scie)
   .transform('prof and above',SumValues,:h_prof_and_above, :h_p_scie,:h_ap_scie)
   .transform('prof and above',SumValues,:i_prof_and_above, :i_p_scie,:i_ap_scie)
   .transform('transposing prof bands', Transposer, :proficiency_band, :value_float, :w_prof_and_above, :w_pp_scie, :w_p_scie, :w_ap_scie, :b_prof_and_above, :b_pp_scie, :b_p_scie, :b_ap_scie, :a_prof_and_above, :a_pp_scie, :a_p_scie, :a_ap_scie, :p_prof_and_above, :p_pp_scie, :p_p_scie, :p_ap_scie, :h_prof_and_above, :h_pp_scie, :h_p_scie, :h_ap_scie, :i_prof_and_above, :i_pp_scie, :i_p_scie, :i_ap_scie)
   .transform('delete * and blank rows in value_float', DeleteRows, :value_float, '*', nil)
   .transform("fix special cases for prof and above", WithBlock) do |row|
          if row[:value_float].to_f < 0
            row[:value_float] = 0
          elsif row[:value_float].to_f > 100
            row[:value_float] = 100
          end
     row
    end  
   .transform("mapping proficiency bands",
     HashLookup, :proficiency_band, map_prof_band, to: :proficiency_band_gsdata_id)
   .transform('mapping prof cols to breakdown id', HashLookup, :proficiency_band, map_prof_to_breakdown, to: :breakdown_gsdata_id)
   .transform('mapping breakdown id to breakdown names', HashLookup, :breakdown_gsdata_id, map_breakdown_to_name, to: :breakdown)
   .transform("mapping number tested", WithBlock) do |row|
     if row[:breakdown_gsdata_id] == 21
       row[:number_tested] = row[:w_enroll_scie]
     elsif row[:breakdown_gsdata_id] == 17
       row[:number_tested] = row[:b_enroll_scie]
     elsif row[:breakdown_gsdata_id] == 16
       row[:number_tested] = row[:a_enroll_scie]
     elsif row[:breakdown_gsdata_id] == 37
       row[:number_tested] = row[:p_enroll_scie]
     elsif row[:breakdown_gsdata_id] == 19
       row[:number_tested] = row[:h_enroll_scie]
     elsif row[:breakdown_gsdata_id] == 18
       row[:number_tested] = row[:i_enroll_scie]
     elsif row[:breakdown_gsdata_id] == 20
       row[:number_tested] = row[:p_enroll_scie]
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

 source('ask_04_econ.txt',[],col_sep:"\t")  do |s|
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
   .transform('prof and above',SumValues,:ecdis_y_prof_and_above, :ecdis_y_p_scie,:ecdis_y_ap_scie)
   .transform('prof and above',SumValues,:ecdis_n_prof_and_above, :ecdis_n_p_scie,:ecdis_n_ap_scie)
   .transform('transposing prof bands', Transposer, :proficiency_band, :value_float, :ecdis_y_prof_and_above, :ecdis_y_pp_scie, :ecdis_y_p_scie, :ecdis_y_ap_scie, :ecdis_n_prof_and_above, :ecdis_n_pp_scie, :ecdis_n_p_scie, :ecdis_n_ap_scie)
   .transform('delete * and blank rows in value_float', DeleteRows, :value_float, '*', nil)
   .transform("fix special cases for prof and above", WithBlock) do |row|
          if row[:value_float].to_f < 0
            row[:value_float] = 0
          elsif row[:value_float].to_f > 100
            row[:value_float] = 100
          end
     row
    end  
   .transform("mapping proficiency bands",
     HashLookup, :proficiency_band, map_prof_band, to: :proficiency_band_gsdata_id)
   .transform('mapping prof cols to breakdown id', HashLookup, :proficiency_band, map_prof_to_breakdown, to: :breakdown_gsdata_id)
   .transform('mapping breakdown id to breakdown names', HashLookup, :breakdown_gsdata_id, map_breakdown_to_name, to: :breakdown)
   .transform("mapping number tested", WithBlock) do |row|
     if row[:breakdown_gsdata_id] == 23
       row[:number_tested] = row[:ecdis_y_enroll_scie]
     elsif row[:breakdown_gsdata_id] == 24
       row[:number_tested] = row[:ecdis_n_enroll_scie]
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
 
 source('ask_08.txt',[],col_sep:"\t")  do |s|
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
       grade: 8, 
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
          if row[:value_float].to_f < 0
            row[:value_float] = 0
          elsif row[:value_float].to_f > 100
            row[:value_float] = 100
          end
     row
    end  
   .transform("mapping proficiency bands",
     HashLookup, :proficiency_band, map_prof_band, to: :proficiency_band_gsdata_id)
   .transform('mapping prof cols to breakdown id', HashLookup, :proficiency_band, map_prof_to_breakdown, to: :breakdown_gsdata_id)
   .transform('mapping breakdown id to breakdown names', HashLookup, :breakdown_gsdata_id, map_breakdown_to_name, to: :breakdown)
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

 source('ask_08_gender.txt',[],col_sep:"\t")  do |s|
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
       grade: 8, 
       notes: 'DXT-2557: NJ NJ ASK',
       description: 'In 2016-2017 New Jersey used the New Jersey Assessment of Skills and Knowledge (NJ ASK) to test students in grades 4 and 8 in science.  The NJ ASK is a standards-based test, which means it measures how well students are mastering specific skills defined for each grade by the state of New Jersey.  The goal is for all students to score at or above the proficient level.'
     })
   .transform('prof and above',SumValues,:f_prof_and_above, :f_p_scie,:f_ap_scie)
   .transform('prof and above',SumValues,:m_prof_and_above, :m_p_scie,:m_ap_scie)
   .transform('transposing prof bands', Transposer, :proficiency_band, :value_float, :f_prof_and_above, :f_pp_scie, :f_p_scie, :f_ap_scie, :m_prof_and_above, :m_pp_scie, :m_p_scie, :m_ap_scie)
   .transform('delete * and blank rows in value_float', DeleteRows, :value_float, '*', nil)
   .transform("fix special cases for prof and above", WithBlock) do |row|
          if row[:value_float].to_f < 0
            row[:value_float] = 0
          elsif row[:value_float].to_f > 100
            row[:value_float] = 100
          end
     row
    end  
   .transform("mapping proficiency bands",
     HashLookup, :proficiency_band, map_prof_band, to: :proficiency_band_gsdata_id)
   .transform('mapping prof cols to breakdown id', HashLookup, :proficiency_band, map_prof_to_breakdown, to: :breakdown_gsdata_id)
   .transform('mapping breakdown id to breakdown names', HashLookup, :breakdown_gsdata_id, map_breakdown_to_name, to: :breakdown)
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
 end

  source('ask_08_ethnic.txt',[],col_sep:"\t")  do |s|
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
       grade: 8, 
       notes: 'DXT-2557: NJ NJ ASK',
       description: 'In 2016-2017 New Jersey used the New Jersey Assessment of Skills and Knowledge (NJ ASK) to test students in grades 4 and 8 in science.  The NJ ASK is a standards-based test, which means it measures how well students are mastering specific skills defined for each grade by the state of New Jersey.  The goal is for all students to score at or above the proficient level.'
     })
   .transform('prof and above',SumValues,:w_prof_and_above, :w_p_scie,:w_ap_scie)
   .transform('prof and above',SumValues,:b_prof_and_above, :b_p_scie,:b_ap_scie)
   .transform('prof and above',SumValues,:a_prof_and_above, :a_p_scie,:a_ap_scie)
   .transform('prof and above',SumValues,:p_prof_and_above, :p_p_scie,:p_ap_scie)
   .transform('prof and above',SumValues,:h_prof_and_above, :h_p_scie,:h_ap_scie)
   .transform('prof and above',SumValues,:i_prof_and_above, :i_p_scie,:i_ap_scie)
   .transform('transposing prof bands', Transposer, :proficiency_band, :value_float, :w_prof_and_above, :w_pp_scie, :w_p_scie, :w_ap_scie, :b_prof_and_above, :b_pp_scie, :b_p_scie, :b_ap_scie, :a_prof_and_above, :a_pp_scie, :a_p_scie, :a_ap_scie, :p_prof_and_above, :p_pp_scie, :p_p_scie, :p_ap_scie, :h_prof_and_above, :h_pp_scie, :h_p_scie, :h_ap_scie, :i_prof_and_above, :i_pp_scie, :i_p_scie, :i_ap_scie)
   .transform('delete * and blank rows in value_float', DeleteRows, :value_float, '*', nil)
   .transform("fix special cases for prof and above", WithBlock) do |row|
          if row[:value_float].to_f < 0
            row[:value_float] = 0
          elsif row[:value_float].to_f > 100
            row[:value_float] = 100
          end
     row
    end  
   .transform("mapping proficiency bands",
     HashLookup, :proficiency_band, map_prof_band, to: :proficiency_band_gsdata_id)
   .transform('mapping prof cols to breakdown id', HashLookup, :proficiency_band, map_prof_to_breakdown, to: :breakdown_gsdata_id)
   .transform('mapping breakdown id to breakdown names', HashLookup, :breakdown_gsdata_id, map_breakdown_to_name, to: :breakdown)
   .transform("mapping number tested", WithBlock) do |row|
     if row[:breakdown_gsdata_id] == 21
       row[:number_tested] = row[:w_enroll_scie]
     elsif row[:breakdown_gsdata_id] == 17
       row[:number_tested] = row[:b_enroll_scie]
     elsif row[:breakdown_gsdata_id] == 16
       row[:number_tested] = row[:a_enroll_scie]
     elsif row[:breakdown_gsdata_id] == 37
       row[:number_tested] = row[:p_enroll_scie]
     elsif row[:breakdown_gsdata_id] == 19
       row[:number_tested] = row[:h_enroll_scie]
     elsif row[:breakdown_gsdata_id] == 18
       row[:number_tested] = row[:i_enroll_scie]
     elsif row[:breakdown_gsdata_id] == 20
       row[:number_tested] = row[:p_enroll_scie]
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

 source('ask_08_econ.txt',[],col_sep:"\t")  do |s|
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
       grade: 8, 
       notes: 'DXT-2557: NJ NJ ASK',
       description: 'In 2016-2017 New Jersey used the New Jersey Assessment of Skills and Knowledge (NJ ASK) to test students in grades 4 and 8 in science.  The NJ ASK is a standards-based test, which means it measures how well students are mastering specific skills defined for each grade by the state of New Jersey.  The goal is for all students to score at or above the proficient level.'
     })
   .transform('prof and above',SumValues,:ecdis_y_prof_and_above, :ecdis_y_p_scie,:ecdis_y_ap_scie)
   .transform('prof and above',SumValues,:ecdis_n_prof_and_above, :ecdis_n_p_scie,:ecdis_n_ap_scie)
   .transform('transposing prof bands', Transposer, :proficiency_band, :value_float, :ecdis_y_prof_and_above, :ecdis_y_pp_scie, :ecdis_y_p_scie, :ecdis_y_ap_scie, :ecdis_n_prof_and_above, :ecdis_n_pp_scie, :ecdis_n_p_scie, :ecdis_n_ap_scie)
   .transform('delete * and blank rows in value_float', DeleteRows, :value_float, '*', nil)
   .transform("fix special cases for prof and above", WithBlock) do |row|
          if row[:value_float].to_f < 0
            row[:value_float] = 0
          elsif row[:value_float].to_f > 100
            row[:value_float] = 100
          end
     row
    end  
   .transform("mapping proficiency bands",
     HashLookup, :proficiency_band, map_prof_band, to: :proficiency_band_gsdata_id)
   .transform('mapping prof cols to breakdown id', HashLookup, :proficiency_band, map_prof_to_breakdown, to: :breakdown_gsdata_id)
   .transform('mapping breakdown id to breakdown names', HashLookup, :breakdown_gsdata_id, map_breakdown_to_name, to: :breakdown)
   .transform("mapping number tested", WithBlock) do |row|
     if row[:breakdown_gsdata_id] == 23
       row[:number_tested] = row[:ecdis_y_enroll_scie]
     elsif row[:breakdown_gsdata_id] == 24
       row[:number_tested] = row[:ecdis_n_enroll_scie]
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

 source('njbct.txt',[],col_sep:"\t")  do |s|
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
       test_data_type: 'NJBCT',
       gsdata_test_data_type_id: 288,
       subject: 'Biology I',
       academic_gsdata_id: 22,
       grade: 'All', 
       notes: 'DXT-2557: NJ NJBCT',
       description: 'In 2016-2017 New Jersey used the New Jersey Biology Competency Test (NJBCT) to assess students in Biology.  The New Jersey Biology Competency Test (NJBCT) is standards-based, which means it measures how well students are mastering specific skills defined by the state of New Jersey.  The goal is for all students to score at or above the proficient level on the test.'
     })
   .transform('prof and above',SumValues,:total_prof_and_above, :total_p_scie,:total_ap_scie)
   .transform('prof and above',SumValues,:ge_prof_and_above, :ge_p_scie,:ge_ap_scie)
   .transform('prof and above',SumValues,:se_prof_and_above, :se_p_scie,:se_ap_scie)
   .transform('prof and above',SumValues,:lep_prof_and_above, :lep_p_scie,:lep_ap_scie)
   .transform('transposing prof bands', Transposer, :proficiency_band, :value_float, :total_prof_and_above, :total_pp_scie, :total_p_scie, :total_ap_scie, :ge_prof_and_above, :ge_pp_scie, :ge_p_scie, :ge_ap_scie, :se_prof_and_above, :se_pp_scie, :se_p_scie, :se_ap_scie, :lep_prof_and_above, :lep_pp_scie, :lep_p_scie, :lep_ap_scie)
   .transform('delete * and blank rows in value_float', DeleteRows, :value_float, '*', nil)
   .transform("fix special cases for prof and above", WithBlock) do |row|
          if row[:value_float].to_f < 0
            row[:value_float] = 0
          elsif row[:value_float].to_f > 100
            row[:value_float] = 100
          end
     row
    end 
   .transform("mapping proficiency bands",
     HashLookup, :proficiency_band, map_prof_band, to: :proficiency_band_gsdata_id)
   .transform('mapping prof cols to breakdown id', HashLookup, :proficiency_band, map_prof_to_breakdown, to: :breakdown_gsdata_id)
   .transform('mapping breakdown id to breakdown names', HashLookup, :breakdown_gsdata_id, map_breakdown_to_name, to: :breakdown)
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

 source('njbct_gender.txt',[],col_sep:"\t")  do |s|
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
       test_data_type: 'NJBCT',
       gsdata_test_data_type_id: 288,
       subject: 'Biology I',
       academic_gsdata_id: 22,
       grade: 'All', 
       notes: 'DXT-2557: NJ NJBCT',
       description: 'In 2016-2017 New Jersey used the New Jersey Biology Competency Test (NJBCT) to assess students in Biology.  The New Jersey Biology Competency Test (NJBCT) is standards-based, which means it measures how well students are mastering specific skills defined by the state of New Jersey.  The goal is for all students to score at or above the proficient level on the test.'
     })
   .transform('prof and above',SumValues,:f_prof_and_above, :f_p_scie,:f_ap_scie)
   .transform('prof and above',SumValues,:m_prof_and_above, :m_p_scie,:m_ap_scie)
   .transform('transposing prof bands', Transposer, :proficiency_band, :value_float, :f_prof_and_above, :f_pp_scie, :f_p_scie, :f_ap_scie, :m_prof_and_above, :m_pp_scie, :m_p_scie, :m_ap_scie)
   .transform('delete * and blank rows in value_float', DeleteRows, :value_float, '*', nil)
   .transform("fix special cases for prof and above", WithBlock) do |row|
          if row[:value_float].to_f < 0
            row[:value_float] = 0
          elsif row[:value_float].to_f > 100
            row[:value_float] = 100
          end
     row
    end 
   .transform("mapping proficiency bands",
     HashLookup, :proficiency_band, map_prof_band, to: :proficiency_band_gsdata_id)
   .transform('mapping prof cols to breakdown id', HashLookup, :proficiency_band, map_prof_to_breakdown, to: :breakdown_gsdata_id)
   .transform('mapping breakdown id to breakdown names', HashLookup, :breakdown_gsdata_id, map_breakdown_to_name, to: :breakdown)
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
 end

source('njbct_ethnic.txt',[],col_sep:"\t")  do |s|
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
       test_data_type: 'NJBCT',
       gsdata_test_data_type_id: 288,
       subject: 'Biology I',
       academic_gsdata_id: 22,
       grade: 'All', 
       notes: 'DXT-2557: NJ NJBCT',
       description: 'In 2016-2017 New Jersey used the New Jersey Biology Competency Test (NJBCT) to assess students in Biology.  The New Jersey Biology Competency Test (NJBCT) is standards-based, which means it measures how well students are mastering specific skills defined by the state of New Jersey.  The goal is for all students to score at or above the proficient level on the test.'
     })
   .transform('prof and above',SumValues,:w_prof_and_above, :w_p_scie,:w_ap_scie)
   .transform('prof and above',SumValues,:b_prof_and_above, :b_p_scie,:b_ap_scie)
   .transform('prof and above',SumValues,:a_prof_and_above, :a_p_scie,:a_ap_scie)
   .transform('prof and above',SumValues,:p_prof_and_above, :p_p_scie,:p_ap_scie)
   .transform('prof and above',SumValues,:h_prof_and_above, :h_p_scie,:h_ap_scie)
   .transform('prof and above',SumValues,:i_prof_and_above, :i_p_scie,:i_ap_scie)
   .transform('transposing prof bands', Transposer, :proficiency_band, :value_float, :w_prof_and_above, :w_pp_scie, :w_p_scie, :w_ap_scie, :b_prof_and_above, :b_pp_scie, :b_p_scie, :b_ap_scie, :a_prof_and_above, :a_pp_scie, :a_p_scie, :a_ap_scie, :p_prof_and_above, :p_pp_scie, :p_p_scie, :p_ap_scie, :h_prof_and_above, :h_pp_scie, :h_p_scie, :h_ap_scie, :i_prof_and_above, :i_pp_scie, :i_p_scie, :i_ap_scie)
   .transform('delete * and blank rows in value_float', DeleteRows, :value_float, '*', nil)
   .transform("fix special cases for prof and above", WithBlock) do |row|
          if row[:value_float].to_f < 0
            row[:value_float] = 0
          elsif row[:value_float].to_f > 100
            row[:value_float] = 100
          end
     row
    end
   .transform("mapping proficiency bands",
     HashLookup, :proficiency_band, map_prof_band, to: :proficiency_band_gsdata_id)
   .transform('mapping prof cols to breakdown id', HashLookup, :proficiency_band, map_prof_to_breakdown, to: :breakdown_gsdata_id)
   .transform('mapping breakdown id to breakdown names', HashLookup, :breakdown_gsdata_id, map_breakdown_to_name, to: :breakdown)
   .transform("mapping number tested", WithBlock) do |row|
     if row[:breakdown_gsdata_id] == 21
       row[:number_tested] = row[:w_enroll_scie]
     elsif row[:breakdown_gsdata_id] == 17
       row[:number_tested] = row[:b_enroll_scie]
     elsif row[:breakdown_gsdata_id] == 16
       row[:number_tested] = row[:a_enroll_scie]
     elsif row[:breakdown_gsdata_id] == 37
       row[:number_tested] = row[:p_enroll_scie]
     elsif row[:breakdown_gsdata_id] == 19
       row[:number_tested] = row[:h_enroll_scie]
     elsif row[:breakdown_gsdata_id] == 18
       row[:number_tested] = row[:i_enroll_scie]
     elsif row[:breakdown_gsdata_id] == 20
       row[:number_tested] = row[:p_enroll_scie]
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

 source('njbct_econ.txt',[],col_sep:"\t")  do |s|
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
       test_data_type: 'NJBCT',
       gsdata_test_data_type_id: 288,
       subject: 'Biology I',
       academic_gsdata_id: 22,
       grade: 'All', 
       notes: 'DXT-2557: NJ NJBCT',
       description: 'In 2016-2017 New Jersey used the New Jersey Biology Competency Test (NJBCT) to assess students in Biology.  The New Jersey Biology Competency Test (NJBCT) is standards-based, which means it measures how well students are mastering specific skills defined by the state of New Jersey.  The goal is for all students to score at or above the proficient level on the test.'
     })
   .transform('prof and above',SumValues,:ecdis_y_prof_and_above, :ecdis_y_p_scie,:ecdis_y_ap_scie)
   .transform('prof and above',SumValues,:ecdis_n_prof_and_above, :ecdis_n_p_scie,:ecdis_n_ap_scie)
   .transform('transposing prof bands', Transposer, :proficiency_band, :value_float, :ecdis_y_prof_and_above, :ecdis_y_pp_scie, :ecdis_y_p_scie, :ecdis_y_ap_scie, :ecdis_n_prof_and_above, :ecdis_n_pp_scie, :ecdis_n_p_scie, :ecdis_n_ap_scie)
   .transform('delete * and blank rows in value_float', DeleteRows, :value_float, '*', nil)
   .transform("fix special cases for prof and above", WithBlock) do |row|
          if row[:value_float].to_f < 0
            row[:value_float] = 0
          elsif row[:value_float].to_f > 100
            row[:value_float] = 100
          end
     row
    end
   .transform("mapping proficiency bands",
     HashLookup, :proficiency_band, map_prof_band, to: :proficiency_band_gsdata_id) 
   .transform('mapping prof cols to breakdown id', HashLookup, :proficiency_band, map_prof_to_breakdown, to: :breakdown_gsdata_id)
   .transform('mapping breakdown id to breakdown names', HashLookup, :breakdown_gsdata_id, map_breakdown_to_name, to: :breakdown)
   .transform("mapping number tested", WithBlock) do |row|
     if row[:breakdown_gsdata_id] == 23
       row[:number_tested] = row[:ecdis_y_enroll_scie]
     elsif row[:breakdown_gsdata_id] == 24
       row[:number_tested] = row[:ecdis_n_enroll_scie]
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