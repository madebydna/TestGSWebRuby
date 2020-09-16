require 'set'
require_relative '../../metrics_processor'

class TNMetricsProcessor2019CSA < GS::ETL::MetricsProcessor

	def initialize(*args)
		super
		@year = 2019
		@ticket_n = 'DXT-3606'
	end


	map_breakdown_id = {
		'All Students' => 1,
		'Economically Disadvantaged' => 23,
		'English Learners' => 32,
		'Students with Disabilities' => 27,
		'American Indian or Alaska Native' => 18,
		'Asian' => 16,
		'Black or African American' => 17, 
		'English Learners with Transitional 1-4' => 32,
		'Female' => 26,
		'Hispanic' => 19,
		'Male' => 25,
		'Native Hawaiian or Other Pacific Islander' => 20,
		'Non-Economically Disadvantaged' => 24,
		'Non-English Learners/Transitional 1-4' => 33,
		'Non-Students with Disabilities' => 30,
		'White' => 21,
		'White students' => 21
	}

	map_subject_id = {
		'English' => 17,
		'Math' => 5,
		'Reading' => 2,
		'Science' => 19,
		'Composite' => 1,
		'NA' => 0
	}

	map_grade = {
		443 => 'NA',
		448 => 'All',
		454 => 'All',
		396 => 'All',
		482 => 'NA',
		409 => 'NA'
	}


	source('ACT_district_suppressed_2019.txt', [], col_sep:"\t") do |s|
		s.transform('Fill missing default fields', Fill,{
			entity_type: 'district',
			year: '2019'
		})
		.transform('Rename columns',MultiFieldRenamer, {
			district: :district_id,
			subgroup: :breakdown,
			valid_tests: :cohort_count
		})
		.transform('transpose subject columns',Transposer,:subject_data_type,:value,:participation_rate,:average_english_score,:average_math_score,:average_reading_score,:average_science_score,:average_composite_score,:percent_scoring_21_or_higher)
		.transform('Create data type id and subject for transposed values, set cohort_counts', WithBlock) do |row|
			if [:participation_rate,:percent_scoring_21_or_higher].include? row[:subject_data_type]
				row[:subject] = 'Composite'
				if row[:subject_data_type] == :participation_rate
					row[:data_type_id] = 396
					row[:data_type] = 'ACT Participation'
					row[:cohort_count] = 'NULL'
				elsif row[:subject_data_type] == :percent_scoring_21_or_higher
					row[:data_type_id] = 454
					row[:data_type] = 'ACT percent college ready'
					row[:cohort_count] = row[:cohort_count]
				else
					row[:data_type_id] = 'Error'
					row[:data_type] = 'Error'
				end
			elsif [:average_english_score,:average_math_score,:average_reading_score,:average_science_score,:average_composite_score].include? row[:subject_data_type]
				row[:subject] = row[:subject_data_type].to_s.split('_')[1].capitalize
				row[:data_type_id] = 448
				row[:data_type] = 'ACT average score'
				row[:cohort_count] = row[:cohort_count]
			else
				row[:data_type_id] = 'Error'
				row[:data_type] = 'Error'
			end
			row
		end
	end
	source('ACT_school_suppressed_2019.txt', [], col_sep:"\t") do |s|
		s.transform('Fill missing default fields', Fill,{
			entity_type: 'school',
			year: '2019'
		})
		.transform('Rename columns',MultiFieldRenamer, {
			district: :district_id,
			school: :school_id,
			subgroup: :breakdown,
			valid_tests: :cohort_count
		})
		.transform('transpose subject columns',Transposer,:subject_data_type,:value,:participation_rate,:average_english_score,:average_math_score,:average_reading_score,:average_science_score,:average_composite_score,:percent_scoring_21_or_higher)
		.transform('Create data type id and subject for transposed values, set cohort_counts', WithBlock) do |row|
			if [:participation_rate,:percent_scoring_21_or_higher].include? row[:subject_data_type]
				row[:subject] = 'Composite'
				if row[:subject_data_type] == :participation_rate
					row[:data_type_id] = 396
					row[:data_type] = 'ACT Participation'
					row[:cohort_count] = 'NULL'
				elsif row[:subject_data_type] == :percent_scoring_21_or_higher
					row[:data_type_id] = 454
					row[:data_type] = 'ACT percent college ready'
					row[:cohort_count] = row[:cohort_count]
				else
					row[:data_type_id] = 'Error'
					row[:data_type] = 'Error'
				end
			elsif [:average_english_score,:average_math_score,:average_reading_score,:average_science_score,:average_composite_score].include? row[:subject_data_type]
				row[:subject] = row[:subject_data_type].to_s.split('_')[1].capitalize
				row[:data_type_id] = 448
				row[:data_type] = 'ACT average score'
				row[:cohort_count] = row[:cohort_count]
			else
				row[:data_type_id] = 'Error'
				row[:data_type] = 'Error'
			end
			row
		end
	end
	source('2018-19_state_grad_rate_suppressed.csv', [], col_sep:",") do |s|
		s.transform('Fill missing default fields', Fill,{
			entity_type: 'state',
			data_type: 'graduation rate',
			data_type_id: 443,
			subject: 'NA'
		})
		.transform('Rename columns',MultiFieldRenamer, {
			system: :district_id,
			system_name: :district_name,
			subgroup: :breakdown,
			grad_cohort: :cohort_count,
			grad_rate: :value
		})
	end
	source('2018-19_district_grad_rate_suppressed.csv', [], col_sep:",") do |s|
		s.transform('Fill missing default fields', Fill,{
			entity_type: 'district',
			data_type: 'graduation rate',
			data_type_id: 443,
			subject: 'NA'
		})
		.transform('Rename columns',MultiFieldRenamer, {
			system: :district_id,
			system_name: :district_name,
			subgroup: :breakdown,
			grad_cohort: :cohort_count,
			grad_rate: :value
		})
	end
	source('2018-19_school_grad_rate_suppressed.csv', [], col_sep:",") do |s|
		s.transform('Fill missing default fields', Fill,{
			entity_type: 'school',
			data_type: 'graduation rate',
			data_type_id: 443,
			subject: 'NA'
		})
		.transform('Rename columns',MultiFieldRenamer, {
			system: :district_id,
			system_name: :district_name,
			school: :school_id,
			subgroup: :breakdown,
			grad_cohort: :cohort_count,
			grad_rate: :value
		})
	end
	source('2013 and 2014 PS Enrollment Data by School and LEA for Great Schools.txt', [], col_sep:"\t") do |s|
		s.transform('Fill missing default fields', Fill,{
			data_type: 'college enrollment',
			data_type_id: 482,
			subject: 'NA'
		})
		.transform('Rename columns',MultiFieldRenamer, {
			graduation_year: :year,
			group: :breakdown,
			number_of_ontime_graduates____30: :cohort_count,
			percent_who_enroll_in_any_postsecondary: :value
		})
		.transform('Assign entity type', WithBlock) do |row|
			if row[:district_id] == '0'
				row[:entity_type] = 'state'
			elsif row[:district_id] != '0'
				if row[:school_id] == '0'
					row[:entity_type] = 'district'
				elsif row[:school_id] != '0'
					row[:entity_type] = 'school'
				end
			end
			row
		end
		.transform('delete unwanted years',DeleteRows,:year,"2017")
	end
	source('Persist Data for Great Schools.txt', [], col_sep:"\t") do |s|
		s.transform('Fill missing default fields', Fill,{
			entity_type: 'school',
			data_type: 'college persistence',
			data_type_id: 409,
			subject: 'NA',
			year: '2018',
			breakdown: 'All Students'
		})
		.transform('Rename columns',MultiFieldRenamer, {
			number_enrollees: :cohort_count,
			percent_persist: :value
		})
		.transform('Assign entity type', WithBlock) do |row|
			if row[:district_id] == '0'
				row[:entity_type] = 'state'
			elsif row[:district_id] != '0'
				if row[:school_id] == '0'
					row[:entity_type] = 'district'
				elsif row[:school_id] != '0'
					row[:entity_type] = 'school'
				end
			end
			row
		end
		.transform('delete unwanted years',DeleteRows,:graduation_year,"2016")
		.transform('delete unwanted years',DeleteRows,:graduation_year,"2015")
	end

	shared do |s|
		s.transform('Fill other columns',Fill,{
			notes: 'DXT-3606: TN CSA'
		})
		.transform('Assign date_valid based on year',WithBlock) do |row|
			if row[:year] == '2019'
				row[:date_valid] = '2019-01-01 00:00:00'
			elsif row[:year] == '2018'
				row[:date_valid] = '2018-01-01 00:00:00'
			end
			row
		end
		.transform('Create state_ids', WithBlock) do |row|
			if [443,448,454,396,482].include? row[:data_type_id]
				if row[:entity_type] == 'state'
					row[:state_id] = 'state'
				elsif row[:entity_type] == 'district'
					row[:state_id] = row[:district_id].to_s.rjust(3, '0')
				elsif row[:entity_type] == 'school'
					row[:state_id] = row[:district_id].to_s.rjust(3, '0')+ row[:school_id].to_s.rjust(4, '0')
				else
					row[:state_id] = 'Error--no entity_type'
				end
			elsif row[:data_type_id] == 409
				if row[:entity_type] == 'school'
					row[:state_id] = row[:district_id].to_s[2..4] + row[:school_id].to_s
				else
					row[:state_id] = 'Unexpected entity type for this file.'
				end
			end
			row
		end
		.transform('Remove percent symbols from values', WithBlock) do |row|
			if [409,482].include? row[:data_type_id]
				row[:value] = row[:value].to_s.gsub("%","")
			else
				row[:value] = row[:value]
			end
			row
		end
		.transform('Set unneeded breakdowns to be skipped', WithBlock) do |row|
			if ['Black/Hispanic/Native American','Homeless','Migrant','Non-Black/Hispanic/Native American','Non-Homeless','Non-Migrant','Black/Hispanic/Native American students'].include? row[:breakdown]
				row[:breakdown_skip] = 'Skip'
			else
				row[:breakdown_skip] = 'Keep'
			end
			row
		end
		.transform('delete bad breakdowns',DeleteRows,:breakdown_skip,"Skip")
		.transform('delete blank values',DeleteRows,:value,nil)
		.transform('delete asterisk values',DeleteRows,:value,"*")
		.transform('delete double asterisk values',DeleteRows,:value,"**")
		.transform('delete "#VALUE!" values',DeleteRows,:value,"#VALUE!")
		.transform('map subject ids',HashLookup,:subject, map_subject_id,to: :subject_id)
		.transform('map breakdown ids',HashLookup,:breakdown, map_breakdown_id, to: :breakdown_id)
		.transform('map grades', HashLookup, :data_type_id, map_grade, to: :grade)
	end


	def config_hash
	{
		source_id: 47,
        state: 'tn'
	}
	end
end

TNMetricsProcessor2019CSA.new(ARGV[0],max:nil).run