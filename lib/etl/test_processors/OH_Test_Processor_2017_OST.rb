require_relative "../test_processor"

class OHTestProcessor2017OST < GS::ETL::TestProcessor

  def initiailize(*args)
    super
    @year = 2017
  end

map_oh_subject_type = {
  'reading' => 2,
  'math' => 5,
  'social' => 18,
  'science' => 19,
  'writing' => 3,
  'english_i' => 17,
  'ela_i' => 73,
  'english_ii' => 21,
  'ela_ii' => 70,
  'math_i' => 7,
  'integrated_math_i' => 7,
  'integrated_math_ii' => 9,
  'math_ii' => 9,
  'algebra_i' => 6,
  'geometry' => 8,
  'biology' => 22,
  'physical_science' => 24,
  'government' => 56,
  'history' => 82
}

map_oh_breakdown_gsdata_id = {
  'NonDisabled' => 30,
  'Disabled' => 27,
  'Disadvantaged' => 23,
  'NonDisadvantaged' => 24,
  'White' => 21,
  'Black' => 17,
  'Hispanic' => 19,
  'Multiracial' => 22,
  'American Indian or Alaskan Native' => 18,
  'Asian or Pacific Islander' => 15,
  'Female' => 26,
  'Male' => 25,
  'LEP' => 32
}



source("achieve_state.txt",[],col_sep: "\t") do |s|
  s.transform("Set state entity level", Fill, {entity_level: 'state'})
  .transform("Transpose subject grade columns", 
    Transposer, 
      :subject,:value_float,
      'Reading 3rd Grade 2016-17 % at or above Proficient - Building','Math 3rd Grade 2016-17 % at or above Proficient -Building',
      :reading_4,:math_4,:social_studies_4,
      :reading_5,:math_5,:science_5,
      :reading_6,:math_6,:social_studies_6,
      :reading_7,:math_7,
      :reading_8,:math_8,:science_8,
      :reading_11,:math_11,:science_11,:social_studies_11,:writing_11, :reading_11,
      :english_i_hs,:english_ii_hs,:math_i_hs,:math_ii_hs,:algebra_i_hs,:geometry_hs,:biology_hs,:physical_science_hs,:government_hs,:history_hs)
  .transform("Adding grades",WithBlock) do |row|
    row[:grade] = row[:subject][/([^\_]+)$/]
    row
  end
  .transform("",WithBlock) do |row|
    if row[:grade] == 'hs'
      row[:grade] = 'All'
      row[:subject] = row[:subject].to_s.gsub!('_hs','')
    elsif row[:grade] != 'All'
      row[:grade] = row[:grade]
      row[:subject] = row[:subject][/^[^\_[0-9]]*/]
    else row[:subject] = row[:subject]
    end
    row
  end
  .transform("Adding subject ids",
    HashLookup, :subject, map_oh_subject_type, to: :academic_gsdata_id)
  .transform('Fill missing default fields', Fill, {
    entity_type: 'public_charter',
    proficiency_band: 'Proficiency and Above',
    proficiency_band_gsdata_id: 1,
    level_code: 'e,m,h',
    year: 2017,
    breakdown: 'All Students',
    breakdown_gsdata_id: 1
  })
  .transform('remove NC value rows', DeleteRows, :value_float, 'NC')
  .transform("map >95", HashLookup, :value_float, {'>95.0' => '-95'} )
  .transform("mapping data type",
    HashLookup, :grade, map_data_type, to: :test_data_type)
  .transform("mapping data type id",
    HashLookup, :grade, map_data_type_id, to: :gsdata_test_data_type_id)
end

