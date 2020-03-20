require_relative "../test_processor"
GS::ETL::Logging.disable

class NJTestProcessor2016PARCCASKNJBCT < GS::ETL::TestProcessor

	def initialize(*args)
		super
		@year=2016
	end

	map_subject = {
		'math' => 5,
		'ela' => 4,
		'algebrai' => 7,
		'englishii' => 27,
		'Math' => 5,
		'Alg1' => 7,
		'ELA' => 4,
		'English II' => 27,
    'biology i' => 29
	}

	map_prof_band = {
		l1_percent: 115,
		l2_percent: 116,
		l3_percent: 117,
		l4_percent: 118,
		l5_percent: 119,
		Val_null: 'null',
    total_pp_scie: 3,
    total_p_scie: 4,
    total_ap_scie: 5,
    total_null: 'null',
    ge_pp_scie: 3,
    ge_p_scie: 4,
    ge_ap_scie: 5,
    ge_null: 'null',
    se_pp_scie: 3,
    se_p_scie: 4,
    se_ap_scie: 5,
    se_null: 'null',
    lep_pp_scie: 3,
    lep_p_scie: 4,
    lep_ap_scie: 5,
    lep_null: 'null',
    f_pp_scie: 3,
    f_p_scie: 4,
    f_ap_scie: 5,
    f_null: 'null',
    m_pp_scie: 3,
    m_p_scie: 4,
    m_ap_scie: 5,
    m_null: 'null',
    w_pp_scie: 3,
    w_p_scie: 4,
    w_ap_scie: 5,
    w_null: 'null',
    b_pp_scie: 3,
    b_p_scie: 4,
    b_ap_scie: 5,
    b_null: 'null',
    a_pp_scie: 3,
    a_p_scie: 4,
    a_ap_scie: 5,
    a_null: 'null',
    p_pp_scie: 3,
    p_p_scie: 4,
    p_ap_scie: 5,
    p_null: 'null',
    h_pp_scie: 3,
    h_p_scie: 4,
    h_ap_scie: 5,
    h_null: 'null',
    i_pp_scie: 3,
    i_p_scie: 4,
    i_ap_scie: 5,
    i_null: 'null',
    ecdis_y_pp_scie: 3,
    ecdis_y_p_scie: 4,
    ecdis_y_ap_scie: 5,
    ecdis_y_null: 'null',
    ecdis_n_pp_scie: 3,
    ecdis_n_p_scie: 4,
    ecdis_n_ap_scie: 5,
    ecdis_n_null: 'null'
	}

	map_breakdown = {
		'ALL STUDENTS' => 1,
		'ASIAN' => 2,
		'AFRICAN AMERICAN' => 3,
		'FEMALE' => 11,
		'ECONOMICALLY DISADVANTAGED' => 9,
		'HISPANIC' => 6,
		'ENGLISH LANGUAGE LEARNERS' => 15,
		'MALE' => 12,
		'AMERICAN INDIAN' => 4,
		'NON-ECON. DISADVANTAGED' => 10,
		'NATIVE HAWAIIAN' => 112,
    'PACIFIC ISLANDER' => 112,
		'STUDENTS WITH DISABILITIES' => 13,
		'WHITE' => 8
	}

  map_prof_to_breakdown = {
    total_pp_scie: 1,
    total_p_scie: 1,
    total_ap_scie: 1,
    total_null: 1,
    ge_pp_scie: 14,
    ge_p_scie: 14,
    ge_ap_scie: 14,
    ge_null: 14,
    se_pp_scie: 13,
    se_p_scie: 13,
    se_ap_scie: 13,
    se_null: 13,
    lep_pp_scie: 15,
    lep_p_scie: 15,
    lep_ap_scie: 15,
    lep_null: 15,
    f_pp_scie: 11,
    f_p_scie: 11,
    f_ap_scie: 11,
    f_null: 11,
    m_pp_scie: 12,
    m_p_scie: 12,
    m_ap_scie: 12,
    m_null: 12,
    w_pp_scie: 8,
    w_p_scie: 8,
    w_ap_scie: 8,
    w_null: 8,
    b_pp_scie: 3,
    b_p_scie: 3,
    b_ap_scie: 3,
    b_null: 3,
    a_pp_scie: 2,
    a_p_scie: 2,
    a_ap_scie: 2,
    a_null: 2,
    p_pp_scie: 112,
    p_p_scie: 112,
    p_ap_scie: 112,
    p_null: 112,
    h_pp_scie: 6,
    h_p_scie: 6,
    h_ap_scie: 6,
    h_null: 6,
    i_pp_scie: 4,
    i_p_scie: 4,
    i_ap_scie: 4,
    i_null: 4,
    ecdis_y_pp_scie: 9,
    ecdis_y_p_scie: 9,
    ecdis_y_ap_scie: 9,
    ecdis_y_null: 9,
    ecdis_n_pp_scie: 10,
    ecdis_n_p_scie: 10,
    ecdis_n_ap_scie: 10,
    ecdis_n_null: 10
  }

 source('parcc_ela_03.txt',[],col_sep:"\t")  do |s|
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
       year: 2016,
       entity_type: 'public_charter',
       level_code: 'e,m,h',
       test_data_type: 'NJ PARCC',
       test_data_type_id: 255,
       subject: 'ela',
       subject_id: 4,
       grade: 3
     })
   s.transform("",MultiFieldRenamer,
     {
       subgroup_type: :breakdown,
       valid_scores: :number_tested
     })
   .transform('delete * rows', DeleteRows, :l1_percent, '*')
   .transform('null prof band',SumValues,:Val_null, :l4_percent,:l5_percent)
   .transform('transposing prof bands', Transposer, :proficiency_band, :value_float, :l1_percent, :l2_percent, :l3_percent, :l4_percent, :l5_percent, :Val_null)
   .transform("mapping proficiency bands",
     HashLookup, :proficiency_band, map_prof_band, to: :proficiency_band_id)
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'OTHER')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'SE ACCOMMODATION')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'FORMER - ELL')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'CURRENT - ELL')
   .transform('mapping breakdown', HashLookup, :breakdown, map_breakdown, to: :breakdown_id)
   .transform("removing DFG rows", DeleteRows, :district_name, 'skip')
 end

 source('parcc_ela_04.txt',[],col_sep:"\t")  do |s|
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
       year: 2016,
       entity_type: 'public_charter',
       level_code: 'e,m,h',
       test_data_type: 'NJ PARCC',
       test_data_type_id: 255,
       subject: 'ela',
       subject_id: 4,
       grade: 4
     })
   s.transform("",MultiFieldRenamer,
     {
       subgroup_type: :breakdown,
       valid_scores: :number_tested
     })
   .transform('delete * rows', DeleteRows, :l1_percent, '*')
   .transform('null prof band',SumValues,:Val_null, :l4_percent,:l5_percent)
   .transform('transposing prof bands', Transposer, :proficiency_band, :value_float, :l1_percent, :l2_percent, :l3_percent, :l4_percent, :l5_percent, :Val_null)
   .transform("mapping proficiency bands",
     HashLookup, :proficiency_band, map_prof_band, to: :proficiency_band_id)
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'OTHER')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'SE ACCOMMODATION')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'FORMER - ELL')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'CURRENT - ELL')
   .transform('mapping breakdown', HashLookup, :breakdown, map_breakdown, to: :breakdown_id)
   .transform("removing DFG rows", DeleteRows, :district_name, 'skip')
 end

 source('parcc_ela_05.txt',[],col_sep:"\t")  do |s|
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
       year: 2016,
       entity_type: 'public_charter',
       level_code: 'e,m,h',
       test_data_type: 'NJ PARCC',
       test_data_type_id: 255,
       subject: 'ela',
       subject_id: 4,
       grade: 5
     })
   s.transform("",MultiFieldRenamer,
     {
       subgroup_type: :breakdown,
       valid_scores: :number_tested
     })
   .transform('delete * rows', DeleteRows, :l1_percent, '*')
   .transform('null prof band',SumValues,:Val_null, :l4_percent,:l5_percent)
   .transform('transposing prof bands', Transposer, :proficiency_band, :value_float, :l1_percent, :l2_percent, :l3_percent, :l4_percent, :l5_percent, :Val_null)
   .transform("mapping proficiency bands",
     HashLookup, :proficiency_band, map_prof_band, to: :proficiency_band_id)
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'OTHER')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'SE ACCOMMODATION')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'FORMER - ELL')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'CURRENT - ELL')
   .transform('mapping breakdown', HashLookup, :breakdown, map_breakdown, to: :breakdown_id)
   .transform("removing DFG rows", DeleteRows, :district_name, 'skip')
 end

 source('parcc_ela_06.txt',[],col_sep:"\t")  do |s|
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
       year: 2016,
       entity_type: 'public_charter',
       level_code: 'e,m,h',
       test_data_type: 'NJ PARCC',
       test_data_type_id: 255,
       subject: 'ela',
       subject_id: 4,
       grade: 6
     })
   s.transform("",MultiFieldRenamer,
     {
       subgroup_type: :breakdown,
       valid_scores: :number_tested
     })
   .transform('delete * rows', DeleteRows, :l1_percent, '*')
   .transform('null prof band',SumValues,:Val_null, :l4_percent,:l5_percent)
   .transform('transposing prof bands', Transposer, :proficiency_band, :value_float, :l1_percent, :l2_percent, :l3_percent, :l4_percent, :l5_percent, :Val_null)
   .transform("mapping proficiency bands",
     HashLookup, :proficiency_band, map_prof_band, to: :proficiency_band_id)
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'OTHER')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'SE ACCOMMODATION')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'FORMER - ELL')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'CURRENT - ELL')
   .transform('mapping breakdown', HashLookup, :breakdown, map_breakdown, to: :breakdown_id)
   .transform("removing DFG rows", DeleteRows, :district_name, 'skip')
 end

 source('parcc_ela_07.txt',[],col_sep:"\t")  do |s|
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
       year: 2016,
       entity_type: 'public_charter',
       level_code: 'e,m,h',
       test_data_type: 'NJ PARCC',
       test_data_type_id: 255,
       subject: 'ela',
       subject_id: 4,
       grade: 7
     })
   s.transform("",MultiFieldRenamer,
     {
       subgroup_type: :breakdown,
       valid_scores: :number_tested
     })
   .transform('delete * rows', DeleteRows, :l1_percent, '*')
   .transform('null prof band',SumValues,:Val_null, :l4_percent,:l5_percent)
   .transform('transposing prof bands', Transposer, :proficiency_band, :value_float, :l1_percent, :l2_percent, :l3_percent, :l4_percent, :l5_percent, :Val_null)
   .transform("mapping proficiency bands",
     HashLookup, :proficiency_band, map_prof_band, to: :proficiency_band_id)
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'OTHER')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'SE ACCOMMODATION')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'FORMER - ELL')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'CURRENT - ELL')
   .transform('mapping breakdown', HashLookup, :breakdown, map_breakdown, to: :breakdown_id)
   .transform("removing DFG rows", DeleteRows, :district_name, 'skip')
 end

 source('parcc_ela_08.txt',[],col_sep:"\t")  do |s|
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
       year: 2016,
       entity_type: 'public_charter',
       level_code: 'e,m,h',
       test_data_type: 'NJ PARCC',
       test_data_type_id: 255,
       subject: 'ela',
       subject_id: 4,
       grade: 8
     })
   s.transform("",MultiFieldRenamer,
     {
       subgroup_type: :breakdown,
       valid_scores: :number_tested
     })
   .transform('delete * rows', DeleteRows, :l1_percent, '*')
   .transform('null prof band',SumValues,:Val_null, :l4_percent,:l5_percent)
   .transform('transposing prof bands', Transposer, :proficiency_band, :value_float, :l1_percent, :l2_percent, :l3_percent, :l4_percent, :l5_percent, :Val_null)
   .transform("mapping proficiency bands",
     HashLookup, :proficiency_band, map_prof_band, to: :proficiency_band_id)
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'OTHER')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'SE ACCOMMODATION')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'FORMER - ELL')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'CURRENT - ELL')
   .transform('mapping breakdown', HashLookup, :breakdown, map_breakdown, to: :breakdown_id)
   .transform("removing DFG rows", DeleteRows, :district_name, 'skip')
 end

 source('parcc_ela_10.txt',[],col_sep:"\t")  do |s|
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
       year: 2016,
       entity_type: 'public_charter',
       level_code: 'e,m,h',
       test_data_type: 'NJ PARCC',
       test_data_type_id: 255,
       subject: 'ela',
       subject_id: 4,
       grade: 10
     })
   s.transform("",MultiFieldRenamer,
     {
       subgroup_type: :breakdown,
       valid_scores: :number_tested
     })
   .transform('delete * rows', DeleteRows, :l1_percent, '*')
   .transform('null prof band',SumValues,:Val_null, :l4_percent,:l5_percent)
   .transform('transposing prof bands', Transposer, :proficiency_band, :value_float, :l1_percent, :l2_percent, :l3_percent, :l4_percent, :l5_percent, :Val_null)
   .transform("mapping proficiency bands",
     HashLookup, :proficiency_band, map_prof_band, to: :proficiency_band_id)
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'OTHER')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'SE ACCOMMODATION')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'FORMER - ELL')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'CURRENT - ELL')
   .transform('mapping breakdown', HashLookup, :breakdown, map_breakdown, to: :breakdown_id)
   .transform("removing DFG rows", DeleteRows, :district_name, 'skip')
 end

 source('parcc_ela_11.txt',[],col_sep:"\t")  do |s|
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
       year: 2016,
       entity_type: 'public_charter',
       level_code: 'e,m,h',
       test_data_type: 'NJ PARCC',
       test_data_type_id: 255,
       subject: 'ela',
       subject_id: 4,
       grade: 11
     })
   s.transform("",MultiFieldRenamer,
     {
       subgroup_type: :breakdown,
       valid_scores: :number_tested
     })
   .transform('delete * rows', DeleteRows, :l1_percent, '*')
   .transform('null prof band',SumValues,:Val_null, :l4_percent,:l5_percent)
   .transform('transposing prof bands', Transposer, :proficiency_band, :value_float, :l1_percent, :l2_percent, :l3_percent, :l4_percent, :l5_percent, :Val_null)
   .transform("mapping proficiency bands",
     HashLookup, :proficiency_band, map_prof_band, to: :proficiency_band_id)
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'OTHER')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'SE ACCOMMODATION')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'FORMER - ELL')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'CURRENT - ELL')
   .transform('mapping breakdown', HashLookup, :breakdown, map_breakdown, to: :breakdown_id)
   .transform("removing DFG rows", DeleteRows, :district_name, 'skip')
 end

 source('parcc_math_03.txt',[],col_sep:"\t")  do |s|
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
       year: 2016,
       entity_type: 'public_charter',
       level_code: 'e,m,h',
       test_data_type: 'NJ PARCC',
       test_data_type_id: 255,
       subject: 'math',
       subject_id: 5,
       grade: 3
     })
   s.transform("",MultiFieldRenamer,
     {
       subgroup_type: :breakdown,
       valid_scores: :number_tested
     })
   .transform('delete * rows', DeleteRows, :l1_percent, '*')
   .transform('null prof band',SumValues,:Val_null, :l4_percent,:l5_percent)
   .transform('transposing prof bands', Transposer, :proficiency_band, :value_float, :l1_percent, :l2_percent, :l3_percent, :l4_percent, :l5_percent, :Val_null)
   .transform("mapping proficiency bands",
     HashLookup, :proficiency_band, map_prof_band, to: :proficiency_band_id)
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'OTHER')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'SE ACCOMMODATION')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'FORMER - ELL')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'CURRENT - ELL')
   .transform('mapping breakdown', HashLookup, :breakdown, map_breakdown, to: :breakdown_id)
   .transform("removing DFG rows", DeleteRows, :district_name, 'skip')
 end

 source('parcc_math_04.txt',[],col_sep:"\t")  do |s|
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
       year: 2016,
       entity_type: 'public_charter',
       level_code: 'e,m,h',
       test_data_type: 'NJ PARCC',
       test_data_type_id: 255,
       subject: 'math',
       subject_id: 5,
       grade: 4
     })
   s.transform("",MultiFieldRenamer,
     {
       subgroup_type: :breakdown,
       valid_scores: :number_tested
     })
   .transform('delete * rows', DeleteRows, :l1_percent, '*')
   .transform('null prof band',SumValues,:Val_null, :l4_percent,:l5_percent)
   .transform('transposing prof bands', Transposer, :proficiency_band, :value_float, :l1_percent, :l2_percent, :l3_percent, :l4_percent, :l5_percent, :Val_null)
   .transform("mapping proficiency bands",
     HashLookup, :proficiency_band, map_prof_band, to: :proficiency_band_id)
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'OTHER')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'SE ACCOMMODATION')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'FORMER - ELL')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'CURRENT - ELL')
   .transform('mapping breakdown', HashLookup, :breakdown, map_breakdown, to: :breakdown_id)
   .transform("removing DFG rows", DeleteRows, :district_name, 'skip')
 end

 source('parcc_math_05.txt',[],col_sep:"\t")  do |s|
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
       year: 2016,
       entity_type: 'public_charter',
       level_code: 'e,m,h',
       test_data_type: 'NJ PARCC',
       test_data_type_id: 255,
       subject: 'math',
       subject_id: 5,
       grade: 5
     })
   s.transform("",MultiFieldRenamer,
     {
       subgroup_type: :breakdown,
       valid_scores: :number_tested
     })
   .transform('delete * rows', DeleteRows, :l1_percent, '*')
   .transform('null prof band',SumValues,:Val_null, :l4_percent,:l5_percent)
   .transform('transposing prof bands', Transposer, :proficiency_band, :value_float, :l1_percent, :l2_percent, :l3_percent, :l4_percent, :l5_percent, :Val_null)
   .transform("mapping proficiency bands",
     HashLookup, :proficiency_band, map_prof_band, to: :proficiency_band_id)
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'OTHER')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'SE ACCOMMODATION')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'FORMER - ELL')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'CURRENT - ELL')
   .transform('mapping breakdown', HashLookup, :breakdown, map_breakdown, to: :breakdown_id)
   .transform("removing DFG rows", DeleteRows, :district_name, 'skip')
 end

 source('parcc_math_06.txt',[],col_sep:"\t")  do |s|
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
       year: 2016,
       entity_type: 'public_charter',
       level_code: 'e,m,h',
       test_data_type: 'NJ PARCC',
       test_data_type_id: 255,
       subject: 'math',
       subject_id: 5,
       grade: 6
     })
   s.transform("",MultiFieldRenamer,
     {
       subgroup_type: :breakdown,
       valid_scores: :number_tested
     })
   .transform('delete * rows', DeleteRows, :l1_percent, '*')
   .transform('null prof band',SumValues,:Val_null, :l4_percent,:l5_percent)
   .transform('transposing prof bands', Transposer, :proficiency_band, :value_float, :l1_percent, :l2_percent, :l3_percent, :l4_percent, :l5_percent, :Val_null)
   .transform("mapping proficiency bands",
     HashLookup, :proficiency_band, map_prof_band, to: :proficiency_band_id)
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'OTHER')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'SE ACCOMMODATION')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'FORMER - ELL')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'CURRENT - ELL')
   .transform('mapping breakdown', HashLookup, :breakdown, map_breakdown, to: :breakdown_id)
   .transform("removing DFG rows", DeleteRows, :district_name, 'skip')
 end

 source('parcc_math_07.txt',[],col_sep:"\t")  do |s|
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
       year: 2016,
       entity_type: 'public_charter',
       level_code: 'e,m,h',
       test_data_type: 'NJ PARCC',
       test_data_type_id: 255,
       subject: 'math',
       subject_id: 5,
       grade: 7
     })
   s.transform("",MultiFieldRenamer,
     {
       subgroup_type: :breakdown,
       valid_scores: :number_tested
     })
   .transform('delete * rows', DeleteRows, :l1_percent, '*')
   .transform('null prof band',SumValues,:Val_null, :l4_percent,:l5_percent)
   .transform('transposing prof bands', Transposer, :proficiency_band, :value_float, :l1_percent, :l2_percent, :l3_percent, :l4_percent, :l5_percent, :Val_null)
   .transform("mapping proficiency bands",
     HashLookup, :proficiency_band, map_prof_band, to: :proficiency_band_id)
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'OTHER')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'SE ACCOMMODATION')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'FORMER - ELL')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'CURRENT - ELL')
   .transform('mapping breakdown', HashLookup, :breakdown, map_breakdown, to: :breakdown_id)
   .transform("removing DFG rows", DeleteRows, :district_name, 'skip')
 end

 source('parcc_math_08.txt',[],col_sep:"\t")  do |s|
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
       year: 2016,
       entity_type: 'public_charter',
       level_code: 'e,m,h',
       test_data_type: 'NJ PARCC',
       test_data_type_id: 255,
       subject: 'math',
       subject_id: 5,
       grade: 8
     })
   s.transform("",MultiFieldRenamer,
     {
       subgroup_type: :breakdown,
       valid_scores: :number_tested
     })
   .transform('delete * rows', DeleteRows, :l1_percent, '*')
   .transform('null prof band',SumValues,:Val_null, :l4_percent,:l5_percent)
   .transform('transposing prof bands', Transposer, :proficiency_band, :value_float, :l1_percent, :l2_percent, :l3_percent, :l4_percent, :l5_percent, :Val_null)
   .transform("mapping proficiency bands",
     HashLookup, :proficiency_band, map_prof_band, to: :proficiency_band_id)
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'OTHER')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'SE ACCOMMODATION')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'FORMER - ELL')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'CURRENT - ELL')
   .transform('mapping breakdown', HashLookup, :breakdown, map_breakdown, to: :breakdown_id)
   .transform("removing DFG rows", DeleteRows, :district_name, 'skip')
 end

 source('parcc_math_alg2.txt',[],col_sep:"\t")  do |s|
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
       year: 2016,
       entity_type: 'public_charter',
       level_code: 'e,m,h',
       test_data_type: 'NJ PARCC',
       test_data_type_id: 255,
       subject: 'algebra ii',
       subject_id: 11
     })
   s.transform("",MultiFieldRenamer,
     {
       subgroup_type: :breakdown,
       valid_scores: :number_tested
     })
   .transform('delete * rows', DeleteRows, :l1_percent, '*')
   .transform('null prof band',SumValues,:Val_null, :l4_percent,:l5_percent)
   .transform('transposing prof bands', Transposer, :proficiency_band, :value_float, :l1_percent, :l2_percent, :l3_percent, :l4_percent, :l5_percent, :Val_null)
   .transform("mapping proficiency bands",
     HashLookup, :proficiency_band, map_prof_band, to: :proficiency_band_id)
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'OTHER')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'SE ACCOMMODATION')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'FORMER - ELL')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'CURRENT - ELL')
   .transform('mapping breakdown', HashLookup, :breakdown, map_breakdown, to: :breakdown_id)
   .transform("removing DFG rows", DeleteRows, :district_name, 'skip')
   .transform("removing grade rows", DeleteRows, :grade, 'skip')
 end

 source('parcc_math_geo.txt',[],col_sep:"\t")  do |s|
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
       year: 2016,
       entity_type: 'public_charter',
       level_code: 'e,m,h',
       test_data_type: 'NJ PARCC',
       test_data_type_id: 255,
       subject: 'geometry',
       subject_id: 9
     })
   s.transform("",MultiFieldRenamer,
     {
       subgroup_type: :breakdown,
       valid_scores: :number_tested
     })
   .transform('delete * rows', DeleteRows, :l1_percent, '*')
   .transform('null prof band',SumValues,:Val_null, :l4_percent,:l5_percent)
   .transform('transposing prof bands', Transposer, :proficiency_band, :value_float, :l1_percent, :l2_percent, :l3_percent, :l4_percent, :l5_percent, :Val_null)
   .transform("mapping proficiency bands",
     HashLookup, :proficiency_band, map_prof_band, to: :proficiency_band_id)
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'OTHER')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'SE ACCOMMODATION')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'FORMER - ELL')
   .transform('delete unwanted subgroup', DeleteRows, :breakdown, 'CURRENT - ELL')
   .transform('mapping breakdown', HashLookup, :breakdown, map_breakdown, to: :breakdown_id)
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
       year: 2016,
       entity_type: 'public_charter',
       level_code: 'e,m,h',
       test_data_type: 'NJ ASK',
       test_data_type_id: 5,
       subject: 'science',
       subject_id: 25,
       grade: 4
     })
   .transform('null prof band',SumValues,:total_null, :total_p_scie,:total_ap_scie)
   .transform('null prof band',SumValues,:ge_null, :ge_p_scie,:ge_ap_scie)
   .transform('null prof band',SumValues,:se_null, :se_p_scie,:se_ap_scie)
   .transform('null prof band',SumValues,:lep_null, :lep_p_scie,:lep_ap_scie)
   .transform('transposing prof bands', Transposer, :proficiency_band, :value_float, :total_null, :total_pp_scie, :total_p_scie, :total_ap_scie, :ge_null, :ge_pp_scie, :ge_p_scie, :ge_ap_scie, :se_null, :se_pp_scie, :se_p_scie, :se_ap_scie, :lep_null, :lep_pp_scie, :lep_p_scie, :lep_ap_scie)
   .transform("mapping proficiency bands",
     HashLookup, :proficiency_band, map_prof_band, to: :proficiency_band_id)
   .transform('mapping breakdown', HashLookup, :proficiency_band, map_prof_to_breakdown, to: :breakdown_id)
   .transform("mapping number tested", WithBlock) do |row|
     if row[:breakdown_id] == 1
       row[:number_tested] = row[:total_valid_scale_scie]
     elsif row[:breakdown_id] == 14
       row[:number_tested] = row[:ge_valid_scale_scie]
     elsif row[:breakdown_id] == 13
       row[:number_tested] = row[:se_valid_scale_scie]
     elsif row[:breakdown_id] == 15
       row[:number_tested] = row[:lep_valid_scale_scie]
     end
     row
   end
   .transform("removing * rows", DeleteRows, :number_tested, '*')
   .transform("removing 0 rows", DeleteRows, :number_tested, '0')
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
       year: 2016,
       entity_type: 'public_charter',
       level_code: 'e,m,h',
       test_data_type: 'NJ ASK',
       test_data_type_id: 5,
       subject: 'science',
       subject_id: 25,
       grade: 4
     })
   .transform('null prof band',SumValues,:f_null, :f_p_scie,:f_ap_scie)
   .transform('null prof band',SumValues,:m_null, :m_p_scie,:m_ap_scie)
   .transform('transposing prof bands', Transposer, :proficiency_band, :value_float, :f_null, :f_pp_scie, :f_p_scie, :f_ap_scie, :m_null, :m_pp_scie, :m_p_scie, :m_ap_scie)
   .transform("mapping proficiency bands",
     HashLookup, :proficiency_band, map_prof_band, to: :proficiency_band_id)
   .transform('mapping breakdown', HashLookup, :proficiency_band, map_prof_to_breakdown, to: :breakdown_id)
   .transform("mapping number tested", WithBlock) do |row|
     if row[:breakdown_id] == 11
       row[:number_tested] = row[:f_valid_scale_scie]
     elsif row[:breakdown_id] == 12
       row[:number_tested] = row[:m_valid_scale_scie]
     end
     row
   end
   .transform("removing * rows", DeleteRows, :number_tested, '*')
   .transform("removing 0 rows", DeleteRows, :number_tested, '0')
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
       year: 2016,
       entity_type: 'public_charter',
       level_code: 'e,m,h',
       test_data_type: 'NJ ASK',
       test_data_type_id: 5,
       subject: 'science',
       subject_id: 25,
       grade: 4
     })
   .transform('null prof band',SumValues,:w_null, :w_p_scie,:w_ap_scie)
   .transform('null prof band',SumValues,:b_null, :b_p_scie,:b_ap_scie)
   .transform('null prof band',SumValues,:a_null, :a_p_scie,:a_ap_scie)
   .transform('null prof band',SumValues,:p_null, :p_p_scie,:p_ap_scie)
   .transform('null prof band',SumValues,:h_null, :h_p_scie,:h_ap_scie)
   .transform('null prof band',SumValues,:i_null, :i_p_scie,:i_ap_scie)
   .transform('transposing prof bands', Transposer, :proficiency_band, :value_float, :w_null, :w_pp_scie, :w_p_scie, :w_ap_scie, :b_null, :b_pp_scie, :b_p_scie, :b_ap_scie, :a_null, :a_pp_scie, :a_p_scie, :a_ap_scie, :p_null, :p_pp_scie, :p_p_scie, :p_ap_scie, :h_null, :h_pp_scie, :h_p_scie, :h_ap_scie, :i_null, :i_pp_scie, :i_p_scie, :i_ap_scie)
   .transform("mapping proficiency bands",
     HashLookup, :proficiency_band, map_prof_band, to: :proficiency_band_id)
   .transform('mapping breakdown', HashLookup, :proficiency_band, map_prof_to_breakdown, to: :breakdown_id)
   .transform("mapping number tested", WithBlock) do |row|
     if row[:breakdown_id] == 8
       row[:number_tested] = row[:w_valid_scale_scie]
     elsif row[:breakdown_id] == 3
       row[:number_tested] = row[:b_valid_scale_scie]
     elsif row[:breakdown_id] == 2
       row[:number_tested] = row[:a_valid_scale_scie]
     elsif row[:breakdown_id] == 112
       row[:number_tested] = row[:p_valid_scale_scie]
     elsif row[:breakdown_id] == 6
       row[:number_tested] = row[:h_valid_scale_scie]
     elsif row[:breakdown_id] == 4
       row[:number_tested] = row[:i_valid_scale_scie]
     end
     row
   end
   .transform("removing * rows", DeleteRows, :number_tested, '*')
   .transform("removing 0 rows", DeleteRows, :number_tested, '0')
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
       year: 2016,
       entity_type: 'public_charter',
       level_code: 'e,m,h',
       test_data_type: 'NJ ASK',
       test_data_type_id: 5,
       subject: 'science',
       subject_id: 25,
       grade: 4
     })
   .transform('null prof band',SumValues,:ecdis_y_null, :ecdis_y_p_scie,:ecdis_y_ap_scie)
   .transform('null prof band',SumValues,:ecdis_n_null, :ecdis_n_p_scie,:ecdis_n_ap_scie)
   .transform('transposing prof bands', Transposer, :proficiency_band, :value_float, :ecdis_y_null, :ecdis_y_pp_scie, :ecdis_y_p_scie, :ecdis_y_ap_scie, :ecdis_n_null, :ecdis_n_pp_scie, :ecdis_n_p_scie, :ecdis_n_ap_scie)
   .transform("mapping proficiency bands",
     HashLookup, :proficiency_band, map_prof_band, to: :proficiency_band_id)
   .transform('mapping breakdown', HashLookup, :proficiency_band, map_prof_to_breakdown, to: :breakdown_id)
   .transform("mapping number tested", WithBlock) do |row|
     if row[:breakdown_id] == 9
       row[:number_tested] = row[:ecdis_y_valid_scale_scie]
     elsif row[:breakdown_id] == 10
       row[:number_tested] = row[:ecdis_n_valid_scale_scie]
     end
     row
   end
   .transform("removing * rows", DeleteRows, :number_tested, '*')
   .transform("removing 0 rows", DeleteRows, :number_tested, '0')
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
       year: 2016,
       entity_type: 'public_charter',
       level_code: 'e,m,h',
       test_data_type: 'NJ ASK',
       test_data_type_id: 5,
       subject: 'science',
       subject_id: 25,
       grade: 8
     })
   .transform('null prof band',SumValues,:total_null, :total_p_scie,:total_ap_scie)
   .transform('null prof band',SumValues,:ge_null, :ge_p_scie,:ge_ap_scie)
   .transform('null prof band',SumValues,:se_null, :se_p_scie,:se_ap_scie)
   .transform('null prof band',SumValues,:lep_null, :lep_p_scie,:lep_ap_scie)
   .transform('transposing prof bands', Transposer, :proficiency_band, :value_float, :total_null, :total_pp_scie, :total_p_scie, :total_ap_scie, :ge_null, :ge_pp_scie, :ge_p_scie, :ge_ap_scie, :se_null, :se_pp_scie, :se_p_scie, :se_ap_scie, :lep_null, :lep_pp_scie, :lep_p_scie, :lep_ap_scie)
   .transform("mapping proficiency bands",
     HashLookup, :proficiency_band, map_prof_band, to: :proficiency_band_id)
   .transform('mapping breakdown', HashLookup, :proficiency_band, map_prof_to_breakdown, to: :breakdown_id)
   .transform("mapping number tested", WithBlock) do |row|
     if row[:breakdown_id] == 1
       row[:number_tested] = row[:total_valid_scale_scie]
     elsif row[:breakdown_id] == 14
       row[:number_tested] = row[:ge_valid_scale_scie]
     elsif row[:breakdown_id] == 13
       row[:number_tested] = row[:se_valid_scale_scie]
     elsif row[:breakdown_id] == 15
       row[:number_tested] = row[:lep_valid_scale_scie]
     end
     row
   end
   .transform("removing * rows", DeleteRows, :number_tested, '*')
   .transform("removing 0 rows", DeleteRows, :number_tested, '0')
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
       year: 2016,
       entity_type: 'public_charter',
       level_code: 'e,m,h',
       test_data_type: 'NJ ASK',
       test_data_type_id: 5,
       subject: 'science',
       subject_id: 25,
       grade: 8
     })
   .transform('null prof band',SumValues,:f_null, :f_p_scie,:f_ap_scie)
   .transform('null prof band',SumValues,:m_null, :m_p_scie,:m_ap_scie)
   .transform('transposing prof bands', Transposer, :proficiency_band, :value_float, :f_null, :f_pp_scie, :f_p_scie, :f_ap_scie, :m_null, :m_pp_scie, :m_p_scie, :m_ap_scie)
   .transform("mapping proficiency bands",
     HashLookup, :proficiency_band, map_prof_band, to: :proficiency_band_id)
   .transform('mapping breakdown', HashLookup, :proficiency_band, map_prof_to_breakdown, to: :breakdown_id)
   .transform("mapping number tested", WithBlock) do |row|
     if row[:breakdown_id] == 11
       row[:number_tested] = row[:f_valid_scale_scie]
     elsif row[:breakdown_id] == 12
       row[:number_tested] = row[:m_valid_scale_scie]
     end
     row
   end
   .transform("removing * rows", DeleteRows, :number_tested, '*')
   .transform("removing 0 rows", DeleteRows, :number_tested, '0')
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
       year: 2016,
       entity_type: 'public_charter',
       level_code: 'e,m,h',
       test_data_type: 'NJ ASK',
       test_data_type_id: 5,
       subject: 'science',
       subject_id: 25,
       grade: 8
     })
   .transform('null prof band',SumValues,:w_null, :w_p_scie,:w_ap_scie)
   .transform('null prof band',SumValues,:b_null, :b_p_scie,:b_ap_scie)
   .transform('null prof band',SumValues,:a_null, :a_p_scie,:a_ap_scie)
   .transform('null prof band',SumValues,:p_null, :p_p_scie,:p_ap_scie)
   .transform('null prof band',SumValues,:h_null, :h_p_scie,:h_ap_scie)
   .transform('null prof band',SumValues,:i_null, :i_p_scie,:i_ap_scie)
   .transform('transposing prof bands', Transposer, :proficiency_band, :value_float, :w_null, :w_pp_scie, :w_p_scie, :w_ap_scie, :b_null, :b_pp_scie, :b_p_scie, :b_ap_scie, :a_null, :a_pp_scie, :a_p_scie, :a_ap_scie, :p_null, :p_pp_scie, :p_p_scie, :p_ap_scie, :h_null, :h_pp_scie, :h_p_scie, :h_ap_scie, :i_null, :i_pp_scie, :i_p_scie, :i_ap_scie)
   .transform("mapping proficiency bands",
     HashLookup, :proficiency_band, map_prof_band, to: :proficiency_band_id)
   .transform('mapping breakdown', HashLookup, :proficiency_band, map_prof_to_breakdown, to: :breakdown_id)
   .transform("mapping number tested", WithBlock) do |row|
     if row[:breakdown_id] == 8
       row[:number_tested] = row[:w_valid_scale_scie]
     elsif row[:breakdown_id] == 3
       row[:number_tested] = row[:b_valid_scale_scie]
     elsif row[:breakdown_id] == 2
       row[:number_tested] = row[:a_valid_scale_scie]
     elsif row[:breakdown_id] == 112
       row[:number_tested] = row[:p_valid_scale_scie]
     elsif row[:breakdown_id] == 6
       row[:number_tested] = row[:h_valid_scale_scie]
     elsif row[:breakdown_id] == 4
       row[:number_tested] = row[:i_valid_scale_scie]
     end
     row
   end
   .transform("removing * rows", DeleteRows, :number_tested, '*')
   .transform("removing 0 rows", DeleteRows, :number_tested, '0')
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
       year: 2016,
       entity_type: 'public_charter',
       level_code: 'e,m,h',
       test_data_type: 'NJ ASK',
       test_data_type_id: 5,
       subject: 'science',
       subject_id: 25,
       grade: 8
     })
   .transform('null prof band',SumValues,:ecdis_y_null, :ecdis_y_p_scie,:ecdis_y_ap_scie)
   .transform('null prof band',SumValues,:ecdis_n_null, :ecdis_n_p_scie,:ecdis_n_ap_scie)
   .transform('transposing prof bands', Transposer, :proficiency_band, :value_float, :ecdis_y_null, :ecdis_y_pp_scie, :ecdis_y_p_scie, :ecdis_y_ap_scie, :ecdis_n_null, :ecdis_n_pp_scie, :ecdis_n_p_scie, :ecdis_n_ap_scie)
   .transform("mapping proficiency bands",
     HashLookup, :proficiency_band, map_prof_band, to: :proficiency_band_id)
   .transform('mapping breakdown', HashLookup, :proficiency_band, map_prof_to_breakdown, to: :breakdown_id)
   .transform("mapping number tested", WithBlock) do |row|
     if row[:breakdown_id] == 9
       row[:number_tested] = row[:ecdis_y_valid_scale_scie]
     elsif row[:breakdown_id] == 10
       row[:number_tested] = row[:ecdis_n_valid_scale_scie]
     end
     row
   end
   .transform("removing * rows", DeleteRows, :number_tested, '*')
   .transform("removing 0 rows", DeleteRows, :number_tested, '0')
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
       year: 2016,
       entity_type: 'public_charter',
       level_code: 'e,m,h',
       test_data_type: 'NJBCT',
       test_data_type_id: 192,
       subject: 'biology i',
       subject_id: 29,
       grade: 'All'
     })
   .transform('null prof band',SumValues,:total_null, :total_p_scie,:total_ap_scie)
   .transform('null prof band',SumValues,:ge_null, :ge_p_scie,:ge_ap_scie)
   .transform('null prof band',SumValues,:se_null, :se_p_scie,:se_ap_scie)
   .transform('null prof band',SumValues,:lep_null, :lep_p_scie,:lep_ap_scie)
   .transform('transposing prof bands', Transposer, :proficiency_band, :value_float, :total_null, :total_pp_scie, :total_p_scie, :total_ap_scie, :ge_null, :ge_pp_scie, :ge_p_scie, :ge_ap_scie, :se_null, :se_pp_scie, :se_p_scie, :se_ap_scie, :lep_null, :lep_pp_scie, :lep_p_scie, :lep_ap_scie)
   .transform("mapping proficiency bands",
     HashLookup, :proficiency_band, map_prof_band, to: :proficiency_band_id)
   .transform('mapping breakdown', HashLookup, :proficiency_band, map_prof_to_breakdown, to: :breakdown_id)
   .transform("mapping number tested", WithBlock) do |row|
     if row[:breakdown_id] == 1
       row[:number_tested] = row[:total_valid_scale_scie]
     elsif row[:breakdown_id] == 14
       row[:number_tested] = row[:ge_valid_scale_scie]
     elsif row[:breakdown_id] == 13
       row[:number_tested] = row[:se_valid_scale_scie]
     elsif row[:breakdown_id] == 15
       row[:number_tested] = row[:lep_valid_scale_scie]
     end
     row
   end
   .transform("removing * rows", DeleteRows, :number_tested, '*')
   .transform("removing 0 rows", DeleteRows, :number_tested, '0')
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
     else row[:state_id] = row[:state_id]
     end
     row
   end
   .transform("Fill Columns",Fill,
     {
       year: 2016,
       entity_type: 'public_charter',
       level_code: 'e,m,h',
       test_data_type: 'NJBCT',
       test_data_type_id: 192,
       subject: 'biology i',
       subject_id: 29,
       grade: 'All'
     })
   .transform('null prof band',SumValues,:f_null, :f_p_scie,:f_ap_scie)
   .transform('null prof band',SumValues,:m_null, :m_p_scie,:m_ap_scie)
   .transform('transposing prof bands', Transposer, :proficiency_band, :value_float, :f_null, :f_pp_scie, :f_p_scie, :f_ap_scie, :m_null, :m_pp_scie, :m_p_scie, :m_ap_scie)
   .transform("mapping proficiency bands",
     HashLookup, :proficiency_band, map_prof_band, to: :proficiency_band_id)
   .transform('mapping breakdown', HashLookup, :proficiency_band, map_prof_to_breakdown, to: :breakdown_id)
   .transform("mapping number tested", WithBlock) do |row|
     if row[:breakdown_id] == 11
       row[:number_tested] = row[:f_valid_scale_scie]
     elsif row[:breakdown_id] == 12
       row[:number_tested] = row[:m_valid_scale_scie]
     end
     row
   end
   .transform("removing * rows", DeleteRows, :number_tested, '*')
   .transform("removing 0 rows", DeleteRows, :number_tested, '0')
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
     else row[:state_id] = row[:state_id]
     end
     row
   end
   .transform("Fill Columns",Fill,
     {
       year: 2016,
       entity_type: 'public_charter',
       level_code: 'e,m,h',
       test_data_type: 'NJBCT',
       test_data_type_id: 192,
       subject: 'biology i',
       subject_id: 29,
       grade: 'All'
     })
   .transform('null prof band',SumValues,:w_null, :w_p_scie,:w_ap_scie)
   .transform('null prof band',SumValues,:b_null, :b_p_scie,:b_ap_scie)
   .transform('null prof band',SumValues,:a_null, :a_p_scie,:a_ap_scie)
   .transform('null prof band',SumValues,:p_null, :p_p_scie,:p_ap_scie)
   .transform('null prof band',SumValues,:h_null, :h_p_scie,:h_ap_scie)
   .transform('null prof band',SumValues,:i_null, :i_p_scie,:i_ap_scie)
   .transform('transposing prof bands', Transposer, :proficiency_band, :value_float, :w_null, :w_pp_scie, :w_p_scie, :w_ap_scie, :b_null, :b_pp_scie, :b_p_scie, :b_ap_scie, :a_null, :a_pp_scie, :a_p_scie, :a_ap_scie, :p_null, :p_pp_scie, :p_p_scie, :p_ap_scie, :h_null, :h_pp_scie, :h_p_scie, :h_ap_scie, :i_null, :i_pp_scie, :i_p_scie, :i_ap_scie)
   .transform("mapping proficiency bands",
     HashLookup, :proficiency_band, map_prof_band, to: :proficiency_band_id)
   .transform('mapping breakdown', HashLookup, :proficiency_band, map_prof_to_breakdown, to: :breakdown_id)
   .transform("mapping number tested", WithBlock) do |row|
     if row[:breakdown_id] == 8
       row[:number_tested] = row[:w_valid_scale_scie]
     elsif row[:breakdown_id] == 3
       row[:number_tested] = row[:b_valid_scale_scie]
     elsif row[:breakdown_id] == 2
       row[:number_tested] = row[:a_valid_scale_scie]
     elsif row[:breakdown_id] == 112
       row[:number_tested] = row[:p_valid_scale_scie]
     elsif row[:breakdown_id] == 6
       row[:number_tested] = row[:h_valid_scale_scie]
     elsif row[:breakdown_id] == 4
       row[:number_tested] = row[:i_valid_scale_scie]
     end
     row
   end
   .transform("removing * rows", DeleteRows, :number_tested, '*')
   .transform("removing 0 rows", DeleteRows, :number_tested, '0')
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
     else row[:state_id] = row[:state_id]
     end
     row
   end
   .transform("Fill Columns",Fill,
     {
       year: 2016,
       entity_type: 'public_charter',
       level_code: 'e,m,h',
       test_data_type: 'NJBCT',
       test_data_type_id: 192,
       subject: 'biology i',
       subject_id: 29,
       grade: 'All'
     })
   .transform('null prof band',SumValues,:ecdis_y_null, :ecdis_y_p_scie,:ecdis_y_ap_scie)
   .transform('null prof band',SumValues,:ecdis_n_null, :ecdis_n_p_scie,:ecdis_n_ap_scie)
   .transform('transposing prof bands', Transposer, :proficiency_band, :value_float, :ecdis_y_null, :ecdis_y_pp_scie, :ecdis_y_p_scie, :ecdis_y_ap_scie, :ecdis_n_null, :ecdis_n_pp_scie, :ecdis_n_p_scie, :ecdis_n_ap_scie)
   .transform("mapping proficiency bands",
     HashLookup, :proficiency_band, map_prof_band, to: :proficiency_band_id)
   .transform('mapping breakdown', HashLookup, :proficiency_band, map_prof_to_breakdown, to: :breakdown_id)
   .transform("mapping number tested", WithBlock) do |row|
     if row[:breakdown_id] == 9
       row[:number_tested] = row[:ecdis_y_valid_scale_scie]
     elsif row[:breakdown_id] == 10
       row[:number_tested] = row[:ecdis_n_valid_scale_scie]
     end
     row
   end
   .transform("removing * rows", DeleteRows, :number_tested, '*')
   .transform("removing 0 rows", DeleteRows, :number_tested, '0')
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
			source_id: 2,
			state:'nj',
			notes:'DXT-1886 NJ 2016 PARCC ASK NJBCT test load',
			url: 'http://www.state.nj.us/education/',
			file: 'nj/2016/nj.2016.1.public.charter.[level].txt',
			level: nil,
			school_type: 'public,charter'
		}
	end
end

NJTestProcessor2016PARCCASKNJBCT.new(ARGV[0],max:nil,offset:nil).run
