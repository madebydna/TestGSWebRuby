require_relative "../test_processor"

class OHTestProcessor2017OST < GS::ETL::TestProcessor

  def initialize(*args)
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

  map_oh_subject_type_state = {
  'English Language Arts' => 4,
  'Mathematics' => 5,
  'Social Studies' => 18,
  'Science' => 19,
  'English Language Arts I' => 73,
  'English Language Arts II' => 21,
  'Mathematics I' => 7,
  'Mathematics II' => 9,
  'Algebra I' => 6,
  'Geometry' => 8,
  'Biology' => 22,
  'Physical Science' => 24,
  'American US Government' => 56,
  'American US History' => 23
 }

 map_oh_breakdown_gsdata_id = {
  'NonDisabled' => 30,
  'Disabled' => 27,
  'Disadvantaged' => 23,
  'NonDisadvantaged' => 24,
  'White' => 21,
  '"White, Non-Hispanic"' => 21,
  'Black' => 17,
  '"Black, Non-Hispanic"' => 17,
  'Asian' => 16,
  'Hispanic' => 19,
  'Multiracial' => 22,
  'American Indian or Alaskan Native' => 18,
  'Asian or Pacific Islander' => 15,
  'Pacific Islander' => 37,
  'Female' => 26,
  'Male' => 25,
  'LEP' => 32,
  'NonLEP' => 33
 }

 map_oh_grade = {
  'Third Grade' => 3,
  'Fourth Grade' => 4,
  'Fifth Grade' => 5,
  'Sixth Grade' => 6,
  'Seventh Grade'=> 7,
  'Eighth Grade' => 8,
  'High School' => 'All'
 }

  source("1617_BUILDING_ACHIEVEMENT.txt",[],col_sep: "\t") do |s|
   s.transform("Transpose subject grade columns", 
     Transposer, 
      :subject,:value_float,
      :reading_3,:math_3,
      :reading_4,:math_4,:social_studies_4,
      :reading_5,:math_5,:science_5,
      :reading_6,:math_6,:social_studies_6,
      :reading_7,:math_7,
      :reading_8,:math_8,:science_8,
      :english_i_hs,:english_ii_hs,:math_i_hs,:math_ii_hs,:algebra_i_hs,:geometry_hs,:biology_hs,:physical_science_hs,:government_hs,:history_hs)
    .transform('remove NC value rows', DeleteRows, :value_float, 'NC')
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
      entity_level: 'school',
      breakdown: 'All Students',
      breakdown_gsdata_id: 1
    })
  end


  source("1617_BUILDING_DISABLED.txt",[],col_sep: "\t") do |s|
   s.transform("Transpose subject grade columns", 
    Transposer, 
      :subject,:value_float,
      :reading_3,:math_3,
      :reading_4,:math_4,:social_studies_4,
      :reading_5,:math_5,:science_5,
      :reading_6,:math_6,:social_studies_6,
      :reading_7,:math_7,
      :reading_8,:math_8,:science_8,
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
    .transform('remove NC value rows', DeleteRows, :value_float, 'NC')
    .transform("map >95", HashLookup, :value_float, {'>95.0' => '95'} )
    .transform("Adding subject ids",
     HashLookup, :subject, map_oh_subject_type, to: :academic_gsdata_id)
    .transform('Fill missing default fields', Fill, {
      entity_level: 'school'
    })
    .transform('Rename column headers', MultiFieldRenamer,{
      student_group: :breakdown,
    })
    .transform("Adding breakdown ids",
     HashLookup, :breakdown, map_oh_breakdown_gsdata_id, to: :breakdown_gsdata_id)
  end

  source("1617_BUILDING_ECON_DIS.txt",[],col_sep: "\t") do |s|
   s.transform("Transpose subject grade columns", 
    Transposer, 
      :subject,:value_float,
      :reading_3,:math_3,
      :reading_4,:math_4,:social_studies_4,
      :reading_5,:math_5,:science_5,
      :reading_6,:math_6,:social_studies_6,
      :reading_7,:math_7,
      :reading_8,:math_8,:science_8,
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
    .transform('remove NC value rows', DeleteRows, :value_float, 'NC')
    .transform("map >95", HashLookup, :value_float, {'>95.0' => '95'} )
    .transform("Adding subject ids",
     HashLookup, :subject, map_oh_subject_type, to: :academic_gsdata_id)
    .transform('Fill missing default fields', Fill, {
      entity_level: 'school'
    })
    .transform('Rename column headers', MultiFieldRenamer,{
      student_group: :breakdown,
    })
    .transform("Adding breakdown ids",
     HashLookup, :breakdown, map_oh_breakdown_gsdata_id, to: :breakdown_gsdata_id)
  end


  source("1617_BUILDING_ETHNIC.txt",[],col_sep: "\t") do |s|
   s.transform("Transpose subject grade columns", 
    Transposer, 
      :subject,:value_float,
      :reading_3,:math_3,
      :reading_4,:math_4,:social_studies_4,
      :reading_5,:math_5,:science_5,
      :reading_6,:math_6,:social_studies_6,
      :reading_7,:math_7,
      :reading_8,:math_8,:science_8,
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
    .transform('remove NC and nil value rows', DeleteRows, :value_float, 'NC', nil)
    .transform("map >95", HashLookup, :value_float, {'>95.0' => '95'} )
    .transform("Adding subject ids",
     HashLookup, :subject, map_oh_subject_type, to: :academic_gsdata_id)
    .transform('Fill missing default fields', Fill, {
      entity_level: 'school'
    })
    .transform('Rename column headers', MultiFieldRenamer,{
      student_group: :breakdown,
    })
    .transform("Adding breakdown ids",
     HashLookup, :breakdown, map_oh_breakdown_gsdata_id, to: :breakdown_gsdata_id)
  end

  source("1617_BUILDING_GENDER.txt",[],col_sep: "\t") do |s|
   s.transform("Transpose subject grade columns", 
    Transposer, 
      :subject,:value_float,
      :reading_3,:math_3,
      :reading_4,:math_4,:social_studies_4,
      :reading_5,:math_5,:science_5,
      :reading_6,:math_6,:social_studies_6,
      :reading_7,:math_7,
      :reading_8,:math_8,:science_8,
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
    .transform('remove NC and nil value rows', DeleteRows, :value_float, 'NC', nil)
    .transform("map >95", HashLookup, :value_float, {'>95.0' => '95'} )
    .transform("Adding subject ids",
     HashLookup, :subject, map_oh_subject_type, to: :academic_gsdata_id)
    .transform('Fill missing default fields', Fill, {
      entity_level: 'school'
    })
    .transform('Rename column headers', MultiFieldRenamer,{
      student_group: :breakdown,
    })
    .transform("Adding breakdown ids",
     HashLookup, :breakdown, map_oh_breakdown_gsdata_id, to: :breakdown_gsdata_id)
  end

  source("1617_BUILDING_LEP.txt",[],col_sep: "\t") do |s|
   s.transform("Transpose subject grade columns", 
    Transposer, 
      :subject,:value_float,
      :reading_3,:math_3,
      :reading_4,:math_4,:social_studies_4,
      :reading_5,:math_5,:science_5,
      :reading_6,:math_6,:social_studies_6,
      :reading_7,:math_7,
      :reading_8,:math_8,:science_8,
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
    .transform('remove NC and nil value rows', DeleteRows, :value_float, 'NC', nil)
    .transform("map >95", HashLookup, :value_float, {'>95.0' => '95'} )
    .transform("Adding subject ids",
     HashLookup, :subject, map_oh_subject_type, to: :academic_gsdata_id)
    .transform('Fill missing default fields', Fill, {
      entity_level: 'school'
    })
    .transform('Rename column headers', MultiFieldRenamer,{
      student_group: :breakdown,
    })
    .transform("Adding breakdown ids",
     HashLookup, :breakdown, map_oh_breakdown_gsdata_id, to: :breakdown_gsdata_id)
  end

  source("1617_DISTRICT_ACHIEVEMENT.txt",[],col_sep: "\t") do |s|
   s.transform("Transpose subject grade columns", 
     Transposer, 
      :subject,:value_float,
      :reading_3,:math_3,
      :reading_4,:math_4,:social_studies_4,
      :reading_5,:math_5,:science_5,
      :reading_6,:math_6,:social_studies_6,
      :reading_7,:math_7,
      :reading_8,:math_8,:science_8,
      :english_i_hs,:english_ii_hs,:math_i_hs,:math_ii_hs,:algebra_i_hs,:geometry_hs,:biology_hs,:physical_science_hs,:government_hs,:history_hs)
    .transform('remove NC value rows', DeleteRows, :value_float, 'NC', nil)
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
      entity_level: 'district',
      breakdown: 'All Students',
      breakdown_gsdata_id: 1
    })
  end


  source("1617_DISTRICT_DISABLED.txt",[],col_sep: "\t") do |s|
   s.transform("Transpose subject grade columns", 
    Transposer, 
      :subject,:value_float,
      :reading_3,:math_3,
      :reading_4,:math_4,:social_studies_4,
      :reading_5,:math_5,:science_5,
      :reading_6,:math_6,:social_studies_6,
      :reading_7,:math_7,
      :reading_8,:math_8,:science_8,
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
    .transform('remove NC value rows', DeleteRows, :value_float, 'NC')
    .transform("map >95", HashLookup, :value_float, {'>95.0' => '95'} )
    .transform("Adding subject ids",
     HashLookup, :subject, map_oh_subject_type, to: :academic_gsdata_id)
    .transform('Fill missing default fields', Fill, {
      entity_level: 'district'
    })
    .transform('Rename column headers', MultiFieldRenamer,{
      student_group: :breakdown,
    })
    .transform("Adding breakdown ids",
     HashLookup, :breakdown, map_oh_breakdown_gsdata_id, to: :breakdown_gsdata_id)
  end

  source("1617_DISTRICT_ECON_DIS.txt",[],col_sep: "\t") do |s|
   s.transform("Transpose subject grade columns", 
    Transposer, 
      :subject,:value_float,
      :reading_3,:math_3,
      :reading_4,:math_4,:social_studies_4,
      :reading_5,:math_5,:science_5,
      :reading_6,:math_6,:social_studies_6,
      :reading_7,:math_7,
      :reading_8,:math_8,:science_8,
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
    .transform('remove NC value rows', DeleteRows, :value_float, 'NC')
    .transform("map >95", HashLookup, :value_float, {'>95.0' => '95'} )
    .transform("Adding subject ids",
     HashLookup, :subject, map_oh_subject_type, to: :academic_gsdata_id)
    .transform('Fill missing default fields', Fill, {
      entity_level: 'district'
    })
    .transform('Rename column headers', MultiFieldRenamer,{
      student_group: :breakdown,
    })
    .transform("Adding breakdown ids",
     HashLookup, :breakdown, map_oh_breakdown_gsdata_id, to: :breakdown_gsdata_id)
  end


  source("1617_DISTRICT_ETHNIC.txt",[],col_sep: "\t") do |s|
   s.transform("Transpose subject grade columns", 
    Transposer, 
      :subject,:value_float,
      :reading_3,:math_3,
      :reading_4,:math_4,:social_studies_4,
      :reading_5,:math_5,:science_5,
      :reading_6,:math_6,:social_studies_6,
      :reading_7,:math_7,
      :reading_8,:math_8,:science_8,
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
    .transform('remove NC and nil value rows', DeleteRows, :value_float, 'NC', nil)
    .transform("map >95", HashLookup, :value_float, {'>95.0' => '95'} )
    .transform("Adding subject ids",
     HashLookup, :subject, map_oh_subject_type, to: :academic_gsdata_id)
    .transform('Fill missing default fields', Fill, {
      entity_level: 'district'
    })
    .transform('Rename column headers', MultiFieldRenamer,{
      student_group: :breakdown,
    })
    .transform("Adding breakdown ids",
     HashLookup, :breakdown, map_oh_breakdown_gsdata_id, to: :breakdown_gsdata_id)
  end

  source("1617_DISTRICT_GENDER.txt",[],col_sep: "\t") do |s|
   s.transform("Transpose subject grade columns", 
    Transposer, 
      :subject,:value_float,
      :reading_3,:math_3,
      :reading_4,:math_4,:social_studies_4,
      :reading_5,:math_5,:science_5,
      :reading_6,:math_6,:social_studies_6,
      :reading_7,:math_7,
      :reading_8,:math_8,:science_8,
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
    .transform('remove NC and nil value rows', DeleteRows, :value_float, 'NC', nil)
    .transform("map >95", HashLookup, :value_float, {'>95.0' => '95'} )
    .transform("Adding subject ids",
     HashLookup, :subject, map_oh_subject_type, to: :academic_gsdata_id)
    .transform('Fill missing default fields', Fill, {
      entity_level: 'district'
    })
    .transform('Rename column headers', MultiFieldRenamer,{
      student_group: :breakdown,
    })
    .transform("Adding breakdown ids",
     HashLookup, :breakdown, map_oh_breakdown_gsdata_id, to: :breakdown_gsdata_id)
  end

  source("1617_DISTRICT_LEP.txt",[],col_sep: "\t") do |s|
   s.transform("Transpose subject grade columns", 
    Transposer, 
      :subject,:value_float,
      :reading_3,:math_3,
      :reading_4,:math_4,:social_studies_4,
      :reading_5,:math_5,:science_5,
      :reading_6,:math_6,:social_studies_6,
      :reading_7,:math_7,
      :reading_8,:math_8,:science_8,
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
    .transform('remove NC and nil value rows', DeleteRows, :value_float, 'NC', nil)
    .transform("map >95", HashLookup, :value_float, {'>95.0' => '95'} )
    .transform("Adding subject ids",
     HashLookup, :subject, map_oh_subject_type, to: :academic_gsdata_id)
    .transform('Fill missing default fields', Fill, {
      entity_level: 'district'
    })
    .transform('Rename column headers', MultiFieldRenamer,{
      student_group: :breakdown,
    })
    .transform("Adding breakdown ids",
     HashLookup, :breakdown, map_oh_breakdown_gsdata_id, to: :breakdown_gsdata_id)
  end

  source("1617_STATE_ACHIEVEMENT.txt",[],col_sep: "\t") do |s|
   s.transform('Rename column headers', MultiFieldRenamer,{
      proficient_percentage: :value_float,
      assessment_subject: :subject,
      grade_level: :grade

    })
    .transform('remove NC value rows', DeleteRows, :value_float, 'NC', nil)
    .transform("Remove "%" in value_float", WithBlock) do |row|
      unless row[:value_float].nil?
          row[:value_float] = row[:value_float].gsub(/[\%]/, '')
     end
     row
    end
    .transform("Adding grades",
     HashLookup, :grade, map_oh_grade, to: :grade)
    .transform("Adding subject ids",
     HashLookup, :subject, map_oh_subject_type_state, to: :academic_gsdata_id)
    .transform('Fill missing default fields', Fill, {
      entity_level: 'state',
      breakdown: 'All Students',
      breakdown_gsdata_id: 1
    })
  end

  source("1617_STATE_DISABLED.txt",[],col_sep: "\t") do |s|
   s.transform('Rename column headers', MultiFieldRenamer,{
      proficient_percentage: :value_float,
      disabled_flag: :breakdown,
      assessment_subject: :subject
    })
    .transform('remove NC value rows', DeleteRows, :value_float, 'NC', nil)
    .transform("Remove "%" in value_float", WithBlock) do |row|
      unless row[:value_float].nil?
          row[:value_float] = row[:value_float].gsub(/[\%]/, '')
     end
     row
    end
    .transform("Adding grades",
     HashLookup, :grade_level, map_oh_grade, to: :grade)
    .transform("Adding subject ids",
     HashLookup, :subject, map_oh_subject_type_state, to: :academic_gsdata_id)
    .transform("Map breakdown", WithBlock) do |row|
       if row[:breakdown]=='N'
         row[:breakdown] = 'NonDisabled'
       elsif row[:breakdown]=='Y'
         row[:breakdown] = 'Disabled'
     end
     row
    end
    .transform("Adding breakdown ids",
      HashLookup, :breakdown, map_oh_breakdown_gsdata_id, to: :breakdown_gsdata_id)
    .transform('Fill missing default fields', Fill, {
      entity_level: 'state'
    })
  end

  source("1617_STATE_GENDER.txt",[],col_sep: "\t") do |s|
   s.transform('Rename column headers', MultiFieldRenamer,{
      proficient_percentage: :value_float,
      student_gender: :breakdown,
      assessment_subject: :subject
    })
    .transform('remove NC value rows', DeleteRows, :value_float, 'NC', nil)
    .transform("Remove "%" in value_float", WithBlock) do |row|
      unless row[:value_float].nil?
          row[:value_float] = row[:value_float].gsub(/[\%]/, '')
     end
     row
    end
    .transform("Adding grades",
     HashLookup, :grade_level, map_oh_grade, to: :grade)
    .transform("Adding subject ids",
     HashLookup, :subject, map_oh_subject_type_state, to: :academic_gsdata_id)
    .transform("Adding breakdown ids",
      HashLookup, :breakdown, map_oh_breakdown_gsdata_id, to: :breakdown_gsdata_id)
    .transform('Fill missing default fields', Fill, {
      entity_level: 'state'
    })
  end

  source("1617_STATE_LEP.txt",[],col_sep: "\t") do |s|
   s.transform('Rename column headers', MultiFieldRenamer,{
      proficient_percentage: :value_float,
      limited_english_proficiency_flag: :breakdown,
      assessment_subject: :subject
    })
    .transform('remove NC value rows', DeleteRows, :value_float, 'NC', nil)
    .transform("Remove "%" in value_float", WithBlock) do |row|
      unless row[:value_float].nil?
          row[:value_float] = row[:value_float].gsub(/[\%]/, '')
     end
     row
    end
    .transform("Adding grades",
     HashLookup, :grade_level, map_oh_grade, to: :grade)
    .transform("Adding subject ids",
     HashLookup, :subject, map_oh_subject_type_state, to: :academic_gsdata_id)
    .transform("Map breakdown", WithBlock) do |row|
       if row[:breakdown]=='No'
         row[:breakdown] = 'NonLEP'
       elsif row[:breakdown]=='Yes'
         row[:breakdown] = 'LEP'
      end
     row
    end
    .transform("Adding breakdown ids",
      HashLookup, :breakdown, map_oh_breakdown_gsdata_id, to: :breakdown_gsdata_id)
    .transform('Fill missing default fields', Fill, {
      entity_level: 'state'
    })
  end
  

  source("1617_STATE_ECON_DIS.txt",[],col_sep: "\t") do |s|
   s.transform('Rename column headers', MultiFieldRenamer,{
      proficient_percentage: :value_float,
      economy_disadvantaged_flag: :breakdown,
      assessment_subject: :subject
    })
    .transform('remove NC value rows', DeleteRows, :value_float, 'NC', nil)
    .transform("Remove "%" in value_float", WithBlock) do |row|
      unless row[:value_float].nil?
          row[:value_float] = row[:value_float].gsub(/[\%]/, '')
     end
     row
    end
    .transform("Adding grades",
     HashLookup, :grade_level, map_oh_grade, to: :grade)
    .transform("Adding subject ids",
     HashLookup, :subject, map_oh_subject_type_state, to: :academic_gsdata_id)
    .transform("Map breakdown", WithBlock) do |row|
       if row[:breakdown]=='N'
         row[:breakdown] = 'NonDisadvantaged'
       elsif row[:breakdown]=='Y'
         row[:breakdown] = 'Disadvantaged'
      end
     row
    end
    .transform("Adding breakdown ids",
      HashLookup, :breakdown, map_oh_breakdown_gsdata_id, to: :breakdown_gsdata_id)
    .transform('Fill missing default fields', Fill, {
      entity_level: 'state'
    })
  end

  source("1617_STATE_ETHNIC.txt",[],col_sep: "\t") do |s|
   s.transform('Rename column headers', MultiFieldRenamer,{
      proficient_percentage: :value_float,
      student_race: :breakdown,
      assessment_subject: :subject
    })
    .transform('remove NC value rows', DeleteRows, :value_float, 'NC', nil, '&lt; 10')
    .transform("Remove "%" in value_float", WithBlock) do |row|
      unless row[:value_float].nil?
          row[:value_float] = row[:value_float].gsub(/[\%]/, '')
     end
     row
    end
    .transform("Adding grades",
     HashLookup, :grade_level, map_oh_grade, to: :grade)
    .transform("Adding subject ids",
     HashLookup, :subject, map_oh_subject_type_state, to: :academic_gsdata_id)
    .transform("Adding breakdown ids",
      HashLookup, :breakdown, map_oh_breakdown_gsdata_id, to: :breakdown_gsdata_id)
    .transform('Fill missing default fields', Fill, {
      entity_level: 'state'
    })
  end

  shared do |s|
     s.transform('Fill missing default fields', Fill, {
      year: 2017,
      entity_type: 'public_charter',
      level_code: 'e,m,h',
      proficiency_band_gsdata_id: 1,
      proficiency_band: 'proficient and above',
      test_data_type: 'OST',
      gsdata_test_data_type_id: 256,
      notes: 'DXT-2876: OH OST 2017 test load.',
      description: 'In 2016-2017, students took state tests in math, English language arts, science and social studies to measure how well they are meeting the expectations of their grade levels. The tests match the content and skills that are taught in the classroom every day and measure real-world skills like critical thinking, problem solving and writing.'
    })
    .transform("Creating StateID, district and school id and dist and sch names", WithBlock) do |row|
     if row[:entity_level] == 'state'
       row[:state_id] = 'state'
     elsif row[:entity_level] == 'district'
        row[:state_id] = row[:district_irn]
        row[:district_id] = row[:district_irn]
     elsif row[:entity_level] == 'school'
        row[:state_id] = row[:building_irn]
        row[:school_id] = row[:building_irn]
        row[:school_name] = row[:building_name]
        row[:district_id] = row[:district_irn]
     end
     row
   end
  end

  def config_hash
    {
        gsdata_source_id: 40,
        source_name: 'Ohio Department of Education',
        date_valid: '2017-01-01 00:00:00',
        state: 'oh',
        url: 'https://reportcard.education.ohio.gov/download',
        file: 'oh/2017/output/oh.2017.1.public.charter.[level].txt',
        level: nil,
        school_type: 'public,charter'
    }
  end
end

OHTestProcessor2017OST.new(ARGV[0], max: nil).run