source("Achieve_School.txt",[],col_sep: "\t") do |s|
  s.transform("Set school entity level", Fill, {entity_level: 'school'})
  .transform("Renaming fields", MultiFieldRenamer,
    {
      building_irn: :state_id,
      building_name: :school_name,
      District_Name: :district_name
  	})
   .transform("padding ids",WithBlock) do |row|
     row[:state_id] = '%06i' % (row[:state_id].to_i)
     row
   end
  .transform("Transpose subject grade columns", 
    Transposer, 
      :subject,:value_float,
      :reading_3,:math_3,
      :reading_4,:math_4,:social_studies_4,
      :reading_5,:math_5,:science_5,
      :reading_6,:math_6,:social_studies_6,
      :reading_7,:math_7,
      :reading_8,:math_8,:science_8,
      :reading_11,:math_11,:science_11,:social_studies_11,:writing_11,
      :english_i_hs,:english_ii_hs,:math_i_hs,:math_ii_hs,:algebra_i_hs,:geometry_hs,:biology_hs,:physical_science_hs,:government_hs,:history_hs)
  .transform("Adding grades",WithBlock) do |row|
    row[:grade] = row[:subject][/([^\_]+)$/]
    row
  end
  .transform("",WithBlock) do |row|
    if row[:grade] == 'hs'
      row[:grade] = 'All'
      row[:subject] = row[:subject].to_s.gsub!('_hs','')
    elsif row[:grade] != 'All'
      row[:grade] = row[:grade]
      row[:subject] = row[:subject][/^[^\_[0-9]]*/]
    else row[:subject] = row[:subject]
    end
    row
  end
  .transform("Adding subject ids",
    HashLookup, :subject, map_oh_subject_type, to: :academic_gsdata_id)
  .transform('Fill missing default fields', Fill, {
    entity_type: 'public_charter',
    proficiency_band: 'Proficiency and Above',
    proficiency_band_gsdata_id: 1,
    number_tested: nil,
    level_code: 'e,m,h',
    year: 2017,
    breakdown: 'All Students',
    breakdown_gsdata_id: 1
  })
  .transform('remove NC value rows', DeleteRows, :value_float, 'NC')
  .transform("map >95", HashLookup, :value_float, {'>95.0' => '-95'} )
  .transform("mapping data type",
    HashLookup, :grade, map_data_type, to: :test_data_type)
  .transform("mapping data type id",
    HashLookup, :grade, map_data_type_id, to: :gsdata_test_data_type_id)
end

source("achieve_disab.txt",[],col_sep: "\t") do |s|
  s.transform("Set school entity level", Fill, {entity_level: 'school'})
  .transform("Renaming fields", MultiFieldRenamer,
    {
      building_irn: :state_id,
      building_name: :school_name,
      District_Name: :district_name,
      student_group: :breakdown
  	})
   .transform("padding ids",WithBlock) do |row|
     row[:state_id] = '%06i' % (row[:state_id].to_i)
     row
   end
  .transform("Transpose subject grade columns", 
    Transposer, 
      :subject,:value_float,
      :reading_3,:math_3,
      :reading_4,:math_4,:social_studies_4,
      :reading_5,:math_5,:science_5,
      :reading_6,:math_6,:social_studies_6,
      :reading_7,:math_7,
      :reading_8,:math_8,:science_8,
      :reading_11,:math_11,:science_11,:social_studies_11,:writing_11, :reading_11,
      :ela_i_eoc,:ela_ii_eoc,:integrated_math_i_eoc,:integrated_math_ii_eoc,:algebra_i_eoc,:geometry_eoc,:biology_eoc,:physical_science_eoc,:government_eoc,:history_eoc)
  .transform("Adding grades",WithBlock) do |row|
    row[:grade] = row[:subject][/([^\_]+)$/]
    row
  end
  .transform("",WithBlock) do |row|
    if row[:grade] == 'eoc'
      row[:grade] = 'All'
      row[:subject] = row[:subject].to_s.gsub!('_eoc','')
    elsif row[:grade] != 'All'
      row[:grade] = row[:grade]
      row[:subject] = row[:subject][/^[^\_[0-9]]*/]
    else row[:subject] = row[:subject]
    end
    row
  end
  .transform("Adding subject ids",
    HashLookup, :subject, map_oh_subject_type, to: :academic_gsdata_id)
  .transform("Adding breakdown ids",
    HashLookup, :breakdown, map_oh_breakdown_gsdata_id, to: :breakdown_gsdata_id)
  .transform('Fill missing default fields', Fill, {
    entity_type: 'public_charter',
    proficiency_band: 'Proficiency and Above',
    proficiency_band_gsdata_id: 1,
    level_code: 'e,m,h',
    year: 2017
  })
  .transform('remove NC value rows', DeleteRows, :value_float, 'NC')
  .transform("map >95", HashLookup, :value_float, {'>95.0' => '-95'} )
  .transform("mapping data type",
    HashLookup, :grade, map_data_type, to: :test_data_type)
  .transform("mapping data type id",
    HashLookup, :grade, map_data_type_id, to: :gsdata_test_data_type_id)
end

