require_relative "../test_processor"
GS::ETL::Logging.disable

class NHTestProcessor2015sbac < GS::ETL::TestProcessor

   def initialize(*args)
      super
      @year = 2015
   end

  source("sbac-disagregated-data-math.txt",[],col_sep: "\t") do |s|
      s.transform("Set subject and id",Fill,{   
         subject: 'math',
	 subject_id: '5'
      })
  end 
  source("sbac-disagregated-data-ela.txt",[],col_sep: "\t") do |s|
      s.transform("Set subject and id",Fill,{   
         subject: 'reading',
	 subject_id: '2'
      })
  end

   map_breakdown_id = {
	   'All' => 1,                                               
	   'Econddis_NotEcondis' => 10,                               
	   'Econdis' => 9,                                                                               
	   'EL_NotEL' => 16,                  
	   'Gender_Female' => 11,                                     
	   'Gender_Male' => 12,                                   
	   'IEP' => 13,                                 
	   'IEP_NotIEP'  => 14,                                       
	   'Migrant_NotMigrant' => 28,                                
	   'Race_Asian' => 2,                                        
	   'Race_Black_AfrAmerican' => 3,                            
	   'Race_Hispanic' => 6,                     
	   'Race_Two_or_More' => 21,                                  
	   'Race_White' => 8,                           
	   'EL_Current' => 15,                                  
	   'Race_AmerInd_AlaskanNat' => 4,
	   'Race_Hawaiian' => 51,                     
	   'Migrant' => 19                          	   
   }

   map_prof_band_id = {
      plevel1: 34,
      plevel2: 35,
      plevel3: 36,
      plevel4: 37,
      null: 'null'
   }

   shared do |s|
     s.transform("Rename columns", MultiFieldRenamer,
      {
      replevel: :entity_level,
      discode: :district_id,
      disname: :district_name,
      schcode: :school_id,
      schname: :school_name,
      subgroup: :breakdown,
#      plevel1: :'% level 1',
#      plevel2: :'% level 2',
#      plevel3: :'% level 3',
#      plevel4: :'% level 4',
      naccountabletested: :number_tested,
      })
     .transform("delete rows where subgroup is waiver_",DeleteRows, :breakdown, /^Waiver/)
     .transform("delete rows where subgroup is el_monitor",DeleteRows, :breakdown, /^EL_Monitor/)
     .transform("delete rows where proficiency band is n < 11 ",DeleteRows, :'plevel1', 'n < 11')
     .transform("remove whitespace from breakdown",WithBlock,) do |row|
	     row[:breakdown] = row[:breakdown].strip
	     row
     end
     .transform("Add column with breakdown id", HashLookup, :breakdown, map_breakdown_id, to: :breakdown_id)
     .transform("entity level", WithBlock,) do |row|
	     if row[:entity_level] == 'dis'
		     row[:entity_level] = 'district'
		     row[:state_id] = "%03i" % (row[:district_id])
	     elsif row[:entity_level] == 'sch'
		     row[:entity_level] = 'school'
		     row[:state_id] = "%03i%05i" % [row[:district_id],row[:school_id]]
	     elsif row[:entity_level] == 'sta'
		     row[:entity_level] = 'state'
		     row[:state_id] = 'state'
	     end
	     row
     end
     .transform("grade 0", WithBlock,) do |row|
	     if row[:grade] == '0'
		     row[:grade] = 'All'
	     end
	     row
     end
     .transform("sum level 3 and 4 for null prof band", SumValues, :null, :plevel4, :plevel3)
     .transform("transpose prof bands", Transposer, :proficiency_band, :value_float, :plevel4, :plevel3, :plevel2, :plevel1, :null)
     .transform("map prof band id",HashLookup, :proficiency_band, map_prof_band_id, to: :proficiency_band_id) 
     .transform("Fill in year, entity type, level code, test data type and id", Fill, {
         year: 2015,
	 level_code: 'e,m,h',
	 entity_type: 'public,charter',
	 test_data_type: 'sbac',
	 test_data_type_id: '308'
      })
   end

   def config_hash
   {
       source_id: 32,
       state: 'nh',
       notes: 'DXT-1756 NH 2015 SBAC',
       url: 'http://education.nh.gov/instruction/assessment/sbac/index.htm',
       file: 'nh/2015/nh.2015.1.public.charter.[level].txt',
       level: nil,
       school_type: 'public,charter'
   } 
   end
end

NHTestProcessor2015sbac.new(ARGV[0],max:nil).run
