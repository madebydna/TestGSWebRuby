require_relative "../test_processor"

class NHTestProcessor2016SBAC < GS::ETL::TestProcessor

   def initialize(*args)
      super
      @year = 2016
   end

	 key_map_bd = {
			 'All' => 1,
			 'Econddis_NotEcondis' => 10,
			 'Econdis' => 9,
			 'EL_NotEL' => 16,
			 'Gender_Female' => 11,
			 'Gender_Male' => 12,
			 'IEP' => 13,
			 'IEP_NotIEP'  => 14,
			 'Race_Asian' => 2,
			 'Race_Black_AfrAmerican' => 3,
			 'Race_Hispanic' => 6,
			 'Race_Two_or_More' => 21,
			 'Race_White' => 8,
			 'EL_Current' => 15,
			 'Race_AmerInd_AlaskanNat' => 4,
			 'Race_Hawaiian' => 51
	 }

	 key_map_pro = {
			 :"plevel1" => 34,
			 :"plevel2" => 35,
			 :"plevel3" => 36,
			 :"plevel4" => 37,
			 :"null" => 'null'
	 }

   source("disag-math15-16_582017.txt",[],col_sep: "\t") do |s|
      s.transform('Fill missing default fields',Fill,{
         subject: 'math',
	       subject_id: '5'
      })
  end
  source("disag-ela15-16_582017.txt",[],col_sep: "\t") do |s|
      s.transform('Fill missing default fields',Fill,{
         subject: 'reading',
				 subject_id: '2'
      })
  end

   shared do |s|
     s.transform("Rename columns", MultiFieldRenamer,
      {
				replevel: :entity_level,
				discode: :district_id,
				disname: :district_name,
				schcode: :school_id,
				schname: :school_name,
				subgroup: :breakdown,
				naccountabletested: :number_tested,
      })
			.transform("Fill in year, entity type, level code, test data type and id", Fill, {
					year: 2016,
					level_code: 'e,m,h',
					entity_type: 'public_charter',
					test_data_type: 'sbac',
					test_data_type_id: '308'
				 })
			.transform("Process breakdown", WithBlock,) do |row|
			 row[:breakdown] = row[:breakdown].gsub!(' ', '')
			 row
		 end
     .transform("Remove breakdowns",DeleteRows, :breakdown, /^Waiver/, /^EL_Monitor/, "Migrant", "Migrant_NotMigrant")
     .transform("Delete rows where number tested is less than 10" ,DeleteRows, :number_tested, '0','1','2','3','4','5','6','7','8','9')
		 .transform("Delete suppressed rows" ,DeleteRows, :plevel1, 'n < 11')
		 .transform("Sum level 3 and 4 for null prof band", SumValues, :null, :plevel4, :plevel3)
		 .transform("Process grade 0", WithBlock,) do |row|
			 if row[:grade] == '0'
				 row[:grade] = 'All'
			 end
			 row
		 end
		 .transform("transpose prof bands", Transposer,
					:proficiency_band,
					:value_float,
					:"plevel4",
					:"plevel3",
					:"plevel2",
					:"plevel1",
					:"null")
		 .transform("map prof band id",HashLookup, :proficiency_band, key_map_pro, to: :proficiency_band_id)
	   .transform("Add column with breakdown id", HashLookup, :breakdown, key_map_bd, to: :breakdown_id)
		 .transform("Process prof null", WithBlock,) do |row|
			 if row[:value_float] == 101
				 row[:value_float] = 100
			 end
			 row
		 end
		 .transform("entity level", WithBlock,) do |row|
	     if row[:entity_level] == 'dis'
		     row[:entity_level] = 'district'
		     row[:state_id] = row[:district_id].rjust(3,'0')
	     elsif row[:entity_level] == 'sch'
		     row[:entity_level] = 'school'
				 row[:district_id] = row[:district_id].rjust(3,'0')
		     row[:state_id] = row[:district_id].rjust(3,'0')+row[:school_id].rjust(5,'0')
	     elsif row[:entity_level] == 'sta'
		     row[:entity_level] = 'state'
	     end
	     row
      end
			.transform('Fill missing ids and names with entity_level', WithBlock) do |row|
				 [:state_id, :school_id, :district_id, :school_name, :district_name].each do |col|
					 row[col] ||= row[:entity_level]
				 end
				 row
		  end
		 end

   def config_hash
   {
       source_id: 32,
       state: 'nh',
       notes: 'DXT-2118 NH 2016 SBAC',
       url: 'http://education.nh.gov/instruction/assessment/sbac/index.htm',
       file: 'nh/2016/output/nh.2016.1.public.charter.[level].txt',
       level: nil,
       school_type: 'public,charter'
   } 
   end
end

NHTestProcessor2016SBAC.new(ARGV[0],max:nil).run
