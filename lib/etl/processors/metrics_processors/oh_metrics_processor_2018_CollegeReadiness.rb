require_relative '../../metrics_processor'

class OHMetricsProcessor2018CollegeReadiness < GS::ETL::MetricsProcessor

	def initialize(*args)
		super
		@year = 2018
		@ticket_n = 'DXT-3388'
	end

	map_breakdown_id = {
		#grad, ACT,SAT breakdown
		'All Students' => 1,
		#grad breakdowns
		'NOTDISABLED' => 30,
		'DISABLED' => 27,
		'NOTECONDISADV' => 24,
		'ECONDISADV' => 23,
		'MALE' => 25,
		'FEMALE' => 26,
		'NOTENGLEARN' => 33,
		'ENGLEARN' => 32,
		'WHITE' => 21,
		'HISPANIC' => 19,
		'INDIAN' => 18,
		'MULTIRACIAL' => 22,
		'BLACK' => 17,
		'ASIAN' => 15,
		#ACT, SAT breakdowns
		'American Indian/Alaskan Native' => 18,
		'Asian/Pacific Islander' => 15,
		'"Black, Non-Hispanic"' => 17,
		'Hispanic' => 19,
		'Multiracial' => 22,
		'"White, Non-Hispanic"' => 21,
		'Female' => 26,
		'Male' => 25,
		'Economically Disadvantaged' => 23,
		'English Learners' => 32,
		'Students with Disabilities' => 27
	}

	map_subject_id = {
		#grad
		'NA' => 0,
		#ACT, SAT
		'Composite' => 1
	}

	map_grade = {
		443 => 'NA',
		396 => 'All',
		454 => 'All',
		439 => 'All',
		442 => 'All'
	}

#grad files
#state level
	source('4-Year Longitudinal Graduation Rate (State).txt',[],col_sep:"\t") do |s|
	s.transform('Fill missing default fields', Fill, {
		entity_type: 'state',
		data_type: 'graduation rate',
		data_type_id: 443,
		breakdown: 'All Students',
		district_id: 'state',
		district_name: 'state',
		school_id: 'state',
		school_name: 'state'
	})
	end
#school level
	source('1819_BUILDING_GRAD_RATE.txt',[],col_sep:"\t") do |s|
	s.transform('Fill missing default fields', Fill, {
		entity_type: 'school',
		data_type: 'graduation rate',
		data_type_id: 443,
		breakdown: 'All Students'
	})
	end
	source('BUILDING_DISABLED_1819.txt',[],col_sep:"\t") do |s|
	s.transform('Fill missing default fields', Fill, {
		entity_type: 'school',
		data_type: 'graduation rate',
		data_type_id: 443,
		cohort_count: 'NULL'
	})
	end
	source('BUILDING_ECON_DIS_1819.txt',[],col_sep:"\t") do |s|
	s.transform('Fill missing default fields', Fill, {
		entity_type: 'school',
		data_type: 'graduation rate',
		data_type_id: 443,
		cohort_count: 'NULL'
	})
	end
	source('BUILDING_ETHNIC_1819.txt',[],col_sep:"\t") do |s|
	s.transform('Fill missing default fields', Fill, {
		entity_type: 'school',
		data_type: 'graduation rate',
		data_type_id: 443,
		cohort_count: 'NULL'
	})
	end
	source('BUILDING_GENDER_1819.txt',[],col_sep:"\t") do |s|
	s.transform('Fill missing default fields', Fill, {
		entity_type: 'school',
		data_type: 'graduation rate',
		data_type_id: 443,
		cohort_count: 'NULL'
	})
	end
	source('BUILDING_LEP_1819.txt',[],col_sep:"\t") do |s|
	s.transform('Fill missing default fields', Fill, {
		entity_type: 'school',
		data_type: 'graduation rate',
		data_type_id: 443,
		cohort_count: 'NULL'
	})
	end

