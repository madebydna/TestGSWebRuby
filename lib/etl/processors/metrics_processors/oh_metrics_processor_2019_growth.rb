require 'set'
require_relative '../../metrics_processor'

class OHMetricsProcessor2019Growth < GS::ETL::MetricsProcessor

	def initialize(*args)
		super
		@year = 2019
		@ticket_n = 'DXT-3463'
	end

	map_subject_id = {
	  'composite' => 1,
	  'reading' => 2,
	  'math' => 5,
	  'science' => 19,
	  'algebra_1' => 6,
	  'geometry' => 8,
	  'integrated_math_1' => 7,
	  'integrated_math_2' => 9,
	  'ela_1' => 73,
	  'ela_2' => 70,
	}

	source('1819_VA_ORG_DETAILS.txt',[],col_sep:"\t") do |s|
	    s.transform('Fill missing default fields', Fill, {
	      entity_type: 'school'
	    })
	    s.transform('rename columns',MultiFieldRenamer, {
		  building_irn: :school_id,
		  building_name: :school_name,
		  district_irn: :district_id,
		  district_name: :district_name
		})
	end
	source('1819_VA_DIST_DETAILS.txt',[],col_sep:"\t") do |s|
	    s.transform('Fill missing default fields', Fill, {
	      entity_type: 'district',
	      school_id: '',
	      school_name: 'all schools'
	    })
	    s.transform('rename columns',MultiFieldRenamer, {
		  district_irn: :district_id,
		  district_name: :district_name
		})
	end

	shared do |s|
		s.transform('Transpose subject grade columns for values to load', 
	     Transposer, 
	      :grade_subject,:value,
	      :overall_composite_index,:grade_4_composite_index,
	      :grade_5_composite_index,:grade_6_composite_index,
	      :grade_7_composite_index,:grade_8_composite_index,
	      :reading_index,:grade_4_reading_index,
	      :grade_5_reading_index,:grade_6_reading_index,
	      :grade_7_reading_index,:grade_8_reading_index,
	      :math_index,:grade_4_math_index,
	      :grade_5_math_index,:grade_6_math_index,
	      :grade_7_math_index,:grade_8_math_index,
	      :science_index,:grade_5_science_index,
	      :grade_8_science_index,
	      :algebra_1_index,:geometry_index,
	      :integrated_math_1_index,:integrated_math_2_index,
	      :ela_1_index,:ela_2_index
	      )
		.transform('Adjust subject_grade field to standardize for EOC subjects and grade all reading, math, and science',WithBlock) do |row|
			if [:reading_index,:math_index,:science_index,:algebra_1_index,:geometry_index,:integrated_math_1_index,:integrated_math_2_index,:ela_1_index,:ela_2_index].include? row[:grade_subject]
				row[:subject] = 'overall_' + row[:grade_subject].to_s
			else
				row[:subject] = row[:grade_subject]
			end
			row
		end		
		.transform('Create grade field', WithBlock) do |row|
			if row[:subject][/^overall_/]
				row[:grade] = 'All'
			elsif row[:subject][/^grade_.*/]
				m = row[:subject].match /^grade_([0-9])/
				row[:grade] = m[1]
			else
				row[:grade] = 'Error'
			end
			row
		end
		.transform('Create subject field', WithBlock) do |row|
			if row[:subject][/^overall_/]
				m = row[:subject].match /^overall_(.*)_index$/ #grab subject from inbetween overall_ and _index
				row[:subject] = m[1]
			elsif row[:subject][/^grade_[0-9]_/]
				m = row[:subject].match /^grade_[0-9]_(.*)_index$/
				row[:subject] = m[1]
			else
				row[:subject] = 'Error'
			end
			row
		end
		.transform('Map cohort count to appropriate subject and grade column', WithBlock) do |row|
			if row[:subject] == 'composite'
				row[:cohort_count] = nil
			elsif row[:subject] == 'reading'
				if row[:grade] == 'All'
					row[:cohort_count] = row[:reading_student_count]
				elsif row[:grade] == '4'
					row[:cohort_count] = row[:grade_4_reading_student_count]
				elsif row[:grade] == '5'
					row[:cohort_count] = row[:grade_5_reading_student_count]
				elsif row[:grade] == '6'
					row[:cohort_count] = row[:grade_6_reading_student_count] 
				elsif row[:grade] == '7'
					row[:cohort_count] = row[:grade_7_reading_student_count]
				elsif row[:grade] == '8'
					row[:cohort_count] = row[:grade_8_reading_student_count] 
				else
					row[:cohort_count] = 'reading_Error'
				end 
			elsif row[:subject] == 'math'
				if row[:grade] == 'All'
					row[:cohort_count] = row[:math_student_count]
				elsif row[:grade] == '4'
					row[:cohort_count] = row[:grade_4_math_student_count]
				elsif row[:grade] == '5'
					row[:cohort_count] = row[:grade_5_math_student_count]
				elsif row[:grade] == '6'
					row[:cohort_count] = row[:grade_6_math_student_count] 
				elsif row[:grade] == '7'
					row[:cohort_count] = row[:grade_7_math_student_count]  
				elsif row[:grade] == '8'
					row[:cohort_count] = row[:grade_8_math_student_count] 
				else
					row[:cohort_count] = 'Error'
				end
			elsif row[:subject] == 'science'
				if row[:grade] == 'All'
					row[:cohort_count] = row[:science_student_count]
				elsif row[:grade] == '5'
					row[:cohort_count] = row[:grade_5_science_student_count]
				elsif row[:grade] == '8'
					row[:cohort_count] = row[:grade_8_science_student_count]
				else
					row[:cohort_count] = 'Error'
				end
			elsif row[:subject] == 'algebra_1'
				row[:cohort_count] = row[:algebra_1_student_count]
			elsif row[:subject] == 'geometry'
				row[:cohort_count] = row[:geometry_student_count]
			elsif row[:subject] == 'integrated_math_1'
				row[:cohort_count] = row[:integrated_math_1_student_count]
			elsif row[:subject] == 'integrated_math_2'
				row[:cohort_count] = row[:integrated_math_2_student_count]
			elsif row[:subject] == 'ela_1'
				row[:cohort_count] = row[:ela_1_student_count]
			elsif row[:subject] == 'ela_2'
				row[:cohort_count] = row[:ela_2_student_count]
			else
				row[:cohort_count] = 'Error'
			end
			row
		end
		.transform('map subject ids',HashLookup,:subject, map_subject_id,to: :subject_id)
		.transform('remove "NC" value rows', DeleteRows, :value, 'NC')
		.transform('replace "NC" cohort counts with nil values', WithBlock) do |row|
			if row[:cohort_count] == 'NC'
				row[:cohort_count] = nil
			else
				row[:cohort_count] = row[:cohort_count]
			end
			row
		end
		.transform('create state_id field', WithBlock) do |row|
			if row[:entity_type] == 'district'
				row[:state_id] = row[:district_id]
			elsif row[:entity_type] == 'school'
				row[:state_id] = row[:school_id]
			end
			row
		end
		.transform('fill other columns',Fill,{
			year: 2019,
			data_type: 'growth',
			data_type_id: 447,
			date_valid: '2019-01-01 00:00:00',
			notes: 'DXT-3463: OH Growth',
			breakdown: 'All Students',
			breakdown_id: 1
		})
	end

	def config_hash
	{
		source_id: 40,
        state: 'oh'
	}
	end
end

OHMetricsProcessor2019Growth.new(ARGV[0],max:nil).run