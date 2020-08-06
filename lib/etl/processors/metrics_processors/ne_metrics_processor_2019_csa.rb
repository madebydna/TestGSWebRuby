require 'set'
require_relative '../../metrics_processor'

class NEMetricsProcessor2019CSA < GS::ETL::MetricsProcessor

	def initialize(*args)
		super
		@year = 2019
		@ticket_n = 'DXT-3561'
	end

	map_subject_id = {
	'Composite' => 1,
	'NA' => 0
	}

	map_breakdown_id = {
	#ACT
	'All Students' => 1,
	#grad
	'All students' => 1,
	'English Language Learners' => 32,
	'Ethnic7 - American Indian or Alaska Native' => 18,
	'Ethnic7 - Asian' => 16,
	'Ethnic7 - Black or African American' => 17,
	'Ethnic7 - Hispanic or Latino' => 19,
	'Ethnic7 - Native Hawaiian or Other Pacific Islander' => 20,
	'Ethnic7 - Two or More Races' => 22,
	'Ethnic7 - White' => 21,
	'Female' => 26,
	'Male' => 25,
	'Special Education Students' => 27,
	'Students eligible for free and reduced lunch' => 23,
	#college enrollment and peristence
	'Not ELL' => 33,
	'ELL' => 32,
	'Not FRL' => 24,
	'FRL' => 23,
	'American Indian or Alaska Native' => 18,
	'Asian' => 16,
	'Black or African American' => 17,
	'Hispanic' => 19,
	'Native Hawaiian or Other Pacific Islander' => 20,
	'Two Or More Races' => 22,
	'White' => 21,
	'Not special education' => 30,
	'Special education' => 27
	}

	map_grade = {
	448 => 'All',
	443 => 'NA',
	414 => 'NA',
	409 => 'NA'
	}

	source('ACT_Composite_20182019.txt',[],col_sep:"\t") do |s|
	s.transform('Fill missing default fields', Fill, {
		data_type: 'ACT average score',
		data_type_id: 448,
		breakdown: 'All Students',
		subject: 'Composite'
	})
	.transform('rename columns',MultiFieldRenamer, {
		datayears: :year,
		level: :entity_type,
		students_with_composite_scores: :cohort_count,
		average_composite_score: :value,
		county: :county_id,
		district: :district_id,
		school: :school_id,
		name: :entity_name
	})
	.transform('Create field to skip duplicative state rows', WithBlock) do |row|
		if row[:entity_name] == 'STATE OF NEBRASKA'
			if row[:entity_type] == 'ST'
				row[:entity_type] = row[:entity_type]
			else
				row[:entity_type] = 'Skip'
			end
		end
		row
	end
	.transform('delete duplicative state rows',DeleteRows,:entity_type,'Skip')
	end
	source('Cohort_20182019.txt',[],col_sep:"\t") do |s|
	s.transform('Fill missing default fields', Fill, {
		data_type: 'graduation rate',
		data_type_id: 443,
		subject: 'NA'
	})
	.transform('rename columns',MultiFieldRenamer, {
		school_year: :year,
		type: :entity_type,
		graduation_count: :cohort_count,
		graduation_pct: :value,
		description: :breakdown,
		county: :county_id,
		district: :district_id,
		school: :school_id,
		agency_name: :entity_name
	})
	.transform('Assign skip to bad cohort years', WithBlock) do |row|
		if row[:graduation_cohort].to_i <= 2018
			row[:graduation_cohort] = 'Skip'
		else
			row[:graduation_cohort] = row[:graduation_cohort]
		end
		row
	end
	.transform('delete bad cohort values',DeleteRows,:graduation_cohort,'Skip')
	.transform('Adjust to percent values', WithBlock) do |row|
		if row[:value] == '-1.00'
			row[:value] = row[:value]
		else
			row[:value] = row[:value].to_f * 100
		end
		row
	end
	end
	source('NE 2019 College Enrollment & Persistence.txt',[],col_sep:"\t") do |s|
	s.transform('Fill missing default fields', Fill, {
		subject: 'NA',
		cohort_count: 'NULL'
	})
	.transform('rename columns',MultiFieldRenamer, {
		level: :entity_type,
		district: :district_name,
		school: :school_name
	})
	.transform('Transpose wide college data types into long',
	Transposer,
		:data_type,:value,
		:collegeenrollmentrate,:collegepersistencerate
		)
	.transform('Assign data type ids and years', WithBlock) do |row|
		if row[:data_type] == :collegeenrollmentrate
			row[:data_type_id] = 414
			row[:year] = 2017
		elsif row[:data_type] == :collegepersistencerate
			row[:data_type_id] = 409
			row[:year] = 2018
		end
		row
	end
	.transform('Create breakdown field from subgroup and group field', WithBlock) do |row|
		if row[:subgroup] == 'All Students'
			row[:breakdown] = row[:subgroup]
		elsif row[:subgroup] == 'English Learner'
			if row[:group] == 'No'
				row[:breakdown] = 'Not ELL'
			elsif row[:group] == 'Yes'
				row[:breakdown] = 'ELL'
			end
		elsif row[:subgroup] == 'Food Program Eligible'
			if row[:group] == 'No'
				row[:breakdown] = 'Not FRL'
			elsif row[:group] == 'Yes'
				row[:breakdown] = 'FRL'
			end
		elsif row[:subgroup] == 'Special Education'
			if row[:group] == 'No'
				row[:breakdown] = 'Not special education'
			elsif row[:group] == 'Yes'
				row[:breakdown] = 'Special education'
			end
		elsif row[:subgroup] == 'Race/Ethnicity'
			row[:breakdown] = row[:group]
		else
			row[:breakdown] == row[:breakdown]
		end
		row
	end
	end

	shared do |s|
		s.transform('fill other columns',Fill,{
			notes: 'DXT-3561: NE CSA'
		})
		.transform('Create entity_type field', WithBlock) do |row|
			if row[:entity_type] == 'ST'
				row[:entity_type] = 'state'
			elsif row[:entity_type] == 'DI'
				row[:entity_type] = 'district'
			elsif row[:entity_type] == 'SC'
				row[:entity_type] = 'school'
			else
				row[:entity_type].downcase!
			end
			row
		end
		.transform('Create date_valid field', WithBlock) do |row|
			if row[:year] == 2018
				row[:date_valid] = '2018-01-01 00:00:00'
			elsif row[:year] == 2017
				row[:date_valid] = '2017-01-01 00:00:00'
			elsif row[:year] == '20182019'
				row[:date_valid] = '2019-01-01 00:00:00'
			end
			row
		end
		.transform('Create state id and name field', WithBlock) do |row|
			if row[:entity_type] == 'state'
				row[:state_id] = 'state'
				row[:district_name] = 'state'
				row[:school_name] = 'state'
			elsif ['district','school'].include? row[:entity_type]
				if [414,409].include? row[:data_type_id]
					row[:state_id] = row[:state_id]
				else
					row[:state_id] = row[:county_id].to_s + row[:district_id].to_s + row[:school_id].to_s
				end
			end
			row
		end
		.transform('Create field to skip bad breakdowns', WithBlock) do |row|
			if ['Foster Care','Homeless'].include? row[:breakdown]
				row[:breakdown] = 'Skip'
			else
				row[:breakdown] = row[:breakdown]
			end
			row
		end
		.transform('Skip bad entity_types',DeleteRows,:entity_type,'lc')
		.transform('delete "-1.0000" values',DeleteRows,:value,'-1.0000')
		.transform('delete "-1" values',DeleteRows,:value,'-1')
		.transform('delete "-1" values',DeleteRows,:value,'-1.00')
		.transform('delete "*" values',DeleteRows,:value,'*')
		.transform('skip bad breakdowns', DeleteRows, :breakdown, 'Skip')
		.transform('map breakdown ids',HashLookup,:breakdown, map_breakdown_id,to: :breakdown_id)
		.transform('map subject ids',HashLookup,:subject, map_subject_id,to: :subject_id)
		.transform('map grades',HashLookup,:data_type_id, map_grade,to: :grade)
	end

	def config_hash
	{
		source_id: 31,
        state: 'ne'
	}
	end
end

NEMetricsProcessor2019CSA.new(ARGV[0],max:nil).run