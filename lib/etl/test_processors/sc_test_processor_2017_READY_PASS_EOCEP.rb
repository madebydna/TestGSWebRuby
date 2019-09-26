require_relative "../test_processor"

class SCTestProcessor2018READYPASSEOCEP < GS::ETL::TestProcessor

	def initialize(*args)
		super
		@year = 2018
	end

	map_prof_band = {
	'sci_pct1' => 5,
	'sci_pct2' => 6,
	'sci_pct3' => 7,
	'sci_pct4' => 8,
	'soc_pct1' => 2,
	'soc_pct2' => 3,
	'soc_pct3' => 4,
	'sci_prof_and_above' => 1,
	'soc_prof_and_above' => 1,
	'ela_pct1' => 5,
	'ela_pct2' => 6,
	'ela_pct3' => 7,
	'ela_pct4' => 8,
	'math_pct1' => 5,
	'math_pct2' => 6,
	'math_pct3' => 7,
	'math_pct4' => 8,
	'ela_prof_and_above' => 1,
	'math_prof_and_above' => 1
	}

	# map_prof_band_eoc = {
	# 'f' => 195,
	# 'd' => 196,
	# 'c' => 197,
	# 'b' => 198,
	# 'a' => 199,
	# 'null' => 'null'
	# }

	map_subject = {
	'ela' => 4,
	'math' => 5,
	'sci' => 19,
	'soc' => 18,
	'1' => 6,#alg1
	'2' => 22 #bio 1
	# '3' => 19, #english 1
	# '4' => 31, #physical science
	# '5' => 66, #US history and constitution
	}

	map_breakdown = {
	'01ALL' => 1,
	'02M' => 25,
	'03F' => 26,
	'04H' => 19,
	'05I' => 18,
	'06A' => 16,
	'07B' => 17,
	'08P' => 20,
	'09W' => 21,
	'10M' => 22,
	'11SWD' => 27,#disabilities
	'12NSWD' => 30,#no disabilities
	'13MIG' => 19,#migrant --skip
	'14NMIG' => 28,#not migrant --skip
	'15LEP' => 32,#lep 
	'16NLEP' => 33,#not lep
	'17SIP' => 23,#econ dis
	'18NSIP' => 24,#not econ dis
	'1' => 1,#all
	'2' => 25,#male
	'3' => 26,#female
	'4' => 19,#hispanic/latino
	'5' => 18,#am-in/alaska native
	'6' => 16,#asian
	'7' => 17,#african american /black
	'8' => 20,#native hawaiian other pacific islander
	'9' => 21,#white
	'10' => 22,#two more races
	'11' => 27,#disabled
	'12' => 30,#not disables
	'13' => 32,#lep
	'14' => 33,#not lep
	'15' => 23,#econ dis
	'16' => 24#not econ dis
	}

	# source("SC_PASS_2017.txt",[],col_sep:"\t") do |s|
	# 	s.transform("Fill values", Fill,{
	# 		test_data_type: 'pass',
	# 		test_data_type_id: '276',
	# 		description: 'In 2016-2017, students took The South Carolina Palmetto Assessment of State Standards (SCPASS). SCPASS is a statewide assessment administered to students in grades four through eight. All students in these grade levels are required to take the SCPASS except those who qualify for the South Carolina Alternate Assessment (SC-Alt). SCPASS includes tests in two subjects: science and social studies.'
	# 		})
	# end

	# source("SC_PASS_2018.txt",[],col_sep:"\t") do |s|
	# 	s.transform("Fill values", Fill,{
	# 		test_data_type: 'pass',
	# 		test_data_type_id: '276',
	# 		description: 'In 2017-2018, students took The South Carolina Palmetto Assessment of State Standards (SCPASS). SCPASS is a statewide assessment administered to students in science in the 4th, 6th and 8th grade and in social studies in the 5th and 7th grade. All students in these grade levels are required to take the SCPASS except those who qualify for the South Carolina Alternate Assessment (SC-Alt). SCPASS includes tests in two subjects: science and social studies.'
	# 		})
	# end


	source("SC_READY_2017.txt",[],col_sep:"\t") do |s|
		s.transform("Fill values", Fill,{
			test_data_type: 'sc ready',
			test_data_type_id: '279',
			description: 'In 2016-2017, students took the South Carolina College- and Career-Ready Assessments (SC READY). The SC Ready is a statewide assessment that includes tests in English Language Arts (ELA) and mathematics administered to students in grades 3-8. All students in grades 3-8 are required to participate in the SC READY, except those who qualify for the South Carolina National Center and State Collaborative (SC-NCSC) alternate assessment. The initial administration of the SC READY was in spring 2016, and the SC READY test results will be used for state and federal accountability purposes.'
			})
	end

	source("SC_READY_2018.txt",[],col_sep:"\t") do |s|
		s.transform("Fill values", Fill,{
			test_data_type: 'sc ready',
			test_data_type_id: '279',
			description: 'In 2017-2018, students took the South Carolina College- and Career-Ready Assessments (SC READY). The SC Ready is a statewide assessment that includes tests in English Language Arts (ELA) and mathematics administered to students in grades 3-8. All students in grades 3-8 are required to participate in the SC READY, except those who qualify for the South Carolina National Center and State Collaborative (SC-NCSC) alternate assessment. The initial administration of the SC READY was in spring 2016, and the SC READY test results will be used for state and federal accountability purposes.'
			})
	end


	shared do |s|
		s.transform("Map subject id", HashLookup, :subject, map_subject, to: :subject_id)
		.transform("Map breakdown id", HashLookup, :demoid, map_breakdown, to: :breakdown_id)
		.transform("Map prof band id", WithBlock) do |row|
			if row[:test_data_type_id] == '276' or row[:test_data_type_id] == '279'
				row[:proficiency_band_id] = map_prof_band[row[:name]]
			# elsif row[:test_data_type_id] == '191'
			# 	row[:proficiency_band_id] = map_prof_band_eoc[row[:proficiency_band]]
			end
			row
		end
		.transform("Fix inequalities in value and fix grade padding", WithBlock,) do |row|
	     if row[:value] < 0 
	      row[:value] = 0
	     end
         if row[:value] > 100
	      row[:value] = 100
	      end
	      row[:grade].sub!(/^0/, '')
	      row
        end
		.transform("Fill other columns", Fill,{
		notes: 'DXT-3136 SC READY, PASS, EOCEP',
		date_valid: '2018-01-01 00:00:00'
		})
	end

	def config_hash
		{
			source_id: 45,
			state: 'sc'
		}
	end
end

SCTestProcessor2018READYPASSEOCEP.new(ARGV[0],max:nil).run