require_relative "../test_processor"
GS::ETL::Logging.disable

class MATestProcessor2017PARCCMCAS < GS::ETL::TestProcessor
	
	def initialize(*args)
		super
		@year = 2017
	end

	map_breakdown_id = {
	'All Students' => 1,
	'Male' => 12,
	'Female' => 11,
	'African American' => 3,
	'White' => 8,
	'Hispanic/Latino' => 6,
	'Students with Disabilities' => 13,
	'Economically Disadvantaged' => 9,
	'Non-Economically Disadvantaged' => 10,
	'Multi-Race (non-Hispanic/Latino)' => 21,
	'Asian' => 2,
	'English Language Learner (ELL)' => 15,
	'Native American' => 4,
	'Hawaiian/Pacific Islander' => 112
	}

	map_gsdata_breakdown_id = {
	'All Students' => 1,
	'Male' => 25,
	'Female' => 26,
	'African American' => 17,
	'White' => 21,
	'Hispanic/Latino' => 19,
	'Students with Disabilities' => 27,
	'Economically Disadvantaged' => 23,
	'Non-Economically Disadvantaged' => 24,
	'Multi-Race (non-Hispanic/Latino)' => 22,
	'Asian' => 16,
	'English Language Learner (ELL)' => 32,
	'Native American' => 18,
	'Hawaiian/Pacific Islander' => 20
	}


	map_subject_id = {
	'ELA' => 4,
	'Math' => 5,
	'Science' => 25,
	'Introductory Physics' => 41,
	'Technology/Engineering' => 61,
	'Biology' => 29,
	'Chemistry' => 42
	}

	map_gsdata_academic_id = {
	'ELA' => 4,
	'Math' => 5,
	'Science' => 19,
	'Introductory Physics' => 34,
	'Technology/Engineering' => 47,
	'Biology' => 22,
	'Chemistry' => 35
	}

	source('ma_2017_MCAS_school.txt',[],col_sep:"\t") do |s|
	s.transform('Fill missing default fields', Fill, {
		entity_level: 'school',
	})
	end

	source('ma_2017_MCAS_district.txt',[],col_sep:"\t") do |s|
		s.transform('setting entity levels',WithBlock) do |row|
			if row[:districtname] == 'State'
				row[:entity_level] = 'state'
			else row[:entity_level] = 'district'
			end
			row
		end
	end

	source('ma_2017_PARCC_school.txt',[],col_sep:"\t") do |s|
		s.transform("set data types",Fill,{
			entity_level: 'school',
			test_data_type: 'MA PARCC',
			test_data_type_id: 305,
			gsdata_test_data_type_id: 292,
			notes: 'DXT-2655: MA MA PARCC',
			description: 'In 2016-2017, students were tested with the PARCC assessment for grades 3-8 in English and Math.'
		})
	end

	source('ma_2017_PARCC_district.txt',[],col_sep:"\t") do |s|
		s.transform('setting entity levels',WithBlock) do |row|
			if row[:districtname] == 'State'
				row[:entity_level] = 'state'
			else row[:entity_level] = 'district'
			end
			row
		end
		s.transform("set data types",Fill,{
			test_data_type: 'MA PARCC',
			test_data_type_id: 305,
			gsdata_test_data_type_id: 292,
			notes: 'DXT-2655: MA MA PARCC',
			description: 'In 2016-2017, students were tested with the PARCC assessment for grades 3-8 in English and Math.'
		})
	end

	shared do |s|
		s.transform('rename columns',MultiFieldRenamer,{
			districtcode: :district_id,
			districtname: :district_name,
			schoolcode: :school_id,
			schoolname: :school_name,
			subgroup: :breakdown
		})
		.transform('skip migrant subgroups',DeleteRows,:breakdown,'"Middle Sch.(grd. 6,7,8)"','"Middle/High Sch.(grd. 6,7,8,10)"','High Sch.(grd. 10)','"Elem. Sch. (grd. 3,4,5)"','"Elem/Middle Sch.(grd. 3,4,5,6,7,8)"','High Needs','migrant','Ever ELL','Former ELL','ELL and Former ELL','Non-Title I','Title I','Non-Binary')
		.transform('skip migrant subgroups',DeleteRows,:grade,'EM','ES','HH','MH','MS')
		.transform('transpose proficiency band ids',Transposer,:subject,:value_float,:eadvpro_per,:madvpro_per,:sadvpro_per,:bioadvpro_per, :cheadvpro_per, :phyadvpro_per, :tecadvpro_per,:emeet_exceed_per,:mmeet_exceed_per)
		.transform('delete blank rows',WithBlock) do |row|
			if row[:value_float] == ' '
				row[:value_float] = 'skip'
			end
			row
		end
		.transform('delete blank data',DeleteRows,:value_float,'skip')
		.transform('create subject/value columns from transposed columns',WithBlock) do |row|
			if row[:subject].to_s =~ /^e/
				row[:proficiency_band] = 'prof_null'
				row[:subject] = 'ELA'
				row[:number_tested] = row[:etotal]
			elsif row[:subject].to_s =~ /^m/
				row[:proficiency_band] = 'prof_null'
				row[:subject] = 'Math'
				row[:number_tested] = row[:mtotal]
			elsif row[:subject].to_s =~ /^s/
				row[:proficiency_band] = 'prof_null'
				row[:subject] = 'Science'
				row[:number_tested] = row[:stotal]
			elsif row[:subject].to_s =~ /^bio/
				row[:proficiency_band] = 'prof_null'
				row[:subject] = 'Biology'
				row[:number_tested] = row[:biototal]
			elsif row[:subject].to_s =~ /^che/
				row[:proficiency_band] = 'prof_null'
				row[:subject] = 'Chemistry'
				row[:number_tested] = row[:chetotal]
			elsif row[:subject].to_s =~ /^phy/
				row[:proficiency_band] = 'prof_null'
				row[:subject] = 'Introductory Physics'
				row[:number_tested] = row[:phytotal]
			elsif row[:subject].to_s =~ /^tec/
				row[:proficiency_band] = 'prof_null'
				row[:subject] = 'Technology/Engineering'
				row[:number_tested] = row[:tectotal]
			end
			row
		end
		.transform('n tested < 10',DeleteRows,:number_tested,'1','2','3','4','5','6','7','8','9')
		.transform('assign MCAS tests',WithBlock) do |row|
			if row[:test_data_type_id] != 305
				if row[:subject] == 'ELA' || row[:subject] == 'Math' || row[:subject] == 'Science'
					row[:test_data_type] = 'MCAS'
					row[:test_data_type_id] = 39
					row[:gsdata_test_data_type_id] = 290
					row[:notes] = 'DXT-2655: MA MCAS'
					row[:description] = 'In 2016-2017 Massachusetts used the Massachusetts Comprehensive Assessment System (MCAS) to test students in grade 10 in English Language Arts and Math, and grades 5, 8 and 10 in science. The grade 10 MCAS is a high school graduation requirement. The MCAS is a standards-based test, it measures specific skills defined for each grade by the state of Massachusetts. The goal is for all students to score at or above proficient on the test.'
				elsif
					row[:test_data_type] = 'MCAS STE'
					row[:test_data_type_id] = 129
					row[:gsdata_test_data_type_id] = 291
					row[:notes] = 'DXT-2655: MA MCAS STE'
					row[:description] = 'In 2016-2017 Massachusetts used the Massachusetts Comprehensive Assessment System Science and Technology/Engineering Tests (MCAS STE) to test students in high school in biology, chemistry, introductory physics and technology/engineering. The MCAS STE is a standards-based test, which means it measures specific skills defined for each grade by the state of Massachusetts. The goal is for all students to score at or above proficient on the test.'
				end
			end
			row
		end
		.transform('breakdown id',HashLookup,:breakdown,map_breakdown_id,to: :breakdown_id)
		.transform('breakdown id',HashLookup,:breakdown,map_gsdata_breakdown_id,to: :breakdown_gsdata_id)
		.transform('subject ids',HashLookup,:subject, map_subject_id,to: :subject_id)
		.transform('academic ids',HashLookup,:subject, map_gsdata_academic_id,to: :academic_gsdata_id)
		.transform('mapping grades',WithBlock) do |row|
			if row[:grade] == '03' || row[:grade] == '04' || row[:grade] == '05' || row[:grade] == '06' || row[:grade] == '07' || row[:grade] == '08'
				row[:grade] = row[:grade].tr('0','')
			elsif row[:grade] == '10'
				row[:grade] = row[:grade]
			else row[:grade] = 'All'
			end
			row
		end
		.transform('setting state id',WithBlock) do |row|
			if row[:entity_level] == 'state'
				row[:state_id] = 'state'
				row[:district_id] = 'state'
			elsif row[:entity_level] == 'district'
				row[:state_id] = row[:district_id][0..3]
				row[:district_id] = row[:state_id]
			else
				row[:state_id] = row[:school_id]
				row[:district_id] = nil
			end
			row
		end
		.transform('',Fill,{
			year: 2017,
			entity_type: 'public,charter',
			level_code: 'e,m,h',
			proficiency_band_id: 'null',
			proficiency_band_gsdata_id: 1
		})
		.transform('fix values over 100', WithBlock) do |row|
			if row[:value_float].to_f > 100
				row[:value_float] = '100'
			end
			row
		end
	end

	def config_hash
		{
		source_id: 20,
		source_name: "Massachusetts Department of Education",
		date_valid: '2017-01-01 00:00:00',
		state: 'ma',
		url: 'http://www.doe.mass.edu/',
		file: 'ma/2017/ma.2017.1.public.charter.[level].txt',
		level: nil,
		school_type: 'public,charter'
		}
	end

end

MATestProcessor2017PARCCMCAS.new(ARGV[0],max:nil,offset:nil).run
