require_relative "../../test_processor"

class SCTestProcessor201720182019READYPASSEOCEP < GS::ETL::TestProcessor

	def initialize(*args)
		super
		@year = 2019
	end

	map_prof_band = {
	'prof_and_above' => 1
	}


	map_subject = {
	'ela' => 4,
	'math' => 5,
	'sci' => 19,
	'soc' => 18,
	'1' => 6, #alg1
	'2' => 22,#bio 1
	'3' => 17, #english 1
	'4' => 52 #US history and constitution
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
	'12' => 30,#general education
	'13' => 32,#lep
	'14' => 33,#not lep
	'15' => 23,#econ dis
	'16' => 24#not econ dis
	}

	source("sc_pass_2017_2018_2019.txt",[],col_sep:"\t") do |s|
		s.transform("Fill values", Fill,{
			data_type: 'PASS',
			data_type_id: '276',
			notes: 'DXT-3445 SC PASS'
			})
		.transform("Filling in description and date valid", WithBlock) do |row|
			    if row[:year] == '2017'
        			row[:date_valid] = '2017-01-01 00:00:00'
        			row[:description] = 'In 2016-2017, students took The South Carolina Palmetto Assessment of State Standards (SCPASS). SCPASS is a statewide assessment administered to students in grades four through eight. All students in these grade levels are required to take the SCPASS except those who qualify for the South Carolina Alternate Assessment (SC-Alt). SCPASS includes tests in two subjects: science and social studies.'
      			elsif row[:year] == '2018'
        			row[:date_valid] = '2018-01-01 00:00:00'
        			row[:description] = 'In 2017-2018, students took The South Carolina Palmetto Assessment of State Standards (SCPASS). SCPASS is a statewide assessment administered to students in science in the 4th, 6th and 8th grade and in social studies in the 5th and 7th grade. All students in these grade levels are required to take the SCPASS except those who qualify for the South Carolina Alternate Assessment (SC-Alt). SCPASS includes tests in two subjects: science and social studies.'
      			elsif row[:year] == '2019'
        			row[:date_valid] = '2019-01-01 00:00:00'
        			row[:description] = 'In 2018-201, students took The South Carolina Palmetto Assessment of State Standards (SCPASS). SCPASS is a statewide assessment administered to students in science in the 4th, 6th and 8th grade and in social studies in the 5th and 7th grade. All students in these grade levels are required to take the SCPASS except those who qualify for the South Carolina Alternate Assessment (SC-Alt). SCPASS includes tests in two subjects: science and social studies.'
      			end
     		row
    	end
	end



	source("sc_ready_2017_2018_2019.txt",[],col_sep:"\t") do |s|
		s.transform("Fill values", Fill,{
			data_type: 'SC READY',
			data_type_id: '279',
			notes: 'DXT-3445 SC SC READY'
			})
		.transform("Filling in description and date valid", WithBlock) do |row|
			    if row[:year] == '2017'
        			row[:date_valid] = '2017-01-01 00:00:00'
        			row[:description] = 'In 2016-2017, students took the South Carolina College- and Career-Ready Assessments (SC READY). The SC Ready is a statewide assessment that includes tests in English Language Arts (ELA) and mathematics administered to students in grades 3-8. All students in grades 3-8 are required to participate in the SC READY, except those who qualify for the South Carolina National Center and State Collaborative (SC-NCSC) alternate assessment. The initial administration of the SC READY was in spring 2016, and the SC READY test results will be used for state and federal accountability purposes.'
      			elsif row[:year] == '2018'
        			row[:date_valid] = '2018-01-01 00:00:00'
        			row[:description] = 'In 2017-2018, students took the South Carolina College- and Career-Ready Assessments (SC READY). The SC Ready is a statewide assessment that includes tests in English Language Arts (ELA) and mathematics administered to students in grades 3-8. All students in grades 3-8 are required to participate in the SC READY, except those who qualify for the South Carolina Alternate Assessment (SC-Alt). The initial administration of the SC READY was in spring 2016, and the SC READY test results will be used for state and federal accountability purposes.'
      			elsif row[:year] == '2019'
        			row[:date_valid] = '2019-01-01 00:00:00'
        			row[:description] = 'In 2018-2019, students took the South Carolina College- and Career-Ready Assessments (SC READY). The SC Ready is a statewide assessment that includes tests in English Language Arts (ELA) and mathematics administered to students in grades 3-8. All students in grades 3-8 are required to participate in the SC READY, except those who qualify for the South Carolina Alternate Assessment (SC-Alt). The initial administration of the SC READY was in spring 2016, and the SC READY test results will be used for state and federal accountability purposes.'
      			end
     		row
    	end
	end


	source("sc_eocep_2017_2018_2019.txt",[],col_sep:"\t") do |s|
		s.transform("Fill values", Fill,{
			data_type: 'SC EOCEP',
			data_type_id: '277',
			notes: 'DXT-3445 SC SC EOCEP',
			})
		.transform("Filling in description and date valid", WithBlock) do |row|
			    if row[:year] == '2017'
        			row[:date_valid] = '2017-01-01 00:00:00'
        			row[:description] = 'In 2016-2017 South Carolina used the End-of-Course Examination Program (EOCEP) to test middle and high school students in Algebra I, Biology I, English I, and US History & the Constitution. The EOCEP provides tests for high school core courses and for courses taken in middle school for high school credit. The EOCEP is a standards-based test program, which means it measures how well students are mastering specific skills defined for each grade by the state of South Carolina. The goal is for all students to score a D or above.'
      			elsif row[:year] == '2018'
        			row[:date_valid] = '2018-01-01 00:00:00'
        			row[:description] = 'In 2017-2018 South Carolina used the End-of-Course Examination Program (EOCEP) to test middle and high school students in Algebra I, Biology I, English I, and US History & the Constitution. The EOCEP provides tests for high school core courses and for courses taken in middle school for high school credit. The EOCEP is a standards-based test program, which means it measures how well students are mastering specific skills defined for each grade by the state of South Carolina. The goal is for all students to score a D or above.'
      			elsif row[:year] == '2019'
        			row[:date_valid] = '2019-01-01 00:00:00'
        			row[:description] = 'In 2018-2019 South Carolina used the End-of-Course Examination Program (EOCEP) to test middle and high school students in Algebra I, Biology I, English I, and US History & the Constitution. The EOCEP provides tests for high school core courses and for courses taken in middle school for high school credit. The EOCEP is a standards-based test program, which means it measures how well students are mastering specific skills defined for each grade by the state of South Carolina. The goal is for all students to score a D or above.'
      			end
     		row
    	end
	end



	shared do |s|
		s.transform("Map breakdown id", HashLookup, :demoid, map_breakdown, to: :breakdown_id)
		.transform("Map prof band id", HashLookup, :proficiency_band, map_prof_band, to: :proficiency_band_id)
	    .transform("Map subject id", WithBlock) do |row|
			if row[:data_type_id] == '276' or row[:data_type_id] == '279'
				row[:subject_id] = map_subject[row[:subject]]
			elsif row[:data_type_id] == '277'
			 	row[:subject_id] = map_subject[row[:testid]]
			end
			row
		end
	end

	def config_hash
		{
			source_id: 45,
			state: 'sc'
		}
	end
end

SCTestProcessor201720182019READYPASSEOCEP.new(ARGV[0],max:nil).run