source("achieve_econ.txt",[],col_sep: "\t") do |s|
  s.transform("Set school entity level", Fill, {entity_level: 'school'})
  .transform("Renaming fields", MultiFieldRenamer,
    {
      building_irn: :state_id,
      district_irn: :district_id,
      building_name: :school_name,
      District_Name: :district_name,
      student_group: :breakdown
  	})
   .transform("padding ids",WithBlock) do |row|
     row[:state_id] = '%06i' % (row[:state_id].to_i)
     row
   end
  .transform("Transpose subject grade columns", 
    Transposer, 
      :subject,:value_float,
      :reading_3,:math_3,
      :reading_4,:math_4,:social_studies_4,
      :reading_5,:math_5,:science_5,
      :reading_6,:math_6,:social_studies_6,
      :reading_7,:math_7,
      :reading_8,:math_8,:science_8,
      :reading_11,:math_11,:science_11,:social_studies_11,:writing_11, :reading_11,
      :ela_i_eoc,:ela_ii_eoc,:integrated_math_i_eoc,:integrated_math_ii_eoc,:algebra_i_eoc,:geometry_eoc,:biology_eoc,:physical_science_eoc,:government_eoc,:history_eoc)
  .transform("Adding grades",WithBlock) do |row|
    row[:grade] = row[:subject][/([^\_]+)$/]
    row
  end
  .transform("",WithBlock) do |row|
    if row[:grade] == 'eoc'
      row[:grade] = 'All'
      row[:subject] = row[:subject].to_s.gsub!('_eoc','')
    elsif row[:grade] != 'All'
      row[:grade] = row[:grade]
      row[:subject] = row[:subject][/^[^\_[0-9]]*/]
    else row[:subject] = row[:subject]
    end
    row
  end
  .transform("Adding subject ids",
    HashLookup, :subject, map_oh_subject_type, to: :academic_gsdata_id)
  .transform("Adding breakdown ids",
    HashLookup, :breakdown, map_oh_breakdown_gsdata_id, to: :breakdown_gsdata_id)
  .transform('Fill missing default fields', Fill, {
    entity_type: 'public_charter',
    proficiency_band: 'Proficiency and Above',
    proficiency_band_gsdata_id: 1,
    level_code: 'e,m,h',
    year: 2017
  })
  .transform('remove NC value rows', DeleteRows, :value_float, 'NC')
  .transform("map >95", HashLookup, :value_float, {'>95.0' => '-95'} )
  .transform("mapping data type",
    HashLookup, :grade, map_data_type, to: :test_data_type)
  .transform("mapping data type id",
    HashLookup, :grade, map_data_type_id, to: :gsdata_test_data_type_id)
end

source("achieve_ethnic.txt",[],col_sep: "\t") do |s|
  s.transform("Set school entity level", Fill, {entity_level: 'school'})
  .transform("Renaming fields", MultiFieldRenamer,
    {
      building_irn: :state_id,
      district_irn: :district_id,
      building_name: :school_name,
      District_Name: :district_name,
      student_group: :breakdown
  	})
   .transform("padding ids",WithBlock) do |row|
     row[:state_id] = '%06i' % (row[:state_id].to_i)
     row
   end
  .transform("Transpose subject grade columns", 
    Transposer, 
      :subject,:value_float,
      :reading_3,:math_3,
      :reading_4,:math_4,:social_studies_4,
      :reading_5,:math_5,:science_5,
      :reading_6,:math_6,:social_studies_6,
      :reading_7,:math_7,
      :reading_8,:math_8,:science_8,
      :reading_11,:math_11,:science_11,:social_studies_11,:writing_11, :reading_11,
      :ela_i_eoc,:ela_ii_eoc,:integrated_math_i_eoc,:integrated_math_ii_eoc,:algebra_i_eoc,:geometry_eoc,:biology_eoc,:physical_science_eoc,:government_eoc,:history_eoc)
  .transform("Adding grades",WithBlock) do |row|
    row[:grade] = row[:subject][/([^\_]+)$/]
    row
  end
  .transform("",WithBlock) do |row|
    if row[:grade] == 'eoc'
      row[:grade] = 'All'
      row[:subject] = row[:subject].to_s.gsub!('_eoc','')
    elsif row[:grade] != 'All'
      row[:grade] = row[:grade]
      row[:subject] = row[:subject][/^[^\_[0-9]]*/]
    else row[:subject] = row[:subject]
    end
    row
  end
  .transform("Adding subject ids",
    HashLookup, :subject, map_oh_subject_type, to: :academic_gsdata_id)
  .transform("Adding breakdown ids",
    HashLookup, :breakdown, map_oh_breakdown_gsdata_id, to: :breakdown_gsdata_id)
  .transform('Fill missing default fields', Fill, {
    entity_type: 'public_charter',
    proficiency_band: 'Proficiency and Above',
    proficiency_band_gsdata_id: 1,
    level_code: 'e,m,h',
    year: 2017
  })
  .transform('remove NC value rows', DeleteRows, :value_float, 'NC')
  .transform("fill blank values", WithBlock) do |row|
    if row[:value_float].nil?
      row[:value_float] = 'skip'
    end
    row
  end
  .transform('remove NC value rows', DeleteRows, :value_float, 'skip')
  .transform("map >95", HashLookup, :value_float, {'>95.0' => '-95'} )
  .transform("mapping data type",
    HashLookup, :grade, map_data_type, to: :test_data_type)
  .transform("mapping data type id",
    HashLookup, :grade, map_data_type_id, to: :gsdata_test_data_type_id)
