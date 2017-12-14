require_relative "../test_processor"
GS::ETL::Logging.disable

class WATestProcessor2013EOC_MSP_HSPE < GS::ETL::TestProcessor

   def initialize(*args)
      super
      @year = 2013
   end

  source("2013_WA_EOC_MSP_HSPE_School.txt",[],col_sep:"\t") do |s|
      s.transform("fill entity level",Fill,{   
	 entity_level: 'school'
      })
  end 
  source("2013_WA_EOC_MSP_HSPE_District.txt",[],col_sep:"\t") do |s|
      s.transform("fill entity level",Fill,{   
	 entity_level: 'district'
      })
  end  
  source("2013_WA_EOC_MSP_HSPE_State.txt",[],col_sep:"\t") do |s|
      s.transform("fill entity level",Fill,{   
	 entity_level: 'state'
      })
  end
   map_breakdown_id = {
	   'All' => 1,
	   'Male' => 12,	   
	   'Female' => 11,
	   'American Indian / Alaskan Native' => 4,
	   'Hispanic / Latino of any race(s)' => 6,
	   'White' => 8,
	   'Special Education' => 13,
	   'Limited English' => 15,
	   'Low Income' => 9,
	   'Non Special Education' => 14,
	   'Non Low Income' => 10,
	   'Two or More Races' => 21,
	   'Migrant' => 19,
	   'Asian / Pacific Islander' => 22, 
	   'Black / African American' => 3,
	   'Asian' => 2,
	   'Native Hawaiian / Other Pacific Islander' => 112 
   }

   map_prof_band_id = {
      plevel4: 187,
      plevel3: 186,
      plevelbasic: 185,
      plevel2: 184,
      plevel1: 183,
      null: 'null'
   }

   map_subject_id = {
   	'Reading' => 2,
	'Math' => 5,
	'Algebra' => 7,
	'Biology' => 29,
	'Geometry' => 9,
	'Integrated Math 1' => 8,
	'Integrated Math 2' => 10,
	'Science' => 25,
	'Writing' => 3
   }
   map_test_data_type = {
   	'EOC' => 156,
	'MSP' => 149,
	'HSPE' => 150
   }

   shared do |s|
     s.transform("Rename columns", MultiFieldRenamer,
      {
      districtcode: :district_id,
      district: :district_name,
      schoolcode: :school_id,
      school: :school_name,
      studentgroup: :breakdown,
      testadministration: :test_data_type,
      gradelevel: :grade,
      #percentmeetingstandardexcludingnoscore: :prof_null
      })
     .transform("delete rows where subgroup is continuousy enrolled, section 504, or foster care",DeleteRows, :breakdown, 'Continuously Enrolled','Section 504','Foster Care')
     .transform("delete rows where subgroup is Title 1",DeleteRows, :breakdown, /^Title/)
     .transform("delete rows where data is suppressed",DeleteRows, :suppressed, 'y')
     .transform("extract grade", WithBlock,) do |row|
	     row[:grade] = (row[:grade])[0...-2]
	     row
     end
     .transform("calculate number_tested", WithBlock,) do |row|
	     row[:number_tested] = row[:countlevel4].to_i + row[:countlevel3].to_i + row[:countlevelbasic].to_i + row[:countlevel2].to_i + row[:countlevel1].to_i
	     row
     end
     .transform("delete rows where number_tested < 10 ",DeleteRows, :number_tested, 0,1,2,3,4,5,6,7,8,9)
     .transform("calculate prof bands", WithBlock,) do |row|
	     row[:plevel4] = ((row[:countlevel4].to_f /  row[:number_tested].to_f) * 100).round(2) 
	     row[:plevel3] = ((row[:countlevel3].to_f /  row[:number_tested].to_f) * 100).round(2)
	     row[:plevelbasic] = ((row[:countlevelbasic].to_f /  row[:number_tested].to_f) * 100).round(2) 
	     row[:plevel2] = ((row[:countlevel2].to_f /  row[:number_tested].to_f) * 100).round(2) 
	     row[:plevel1] = ((row[:countlevel1].to_f /  row[:number_tested].to_f) * 100).round(2) 
	     row
     end
     .transform("add levels basic, 3, and 4 for null prof band", SumValues, :null, :plevelbasic, :plevel3, :plevel4)
     .transform("state_id", WithBlock) do |row|
	     if row[:entity_level] == 'school'
		     row[:state_id] = row[:school_id]
	     elsif row[:entity_level] == 'district'
		     row[:state_id] = "%05i" % (row[:district_id])
	     else
		     row[:state_id] == 'state'
	     end
	     row
     end
     .transform("map subject ids", HashLookup, :subject, map_subject_id, to: :subject_id)
     .transform("map test data type",HashLookup, :test_data_type, map_test_data_type, to: :test_data_type_id)
     .transform("map breakdown id",HashLookup, :breakdown, map_breakdown_id, to: :breakdown_id)
     .transform("transpose prof bands", Transposer, :proficiency_band, :value_float, :plevel4, :plevel3, :plevelbasic, :plevel2, :plevel1, :null)
     .transform("map prof band id",HashLookup, :proficiency_band, map_prof_band_id, to: :proficiency_band_id) 
     .transform("Fill in year, entity type, level code, test data type and id", Fill, {
         year: 2013,
	 level_code: 'e,m,h',
	 entity_type: 'public,charter',
      })
   end

   def config_hash
   {
       source_id: 8,
       state: 'wa',
       notes: 'DXT-1781 WA 2013,2014,2015 EOC MSP HSPE reload',
       url: 'http://reportcard.ospi.k12.wa.us/DataDownload.aspx',
       file: 'wa/DXT-1781/wa.2013.1.public.charter.[level].txt',
       level: nil,
       school_type: 'public,charter'
   } 
   end
end

WATestProcessor2013EOC_MSP_HSPE.new(ARGV[0],max:nil).run
