require_relative '../../metrics_processor'

class IDMetricsProcessor2019Growth < GS::ETL::MetricsProcessor

	def initialize(*args)
		super
		@year = 2019
		@ticket_n = 'DXT-3505'
	end

	map_breakdown_id = {
		'all_students' => 1,
		'american_indian' => 18,
		'asian' => 16,
		'black' => 17,
		'economically_disadvantaged' => 23,
		'english_learners' => 32,
		'female' => 26,
		'hawaiian_pacific_islander' => 20,
		'hispanic' => 19,
		'male' => 25,
		'multiracial' => 22,
		'no_disabilities' => 30,
		'not_economically_disadvantaged' => 24,
		'not_english_learners' => 33,
		'students_with_disabilities' => 27,
		'white' => 21
	}

	map_subject_id = {
		'ela_growth' => 4,
		'math_growth' => 5
	}

	source('State-2019-Underlying-Report-Card-Performance-Data.txt',[],col_sep:"\t") do |s|
	    s.transform('Fill missing default fields', Fill, {
	      entity_type: 'state',
	      state_id: 'state'
	    })
	end

	source('District-2019-Underlying-Report-Card-Performance-Data.txt',[],col_sep:"\t") do |s|
	    s.transform('Fill missing default fields', Fill, {
	      entity_type: 'district',
	    })
	    .transform('rename columns',MultiFieldRenamer,{
			entity_id: :state_id,
			entity_name: :district_name
		})
	end

	source('School-2019-Underlying-Report-Card-Performance-Data.txt',[],col_sep:"\t") do |s|
	    s.transform('Fill missing default fields', Fill, {
	      entity_type: 'school',
	    })
	    .transform('rename columns',MultiFieldRenamer,{
			entity_name: :school_name
		})
		.transform('create state_ids',WithBlock) do |row|
			row[:state_id] = row[:district_id] + row[:entity_id]
			row
		end
	end

	shared do |s|
		s.transform('rename columns',MultiFieldRenamer,{
			studentgroup: :breakdown,
			metric: :subject
		})
		.transform('delete unwanted year rows',DeleteRows,:year,'2018')
		.transform('delete unwanted breakdown rows',DeleteRows,:breakdown,'foster','grade_1','grade_10','grade_11','grade_12','grade_2','grade_3','grade_4','grade_5','grade_6','grade_7','grade_8','grade_9','grade_hs','grade_kg','homeless','migrant','military_connected','not_american_indian','not_asian','not_black','not_foster','not_hawaiian_pacific_islander','not_hispanic','not_homeless','not_migrant','not_military_connected','not_multiracial','not_white')
		.transform('delete unwanted subject rows',DeleteRows,:subject,'advanced_math_8','advanced_math_9','college_and_career_readiness_courses','ela_proficiency','english_learner_proficiency','english_learner_progress','grad_4yr','grad_5yr','iri_fall_proficiency','iri_fall_spring_change','iri_spring_proficiency','math_proficiency','parent_engagement','science_proficiency','student_engagement','teacher_engagement')
		.transform('prepare to delete suppressed rows',WithBlock) do |row|
			if row[:value] == "n_size"
				row[:row_suppressed] = 'skip'
			elsif row[:value].include? ">" 
				row[:row_suppressed] = 'skip'
			elsif row[:value].include? "<"
				row[:row_suppressed] = 'skip'	
			end
			row
		end
		.transform('delete suppressed rows',DeleteRows,:row_suppressed,'skip')
		.transform('assign date_valid', WithBlock) do |row|
	    	if row[:year] == '2017'
	    		row[:date_valid] = '2017-01-01 00:00:00'
	    	elsif row[:year] == '2019'
	      		row[:date_valid] = '2019-01-01 00:00:00'
	      	end
	      	row
	    end
		.transform('fill other columns',Fill,{
			data_type: 'growth',
			data_type_id: 460,
			notes: 'DXT-3505: ID Growth',
			grade: 'All'
		})
		.transform('map breakdown ids',HashLookup,:breakdown, map_breakdown_id,to: :breakdown_id)
		.transform('map breakdown ids',HashLookup,:subject, map_subject_id,to: :subject_id)
	end

	def config_hash
	{
		source_id: 16,
        state: 'id'
	}
	end
end

IDMetricsProcessor2019Growth.new(ARGV[0],max:nil).run