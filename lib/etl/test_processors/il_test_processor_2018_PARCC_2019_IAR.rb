require_relative "../test_processor"
#GS::ETL::Logging.disable

class ILTestProcessor20182019PARCCIAR < GS::ETL::TestProcessor
	
	def initialize(*args)
		super
		@year = 2019
	end

	map_breakdown_id = {
		'All' => 1,
		'American Indian or Alaska Native' => 18,
		'Asian' => 16,
		'Black or African American' => 17,
		'EL' => 32,
		'Female' => 26,
		'Hispanic or Latino' => 19,
		'IEP' => 27,
		'Low Income' => 23,
		'Male' => 25,
		'Native Hawaiian or Other Pacific Islander' => 20,
		'Non-IEP' => 30,
		'Non-Low Income' => 24,
		'Two or More Race' => 22,
		'White' => 21,
		'Children with Disabilities' => 27

	}

	map_proficiency_band_id = {
		'level_1' => 146, #did not meet expectations
		'level_2' => 147, #partially met
		'level_3' => 148, #approached
		'level_4' => 149, #met
		'level_5' => 150, #exceeded
		'prof_and_above' => 1
	}


	map_subject_id = {
		'ELA' => 4,
		'Mathematics' => 5
	}

	# source('il_test.txt',[],col_sep:"\t") do |s|
	# 	s.transform('test data type',Fill,{
	# 	test_data_type_id: 297,
	# 	test_data_type: 'IL PARCC',
	# 	date_valid: '2018-01-01 00:00:00',
	# 	notes: 'DXT-3375: IL PARCC',
	# 	description: 'In 2017-18, students in Illinois took The Partnership for Assessment of Readiness for College and Careers (PARCC). PARCC is the state assessment and accountability measure for Illinois students enrolled in a public school district. PARCC assesses the New Illinois Learning Standards Incorporating the Common Core and will be administered to students in English Language Arts and Mathematics in grades 3-8.'
	# 	})
	# end

	source('il_2018_parcc.txt',[],col_sep:"\t") do |s|
		s.transform('test data type',Fill,{
		test_data_type_id: 297,
		test_data_type: 'IL PARCC',
		date_valid: '2018-01-01 00:00:00',
		notes: 'DXT-3375: IL PARCC',
		description: 'In 2017-18, students in Illinois took The Partnership for Assessment of Readiness for College and Careers (PARCC). PARCC is the state assessment and accountability measure for Illinois students enrolled in a public school district. PARCC assesses the New Illinois Learning Standards Incorporating the Common Core and will be administered to students in English Language Arts and Mathematics in grades 3-8.'
		})
	end

	source('il_2019_iar.txt',[],col_sep:"\t") do |s|
		s.transform('test data type',Fill,{
		test_data_type_id: 490,
		test_data_type: 'IAR',
		date_valid: '2019-01-01 00:00:00',
		notes: 'DXT-3375: IL IAR',
		description: 'In 2018-19, Illinois began using the Illinois Assessment of Readiness (IAR). The IAR is the state assessment and accountability measure for Illinois students enrolled in a public school district. IAR assesses the New Illinois Learning​ Standards Incorporating the Common Core and will be administered in English Language Arts and Mathematics. IAR assessments in English Language Arts and Mathematics will be administered to all students in grades 3-8.'
		})
	end

	shared do |s|
		s.transform('breakdown id',HashLookup,:breakdown,map_breakdown_id,to: :breakdown_id)
		.transform('subject ids',HashLookup,:subject, map_subject_id,to: :subject_id)
		.transform('proficiency band id',HashLookup, :proficiency_band, map_proficiency_band_id,to: :proficiency_band_id)
	end

	def config_hash
		{
		source_id: 17,
		state: 'il'
		}
	end

end

ILTestProcessor20182019PARCCIAR.new(ARGV[0],max:nil,offset:nil).run