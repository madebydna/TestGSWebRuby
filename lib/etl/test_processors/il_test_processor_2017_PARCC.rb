require_relative "../test_processor"
GS::ETL::Logging.disable

class ILTestProcessor2017PARCC < GS::ETL::TestProcessor
	
	def initialize(*args)
		super
		@year = 2017
	end

	map_breakdown_id = {
	'All' => 1,
	'Male' => 12,
	'Female' => 11,
	'Black' => 3,
	'White' => 8,
	'Hispanic' => 6,
	'IEP' => 13,
	'Non-IEP' => 14,
	'EconDis' => 9,
	'Non-EconDis' => 10,
	'Multi' => 21,
	'Asian' => 2,
	'LEP' => 15,
	'NativeAmeri' => 4,
	'HawaiianOthers' => 112
	}

	map_gsdata_breakdown_id = {
	'All' => 1,
	'Male' => 25,
	'Female' => 26,
	'Black' => 17,
	'White' => 21,
	'Hispanic' => 19,
	'IEP' => 27,
	'Non-IEP' => 30,
	'EconDis' => 23,
	'Non-EconDis' => 24,
	'Multi' => 22,
	'Asian' => 16,
	'LEP' => 32,
	'NativeAmeri' => 18,
	'HawaiianOthers' => 20
	}

	map_proficiency_band_id = {
	'notmet' => 214,
	'partiallymet' => 215,
	'approached' => 216,
	'met' => 217,
	'exceeded' => 218,
	'null' => 'null'
	}

	map_gsdata_proficiency_band_id = {
	'notmet' => 146,
	'partiallymet' => 147,
	'approached' => 148,
	'met' => 149,
	'exceeded' => 150,
	'null' => 1
	}

	map_subject_id = {
	'ELA' => 4,
	'Math' => 5
	}

	map_gsdata_academic_id = {
	'ELA' => 4,
	'Math' => 5
	}

	source('il_state.txt',[],col_sep:"\t") do |s|
		s.transform('data type',Fill,{
		entity_level: 'state'
		})
	end

	source('il_district.txt',[],col_sep:"\t") do |s|
		s.transform('data type',Fill,{
		entity_level: 'district'
		})
	end

	source('il_school.txt',[],col_sep:"\t") do |s|
		s.transform('data type',Fill,{
		entity_level: 'school'
		})
	end

	shared do |s|
		s.transform('breakdown id',HashLookup,:breakdown,map_breakdown_id,to: :breakdown_id)
		.transform('breakdown id',HashLookup,:breakdown,map_gsdata_breakdown_id,to: :breakdown_gsdata_id)
		.transform('subject ids',HashLookup,:subject, map_subject_id,to: :subject_id)
		.transform('academic ids',HashLookup,:subject, map_gsdata_academic_id,to: :academic_gsdata_id)
		.transform('proficiency band id',HashLookup, :proficiency_band, map_proficiency_band_id,to: :proficiency_band_id)
		.transform('proficiency band id',HashLookup, :proficiency_band, map_gsdata_proficiency_band_id,to: :proficiency_band_gsdata_id)
		.transform('',Fill,{
			year: 2017,
			entity_type: 'public,charter',
			level_code: 'e,m,h',
			test_data_type: 'IL PARCC',
			test_data_type_id: 303,
			gsdata_test_data_type_id: 297,
			notes: 'DXT-2493: IL PARCC',
			description: 'In 2016-2017, students in Illinois took The Partnership for Assessment of Readiness for College and Careers (PARCC). PARCC is the state assessment and accountability measure for Illinois students enrolled in a public school district. PARCC assesses the New Illinois Learning Standards Incorporating the Common Core and will be administered to students in English Language Arts and Mathematics.'
		})
		.transform('rename columns',MultiFieldRenamer,{
			value: :value_float
		})
		.transform('fix grade all',WithBlock) do |row|
			if row[:grade] == 'TOT'
				row[:grade] = 'All'
			else
				row[:grade]
			end
			row
		end
	end

	def config_hash
		{
		source_id: 3,
		source_name: "Illinois State Board of Education",
		date_valid: '2017-01-01 00:00:00',
		state: 'il',
		url: 'http://www.isbe.net',
		file: 'il/2017/il.2017.1.public.charter.[level].txt',
		level: nil,
		school_type: 'public,charter'
		}
	end

end

ILTestProcessor2017PARCC.new(ARGV[0],max:nil,offset:nil).run
