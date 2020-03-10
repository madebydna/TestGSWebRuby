require_relative "../test_processor"

class NMTestProcessor2016SBAPARCC < GS::ETL::TestProcessor

  def initialize(*args)
    super
    @year = 2016
  end


   map_nm_breakdown = {
     'All Students' => 1,
     'African American' => 3,
     'American Indian' => 4,
     'Asian' => 2,
     'Caucasian' => 8,
     'Economically Disadvantaged' => 9,
     'English Language Learners' => 15,
     'Female' => 11,
     'Hispanic' => 6,
     'Male' => 12,
     'Students w Disabilities' => 13
   }

   map_nm_subject = {
     :reading => 2,
     :math => 5,
     :science => 25
   }

   map_nm_test = {
     :reading => 'NM PARCC',
     :math => 'NM PARCC',
     :science => 'NMSBA'
   }

   map_nm_test_id = {
     'NM PARCC' => 304,
     'NMSBA' => 96
   }

 source("nm_SBA_PARCC_2016.txt",[], col_sep: "\t") do |s|
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
     proficiency_band: 'null',
     proficiency_band_id: 'null',
     level_code: 'e,m,h',
     grade: 'All',
     year: 2016
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
    HashLookup, :subject, map_nm_subject, to: :subject_id)
   .transform("Filling in test names",
    HashLookup, :subject, map_nm_test, to: :test_data_type)
   .transform("Filling in test ids",
    HashLookup, :test_data_type, map_nm_test_id, to: :test_data_type_id)
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
   .transform("Adding column breakdown_id from group",
    HashLookup, :group, map_nm_breakdown, to: :breakdown_id)
   .transform("Remove Migrant", WithBlock) do |row|
     if row[:group] != 'Migrant'
       row[:breakdown] = row[:group]
       row
     end
   end
   .transform("Removing grades KN,1,2", DeleteRows,:grade,'KN','1','2','12')
   .transform('Fill missing default fields', Fill, {
     entity_type: 'public_charter',
     proficiency_band: 'null',
     proficiency_band_id: 'null',
     level_code: 'e,m,h',
     year: 2016
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
    HashLookup, :test_data_type, map_nm_test_id, to: :test_data_type_id)
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



  def config_hash
    {
        source_id: 45,
        state: 'nm',
        notes: 'DXT-2123: NM SBA PARCC 2016 test load.',
        url: 'http://ped.state.nm.us/AssessmentAccountability/AcademicGrowth/NMSBA.html',
        file: 'nm/2016/output/nm.2016.1.public.charter.[level].txt',
        level: nil,
        school_type: 'public,charter'
    }
  end
end

NMTestProcessor2016SBAPARCC.new(ARGV[0], max: nil).run
