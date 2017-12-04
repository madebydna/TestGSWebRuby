require_relative "../test_processor"
GS::ETL::Logging.disable

class VTTestProcessor2016SBAC_NECAP < GS::ETL::TestProcessor
	
	def initialize(*args)
		super
		@year = 2016
	end

	map_breakdown_id = {
		'All Students' => 1,
		'No Special Ed' => 14,
		'Not ELL' => 16,
		'Not FRL' => 10,
		'Female' => 11,
		'American Indian or Alaskan Native' => 4,
		'Special Ed' => 13,
		'ELL' => 15,
		'FRL' => 9,
		'Male' => 12,
		'Asian' => 2,
		'Black' => 3,
		'Hispanic' => 6,
		'Native Hawaiian or Pacific Islander' => 112,
		'White' =>8
	}


	map_subject_id = {
		'SB English Language Arts ' => 4,
		'SB Math ' => 5,
		'NECAP Science ' => 25
	}
	
	map_prof_band_id = {
		level_4_proficient_with_distinction: 146, 
		level_3_proficient: 145, 
		level_2_partially_proficient: 144, 
		level_1_substantially_below_proficient: 143,
		prof_null: 'null'
	}

	source('VT_2016_sbac_school_ind.txt',[],col_sep:"\t") do |s|
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
			row[:state_id] = row[:school_id]
			row
		end
		.transform('entity level',Fill,{
			entity_level: 'school',
			test_data_type: 'sbac',
			test_data_type_id: 253,
			proficiency_band: 'prof_null',
			proficiency_band_id: 'null'
			})
	end
	
			
	source('VT_2016_sbac_school_public.txt',[],col_sep:"\t") do |s|
		s.transform('rename fields',MultiFieldRenamer,{
		#school_id: :state_id,
		lea_id: :district_id,
		lea_name: :district_name,
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
			row[:state_id] = row[:school_id]
			row
		end
		.transform('entity level',Fill,{
			entity_level: 'school',
			test_data_type: 'sbac',
			test_data_type_id: 253,
			proficiency_band: 'prof_null',
			proficiency_band_id: 'null'
			})

	end

	source('VT_2016-science-necap_school.txt',[],col_sep:"\t") do |s|
		s.transform('rename fields',MultiFieldRenamer,{
		psid: :state_id,
		leaid: :district_id,
		leaname: :district_name,
		group: :breakdown,
		n: :number_tested,
		})
		.transform('',WithBlock,) do |row|
			#require 'byebug'
			#byebug
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
		.transform('null prof band',SumValues,:prof_null,:level_4_proficient_with_distinction,:level_3_proficient)
		.transform('transpose prof bands',Transposer,:proficiency_band,:value_float,:prof_null,:level_4_proficient_with_distinction,:level_3_proficient,:level_2_partially_proficient,:level_1_substantially_below_proficient)
		.transform('map prof band id',HashLookup,:proficiency_band, map_prof_band_id,to: :proficiency_band_id)
		.transform('entity level',Fill,{
			entity_level: 'school',
			test_data_type: 'necap',
			test_data_type_id: 95,
			})
	end

	source('VT_2016-science-necap_state.txt',[],col_sep:"\t") do |s|
		s.transform('rename fields',MultiFieldRenamer,{
		group: :breakdown,
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
		.transform('null prof band',SumValues,:prof_null,:level_4_proficient_with_distinction,:level_3_proficient)
		.transform('transpose prof bands',Transposer,:proficiency_band,:value_float,:prof_null,:level_4_proficient_with_distinction,:level_3_proficient,:level_2_partially_proficient,:level_1_substantially_below_proficient)
		.transform('map prof band id',HashLookup,:proficiency_band, map_prof_band_id,to: :proficiency_band_id)
		.transform('entity level',Fill,{
			entity_level: 'state',
			test_data_type: 'necap',
			test_data_type_id: 95,
			})

	end

	source('VT_2016_sbac_state.txt',[],col_sep:"\t") do |s|
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
			test_data_type_id: 253,
			proficiency_band: 'prof_null',
			proficiency_band_id: 'null'
			})

	end

	shared do |s|
		s.transform('',Fill,{
			entity_type: 'public,charter',
			level_code: 'e,m,h',
			year: 2016
		})
		.transform('',WithBlock,) do |row|
			#require 'byebug'
			#byebug
			row[:value_float] = row[:value_float].to_s.gsub('%','')
			row[:grade] = row[:grade].to_s.sub(/^[ 0]+/,'')
			row
		end
		.transform('breakdowns',HashLookup,:breakdown,map_breakdown_id,to: :breakdown_id)
		.transform('subject',HashLookup,:subject, map_subject_id, to: :subject_id)
	end

	def config_hash
		{
		source_id: 47,
		state: 'vt',
		notes: 'DXT-2149 VT SBAC, NECAP 2016',
		url: 'http://education.vermont.gov/documents/data-smarter-balanced-state-school-level-2016',
		file: 'vt/2016/vt.2016.1.public.charter.[level].txt',
		level: nil,
		school_type: 'public,charter'
		}
	end

end

VTTestProcessor2016SBAC_NECAP.new(ARGV[0],max:nil,offset:nil).run
