require_relative "../test_processor"

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
     '"English Language Learners, Current"' => 32,
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

 source("ACC_Webfiles_2017_Proficiencies_All_ByStateByDistrictBySchool.txt",[], col_sep: "\t") do |s|
   s.transform("Fill grade all", Fill,{
    grade: 'All'
   })
 end

  source('ACC_Webfiles_2017_Proficiencies_All_ByStateByDistrictBySchoolByGrade.txt',[], col_sep: "\t") do |s|
   s.transform("Removing grades KN,1,2", DeleteRows,:grade,'K','1','2')
 end

  shared do |s|
    s.transform('Fill missing default fields', Fill, {
      year: 2017,
      entity_type: 'public_charter',
      level_code: 'e,m,h',
      proficiency_band_gsdata_id: 1,
      proficiency_band: 'proficient and above',
    })
    .transform('Rename column headers', MultiFieldRenamer,{
      group: :breakdown,
    })
    .transform("Skip migrant", DeleteRows, :breakdown, 'Migrant')
    .transform("Adding column breakdown_id from group",
      HashLookup, :breakdown, map_nm_breakdown, to: :breakdown_gsdata_id)
    .transform("Renaming subject value columns", MultiFieldRenamer,
     {
       reading_proficientabove: :reading,
       math_proficientabove: :math,
       science_proficientabove: :science,
     })
    .transform("Transpose", Transposer, :subject,:value_float,:reading,:math,:science)
    .transform("Filling in subject ids",
    HashLookup, :subject, map_nm_subject, to: :academic_gsdata_id)
    .transform("Filling in test names",
    HashLookup, :subject, map_nm_test, to: :test_data_type)
    .transform("Filling in test ids",
    HashLookup, :test_data_type, map_nm_test_id, to: :gsdata_test_data_type_id)
    .transform("Filling in description", WithBlock) do |row|
     if row[:gsdata_test_data_type_id] == 245
       row[:description] = 'In 2016-2017, New Mexico used the PARCC assessment to test students in grades 3-12 in Math and grades 3-11 in Reading.'
       row[:notes] = 'DXT-2878: NM NM PARCC'
     elsif row[:gsdata_test_data_type_id] == 244
       row[:description] = 'In 2016-2017, New Mexico used the New Mexico Standards-Based Assessment (NMSBA) to test students in grades 4, 7 and 11 in Science.'
       row[:notes] = 'DXT-2878: NM NMSBA'
     end
     row
    end
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
    .transform("Remove , in number_tested", WithBlock) do |row|
      unless row[:number_tested].nil?
          row[:number_tested] = row[:number_tested].gsub(/[\,]/, '')
     end
     row
    end
    .transform("Remove "" in number_tested", WithBlock) do |row|
      unless row[:number_tested].nil?
          row[:number_tested] = row[:number_tested].gsub(/[\"]/, '')
     end
     row
    end
   .transform("Delete rows where number tested is less than 10 and blank ",DeleteRows, :number_tested, '0','1','2','3','4','5','6','7','8','9')
   .transform("fix special cases for prof and above", WithBlock) do |row|
          if row[:value_float].nil?
            row[:value_float]=row[:value_float]
          elsif row[:value_float] == "<= 1"
            row[:value_float] = '1'
          elsif row[:value_float] == " >=95"
            row[:value_float] = '95'
          elsif row[:value_float] == ">=95"
            row[:value_float] = '95'
      end
     row
    end
    .transform("Skip missing prof and above values", DeleteRows, :value_float, nil)
    .transform("Skip range values", DeleteRows, :value_float, '>= 80', '<= 10', '<= 20', '>= 90', '<= 5', '<= 2', ' >= 90', ' >= 80')
    .transform("Set entity", WithBlock) do |row|
     if row[:state_or_district] == 'Statewide'
       row[:entity_level] = 'state'
     elsif row[:school] == 'Districtwide'
       row[:entity_level] = 'district'
     else row[:entity_level] = 'school'
     end
     row
   end
   .transform("Creating StateID, district and school id and dist and sch names", WithBlock) do |row|
     if row[:entity_level] == 'state'
       row[:state_id] = 'state'
     elsif row[:entity_level] == 'district'
        row[:state_id] = '%03i' % (row[:code].to_i)
        row[:district_id] = row[:code]
        row[:district_name] = row[:state_or_district]
     elsif row[:entity_level] == 'school'
        row[:state_id] = '%06i' % (row[:code].to_i)
        row[:school_id] = row[:code]
        row[:school_name] = row[:school]
        row[:district_id] = row[:state_id].slice(0,3)
        row[:district_name] = row[:state_or_district]
     end
     row
   end
end



  def config_hash
    {
        gsdata_source_id: 35,
        state: 'nm',
        source_name: 'New Mexico Public Education Department',
        date_valid: '2017-01-01 00:00:00',
        notes: 'DXT-2878: NM SBA PARCC 2017 test load.',
        url: 'http://ped.state.nm.us/AssessmentAccountability/AcademicGrowth/NMSBA.html',
        file: 'nm/2016/output/nm.2017.1.public.charter.[level].txt',
        level: nil,
        school_type: 'public,charter'
    }
  end
end

NMTestProcessor2017SBAPARCC.new(ARGV[0], max: nil).run