#district level
	source('1819_DISTRICT_GRAD_RATE.txt',[],col_sep:"\t") do |s|
	s.transform('Fill missing default fields', Fill, {
		entity_type: 'district',
		data_type: 'graduation rate',
		data_type_id: 443,
		breakdown: 'All Students'
	})
	end
	source('1819_dist_disabled_DIS.txt',[],col_sep:"\t") do |s|
	s.transform('Fill missing default fields', Fill, {
		entity_type: 'district',
		data_type: 'graduation rate',
		data_type_id: 443,
		cohort_count: 'NULL'
	})
	end
	source('1819_dist_econ_DIS.txt',[],col_sep:"\t") do |s|
	s.transform('Fill missing default fields', Fill, {
		entity_type: 'district',
		data_type: 'graduation rate',
		data_type_id: 443,
		cohort_count: 'NULL'
	})
	end
	source('1819_dist_race_DIS.txt',[],col_sep:"\t") do |s|
	s.transform('Fill missing default fields', Fill, {
		entity_type: 'district',
		data_type: 'graduation rate',
		data_type_id: 443,
		cohort_count: 'NULL'
	})
	end
	source('1819_dist_gender_DIS.txt',[],col_sep:"\t") do |s|
	s.transform('Fill missing default fields', Fill, {
		entity_type: 'district',
		data_type: 'graduation rate',
		data_type_id: 443,
		cohort_count: 'NULL'
	})
	end
	source('1819_dist_LEP_DIS.txt',[],col_sep:"\t") do |s|
	s.transform('Fill missing default fields', Fill, {
		entity_type: 'district',
		data_type: 'graduation rate',
		data_type_id: 443,
		cohort_count: 'NULL'
	})
	end

