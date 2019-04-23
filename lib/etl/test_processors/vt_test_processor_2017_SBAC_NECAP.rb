require_relative "../test_processor"
GS::ETL::Logging.disable

class VTTestProcessor2017SBAC_NECAP < GS::ETL::TestProcessor
	
	def initialize(*args)
		super
		@year = 2017
	end

	map_breakdown_gsdata_id = {
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


	map_academic_gsdata_id = {
		'SB English Language Arts ' => 4,
		'SB Math ' => 5,
		'NECAP Science ' => 19
	}
	
	map_prof_band_id = {
		level_4_proficient_with_distinction: 8, 
		level_3_proficient: 7, 
		level_2_partially_proficient: 6, 
		level_1_substantially_below_proficient: 5,
		prof_and_above: 1
	}

	# source('VT_2016_sbac_school_ind.txt',[],col_sep:"\t") do |s|
	# 	s.transform('rename fields',MultiFieldRenamer,{
	# 		group: :breakdown,
	# 		n: :number_tested,
	# 		total_proficient_and_above: :value_float})
	# 	.transform('',WithBlock,) do |row|
	# 		#require 'byebug'
	# 		#byebug
	# 		row
	# 	end
	# 	.transform('remove rows with blank or 0 ntested',DeleteRows,:number_tested,nil,'0')
	# 	.transform('remove migrant and not migrant',DeleteRows,:breakdown,'Migrant','Not Migrant')
	# 	.transform('subject and grade',WithBlock,) do |row|
	# 		row[:subject],row[:grade] = row[:test_name].split('Grade')
	# 		row[:state_id] = row[:school_id]
	# 		row
	# 	end
	# 	.transform('entity level',Fill,{
	# 		entity_level: 'school',
	# 		test_data_type: 'sbac',
	# 		gsdata_test_data_type_id: 253,
	# 		proficiency_band: 'prof_null',
	# 		proficiency_band_id: 'null'
	# 		})
	# end
	
			
	# source('VT_2016_sbac_school_public.txt',[],col_sep:"\t") do |s|
	# 	s.transform('rename fields',MultiFieldRenamer,{
	# 	#school_id: :state_id,
	# 	lea_id: :district_id,
	# 	lea_name: :district_name,
	# 	group: :breakdown,
	# 	n: :number_tested,
	# 	total_proficient_and_above: :value_float})
	# 	.transform('',WithBlock,) do |row|
	# 		#require 'byebug'
	# 		#byebug
	# 		row
	# 	end
	# 	.transform('remove rows with blank or 0 ntested',DeleteRows,:number_tested,nil,'0')
	# 	.transform('remove migrant and not migrant',DeleteRows,:breakdown,'Migrant','Not Migrant')
	# 	.transform('subject and grade',WithBlock,) do |row|
	# 		row[:subject],row[:grade] = row[:test_name].split('Grade')
	# 		row[:state_id] = row[:school_id]
	# 		row
	# 	end
	# 	.transform('entity level',Fill,{
	# 		entity_level: 'school',
	# 		test_data_type: 'sbac',
	# 		gsdata_test_data_type_id: 253,
	# 		proficiency_band: 'prof_null',
	# 		proficiency_band_id: 'null'
	# 		})

	# end

	# source('VT_2016-science-necap_school.txt',[],col_sep:"\t") do |s|
	# 	s.transform('rename fields',MultiFieldRenamer,{
	# 	psid: :state_id,
	# 	leaid: :district_id,
	# 	leaname: :district_name,
	# 	group: :breakdown,
	# 	n: :number_tested,
	# 	})
	# 	.transform('',WithBlock,) do |row|
	# 		#require 'byebug'
	# 		#byebug
	# 		unless row[:disaggregate] == 'Disability' && row[:breakdown] == 'All Students'
	# 			row
	# 		end
	# 	end
	# 	.transform('remove rows with blank or 0 ntested',DeleteRows,:number_tested,nil,'0')
	# 	.transform('remove migrant and not migrant',DeleteRows,:breakdown,'Migrant','Not Migrant')
	# 	.transform('subject and grade',WithBlock,) do |row|
	# 		row[:subject],row[:grade] = row[:test_name].split('Grade')
	# 		row[:school_id] = row[:state_id]
	# 		row
	# 	end
	# 	.transform('prof and above',SumValues,:proficiency_and_above,:level_4_proficient_with_distinction,:level_3_proficient)
	# 	.transform('transpose prof bands',Transposer,:proficiency_band,:value_float,:prof_null,:level_4_proficient_with_distinction,:level_3_proficient,:level_2_partially_proficient,:level_1_substantially_below_proficient)
	# 	.transform('map prof band id',HashLookup,:proficiency_band, map_prof_band_id,to: :proficiency_band_id)
	# 	.transform('entity level',Fill,{
	# 		entity_level: 'school',
	# 		test_data_type: 'necap',
	# 		gsdata_test_data_type_id: 95,
	# 		})
	# end

	source('VT_2017_NECAP_STATE.txt',[],col_sep:"\t") do |s|
		s.transform('rename fields',MultiFieldRenamer,{
		disaggregate: :breakdown,
		n: :number_tested,
		})
		.transform('',WithBlock,) do |row|
			#require 'byebug'
			#byebug
			row
		end	
		.transform('',WithBlock,) do |row|
			unless row[:disaggregate] == 'Disability' && row[:breakdown] == 'All Students'
				row
			end
		end
		.transform('remove rows with blank or 0 ntested',DeleteRows,:number_tested,nil,'0')
		.transform('remove migrant and not migrant',DeleteRows,:breakdown,'Migrant','Not Migrant')
		.transform('subject and grade',WithBlock,) do |row|
			row[:subject],row[:grade] = row[:test_name].split('Grade')
			row[:school_id] = row[:state_id]
			row
		end
		.transform('prof and above',SumValues,:proficiency_and_above,:level_4_proficient_with_distinction,:level_3_proficient)
		.transform('transpose prof bands',Transposer,:proficiency_band,:value_float,:prof_null,:level_4_proficient_with_distinction,:level_3_proficient,:level_2_partially_proficient,:level_1_substantially_below_proficient)
		.transform('map prof band id',HashLookup,:proficiency_band, map_prof_band_id,to: :proficiency_band_id)
		.transform('entity level',Fill,{
			entity_level: 'state',
			test_data_type: 'necap',
			gsdata_test_data_type_id: 191,
			})

	end

	source('VT_2017_SBAC_STATE.txt',[],col_sep:"\t") do |s|
		s.transform('rename fields',MultiFieldRenamer,{
		group: :breakdown,
		n: :number_tested,
		total_proficient_and_above: :value_float})
		.transform('',WithBlock,) do |row|
			#require 'byebug'
			#byebug
			row
		end
		.transform('remove rows with blank or 0 ntested',DeleteRows,:number_tested,nil,'0')
		.transform('remove migrant and not migrant',DeleteRows,:breakdown,'Migrant','Not Migrant')
		.transform('subject and grade',WithBlock,) do |row|
			row[:subject],row[:grade] = row[:test_name].split('Grade')
			row
		end
		.transform('entity level',Fill,{
			entity_level: 'state',
			test_data_type: 'sbac',
			gsdata_test_data_type_id: 218,
			proficiency_band: 'proficiency_and_above',
			proficiency_band_id: 1
			})

	end

	shared do |s|
		s.transform('',Fill,{
			entity_type: 'public,charter',
			level_code: 'e,m,h',
			year: 2017
		})
		.transform('',WithBlock,) do |row|
			#require 'byebug'
			#byebug
			row[:value_float] = row[:value_float].to_s.gsub('%','')
			row[:grade] = row[:grade].to_s.sub(/^[ 0]+/,'')
			row
		end
		.transform('breakdowns',HashLookup,:breakdown,map_breakdown_gsdata_id,to: :breakdown_gsdata_id)
		.transform('subject',HashLookup,:subject, map_academic_gsdata_id, to: :academic_gsdata_id)
	end

	def config_hash
		{
		source_id: 50,
		state: 'vt',
		notes: 'DXT-3080 VT SBAC, NECAP 2017',
		url: 'https://education.vermont.gov/documents/data-smarter-balanced-state-school-level-2017',
		file: 'vt/2017/vt.2017.1.public.charter.[level].txt',
		level: nil,
		school_type: 'public,charter'
		}
	end

end

VTTestProcessor2017SBAC_NECAP.new(ARGV[0],max:nil,offset:nil).run