end

source("achieve_gender.txt",[],col_sep: "\t") do |s|
  s.transform("Set school entity level", Fill, {entity_level: 'school'})
  .transform("Renaming fields", MultiFieldRenamer,
    {
      building_irn: :state_id,
      district_irn: :district_id,
      building_name: :school_name,
      District_Name: :district_name,
      student_group: :breakdown
  	})
   .transform("padding ids",WithBlock) do |row|
     row[:state_id] = '%06i' % (row[:state_id].to_i)
     row
   end
  .transform("Transpose subject grade columns", 
    Transposer, 
      :subject,:value_float,
      :reading_3,:math_3,
      :reading_4,:math_4,:social_studies_4,
      :reading_5,:math_5,:science_5,
      :reading_6,:math_6,:social_studies_6,
      :reading_7,:math_7,
      :reading_8,:math_8,:science_8,
      :reading_11,:math_11,:science_11,:social_studies_11,:writing_11, :reading_11,
      :ela_i_eoc,:ela_ii_eoc,:integrated_math_i_eoc,:integrated_math_ii_eoc,:algebra_i_eoc,:geometry_eoc,:biology_eoc,:physical_science_eoc,:government_eoc,:history_eoc)
  .transform("Adding grades",WithBlock) do |row|
    row[:grade] = row[:subject][/([^\_]+)$/]
    row
  end
  .transform("",WithBlock) do |row|
    if row[:grade] == 'eoc'
      row[:grade] = 'All'
      row[:subject] = row[:subject].to_s.gsub!('_eoc','')
    elsif row[:grade] != 'All'
      row[:grade] = row[:grade]
      row[:subject] = row[:subject][/^[^\_[0-9]]*/]
    else row[:subject] = row[:subject]
    end
    row
  end
  .transform("Adding subject ids",
    HashLookup, :subject, map_oh_subject_type, to: :academic_gsdata_id)
  .transform("Adding breakdown ids",
    HashLookup, :breakdown, map_oh_breakdown_gsdata_id, to: :breakdown_gsdata_id)
  .transform('Fill missing default fields', Fill, {
    entity_type: 'public_charter',
    proficiency_band: 'Proficiency and Above',
    proficiency_band_gsdata_id: 1,
    level_code: 'e,m,h',
    year: 2017
  })
  .transform('remove NC value rows', DeleteRows, :value_float, 'NC')
  .transform("fill blank values", WithBlock) do |row|
    if row[:value_float].nil?
      row[:value_float] = 'skip'
    end
    row
  end
  .transform('remove NC value rows', DeleteRows, :value_float, 'skip')
  .transform("map >95", HashLookup, :value_float, {'>95.0' => '-95'} )
  .transform("mapping data type",
    HashLookup, :grade, map_data_type, to: :test_data_type)
  .transform("mapping data type id",
    HashLookup, :grade, map_data_type_id, to: :gsdata_test_data_type_id)
end

