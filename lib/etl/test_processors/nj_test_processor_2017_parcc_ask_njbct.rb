require_relative "../test_processor"
GS::ETL::Logging.disable

class NJTestProcessor2017PARCCASKNJBCT < GS::ETL::TestProcessor

	def initialize(*args)
		super
		@year=2017
	end

	#map_subject = {
	#	'math' => 5,
	#	'ela' => 4,
	#	'algebrai' => 6,
	#	'englishii' => 21,
	#	'Math' => 5,
	#	'alg1' => 6,
	#	'ELA' => 4,
	#	'English II' => 21,
  # 'biology i' => 22
	#}

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
		'NATIVE HAWAIIAN' => 41,
    'PACIFIC ISLANDER' => 37,
		'STUDENTS WITH DISABILITIES' => 27,
		'WHITE' => 21
	}

  map_prof_to_breakdown = {
    total_pp_scie: 1,
    total_p_scie: 1,
    total_ap_scie: 1,
    total_prof_and_above: 1,
    ge_pp_scie: 30,
    ge_p_scie: 30,
    ge_ap_scie: 30,
    ge_prof_and_above: 1,
    se_pp_scie: 27,
    se_p_scie: 27,
    se_ap_scie: 27,
    se_prof_and_above: 1,
    lep_pp_scie: 32,
    lep_p_scie: 32,
    lep_ap_scie: 32,
    lep_prof_and_above: 1,
    f_pp_scie: 26,
    f_p_scie: 26,
    f_ap_scie: 26,
    f_prof_and_above: 1,
    m_pp_scie: 25,
    m_p_scie: 25,
    m_ap_scie: 25,
    m_prof_and_above: 1,
    w_pp_scie: 21,
    w_p_scie: 21,
    w_ap_scie: 21,
    w_prof_and_above: 1,
    b_pp_scie: 17,
    b_p_scie: 17,
    b_ap_scie: 17,
    b_prof_and_above: 1,
    a_pp_scie: 16,
    a_p_scie: 16,
    a_ap_scie: 16,
    a_prof_and_above: 1,
    p_pp_scie: 37,
    p_p_scie: 37,
    p_ap_scie: 37,
    p_prof_and_above: 1,
    h_pp_scie: 19,
    h_p_scie: 19,
    h_ap_scie: 19,
    h_prof_and_above: 1,
    i_pp_scie: 18,
    i_p_scie: 18,
    i_ap_scie: 18,
    i_prof_and_above: 1,
    ecdis_y_pp_scie: 23,
    ecdis_y_p_scie: 23,
    ecdis_y_ap_scie: 23,
    ecdis_y_prof_and_above: 1,
    ecdis_n_pp_scie: 24,
    ecdis_n_p_scie: 24,
    ecdis_n_ap_scie: 24,
    ecdis_n_prof_and_above: 1
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
       subject: 'ela',
       academic_gsdata_id: 4,
       grade: 3
     })
   s.transform("Rename columns",MultiFieldRenamer,
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
     else row[:state_id] = row[:state_id]
     end
     row
   end
   .transform("Fill Columns",Fill,
     {
       year: 2017,
       entity_type: 'public_charter',
       level_code: 'e,m,h',
       test_data_type: 'NJ PARCC',
       gsdata_test_data_type_id: 298,
       subject: 'ela',
       academic_gsdata_id: 4,
       grade: 4
     })
   s.transform("Rename columns",MultiFieldRenamer,
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
     else row[:state_id] = row[:state_id]
     end
     row
   end
   .transform("Fill Columns",Fill,
     {
       year: 2017,
       entity_type: 'public_charter',
       level_code: 'e,m,h',
       test_data_type: 'NJ PARCC',
       gsdata_test_data_type_id: 298,
       subject: 'ela',
       academic_gsdata_id: 4,
       grade: 5
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
     else row[:state_id] = row[:state_id]
     end
     row
   end
   .transform("Fill Columns",Fill,
     {
       year: 2017,
       entity_type: 'public_charter',
       level_code: 'e,m,h',
       test_data_type: 'NJ PARCC',
       gsdata_test_data_type_id: 298,
       subject: 'ela',
       academic_gsdata_id: 4,
       grade: 6
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
     else row[:state_id] = row[:state_id]
     end
     row
   end
   .transform("Fill Columns",Fill,
     {
       year: 2017,
       entity_type: 'public_charter',
       level_code: 'e,m,h',
       test_data_type: 'NJ PARCC',
       gsdata_test_data_type_id: 298,
       subject: 'ela',
       academic_gsdata_id: 4,
       grade: 7
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
     else row[:state_id] = row[:state_id]
     end
     row
   end
   .transform("Fill Columns",Fill,
     {
       year: 2017,
       entity_type: 'public_charter',
       level_code: 'e,m,h',
       test_data_type: 'NJ PARCC',
       gsdata_test_data_type_id: 298,
       subject: 'ela',
       academic_gsdata_id: 4,
       grade: 8
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
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'OTHER')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'SE ACCOMMODATION')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'FORMER - ELL')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'CURRENT - ELL')
   .transform('mapping breakdown', HashLookup, :breakdown, map_breakdown, to: :breakdown_gsdata_id)
   .transform("removing DFG rows", DeleteRows, :district_name, 'skip')
 end

 source('ELA10.txt',[],col_sep:"\t")  do |s|
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
     else row[:state_id] = row[:state_id]
     end
     row
   end
   .transform("Fill Columns",Fill,
     {
       year: 2017,
       entity_type: 'public_charter',
       level_code: 'e,m,h',
       test_data_type: 'NJ PARCC',
       gsdata_test_data_type_id: 298,
       subject: 'ela',
       academic_gsdata_id: 4,
       grade: 10
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
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'OTHER')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'SE ACCOMMODATION')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'FORMER - ELL')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'CURRENT - ELL')
   .transform('mapping breakdown', HashLookup, :breakdown, map_breakdown, to: :breakdown_gsdata_id)
   .transform("removing DFG rows", DeleteRows, :district_name, 'skip')
 end

 source('ELA11.txt',[],col_sep:"\t")  do |s|
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
     else row[:state_id] = row[:state_id]
     end
     row
   end
   .transform("Fill Columns",Fill,
     {
       year: 2017,
       entity_type: 'public_charter',
       level_code: 'e,m,h',
       test_data_type: 'NJ PARCC',
       gsdata_test_data_type_id: 298,
       subject: 'ela',
       academic_gsdata_id: 4,
       grade: 11
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
     else row[:state_id] = row[:state_id]
     end
     row
   end
   .transform("Fill Columns",Fill,
     {
       year: 2017,
       entity_type: 'public_charter',
       level_code: 'e,m,h',
       test_data_type: 'NJ PARCC',
       gsdata_test_data_type_id: 298,
       subject: 'math',
       academic_gsdata_id: 5,
       grade: 3
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
     else row[:state_id] = row[:state_id]
     end
     row
   end
   .transform("Fill Columns",Fill,
     {
       year: 2017,
       entity_type: 'public_charter',
       level_code: 'e,m,h',
       test_data_type: 'NJ PARCC',
       gsdata_test_data_type_id: 298,
       subject: 'math',
       academic_gsdata_id: 5,
       grade: 4
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
     else row[:state_id] = row[:state_id]
     end
     row
   end
   .transform("Fill Columns",Fill,
     {
       year: 2017,
       entity_type: 'public_charter',
       level_code: 'e,m,h',
       test_data_type: 'NJ PARCC',
       gsdata_test_data_type_id: 298,
       subject: 'math',
       academic_gsdata_id: 5,
       grade: 5
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
     else row[:state_id] = row[:state_id]
     end
     row
   end
   .transform("Fill Columns",Fill,
     {
       year: 2017,
       entity_type: 'public_charter',
       level_code: 'e,m,h',
       test_data_type: 'NJ PARCC',
       gsdata_test_data_type_id: 298,
       subject: 'math',
       academic_gsdata_id: 5,
       grade: 6
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
     else row[:state_id] = row[:state_id]
     end
     row
   end
   .transform("Fill Columns",Fill,
     {
       year: 2017,
       entity_type: 'public_charter',
       level_code: 'e,m,h',
       test_data_type: 'NJ PARCC',
       gsdata_test_data_type_id: 298,
       subject: 'math',
       academic_gsdata_id: 5,
       grade: 7
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
     else row[:state_id] = row[:state_id]
     end
     row
   end
   .transform("Fill Columns",Fill,
     {
       year: 2017,
       entity_type: 'public_charter',
       level_code: 'e,m,h',
       test_data_type: 'NJ PARCC',
       gsdata_test_data_type_id: 298,
       subject: 'math',
       academic_gsdata_id: 5,
       grade: 8
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
     if row[:subgroup_type].include? "GRADE"
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
     else row[:state_id] = row[:state_id]
     end
     row
   end
   .transform("Fill Columns",Fill,
     {
       year: 2017,
       entity_type: 'public_charter',
       level_code: 'e,m,h',
       test_data_type: 'NJ PARCC',
       gsdata_test_data_type_id: 298,
       subject: 'Algebra I',
       academic_gsdata_id: 6
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
     if row[:subgroup_type].include? "GRADE"
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
     else row[:state_id] = row[:state_id]
     end
     row
   end
   .transform("Fill Columns",Fill,
     {
       year: 2017,
       entity_type: 'public_charter',
       level_code: 'e,m,h',
       test_data_type: 'NJ PARCC',
       gsdata_test_data_type_id: 298,
       subject: 'Algebra II',
       academic_gsdata_id: 10
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
     if row[:subgroup_type].include? "GRADE"
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
     else row[:state_id] = row[:state_id]
     end
     row
   end
   .transform("Fill Columns",Fill,
     {
       year: 2017,
       entity_type: 'public_charter',
       level_code: 'e,m,h',
       test_data_type: 'NJ PARCC',
       gsdata_test_data_type_id: 298,
       subject: 'Geometry',
       academic_gsdata_id: 8
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
     else row[:state_id] = row[:state_id]
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
       grade: 4
     })
   .transform('prof and above',SumValues,:total_prof_and_above, :total_p_scie,:total_ap_scie)
   .transform('prof and above',SumValues,:ge_prof_and_above, :ge_p_scie,:ge_ap_scie)
   .transform('prof and above',SumValues,:se_prof_and_above, :se_p_scie,:se_ap_scie)
   .transform('prof and above',SumValues,:lep_prof_and_above, :lep_p_scie,:lep_ap_scie)
   .transform('transposing prof bands', Transposer, :proficiency_band, :value_float, :total_prof_and_above, :total_pp_scie, :total_p_scie, :total_ap_scie, :ge_prof_and_above, :ge_pp_scie, :ge_p_scie, :ge_ap_scie, :se_prof_and_above, :se_pp_scie, :se_p_scie, :se_ap_scie, :lep_prof_and_above, :lep_pp_scie, :lep_p_scie, :lep_ap_scie)
   .transform("mapping proficiency bands",
     HashLookup, :proficiency_band, map_prof_band, to: :proficiency_band_gsdata_id)
   .transform('mapping breakdown', HashLookup, :proficiency_band, map_prof_to_breakdown, to: :breakdown_gsdata_id)
   .transform("mapping number tested", WithBlock) do |row|
     if row[:breakdown_gsdata_id] == 1
       row[:number_tested] = row[:total_valid_scale_scie]
     elsif row[:breakdown_gsdata_id] == 30
       row[:number_tested] = row[:ge_valid_scale_scie]
     elsif row[:breakdown_gsdata_id] == 27
       row[:number_tested] = row[:se_valid_scale_scie]
     elsif row[:breakdown_gsdata_id] == 32
       row[:number_tested] = row[:lep_valid_scale_scie]
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
     else row[:state_id] = row[:state_id]
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
       grade: 4
     })
   .transform('prof and above',SumValues,:f_prof_and_above, :f_p_scie,:f_ap_scie)
   .transform('prof and above',SumValues,:m_prof_and_above, :m_p_scie,:m_ap_scie)
   .transform('transposing prof bands', Transposer, :proficiency_band, :value_float, :f_prof_and_above, :f_pp_scie, :f_p_scie, :f_ap_scie, :m_prof_and_above, :m_pp_scie, :m_p_scie, :m_ap_scie)
   .transform("mapping proficiency bands",
     HashLookup, :proficiency_band, map_prof_band, to: :proficiency_band_gsdata_id)
   .transform('mapping breakdown', HashLookup, :proficiency_band, map_prof_to_breakdown, to: :breakdown_gsdata_id)
   .transform("mapping number tested", WithBlock) do |row|
     if row[:breakdown_gsdata_id] == 26
       row[:number_tested] = row[:f_valid_scale_scie]
     elsif row[:breakdown_gsdata_id] == 25
       row[:number_tested] = row[:m_valid_scale_scie]
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
     else row[:state_id] = row[:state_id]
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
       grade: 4
     })
   .transform('prof and above',SumValues,:w_prof_and_above, :w_p_scie,:w_ap_scie)
   .transform('prof and above',SumValues,:b_prof_and_above, :b_p_scie,:b_ap_scie)
   .transform('prof and above',SumValues,:a_prof_and_above, :a_p_scie,:a_ap_scie)
   .transform('prof and above',SumValues,:p_prof_and_above, :p_p_scie,:p_ap_scie)
   .transform('prof and above',SumValues,:h_prof_and_above, :h_p_scie,:h_ap_scie)
   .transform('prof and above',SumValues,:i_prof_and_above, :i_p_scie,:i_ap_scie)
   .transform('transposing prof bands', Transposer, :proficiency_band, :value_float, :w_prof_and_above, :w_pp_scie, :w_p_scie, :w_ap_scie, :b_prof_and_above, :b_pp_scie, :b_p_scie, :b_ap_scie, :a_prof_and_above, :a_pp_scie, :a_p_scie, :a_ap_scie, :p_prof_and_above, :p_pp_scie, :p_p_scie, :p_ap_scie, :h_prof_and_above, :h_pp_scie, :h_p_scie, :h_ap_scie, :i_prof_and_above, :i_pp_scie, :i_p_scie, :i_ap_scie)
   .transform("mapping proficiency bands",
     HashLookup, :proficiency_band, map_prof_band, to: :proficiency_band_gsdata_id)
   .transform('mapping breakdown', HashLookup, :proficiency_band, map_prof_to_breakdown, to: :breakdown_gsdata_id)
   .transform("mapping number tested", WithBlock) do |row|
     if row[:breakdown_gsdata_id] == 21
       row[:number_tested] = row[:w_valid_scale_scie]
     elsif row[:breakdown_gsdata_id] == 17
       row[:number_tested] = row[:b_valid_scale_scie]
     elsif row[:breakdown_gsdata_id] == 16
       row[:number_tested] = row[:a_valid_scale_scie]
     elsif row[:breakdown_gsdata_id] == 37
       row[:number_tested] = row[:p_valid_scale_scie]
     elsif row[:breakdown_gsdata_id] == 19
       row[:number_tested] = row[:h_valid_scale_scie]
     elsif row[:breakdown_gsdata_id] == 18
       row[:number_tested] = row[:i_valid_scale_scie]
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
     else row[:state_id] = row[:state_id]
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
       grade: 4
     })
   .transform('prof and above',SumValues,:ecdis_y_prof_and_above, :ecdis_y_p_scie,:ecdis_y_ap_scie)
   .transform('prof and above',SumValues,:ecdis_n_prof_and_above, :ecdis_n_p_scie,:ecdis_n_ap_scie)
   .transform('transposing prof bands', Transposer, :proficiency_band, :value_float, :ecdis_y_prof_and_above, :ecdis_y_pp_scie, :ecdis_y_p_scie, :ecdis_y_ap_scie, :ecdis_n_prof_and_above, :ecdis_n_pp_scie, :ecdis_n_p_scie, :ecdis_n_ap_scie)
   .transform("mapping proficiency bands",
     HashLookup, :proficiency_band, map_prof_band, to: :proficiency_band_gsdata_id)
   .transform('mapping breakdown', HashLookup, :proficiency_band, map_prof_to_breakdown, to: :breakdown_gsdata_id)
   .transform("mapping number tested", WithBlock) do |row|
     if row[:breakdown_gsdata_id] == 23
       row[:number_tested] = row[:ecdis_y_valid_scale_scie]
     elsif row[:breakdown_gsdata_id] == 24
       row[:number_tested] = row[:ecdis_n_valid_scale_scie]
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
     else row[:state_id] = row[:state_id]
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
       grade: 8
     })
   .transform('prof and above',SumValues,:total_prof_and_above, :total_p_scie,:total_ap_scie)
   .transform('prof and above',SumValues,:ge_prof_and_above, :ge_p_scie,:ge_ap_scie)
   .transform('prof and above',SumValues,:se_prof_and_above, :se_p_scie,:se_ap_scie)
   .transform('prof and above',SumValues,:lep_prof_and_above, :lep_p_scie,:lep_ap_scie)
   .transform('transposing prof bands', Transposer, :proficiency_band, :value_float, :total_prof_and_above, :total_pp_scie, :total_p_scie, :total_ap_scie, :ge_prof_and_above, :ge_pp_scie, :ge_p_scie, :ge_ap_scie, :se_prof_and_above, :se_pp_scie, :se_p_scie, :se_ap_scie, :lep_prof_and_above, :lep_pp_scie, :lep_p_scie, :lep_ap_scie)
   .transform("mapping proficiency bands",
     HashLookup, :proficiency_band, map_prof_band, to: :proficiency_band_gsdata_id)
   .transform('mapping breakdown', HashLookup, :proficiency_band, map_prof_to_breakdown, to: :breakdown_gsdata_id)
   .transform("mapping number tested", WithBlock) do |row|
     if row[:breakdown_gsdata_id] == 1
       row[:number_tested] = row[:total_valid_scale_scie]
     elsif row[:breakdown_gsdata_id] == 30
       row[:number_tested] = row[:ge_valid_scale_scie]
     elsif row[:breakdown_gsdata_id] == 27
       row[:number_tested] = row[:se_valid_scale_scie]
     elsif row[:breakdown_gsdata_id] == 32
       row[:number_tested] = row[:lep_valid_scale_scie]
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
     else row[:state_id] = row[:state_id]
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
       grade: 8
     })
   .transform('prof and above',SumValues,:f_prof_and_above, :f_p_scie,:f_ap_scie)
   .transform('prof and above',SumValues,:m_prof_and_above, :m_p_scie,:m_ap_scie)
   .transform('transposing prof bands', Transposer, :proficiency_band, :value_float, :f_prof_and_above, :f_pp_scie, :f_p_scie, :f_ap_scie, :m_prof_and_above, :m_pp_scie, :m_p_scie, :m_ap_scie)
   .transform("mapping proficiency bands",
     HashLookup, :proficiency_band, map_prof_band, to: :proficiency_band_gsdata_id)
   .transform('mapping breakdown', HashLookup, :proficiency_band, map_prof_to_breakdown, to: :breakdown_gsdata_id)
   .transform("mapping number tested", WithBlock) do |row|
     if row[:breakdown_gsdata_id] == 26
       row[:number_tested] = row[:f_valid_scale_scie]
     elsif row[:breakdown_gsdata_id] == 25
       row[:number_tested] = row[:m_valid_scale_scie]
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
     else row[:state_id] = row[:state_id]
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
       grade: 8
     })
   .transform('prof and above',SumValues,:w_prof_and_above, :w_p_scie,:w_ap_scie)
   .transform('prof and above',SumValues,:b_prof_and_above, :b_p_scie,:b_ap_scie)
   .transform('prof and above',SumValues,:a_prof_and_above, :a_p_scie,:a_ap_scie)
   .transform('prof and above',SumValues,:p_prof_and_above, :p_p_scie,:p_ap_scie)
   .transform('prof and above',SumValues,:h_prof_and_above, :h_p_scie,:h_ap_scie)
   .transform('prof and above',SumValues,:i_prof_and_above, :i_p_scie,:i_ap_scie)
   .transform('transposing prof bands', Transposer, :proficiency_band, :value_float, :w_prof_and_above, :w_pp_scie, :w_p_scie, :w_ap_scie, :b_prof_and_above, :b_pp_scie, :b_p_scie, :b_ap_scie, :a_prof_and_above, :a_pp_scie, :a_p_scie, :a_ap_scie, :p_prof_and_above, :p_pp_scie, :p_p_scie, :p_ap_scie, :h_prof_and_above, :h_pp_scie, :h_p_scie, :h_ap_scie, :i_prof_and_above, :i_pp_scie, :i_p_scie, :i_ap_scie)
   .transform("mapping proficiency bands",
     HashLookup, :proficiency_band, map_prof_band, to: :proficiency_band_gsdata_id)
   .transform('mapping breakdown', HashLookup, :proficiency_band, map_prof_to_breakdown, to: :breakdown_gsdata_id)
   .transform("mapping number tested", WithBlock) do |row|
     if row[:breakdown_gsdata_id] == 21
       row[:number_tested] = row[:w_valid_scale_scie]
     elsif row[:breakdown_gsdata_id] == 17
       row[:number_tested] = row[:b_valid_scale_scie]
     elsif row[:breakdown_gsdata_id] == 16
       row[:number_tested] = row[:a_valid_scale_scie]
     elsif row[:breakdown_gsdata_id] == 37
       row[:number_tested] = row[:p_valid_scale_scie]
     elsif row[:breakdown_gsdata_id] == 19
       row[:number_tested] = row[:h_valid_scale_scie]
     elsif row[:breakdown_gsdata_id] == 18
       row[:number_tested] = row[:i_valid_scale_scie]
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
     else row[:state_id] = row[:state_id]
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
       grade: 8
     })
   .transform('prof and above',SumValues,:ecdis_y_prof_and_above, :ecdis_y_p_scie,:ecdis_y_ap_scie)
   .transform('prof and above',SumValues,:ecdis_n_prof_and_above, :ecdis_n_p_scie,:ecdis_n_ap_scie)
   .transform('transposing prof bands', Transposer, :proficiency_band, :value_float, :ecdis_y_prof_and_above, :ecdis_y_pp_scie, :ecdis_y_p_scie, :ecdis_y_ap_scie, :ecdis_n_prof_and_above, :ecdis_n_pp_scie, :ecdis_n_p_scie, :ecdis_n_ap_scie)
   .transform("mapping proficiency bands",
     HashLookup, :proficiency_band, map_prof_band, to: :proficiency_band_gsdata_id)
   .transform('mapping breakdown', HashLookup, :proficiency_band, map_prof_to_breakdown, to: :breakdown_gsdata_id)
   .transform("mapping number tested", WithBlock) do |row|
     if row[:breakdown_gsdata_id] == 23
       row[:number_tested] = row[:ecdis_y_valid_scale_scie]
     elsif row[:breakdown_gsdata_id] == 24
       row[:number_tested] = row[:ecdis_n_valid_scale_scie]
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
     else row[:state_id] = row[:state_id]
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
       grade: 'All'
     })
   .transform('prof and above',SumValues,:total_prof_and_above, :total_p_scie,:total_ap_scie)
   .transform('prof and above',SumValues,:ge_prof_and_above, :ge_p_scie,:ge_ap_scie)
   .transform('prof and above',SumValues,:se_prof_and_above, :se_p_scie,:se_ap_scie)
   .transform('prof and above',SumValues,:lep_prof_and_above, :lep_p_scie,:lep_ap_scie)
   .transform('transposing prof bands', Transposer, :proficiency_band, :value_float, :total_prof_and_above, :total_pp_scie, :total_p_scie, :total_ap_scie, :ge_prof_and_above, :ge_pp_scie, :ge_p_scie, :ge_ap_scie, :se_prof_and_above, :se_pp_scie, :se_p_scie, :se_ap_scie, :lep_prof_and_above, :lep_pp_scie, :lep_p_scie, :lep_ap_scie)
   .transform("mapping proficiency bands",
     HashLookup, :proficiency_band, map_prof_band, to: :proficiency_band_gsdata_id)
   .transform('mapping breakdown', HashLookup, :proficiency_band, map_prof_to_breakdown, to: :breakdown_gsdata_id)
   .transform("mapping number tested", WithBlock) do |row|
     if row[:breakdown_gsdata_id] == 1
       row[:number_tested] = row[:total_valid_scale_scie]
     elsif row[:breakdown_gsdata_id] == 30
       row[:number_tested] = row[:ge_valid_scale_scie]
     elsif row[:breakdown_gsdata_id] == 27
       row[:number_tested] = row[:se_valid_scale_scie]
     elsif row[:breakdown_gsdata_id] == 32
       row[:number_tested] = row[:lep_valid_scale_scie]
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

 source('nbjct_gender.txt',[],col_sep:"\t")  do |s|
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
     else row[:state_id] = row[:state_id]
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
       grade: 'All'
     })
   .transform('prof and above',SumValues,:f_prof_and_above, :f_p_scie,:f_ap_scie)
   .transform('prof and above',SumValues,:m_prof_and_above, :m_p_scie,:m_ap_scie)
   .transform('transposing prof bands', Transposer, :proficiency_band, :value_float, :f_prof_and_above, :f_pp_scie, :f_p_scie, :f_ap_scie, :m_prof_and_above, :m_pp_scie, :m_p_scie, :m_ap_scie)
   .transform("mapping proficiency bands",
     HashLookup, :proficiency_band, map_prof_band, to: :proficiency_band_gsdata_id)
   .transform('mapping breakdown', HashLookup, :proficiency_band, map_prof_to_breakdown, to: :breakdown_gsdata_id)
   .transform("mapping number tested", WithBlock) do |row|
     if row[:breakdown_gsdata_id] == 26
       row[:number_tested] = row[:f_valid_scale_scie]
     elsif row[:breakdown_gsdata_id] == 25
       row[:number_tested] = row[:m_valid_scale_scie]
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

 source('nbjct_ethnic.txt',[],col_sep:"\t")  do |s|
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
     else row[:state_id] = row[:state_id]
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
       grade: 'All'
     })
   .transform('prof and above',SumValues,:w_prof_and_above, :w_p_scie,:w_ap_scie)
   .transform('prof and above',SumValues,:b_prof_and_above, :b_p_scie,:b_ap_scie)
   .transform('prof and above',SumValues,:a_prof_and_above, :a_p_scie,:a_ap_scie)
   .transform('prof and above',SumValues,:p_prof_and_above, :p_p_scie,:p_ap_scie)
   .transform('prof and above',SumValues,:h_prof_and_above, :h_p_scie,:h_ap_scie)
   .transform('prof and above',SumValues,:i_prof_and_above, :i_p_scie,:i_ap_scie)
   .transform('transposing prof bands', Transposer, :proficiency_band, :value_float, :w_prof_and_above, :w_pp_scie, :w_p_scie, :w_ap_scie, :b_prof_and_above, :b_pp_scie, :b_p_scie, :b_ap_scie, :a_prof_and_above, :a_pp_scie, :a_p_scie, :a_ap_scie, :p_prof_and_above, :p_pp_scie, :p_p_scie, :p_ap_scie, :h_prof_and_above, :h_pp_scie, :h_p_scie, :h_ap_scie, :i_prof_and_above, :i_pp_scie, :i_p_scie, :i_ap_scie)
   .transform("mapping proficiency bands",
     HashLookup, :proficiency_band, map_prof_band, to: :proficiency_band_gsdata_id)
   .transform('mapping breakdown', HashLookup, :proficiency_band, map_prof_to_breakdown, to: :breakdown_gsdata_id)
   .transform("mapping number tested", WithBlock) do |row|
     if row[:breakdown_gsdata_id] == 21
       row[:number_tested] = row[:w_valid_scale_scie]
     elsif row[:breakdown_gsdata_id] == 17
       row[:number_tested] = row[:b_valid_scale_scie]
     elsif row[:breakdown_gsdata_id] == 16
       row[:number_tested] = row[:a_valid_scale_scie]
     elsif row[:breakdown_gsdata_id] == 37
       row[:number_tested] = row[:p_valid_scale_scie]
     elsif row[:breakdown_gsdata_id] == 19
       row[:number_tested] = row[:h_valid_scale_scie]
     elsif row[:breakdown_gsdata_id] == 18
       row[:number_tested] = row[:i_valid_scale_scie]
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

 source('nbjct_econ.txt',[],col_sep:"\t")  do |s|
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
     else row[:state_id] = row[:state_id]
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
       grade: 'All'
     })
   .transform('prof and above',SumValues,:ecdis_y_prof_and_above, :ecdis_y_p_scie,:ecdis_y_ap_scie)
   .transform('prof and above',SumValues,:ecdis_n_prof_and_above, :ecdis_n_p_scie,:ecdis_n_ap_scie)
   .transform('transposing prof bands', Transposer, :proficiency_band, :value_float, :ecdis_y_prof_and_above, :ecdis_y_pp_scie, :ecdis_y_p_scie, :ecdis_y_ap_scie, :ecdis_n_prof_and_above, :ecdis_n_pp_scie, :ecdis_n_p_scie, :ecdis_n_ap_scie)
   .transform("mapping proficiency bands",
     HashLookup, :proficiency_band, map_prof_band, to: :proficiency_band_gsdata_id)
   .transform('mapping breakdown', HashLookup, :proficiency_band, map_prof_to_breakdown, to: :breakdown_gsdata_id)
   .transform("mapping number tested", WithBlock) do |row|
     if row[:breakdown_gsdata_id] == 23
       row[:number_tested] = row[:ecdis_y_valid_scale_scie]
     elsif row[:breakdown_gsdata_id] == 24
       row[:number_tested] = row[:ecdis_n_valid_scale_scie]
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
      notes:'DXT-2987 NJ 2017 PARCC ASK NJBCT test load',
			url: 'http://www.state.nj.us/education/',
			file: 'nj/2017/nj.2017.1.public.charter.[level].txt',
			level: nil,
			school_type: 'public,charter'
		}
	end
end

NJTestProcessor2017PARCCASKNJBCT.new(ARGV[0],max:nil,offset:nil).run