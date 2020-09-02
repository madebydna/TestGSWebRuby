require_relative '../../metrics_processor'

class COMetricsProcessor2019CollegeReadiness < GS::ETL::MetricsProcessor

	def initialize(*args)
		super
		@year = 2019
		@ticket_n = 'DXT-3610'
	end

	map_breakdown_id = {
		#grad, SAT shared breakdowns
		'All Students' => 1, 
		'Female' => 26,
		'Male' => 25,
		'Asian' => 16,
		'White' => 21,
		'Limited English Proficient' => 32,
		#grad only breakdowns
		'American Indian Or Alaska Native' => 18,
		'Black Or African American' => 17,
		'Native Hawaiian Or Other Pacific Islander' => 20,
		'Two Or More Races' => 22,
		'Hispanic Or Latino' => 19,
		'Econ Disadvant' => 23,
		'Students With Disabilities' => 27,
		#SAT only breakdowns
		'Two or More Races' => 22,
		'American Indian or Alaska Native' => 18,
		'Hawaiian/Pacific Islander' => 20,
		'Black' => 17,
		'Hispanic' => 19,
		'Free/Reduced Lunch Eligible' => 23,
		'Not Free/Reduced Lunch Eligible' => 24,
		'IEP' => 27,
		'No IEP' => 30,
		'English Learner (EL)' => 32,
		'Not English Learner (Not EL)' => 33,
		'Econ. Disadvant.' => 23,
		'Students with Disabilities' => 27
	}

	map_subject_id = {
		#grad
		'NA' => 0,
		#SAT
		'Total' => 1,
		'Evidence Based Reading & Writing' => 2,
		'Mathematics' => 5
	}

#grad files
#school level
	source('grad_school_race_gender.txt',[],col_sep:"\t") do |s|
	s.transform('Fill missing default fields', Fill, {
		entity_type: 'school',
		data_type: 'graduation rate',
		data_type_id: 443,
		subject: 'NA',
		grade: 'NA'
	})
	.transform('rename columns',MultiFieldRenamer, {
		organization_code: :district_id,
		school_code: :school_id
	})
	.transform('Transpose wide subgroups into long',Transposer,
		:subgroup_data_type,:value,
		:all_students_graduation_rate,
		:female_graduation_rate,:male_graduation_rate,
		:american_indian_or_alaska_native_graduation_rate,:asian_graduation_rate,:black_or_african_american_graduation_rate,:hispanic_or_latino_graduation_rate,:white_graduation_rate,:native_hawaiian_or_other_pacific_islander_graduation_rate,:two_or_more_races_graduation_rate
		)
	.transform('delete unwanted grad cohort values',DeleteRows,:class_of_anticipated_year_of_graduation_cohort,'2015-2016','2016-2017','2017-2018','ANTICIPATED_YEAR_OF_GRADUATION')
	.transform('delete empty rows',DeleteRows,:district_id,nil)
	.transform('Skip district totals and dropout totals in school file',DeleteRows,:school_id,'9998','0000')
	.transform('Skip duplicative Yampah Mountain School',DeleteRows,:school_id,'6134','3393','4699')
	end
	source('grad_school_ipst.txt',[],col_sep:"\t") do |s|
	s.transform('Fill missing default fields', Fill, {
		entity_type: 'school',
		data_type: 'graduation rate',
		data_type_id: 443,
		subject: 'NA',
		grade: 'NA'
	})
	.transform('rename columns',MultiFieldRenamer, {
		organization_code: :district_id,
		school_code: :school_id
	})
	.transform('Transpose wide subgroups into long',Transposer,
		:subgroup_data_type,:value,
		:students_with_disabilities_graduation_rate,:limited_english_proficient_graduation_rate,:econ_disadvant_graduation_rate
		)
	.transform('delete unwanted grad cohort values',DeleteRows,:class_of_anticipated_year_of_graduation_cohort,'2015-2016','2016-2017','2017-2018','ANTICIPATED_YEAR_OF_GRADUATION')
	.transform('delete empty rows',DeleteRows,:district_id,nil)
	.transform('Skip district totals and dropout totals in school file',DeleteRows,:school_id,'9998','0000')
	.transform('Skip duplicative Yampah Mountain School',DeleteRows,:school_id,'6134','3393','4699')
	end