source("achieve_lep.txt",[],col_sep: "\t") do |s|
  s.transform("Set school entity level", Fill, {entity_level: 'school'})
  .transform("Renaming fields", MultiFieldRenamer,
    {
      building_irn: :state_id,
      district_irn: :district_id,
      building_name: :school_name,
      District_Name: :district_name,
      student_group: :breakdown
  	})
   .transform("padding ids",WithBlock) do |row|
     row[:state_id] = '%06i' % (row[:state_id].to_i)
     row
   end
  .transform("Transpose subject grade columns", 
    Transposer, 
      :subject,:value_float,
      :reading_3,:math_3,
      :reading_4,:math_4,:social_studies_4,
      :reading_5,:math_5,:science_5,
      :reading_6,:math_6,:social_studies_6,
      :reading_7,:math_7,
      :reading_8,:math_8,:science_8,
      :reading_11,:math_11,:science_11,:social_studies_11,:writing_11, :reading_11,
      :ela_i_eoc,:ela_ii_eoc,:integrated_math_i_eoc,:integrated_math_ii_eoc,:algebra_i_eoc,:geometry_eoc,:biology_eoc,:physical_science_eoc,:government_eoc,:history_eoc)
  .transform("Adding grades",WithBlock) do |row|
    row[:grade] = row[:subject][/([^\_]+)$/]
    row
  end
  .transform("",WithBlock) do |row|
    if row[:grade] == 'eoc'
      row[:grade] = 'All'
      row[:subject] = row[:subject].to_s.gsub!('_eoc','')
    elsif row[:grade] != 'All'
      row[:grade] = row[:grade]
      row[:subject] = row[:subject][/^[^\_[0-9]]*/]
    else row[:subject] = row[:subject]
    end
    row
  end
  .transform("Adding subject ids",
    HashLookup, :subject, map_oh_subject_type, to: :academic_gsdata_id)
  .transform("Adding breakdown ids",
    HashLookup, :breakdown, map_oh_breakdown_gsdata_id, to: :breakdown_gsdata_id)
  .transform('Fill missing default fields', Fill, {
    entity_type: 'public_charter',
    proficiency_band: 'Proficiency and Above',
    proficiency_band_gsdata_id: 1,
    level_code: 'e,m,h',
    year: 2017
  })
  .transform('remove NC value rows', DeleteRows, :value_float, 'NC')
  .transform("fill blank values", WithBlock) do |row|
    if row[:value_float].nil?
      row[:value_float] = 'skip'
    end
    row
  end
  .transform('remove NC value rows', DeleteRows, :value_float, 'skip')
  .transform("map >95", HashLookup, :value_float, {'>95.0' => '-95'} )
  .transform("mapping data type",
    HashLookup, :grade, map_data_type, to: :test_data_type)
  .transform("mapping data type id",
    HashLookup, :grade, map_data_type_id, to: :gsdata_test_data_type_id)
end

source("achieve_district.txt",[],col_sep: "\t") do |s|
  s.transform("Set district entity level", Fill, {entity_level: 'district'})
  .transform("Renaming fields", MultiFieldRenamer,
    {
      district_irn: :state_id,
      district_name: :district_name
  	})
   .transform("padding ids",WithBlock) do |row|
     row[:state_id] = '%06i' % (row[:state_id].to_i)
     row
   end
  .transform("Transpose subject grade columns", 
    Transposer, 
      :subject,:value_float,
      :reading_3,:math_3,
      :reading_4,:math_4,:social_studies_4,
      :reading_5,:math_5,:science_5,
      :reading_6,:math_6,:social_studies_6,
      :reading_7,:math_7,
      :reading_8,:math_8,:science_8,
      :reading_11,:math_11,:science_11,:social_studies_11,:writing_11,
      :english_i_hs,:english_ii_hs,:math_i_hs,:math_ii_hs,:algebra_i_hs,:geometry_hs,:biology_hs,:physical_science_hs,:government_hs,:history_hs)
  .transform("Adding grades",WithBlock) do |row|
    row[:grade] = row[:subject][/([^\_]+)$/]
    row
  end
  .transform("",WithBlock) do |row|
    if row[:grade] == 'hs'
      row[:grade] = 'All'
      row[:subject] = row[:subject].to_s.gsub!('_hs','')
    elsif row[:grade] != 'All'
      row[:grade] = row[:grade]
      row[:subject] = row[:subject][/^[^\_[0-9]]*/]
    else row[:subject] = row[:subject]
    end
    row
  end
  .transform("Adding subject ids",
    HashLookup, :subject, map_oh_subject_type, to: :academic_gsdata_id)
  .transform('Fill missing default fields', Fill, {
    entity_type: 'public_charter',
    proficiency_band: 'Proficiency and Above',
    proficiency_band_gsdata_id: 1,
    number_tested: nil,
    level_code: 'e,m,h',
    year: 2017,
    breakdown: 'All Students',
    breakdown_gsdata_id: 1
  })
  .transform('remove NC value rows', DeleteRows, :value_float, 'NC')
  .transform("map >95", HashLookup, :value_float, {'>95.0' => '-95'} )
  .transform("mapping data type",
    HashLookup, :grade, map_data_type, to: :test_data_type)
  .transform("mapping data type id",
    HashLookup, :grade, map_data_type_id, to: :gsdata_test_data_type_id)
end

