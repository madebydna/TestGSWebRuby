require 'set'
require_relative '../../metrics_processor'

class ARMetricsProcessor2019Growth < GS::ETL::MetricsProcessor

	def initialize(*args)
		super
		@year = 2019
		@ticket_n = 'DXT-3451'
	end

	map_subject_id = {
	  'ela' => 4,
	  'math' => 5
	}

	map_breakdown_id = {
		'all_students' => 1,
		'students_with_disabilities' => 27,
		'economically_disadvantaged' => 23,
		'african_american' => 17,
		'hispanic' => 19,
		'white' => 21,
		'female' => 26,
		'male' => 25,
		'english_learners' => 32
	}

	source('2018_2019_AR_school_growth.txt',[],col_sep:"\t") do |s|
	    s.transform('Fill missing default fields', Fill, {
	      entity_type: 'school'
	    })
	    s.transform('rename columns',MultiFieldRenamer, {
		  lea: :school_id
		})
	end
	source('2018_2019_AR_district_growth.txt',[],col_sep:"\t") do |s|
	    s.transform('Fill missing default fields', Fill, {
	      entity_type: 'district',
	      school_id: '',
	      school_name: 'all schools'
	    })
	    s.transform('rename columns',MultiFieldRenamer, {
		  lea: :district_id
		})
	end

	shared do |s|
		s.transform('Transpose year,grade,subject,subgroup columns for values to load', 
	     Transposer, 
	      :year_grade_subject_subgroup,:value,
	      :all_grades__lea_mean_valueadded_growth_math_201718_african_american,
	      :all_grades__lea_mean_valueadded_growth_math_201819_african_american,
	      :all_grades__lea_mean_valueadded_growth_math_201718_caucasian, 
	      :all_grades__lea_mean_valueadded_growth_math_201819_caucasian, 
	      :all_grades__lea_mean_valueadded_growth_math_201718_hispanic, 
	      :all_grades__lea_mean_valueadded_growth_math_201819_hispanic, 
	      :all_grades__lea_mean_valueadded_growth_math_201718_economically_disadvantaged, 
	      :all_grades__lea_mean_valueadded_growth_math_201819_economically_disadvantaged, 
	      :all_grades__lea_mean_valueadded_growth_math_201718_english_learners, 
	      :all_grades__lea_mean_valueadded_growth_math_201819_english_learners, 
	      :all_grades__lea_mean_valueadded_growth_math_201718_students_with_disabilities, 
	      :all_grades__lea_mean_valueadded_growth_math_201819_students_with_disabilities,
	      :all_grades__lea_mean_valueadded_growth_math_201718_male,
	      :all_grades__lea_mean_valueadded_growth_math_201819_male,
	      :all_grades__lea_mean_valueadded_growth_math_201718_female,
	      :all_grades__lea_mean_valueadded_growth_math_201819_female,
	      :all_grades__lea_mean_valueadded_growth_math_201718_combined_population,
	      :all_grades__lea_mean_valueadded_growth_math_201819_combined_population,
	      :all_grades__lea_mean_valueadded_growth_ela_201718_african_american,
	      :all_grades__lea_mean_valueadded_growth_ela_201819_african_american,
	      :all_grades__lea_mean_valueadded_growth_ela_201718_caucasian,
	      :all_grades__lea_mean_valueadded_growth_ela_201819_caucasian,
	      :all_grades__lea_mean_valueadded_growth_ela_201718_hispanic,
	      :all_grades__lea_mean_valueadded_growth_ela_201819_hispanic,
	      :all_grades__lea_mean_valueadded_growth_ela_201718_economically_disadvantaged,
	      :all_grades__lea_mean_valueadded_growth_ela_201819_economically_disadvantaged,
	      :all_grades__lea_mean_valueadded_growth_ela_201718_english_learners,
	      :all_grades__lea_mean_valueadded_growth_ela_201819_english_learners,
	      :all_grades__lea_mean_valueadded_growth_ela_201718_students_with_disabilities,
	      :all_grades__lea_mean_valueadded_growth_ela_201819_students_with_disabilities,
	      :all_grades__lea_mean_valueadded_growth_ela_201718_male,
	      :all_grades__lea_mean_valueadded_growth_ela_201819_male,
	      :all_grades__lea_mean_valueadded_growth_ela_201718_female,
	      :all_grades__lea_mean_valueadded_growth_ela_201819_female,
	      :all_grades__lea_mean_valueadded_growth_ela_201718_combined_population,
	      :all_grades__lea_mean_valueadded_growth_ela_201819_combined_population,
	      :grade_3__lea_mean_valueadded_growth_math_201718_african_american,
	      :grade_3__lea_mean_valueadded_growth_math_201819_african_american,
	      :grade_3__lea_mean_valueadded_growth_math_201718_caucasian,
	      :grade_3__lea_mean_valueadded_growth_math_201819_caucasian,
	      :grade_3__lea_mean_valueadded_growth_math_201718_hispanic,
	      :grade_3__lea_mean_valueadded_growth_math_201819_hispanic,
	      :grade_3__lea_mean_valueadded_growth_math_201718_economically_disadvantaged,
	      :grade_3__lea_mean_valueadded_growth_math_201819_economically_disadvantaged,
	      :grade_3__lea_mean_valueadded_growth_math_201718_english_learners,
	      :grade_3__lea_mean_valueadded_growth_math_201819_english_learners,
	      :grade_3__lea_mean_valueadded_growth_math_201718_students_with_disabilities,
	      :grade_3__lea_mean_valueadded_growth_math_201819_students_with_disabilities,
	      :grade_3__lea_mean_valueadded_growth_math_201718_male,
	      :grade_3__lea_mean_valueadded_growth_math_201819_male,
	      :grade_3__lea_mean_valueadded_growth_math_201718_female,
	      :grade_3__lea_mean_valueadded_growth_math_201819_female,
	      :grade_3__lea_mean_valueadded_growth_math_201718_combined_population,
	      :grade_3__lea_mean_valueadded_growth_math_201819_combined_population,
	      :grade_3__lea_mean_valueadded_growth_ela_201718_african_american,
	      :grade_3__lea_mean_valueadded_growth_ela_201819_african_american,
	      :grade_3__lea_mean_valueadded_growth_ela_201718_caucasian,
	      :grade_3__lea_mean_valueadded_growth_ela_201819_caucasian,
	      :grade_3__lea_mean_valueadded_growth_ela_201718_hispanic,
	      :grade_3__lea_mean_valueadded_growth_ela_201819_hispanic,
	      :grade_3__lea_mean_valueadded_growth_ela_201718_economically_disadvantaged,
	      :grade_3__lea_mean_valueadded_growth_ela_201819_economically_disadvantaged,
	      :grade_3__lea_mean_valueadded_growth_ela_201718_english_learners,
	      :grade_3__lea_mean_valueadded_growth_ela_201819_english_learners,
	      :grade_3__lea_mean_valueadded_growth_ela_201718_students_with_disabilities,
	      :grade_3__lea_mean_valueadded_growth_ela_201819_students_with_disabilities,
	      :grade_3__lea_mean_valueadded_growth_ela_201718_male,
	      :grade_3__lea_mean_valueadded_growth_ela_201819_male,
	      :grade_3__lea_mean_valueadded_growth_ela_201718_female,
	      :grade_3__lea_mean_valueadded_growth_ela_201819_female,
	      :grade_3__lea_mean_valueadded_growth_ela_201718_combined_population,
	      :grade_3__lea_mean_valueadded_growth_ela_201819_combined_population,
	      :grade_4__lea_mean_valueadded_growth_math_201718_african_american,
	      :grade_4__lea_mean_valueadded_growth_math_201819_african_american,
	      :grade_4__lea_mean_valueadded_growth_math_201718_caucasian,
	      :grade_4__lea_mean_valueadded_growth_math_201819_caucasian,
	      :grade_4__lea_mean_valueadded_growth_math_201718_hispanic,
	      :grade_4__lea_mean_valueadded_growth_math_201819_hispanic,
	      :grade_4__lea_mean_valueadded_growth_math_201718_economically_disadvantaged,
	      :grade_4__lea_mean_valueadded_growth_math_201819_economically_disadvantaged,
	      :grade_4__lea_mean_valueadded_growth_math_201718_english_learners,
	      :grade_4__lea_mean_valueadded_growth_math_201819_english_learners,
	      :grade_4__lea_mean_valueadded_growth_math_201718_students_with_disabilities,
	      :grade_4__lea_mean_valueadded_growth_math_201819_students_with_disabilities,
	      :grade_4__lea_mean_valueadded_growth_math_201718_male,
	      :grade_4__lea_mean_valueadded_growth_math_201819_male,
	      :grade_4__lea_mean_valueadded_growth_math_201718_female,
	      :grade_4__lea_mean_valueadded_growth_math_201819_female,
	      :grade_4__lea_mean_valueadded_growth_math_201718_combined_population,
	      :grade_4__lea_mean_valueadded_growth_math_201819_combined_population,
	      :grade_4__lea_mean_valueadded_growth_ela_201718_african_american,
	      :grade_4__lea_mean_valueadded_growth_ela_201819_african_american,
	      :grade_4__lea_mean_valueadded_growth_ela_201718_caucasian,
	      :grade_4__lea_mean_valueadded_growth_ela_201819_caucasian,
	      :grade_4__lea_mean_valueadded_growth_ela_201718_hispanic,
	      :grade_4__lea_mean_valueadded_growth_ela_201819_hispanic,
	      :grade_4__lea_mean_valueadded_growth_ela_201718_economically_disadvantaged,
	      :grade_4__lea_mean_valueadded_growth_ela_201819_economically_disadvantaged,
	      :grade_4__lea_mean_valueadded_growth_ela_201718_english_learners,
	      :grade_4__lea_mean_valueadded_growth_ela_201819_english_learners,
	      :grade_4__lea_mean_valueadded_growth_ela_201718_students_with_disabilities,
	      :grade_4__lea_mean_valueadded_growth_ela_201819_students_with_disabilities,
	      :grade_4__lea_mean_valueadded_growth_ela_201718_male,
	      :grade_4__lea_mean_valueadded_growth_ela_201819_male,
	      :grade_4__lea_mean_valueadded_growth_ela_201718_female,
	      :grade_4__lea_mean_valueadded_growth_ela_201819_female,
	      :grade_4__lea_mean_valueadded_growth_ela_201718_combined_population,
	      :grade_4__lea_mean_valueadded_growth_ela_201819_combined_population,
	      :grade_5__lea_mean_valueadded_growth_math_201718_african_american,
	      :grade_5__lea_mean_valueadded_growth_math_201819_african_american,
	      :grade_5__lea_mean_valueadded_growth_math_201718_caucasian,
	      :grade_5__lea_mean_valueadded_growth_math_201819_caucasian,
	      :grade_5__lea_mean_valueadded_growth_math_201718_hispanic,
	      :grade_5__lea_mean_valueadded_growth_math_201819_hispanic,
	      :grade_5__lea_mean_valueadded_growth_math_201718_economically_disadvantaged,
	      :grade_5__lea_mean_valueadded_growth_math_201819_economically_disadvantaged,
	      :grade_5__lea_mean_valueadded_growth_math_201718_english_learners,
	      :grade_5__lea_mean_valueadded_growth_math_201819_english_learners,
	      :grade_5__lea_mean_valueadded_growth_math_201718_students_with_disabilities,
	      :grade_5__lea_mean_valueadded_growth_math_201819_students_with_disabilities,
	      :grade_5__lea_mean_valueadded_growth_math_201718_male,
	      :grade_5__lea_mean_valueadded_growth_math_201819_male,
	      :grade_5__lea_mean_valueadded_growth_math_201718_female,
	      :grade_5__lea_mean_valueadded_growth_math_201819_female,
	      :grade_5__lea_mean_valueadded_growth_math_201718_combined_population,
	      :grade_5__lea_mean_valueadded_growth_math_201819_combined_population,
	      :grade_5__lea_mean_valueadded_growth_ela_201718_african_american,
	      :grade_5__lea_mean_valueadded_growth_ela_201819_african_american,
	      :grade_5__lea_mean_valueadded_growth_ela_201718_caucasian,
	      :grade_5__lea_mean_valueadded_growth_ela_201819_caucasian,
	      :grade_5__lea_mean_valueadded_growth_ela_201718_hispanic,
	      :grade_5__lea_mean_valueadded_growth_ela_201819_hispanic,
	      :grade_5__lea_mean_valueadded_growth_ela_201718_economically_disadvantaged,
	      :grade_5__lea_mean_valueadded_growth_ela_201819_economically_disadvantaged,
	      :grade_5__lea_mean_valueadded_growth_ela_201718_english_learners,
	      :grade_5__lea_mean_valueadded_growth_ela_201819_english_learners,
	      :grade_5__lea_mean_valueadded_growth_ela_201718_students_with_disabilities,
	      :grade_5__lea_mean_valueadded_growth_ela_201819_students_with_disabilities,
	      :grade_5__lea_mean_valueadded_growth_ela_201718_male,
	      :grade_5__lea_mean_valueadded_growth_ela_201819_male,
	      :grade_5__lea_mean_valueadded_growth_ela_201718_female,
	      :grade_5__lea_mean_valueadded_growth_ela_201819_female,
	      :grade_5__lea_mean_valueadded_growth_ela_201718_combined_population,
	      :grade_5__lea_mean_valueadded_growth_ela_201819_combined_population,
	      :grade_6__lea_mean_valueadded_growth_math_201718_african_american,
	      :grade_6__lea_mean_valueadded_growth_math_201819_african_american,
	      :grade_6__lea_mean_valueadded_growth_math_201718_caucasian,
	      :grade_6__lea_mean_valueadded_growth_math_201819_caucasian,
	      :grade_6__lea_mean_valueadded_growth_math_201718_hispanic,
	      :grade_6__lea_mean_valueadded_growth_math_201819_hispanic,
	      :grade_6__lea_mean_valueadded_growth_math_201718_economically_disadvantaged,
	      :grade_6__lea_mean_valueadded_growth_math_201819_economically_disadvantaged,
	      :grade_6__lea_mean_valueadded_growth_math_201718_english_learners,
	      :grade_6__lea_mean_valueadded_growth_math_201819_english_learners,
	      :grade_6__lea_mean_valueadded_growth_math_201718_students_with_disabilities,
	      :grade_6__lea_mean_valueadded_growth_math_201819_students_with_disabilities,
	      :grade_6__lea_mean_valueadded_growth_math_201718_male,
	      :grade_6__lea_mean_valueadded_growth_math_201819_male,
	      :grade_6__lea_mean_valueadded_growth_math_201718_female,
	      :grade_6__lea_mean_valueadded_growth_math_201819_female,
	      :grade_6__lea_mean_valueadded_growth_math_201718_combined_population,
	      :grade_6__lea_mean_valueadded_growth_math_201819_combined_population,
	      :grade_6__lea_mean_valueadded_growth_ela_201718_african_american,
	      :grade_6__lea_mean_valueadded_growth_ela_201819_african_american,
	      :grade_6__lea_mean_valueadded_growth_ela_201718_caucasian,
	      :grade_6__lea_mean_valueadded_growth_ela_201819_caucasian,
	      :grade_6__lea_mean_valueadded_growth_ela_201718_hispanic,
	      :grade_6__lea_mean_valueadded_growth_ela_201819_hispanic,
	      :grade_6__lea_mean_valueadded_growth_ela_201718_economically_disadvantaged,
	      :grade_6__lea_mean_valueadded_growth_ela_201819_economically_disadvantaged,
	      :grade_6__lea_mean_valueadded_growth_ela_201718_english_learners,
	      :grade_6__lea_mean_valueadded_growth_ela_201819_english_learners,
	      :grade_6__lea_mean_valueadded_growth_ela_201718_students_with_disabilities,
	      :grade_6__lea_mean_valueadded_growth_ela_201819_students_with_disabilities,
	      :grade_6__lea_mean_valueadded_growth_ela_201718_male,
	      :grade_6__lea_mean_valueadded_growth_ela_201819_male,
	      :grade_6__lea_mean_valueadded_growth_ela_201718_female,
	      :grade_6__lea_mean_valueadded_growth_ela_201819_female,
	      :grade_6__lea_mean_valueadded_growth_ela_201718_combined_population,
	      :grade_6__lea_mean_valueadded_growth_ela_201819_combined_population,
	      :grade_7__lea_mean_valueadded_growth_math_201718_african_american,
	      :grade_7__lea_mean_valueadded_growth_math_201819_african_american,
	      :grade_7__lea_mean_valueadded_growth_math_201718_caucasian,
	      :grade_7__lea_mean_valueadded_growth_math_201819_caucasian,
	      :grade_7__lea_mean_valueadded_growth_math_201718_hispanic,
	      :grade_7__lea_mean_valueadded_growth_math_201819_hispanic,
	      :grade_7__lea_mean_valueadded_growth_math_201718_economically_disadvantaged,
	      :grade_7__lea_mean_valueadded_growth_math_201819_economically_disadvantaged,
	      :grade_7__lea_mean_valueadded_growth_math_201718_english_learners,
	      :grade_7__lea_mean_valueadded_growth_math_201819_english_learners,
	      :grade_7__lea_mean_valueadded_growth_math_201718_students_with_disabilities,
	      :grade_7__lea_mean_valueadded_growth_math_201819_students_with_disabilities,
	      :grade_7__lea_mean_valueadded_growth_math_201718_male,
	      :grade_7__lea_mean_valueadded_growth_math_201819_male,
	      :grade_7__lea_mean_valueadded_growth_math_201718_female,
	      :grade_7__lea_mean_valueadded_growth_math_201819_female,
	      :grade_7__lea_mean_valueadded_growth_math_201718_combined_population,
	      :grade_7__lea_mean_valueadded_growth_math_201819_combined_population,
	      :grade_7__lea_mean_valueadded_growth_ela_201718_african_american,
	      :grade_7__lea_mean_valueadded_growth_ela_201819_african_american,
	      :grade_7__lea_mean_valueadded_growth_ela_201718_caucasian,
	      :grade_7__lea_mean_valueadded_growth_ela_201819_caucasian,
	      :grade_7__lea_mean_valueadded_growth_ela_201718_hispanic,
	      :grade_7__lea_mean_valueadded_growth_ela_201819_hispanic,
	      :grade_7__lea_mean_valueadded_growth_ela_201718_economically_disadvantaged,
	      :grade_7__lea_mean_valueadded_growth_ela_201819_economically_disadvantaged,
	      :grade_7__lea_mean_valueadded_growth_ela_201718_english_learners,
	      :grade_7__lea_mean_valueadded_growth_ela_201819_english_learners,
	      :grade_7__lea_mean_valueadded_growth_ela_201718_students_with_disabilities,
	      :grade_7__lea_mean_valueadded_growth_ela_201819_students_with_disabilities,
	      :grade_7__lea_mean_valueadded_growth_ela_201718_male,
	      :grade_7__lea_mean_valueadded_growth_ela_201819_male,
	      :grade_7__lea_mean_valueadded_growth_ela_201718_female,
	      :grade_7__lea_mean_valueadded_growth_ela_201819_female,
	      :grade_7__lea_mean_valueadded_growth_ela_201718_combined_population,
	      :grade_7__lea_mean_valueadded_growth_ela_201819_combined_population,
	      :grade_8__lea_mean_valueadded_growth_math_201718_african_american,
	      :grade_8__lea_mean_valueadded_growth_math_201819_african_american,
	      :grade_8__lea_mean_valueadded_growth_math_201718_caucasian,
	      :grade_8__lea_mean_valueadded_growth_math_201819_caucasian,
	      :grade_8__lea_mean_valueadded_growth_math_201718_hispanic,
	      :grade_8__lea_mean_valueadded_growth_math_201819_hispanic,
	      :grade_8__lea_mean_valueadded_growth_math_201718_economically_disadvantaged,
	      :grade_8__lea_mean_valueadded_growth_math_201819_economically_disadvantaged,
	      :grade_8__lea_mean_valueadded_growth_math_201718_english_learners,
	      :grade_8__lea_mean_valueadded_growth_math_201819_english_learners,
	      :grade_8__lea_mean_valueadded_growth_math_201718_students_with_disabilities,
	      :grade_8__lea_mean_valueadded_growth_math_201819_students_with_disabilities,
	      :grade_8__lea_mean_valueadded_growth_math_201718_male,
	      :grade_8__lea_mean_valueadded_growth_math_201819_male,
	      :grade_8__lea_mean_valueadded_growth_math_201718_female,
	      :grade_8__lea_mean_valueadded_growth_math_201819_female,
	      :grade_8__lea_mean_valueadded_growth_math_201718_combined_population,
	      :grade_8__lea_mean_valueadded_growth_math_201819_combined_population,
	      :grade_8__lea_mean_valueadded_growth_ela_201718_african_american,
	      :grade_8__lea_mean_valueadded_growth_ela_201819_african_american,
	      :grade_8__lea_mean_valueadded_growth_ela_201718_caucasian,
	      :grade_8__lea_mean_valueadded_growth_ela_201819_caucasian,
	      :grade_8__lea_mean_valueadded_growth_ela_201718_hispanic,
	      :grade_8__lea_mean_valueadded_growth_ela_201819_hispanic,
	      :grade_8__lea_mean_valueadded_growth_ela_201718_economically_disadvantaged,
	      :grade_8__lea_mean_valueadded_growth_ela_201819_economically_disadvantaged,
	      :grade_8__lea_mean_valueadded_growth_ela_201718_english_learners,
	      :grade_8__lea_mean_valueadded_growth_ela_201819_english_learners,
	      :grade_8__lea_mean_valueadded_growth_ela_201718_students_with_disabilities,
	      :grade_8__lea_mean_valueadded_growth_ela_201819_students_with_disabilities,
	      :grade_8__lea_mean_valueadded_growth_ela_201718_male,
	      :grade_8__lea_mean_valueadded_growth_ela_201819_male,
	      :grade_8__lea_mean_valueadded_growth_ela_201718_female,
	      :grade_8__lea_mean_valueadded_growth_ela_201819_female,
	      :grade_8__lea_mean_valueadded_growth_ela_201718_combined_population,
	      :grade_8__lea_mean_valueadded_growth_ela_201819_combined_population,
	      :grade_9__lea_mean_valueadded_growth_math_201718_african_american,
	      :grade_9__lea_mean_valueadded_growth_math_201819_african_american,
	      :grade_9__lea_mean_valueadded_growth_math_201718_caucasian,
	      :grade_9__lea_mean_valueadded_growth_math_201819_caucasian,
	      :grade_9__lea_mean_valueadded_growth_math_201718_hispanic,
	      :grade_9__lea_mean_valueadded_growth_math_201819_hispanic,
	      :grade_9__lea_mean_valueadded_growth_math_201718_economically_disadvantaged,
	      :grade_9__lea_mean_valueadded_growth_math_201819_economically_disadvantaged,
	      :grade_9__lea_mean_valueadded_growth_math_201718_english_learners,
	      :grade_9__lea_mean_valueadded_growth_math_201819_english_learners,
	      :grade_9__lea_mean_valueadded_growth_math_201718_students_with_disabilities,
	      :grade_9__lea_mean_valueadded_growth_math_201819_students_with_disabilities,
	      :grade_9__lea_mean_valueadded_growth_math_201718_male,
	      :grade_9__lea_mean_valueadded_growth_math_201819_male,
	      :grade_9__lea_mean_valueadded_growth_math_201718_female,
	      :grade_9__lea_mean_valueadded_growth_math_201819_female,
	      :grade_9__lea_mean_valueadded_growth_math_201718_combined_population,
	      :grade_9__lea_mean_valueadded_growth_math_201819_combined_population,
	      :grade_9__lea_mean_valueadded_growth_ela_201718_african_american,
	      :grade_9__lea_mean_valueadded_growth_ela_201819_african_american,
	      :grade_9__lea_mean_valueadded_growth_ela_201718_caucasian,
	      :grade_9__lea_mean_valueadded_growth_ela_201819_caucasian,
	      :grade_9__lea_mean_valueadded_growth_ela_201718_hispanic,
	      :grade_9__lea_mean_valueadded_growth_ela_201819_hispanic,
	      :grade_9__lea_mean_valueadded_growth_ela_201718_economically_disadvantaged,
	      :grade_9__lea_mean_valueadded_growth_ela_201819_economically_disadvantaged,
	      :grade_9__lea_mean_valueadded_growth_ela_201718_english_learners,
	      :grade_9__lea_mean_valueadded_growth_ela_201819_english_learners,
	      :grade_9__lea_mean_valueadded_growth_ela_201718_students_with_disabilities,
	      :grade_9__lea_mean_valueadded_growth_ela_201819_students_with_disabilities,
	      :grade_9__lea_mean_valueadded_growth_ela_201718_male,
	      :grade_9__lea_mean_valueadded_growth_ela_201819_male,
	      :grade_9__lea_mean_valueadded_growth_ela_201718_female,
	      :grade_9__lea_mean_valueadded_growth_ela_201819_female,
	      :grade_9__lea_mean_valueadded_growth_ela_201718_combined_population,
	      :grade_9__lea_mean_valueadded_growth_ela_201819_combined_population,
	      :grade_10__lea_mean_valueadded_growth_math_201718_african_american,
	      :grade_10__lea_mean_valueadded_growth_math_201819_african_american,
	      :grade_10__lea_mean_valueadded_growth_math_201718_caucasian,
	      :grade_10__lea_mean_valueadded_growth_math_201819_caucasian,
	      :grade_10__lea_mean_valueadded_growth_math_201718_hispanic,
	      :grade_10__lea_mean_valueadded_growth_math_201819_hispanic,
	      :grade_10__lea_mean_valueadded_growth_math_201718_economically_disadvantaged,
	      :grade_10__lea_mean_valueadded_growth_math_201819_economically_disadvantaged,
	      :grade_10__lea_mean_valueadded_growth_math_201718_english_learners,
	      :grade_10__lea_mean_valueadded_growth_math_201819_english_learners,
	      :grade_10__lea_mean_valueadded_growth_math_201718_students_with_disabilities,
	      :grade_10__lea_mean_valueadded_growth_math_201819_students_with_disabilities,
	      :grade_10__lea_mean_valueadded_growth_math_201718_male,
	      :grade_10__lea_mean_valueadded_growth_math_201819_male,
	      :grade_10__lea_mean_valueadded_growth_math_201718_female,
	      :grade_10__lea_mean_valueadded_growth_math_201819_female,
	      :grade_10__lea_mean_valueadded_growth_math_201718_combined_population,
	      :grade_10__lea_mean_valueadded_growth_math_201819_combined_population,
	      :grade_10__lea_mean_valueadded_growth_ela_201718_african_american,
	      :grade_10__lea_mean_valueadded_growth_ela_201819_african_american,
	      :grade_10__lea_mean_valueadded_growth_ela_201718_caucasian,
	      :grade_10__lea_mean_valueadded_growth_ela_201819_caucasian,
	      :grade_10__lea_mean_valueadded_growth_ela_201718_hispanic,
	      :grade_10__lea_mean_valueadded_growth_ela_201819_hispanic,
	      :grade_10__lea_mean_valueadded_growth_ela_201718_economically_disadvantaged,
	      :grade_10__lea_mean_valueadded_growth_ela_201819_economically_disadvantaged,
	      :grade_10__lea_mean_valueadded_growth_ela_201718_english_learners,
	      :grade_10__lea_mean_valueadded_growth_ela_201819_english_learners,
	      :grade_10__lea_mean_valueadded_growth_ela_201718_students_with_disabilities,
	      :grade_10__lea_mean_valueadded_growth_ela_201819_students_with_disabilities,
	      :grade_10__lea_mean_valueadded_growth_ela_201718_male,
	      :grade_10__lea_mean_valueadded_growth_ela_201819_male,
	      :grade_10__lea_mean_valueadded_growth_ela_201718_female, 
	      :grade_10__lea_mean_valueadded_growth_ela_201819_female, 
	      :grade_10__lea_mean_valueadded_growth_ela_201718_combined_population, 
	      :grade_10__lea_mean_valueadded_growth_ela_201819_combined_population
	      ) 
		.transform('Create grade field', WithBlock) do |row|
			if row[:year_grade_subject_subgroup][/^all_grades_/]
				row[:grade] = 'All'
			elsif row[:year_grade_subject_subgroup][/^grade_.*/]
				m = row[:year_grade_subject_subgroup].match /^grade_([0-9]+)__[a-z]/
				row[:grade] = m[1]
			else
				row[:grade] = 'Error'
			end
			row
		end
		.transform('Create subject field', WithBlock) do |row|
			if row[:year_grade_subject_subgroup][/^all_grades_/]
				m = row[:year_grade_subject_subgroup].match /^all_grades__lea_mean_valueadded_growth_(.*)_[0-9]/ #grab subject from inbetween overall_ and _index
				row[:subject] = m[1]
			elsif row[:year_grade_subject_subgroup][/^grade_[0-9]+_/]
				m = row[:year_grade_subject_subgroup].match /^grade_[0-9]+__lea_mean_valueadded_growth_(.*)_[0-9]/
				row[:subject] = m[1]
			else
				row[:subject] = 'Error'
			end
			row
		end
		.transform('Create year field', WithBlock) do |row|
			if row[:year_grade_subject_subgroup][/^all_grades__lea_mean_valueadded_growth_ela_/]
				m = row[:year_grade_subject_subgroup].match /^all_grades__lea_mean_valueadded_growth_ela_([0-9]+)_[a-z]/
				row[:year] = m[1]
			elsif row[:year_grade_subject_subgroup][/^all_grades__lea_mean_valueadded_growth_math_/]
				m = row[:year_grade_subject_subgroup].match /^all_grades__lea_mean_valueadded_growth_math_([0-9]+)_[a-z]/
				row[:year] = m[1]
			elsif row[:year_grade_subject_subgroup][/^grade_[0-9]+__lea_mean_valueadded_growth_ela_/]
				m = row[:year_grade_subject_subgroup].match /^grade_[0-9]+__lea_mean_valueadded_growth_ela_([0-9]+)_[a-z]/
				row[:year] = m[1]
			elsif row[:year_grade_subject_subgroup][/^grade_[0-9]+__lea_mean_valueadded_growth_math_/]
				m = row[:year_grade_subject_subgroup].match /^grade_[0-9]+__lea_mean_valueadded_growth_math_([0-9]+)_[a-z]/
				row[:year] = m[1]
			else
				row[:year] = 'Error'
			end
			row
		end	
		.transform('Standardize year field', WithBlock) do |row|
			if row[:year] == '201718'
				row[:year] = 2018
			elsif row[:year] == '201819'
				row[:year] = 2019
			end
			row
		end
		.transform('Create date_valid field', WithBlock) do |row|
			if row[:year] == 2018
				row[:date_valid] = '2018-01-01 00:00:00'
			elsif row[:year] == 2019
				row[:date_valid] = '2019-01-01 00:00:00'
			else
				row[:date_valid] = 'Error'
			end
			row
		end
		.transform('Create breakdown field', WithBlock) do |row|
			if row[:year_grade_subject_subgroup][/^all_grades__lea_mean_valueadded_growth_ela_[0-9]+_/]
				m = row[:year_grade_subject_subgroup].match /^all_grades__lea_mean_valueadded_growth_ela_[0-9]+_(.*)$/
				row[:breakdown] = m[1]
			elsif row[:year_grade_subject_subgroup][/^all_grades__lea_mean_valueadded_growth_math_[0-9]+_/]
				m = row[:year_grade_subject_subgroup].match /^all_grades__lea_mean_valueadded_growth_math_[0-9]+_(.*)$/
				row[:breakdown] = m[1]
			elsif row[:year_grade_subject_subgroup][/^grade_[0-9]+__lea_mean_valueadded_growth_ela_[0-9]+_/]
				m = row[:year_grade_subject_subgroup].match /^grade_[0-9]+__lea_mean_valueadded_growth_ela_[0-9]+_(.*)$/
				row[:breakdown] = m[1]
			elsif row[:year_grade_subject_subgroup][/^grade_[0-9]+__lea_mean_valueadded_growth_math_[0-9]+_/]
				m = row[:year_grade_subject_subgroup].match /^grade_[0-9]+__lea_mean_valueadded_growth_math_[0-9]+_(.*)$/
				row[:breakdown] = m[1]
			end
			row
		end
		.transform('Correct weird breakdown names for easier output', WithBlock) do |row|
			if row[:breakdown] == 'combined_population'
				row[:breakdown] = 'all_students'
			elsif row[:breakdown] == 'caucasian'
				row[:breakdown] = 'white'
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
		.transform('map subject ids',HashLookup,:subject, map_subject_id,to: :subject_id)
		.transform('map breakdown ids',HashLookup,:breakdown, map_breakdown_id, to: :breakdown_id)
		.transform('remove "N/A" value rows', DeleteRows, :value, 'N/A')
		.transform('delete blank values',DeleteRows,:value,nil)
		.transform('Trim to two places after decimal', WithBlock) do |row|
			if row[:value] != 'N/A'
				row[:value] = '%.2f' % row[:value] 
			else
				row[:value] = row[:value]
			end
			row
		end
		.transform('fill other columns',Fill,{
			data_type: 'growth',
			data_type_id: 447,
			notes: 'DXT-3451: AR Growth'
		})
	end

	def config_hash
	{
		source_id: 7,
        state: 'ar'
	}
	end
end

ARMetricsProcessor2019Growth.new(ARGV[0],max:nil).run