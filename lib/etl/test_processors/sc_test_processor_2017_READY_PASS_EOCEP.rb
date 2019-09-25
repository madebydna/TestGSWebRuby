require_relative "../test_processor"
GS::ETL::Logging.disable

class SCTestProcessor2018_ACTAspire_PASS_EOCEP < GS::ETL::TestProcessor

	def initialize(*args)
		super
		@year = 2018
	end


	source("2018SCPASSv2_state.txt",[],col_sep:"\t") do |s|
		s.transform("Fill entity level", Fill,{
			entity_type: 'state',
			test_data_type: 'sc pass',
			test_data_type_id: '146',
			})
	end
	source("2018SCPASSv2_district.txt",[],col_sep:"\t") do |s|
		s.transform("Fill entity level", Fill,{
			entity_type: 'district',
			test_data_type: 'sc pass',
			test_data_type_id: '146',
			})
	end
	source("2018SCPASSv2_school.txt",[],col_sep:"\t") do |s|
		s.transform("Fill entity level", Fill,{
			entity_type: 'school',
			test_data_type: 'sc pass',
			test_data_type_id: '146',
			})
	end
	source("EOCEP2018_state.txt",[],col_sep:"\t") do |s|
		s.transform("Fill entity level", Fill,{
			entity_type: 'state',
			test_data_type: 'eocep',
			test_data_type_id: '191',
			grade: 'All',
			})
			.transform("delete rows where testid is 17 or greater",DeleteRows, :demoid, '17','18','19','20','21')
			.transform("delete rows with no data because number tested < 10",DeleteRows, :numbertested, nil,'0','1','2','3','4','5','6','7','8','9')
	end
	source("EOCEP2018_district.txt",[],col_sep:"\t") do |s|
		s.transform("Fill entity level", Fill,{
			entity_type: 'district',
			test_data_type: 'eocep',
			test_data_type_id: '191',
			grade: 'All',
			})
			.transform("delete rows where testid is 17 or greater",DeleteRows, :demoid, '17','18','19','20','21')
			.transform("delete rows with no data because number tested < 10",DeleteRows, :numbertested, nil,'0','1','2','3','4','5','6','7','8','9')
	end

	source("EOCEP2018_school.txt",[],col_sep:"\t") do |s|
		s.transform("Fill entity level", Fill,{
			entity_type: 'school',
			test_data_type: 'eocep',
			test_data_type_id: '191',
			grade: 'All',
			})
			.transform("delete rows where testid is 17 or greater",DeleteRows, :demoid, '17','18','19','20','21')
			.transform("delete rows with no data because number tested < 10",DeleteRows, :numbertested, nil,'0','1','2','3','4','5','6','7','8','9')
	end
	# map_prof_band_aspire = {
	# '1' => 34,
	# '2' => 35,
	# '3' => 36,
	# '4' => 37,
	# '34' => 'null'
	# }

	map_prof_band_pass = {
	'sci_pct1' => 5,
	'sci_pct2' => 6,
	'sci_pct3' => 7,
	'sci_pct4' => 8,
	'soc_pct1' => 2,
	'soc_pct2' => 3,
	'soc_pct3' => 4,
	'sci_prof_and_above' => 1
	'soc_prof_and_above' => 1
	}

	map_prof_band_eoc = {
	'f' => 195,
	'd' => 196,
	'c' => 197,
	'b' => 198,
	'a' => 199,
	'null' => 'null'
	}

	map_subject = {
	'ela' => 4,
	'math' => 5,
	'sci' => 19,
	'soc' => 18,
	'1' => 6,#alg1
	'2' => 22, #bio 1
	'3' => 19, #english 1
	'4' => 31, #physical science
	'5' => 66, #US history and constitution
	}

	map_breakdown = {
	'01ALL' => 1,
	'02M' => 12,
	'03F' => 11,
	'04H' => 6,
	'05I' => 4,
	'06A' => 2,
	'07B' => 3,
	'08P' => 112,
	'09W' => 8,
	'10M' => 21,
	'11SWD' => 13,#disabilities
	'12NSWD' => 14,#no disabilities
	'13MIG' => 19,#migrant
	'14NMIG' => 28,#not migrant
	'15LEP' => 15,#lep
	'16NLEP' => 16,#not lep
	'17SIP' => 9,#econ dis
	'18NSIP' => 10,#not econ dis
	'1' => 1,#all
	'2' => 12,#male
	'3' => 11,#female
	'4' => 6,#hispanic/latino
	'5' => 4,#am-in/alaska native
	'6' => 2,#asian
	'7' => 3,#african american /black
	'8' => 112,#native hawaiian other pacific islander
	'9' => 8,#white
	'10' => 21,#two more races
	'11' => 13,#disabled
	'12' => 14,#not disables
	'13' => 15,#lep
	'14' => 16,#not lep
	'15' => 9,#econ dis
	'16' => 10,#not econ dis
	}

	shared do |s|
		s.transform("Rename columns", MultiFieldRenamer,{
		testgrade: :grade,
		demoid: :breakdown,
		districtname: :district_name,
		distcode: :district_id,
		schoolname: :school_name,
		schoolid: :school_id,
		numbertested: :number_tested,
		testid: :subject,
		chbedscode: :school_id
		})
		.transform("null prof band for pass",WithBlock) do |row|
			if row[:test_data_type_id] == '146'
				row[:scipctnull] = (row[:scipct2].to_f + row[:scipct3].to_f).round(2) 
			        row[:socpctnull] = (row[:socpct2].to_f + row[:socpct3].to_f).round(2) 
			elsif row[:test_data_type_id] == '191'
				row[:null]= (row[:pcta].to_f + row[:pctb].to_f+row[:pctc].to_f+row[:pctd].to_f).round(2) 
			end
			row
		end
		.transform("Transpose subjects prof band columns",Transposer,:subjectprof, :value_float, :engpct1, :engpct2, :engpct3, :engpct4, :engpct34,:mathpct1,:mathpct2,:mathpct3,:mathpct4,:mathpct34,:readpct1, :readpct2,:readpct3,:readpct4,:readpct34,:writpct1,:writpct2,:writpct3,:writpct4,:writpct34,:scipct1,:scipct2,:scipct3,:scipctnull,:socpct1,:socpct2,:socpct3,:socpctnull,:pcta,:pctb,:pctc,:pctd,:pctf,:null)
		.transform("set prof band and subject",WithBlock) do |row|
			if row[:test_data_type_id]  != '191'
				row[:subject] = (row[:subjectprof].to_s).split(/pct/).first
			end
			row[:proficiency_band] = (row[:subjectprof].to_s).split(/pct/).last
			row
		end
		.transform("number tested", WithBlock) do |row|
			if row[:subject] ==  'ela'
				row[:number_tested] = row[:engn]
			elsif row[:subject] == 'math'
				row[:number_tested] = row[:mathn]
			elsif row[:subject] ==  'soc'
				row[:number_tested] = row[:socn]
			elsif row[:subject] == 'sci'
				row[:number_tested] = row[:scin]
			end
			row
		end
		.transform("delete rows with no data because number tested < 10",DeleteRows, :number_tested, nil,'0','1','2','3','4','5','6','7','8','9')
		.transform("Map subject id", HashLookup, :subject, map_subject, to: :subject_id)
		.transform("Map breakdown id", HashLookup, :breakdown, map_breakdown, to: :breakdown_id)
		.transform("Map prof band id", WithBlock) do |row|
			if row[:test_data_type_id] == '312'
				row[:proficiency_band_id] = map_prof_band_aspire[row[:proficiency_band]]
			elsif row[:test_data_type_id] == '146'
				row[:proficiency_band_id] = map_prof_band_pass[row[:proficiency_band]]
			elsif row[:test_data_type_id] == '191'
				row[:proficiency_band_id] = map_prof_band_eoc[row[:proficiency_band]]
			end
			row
		end
		.transform("state_id",WithBlock) do |row|
			if row[:entity_type] == 'school'
				row[:state_id] = "%07i" %(row[:school_id].to_i)
			elsif row[:entity_type] == 'district'
				row[:state_id] = "%04i" %(row[:district_id].to_i)
			elsif row[:entity_type] == 'state'
				row[:state_id] = 'state'
			end
			row
		end
		.transform("remove leading zeros from grade", WithBlock) do |row|
			if row[:grade] != 'All'
				row[:grade] = row[:grade].to_i
			end
			row
		end
		.transform("check for blank value_float that should be zero", WithBlock) do |row|
			if row[:value_float].nil?
			#if row[:value_float] =~ /\s/
			#if row[:value_float] !~ /\d/
			#if row[:value_float] == ''
				row[:value_float] = 0
			end
			row
		end
		.transform("Fill other columns", Fill,{
		year: 2018
		notes: 'DXT-3136 SC READY, PASS, EOCEP',
		date_valid: '2018-01-01 00:00:00',
		})
	end

	def config_hash
		{
			source_id: 8,
			state: 'sc'
		}
	end
end

SCTestProcessor2018_ACTAspire_PASS_EOCEP.new(ARGV[0],max:nil).run
