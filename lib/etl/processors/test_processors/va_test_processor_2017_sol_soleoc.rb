require_relative "../test_processor"


class VATestProcessor2017SOL_EOC < GS::ETL::TestProcessor
	
	def initialize(*args)
		super
		@year = 2017
	end

	map_breakdown_id = {
		'1' => 4,#native american or native alaskan
		'2' => 2,#asian
		'3' => 3,#black
		'4' => 6,#hispanic
		'5' => 8,#white
		'6' => 112,#Native Hawaiian or Other PI
		'99' => 21,#multiracial
		'swd' => 13,
		'swod' => 14,
		'frl' => 9,
		'non-frl' =>10,
		'lep' => 15,
		'non-lep' => 16,
		'F' => 11,
		'M' => 12,
		nil => 1
	}

	gsdata_map_breakdown_id = {
		'1' => 18,#native american or native alaskan
		'2' => 16,#asian
		'3' => 17,#black
		'4' => 19,#hispanic
		'5' => 21,#white
		'6' => 20,#Native Hawaiian or Other PI
		'99' => 22,#multiracial
		'swd' => 27,
		'swod' => 30,
		'frl' => 23,
		'non-frl' =>24,
		'lep' => 32,
		'non-lep' => 33,
		'M' => 25,
		'F' => 26,
		nil => 1
	}

	gsdata_map_subject_id = {
		'English Reading' => 80,
		'Writing' => 3,
		'Geography' => 42,
		'VA & US History' => 81,
		'World History I' => 43,
		'World History II' => 44,
		'Algebra I' => 6,
		'Algebra II' => 10,
		'Geometry' => 8,
		'Biology' => 22,
		'Chemistry' => 35,
		'Earth Science' => 36,
		'Mathematics'=> 5,
		'Science'=> 19,
		'History'=> 82
	}

	map_subject_id = {
		'English Reading' => 95,
		'Writing' => 3,
		'Geography' => 56,
		'VA & US History' => 96,
		'World History I' => 57,
		'World History II' => 58,
		'Algebra I' => 7,
		'Algebra II' => 11,
		'Geometry' => 9,
		'Biology' => 29,
		'Chemistry' => 42,
		'Earth Science' => 43,
		'Mathematics'=> 5,
		'Science'=> 25,
		'History'=> 97
	}

	map_prof_band_id ={
		pass_advanced_rate: 171,
		pass_prof_rate: 170,
		fail_rate: 169,
		pass_rate: 'null'
	}
	map_prof_band_id_gsdata ={
		pass_advanced_rate: 85,
		pass_prof_rate: 84,
		fail_rate: 83,
		pass_rate: 1
	} 	 

	source('va_sol_2017.txt',[],col_sep:"\t") do |s|
		s.transform('Fill missing default fields', Fill, {
      	test_data_type: 'Virginia Standards of Learning',
      	test_data_type_id: 41,
      	gsdata_test_data_type_id: 293, 
    })
	end	
	source('va_sol_eoc_2017.txt',[],col_sep:"\t") do |s|
		s.transform('Fill missing default fields', Fill, {
      	test_data_type: 'VAEOC',
      	test_data_type_id: 111,
      	gsdata_test_data_type_id: 294, 
    })
	end	

	shared do |s|
		s.transform('map breakdowns',HashLookup,:breakdown,map_breakdown_id,to: :breakdown_id)
    	.transform("Adding column breakdown_gsdata_id from breadown",HashLookup, :breakdown, gsdata_map_breakdown_id, to: :breakdown_gsdata_id)		
		.transform('map subjects',HashLookup,:test, map_subject_id, to: :subject_id)
		.transform('map subjects',HashLookup,:test, gsdata_map_subject_id, to: :academic_gsdata_id)		
		.transform('rename fields',MultiFieldRenamer,
		 {
			level_code: :entity,
			sch_namex: :school_name,
			div_namex: :district_name,
			sch_num: :school_id,
			div_num: :district_id,
			test: :subject,
			test_level: :grade,
			total_cnt: :number_tested
		})
		.transform('determine entity level and state_id',WithBlock,) do |row|
			if row[:entity] == 'DIV'
				row[:entity_level] = 'district'
				row[:state_id] = row[:district_id]
			elsif row[:entity] == 'SCH'
				row[:entity_level] = 'school'
				row[:state_id] = row[:district_id] + row[:school_id]
			else
				row[:entity_level] = 'state'
			end
			row
		end
		.transform('grade eoc is grade all',WithBlock,) do |row|
			if row[:grade] == 'EOC'
				row[:grade] = 'All'
			end
			row
		end
		.transform('source',WithBlock,) do |row|
			if row[:test_data_type_id] == 41
				row[:notes] = 'DXT-2696: VA SOL'
				row[:description] = "In 2016-2017 Virginia used the Standards of Learning (SOL) tests to assess students in reading and math in grades 3 through 8, writing in grades 5 and 8, and science in grades 3, 5 and 8. The SOL tests are standards-based, which means they measure how well students are mastering specific skills defined for each grade by the state of Virginia. The goal is for all students to pass the tests."
			else
				row[:notes] = 'DXT-2696: VA VA EOC'
				row[:description] = "In 2016-2017 Virginia used the Standards of Learning (SOL) End-of-Course tests to assess students in reading, writing, math, science and history/social science subjects at the end of each course, regardless of the student's grade level. The SOL End-of-Course tests are standards-based, which means they measure how well students are mastering specific skills defined for each grade by the state of Virginia. High school students must pass at least six SOL End-of-Course tests to graduate. The goal is for all students to pass the tests."
			end
			row
		end					
		.transform('transpose prof bands',Transposer,:proficiency_band, :value_float,:pass_advanced_rate,:pass_prof_rate,:fail_rate,:pass_rate )
		.transform('map prof bands',HashLookup,:proficiency_band, map_prof_band_id,to: :proficiency_band_id)
		.transform('map prof bands',HashLookup,:proficiency_band, map_prof_band_id_gsdata,to: :proficiency_band_gsdata_id)		
		.transform('',Fill,{
			entity_type: 'public,charter',
			level_code: 'e,m,h',
			year: 2017
		})
	end

	def config_hash
		{
		source_id:27,
		gsdata_source_id: 51,
		source_name:'Virginia Department of Education',
	    state: 'va',
		notes: 'DXT-2696 VA SOL, EOC 2017',
		url: '',
        date_valid: '2017-01-01 00:00:00',		
		file: 'va/2017/va.2017.1.public.charter.[level].txt',
		level: nil,
		school_type: 'public,charter'
		}		
	end

end

VATestProcessor2017SOL_EOC.new(ARGV[0],max:nil,offset:nil).run
