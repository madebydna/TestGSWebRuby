require_relative "../test_processor"
GS::ETL::Logging.disable

class NMTestProcessor2017SBAPARCC < GS::ETL::TestProcessor

  def initialize(*args)
    super
    @year = 2017
  end


   map_nm_breakdown = {
     'All Students' => 1,
     'African American' => 17,
     'American Indian' => 18,
     'Asian' => 16,
     'Caucasian' => 21,
     'Economically Disadvantaged' => 23,
     'English Language Learners' => 32,
     'Female' => 26,
     'Hispanic' => 19,
     'Male' => 25,
     'Students w Disabilities' => 27
   }

   map_nm_subject = {
     :reading => 2,
     :math => 5,
     :science => 19
   }

   map_nm_test = {
     :reading => 'NM PARCC',
     :math => 'NM PARCC',
     :science => 'NMSBA'
   }

   map_nm_test_id = {
     'NM PARCC' => 245,
     'NMSBA' => 244
   }

 source("ACC_Webfiles_2017_Proficiencies_ALL_ByStateByDistrictBySchool.txt",[], col_sep: "\t") do |s|
   s.transform("Set entity", WithBlock) do |row|
     if row[:state_or_district] == 'Statewide'
       row[:entity_level] = 'state'
     elsif row[:school] == 'Districtwide'
       row[:entity_level] = 'district'
     else row[:entity_level] = 'school'
     end
     row
    # require 'byebug'
    # byebug
   end
   .transform("Creating StateID", WithBlock) do |row|
     if row[:entity_level] == 'state'
       row[:state_id] = 'state'
     else row[:state_id] = row[:code]
     end
     row
   end
   .transform("Adding column breakdown_id from group",
    HashLookup, :group, map_nm_breakdown, to: :breakdown_id)
   .transform("Remove Migrant", WithBlock) do |row|
     if row[:group] != 'Migrant'
       row[:breakdown] = row[:group]
       row
     end
   end
   .transform('Fill missing default fields', Fill, {
     entity_type: 'public_charter',
     proficiency_band: 1,
     proficiency_band_gsdata_id: 'null',
     level_code: 'e,m,h',
     grade: 'All',
     year: 2017
   })
   .transform("Adding school and district names", WithBlock) do |row|
     if row[:entity_level] == 'school'
       row[:school_id] = row[:code]
       row[:school_name] = row[:school]
       row[:district_name] = row[:state_or_district]
     elsif row[:entity_level] == 'district'
       row[:district_name] = row[:state_or_district]
     end
       row
   end
   .transform("Adding district ids", WithBlock) do |row|
     if row[:entity_level] == 'district'
       row[:district_id] = row[:code]
     end
     row
   end
   .transform("Renaming subject value columns", MultiFieldRenamer,
     {
       reading_proficientabove: :reading,
       math_proficientabove: :math,
       science_proficientabove: :science
     })
   .transform("Transpose", Transposer, :subject,:value_float,:reading,:math,:science)
   .transform("Filling in number_tested", WithBlock) do |row|
     if row[:subject] == :reading
       row[:number_tested] = row[:reading_count]
     elsif row[:subject] == :math
       row[:number_tested] = row[:math_count]
     elsif row[:subject] == :science
       row[:number_tested] = row[:science_count]
     end
     row
   end
   .transform("Filling in subject ids",
    HashLookup, :subject, map_nm_subject, to: :academic_id)
   .transform("Filling in test names",
    HashLookup, :subject, map_nm_test, to: :test_data_type)
   .transform("Filling in test ids",
    HashLookup, :test_data_type, map_nm_test_id, to: :gsdata_test_data_type_id)
   .transform("Padding School and District level ID's to 6 digits", WithBlock) do |row|
       if row[:entity_level] == 'school'
          row[:state_id] = '%06i' % (row[:state_id].to_i)
          row[:school_id] = '%06i' % (row[:school_id].to_i)
          row[:district_id] = '%06i' % (row[:state_id].to_i)
       elsif row[:entity_level] == 'district'
          row[:state_id] = '%06i' % (row[:state_id].to_i)
          row[:district_id] = '%06i' % (row[:district_id].to_i)
       elsif row[:entity_levl] =='state'
          row[:state_id] = 'state'
       end
       row
   end
   # .transform('remove %',WithBlock,) do |row|
   #   unless row[:number_tested].nil?
   #          row[:number_tested] = row[:number_tested].tr('"','')
   #   end
   #   if row[:number_tested].nil?
   #      row[:number_tested] = 'skip'
   #   end
   #   row
   # end
   .transform('remove blank value rows', DeleteRows, :number_tested, 'skip')
   .transform("Fixing district ids to first 3 numbers", WithBlock) do |row|
     if row[:entity_level] == 'school'
       row[:district_id] = row[:district_id].slice!(0,3)
     elsif row[:entity_level] == 'district'
       row[:state_id] = row[:state_id].slice!(0,3)
       row[:district_id]=row[:district_id].slice!(0,3)
     end
     row
   end
 end


 source('nm_SBA_PARCC_2016_by_grade.txt',[], col_sep: "\t") do |s|
   s.transform("Set entity", WithBlock) do |row|
     if row[:state_or_district] == 'Statewide'
       row[:entity_level] = 'state'
     elsif row[:school] == 'Districtwide'
       row[:entity_level] = 'district'
     else row[:entity_level] = 'school'
     end
     row
    # require 'byebug'
    # byebug
   end
   .transform("Creating StateID", WithBlock) do |row|
     if row[:entity_level] == 'state'
       row[:state_id] = 'state'
     else row[:state_id] = row[:code]
     end
     row
   end
   .transform("Removing grades KN,1,2", DeleteRows,:grade,'KN','1','2','12')
   .transform("Adding school and district names", WithBlock) do |row|
     if row[:entity_level] == 'school'
       row[:school_id] = row[:code]
       row[:school_name] = row[:school]
       row[:district_name] = row[:state_or_district]
     elsif row[:entity_level] == 'district'
       row[:district_name] = row[:state_or_district]
     end
       row
   end
   .transform("Adding district ids", WithBlock) do |row|
     if row[:entity_level] == 'district'
       row[:district_id] = row[:code]
     end
     row
   end
   .transform("Renaming subject value columns", MultiFieldRenamer,
     {
       reading_proficientabove: :reading,
       math_proficientabove: :math,
       science_proficientabove: :science,
       grade: :grade
     })
   .transform("Transpose", Transposer, :subject,:value_float,:reading,:math,:science)
   .transform("Filling in number_tested", WithBlock) do |row|
     if row[:subject] == :reading
       row[:number_tested] = row[:reading_count]
     elsif row[:subject] == :math
       row[:number_tested] = row[:math_count]
     elsif row[:subject] == :science
       row[:number_tested] = row[:science_count]
     end
     row
   end
   .transform("Filling in subject ids",
    HashLookup, :subject, map_nm_subject, to: :subject_id)
   .transform("Filling in test names",
    HashLookup, :subject, map_nm_test, to: :test_data_type)
   .transform("Filling in test ids",
    HashLookup, :test_data_type, map_nm_test_id, to: :gsdata_test_data_type_id)
   .transform("Padding School and District level ID's to 6 digits", WithBlock) do |row|
       if row[:entity_level] == 'school'
          row[:state_id] = '%06i' % (row[:state_id].to_i)
          row[:school_id] = '%06i' % (row[:school_id].to_i)
          row[:district_id] = '%06i' % (row[:state_id].to_i)
       elsif row[:entity_level] == 'district'
          row[:state_id] = '%06i' % (row[:state_id].to_i)
          row[:district_id] = '%06i' % (row[:district_id].to_i)
       end
       row
   end
   .transform('remove %',WithBlock,) do |row|
     unless row[:number_tested].nil?
            row[:number_tested] = row[:number_tested].tr('"','')
     end
     if row[:number_tested].nil?
        row[:number_tested] = 'skip'
     end
     row
   end
   .transform('remove blank value rows', DeleteRows, :number_tested, 'skip')
   .transform("Fixing district ids to first 3 numbers", WithBlock) do |row|
     if row[:entity_level] == 'school'
       row[:district_id] = row[:district_id].slice!(0,3)
     elsif row[:entity_level] == 'district'
       row[:state_id] = row[:state_id].slice!(0,3)
       row[:district_id]=row[:district_id].slice!(0,3)
     end
     row
   end
 end

  shared do |s|
    s.transform('Fill missing default fields', Fill, {
      year: 2017,
      entity_type: 'public_charter',
      level_code: 'e,m,h',
      proficiency_band_gsdata_id: 1,
      proficiency_band: 'proficient and above',
      notes: 'DXT-2878: NM PARCC SBA test',
    })
    .transform("Set entity", WithBlock) do |row|
     if row[:state_or_district] == 'Statewide'
       row[:entity_level] = 'state'
     elsif row[:school] == 'Districtwide'
       row[:entity_level] = 'district'
     else row[:entity_level] = 'school'
     end
     row
   end
    .transform('Rename column headers', MultiFieldRenamer,{
    group: :breakdown,
    })
    .transform("Adding column breakdown_id from group",
      HashLookup, :group, map_nm_breakdown, to: :breakdown_gsdata_id)
    .transform("Skip missing values", DeleteRows, :tested_percentage, '*')
    .transform("Skip migrant", DeleteRows, :breakdown, 'Migrant')
    .transform("Renaming subject value columns", MultiFieldRenamer,
     {
       reading_proficientabove: :reading,
       math_proficientabove: :math,
       science_proficientabove: :science,
       grade: :grade
     })
    .transform("Transpose", Transposer, :subject,:value_float,:reading,:math,:science)
    .transform("Filling in number_tested", WithBlock) do |row|
     if row[:subject] == :reading
       row[:number_tested] = row[:reading_count]
     elsif row[:subject] == :math
       row[:number_tested] = row[:math_count]
     elsif row[:subject] == :science
       row[:number_tested] = row[:science_count]
     end
     row
    end
    .transform('remove %',WithBlock,) do |row|
     unless row[:number_tested].nil?
            row[:number_tested] = row[:number_tested].tr('"','')
     end
     if row[:number_tested].nil?
        row[:number_tested] = 'skip'
     end
     row
   end
   
   .transform("Filling in subject ids",
    HashLookup, :subject, map_nm_subject, to: :subject_id)
   .transform("Filling in test names",
    HashLookup, :subject, map_nm_test, to: :test_data_type)
   .transform("Filling in test ids",
    HashLookup, :test_data_type, map_nm_test_id, to: :gsdata_test_data_type_id)
    .transform("fix special cases for prof and above", WithBlock) do |row|
          if row[:value_float].nil?
            row[:value_float]=row[:value_float]
          elsif row[:value_float] < 0
            row[:value_float] = 0
          elsif row[:value_float] > 100
            row[:value_float] = 100
          elsif row[:value_float].between?(0,1)
            row[:value_float]=row[:value_float].round(2)
          end
     row
    end
    .transform("Skip missing prof and above values", DeleteRows, :value_float, nil)
    .transform("Padding School and District level ID's to 6 digits", WithBlock) do |row|
       if row[:entity_level] == 'school'
          row[:state_id] = '%06i' % (row[:state_id].to_i)
          row[:school_id] = '%06i' % (row[:school_id].to_i)
          row[:district_id] = '%06i' % (row[:state_id].to_i)
       elsif row[:entity_level] == 'district'
          row[:state_id] = '%06i' % (row[:state_id].to_i)
          row[:district_id] = '%06i' % (row[:district_id].to_i)
       end
       row
   end
end



  def config_hash
    {
        source_id: 35,
        state: 'nm',
        source_name: 'New Mexico Public Education Department',
        notes: 'DXT-2878: NM SBA PARCC 2017 test load.',
        url: 'http://ped.state.nm.us/AssessmentAccountability/AcademicGrowth/NMSBA.html',
        file: 'nm/2016/output/nm.2017.1.public.charter.[level].txt',
        level: nil,
        school_type: 'public,charter'
    }
  end
end

NMTestProcessor2017SBAPARCC.new(ARGV[0], max: nil).run