source("achieve_district_disab.txt",[],col_sep: "\t") do |s|
  s.transform("Set district entity level", Fill, {entity_level: 'district'})
  .transform("Renaming fields", MultiFieldRenamer,
    {
      district_irn: :state_id,
      district_name: :district_name,
      student_group: :breakdown
  	})
   .transform("padding ids",WithBlock) do |row|
     row[:state_id] = '%06i' % (row[:state_id].to_i)
     row
   end
  .transform("Transpose subject grade columns", 
    Transposer, 
      :subject,:value_float,
      :reading_3,:math_3,
      :reading_4,:math_4,:social_studies_4,
      :reading_5,:math_5,:science_5,
      :reading_6,:math_6,:social_studies_6,
      :reading_7,:math_7,
      :reading_8,:math_8,:science_8,
      :reading_11,:math_11,:science_11,:social_studies_11,:writing_11, :reading_11,
      :ela_i_eoc,:ela_ii_eoc,:integrated_math_i_eoc,:integrated_math_ii_eoc,:algebra_i_eoc,:geometry_eoc,:biology_eoc,:physical_science_eoc,:government_eoc,:history_eoc)
  .transform("Adding grades",WithBlock) do |row|
    row[:grade] = row[:subject][/([^\_]+)$/]
    row
  end
  .transform("",WithBlock) do |row|
    if row[:grade] == 'eoc'
      row[:grade] = 'All'
      row[:subject] = row[:subject].to_s.gsub!('_eoc','')
    elsif row[:grade] != 'All'
      row[:grade] = row[:grade]
      row[:subject] = row[:subject][/^[^\_[0-9]]*/]
    else row[:subject] = row[:subject]
    end
    row
  end
  .transform("Adding subject ids",
    HashLookup, :subject, map_oh_subject_type, to: :academic_gsdata_id)
  .transform("Adding breakdown ids",
    HashLookup, :breakdown, map_oh_breakdown_gsdata_id, to: :breakdown_gsdata_id)
  .transform('Fill missing default fields', Fill, {
    entity_type: 'public_charter',
    proficiency_band: 'Proficiency and Above',
    proficiency_band_gsdata_id: 1,
    level_code: 'e,m,h',
    year: 2017
  })
  .transform('remove NC value rows', DeleteRows, :value_float, 'NC')
  .transform("map >95", HashLookup, :value_float, {'>95.0' => '-95'} )
  .transform("mapping data type",
    HashLookup, :grade, map_data_type, to: :test_data_type)
  .transform("mapping data type id",
    HashLookup, :grade, map_data_type_id, to: :gsdata_test_data_type_id)
end

source("achieve_district_econ.txt",[],col_sep: "\t") do |s|
  s.transform("Set district entity level", Fill, {entity_level: 'district'})
  .transform("Renaming fields", MultiFieldRenamer,
    {
      district_irn: :state_id,
      district_name: :district_name,
      student_group: :breakdown
  	})
   .transform("padding ids",WithBlock) do |row|
     row[:state_id] = '%06i' % (row[:state_id].to_i)
     row
   end
  .transform("Transpose subject grade columns", 
    Transposer, 
      :subject,:value_float,
      :reading_3,:math_3,
      :reading_4,:math_4,:social_studies_4,
      :reading_5,:math_5,:science_5,
      :reading_6,:math_6,:social_studies_6,
      :reading_7,:math_7,
      :reading_8,:math_8,:science_8,
      :reading_11,:math_11,:science_11,:social_studies_11,:writing_11, :reading_11,
      :ela_i_eoc,:ela_ii_eoc,:integrated_math_i_eoc,:integrated_math_ii_eoc,:algebra_i_eoc,:geometry_eoc,:biology_eoc,:physical_science_eoc,:government_eoc,:history_eoc)
  .transform("Adding grades",WithBlock) do |row|
    row[:grade] = row[:subject][/([^\_]+)$/]
    row
  end
  .transform("",WithBlock) do |row|
    if row[:grade] == 'eoc'
      row[:grade] = 'All'
      row[:subject] = row[:subject].to_s.gsub!('_eoc','')
    elsif row[:grade] != 'All'
      row[:grade] = row[:grade]
      row[:subject] = row[:subject][/^[^\_[0-9]]*/]
    else row[:subject] = row[:subject]
    end
    row
  end
  .transform("Adding subject ids",
    HashLookup, :subject, map_oh_subject_type, to: :academic_gsdata_id)
  .transform("Adding breakdown ids",
    HashLookup, :breakdown, map_oh_breakdown_gsdata_id, to: :breakdown_gsdata_id)
  .transform('Fill missing default fields', Fill, {
    entity_type: 'public_charter',
    proficiency_band: 'Proficiency and Above',
    proficiency_band_gsdata_id: 1,
    level_code: 'e,m,h',
    year: 2017
  })
  .transform('remove NC value rows', DeleteRows, :value_float, 'NC')
  .transform("map >95", HashLookup, :value_float, {'>95.0' => '-95'} )
  .transform("mapping data type",
    HashLookup, :grade, map_data_type, to: :test_data_type)
  .transform("mapping data type id",
    HashLookup, :grade, map_data_type_id, to: :gsdata_test_data_type_id)