#ACT/SAT files
	source('STATE_PFS_2019.txt',[],col_sep:"\t") do |s|
	s.transform('Fill missing default fields', Fill, {
		entity_type: 'state'
	})
	.transform('rename columns',MultiFieldRenamer, {
		prepared_for_success_denominator: :cohort_count,
		disaggregation: :breakdown
	})
	.transform('Transpose wide college data types into long',
	Transposer,
		:data_type,:value,
		:percent_of_students_taking_act_test,
		:percent_of_students_remediation_free_on_act,
		:percent_of_students_taking_sat_test,
		:percent_of_students_remediation_free_on_sat
		)
	.transform('Create data_type_id', WithBlock) do |row|
		if row[:data_type] == :percent_of_students_taking_act_test
			row[:data_type_id] = 396
		elsif row[:data_type] == :percent_of_students_remediation_free_on_act
			row[:data_type_id] = 454
		elsif row[:data_type] == :percent_of_students_taking_sat_test
			row[:data_type_id] = 439
		elsif row[:data_type] == :percent_of_students_remediation_free_on_sat
			row[:data_type_id] = 442
		end
		row
	end
	end
	source('DISTRICT_PFS_1819.txt',[],col_sep:"\t") do |s|
	s.transform('Fill missing default fields', Fill, {
		entity_type: 'district',
		breakdown: 'All Students'
	})
	.transform('rename columns',MultiFieldRenamer, {
		prepared_for_success_denominator_2018_4_year2017_5_year_graduate_cohorts: :cohort_count
	})
	.transform('Transpose wide college data types into long',
	Transposer,
		:data_type,:value,
		:percent_of_students_taking_act_test,
		:percent_of_students_remediation_free_on_act,
		:percent_of_students_taking_sat_test,
		:percent_of_students_remediation_free_on_sat
		)
	.transform('Create data_type_id', WithBlock) do |row|
		if row[:data_type] == :percent_of_students_taking_act_test
			row[:data_type_id] = 396
		elsif row[:data_type] == :percent_of_students_remediation_free_on_act
			row[:data_type_id] = 454
		elsif row[:data_type] == :percent_of_students_taking_sat_test
			row[:data_type_id] = 439
		elsif row[:data_type] == :percent_of_students_remediation_free_on_sat
			row[:data_type_id] = 442
		end
		row
	end
	end
	source('BUILDING_PFS_1819.txt',[],col_sep:"\t") do |s|
	s.transform('Fill missing default fields', Fill, {
		entity_type: 'school',
		breakdown: 'All Students'
	})
	.transform('rename columns',MultiFieldRenamer, {
		prepared_for_success_denominator_2018_4_year2017_5_year_graduate_cohorts: :cohort_count
	})
	.transform('Transpose wide college data types into long',
	Transposer,
		:data_type,:value,
		:percent_of_students_taking_act_test,
		:percent_of_students_remediation_free_on_act,
		:percent_of_students_taking_sat_test,
		:percent_of_students_remediation_free_on_sat
		)
	.transform('Create data_type_id', WithBlock) do |row|
		if row[:data_type] == :percent_of_students_taking_act_test
			row[:data_type_id] = 396
		elsif row[:data_type] == :percent_of_students_remediation_free_on_act
			row[:data_type_id] = 454
		elsif row[:data_type] == :percent_of_students_taking_sat_test
			row[:data_type_id] = 439
		elsif row[:data_type] == :percent_of_students_remediation_free_on_sat
			row[:data_type_id] = 442
		end
		row
	end
	end

	shared do |s|
		s.transform('fill other columns',Fill,{
			notes: 'DXT-3308: OH College Readiness',
			year: 2018,
			date_valid: '2018-01-01 00:00:00'
		})
		.transform('rename columns',MultiFieldRenamer, {
		district_irn: :district_id,
		building_irn: :school_id,
		building_name: :school_name,
		student_group: :breakdown,
		four_year_graduation_rate_denominator__class_of_2018: :cohort_count,
		four_year_graduation_rate__class_of_2018: :value,
		four_year_graduation_rate_2018: :value
		})
		.transform('Create state id field', WithBlock) do |row|
			if row[:entity_type] == 'school'
				row[:state_id] = row[:school_id].to_s 
			elsif row[:entity_type] == 'district'
				row[:state_id] = row[:district_id]
			elsif row[:entity_type] == 'state'
				row[:state_id] = 'state'
			else 'Error'
			end
			row
		end
		.transform('Assign subject based on data type id', WithBlock) do |row|
			if row[:data_type_id] == 443
				row[:subject] = 'NA'
			elsif [396,454,439,442].include? row[:data_type_id] 
				row[:subject] = 'Composite'
			else
				row[:subject] = 'Error'
			end
			row
		end
		.transform('Remove quotes and commas from cohort count and '%' from value', WithBlock) do |row|
			row[:cohort_count] = row[:cohort_count].to_s.gsub(",","")
			row[:cohort_count] = row[:cohort_count].to_s.gsub("\"","")
			if row[:cohort_count].nil?
				row[:cohort_count] = 'NULL'
			end
			row
		end
		.transform('Create field to skip bad breakdowns', WithBlock) do |row|
			if ['Homeless','Migrant','Foster','Military'].include? row[:breakdown]
				row[:breakdown] = 'Skip'
			else
				row[:breakdown] = row[:breakdown]
			end
			row
		end
		.transform('delete blank values',DeleteRows,:value,nil)
		.transform('delete "NC" values',DeleteRows,:value,'NC')
		.transform('skip bad breakdowns', DeleteRows, :breakdown, 'Skip')
		.transform('map breakdown ids',HashLookup,:breakdown, map_breakdown_id,to: :breakdown_id)
		.transform('map subject ids',HashLookup,:subject, map_subject_id,to: :subject_id)
		.transform('map grades',HashLookup,:data_type_id, map_grade,to: :grade)
	end

	def config_hash
	{
		source_id: 40,
        state: 'oh'
	}
	end
end

OHMetricsProcessor2018CollegeReadiness.new(ARGV[0],max:nil).run