#district,state level
	source('grad_district_race_gender.txt',[],col_sep:"\t") do |s|
	s.transform('Fill missing default fields', Fill, {
		data_type: 'graduation rate',
		data_type_id: 443,
		subject: 'NA',
		grade: 'NA'
	})
	.transform('rename columns',MultiFieldRenamer, {
		organization_code: :district_id
	})
	.transform('Assign entity_type',WithBlock) do |row|
		if row[:district_id] == '9999'
			row[:entity_type] = 'state'
		elsif row[:district_id] != '9999'
			row[:entity_type] = 'district'
		else
			row[:entity_type] = 'Error'
		end
		row
	end
	.transform('Transpose wide subgroups into long',Transposer,
		:subgroup_data_type,:value,
		:all_students_graduation_rate,
		:female_graduation_rate,:male_graduation_rate,
		:american_indian_or_alaska_native_graduation_rate,:asian_graduation_rate,:black_or_african_american_graduation_rate,:hispanic_or_latino_graduation_rate,:white_graduation_rate,:native_hawaiian_or_other_pacific_islander_graduation_rate,:two_or_more_races_graduation_rate
		)
	.transform('delete unwanted grad cohort values',DeleteRows,:class_of_anticipated_year_of_graduation_cohort,'2015-2016','2016-2017','2017-2018','ANTICIPATED_YEAR_OF_GRADUATION')
	.transform('delete empty rows',DeleteRows,:district_id,nil,'x00')
	end
	source('grad_district_ipst.txt',[],col_sep:"\t") do |s|
	s.transform('Fill missing default fields', Fill, {
		data_type: 'graduation rate',
		data_type_id: 443,
		subject: 'NA',
		grade: 'NA'
	})
	.transform('rename columns',MultiFieldRenamer, {
		organization_code: :district_id
	})
	.transform('Assign entity_type',WithBlock) do |row|
		if row[:district_id] == '9999'
			row[:entity_type] = 'state'
		elsif row[:district_id] != '9999'
			row[:entity_type] = 'district'
		else
			row[:entity_type] = 'Error'
		end
		row
	end
	.transform('Transpose wide subgroups into long',Transposer,
		:subgroup_data_type,:value,
		:students_with_disabilities_graduation_rate,:limited_english_proficient_graduation_rate,:econ_disadvant_graduation_rate
		)
	.transform('delete unwanted grad cohort values',DeleteRows,:class_of_anticipated_year_of_graduation_cohort,'2015-2016','2016-2017','2017-2018','ANTICIPATED_YEAR_OF_GRADUATION')
	.transform('delete empty rows',DeleteRows,:district_id,nil,'x00')
	end
