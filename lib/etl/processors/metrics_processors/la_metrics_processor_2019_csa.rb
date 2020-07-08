require 'set'
require_relative '../../metrics_processor'

class LAMetricsProcessor2019CSA < GS::ETL::MetricsProcessor

	def initialize(*args)
		super
		@year = 2019
		@ticket_n = 'DXT-3408'
	end

	map_subject_id = {
	'Composite' => 1,
	'NA' => 0
	}

	map_breakdown_id = {
	'All Students' => 1,
	'overall_cohort_grad' => 1,
	'american_indianalaskan_native' => 18,
	'asian' => 16,
	'blackafrican_american' => 17,
	'hispanic' => 19,
	'white' => 21,
	'native_hawaiianpacific_islander' => 20,
	'multirace' => 22,
	'economically_disadvantaged' => 23,
	'students_with_disabilities'=> 27,
	'english_learner' => 32,
	'total_students' => 1,
	'all_students' => 1,
	'male' => 25,
	'female' => 26,
	'raceethnicity_white' => 21,
	'raceethnicity_black' => 17,
	'raceethnicity_american_indian' => 18,
	'raceethnicity_american_indianalaska_native' => 18,
	'raceethnicity_asian' => 16,
	'raceethnicity_hispanic' => 19,
	'raceethnicity_native_hawaiianpacific_islander' => 20,
	'raceethnicity_native_hawaiianother_pacific_islander' => 20,
	'raceethnicity_multirace' => 22,
	'raceethnicity_multiple_racesethnicities' => 22,
	'english_learners' => 32
	}

	map_grade = {
	448 => 'All',
	443 => 'NA',
	412 => 'NA',
	409 => 'NA'
	}

	source('school_act_summary.txt',[],col_sep:"\t") do |s|
	s.transform('Fill missing default fields', Fill, {
		data_type: 'ACT average score',
		data_type_id: 448,
		subject: 'Composite',
		year: 2019,
		cohort_count: 'NULL',
		breakdown: 'All Students',
		entity_type: 'school'
	})
	.transform('rename columns',MultiFieldRenamer, {
		lea_name: :district_name,
		site_code: :school_id,
		site_name: :school_name,
		x_20182019_act_composite_score: :value
	})
	.transform('Create state_id field', WithBlock) do |row|
		row[:state_id] = row[:school_id]
		row
	end
	end
	source('state_district_act_summary.txt',[],col_sep:"\t") do |s|
	s.transform('Fill missing default fields', Fill, {
		data_type: 'ACT average score',
		data_type_id: 448,
		subject: 'Composite',
		year: 2019,
		cohort_count: 'NULL',
		breakdown: 'All Students'
	})
	.transform('rename columns',MultiFieldRenamer, {
		lea_code: :district_id,
		lea_name: :district_name,
		x_20182019_act_composite_score: :value
	})
	.transform('Create state id and entity field', WithBlock) do |row|
		if row[:district_id] == 'LA'
			row[:entity_type] = 'state'
			row[:state_id] = 'state'
		elsif row[:district_id] != 'LA'
			row[:entity_type] = 'district'
			row[:state_id] = row[:district_id]
		else
			row[:entity_type] = 'Error'
			row[:state_id] = 'Error'
		end
		row
	end
	end
	source('2018-state-school-system-and-school-cohort-grad-rates-by-ethnicity.txt',[],col_sep:"\t") do |s|
	s.transform('Fill missing default fields', Fill, {
		data_type: 'graduation rate',
		data_type_id: 443,
		subject: 'NA',
		year: '2018',
		cohort_count: 'NULL'
	})
	.transform('rename columns',MultiFieldRenamer, {
		schoolschool_system_code: :entity_id,
		schoolschool_system_name: :entity_name
	})
	.transform('Transpose wide subgroups', 
	Transposer, 
		:datatype_subgroup,:value,
		:overall_cohort_grad_rate,:american_indianalaskan_native_rate,
		:asian_rate,:blackafrican_american_rate,:hispanic_rate,:white_rate,
		:native_hawaiianpacific_islander_rate,:multirace_rate,
		:economically_disadvantaged_rate,:students_with_disabilities_rate,
		:english_learner_rate
	)
	.transform('Assign entity type and state id field', WithBlock) do |row|
		if row[:entity_id].to_s.length == 2
			row[:entity_type] = 'state'
			row[:state_id] = 'state'
			row[:district_id] = row[:entity_id]
			row[:school_id] = 'state'
			row[:district_name] = 'state'
			row[:school_name] = 'state'
		elsif row[:entity_id].to_s.length == 3
			row[:entity_type] = 'district'
			row[:state_id] = row[:entity_id]
			row[:district_id] = row[:entity_id]
			row[:school_id] = 'all schools'
			row[:district_name] = row[:entity_name]
			row[:school_name] = 'all schools'
		elsif row[:entity_id].to_s.length == 6
			row[:entity_type] = 'school'
			row[:state_id] = row[:entity_id]
			row[:district_id] = row[:entity_id].to_s[0,2]
			row[:school_id] = row[:entity_id]
			row[:district_name] = 'district'
			row[:school_name] = row[:entity_name]
		else
			row[:state_id] = 'Error'
			row[:entity_type] = 'Error'
			row[:district_id] = 'Error'
			row[:school_id] = 'Error'
		end
		row
	end
	end
	source('2017-2018-college-enrollment-with-subgroups.txt',[],col_sep:"\t") do |s|
	s.transform('Fill missing default fields', Fill, {
		data_type: 'college enrollment',
		data_type_id: 412,
		year: 2018,
		subject: 'NA',
		cohort_count: 'NULL'
	})
	.transform('rename columns',MultiFieldRenamer, {
		code: :entity_id,
		name: :entity_name
	})
	.transform('Transpose wide subgroups', 
	Transposer, 
		:datatype_subgroup,:value,
		:total_students_enrolled_,:male_enrolled_,
		:female_enrolled_,:raceethnicity_white_enrolled_,
		:raceethnicity_black_enrolled_,:raceethnicity_american_indian_enrolled_,
		:raceethnicity_asian_enrolled_,:raceethnicity_hispanic_enrolled_,
		:raceethnicity_native_hawaiianpacific_islander_enrolled_,
		:raceethnicity_multirace_enrolled_,:students_with_disabilities_enrolled_,
		:english_learners_enrolled_,:economically_disadvantaged_enrolled_
	)
	.transform('Assign entity type and state_id', WithBlock) do |row|
		if row[:entity_id].to_s.length == 3
			if row[:entity_id] == '000'
				row[:entity_type] = 'state'
				row[:state_id] = 'state'
				row[:district_id] = row[:entity_id]
				row[:school_id] = 'state'
				row[:district_name] = 'state'
				row[:school_name] = 'state'
			elsif row[:entity_id] != '000'
				row[:entity_type] = 'district'
				row[:state_id] = row[:entity_id]
				row[:district_id] = row[:entity_id]
				row[:school_id] = 'all schools'
				row[:district_name] = row[:entity_name]
				row[:school_name] = 'all schools'
			end
		elsif row[:entity_id].to_s.length == 6
			row[:entity_type] = 'school'
			row[:state_id] = row[:entity_id]
			row[:district_id] = row[:entity_id].to_s[0,3]
			row[:school_id] = row[:entity_id]
			row[:district_name] = 'district'
			row[:school_name] = row[:entity_name]
		else
			row[:entity_type] = 'Error'
			row[:state_id] = 'Error'
			row[:district_id] = 'Error'
			row[:school_id] = 'Error'
			row[:district_name] = 'Error'
			row[:school_name] = 'Error'
		end
		row
	end
	end
	source('2016-2017-college-persistence-with-subgroups.txt',[],col_sep:"\t") do |s|
	s.transform('Fill missing default fields', Fill, {
		data_type: 'college persistence',
		data_type_id: 409,
		subject: 'NA',
		year: 2018,
		cohort_count: 'NULL'
	})
	.transform('rename columns',MultiFieldRenamer, {
		school_systemsite_code: :entity_id,
		school_systemsite_name: :entity_name
	})
	.transform('Transpose wide subgroups', 
	Transposer, 
		:datatype_subgroup,:value,
		:all_students__persisted,
		:male__persisted,:female__persisted,
		:raceethnicity_white__persisted,:raceethnicity_black__persisted,
		:raceethnicity_american_indianalaska_native__persisted,:raceethnicity_asian__persisted,
		:raceethnicity_hispanic__persisted,:raceethnicity_native_hawaiianother_pacific_islander__persisted,
		:raceethnicity_multiple_racesethnicities__persisted,
		:students_with_disabilities__persisted,:english_learner__persisted,
		:economically_disadvantaged__persisted
	)
	.transform('Assign entity type and state_id', WithBlock) do |row|
		if row[:entity_id].to_s.length == 3
			if row[:entity_id] == '000'
				row[:entity_type] = 'state'
				row[:state_id] = 'state'
				row[:district_id] = row[:entity_id]
				row[:school_id] = 'state'
				row[:district_name] = 'state'
				row[:school_name] = 'state'
			elsif row[:entity_id] != '000'
				row[:entity_type] = 'district'
				row[:state_id] = row[:entity_id]
				row[:district_id] = row[:entity_id]
				row[:school_id] = 'all schools'
				row[:district_name] = row[:entity_name]
				row[:school_name] = 'all schools'
			end
		elsif row[:entity_id].to_s.length == 6
			row[:entity_type] = 'school'
			row[:state_id] = row[:entity_id]
			row[:district_id] = row[:entity_id].to_s[0,3]
			row[:school_id] = row[:entity_id]
			row[:district_name] = 'district'
			row[:school_name] = row[:entity_name]
		else
			row[:entity_type] = 'Error'
			row[:state_id] = 'Error'
			row[:district_id] = 'Error'
			row[:school_id] = 'Error'
			row[:district_name] = 'Error'
			row[:school_name] = 'Error'
		end
		row
	end
	end

	shared do |s|
		s.transform('fill other columns',Fill,{
			notes: 'DXT-3408: LA CSA',
			breakdown_id: 'placeholder'
		})
		.transform('Create date_valid based on year', WithBlock) do |row|
			if [2019,'2019'].include? row[:year]
				row[:date_valid] = '2019-01-01 00:00:00'
			elsif [2018,'2018','2017-2018'].include? row[:year]
				row[:date_valid] = '2018-01-01 00:00:00'
			else
				row[:date_valid] = 'Error'
			end
			row
		end
		.transform('Adjust transposed breakdowns', WithBlock) do |row|
			if row[:data_type] == 'graduation rate'
				m = row[:datatype_subgroup].to_s.match /^(.*)_rate$/
				row[:breakdown] = m[1]
			elsif row[:data_type] == 'college enrollment'
				m = row[:datatype_subgroup].to_s.match /^(.*)_enrolled_$/
				row[:breakdown] = m[1]
			elsif row[:data_type] == 'college persistence'
				m = row[:datatype_subgroup].to_s.match /^(.*)__persisted$/
				row[:breakdown] = m[1]
			end
			row
		end
		.transform('Adjust state ids', WithBlock) do |row|
			if row[:state_id] == 'R36'
				row[:state_id] = '036'
			elsif row[:state_id] == 'R17'
				row[:state_id] = 'Skip'
			elsif row[:state_id] == 'W4B001'
				row[:state_id] = '328002'
			elsif row[:state_id] == 'W5B001'
				row[:state_id] = '3B5001'
			elsif row[:state_id] == 'WAL001'
				row[:state_id] = '349001'
			elsif row[:state_id] == 'WBB001'
				row[:state_id] = '036043'
			elsif row[:state_id] == 'WBD001'
				row[:state_id] = '036064'
			elsif row[:state_id] == 'WBE001'
				row[:state_id] = '036079'
			elsif row[:state_id] == 'WBF001'
				row[:state_id] = '036096'
			elsif row[:state_id] == 'WBI001'
				row[:state_id] = '036163'
			elsif row[:state_id] == '311002'
				row[:state_id] = '017109'
			elsif row[:state_id] == 'W6A001'
				row[:state_id] = '066014'
			end
			row
		end
		.transform('remove "~" value rows', DeleteRows, :value, '~')
		.transform('remove "NR" value rows', DeleteRows, :value, 'NR')
		.transform('remove "n/a" value rows', DeleteRows, :value, 'n/a')
		.transform('remove "Skip" value rows', DeleteRows, :state_id, 'Skip')
		.transform('map breakdown ids',HashLookup,:breakdown, map_breakdown_id,to: :breakdown_id)
		.transform('map subject ids',HashLookup,:subject, map_subject_id,to: :subject_id)
		.transform('map grades',HashLookup,:data_type_id, map_grade,to: :grade)
	end

	def config_hash
	{
		source_id: 22,
		state: 'la'
	}
	end
end

LAMetricsProcessor2019CSA.new(ARGV[0],max:nil).run