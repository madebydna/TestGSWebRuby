require_relative '../../metrics_processor'

class GAMetricsProcessor2019CSA < GS::ETL::MetricsProcessor

	def initialize(*args)
		super
		@year = 2019
		@ticket_n = 'DXT-3386'
	end

	map_breakdown_id = {
		'All Students' => 1,
		'ALL Students' => 1,
		'all' => 1,
		'American Indian/Alaskan' => 18,
		'american_indian_or_alaskan_native' => 18,
		'Asian/Pacific Islander' => 15,
		'asian' => 16,
		'pacific_islander' => 37,
		'Black' => 17,
		'black' => 17,
		'Economically Disadvantaged' => 23,
		'free_reduced_lunch' => 23,
		'Female' => 26,
		'female'=> 26,
		'Hispanic' => 19,
		'hispanic' => 19,
		'Limited English Proficient' => 32,
		'lep' => 32,
		'Male' => 25,
		'male' => 25,
		'Multi-Racial' => 22,
		'Multi' => 22,
		'two' => 22,
		'Not Economically Disadvantaged' => 24,
		'Students With Disability' => 27,
		'disability' => 27,
		'Students Without Disability' => 30,
		'White' => 21,
		'white' => 21
	}

	map_subject_id = {
		'Reading' => 2,
		'Mathematics' => 5,
		:ls_math_pct => 5,
		'English' => 17,
		:ls_eng_pct => 17,
		'Science' => 19,
		'Composite' => 1,
		'Not Applicable' => 0,
		'Combined Test Score' => 1,
		'Evidence Based Reading and Writing - New' => 2,
		'Math Section Score - New' => 5
	}

	source('act_school.txt',[],col_sep:"\t") do |s|
		s.transform('Fill missing default fields', Fill, {
			year: 2019,
			date_valid: '2019-01-01 00:00:00',
			entity_type: 'school',
			data_type: 'average act',
			data_type_id: 448,
			notes: 'DXT-3386: GA CSA',
			grade: 'All'
	    })
	    .transform('rename columns',MultiFieldRenamer,{
			instn_number: :school_id,
			instn_name: :school_name,
			school_distrct_cd: :district_id,
			school_dstrct_nm: :district_name,
			subgrp_desc: :breakdown,
			test_cmpnt_typ_cd: :subject,
			instn_num_tested_cnt: :cohort_count,
			instn_avg_score_val: :value
		})
		.transform('delete Writing Subscore rows',DeleteRows,:subject, 'Writing Subscore')
		.transform('delete blank values',DeleteRows,:value,nil)
		.transform('map breakdown ids',HashLookup,:breakdown, map_breakdown_id,to: :breakdown_id)
		.transform('map subject ids',HashLookup,:subject, map_subject_id,to: :subject_id)
		.transform('create state_ids',WithBlock) do |row|
			row[:state_id] = row[:district_id] + row[:school_id].rjust(4,'0')
			row
		end
	end

	source('act_district.txt',[],col_sep:"\t") do |s|
	    s.transform('Fill missing default fields', Fill, {
			year: 2019,
			date_valid: '2019-01-01 00:00:00',
			entity_type: 'district',
			data_type: 'average act',
			data_type_id: 448,
			notes: 'DXT-3386: GA CSA',
			grade: 'All'
	    })
	    .transform('rename columns',MultiFieldRenamer,{
			school_distrct_cd: :district_id,
			school_dstrct_nm: :district_name,
			subgrp_desc: :breakdown,
			test_cmpnt_typ_cd: :subject,
			dstrct_num_tested_cnt: :cohort_count,
			dstrct_avg_score_val: :value
		})
		.transform('delete Writing Subscore rows',DeleteRows,:subject, 'Writing Subscore')
		.transform('delete blank values',DeleteRows,:value,nil)
		.transform('map breakdown ids',HashLookup,:breakdown, map_breakdown_id,to: :breakdown_id)
		.transform('map breakdown ids',HashLookup,:subject, map_subject_id,to: :subject_id)
		.transform('create state_ids',WithBlock) do |row|
			row[:state_id] = row[:district_id]
			row
		end
	end

	source('act_state.txt',[],col_sep:"\t") do |s|
	    s.transform('Fill missing default fields', Fill, {
			year: 2019,
	    	date_valid: '2019-01-01 00:00:00',
	    	entity_type: 'state',
	    	state_id: 'state',
			data_type: 'average act',
			data_type_id: 448,
			notes: 'DXT-3386: GA CSA',
			grade: 'All'
	    })
	    .transform('rename columns',MultiFieldRenamer,{
			subgrp_desc: :breakdown,
			test_cmpnt_typ_cd: :subject,
			state_num_tested_cnt: :cohort_count,
			state_avg_score_val: :value
		})
		.transform('delete Writing Subscore rows',DeleteRows,:subject, 'Writing Subscore')
		.transform('delete blank values',DeleteRows,:value,nil)
		.transform('map breakdown ids',HashLookup,:breakdown, map_breakdown_id,to: :breakdown_id)
		.transform('map breakdown ids',HashLookup,:subject, map_subject_id,to: :subject_id)
	end

	source('sat_school.txt',[],col_sep:"\t") do |s|
	    s.transform('Fill missing default fields', Fill, {
	    	year: 2019,
	    	date_valid: '2019-01-01 00:00:00',
	    	entity_type: 'school',
			data_type: 'average sat',
			data_type_id: 446,
			notes: 'DXT-3386: GA CSA',
			grade: 'All'
	    })
	    .transform('rename columns',MultiFieldRenamer,{
			instn_number: :school_id,
			instn_name: :school_name,
			school_distrct_cd: :district_id,
			school_dstrct_nm: :district_name,
			subgrp_desc: :breakdown,
			test_cmpnt_typ_cd: :subject,
			instn_num_tested_cnt: :cohort_count,
			instn_avg_score_val: :value
		})
		.transform('delete unwanted subject rows',DeleteRows,:subject, 'Essay Analysis Score - New','Essay Reading Score - New','Essay Total','Essay Writing Score - New','Reading Test  Score - New','WritLang Test  Score - New')
		.transform('delete blank values',DeleteRows,:value,nil)
		.transform('round cohort values to integers',WithBlock) do |row|
			row[:cohort_count] = row[:cohort_count].to_f.round.to_s
			row
		end
		.transform('map breakdown ids',HashLookup,:breakdown, map_breakdown_id,to: :breakdown_id)
		.transform('map subject ids',HashLookup,:subject, map_subject_id,to: :subject_id)
		.transform('create state_ids',WithBlock) do |row|
			row[:state_id] = row[:district_id] + row[:school_id].rjust(4,'0')
			row
		end
	end

	source('sat_district.txt',[],col_sep:"\t") do |s|
	    s.transform('Fill missing default fields', Fill, {
	    	year: 2019,
	    	date_valid: '2019-01-01 00:00:00',
	    	entity_type: 'district',
			data_type: 'average sat',
			data_type_id: 446,
			notes: 'DXT-3386: GA CSA',
			grade: 'All'
	    })
	    .transform('rename columns',MultiFieldRenamer,{
			school_distrct_cd: :district_id,
			school_dstrct_nm: :district_name,
			subgrp_desc: :breakdown,
			test_cmpnt_typ_cd: :subject,
			dstrct_num_tested_cnt: :cohort_count,
			dstrct_avg_score_val: :value
		})
		.transform('delete unwanted subject rows',DeleteRows,:subject, 'Essay Analysis Score - New','Essay Reading Score - New','Essay Total','Essay Writing Score - New','Reading Test  Score - New','WritLang Test  Score - New')
		.transform('delete blank values',DeleteRows,:value,nil)
		.transform('round cohort values to integers',WithBlock) do |row|
			row[:cohort_count] = row[:cohort_count].to_f.round.to_s
			row
		end
		.transform('map breakdown ids',HashLookup,:breakdown, map_breakdown_id,to: :breakdown_id)
		.transform('map breakdown ids',HashLookup,:subject, map_subject_id,to: :subject_id)
		.transform('create state_ids',WithBlock) do |row|
			row[:state_id] = row[:district_id]
			row
		end
	end

	source('sat_state.txt',[],col_sep:"\t") do |s|
	    s.transform('Fill missing default fields', Fill, {
	    	year: 2019,
	    	date_valid: '2019-01-01 00:00:00',
	    	entity_type: 'state',
	    	state_id: 'state',
			data_type: 'average sat',
			data_type_id: 446,
			notes: 'DXT-3386: GA CSA',
			grade: 'All'
	    })
	    .transform('rename columns',MultiFieldRenamer,{
			school_distrct_cd: :district_id,
			school_dstrct_nm: :district_name,
			subgrp_desc: :breakdown,
			test_cmpnt_typ_cd: :subject,
			state_num_tested_cnt: :cohort_count,
			state_avg_score_val: :value
		})
		.transform('delete unwanted subject rows',DeleteRows,:subject, 'Essay Analysis Score - New','Essay Reading Score - New','Essay Total','Essay Writing Score - New','Reading Test  Score - New','WritLang Test  Score - New')
		.transform('delete blank values',DeleteRows,:value,nil)
		.transform('round cohort values to integers',WithBlock) do |row|
			row[:cohort_count] = row[:cohort_count].to_f.round.to_s
			row
		end
		.transform('map breakdown ids',HashLookup,:breakdown, map_breakdown_id,to: :breakdown_id)
		.transform('map breakdown ids',HashLookup,:subject, map_subject_id,to: :subject_id)
	end

	source('grad.txt',[],col_sep:"\t") do |s|
	    s.transform('Fill missing default fields', Fill, {
	    	year: 2019,
	    	date_valid: '2019-01-01 00:00:00',
			data_type: 'grad rate',
			data_type_id: 443,
			notes: 'DXT-3386: GA CSA',
			grade: 'NA',
			subject: 'Not Applicable'
	    })
	    .transform('rename columns',MultiFieldRenamer,{
			instn_number: :school_id,
			instn_name: :school_name,
			school_dstrct_cd: :district_id,
			school_dstrct_nm: :district_name,
			total_count: :cohort_count,
			program_percent: :value
		})
		.transform('setting entity and state_id',WithBlock) do |row|
			if row[:detail_lvl_desc] == 'State'
				row[:entity_type] = 'state'
				row[:state_id] = 'state'
			elsif row[:detail_lvl_desc] == 'District'
				row[:entity_type] = 'district'
				row[:state_id] = row[:district_id]
			else
				row[:entity_type] = 'school'
				row[:state_id] = row[:district_id] + row[:school_id].rjust(4,'0')
			end
			row
		end
		.transform('create breakdown',WithBlock) do |row|
			row[:breakdown] = row[:label_lvl_1_desc].split('-')[1]
			row
		end
		.transform('delete unwanted breakdown rows',DeleteRows,:breakdown,'Active Duty','Homeless','Migrant')
		.transform('delete blank values',DeleteRows,:value,nil)
		.transform('map breakdown ids',HashLookup,:breakdown, map_breakdown_id,to: :breakdown_id)
		.transform('map subject ids',HashLookup,:subject, map_subject_id,to: :subject_id)
	end

	source('enroll.txt',[],col_sep:"\t") do |s|
	    s.transform('Fill missing default fields', Fill, {
	    	year: 2019,
	    	date_valid: '2019-01-01 00:00:00',
			data_type: 'enrollment',
			data_type_id: 414,
			notes: 'DXT-3386: GA CSA',
			grade: 'NA',
			subject: 'Not Applicable'
	    })
	    .transform('rename columns',MultiFieldRenamer,{
			school_code: :school_id,
			school_name: :school_name,
			school_district_code: :district_id,
			school_district_name: :district_name
		})
		.transform('setting entity and state_id',WithBlock) do |row|
			if row[:district_name] == 'All Systems'
				row[:entity_type] = 'state'
				row[:state_id] = 'state'
			elsif row[:district_name] != 'All Systems' and row[:school_name] == 'All Schools'
				row[:entity_type] = 'district'
				row[:state_id] = row[:district_id]
			elsif row[:school_name] != 'All Schools'
				row[:entity_type] = 'school'
				row[:state_id] = row[:district_id] + row[:school_id].rjust(4,'0')
			end
			row
		end
		.transform('transpose breakdowns',Transposer,:breakdown,:value,:percent__all,:percent__male,:percent__female,:percent__free_reduced_lunch,:percent__lep,:percent__disability,:percent__hispanic,:percent__two,:percent__american_indian_or_alaskan_native,:percent__asian,:percent__black,:percent__white,:percent__pacific_islander)
		.transform('create breakdown',WithBlock) do |row|
			row[:breakdown] = row[:breakdown].to_s.split('__')[1]
			row
		end
		.transform('delete blank values',DeleteRows,:value,nil)
		.transform('matching cohort count',WithBlock) do |row|
			if row[:breakdown] == 'all'
				row[:cohort_count] = row[:total_high_school_graduates__total_all]
			elsif row[:breakdown] == 'male'
				row[:cohort_count] = row[:total_high_school_graduates__male]
			elsif row[:breakdown] == 'female'
				row[:cohort_count] = row[:total_high_school_graduates__female]
			elsif row[:breakdown] == 'free_reduced_lunch'
				row[:cohort_count] = row[:total_high_school_graduates__free_reduced_lunch]
			elsif row[:breakdown] == 'lep'
				row[:cohort_count] = row[:total_high_school_graduates__lep]
			elsif row[:breakdown] == 'disability'
				row[:cohort_count] = row[:total_high_school_graduates__disability]
			elsif row[:breakdown] == 'hispanic'
				row[:cohort_count] = row[:total_high_school_graduates__hispanic]
			elsif row[:breakdown] == 'two'
				row[:cohort_count] = row[:total_high_school_graduates__two]
			elsif row[:breakdown] == 'american_indian_or_alaskan_native'
				row[:cohort_count] = row[:total_high_school_graduates__american_indian_or_alaskan_native]
			elsif row[:breakdown] == 'asian'
				row[:cohort_count] = row[:total_high_school_graduates__asian]
			elsif row[:breakdown] == 'black'
				row[:cohort_count] = row[:total_high_school_graduates__black]
			elsif row[:breakdown] == 'white'
				row[:cohort_count] = row[:total_high_school_graduates__white]
			elsif row[:breakdown] == 'pacific_islander'
				row[:cohort_count] = row[:total_high_school_graduates__pacific_islander]
			end
			row
		end
		.transform('map breakdown ids',HashLookup,:breakdown, map_breakdown_id,to: :breakdown_id)
		.transform('map subject ids',HashLookup,:subject, map_subject_id,to: :subject_id)
	end

	source('persist.txt',[],col_sep:"\t") do |s|
	    s.transform('Fill missing default fields', Fill, {
	    	year: 2019,
	    	date_valid: '2019-01-01 00:00:00',
			data_type: 'persistence',
			data_type_id: 409,
			notes: 'DXT-3386: GA CSA',
			grade: 'NA',
			subject: 'Not Applicable'
	    })
	    .transform('rename columns',MultiFieldRenamer,{
			school_code: :school_id,
			school_name: :school_name,
			school_district_code: :district_id,
			school_district_name: :district_name
		})
		.transform('setting entity and state_id',WithBlock) do |row|
			if row[:district_name] == 'All Systems'
				row[:entity_type] = 'state'
				row[:state_id] = 'state'
			elsif row[:district_name] != 'All Systems' and row[:school_id] == 'ALL'
				row[:entity_type] = 'district'
				row[:state_id] = row[:district_id]
			elsif row[:school_id] != 'ALL'
				row[:entity_type] = 'school'
				row[:state_id] = row[:district_id] + row[:school_id].rjust(4,'0')
			end
			row
		end
		.transform('transpose breakdowns',Transposer,:breakdown,:value,:percent__all,:percent__male,:percent__female,:percent__free_reduced_lunch,:percent__lep,:percent__disability,:percent__hispanic,:percent__two,:percent__american_indian_or_alaskan_native,:percent__asian,:percent__black,:percent__white,:percent__pacific_islander)
		.transform('create breakdown',WithBlock) do |row|
			row[:breakdown] = row[:breakdown].to_s.split('__')[1]
			row
		end
		.transform('delete blank values',DeleteRows,:value,nil)
		.transform('matching cohort count',WithBlock) do |row|
			if row[:breakdown] == 'all'
				row[:cohort_count] = row[:number_of_high_school_graduates_enrolled_in_postsecondary_institution__total_all]
			elsif row[:breakdown] == 'male'
				row[:cohort_count] = row[:number_of_high_school_graduates_enrolled_in_postsecondary_institution__male]
			elsif row[:breakdown] == 'female'
				row[:cohort_count] = row[:number_of_high_school_graduates_enrolled_in_postsecondary_institution__female]
			elsif row[:breakdown] == 'free_reduced_lunch'
				row[:cohort_count] = row[:number_of_high_school_graduates_enrolled_in_postsecondary_institution__free_reduced_lunch]
			elsif row[:breakdown] == 'lep'
				row[:cohort_count] = row[:number_of_high_school_graduates_enrolled_in_postsecondary_institution__lep]
			elsif row[:breakdown] == 'disability'
				row[:cohort_count] = row[:number_of_high_school_graduates_enrolled_in_postsecondary_institution__disability]
			elsif row[:breakdown] == 'hispanic'
				row[:cohort_count] = row[:number_of_high_school_graduates_enrolled_in_postsecondary_institution__hispanic]
			elsif row[:breakdown] == 'two'
				row[:cohort_count] = row[:number_of_high_school_graduates_enrolled_in_postsecondary_institution__two]
			elsif row[:breakdown] == 'american_indian_or_alaskan_native'
				row[:cohort_count] = row[:number_of_high_school_graduates_enrolled_in_postsecondary_institution__american_indian_or_alaskan_native]
			elsif row[:breakdown] == 'asian'
				row[:cohort_count] = row[:number_of_high_school_graduates_enrolled_in_postsecondary_institution__asian]
			elsif row[:breakdown] == 'black'
				row[:cohort_count] = row[:number_of_high_school_graduates_enrolled_in_postsecondary_institution__black]
			elsif row[:breakdown] == 'white'
				row[:cohort_count] = row[:number_of_high_school_graduates_enrolled_in_postsecondary_institution__white]
			elsif row[:breakdown] == 'pacific_islander'
				row[:cohort_count] = row[:number_of_high_school_graduates_enrolled_in_postsecondary_institution__pacific_islander]
			end
			row
		end
		.transform('map breakdown ids',HashLookup,:breakdown, map_breakdown_id,to: :breakdown_id)
		.transform('map subject ids',HashLookup,:subject, map_subject_id,to: :subject_id)
	end

	source('remed.txt',[],col_sep:"\t") do |s|
	    s.transform('Fill missing default fields', Fill, {
	    	year: 2018,
	    	date_valid: '2018-01-01 00:00:00',
			data_type: 'remediation',
			data_type_id: 413,
			notes: 'DXT-3386: GA CSA',
			grade: 'NA',
			breakdown: 'All Students'
	    })
	    .transform('rename columns',MultiFieldRenamer,{
			instn_number_hsg: :school_id,
			instn_name_hsg: :school_name,
			school_distrct_cd_hsg: :district_id,
			school_dstrct_nm_hsg: :district_name,
			total_count: :cohort_count,
			program_percent: :value
		})
		.transform('setting entity and state_id',WithBlock) do |row|
			if row[:district_name] == 'State of Georgia' and row[:school_year_hsg] == '2017'
				row[:entity_type] = 'state'
				row[:state_id] = 'state'
			elsif row[:district_name] != 'State of Georgia' and row[:school_year_hsg] == '2017' and row[:school_id] == 'ALL'
				row[:entity_type] = 'district'
				row[:state_id] = row[:district_id]
			elsif row[:school_year_hsg] == '2017' and row[:school_id] != 'ALL'
				row[:entity_type] = 'school'
				row[:state_id] = row[:district_id] + row[:school_id].rjust(4,'0')
			end
			row
		end
		.transform('delete other years',DeleteRows,:entity_type,nil)
		.transform('transpose subjects',Transposer,:subject,:value,:ls_eng_pct,:ls_math_pct)
		.transform('map breakdown ids',HashLookup,:breakdown, map_breakdown_id,to: :breakdown_id)
		.transform('map subject ids',HashLookup,:subject, map_subject_id,to: :subject_id)
	end

	def config_hash
	{
		source_id: 14,
        state: 'ga'
	}
	end
end

GAMetricsProcessor2019CSA.new(ARGV[0],max:nil).run