#SAT files
	source('SAT_allstudents.txt',[],col_sep:"\t") do |s|
	s.transform('Fill missing default fields', Fill, {
		breakdown: 'All Students',
		grade: 'All'
	})
	.transform('rename columns',MultiFieldRenamer, {
		level: :entity_type,
		district_code: :district_id,
		school_code: :school_id
	})
	.transform('Transpose wide subjects and data types into long',Transposer,
		:subject_data_type,:value,
		:participation_rate,
		:total_score_mean_score,:evidencebased_reading__writing_mean_score,:mathematics_mean_score
	)
	end
	source('SAT_gender.txt',[],col_sep:"\t") do |s|
	s.transform('Fill missing default fields', Fill, {
		grade: 'All'
	})
	.transform('rename columns',MultiFieldRenamer, {
		level: :entity_type,
		district_code: :district_id,
		school_code: :school_id,
		gender: :breakdown
	})
	.transform('Transpose wide subjects and data types into long',Transposer,
		:subject_data_type,:value,
		:participation_rate,
		:total_score_mean_score,:evidencebased_reading_and_writing_mean_score,:mathematics_mean_score
	)
	end
	source('SAT_frl.txt',[],col_sep:"\t") do |s|
	s.transform('Fill missing default fields', Fill, {
		grade: 'All'
	})
	.transform('rename columns',MultiFieldRenamer, {
		level: :entity_type,
		district_code: :district_id,
		school_code: :school_id,
		freereduced_lunch_status: :breakdown
	})
	.transform('Transpose wide subjects and data types into long',Transposer,
		:subject_data_type,:value,
		:participation_rate,
		:total_score_mean_score,:evidencebased_reading_and_writing_mean_score,:mathematics_mean_score
	)
	end
	source('SAT_race.txt',[],col_sep:"\t") do |s|
	s.transform('Fill missing default fields', Fill, {
		grade: 'All'
	})
	.transform('rename columns',MultiFieldRenamer, {
		level: :entity_type,
		district_code: :district_id,
		school_code: :school_id,
		raceethnicity: :breakdown
	})
	.transform('Transpose wide subjects and data types into long',Transposer,
		:subject_data_type,:value,
		:participation_rate,
		:total_score_mean_score,:evidencebased_reading_and_writing_mean_score,:mathematics_mean_score
	)
	end
	source('SAT_ell.txt',[],col_sep:"\t") do |s|
	s.transform('Fill missing default fields', Fill, {
		grade: 'All'
	})
	.transform('rename columns',MultiFieldRenamer, {
		level: :entity_type,
		district_code: :district_id,
		school_code: :school_id,
		language_proficiency: :breakdown
	})
	.transform('Transpose wide subjects and data types into long',Transposer,
		:subject_data_type,:value,
		:participation_rate,
		:total_score_mean_score,:evidencebased_reading_and_writing_mean_score,:mathematics_mean_score
	)
	end
	source('SAT_iep.txt',[],col_sep:"\t") do |s|
	s.transform('Fill missing default fields', Fill, {
		grade: 'All'
	})
	.transform('rename columns',MultiFieldRenamer, {
		level: :entity_type,
		district_code: :district_id,
		school_code: :school_id,
		iep_status: :breakdown
	})
	.transform('Transpose wide subjects and data types into long',Transposer,
		:subject_data_type,:value,
		:participation_rate,
		:total_score_mean_score,:evidencebased_reading_and_writing_mean_score,:mathematics_mean_score
	)
	end


	shared do |s|
		s.transform('fill other columns',Fill,{
			notes: 'DXT-3610: CO College Readiness',
			year: 2019,
			date_valid: '2019-01-01 00:00:00'
		})
		.transform('create state_id field', WithBlock) do |row|
			row[:entity_type].to_s.downcase!
			if row[:entity_type] == 'state'
				row[:state_id] = 'state'
			elsif row[:entity_type] == 'district'
				row[:state_id] = row[:district_id]
			elsif row[:entity_type] == 'school'
				row[:state_id] = row[:school_id]
			end
			row
		end
		.transform('Create breakdown field', WithBlock) do |row|
			if row[:data_type_id] == 443
				m = row[:subgroup_data_type].match /^(.*)_graduation_rate$/
				row[:breakdown] = m[1].to_s.split('_').map(&:capitalize).join(' ')
			elsif [439,446].include? row[:data_type_id]
				row[:breakdown] = row[:breakdown]
			end
			row
		end
		.transform('Assign cohort count value', WithBlock) do |row|
			if row[:data_type_id] == 443
				if row[:breakdown] == 'All Students'
					row[:cohort_count] = row[:all_students_final_grad_base]
				elsif row[:breakdown] == 'Female'
					row[:cohort_count] = row[:female_final_grad_base]
				elsif row[:breakdown] == 'Male'
					row[:cohort_count] = row[:male_final_grad_base]
				elsif row[:breakdown] == 'American Indian Or Alaska Native'
					row[:cohort_count] = row[:american_indian_or_alaska_native_final_grad_base]
				elsif row[:breakdown] == 'Asian'
					row[:cohort_count] = row[:asian_final_grad_base]
				elsif row[:breakdown] == 'White' 
					row[:cohort_count] = row[:white_final_grad_base]
				elsif row[:breakdown] == 'Two Or More Races'
					row[:cohort_count] = row[:two_or_more_races_final_grad_base]
				elsif row[:breakdown] == 'Students With Disabilities'
					row[:cohort_count] = row[:students_with_disabilities_final_grad_base]
				elsif row[:breakdown] == 'Limited English Proficient'
					row[:cohort_count] = row[:limited_english_proficient_final_grad_base]
				elsif row[:breakdown] == 'Econ Disadvant'
					row[:cohort_count] = row[:econ_disadvant_final_grad_base]
				elsif row[:breakdown] == 'Black Or African American'
					row[:cohort_count] = row[:black_or_african_american_final_grad_base]
				elsif row[:breakdown] == 'Native Hawaiian Or Other Pacific Islander'
					row[:cohort_count] = row[:native_hawaiian_or_other_pacific_islander_grad_base]
				elsif row[:breakdown] == 'Hispanic Or Latino'
					row[:cohort_count] = row[:hispanic_or_latino_final_grad_base]
				end
			else
				row[:cohort_count] = row[:cohort_count]
			end
			row
		end
		.transform('Create data type and subject field, assign cohort count',WithBlock) do |row| #SAT files only
			if row[:subject_data_type] == :participation_rate
				row[:data_type] = 'SAT participation'
				row[:data_type_id] = 439
				row[:subject] = 'Total'
				row[:cohort_count] = row[:number_of_total_records]
			elsif [:total_score_mean_score,:evidencebased_reading__writing_mean_score,:evidencebased_reading_and_writing_mean_score,:mathematics_mean_score].include? row[:subject_data_type]
				row[:data_type] = 'SAT average score'
				row[:data_type_id] = 446
				row[:cohort_count] = row[:number_of_valid_scores]
				if row[:subject_data_type] == :total_score_mean_score
					row[:subject] = 'Total'
				elsif [:evidencebased_reading_and_writing_mean_score,:evidencebased_reading__writing_mean_score].include? row[:subject_data_type]
					row[:subject] = 'Evidence Based Reading & Writing'
				elsif row[:subject_data_type] == :mathematics_mean_score
					row[:subject] = 'Mathematics'
				end
			end
			row
		end
		.transform('Adjust values and cohort counts to remove quotes, commas, and '%' symbols', WithBlock) do |row|
			row[:value] = row[:value].to_s.gsub("%","")
			row[:cohort_count] = row[:cohort_count].to_s.gsub("\"","").gsub(",","").gsub(" ","")
			row
		end
		.transform('Skip bad breakdowns',DeleteRows,:breakdown,'Not Reported','Not Reported/Not Applicable','EL: LEP','EL: NEP','"Not EL: FEP, FELL"','"Not EL: PHLOTE, NA, Not Reported"') #SAT only
		.transform('delete PSAT values',DeleteRows,:test,'PSAT') #SAT files only
		.transform('delete blank values',DeleteRows,:value,nil,'NA','- -')
		.transform('map breakdown ids',HashLookup,:breakdown, map_breakdown_id,to: :breakdown_id)
		.transform('map subject ids',HashLookup,:subject, map_subject_id,to: :subject_id)
	end


	def config_hash
	{
		source_id: 9,
		state: 'co'
	}
	end
end

COMetricsProcessor2019CollegeReadiness.new(ARGV[0],max:nil).run