end

source("achieve_district_ethnic.txt",[],col_sep: "\t") do |s|
  s.transform("Set district entity level", Fill, {entity_level: 'district'})
  .transform("Renaming fields", MultiFieldRenamer,
    {
      district_irn: :state_id,
      district_name: :district_name,
      student_group: :breakdown
  	})
   .transform("padding ids",WithBlock) do |row|
     row[:state_id] = '%06i' % (row[:state_id].to_i)
     row
   end
  .transform("Transpose subject grade columns", 
    Transposer, 
      :subject,:value_float,
      :reading_3,:math_3,
      :reading_4,:math_4,:social_studies_4,
      :reading_5,:math_5,:science_5,
      :reading_6,:math_6,:social_studies_6,
      :reading_7,:math_7,
      :reading_8,:math_8,:science_8,
      :reading_11,:math_11,:science_11,:social_studies_11,:writing_11, :reading_11,
      :ela_i_eoc,:ela_ii_eoc,:integrated_math_i_eoc,:integrated_math_ii_eoc,:algebra_i_eoc,:geometry_eoc,:biology_eoc,:physical_science_eoc,:government_eoc,:history_eoc)
  .transform("Adding grades",WithBlock) do |row|
    row[:grade] = row[:subject][/([^\_]+)$/]
    row
  end
  .transform("",WithBlock) do |row|
    if row[:grade] == 'eoc'
      row[:grade] = 'All'
      row[:subject] = row[:subject].to_s.gsub!('_eoc','')
    elsif row[:grade] != 'All'
      row[:grade] = row[:grade]
      row[:subject] = row[:subject][/^[^\_[0-9]]*/]
    else row[:subject] = row[:subject]
    end
    row
  end
  .transform("Adding subject ids",
    HashLookup, :subject, map_oh_subject_type, to: :academic_gsdata_id)
  .transform("Adding breakdown ids",
    HashLookup, :breakdown, map_oh_breakdown_gsdata_id, to: :breakdown_gsdata_id)
  .transform('Fill missing default fields', Fill, {
    entity_type: 'public_charter',
    proficiency_band: 'Proficiency and Above',
    proficiency_band_gsdata_id: 1,
    level_code: 'e,m,h',
    year: 2017
  })
  .transform('remove NC value rows', DeleteRows, :value_float, 'NC')
  .transform("map >95", HashLookup, :value_float, {'>95.0' => '-95'} )
  .transform("mapping data type",
    HashLookup, :grade, map_data_type, to: :test_data_type)
  .transform("mapping data type id",
    HashLookup, :grade, map_data_type_id, to: :gsdata_test_data_type_id)
 end

source("achieve_district_gender.txt",[],col_sep: "\t") do |s|
  s.transform("Set district entity level", Fill, {entity_level: 'district'})
  .transform("Renaming fields", MultiFieldRenamer,
    {
      district_irn: :state_id,
      district_name: :district_name,
      student_group: :breakdown
  	})
   .transform("padding ids",WithBlock) do |row|
     row[:state_id] = '%06i' % (row[:state_id].to_i)
     row
   end
  .transform("Transpose subject grade columns", 
    Transposer, 
      :subject,:value_float,
      :reading_3,:math_3,
      :reading_4,:math_4,:social_studies_4,
      :reading_5,:math_5,:science_5,
      :reading_6,:math_6,:social_studies_6,
      :reading_7,:math_7,
      :reading_8,:math_8,:science_8,
      :reading_11,:math_11,:science_11,:social_studies_11,:writing_11, :reading_11,
      :ela_i_eoc,:ela_ii_eoc,:integrated_math_i_eoc,:integrated_math_ii_eoc,:algebra_i_eoc,:geometry_eoc,:biology_eoc,:physical_science_eoc,:government_eoc,:history_eoc)
  .transform("Adding grades",WithBlock) do |row|
    row[:grade] = row[:subject][/([^\_]+)$/]
    row
  end
  .transform("",WithBlock) do |row|
    if row[:grade] == 'eoc'
      row[:grade] = 'All'
      row[:subject] = row[:subject].to_s.gsub!('_eoc','')
    elsif row[:grade] != 'All'
      row[:grade] = row[:grade]
      row[:subject] = row[:subject][/^[^\_[0-9]]*/]
    else row[:subject] = row[:subject]
    end
    row
  end
  .transform("Adding subject ids",
    HashLookup, :subject, map_oh_subject_type, to: :academic_gsdata_id)
  .transform("Adding breakdown ids",
    HashLookup, :breakdown, map_oh_breakdown_gsdata_id, to: :breakdown_gsdata_id)
  .transform('Fill missing default fields', Fill, {
    entity_type: 'public_charter',
    proficiency_band: 'Proficiency and Above',
    proficiency_band_gsdata_id: 1,
    level_code: 'e,m,h',
    year: 2017
  })
  .transform('remove NC value rows', DeleteRows, :value_float, 'NC')
  .transform("map >95", HashLookup, :value_float, {'>95.0' => '-95'} )
  .transform("mapping data type",
    HashLookup, :grade, map_data_type, to: :test_data_type)
  .transform("mapping data type id",
    HashLookup, :grade, map_data_type_id, to: :gsdata_test_data_type_id)
