require_relative "../test_processor"

class WATestProcessor2016_SBAC_EOC_MSP < GS::ETL::TestProcessor

  def initialize(*args)
    super
    @year = 2016
  end

   map_breakdown_id = {
     'All' => 1,
     'Male' => 12,     
     'Female' => 11,
     'American Indian / Alaskan Native' => 4,
     'Black / African American' => 3,
     'Hispanic / Latino of any race(s)' => 6,
     'White' => 8,
     'Migrant' => 19,     
     'Special Education' => 13,
     'Limited English' => 15,
     'Low Income' => 9,
     'Non Special Education' => 14,
     'Non Low Income' => 10,
     'Asian' => 2,
     'Two or More Races' => 21,
     'Native Hawaiian / Other Pacific Islander' => 112 
   }

   map_prof_band_id = {
      :"level4" => 187,
      :"level3" => 186,
      :"levelbasic" => 185,
      :"level2" => 184,
      :"level1" => 183,
      :"prof_null" => 'null'
   }

   map_subject_id = {
    'MATH' => 5,
    'ELA' => 4,
    'Biology' => 29,
    'Science' => 25,
   }
   map_test_data_type = {
    'EOC' => 156,
    'MSP' => 149,
    'SBA' => 317
   }

  source("school_cal.txt",[],col_sep:"\t") do |s|
      s.transform("fill entity level",Fill,{   
	 entity_level: 'school'
      })
  end 
  source("district_cal.txt",[],col_sep:"\t") do |s|
      s.transform("fill entity level",Fill,{   
	 entity_level: 'district'
      })
  end  
  source("state_cal.txt",[],col_sep:"\t") do |s|
      s.transform("fill entity level",Fill,{   
	 entity_level: 'state'
      })
  end

   shared do |s|
     s.transform("Rename columns", MultiFieldRenamer,
      {
        district: :district_name,
        school: :school_name,
        test_type: :test_data_type,
        n_tested: :number_tested,
        pt4: :level4,
        pt3: :level3,
        ptb: :levelbasic,
        pt2: :level2,
        pt1: :level1
      })
      .transform('Fill missing default fields', Fill, {
        entity_type: 'public_charter',
        level_code: 'e,m,h',
        year: 2016
      })
      .transform("transpose prof bands", Transposer, 
      :proficiency_band, 
      :value_float, 
      :"level4", 
      :"level3", 
      :"levelbasic", 
      :"level2", 
      :"level1", 
      :"prof_null"
      )
     .transform("delete rows where number_tested < 10 ",DeleteRows, :number_tested, '0','1','2','3','4','5','6','7','8','9')
     .transform("map subject ids", HashLookup, :subject, map_subject_id, to: :subject_id)
     .transform("map test data type",HashLookup, :test_data_type, map_test_data_type, to: :test_data_type_id)
     .transform("map breakdown id",HashLookup, :breakdown, map_breakdown_id, to: :breakdown_id)
     .transform("map prof band id",HashLookup, :proficiency_band, map_prof_band_id, to: :proficiency_band_id) 
     .transform("state_id", WithBlock) do |row|
	     if row[:entity_level] == 'school'
		     row[:state_id] = row[:school_id]
	     elsif row[:entity_level] == 'district'
		     row[:state_id] = row[:district_id]
	     else
		     row[:state_id] == 'state'
	     end
	     row
     end
   end

   def config_hash
   {
       source_id: 8,
       state: 'wa',
       notes: 'DXT-1885 WA, SBAC, EOC Biology, MSP Science',
       url: 'http://reportcard.ospi.k12.wa.us/DataDownload.aspx',
       file: 'wa/2016/output/wa.2016.1.public.charter.[level].txt',
       level: nil,
       school_type: 'public,charter'
   } 
   end
end

WATestProcessor2016_SBAC_EOC_MSP.new(ARGV[0],max:nil).run
