require_relative "../test_processor"

class WATestProcessor2017_SBAC_EOC_MSP < GS::ETL::TestProcessor

  def initialize(*args)
    super
    @year = 2017
  end

  map_breakdown_id = {
    'All' => 1,
    'Male' => 12,     
    'Female' => 11,
    'American Indian / Alaskan Native' => 4,
    'Black / African American' => 3,
    'Hispanic / Latino of any race(s)' => 6,
    'White' => 8,  
    'Special Education' => 13,
    'Limited English' => 15,
    'Low Income' => 9,
    'Non Special Education' => 14,
    'Non Low Income' => 10,
    'Asian' => 2,
    'Two or More Races' => 21,
    'Native Hawaiian / Other Pacific Islander' => 112 
   }

  map_gsdata_breakdown = {
    'All' => 1,
    'Male' => 25,     
    'Female' => 26,
    'American Indian / Alaskan Native' => 18,
    'Black / African American' => 17,
    'Hispanic / Latino of any race(s)' => 19,
    'White' => 21,  
    'Special Education' => 27,
    'Limited English' => 32,
    'Low Income' => 23,
    'Non Special Education' => 30,
    'Non Low Income' => 24,
    'Asian' => 16,
    'Two or More Races' => 22,
    'Native Hawaiian / Other Pacific Islander' => 20
  }
  map_prof_band_id = {
    :"level4" => 187,
    :"level3" => 186,
    :"levelbasic" => 185,
    :"level2" => 184,
    :"level1" => 183,
    :"prof_null" => 'null'
  }
  map_gsdata_prof_band_id = {
    :"level4" => 31,
    :"level3" => 30,
    :"levelbasic" => 29,
    :"level2" => 28,
    :"level1" => 27,
    :"prof_null" => 1
  }
  map_subject_id = {
   'MATH' => 5,
   'ELA' => 4,
   'Biology' => 29,
   'Science' => 25
   }
  map_gsdata_academic = {
   'MATH' => 5,
   'ELA' => 4,
   'Biology' => 22,
   'Science' => 19
  }
  map_test_data_type = {
   'EOC' => 156,
   'MSP' => 149,
   'SBA' => 317
  }
  map_gsdata_test_data_type = {
   'EOC' => 310,
   'MSP' => 308,
   'SBA' => 311
  }

  source("school.txt",[],col_sep:"\t") do |s|
    s.transform("fill entity level",Fill,{   
	   entity_level: 'school'
    })
  end 
  source("district.txt",[],col_sep:"\t") do |s|
    s.transform("fill entity level",Fill,{   
	   entity_level: 'district'
    })
  end  
  source("state.txt",[],col_sep:"\t") do |s|
    s.transform("fill entity level",Fill,{   
	     entity_level: 'state'
    })
  end

   shared do |s|
     s.transform("Rename columns", MultiFieldRenamer,
      {
        district: :district_name,
        school: :school_name,
        districtcode: :district_id,
        schoolcode: :school_id,
        testadministration: :test_data_type,
        gradelevel: :grade,
        studentgroup: :breakdown,
        percentmeetingstandardexcludingnoscore: :prof_null
      })
      .transform('Fill missing default fields', Fill, {
        entity_type: 'public_charter',
        level_code: 'e,m,h',
        year: 2017
      })
      .transform("delete aim test",DeleteRows, :test_data_type, 'AIM')
      .transform("delete breadkowns",DeleteRows, :breakdown, 'Migrant','Section 504','Continuously Enrolled','Title I Targeted Reading','Title I Targeted Math')
      .transform("delete suppressed data",DeleteRows, :suppressed, 'y')
      .transform("state_id", WithBlock) do |row|
        row[:number_tested] = row[:countlevel4].to_i + row[:countlevel3].to_i + row[:countlevelbasic].to_i + row[:countlevel2].to_i + row[:countlevel1].to_i
        row[:level1] = (row[:countlevel1].to_i/row[:number_tested].to_f * 100).to_s
        row[:level2] = (row[:countlevel2].to_i/row[:number_tested].to_f * 100).to_s
        row[:levelbasic] = (row[:countlevelbasic].to_i/row[:number_tested].to_f * 100).to_s
        row[:level3] = (row[:countlevel3].to_i/row[:number_tested].to_f * 100).to_s
        row[:level4] = (row[:countlevel4].to_i/row[:number_tested].to_f * 100).to_s
        row[:number_tested] = row[:number_tested].to_s
        row
      end
      .transform("transpose prof bands", Transposer, 
        :proficiency_band, 
        :value_float, 
        :level4, 
        :level3, 
        :levelbasic, 
        :level2, 
        :level1, 
        :"prof_null"
      )
     .transform("delete rows where number_tested < 10 ",DeleteRows, :number_tested, '0','1','2','3','4','5','6','7','8','9')
     .transform("map subject ids", HashLookup, :subject, map_subject_id, to: :subject_id)
     .transform("map test data type",HashLookup, :test_data_type, map_test_data_type, to: :test_data_type_id)
     .transform("map breakdown id",HashLookup, :breakdown, map_breakdown_id, to: :breakdown_id)
     .transform("map prof band id",HashLookup, :proficiency_band, map_prof_band_id, to: :proficiency_band_id)
     .transform('map breakdowns', HashLookup, :breakdown, map_gsdata_breakdown, to: :breakdown_gsdata_id)
     .transform('map subjects', HashLookup, :subject, map_gsdata_academic, to: :academic_gsdata_id) 
     .transform("map prof band id",HashLookup, :proficiency_band, map_gsdata_prof_band_id, to: :proficiency_band_gsdata_id)
     .transform("map test data type",HashLookup, :test_data_type, map_gsdata_test_data_type, to: :gsdata_test_data_type_id)
     .transform("source", WithBlock) do |row|
        if row[:gsdata_test_data_type_id] == 310
          row[:grade] = 'All'
          row[:notes] = 'DXT-2559: WA EOC 2017'
          row[:description] = 'In 2016-2017, the EOC currently tests Biology and are standards-based, which means they measure how well students are mastering specific skills defined for each grade by the state of Washington. The goal is for all students to score at or above the state standard.'
        elsif row[:gsdata_test_data_type_id] == 308
          row[:grade] = row[:grade].gsub(/[^\d]/, '')
          row[:notes] = 'DXT-2559: WA MSP 2017'
          row[:description] = 'In 2016-2017, Washington used the Measurements of Student Progress (MSP) to test students science in grades 5 and 8. The MSP is a standards-based test, which means it measures how well students are mastering specific skills defined for each grade by the state of Washington. The goal is for all students to score at or above the state standard.'
        else
          row[:grade] = row[:grade].gsub(/[^\d]/, '')
          row[:notes] = 'DXT-2559: WA SBAC 2017'
          row[:description] = 'In 2016-2017, WA tested students in English and Math with the Smarter Balanced Assessment. Smarter Balanced tests align to the new K-12 learning standards in English language arts and math (Common Core), which are more difficult than previous standards.'
        end
        row
    end
    .transform("state_id", WithBlock) do |row|
	     if row[:entity_level] == 'school'
		     row[:state_id] = row[:school_id]
         row[:district_id] = nil
	     elsif row[:entity_level] == 'district'
		     row[:state_id] = row[:district_id]
         row[:school_id] = nil
	     else
		     row[:state_id] = 'state'
	     end
	     row
   end
end
   def config_hash
   {
       source_id: 8,
       state: 'wa',
       source_name: 'Washington Office of Superintendent of Public Instruction',
       date_valid: '2017-01-01 00:00:00',
       url: 'http://reportcard.ospi.k12.wa.us/DataDownload.aspx',
       file: 'wa/2017/wa.2017.1.public.charter.[level].txt',
       level: nil,
       school_type: 'public,charter'
   } 
   end
end

WATestProcessor2017_SBAC_EOC_MSP.new(ARGV[0],max:nil).run
