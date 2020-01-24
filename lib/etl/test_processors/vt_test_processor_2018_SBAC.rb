require_relative "../test_processor"

class VTTestProcessor2018SBAC < GS::ETL::TestProcessor
	
	def initialize(*args)
		super
		@year = 2018
	end

	map_breakdown_id = {
		'All Students' => 1,
		'No Special Ed' => 30,
		'Not ELL' => 33,
		'Not FRL' => 24,
		'Female' => 26,
		'American Indian or Alaskan Native' => 18,
		'Special Ed' => 27,
		'ELL' => 32,
		'FRL' => 23,
		'Male' => 25,
		'Asian' => 16,
		'Black' => 17,
		'Hispanic' => 19,
		'Native Hawaiian or Pacific Islander' => 20,
		'White' => 21
	}


	map_subject_id = {
		'English Language Arts ' => 4,
		'Math ' => 5
	}
	
	map_prof_band_id = { 
		'total_proficient_and_above' => 1
	}

	source('vt_2018.txt',[],col_sep:"\t")



	shared do |s|
		s.transform('',Fill,{
        	date_valid: '2018-01-01 00:00:00',
			notes: 'DXT-3377 VT SBAC',
			test_data_type: 'VT SBAC',
         	test_data_type_id: 218, 
			description: 'In 2017-2018, students in Vermont took The Smarter Balanced assessment. This assessment of English Language Arts and Mathematics asks students to demonstrate and apply their knowledge and skills in areas such as critical thinking, analytical writing, and problem solving. The Smarter Balanced assessment is aligned with the Common Core State Standards, uses state of the art computer adaptive testing and accessibility technologies, and provides a continuum of summative, interim and formative tools that can be used for a variety of educational purposes. This assessment tests students in English Language Arts and Mathematics from grades 3 to 9.'
		})
		.transform('map breakdown id',HashLookup,:breakdown,map_breakdown_id, to: :breakdown_id)
		.transform('map subject id',HashLookup,:subject, map_subject_id, to: :subject_id)
		.transform('map prof band id',HashLookup,:proficiency_band, map_prof_band_id,to: :proficiency_band_id)
	end

	def config_hash
		{
		source_id: 50,
		state: 'vt'
		}
	end
end

VTTestProcessor2018SBAC.new(ARGV[0],max:nil,offset:nil).run