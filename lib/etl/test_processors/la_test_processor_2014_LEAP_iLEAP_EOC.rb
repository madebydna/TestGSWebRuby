require_relative "../test_processor"
GS::ETL::Logging.disable

class LATestProcessor2014LEAPiLEAPEOC < GS::ETL::TestProcessor

   def initialize(*args)
      super
      @year = 2014
   end

  source("2014_LEAP.txt",[],col_sep: "\t") do |s|
      s.transform("Set data type and id",Fill,{   
         test_data_type: 'leap',
         test_data_type_id: '44',
      })
  end
  source("2014_iLEAP.txt",[],col_sep: "\t") do |s|
      s.transform("Set data type and id",Fill,{   
         test_data_type: 'ileap',
         test_data_type_id: '127',
      })
  end
  source("2014_EOC.txt",[],col_sep: "\t") do |s|
      s.transform("Set data type and id",Fill,{   
         test_data_type: 'laeoc',
         test_data_type_id: '183',
         year: 2014,
	 grade: 'All',
         level_code: 'h',
      })
  end
   map_subject_id = {
      'SCI' => 25,
      'SOC' => 24,
      'ELA' => 4,
      'MTH' => 5,
      'Algebra I' => 7,
      'Biology' => 29,
      'English II' => 27,
      'English III' => 63,
      'Geometry' => 9,
      'U.S. History' => 30,
   }

   map_breakdown_id = {
      'EconomicallyDisadvantaged' => 9,
      'EthnicityRaceBlack or African American' => 3,
      'EthnicityRaceOther' => 23,
      'EthnicityRaceWhite' => 8,
      'Free_ReducedLunch' => 9,
      'EthnicytRaceOther' => 23,
      'EthnicityRaceBlackorAfricanAmerican' => 3,
      'Economically Disadvantaged' => 9,
      'EthnicityOther' => 23,
   }

   map_prof_band_id = {
      advanced: 93,
      mastery: 92,
      basic: 91,
      approaching_basic: 90,
      unsatisfactory: 89,
      excellent_: 29,
      good_: 28,
      fair_: 27,
      needs_improvement_: 26,
      null: 'null'
   }

   shared do |s|
      s.transform("Add subject id", HashLookup, :subject, map_subject_id, to: :subject_id)
      .transform("delete rows where proficiency bands are  ~",DeleteRows, :advpercent, '~', /^#/)
      .transform("delete rows where proficiency bands are  ~",DeleteRows, :excellent_, '~',/^#/)
      .transform("delete rows where school is unknown",DeleteRows, :schoolname, 'unknown','Unknown')
      .transform("Add subject id column for eoc",HashLookup,:'eoc_test', map_subject_id, to: :subject_id)
      .transform("Add column with breakdown id", HashLookup, :subgroup, map_breakdown_id, to: :breakdown_id)
      .transform("downcase entity level", WithBlock,) do |row|
         row[:summarylevel].downcase!
	 row
      end
      .transform("Rename columns", MultiFieldRenamer,
      {
      summarylevel: :entity_level,
      districtcode: :district_id,
      districtname: :district_name,
      schoolcode: :school_id,
      schoolname: :school_name,
      subgroup: :breakdown,
      advpercent: :advanced,
      maspercent: :mastery,
      baspercent: :basic,
      apppercent: :approaching_basic,
      unspercent: :unsatisfactory,
      eoc_test: :subject,
      district_code: :district_id,
      school_code: :school_id
      })
      .transform("state id", WithBlock) do |row|
	     if row[:entity_level] == 'district'
                row [:state_id] = "%03s" % (row[:district_id])
             elsif row[:entity_level] == 'school' 
	        if (row[:school_id].length) == 6
		     row[:state_id] = row[:school_id]
	        elsif (row[:school_id].length) == 3	     
		     row [:state_id] = "%03s%03s" % [row[:district_id], row[:school_id]]
		end
	     elsif row[:entity_level] == 'state'
	        row[:state_id] = 'state'
	     end
	row
      end
      .transform("Prof null column", SumValues, :null, :advanced, :mastery,:excellent_, :good_)
      .transform("Transpose Proficiency bands",Transposer,:proficiency_band, :value_float, :advanced, :mastery, :basic, :approaching_basic, :unsatisfactory, :excellent_, :good_, :fair_, :needs_improvement_,:null)
      .transform("Add column with prof band id", HashLookup, :proficiency_band, map_prof_band_id, to: :proficiency_band_id)
      .transform("Fix inequalities in value float and replace grade hs with all", WithBlock,) do |row|
	   if row[:value_float] == '?1'
	      row[:value_float] = 0
	   end
           if row[:value_float] == '?99'
	      row[:value_float] = '100'
	   end
	   if row[:grade] == 'HS'
	      row[:grade] = 'All'
	   end
	   row[:grade].sub!(/^0/, '')
	   row
      end
      .transform("Fill in n tested, entity type, level code", Fill, {
         level_code: 'e,m,h',
	 number_tested: nil,
	 entity_type: 'public,charter',
      })
   end

   def config_hash
   {
       source_id: 28,
       state: 'la',
       notes: 'DXT-1583 LA LEAP, iLEAP, EOC 2014',
       url: 'http://doe.state.la.us/',
       file: 'la/DXT-1583/2014/la.2014.2.public.charter.[level].txt',
       level: nil,
       school_type: 'public,charter'
   } 
   end
end

LATestProcessor2014LEAPiLEAPEOC.new(ARGV[0],max:nil).run
