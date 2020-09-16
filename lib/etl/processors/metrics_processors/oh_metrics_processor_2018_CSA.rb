require_relative '../../metrics_processor'

class OHMetricsProcessor2018CSA < GS::ETL::MetricsProcessor

	def initialize(*args)
		super
		@year = 2018
		@ticket_n = 'DXT-3388'
	end

	map_breakdown_id = {
		#college enrollment and remediation
		'All Students' => 1
	}

	map_subject_id = {
		#college enrollment
		'NA' => 0,
		#college remediation
		'Math or English' => 89,
		'Math and English' => 1,
		'English' => 17,
		'Math' => 5
	}

	map_grade = {
		487 => 'NA',
		477 => 'NA',
		480 => 'NA',
		413 => 'NA'
	}


#college enrollment and remediation
	source('OH_2018_district_ps_processed.txt',[],col_sep:"\t") do |s|
	s.transform('rename columns',MultiFieldRenamer, {
		irn: :district_id
	})
	.transform('Assign entity_type',WithBlock) do |row|
		if row[:district_id] == 'STATE'
			row[:entity_type] = 'state'
		elsif row[:district_id] != 'STATE'
			row[:entity_type] = 'district'
		else
			row[:entity_type] = 'Error'
		end
		row
	end
	.transform('Transpose wide college data types into long',
	Transposer,
		:data_type_subject,:value,
		:pct_overall,
		:pct_2_yr, :pct_4_yr,
		 :_of_entering_students_taking_developmental_math_or_english, 
		 :_of_entering_students_taking_developmental_math, 
		 :_of_entering_students_taking_developmental_english, 
		 :_of_entering_students_taking_developmental_math_and_english
		)
	end
	source('OH_2018_school_ps_processed.txt',[],col_sep:"\t") do |s|
	s.transform('rename columns',MultiFieldRenamer, {
		irn: :school_id,
		high_school_by_county: :school_name
	})
	.transform('Fill missing default fields', Fill, {
		entity_type: 'school'
	})
	.transform('Transpose wide college data types into long',
	Transposer,
		:data_type_subject,:value,
		:pct_overall,
		:pct_2_yr, :pct_4_yr,
		:_of_entering_students_taking_developmental_math_or_english, 
		:_of_entering_students_taking_developmental_math, 
		:_of_entering_students_taking_developmental_english, 
		:_of_entering_students_taking_developmental_math_and_english
		)
	end

	shared do |s|
		s.transform('fill other columns',Fill,{
			notes: 'DXT-3308: OH CSA',
			year: 2018,
			date_valid: '2018-01-01 00:00:00',
			breakdown: 'All Students'
		})
		.transform('Create state_id field', WithBlock) do |row|
			if row[:entity_type] == 'school'
				row[:state_id] = row[:school_id]
			elsif row[:entity_type] == 'district'
				row[:state_id] = row[:district_id]
			elsif row[:entity_type] == 'state'
				row[:state_id] = 'state'
			else
				row[:state_id] = 'Error'
			end
			row
		end
		.transform('Set bad state_ids to skip', WithBlock) do |row|
			if row[:entity_type] == 'school'
				if ['014040','037069'].include? row[:state_id]
					row[:state_id] = 'Skip'
				else
					row[:state_id] = row[:state_id]
				end
			end
			row
		end
		.transform('Assign data type ids', WithBlock) do |row|
			if [:_of_entering_students_taking_developmental_math_or_english, :_of_entering_students_taking_developmental_math, :_of_entering_students_taking_developmental_english, :_of_entering_students_taking_developmental_math_and_english].include? row[:data_type_subject]
				row[:data_type_id] = 413
			elsif row[:data_type_subject] == :pct_overall
				row[:data_type_id] = 487
			elsif row[:data_type_subject] == :pct_2_yr
				row[:data_type_id] = 477
			elsif row[:data_type_subject] == :pct_4_yr
				row[:data_type_id] = 480
			else 
				row[:data_type_id] = 'Error'
			end
			row
		end
		.transform('Assign subject name and cohort_count', WithBlock) do |row|
			if [487,477,480].include? row[:data_type_id]
				row[:subject] = 'NA'
				row[:cohort_count] = row[:four_year_graduation_rate_numerator__class_of_2018]
			elsif row[:data_type_id] == 413
				row[:cohort_count] = row[:number_of_firsttime_college_students]
				if row[:data_type_subject] == :_of_entering_students_taking_developmental_math_or_english
					row[:subject] = 'Math or English'
				elsif row[:data_type_subject] == :_of_entering_students_taking_developmental_math
					row[:subject] = 'Math'
				elsif row[:data_type_subject] == :_of_entering_students_taking_developmental_english
					row[:subject] = 'English'
				elsif row[:data_type_subject] == :_of_entering_students_taking_developmental_math_and_english
					row[:subject] = 'Math and English'
				else
					row[:subject] = 'Error'
				end
			else
				row[:subject] = 'Error'
			end
			row
		end
		.transform('Skip >=101.5 values', WithBlock) do |row|
			if row[:value] == 'NA'
				row[:value] = row[:value]
			elsif row[:value] != 'NA'
				row[:value] = row[:value].to_f * 100
				row[:value] = sprintf('%.2f', row[:value])
				if row[:value].to_f >= 101.5
					row[:value] = 'NA'
				elsif row[:value].to_f > 100
					row[:value] = '100'
				elsif row[:value].to_f <= 100
					row[:value] = row[:value]
				end
			end
			row
		end
		.transform('delete "NA" values',DeleteRows,:value,'NA')
		.transform('delete "Skip" state_ids',DeleteRows,:state_id,'Skip')
		.transform('map breakdown ids',HashLookup,:breakdown, map_breakdown_id,to: :breakdown_id)
		.transform('map subject ids',HashLookup,:subject, map_subject_id,to: :subject_id)
		.transform('map grades',HashLookup,:data_type_id, map_grade,to: :grade)
	end

	def config_hash
	{
		source_id: 68,
        state: 'oh'
	}
	end
end

OHMetricsProcessor2018CSA.new(ARGV[0],max:nil).run