require 'set'
require_relative '../../metrics_processor'

class MOMetricsProcessor2019CollegeReadiness < GS::ETL::MetricsProcessor

	def initialize(*args)
		super
		@year = 2019
		@ticket_n = 'DXT-3516'
	end

	map_subject_id = {
	  'composite' => 1,
	  :composite => 1,
	  :english => 17,
	  :reading => 2,
	  :math => 5,
	  :science => 19,
	  'na' => 0
	}

	map_breakdown_id = {
	  'All Students' => 1,
	  'all' => 1,
	  'black' => 17,
	  'frl' => 23,
	  'hispanic' => 19,
	  'iep' => 27,
	  'lep' => 32, 
	  'white' => 21,
	  'ell' => 32,
	  'Total' => 1, 
	  'Female' => 26, 
	  'Male' => 25, 
	  'American Indian or Alaskan Native' => 18, 
	  'Asian' => 16, 
	  'Black (Not Hispanic)' => 17, 
	  'Hawaiian or Pacific Islander' => 20, 
	  'Hispanic' => 19, 
	  'Multi-Race' => 22, 
	  'White (Not Hispanic)' => 21,
	  'IEP Total' => 27, 
	  'No' => 33, 
	  'Yes' => 32
	}

	map_grade = {
	  'average ACT score' => 'All',
	  'graduation rate' => 'NA',
	  :overall_college_enrollment => 'NA',
	  :four_year_college_enrollment => 'NA',
	  :two_year_college_enrollment => 'NA'
	}

	map_data_type_id = {
	  'average ACT score' => 448,
	  'graduation rate' => 443,
	  :overall_college_enrollment => 485,
	  :four_year_college_enrollment => 478,
	  :two_year_college_enrollment => 476
	}

	source('Building ACT Results.txt',[],col_sep:"\t") do |s|
	    s.transform('Fill missing default fields', Fill, {
		  entity_type: 'school',
		  data_type: 'average ACT score',
		  breakdown: 'All Students'
	    })
	    .transform('rename columns',MultiFieldRenamer, {
		  county_district_code: :district_id,
		  school_code: :school_id,
		  act_tests_administered: :cohort_count,
		  act_composite_score: :composite,
		  act_english_score: :english,
		  act_math_score: :math,
		  act_reading_score: :reading,
		  act_science_score: :science
	    })
	    .transform('Transpose subject columns for values to load', 
	     Transposer, 
		  :subject,:value,
		  :composite, :english, :math, :reading, :science
	     )
	end
	source('District ACT Results.txt',[],col_sep:"\t") do |s|
	    s.transform('Fill missing default fields', Fill, {
		  entity_type: 'district',
		  data_type: 'average ACT score',
		  breakdown: 'All Students'
	    })
	    .transform('rename columns',MultiFieldRenamer, {
		  county_district_code: :district_id,
		  act_tests_administered: :cohort_count,
		  act_composite_score: :composite,
		  act_english_score: :english,
		  act_math_score: :math,
		  act_reading_score: :reading,
		  act_science_score: :science
	    })
	    .transform('Transpose subject columns for values to load', 
	     Transposer, 
		  :subject,:value,
		  :composite, :english, :math, :reading, :science
	     )
	end
	source('STATE_ACT_20182019.txt',[],col_sep:"\t") do |s|
	    s.transform('Fill missing default fields', Fill, {
		  entity_type: 'state',
		  data_type: 'average ACT score',
		  breakdown: 'All Students',
		  subject: 'composite',
		  cohort_count: 'NULL'
	    })
	    .transform('rename columns',MultiFieldRenamer, {
		  state_act_composite_average: :value
	    })
	end
	source('Building Adjusted Cohort Graduation Rate.txt',[],col_sep:"\t") do |s|
	    s.transform('Fill missing default fields', Fill, {
		  entity_type: 'school',
		  data_type: 'graduation rate',
		  subject: 'na'
	    })
	    .transform('rename columns',MultiFieldRenamer, {
		  county_district_code: :district_id,
		  school_code: :school_id
	    })
	    .transform('Transpose wide subgroup values',
	     Transposer, 
		  :subgroup_value_name,:value,
		  :graduation_rate_4yr_cohort,:black_graduation_rate_4yr_cohort,
		  :hispanic_graduation_rate_4yr_cohort,:white_graduation_rate_4yr_cohort,
		  :iep_graduation_rate_4yr_cohort,:lep_graduation_rate_4yr_cohort,
		  :frl_graduation_rate_4yr_cohort
	     )
	end
	source('District Adjusted Cohort Graduation Rate.txt',[],col_sep:"\t") do |s|
	    s.transform('Fill missing default fields', Fill, {
		  entity_type: 'district',
		  data_type: 'graduation rate',
		  subject: 'na'
	    })
	    .transform('rename columns',MultiFieldRenamer, {
		  county_district_code: :district_id
	    })
	    .transform('Transpose wide subgroup values',
	     Transposer, 
		  :subgroup_value_name,:value,
		  :graduation_rate_4yr_cohort,:black_graduation_rate_4yr_cohort,
		  :hispanic_graduation_rate_4yr_cohort,:white_graduation_rate_4yr_cohort,
		  :iep_graduation_rate_4yr_cohort,:lep_graduation_rate_4yr_cohort,
		  :frl_graduation_rate_4yr_cohort
	     )
	end
	source('STATE_GRADUATION_20182019.txt',[],col_sep:"\t") do |s|
	    s.transform('Fill missing default fields', Fill, {
		  entity_type: 'state',
		  data_type: 'graduation rate',
		  subject: 'na'
	    })
	    .transform('rename columns',MultiFieldRenamer, {
		  graduation_rate: :value,
		  subgroup: :breakdown
	    })
	    .transform('Replace bad cohort count values', WithBlock) do |row|
			if row[:cohort_count] == '.'
				row[:cohort_count] = 'NULL'
			elsif row[:cohort_count] != '.'
				row[:cohort_count] = row[:cohort_count]
			end
			row
		end
	end
	source('Building Graduate Follow-up.txt',[],col_sep:"\t") do |s|
	    s.transform('Fill missing default fields', Fill, {
		  entity_type: 'school',
		  subject: 'na',
		  breakdown: 'All Students'
	    })
	    .transform('rename columns',MultiFieldRenamer, {
		  county_district_code: :district_id,
		  school_code: :school_id,
		  graduates_previous_year: :cohort_count,
		  graduate_followup_college_pct: :overall_college_enrollment,
		  graduate_followup_4yr_pct: :four_year_college_enrollment,
		  graduate_followup_2yr_pct: :two_year_college_enrollment
	    })
	    .transform('Transpose wide subgroup value columns', 
	     Transposer, 
		  :data_type,:value,
		  :overall_college_enrollment,:four_year_college_enrollment,
		  :two_year_college_enrollment
	     )
	end
	source('District Graduate Follow-up.txt',[],col_sep:"\t") do |s|
	    s.transform('Fill missing default fields', Fill, {
		  entity_type: 'district',
		  subject: 'na',
		  breakdown: 'All Students'
	    })
	    .transform('rename columns',MultiFieldRenamer, {
		  county_district_code: :district_id,
		  graduates_previous_year: :cohort_count,
		  graduate_followup_college_pct: :overall_college_enrollment,
		  graduate_followup_4yr_pct: :four_year_college_enrollment,
		  graduate_followup_2yr_pct: :two_year_college_enrollment
	    })
	    .transform('Transpose wide subgroup value columns', 
	     Transposer, 
		  :data_type,:value,
		  :overall_college_enrollment,:four_year_college_enrollment,
		  :two_year_college_enrollment
	     )
	end
	source('LEA Follow Up Public.txt',[],col_sep:"\t") do |s|
	    s.transform('Fill missing default fields', Fill, {
		  entity_type: 'state',
		  subject: 'na'
	    })
	     .transform('rename columns',MultiFieldRenamer, {
		  county_district_code: :district_id,
		  exit_year: :year,
		  num_of_exiters: :cohort_count,
		  subgroup: :breakdown,
		  pct_2_yr: :two_year_college_enrollment,
		  pct_4_yr: :four_year_college_enrollment
	     })
	     .transform('Create combined college enrollment, fix 2 and 4 year enrollment', WithBlock) do |row|
		   row[:overall_college_enrollment] = row[:two_year_college_enrollment].to_f + row[:four_year_college_enrollment].to_f
		   row[:two_year_college_enrollment] = row[:two_year_college_enrollment].to_f
		   row[:four_year_college_enrollment] = row[:four_year_college_enrollment].to_f
		   row
		   end
	     .transform('Transpose wide college data types into long',
	       Transposer,
		    :data_type,:value,
		    :overall_college_enrollment,:four_year_college_enrollment,
		    :two_year_college_enrollment)
	end

	shared do |s|
		s.transform('fill other columns',Fill,{
			notes: 'DXT-3516: MO CSA'
		})
		.transform('Create subgroup field for wide subgroups', WithBlock) do |row|
			if row[:data_type] == 'graduation rate'
				if row[:entity_type] != 'state'
					if row[:subgroup_value_name] == :graduation_rate_4yr_cohort
						row[:breakdown] = 'All Students'
						row[:cohort_count] = row[:adjusted_4yr_cohort]
					elsif [:black_graduation_rate_4yr_cohort,:hispanic_graduation_rate_4yr_cohort,:white_graduation_rate_4yr_cohort,:iep_graduation_rate_4yr_cohort,:lep_graduation_rate_4yr_cohort,:frl_graduation_rate_4yr_cohort].include? row[:subgroup_value_name]
						m = row[:subgroup_value_name].match /^([a-z]+)_graduation_rate_4yr_cohort$/
						row[:breakdown] = m[1]
						if m[1] == 'black'
							row[:cohort_count] = row[:black_adjusted_4yr_cohort]
						elsif m[1] == 'hispanic'
							row[:cohort_count] = row[:hispanic_adjusted_4yr_cohort]
						elsif m[1] == 'white'
							row[:cohort_count] = row[:white_adjusted_4yr_cohort]
						else
							row[:cohort_count] = 'NULL'
						end
					else
						row[:breakdown] = 'Error'
					end
				elsif row[:entity_type] == 'state'
					row[:breakdown] = row[:breakdown]
				end
			elsif row[:data_type] != 'graduation rate'
				row[:breakdown] = row[:breakdown]
			end
			row
		end
		.transform('Create skip field for year', WithBlock) do |row|
			if row[:year] != '2019'
				row[:skip] = 'Y'
			else
				row[:skip] = 'N'
			end
			row
		end
		.transform('Add bad subgroups to skip field', WithBlock) do |row|
			if ['Dropout **','Autism','Deaf/Blindness','Emotional Disturbance','Hearing impairment','Intellectual Disability','Language Impairment','Multiple Disabilities','Orthopedic Impairment','Other Health Impairment','Specific Learning Disability','Speech Impairment','Traumatic Brain Injury','Visual Impairment','Exit Status', '','Graduate','Gender','Race','IEP Disability','LEP/ELL','** - Dropouts include IEP students in grades 9-12 who dropped out, and CTE Concentrators who obtained a high school equivalency certificate."'].include? row[:breakdown]
				row[:skip] = 'Y'
			elsif row[:skip] == 'Y'
				row[:skip] = 'Y'
			else
				row[:skip] = 'N'
			end
			row
		end
		.transform('Create state id field', WithBlock) do |row|
			if ['average ACT score','graduation rate',:overall_college_enrollment,:four_year_college_enrollment,:two_year_college_enrollment].include? row[:data_type]
				if row[:entity_type] == 'school'
					row[:state_id] = row[:school_id].to_s + row[:district_id].to_s
				elsif row[:entity_type] == 'district'
					row[:state_id] = row[:district_id]
				elsif row[:entity_type] == 'state'
					row[:state_id] = 'state'
				else 'Error'
				end
			end
			row
		end
		.transform('Create date_valid', WithBlock) do |row|
			if row[:year] == '2019'
				row[:date_valid] = '2019-01-01 00:00:00'
			else
				row[:date_valid] = 'Error'
			end
			row
		end
		.transform('Remove quotes and commas from cohort count', WithBlock) do |row|
			row[:cohort_count] = row[:cohort_count].to_s.gsub("\"","")
			row[:cohort_count] = row[:cohort_count].to_s.gsub(",","")
			row
		end
		.transform('delete blank values',DeleteRows,:value,'NULL')
		.transform('delete "*" values',DeleteRows,:value,'*')
		.transform('delete "." values',DeleteRows,:value,'.')
		.transform('skip values that have "Y" in skip field', DeleteRows, :skip, 'Y')
		.transform('map breakdown ids',HashLookup,:breakdown, map_breakdown_id,to: :breakdown_id)
		.transform('map subject ids',HashLookup,:subject, map_subject_id,to: :subject_id)
		.transform('map grades',HashLookup,:data_type, map_grade,to: :grade)
		.transform('map data type ids',HashLookup,:data_type, map_data_type_id,to: :data_type_id)
	end

	def config_hash
	{
		source_id: 29,
		state: 'mo'
	}
	end
end

MOMetricsProcessor2019CollegeReadiness.new(ARGV[0],max:nil).run