end

source("achieve_district_lep.txt",[],col_sep: "\t") do |s|
  s.transform("Set district entity level", Fill, {entity_level: 'district'})
  .transform("Renaming fields", MultiFieldRenamer,
    {
      district_irn: :state_id,
      district_name: :district_name,
      student_group: :breakdown
  	})
   .transform("padding ids",WithBlock) do |row|
     row[:state_id] = '%06i' % (row[:state_id].to_i)
     row
   end
  .transform("Transpose subject grade columns", 
    Transposer, 
      :subject,:value_float,
      :reading_3,:math_3,
      :reading_4,:math_4,:social_studies_4,
      :reading_5,:math_5,:science_5,
      :reading_6,:math_6,:social_studies_6,
      :reading_7,:math_7,
      :reading_8,:math_8,:science_8,
      :reading_11,:math_11,:science_11,:social_studies_11,:writing_11, :reading_11,
      :ela_i_eoc,:ela_ii_eoc,:integrated_math_i_eoc,:integrated_math_ii_eoc,:algebra_i_eoc,:geometry_eoc,:biology_eoc,:physical_science_eoc,:government_eoc,:history_eoc)
  .transform("Adding grades",WithBlock) do |row|
    row[:grade] = row[:subject][/([^\_]+)$/]
    row
  end
  .transform("",WithBlock) do |row|
    if row[:grade] == 'eoc'
      row[:grade] = 'All'
      row[:subject] = row[:subject].to_s.gsub!('_eoc','')
    elsif row[:grade] != 'All'
      row[:grade] = row[:grade]
      row[:subject] = row[:subject][/^[^\_[0-9]]*/]
    else row[:subject] = row[:subject]
    end
    row
  end
  .transform("Adding subject ids",
    HashLookup, :subject, map_oh_subject_type, to: :academic_gsdata_id)
  .transform("Adding breakdown ids",
    HashLookup, :breakdown, map_oh_breakdown_gsdata_id, to: :breakdown_gsdata_id)
  .transform('Fill missing default fields', Fill, {
    entity_type: 'public_charter',
    proficiency_band: 'Proficiency and Above',
    proficiency_band_gsdata_id: 1,
    level_code: 'e,m,h',
    year: 2017
  })
  .transform('remove NC value rows', DeleteRows, :value_float, 'NC')
  .transform("map >95", HashLookup, :value_float, {'>95.0' => '-95'} )
  .transform("mapping data type",
    HashLookup, :grade, map_data_type, to: :test_data_type)
  .transform("mapping data type id",
    HashLookup, :grade, map_data_type_id, to: :gsdata_test_data_type_id)
end

  # .transform("adding data type", WithBlock) do |row|
  #   if row[:grade] != '11'
  #     row[:test_data_type] = 'OST'
  #     row[:gsdata_test_data_type_id] = '256'
  #   elsif row[:grade] == '11'
  #     row[:test_data_type] = 'OGT'
  #     row[:gsdata_test_data_type_id] = '22'
  #     row
  #   end
  # end

#  .transform("",WithBlock) do |row|
#    require 'byebug'
#    byebug
#  end

#    row[:grade] = row[:subject][/\d+/].to_i


  def config_hash
    {
        gsdata_source_id: 40,
        source_name: 'Ohio Department of Education',
        date_valid: '2017-01-01 00:00:00',
        state: 'oh',
        notes: 'DXT-2876: OH OST 2017 test load.',
        url: 'https://reportcard.education.ohio.gov/download',
        file: 'oh/2017/output/oh.2017.1.public.charter.[level].txt',
        level: nil,
        school_type: 'public,charter'
    }
  end
end

OHTestProcessor2017OST.new(ARGV[0], max: nil).run
